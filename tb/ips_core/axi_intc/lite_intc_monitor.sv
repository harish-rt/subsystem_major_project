class lite_intc_monitor extends uvm_monitor;
    `uvm_component_utils(lite_intc_monitor)
    `NEW_COMP
    
    uvm_analysis_port #(lite_intc_seq_item)     mon_ap;
	virtual axi4_lite_intc_intf.axi4_lite_mon_mod	mon_if;

    lite_intc_seq_item                          sq_itm_h,aw_pkt,w_pkt,b_pkt,ar_pkt,r_pkt;
    intc_config_obj                             obj;

    lite_intc_seq_item  wr_addr_queue[$],rd_addr_queue[$],wr_data_queue[$],rd_data_queue[$],wr_resp_queue[$];

   extern function void build_phase              	(uvm_phase phase);
   extern function void connect_phase            	(uvm_phase phase);
   extern function void end_of_elaboration_phase 	(uvm_phase phase);
   extern function void start_of_simulation_phase	(uvm_phase phase);
   extern function void extract_phase            	(uvm_phase phase);
   extern function void check_phase              	(uvm_phase phase);
   extern function void report_phase             	(uvm_phase phase);
   extern function void final_phase              	(uvm_phase phase);
   extern task main_phase                         	(uvm_phase phase);
   extern task mon_write_address					();
   extern task mon_write_data						();
   extern task mon_write_resp						();
   extern task mon_read_address						();
   extern task mon_read_data						();
   extern task merge_write							();
   extern task merge_read							();

