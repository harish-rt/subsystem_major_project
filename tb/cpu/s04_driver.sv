//==============================================================================
// s04_driver : pipelined AXI4 master driver (outstanding + OoO + interleave)
//
// Structure
//   main_phase  : get_next_item -> item_done (early) -> push to aw_q / ar_q
//   aw_thread   : drives AW channel, then hands the packet to w_q
//   w_data_thread: drives W channel in AW order
//   ar_thread   : drives AR channel
//   b_resp_thread: collects B by BID, completes the packet
//   r_data_thread: collects R beats by RID, completes the packet at RLAST
//
// Sequence side requirements
//   - unique non-zero AWID/ARID per concurrent sequence (same ID = in-order)
//   - set_response_queue_depth(-1) in the sequence
//   - sequence calls get_response(pkt) after finish_item(pkt)
//
// Assumption: s04_seq_item.RDATA / RRESP are dynamic arrays.
//   If they are queues, remove the "new[]" lines in main_phase and use
//   push_back per beat in r_data_thread instead.
//==============================================================================


//------------------------------------------------------------------------------
// Callback
//------------------------------------------------------------------------------
class master_driver_callback extends uvm_callback;
    `uvm_object_utils(master_driver_callback)
    `NEW_OBJ

    // pre_drive  : fires when the item is accepted by the driver (issue time)
    // post_drive : fires when the response (B or last R) is received
    virtual task pre_drive(s04_seq_item pkt);
        `uvm_info(get_full_name(), "pre_drive :: executing s04_driver callback", UVM_LOW)
    endtask : pre_drive

    virtual task post_drive(s04_seq_item pkt);
        `uvm_info(get_full_name(), "post_drive :: executing s04_driver callback", UVM_LOW)
    endtask : post_drive
endclass : master_driver_callback


//------------------------------------------------------------------------------
// Driver
//------------------------------------------------------------------------------
class s04_driver extends uvm_driver #(s04_seq_item, s04_seq_item);
    `uvm_component_utils(s04_driver)
    `uvm_register_cb(s04_driver, master_driver_callback)

    virtual axi4_tb_intf        drv_intf;

    int                         drv_burst_count;

    // knobs
    int unsigned                max_outstanding = 16;   // limit of in-flight txns
    int unsigned                bready_pct      = 100;  // % of cycles BREADY=1
    int unsigned                rready_pct      = 100;  // % of cycles RREADY=1

    // state
    int unsigned                outstanding;

    s04_seq_item                aw_q[$];                // waiting for AW
    s04_seq_item                ar_q[$];                // waiting for AR
    s04_seq_item                w_q[$];                 // AW done, W pending
    s04_seq_item                b_pend[int][$];         // keyed by AWID
    s04_seq_item                r_pend[int][$];         // keyed by ARID
    int                         r_beat[int];            // beats received per RID

    `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db#(int unsigned)::get(this, "", "MAX_OUTSTANDING", max_outstanding));
        void'(uvm_config_db#(int unsigned)::get(this, "", "BREADY_PCT",      bready_pct));
        void'(uvm_config_db#(int unsigned)::get(this, "", "RREADY_PCT",      rready_pct));
    endfunction

    extern task          reset_phase     (uvm_phase phase);
    extern task          main_phase      (uvm_phase phase);

    extern task          aw_thread       ();
    extern task          ar_thread       ();
    extern task          w_data_thread   ();
    extern task          b_resp_thread   ();
    extern task          r_data_thread   ();

    extern function void finish_txn      (s04_seq_item p);
    extern function void flush           ();

    extern task          drive_write_addr(s04_seq_item pkt);
    extern task          drive_write_data(s04_seq_item pkt);
    extern task          drive_read_add  (s04_seq_item pkt);
endclass : s04_driver


//------------------------------------------------------------------------------
// Reset phase : drive safe defaults immediately (VALID low during reset),
//               then wait for reset release
//------------------------------------------------------------------------------
task s04_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), "reset_phase: Driving bus to safe defaults...", UVM_LOW)

    flush();

    @(drv_intf.axi4_drv_cb);

    drv_intf.axi4_drv_cb.AWADDR   <= '0;
    drv_intf.axi4_drv_cb.AWBURST  <= '0;
    drv_intf.axi4_drv_cb.AWCACHE  <= '0;
    drv_intf.axi4_drv_cb.AWID     <= '0;
    drv_intf.axi4_drv_cb.AWLEN    <= '0;
    drv_intf.axi4_drv_cb.AWLOCK   <= '0;
    drv_intf.axi4_drv_cb.AWPROT   <= '0;
    drv_intf.axi4_drv_cb.AWQOS    <= '0;
    drv_intf.axi4_drv_cb.AWREGION <= '0;
    drv_intf.axi4_drv_cb.AWSIZE   <= '0;
    drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;

    drv_intf.axi4_drv_cb.WDATA    <= '0;
    drv_intf.axi4_drv_cb.WSTRB    <= '0;
    drv_intf.axi4_drv_cb.WLAST    <= 1'b0;
    drv_intf.axi4_drv_cb.WVALID   <= 1'b0;

    drv_intf.axi4_drv_cb.BREADY   <= 1'b0;

    drv_intf.axi4_drv_cb.ARADDR   <= '0;
    drv_intf.axi4_drv_cb.ARBURST  <= '0;
    drv_intf.axi4_drv_cb.ARCACHE  <= '0;
    drv_intf.axi4_drv_cb.ARID     <= '0;
    drv_intf.axi4_drv_cb.ARLEN    <= '0;
    drv_intf.axi4_drv_cb.ARLOCK   <= '0;
    drv_intf.axi4_drv_cb.ARPROT   <= '0;
    drv_intf.axi4_drv_cb.ARQOS    <= '0;
    drv_intf.axi4_drv_cb.ARREGION <= '0;
    drv_intf.axi4_drv_cb.ARSIZE   <= '0;
    drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;

    drv_intf.axi4_drv_cb.RREADY   <= 1'b0;

    // wait until reset is actively low, then for clean release
    wait (drv_intf.ARESETn === 1'b0);
    @(posedge drv_intf.ACLK iff drv_intf.ARESETn === 1'b1);

    @(drv_intf.axi4_drv_cb);
    `uvm_info(get_full_name(), "reset_phase: Bus reset complete.", UVM_LOW)
    phase.drop_objection(this);