endclass 

  function void lite_intc_monitor :: build_phase (uvm_phase phase);
     super.build_phase (phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")

        mon_ap 			= new ("mon_ap",this);
        `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : build_phase

  function void lite_intc_monitor :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void lite_intc_monitor :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void lite_intc_monitor :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void lite_intc_monitor :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void lite_intc_monitor :: check_phase (uvm_phase phase);
     super.check_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void lite_intc_monitor :: report_phase (uvm_phase phase);
     super.report_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void lite_intc_monitor :: final_phase (uvm_phase phase);
     super.final_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

    task lite_intc_monitor :: main_phase (uvm_phase phase);
        `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)

        fork
            forever begin
                @(mon_if.axi4_lite_mon_cb);        
                fork
                    mon_write_address();
                    mon_write_data();
                    mon_write_resp();
                join
                merge_write();
            end
            forever begin
                @(mon_if.axi4_lite_mon_cb);   
                fork
                    mon_read_address();
                    mon_read_data();
                join
                merge_read();
            end
        join
 
    endtask:main_phase

    task lite_intc_monitor :: mon_write_address();
        wait(mon_if.axi4_lite_mon_cb.axi_awvalid && mon_if.axi4_lite_mon_cb.axi_awready) begin
            aw_pkt = lite_intc_seq_item :: type_id :: create ("aw_pkt");
            aw_pkt.axi_awaddr     = mon_if.axi4_lite_mon_cb.axi_awaddr;
            aw_pkt.write          = lite_intc_seq_item::WRITE;
            `uvm_info("axi4_lite_mon_AW",$sformatf("write_address = %0h,write=%s",aw_pkt.axi_awaddr,aw_pkt.write.name),UVM_NONE)
            wr_addr_queue.push_back(aw_pkt);
        end
    endtask

    task lite_intc_monitor :: mon_write_data();
        wait(mon_if.axi4_lite_mon_cb.axi_wvalid && mon_if.axi4_lite_mon_cb.axi_wready) begin
            w_pkt = lite_intc_seq_item :: type_id :: create ("w_pkt");
            w_pkt.axi_wdata      = mon_if.axi4_lite_mon_cb.axi_wdata;
            w_pkt.axi_wstrb      = mon_if.axi4_lite_mon_cb.axi_wstrb;
            `uvm_info("axi4_lite_mon_WD",$sformatf("write_data = %0h",w_pkt.axi_wdata),UVM_LOW)
            wr_data_queue.push_back(w_pkt);
        end
    endtask

    task lite_intc_monitor :: mon_write_resp();
        wait(mon_if.axi4_lite_mon_cb.axi_bvalid && mon_if.axi4_lite_mon_cb.axi_bready) begin
            b_pkt = lite_intc_seq_item :: type_id :: create ("b_pkt");
            b_pkt.axi_bresp      = mon_if.axi4_lite_mon_cb.axi_bresp;
            `uvm_info("axi4_lite_mon_bresp",$sformatf("write_bresp = %b",b_pkt.axi_bresp),UVM_LOW)
            wr_resp_queue.push_back(b_pkt);
        end
    endtask

    task lite_intc_monitor :: mon_read_address();
        wait(mon_if.axi4_lite_mon_cb.axi_arvalid && mon_if.axi4_lite_mon_cb.axi_arready) begin
            ar_pkt = lite_intc_seq_item :: type_id :: create ("ar_pkt");
            ar_pkt.axi_araddr     = mon_if.axi4_lite_mon_cb.axi_araddr;
            ar_pkt.write          = lite_intc_seq_item::READ;
            `uvm_info("axi4_lite_mon_read_addr",$sformatf("read_address = %0h,write=%s",ar_pkt.axi_araddr,ar_pkt.write),UVM_LOW)
            rd_addr_queue.push_back(ar_pkt); 
        end
    endtask

    task lite_intc_monitor :: mon_read_data();
        wait(mon_if.axi4_lite_mon_cb.axi_rvalid && mon_if.axi4_lite_mon_cb.axi_rready) begin
            r_pkt = lite_intc_seq_item :: type_id :: create ("r_pkt");
            r_pkt.axi_rdata      = mon_if.axi4_lite_mon_cb.axi_rdata;
            r_pkt.axi_rresp      = mon_if.axi4_lite_mon_cb.axi_rresp;
            `uvm_info("axi4_lite_mon_read_data",$sformatf("rdata = %0h",r_pkt.axi_rdata),UVM_LOW)
            rd_data_queue.push_back(r_pkt);
        end 
    endtask

    task lite_intc_monitor :: merge_write();
        lite_intc_seq_item w_merge = lite_intc_seq_item :: type_id :: create("w_merge");
        if(wr_addr_queue.size() > 0 && wr_data_queue.size() > 0 && wr_resp_queue.size() > 0 )
            begin
                w_merge.axi_areset_n	= mon_if.areset_n;
                w_merge.axi_awaddr 	= wr_addr_queue[0].axi_awaddr;
                w_merge.axi_wdata 	= wr_data_queue[0].axi_wdata;
                w_merge.axi_wstrb 	= wr_data_queue[0].axi_wstrb;
                //w_merge.axi_wstrb 	= sq_itm_h.axi_wstrb;
                w_merge.axi_bresp 	= wr_resp_queue[0].axi_bresp;
                w_merge.write 		= wr_addr_queue[0].write;
                void'(wr_addr_queue.pop_front);
                void'(wr_data_queue.pop_front);
                void'(wr_resp_queue.pop_front);
                `uvm_info("axi4_lite_mon_WRITE",w_merge.sprint(),UVM_LOW)
                mon_ap.write(w_merge);
            end
    endtask

    task lite_intc_monitor :: merge_read();
        lite_intc_seq_item r_merge = lite_intc_seq_item :: type_id :: create("r_merge");
        if(rd_addr_queue.size() > 0 && rd_data_queue.size() > 0 )
            begin
                r_merge.axi_araddr    = rd_addr_queue[0].axi_araddr;
                r_merge.axi_rdata     = rd_data_queue[0].axi_rdata;
		        r_merge.axi_rresp 	= rd_data_queue[0].axi_rresp;
                r_merge.write         = rd_addr_queue[0].write;
                void'(rd_addr_queue.pop_front);
                void'(rd_data_queue.pop_front);
                `uvm_info("axi4_lite_mon_READ",r_merge.sprint(),UVM_LOW)
                mon_ap.write(r_merge);
            end
    endtask

/*
class lite_intc_monitor extends uvm_monitor;
    `uvm_component_utils(lite_intc_monitor)
    `NEW_COMP
    
    uvm_analysis_port #(lite_intc_seq_item)     mon_ap;
    virtual axi4_lite_intc_intf.axi4_lite_mon_mod mon_if;

    intc_config_obj                             obj;

    // Separate queues to temporarily hold transaction phases
    lite_intc_seq_item wr_addr_queue[$];
    lite_intc_seq_item wr_data_queue[$];
    lite_intc_seq_item wr_resp_queue[$];
    lite_intc_seq_item rd_addr_queue[$];
    lite_intc_seq_item rd_data_queue[$];

   extern function void build_phase                (uvm_phase phase);
   extern task main_phase                           (uvm_phase phase);
   extern task mon_write_address                    ();
   extern task mon_write_data                       ();
   extern task mon_write_resp                       ();
   extern task mon_read_address                     ();
   extern task mon_read_data                        ();
   extern task merge_write                          ();
   extern task merge_read                           ();
endclass 

function void lite_intc_monitor :: build_phase (uvm_phase phase);
    super.build_phase (phase);
    if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))
        `uvm_fatal(get_full_name(),"Config_obj get Failure")
    mon_ap = new ("mon_ap", this);
endfunction : build_phase

// MAIN PHASE: Spawns independent, non-blocking asynchronous monitoring routines
task lite_intc_monitor :: main_phase (uvm_phase phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)

    fork
        mon_write_address();
        mon_write_data();
        mon_write_resp();
        mon_read_address();
        mon_read_data();
        merge_write();
        merge_read();
    join_none
endtask:main_phase

task lite_intc_monitor :: mon_write_address();
    forever begin
        @(mon_if.axi4_lite_mon_cb);
        if(mon_if.axi4_lite_mon_cb.axi_awvalid && mon_if.axi4_lite_mon_cb.axi_awready) begin
            // FIXED: Handle declared locally to avoid shared-memory race conditions
            lite_intc_seq_item local_item = lite_intc_seq_item::type_id::create("local_aw");
            local_item.axi_awaddr = mon_if.axi4_lite_mon_cb.axi_awaddr;
            local_item.write      = lite_intc_seq_item::WRITE;
            `uvm_info("axi4_lite_mon_AW", $sformatf("write_address = %0h", local_item.axi_awaddr), UVM_NONE)
            wr_addr_queue.push_back(local_item);
        end
    end
endtask

task lite_intc_monitor :: mon_write_data();
    forever begin
        @(mon_if.axi4_lite_mon_cb);
        if(mon_if.axi4_lite_mon_cb.axi_wvalid && mon_if.axi4_lite_mon_cb.axi_wready) begin
            lite_intc_seq_item local_item = lite_intc_seq_item::type_id::create("local_wd");
            local_item.axi_wdata  = mon_if.axi4_lite_mon_cb.axi_wdata;
            local_item.axi_wstrb  = mon_if.axi4_lite_mon_cb.axi_wstrb;
            `uvm_info("axi4_lite_mon_WD", $sformatf("write_data = %0h", local_item.axi_wdata), UVM_LOW)
            wr_data_queue.push_back(local_item);
        end
    end
endtask