endtask : reset_phase


//------------------------------------------------------------------------------
// Main phase
//------------------------------------------------------------------------------
task s04_driver::main_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "main_phase running (pipelined)", UVM_MEDIUM)

    fork
        aw_thread();
        ar_thread();
        w_data_thread();
        b_resp_thread();
        r_data_thread();
    join_none

    forever begin
        s04_seq_item p;

        seq_item_port.get_next_item(req);
        $cast(p, req);
        seq_item_port.item_done();              // release sequencer; response comes later

        wait (outstanding < max_outstanding);
        outstanding++;

        `uvm_do_callbacks(s04_driver, master_driver_callback, pre_drive(p));

        if (p.operation == WRITE) begin
            b_pend[p.AWID].push_back(p);
            aw_q.push_back(p);
        end
        else if (p.operation == READ) begin
            p.RDATA = new[p.ARLEN + 1];         // dynamic arrays assumed
            p.RRESP = new[p.ARLEN + 1];
            r_pend[p.ARID].push_back(p);
            ar_q.push_back(p);
        end
    end
endtask : main_phase


//------------------------------------------------------------------------------
// Channel threads
//------------------------------------------------------------------------------
task s04_driver::aw_thread();
    s04_seq_item p;
    forever begin
        wait (aw_q.size() > 0);
        p = aw_q.pop_front();
        drive_write_addr(p);                    // returns after AWREADY
        w_q.push_back(p);                       // W follows AW order
    end
endtask : aw_thread


task s04_driver::ar_thread();
    s04_seq_item p;
    forever begin
        wait (ar_q.size() > 0);
        p = ar_q.pop_front();
        drive_read_add(p);                      // returns after ARREADY
    end
endtask : ar_thread


task s04_driver::w_data_thread();
    s04_seq_item p;
    forever begin
        wait (w_q.size() > 0);
        p = w_q.pop_front();
        drive_write_data(p);                    // len+1 beats, WLAST on final
    end
endtask : w_data_thread


// B channel: BREADY driven per cycle, handshake = BVALID && previously driven BREADY
task s04_driver::b_resp_thread();
    s04_seq_item p;
    int          id;
    bit          b_rdy = 1'b0;

    forever begin
        @(drv_intf.axi4_drv_cb);

        if (drv_intf.axi4_drv_cb.BVALID === 1'b1 && b_rdy) begin
            id = drv_intf.axi4_drv_cb.BID;
            if (!b_pend.exists(id) || b_pend[id].size() == 0) begin
                `uvm_error(get_full_name(), $sformatf("B response with unexpected BID=%0d", id))
            end
            else begin
                p       = b_pend[id].pop_front();   // same ID stays in order
                p.BID   = id;
                p.BRESP = response_t'(drv_intf.axi4_drv_cb.BRESP);
                `uvm_do_callbacks(s04_driver, master_driver_callback, post_drive(p));
                finish_txn(p);
            end
        end

        b_rdy = ($urandom_range(1, 100) <= bready_pct);
        drv_intf.axi4_drv_cb.BREADY <= b_rdy;
    end
endtask : b_resp_thread


// R channel: beats collected per RID, packet completes at RLAST
task s04_driver::r_data_thread();
    s04_seq_item p;
    int          id, beat;
    bit          r_rdy = 1'b0;

    forever begin
        @(drv_intf.axi4_drv_cb);

        if (drv_intf.axi4_drv_cb.RVALID === 1'b1 && r_rdy) begin
            id = drv_intf.axi4_drv_cb.RID;
            if (!r_pend.exists(id) || r_pend[id].size() == 0) begin
                `uvm_error(get_full_name(), $sformatf("R beat with unexpected RID=%0d", id))
            end
            else begin
                p    = r_pend[id][0];           // peek: not done until RLAST
                beat = r_beat.exists(id) ? r_beat[id] : 0;

                if (beat > p.ARLEN) begin
                    `uvm_error(get_full_name(),
                        $sformatf("Too many R beats for RID=%0d (ARLEN=%0d)", id, p.ARLEN))
                end
                else begin
                    p.RDATA[beat] = drv_intf.axi4_drv_cb.RDATA;
                    p.RRESP[beat] = response_t'(drv_intf.axi4_drv_cb.RRESP);
                end
                r_beat[id] = beat + 1;

                if (drv_intf.axi4_drv_cb.RLAST === 1'b1) begin
                    if (beat != p.ARLEN)
                        `uvm_error(get_full_name(),
                            $sformatf("RLAST at beat %0d, expected %0d (RID=%0d)", beat, p.ARLEN, id))
                    void'(r_pend[id].pop_front());
                    r_beat[id] = 0;
                    `uvm_do_callbacks(s04_driver, master_driver_callback, post_drive(p));
                    finish_txn(p);
                end
            end
        end

        r_rdy = ($urandom_range(1, 100) <= rready_pct);
        drv_intf.axi4_drv_cb.RREADY <= r_rdy;
    end
endtask : r_data_thread


//------------------------------------------------------------------------------
// Completion / housekeeping
//------------------------------------------------------------------------------
function void s04_driver::finish_txn(s04_seq_item p);
    p.set_id_info(p);                           // p is the original req: routes to its sequence
    seq_item_port.put_response(p);
    if (outstanding > 0) outstanding--;
    drv_burst_count++;
endfunction : finish_txn


// call on mid-test reset
function void s04_driver::flush();
    aw_q.delete();
    ar_q.delete();
    w_q.delete();
    b_pend.delete();
    r_pend.delete();
    r_beat.delete();
    outstanding = 0;
endfunction : flush


//------------------------------------------------------------------------------
// Channel drivers (address / write data only; responses are in the threads)
//------------------------------------------------------------------------------
task s04_driver::drive_write_addr(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.AWADDR   <= pkt.AWADDR;
    drv_intf.axi4_drv_cb.AWBURST  <= pkt.AWBURST;
    drv_intf.axi4_drv_cb.AWCACHE  <= pkt.AWCACHE;
    drv_intf.axi4_drv_cb.AWID     <= pkt.AWID;
    drv_intf.axi4_drv_cb.AWLEN    <= pkt.AWLEN;
    drv_intf.axi4_drv_cb.AWSIZE   <= pkt.AWSIZE;
    drv_intf.axi4_drv_cb.AWQOS    <= pkt.AWQOS;
    drv_intf.axi4_drv_cb.AWVALID  <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.AWREADY !== 1'b1);

    drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;
endtask : drive_write_addr


task s04_driver::drive_write_data(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    for (int i = 0; i <= pkt.AWLEN; i++) begin
        drv_intf.axi4_drv_cb.WDATA  <= pkt.WDATA[i];
        drv_intf.axi4_drv_cb.WSTRB  <= pkt.WSTRB[i];
        drv_intf.axi4_drv_cb.WVALID <= 1'b1;
        drv_intf.axi4_drv_cb.WLAST  <= (i == pkt.AWLEN) ? 1'b1 : 1'b0;

        do begin
            @(drv_intf.axi4_drv_cb);
        end while (drv_intf.axi4_drv_cb.WREADY !== 1'b1);
    end
    drv_intf.axi4_drv_cb.WVALID <= 1'b0;
    drv_intf.axi4_drv_cb.WLAST  <= 1'b0;
endtask : drive_write_data


task s04_driver::drive_read_add(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.ARADDR   <= pkt.ARADDR;
    drv_intf.axi4_drv_cb.ARBURST  <= pkt.ARBURST;
    drv_intf.axi4_drv_cb.ARCACHE  <= pkt.ARCACHE;
    drv_intf.axi4_drv_cb.ARID     <= pkt.ARID;
    drv_intf.axi4_drv_cb.ARLEN    <= pkt.ARLEN;
    drv_intf.axi4_drv_cb.ARSIZE   <= pkt.ARSIZE;
    drv_intf.axi4_drv_cb.ARQOS    <= pkt.ARQOS;
    drv_intf.axi4_drv_cb.ARVALID  <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.ARREADY !== 1'b1);

    drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;
endtask : drive_read_add


/*
class master_driver_callback extends uvm_callback;
    `uvm_object_utils(master_driver_callback)
    `NEW_OBJ

    virtual task pre_drive(s04_seq_item pkt);
        `uvm_info(get_full_name(), "pre_drive :: executing s04_driver callback", UVM_LOW)
    endtask : pre_drive

    virtual task post_drive(s04_seq_item pkt);
        `uvm_info(get_full_name(), "post_drive :: executing s04_driver callback", UVM_LOW)
    endtask : post_drive
endclass : master_driver_callback

class s04_driver extends uvm_driver #(s04_seq_item, s04_seq_item);
    `uvm_component_utils(s04_driver)
    `uvm_register_cb(s04_driver, master_driver_callback)

    virtual axi4_tb_intf        drv_intf;

    int                         drv_burst_count;
    s04_seq_item                pkt;
    bit disable_cpu_fork    =   0;

    int unsigned outstanding;
    int unsigned max_outstanding = 16;
    
    s04_seq_item w_q[$];                        // AW done, W data pending
    s04_seq_item b_pend[int][$];                // keyed by AWID
    s04_seq_item r_pend[int][$];                // keyed by ARID

    `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    	void'(uvm_config_db#(bit)::get(this,"","DCF",disable_cpu_fork));
        //if (!uvm_config_db#(virtual axi4_tb_intf.DRIVER_MOD)::get(this,"","S04",drv_intf)) begin
        //    `uvm_fatal(get_full_name(), "virtual axi4_tb_intf get failed from config_db!")
        //end
    endfunction

    extern task reset_phase      (uvm_phase phase);
    extern task main_phase       (uvm_phase phase);
    extern task drive_write_addr  (s04_seq_item pkt);
    extern task drive_write_data (s04_seq_item pkt);
    extern task drive_write_resp (s04_seq_item pkt);
    extern task drive_read_add   (s04_seq_item pkt);
    extern task drive_read_data  (s04_seq_item pkt);
    extern task w_data_thread    ();
    extern task b_resp_thread    ();
    extern task r_data_thread    ();
    extern function void finish_txn(s04_seq_item p);
endclass : s04_driver


// Reset Phase
task s04_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), "reset_phase: Driving bus to safe defaults...", UVM_LOW)

    // Wait until reset is actively low, then wait for clean release
    wait(drv_intf.ARESETn === 1'b0);
    @(posedge drv_intf.ACLK iff drv_intf.ARESETn === 1'b1);

    drv_intf.axi4_drv_cb.AWADDR   <= '0;
    drv_intf.axi4_drv_cb.AWBURST  <= '0;
    drv_intf.axi4_drv_cb.AWCACHE  <= '0;
    drv_intf.axi4_drv_cb.AWID     <= '0;
    drv_intf.axi4_drv_cb.AWLEN    <= '0;
    drv_intf.axi4_drv_cb.AWLOCK   <= '0;
    drv_intf.axi4_drv_cb.AWPROT   <= '0;
    drv_intf.axi4_drv_cb.AWQOS    <= '0;
    drv_intf.axi4_drv_cb.AWREGION <= '0;
    drv_intf.axi4_drv_cb.AWSIZE   <= '0;
    drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;

    drv_intf.axi4_drv_cb.WDATA    <= '0;
    drv_intf.axi4_drv_cb.WSTRB    <= '0;
    drv_intf.axi4_drv_cb.WLAST    <= 1'b0;
    drv_intf.axi4_drv_cb.WVALID   <= 1'b0;

    drv_intf.axi4_drv_cb.BREADY   <= 1'b0;

    drv_intf.axi4_drv_cb.ARADDR   <= '0;
    drv_intf.axi4_drv_cb.ARBURST  <= '0;
    drv_intf.axi4_drv_cb.ARCACHE  <= '0;
    drv_intf.axi4_drv_cb.ARID     <= '0;
    drv_intf.axi4_drv_cb.ARLEN    <= '0;
    drv_intf.axi4_drv_cb.ARLOCK   <= '0;
    drv_intf.axi4_drv_cb.ARPROT   <= '0;
    drv_intf.axi4_drv_cb.ARQOS    <= '0;
    drv_intf.axi4_drv_cb.ARREGION <= '0;
    drv_intf.axi4_drv_cb.ARSIZE   <= '0;
    drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;

    drv_intf.axi4_drv_cb.RREADY   <= 1'b0;

    @(drv_intf.axi4_drv_cb);
    `uvm_info(get_full_name(), "reset_phase: Bus reset complete.", UVM_LOW)
    phase.drop_objection(this);
endtask : reset_phase


// Main Phase
/*
task s04_driver::main_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "main_phase running", UVM_MEDIUM)

    forever begin
        seq_item_port.get_next_item(pkt);

        `uvm_do_callbacks(s04_driver, master_driver_callback, pre_drive(pkt));

        if (pkt.operation == WRITE) begin
            if(disable_cpu_fork) begin
                drive_write_addr(pkt);
                drive_write_data(pkt);
                drive_write_resp(pkt);
            end
            else begin
                fork
                    drive_write_addr(pkt);
                    drive_write_data(pkt);
                    drive_write_resp(pkt);
                join
            end
        end 
        else if (pkt.operation == READ) begin
            if(disable_cpu_fork) begin
                drive_read_add(pkt);
                drive_read_data(pkt);
            end
            else begin
                fork
                    drive_read_add(pkt);
                    drive_read_data(pkt);
                join
            end
        end

        `uvm_do_callbacks(s04_driver, master_driver_callback, post_drive(pkt));
        seq_item_port.item_done(pkt);
    end
endtask : main_phase
*/
/*
task s04_driver::main_phase(uvm_phase phase);
  fork
    w_data_thread();
    b_resp_thread();
    r_data_thread();
  join_none

  forever begin
    s04_seq_item p;
    seq_item_port.get_next_item(req);
    $cast(p, req);
    seq_item_port.item_done();           // no response yet

    wait (outstanding < max_outstanding);
    outstanding++;

    if (p.operation == WRITE) begin
      b_pend[p.AWID].push_back(p);
      drive_write_addr(p);               // AW only; returns after AWREADY
      w_q.push_back(p);                  // W thread picks it up in AW order
    end
    else begin
      r_pend[p.ARID].push_back(p);
      drive_read_add(p);                 // AR only; returns after ARREADY
    end
  end
endtask

task s04_driver::w_data_thread();
  s04_seq_item p;
  forever begin
    wait (w_q.size() > 0);
    p = w_q.pop_front();
    drive_write_data(p);                 // len+1 beats, WLAST at the end
  end
endtask

task s04_driver::b_resp_thread();
  s04_seq_item p;
    int id;
  forever begin
    // wait for BVALID (drive BREADY here), then:
    id = drv_intf.axi4_drv_cb.BID;
    p = b_pend[id].pop_front();          // same ID stays in order
    p.BRESP   = response_t'(drv_intf.axi4_drv_cb.BRESP);
    finish_txn(p);
  end
endtask

task s04_driver::r_data_thread();
  s04_seq_item p;
    int id;
  forever begin
    // wait for RVALID, then:
    id = drv_intf.axi4_drv_cb.RID;
    p = r_pend[id][0];                   // peek: not done until RLAST
    drive_read_data(p);
    //p.capture_beat(drv_intf.axi4_drv_cb.RDATA, drv_intf.axi4_drv_cb.RRESP);
    if (drv_intf.axi4_drv_cb.RLAST) begin
      void'(r_pend[id].pop_front());
      finish_txn(p);
    end
  end
endtask

function void s04_driver::finish_txn(s04_seq_item p);
  s04_seq_item rsp = p;                       // or clone
  rsp.set_id_info(p);                    // routes it to the right sequence
  seq_item_port.put_response(rsp);
  outstanding--;
endfunction

// Channel Drivers
task s04_driver::drive_write_addr(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.AWADDR   <= pkt.AWADDR;
    drv_intf.axi4_drv_cb.AWBURST  <= pkt.AWBURST;
    drv_intf.axi4_drv_cb.AWCACHE  <= pkt.AWCACHE;
    drv_intf.axi4_drv_cb.AWID     <= pkt.AWID;
    drv_intf.axi4_drv_cb.AWLEN    <= pkt.AWLEN;
    drv_intf.axi4_drv_cb.AWSIZE   <= pkt.AWSIZE;
    drv_intf.axi4_drv_cb.AWQOS    <= pkt.AWQOS;
    drv_intf.axi4_drv_cb.AWVALID  <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.AWREADY !== 1'b1);

    drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;
endtask : drive_write_addr


task s04_driver::drive_write_data(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    for (int i = 0; i <= pkt.AWLEN; i++) begin
        drv_intf.axi4_drv_cb.WDATA  <= pkt.WDATA[i];
        drv_intf.axi4_drv_cb.WSTRB  <= pkt.WSTRB[i];
        drv_intf.axi4_drv_cb.WVALID <= 1'b1;
        drv_intf.axi4_drv_cb.WLAST  <= (i == pkt.AWLEN) ? 1'b1 : 1'b0;

        do begin
            @(drv_intf.axi4_drv_cb);
        end while (drv_intf.axi4_drv_cb.WREADY !== 1'b1);
    end
    drv_intf.axi4_drv_cb.WVALID <= 1'b0;
    drv_intf.axi4_drv_cb.WLAST  <= 1'b0;
endtask : drive_write_data


task s04_driver::drive_write_resp(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.BREADY <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.BVALID !== 1'b1);
    pkt.BID     = drv_intf.axi4_drv_cb.BID;
    pkt.BRESP   = response_t'(drv_intf.axi4_drv_cb.BRESP);

    drv_intf.axi4_drv_cb.BREADY <= 1'b0;
    drv_burst_count++;
endtask : drive_write_resp


task s04_driver::drive_read_add(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.ARADDR   <= pkt.ARADDR;
    drv_intf.axi4_drv_cb.ARBURST  <= pkt.ARBURST;
    drv_intf.axi4_drv_cb.ARCACHE  <= pkt.ARCACHE;
    drv_intf.axi4_drv_cb.ARID     <= pkt.ARID;
    drv_intf.axi4_drv_cb.ARLEN    <= pkt.ARLEN;
    drv_intf.axi4_drv_cb.ARSIZE   <= pkt.ARSIZE;
    drv_intf.axi4_drv_cb.ARQOS    <= pkt.ARQOS;
    drv_intf.axi4_drv_cb.ARVALID  <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.ARREADY !== 1'b1);

    drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;
endtask : drive_read_add


task s04_driver::drive_read_data(s04_seq_item pkt);
    bit rlast = 1'b0;
    int beat  = 0;

    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.RREADY <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
        if (drv_intf.axi4_drv_cb.RVALID === 1'b1) begin
            pkt.RDATA[beat] = drv_intf.axi4_drv_cb.RDATA;
            pkt.RRESP[beat] = response_t'(drv_intf.axi4_drv_cb.RRESP);
            beat++;
            if (drv_intf.axi4_drv_cb.RLAST === 1'b1) begin
                rlast = 1'b1;
            end
        end
    end while (!rlast);

    drv_intf.axi4_drv_cb.RREADY <= 1'b0;
endtask : drive_read_data