task lite_intc_monitor :: mon_write_resp();
    forever begin
        @(mon_if.axi4_lite_mon_cb);
        if(mon_if.axi4_lite_mon_cb.axi_bvalid && mon_if.axi4_lite_mon_cb.axi_bready) begin
            lite_intc_seq_item local_item = lite_intc_seq_item::type_id::create("local_br");
            local_item.axi_bresp  = mon_if.axi4_lite_mon_cb.axi_bresp;
            `uvm_info("axi4_lite_mon_bresp", $sformatf("write_bresp = %b", local_item.axi_bresp), UVM_LOW)
            wr_resp_queue.push_back(local_item);
        end
    end
endtask

task lite_intc_monitor :: mon_read_address();
    forever begin
        @(mon_if.axi4_lite_mon_cb);
        if(mon_if.axi4_lite_mon_cb.axi_arvalid && mon_if.axi4_lite_mon_cb.axi_arready) begin
            lite_intc_seq_item local_item = lite_intc_seq_item::type_id::create("local_ar");
            local_item.axi_araddr = mon_if.axi4_lite_mon_cb.axi_araddr;
            local_item.write      = lite_intc_seq_item::READ;
            `uvm_info("axi4_lite_mon_read_addr", $sformatf("read_address = %0h", local_item.axi_araddr), UVM_LOW)
            rd_addr_queue.push_back(local_item); 
        end
    end
endtask

task lite_intc_monitor :: mon_read_data();
    forever begin
        @(mon_if.axi4_lite_mon_cb);
        if(mon_if.axi4_lite_mon_cb.axi_rvalid && mon_if.axi4_lite_mon_cb.axi_rready) begin
            lite_intc_seq_item local_item = lite_intc_seq_item::type_id::create("local_rd");
            local_item.axi_rdata  = mon_if.axi4_lite_mon_cb.axi_rdata;
            local_item.axi_rresp  = mon_if.axi4_lite_mon_cb.axi_rresp;
            `uvm_info("axi4_lite_mon_read_data", $sformatf("rdata = %0h", local_item.axi_rdata), UVM_LOW)
            rd_data_queue.push_back(local_item);
        end 
    end
endtask

// MERGE TASKS: Check continuously for items available to build complete transactions
task lite_intc_monitor :: merge_write();
    forever begin
        // Block evaluation until every required queue phase holds data
        wait(wr_addr_queue.size() > 0 && wr_data_queue.size() > 0 && wr_resp_queue.size() > 0);
        
        begin
            lite_intc_seq_item s_merge_h = lite_intc_seq_item::type_id::create("s_merge_h");
            s_merge_h.axi_areset_n  = mon_if.areset_n;
            s_merge_h.axi_awaddr    = wr_addr_queue[0].axi_awaddr;
            s_merge_h.axi_wdata     = wr_data_queue[0].axi_wdata;
            s_merge_h.axi_wstrb     = wr_data_queue[0].axi_wstrb;
            s_merge_h.axi_bresp     = wr_resp_queue[0].axi_bresp;
            s_merge_h.write         = wr_addr_queue[0].write;
            
            void'(wr_addr_queue.pop_front());
            void'(wr_data_queue.pop_front());
            void'(wr_resp_queue.pop_front());
            
            `uvm_info("axi4_lite_mon_WRITE", s_merge_h.sprint(), UVM_LOW)
            mon_ap.write(s_merge_h);
        end
    end
    endtask

task lite_intc_monitor :: merge_read();
    forever begin
        wait(rd_addr_queue.size() > 0 && rd_data_queue.size() > 0);
        
        begin
            lite_intc_seq_item s_merge_h = lite_intc_seq_item::type_id::create("s_merge_h");
            s_merge_h.axi_araddr    = rd_addr_queue[0].axi_araddr;
            s_merge_h.axi_rdata     = rd_data_queue[0].axi_rdata;
            s_merge_h.axi_rresp     = rd_data_queue[0].axi_rresp;
            s_merge_h.write         = rd_addr_queue[0].write;
            
            void'(rd_addr_queue.pop_front());
            void'(rd_data_queue.pop_front());
            
            `uvm_info("axi4_lite_mon_READ", s_merge_h.sprint(), UVM_LOW)
            mon_ap.write(s_merge_h);
        end
    end
endtask
*/
