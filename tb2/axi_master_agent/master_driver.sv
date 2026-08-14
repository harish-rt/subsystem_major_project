/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_driver.sv                        */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2022                       */
/*                                                                        */
/* All Rights Reserved                                                    */
/*                                                                        */
/* NOTICE: All information contained herein is, and remains the           */
/* property of Raiton semiconductor PVT. LTD. and its suppliers           */
/* ,if any.  The intellectual and  technical concepts contained           */
/* herein  are proprietary to  Raiton  semiconductor  PVT. LTD.           */
/* they are protected  by trade secrets and / or copyright law.           */
/* Dissemination of this  information  or reproduction of  this           */
/* material or code is strictly forbidden unless  prior written           */
/* permission is obtained from Raiton semiconductor PVT. LTD.             */
/*                                                                        */
/* RAITON_COPYRIGHT_END                                                   */
// callbacks--
class master_driver_callback extends uvm_callback;
   `uvm_object_utils(master_driver_callback)

   function new (string name = "master_driver_callback");
      super.new(name);
   endfunction

  
   virtual task pre_drive (master_seq_item pkt,mailbox #(master_seq_item) waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx);
     `uvm_info (get_full_name () , "pre_drive :: executing master_driver call back" , UVM_LOW)
   endtask : pre_drive

   virtual task post_drive (master_seq_item pkt,virtual master_intf.DRV_MOD_master vif,uvm_seq_item_pull_port #(master_seq_item) port);
     `uvm_info (get_full_name () , "post_drive :: executing master_driver call back" , UVM_LOW)
   endtask : post_drive

   virtual task drive_rsp(master_seq_item pkt);

   endtask
endclass : master_driver_callback

class master_drv_rsp_cb extends master_driver_callback;
  `uvm_object_utils(master_drv_rsp_cb)

  function new(string name = "master_drv_rsp_cb");
    super.new(name);
  endfunction

  virtual task drive_rsp(master_seq_item pkt);
    //seq_item_port.put_response(pkt);
  endtask


endclass

class master_driver extends uvm_driver #(master_seq_item,master_seq_item);
   `uvm_component_utils (master_driver)
   `uvm_register_cb (master_driver , master_driver_callback)

   virtual master_intf.DRV_MOD_master        master_drv_intf;
   int drv_burst_count;

    mailbox #(master_seq_item) waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx; // mailboxes for read/write channels

   function new (string name = "master_driver" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern task run_phase  (uvm_phase phase);
   extern task reset_phase (uvm_phase phase);
   extern task get_packet ();
   extern task drive_write_add ();
   extern task drive_write_data ();
   extern task drive_read_add ();
   extern task drive_read_data ();
   extern task drive_write_resp ();
endclass :master_driver

task master_driver :: reset_phase (uvm_phase phase);
   `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)
   `uvm_info(get_full_name(),"........master_driver.......reset_phase Driving initial values to interface", UVM_LOW);
     //drive initial values to 0
     //wait( master_drv_intf.areset_n );
     master_drv_intf.mas_drv_cb.awaddr    <= 'b0;
     master_drv_intf.mas_drv_cb.awburst   <= 'b0;
     master_drv_intf.mas_drv_cb.awcache   <= 'b0;
     master_drv_intf.mas_drv_cb.awid      <= 'b0;
     master_drv_intf.mas_drv_cb.awlen     <= 'b0;
     master_drv_intf.mas_drv_cb.awlock    <= 'b0;
     master_drv_intf.mas_drv_cb.awprot    <= 'b0;
     master_drv_intf.mas_drv_cb.awqos     <= 'b0;
     master_drv_intf.mas_drv_cb.awregion  <= 'b0;
     master_drv_intf.mas_drv_cb.awsize    <= 'b0;
     master_drv_intf.mas_drv_cb.awvalid   <= 'b0;
     master_drv_intf.mas_drv_cb.bready    <= 'b0;
     master_drv_intf.mas_drv_cb.rready    <= 'b0;
     master_drv_intf.mas_drv_cb.wdata     <= 'b0;
     master_drv_intf.mas_drv_cb.wlast     <= 'b0;
     master_drv_intf.mas_drv_cb.wstrobe   <= 'b0;
     master_drv_intf.mas_drv_cb.wvalid    <= 'b0;
     master_drv_intf.mas_drv_cb.araddr    <= 'b0;
     master_drv_intf.mas_drv_cb.arburst   <= 'b0;
     master_drv_intf.mas_drv_cb.arcache   <= 'b0;
     master_drv_intf.mas_drv_cb.arid      <= 'b0;
     master_drv_intf.mas_drv_cb.arlen     <= 'b0;
     master_drv_intf.mas_drv_cb.arlock    <= 'b0;
     master_drv_intf.mas_drv_cb.arprot    <= 'b0;
     master_drv_intf.mas_drv_cb.arqos     <= 'b0;
     master_drv_intf.mas_drv_cb.arregion  <= 'b0;
     master_drv_intf.mas_drv_cb.arsize    <= 'b0;
     master_drv_intf.mas_drv_cb.arvalid   <= 'b0;
   `uvm_info(get_full_name(),"........master_driver.......reset_phase Driving initial values to interface is DONE", UVM_LOW);
endtask :reset_phase

task master_driver :: run_phase (uvm_phase phase);

   fork
    get_packet();
    drive_write_add();
    drive_write_data();
    drive_read_add();
    drive_read_data();
    drive_write_resp();
    join

endtask : run_phase

task master_driver :: get_packet();
    master_seq_item pkt;
    waddress_mbx=new();
    wdata_mbx=new();
    raddress_mbx=new();
    rdata_mbx=new();
    wresponse_mbx=new();
    
    forever begin
        seq_item_port.get_next_item(req);
        //pre_drive task to corrupt packet
        `uvm_do_callbacks(master_driver,master_driver_callback,pre_drive(pkt,waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx));
        $cast(pkt,req.clone);
        if(pkt.operation == WRITE ) begin
            waddress_mbx.put(pkt);
            wdata_mbx.put(pkt);
        end
        if(pkt.operation == READ) begin
            raddress_mbx.put(pkt);
            //rdata_mbx.put(pkt);
        end
        
        `uvm_do_callbacks(master_driver,master_driver_callback,post_drive(pkt,master_drv_intf, seq_item_port));
        seq_item_port.item_done();
   end
endtask


task master_driver :: drive_write_add();
master_seq_item pkt;

forever begin
     waddress_mbx.get(pkt);

     master_drv_intf.mas_drv_cb.awaddr   <= pkt.awaddr;
     master_drv_intf.mas_drv_cb.awburst  <= pkt.awburst;
     master_drv_intf.mas_drv_cb.awcache  <= pkt.awcache;
     master_drv_intf.mas_drv_cb.awid     <= pkt.awid;
     master_drv_intf.mas_drv_cb.awlen    <= pkt.awlen;
     master_drv_intf.mas_drv_cb.awsize   <= pkt.awsize;
     master_drv_intf.mas_drv_cb.awvalid  <= 1'b1 ;

     @(master_drv_intf.mas_drv_cb);
     wait(master_drv_intf.mas_drv_cb.awready == 1);
     master_drv_intf.mas_drv_cb.awvalid  <= 1'b0 ;
   end
endtask

task master_driver :: drive_write_data();
    master_seq_item pkt;
  forever begin
    wdata_mbx.get(pkt); 
    for(int i=0;i<=pkt.awlen;i++) begin
      master_drv_intf.mas_drv_cb.wdata    <= pkt.wdata[i];
      master_drv_intf.mas_drv_cb.wstrobe  <= pkt.wstrobe[i];
      master_drv_intf.mas_drv_cb.wvalid   <= 1'b1;
      master_drv_intf.mas_drv_cb.wlast    <= (i == pkt.awlen ) ? 1'b1 : 1'b0;
      
      @(master_drv_intf.mas_drv_cb);
      wait(master_drv_intf.mas_drv_cb.wready == 1'b1);
      master_drv_intf.mas_drv_cb.wvalid   <= 1'b0;
      master_drv_intf.mas_drv_cb.wlast    <= 1'b0;
    end
    `if CORE_EN == 0
      seq_item_port.put_response(pkt);
    `endif
    //`uvm_do_callbacks(master_driver,master_driver_callback,drive_rsp(pkt));
     wresponse_mbx.put(pkt);
 end
endtask

task master_driver :: drive_write_resp();
master_seq_item pkt;
  forever begin
      wresponse_mbx.get(pkt);

      master_drv_intf.mas_drv_cb.bready <= 1'b1;
      @(master_drv_intf.mas_drv_cb);
      wait(master_drv_intf.mas_drv_cb.bvalid ==1'b1);
      pkt.bresp = master_drv_intf.mas_drv_cb.bresp;
      master_drv_intf.mas_drv_cb.bready <= 1'b0;
      drv_burst_count++;
  end
endtask

task master_driver :: drive_read_add();
  master_seq_item pkt;
  forever begin
      raddress_mbx.get(pkt);
      
      master_drv_intf.mas_drv_cb.araddr   <= pkt.araddr;
      master_drv_intf.mas_drv_cb.arburst  <= pkt.arburst;
      master_drv_intf.mas_drv_cb.arcache  <= pkt.arcache;
      master_drv_intf.mas_drv_cb.arid     <= pkt.arid;
      master_drv_intf.mas_drv_cb.arlen    <= pkt.arlen;
      master_drv_intf.mas_drv_cb.arsize   <= pkt.arsize;
      master_drv_intf.mas_drv_cb.arvalid  <= 1'b1 ;

      @(master_drv_intf.mas_drv_cb);
      wait(master_drv_intf.mas_drv_cb.arready ==1'b1);
      master_drv_intf.mas_drv_cb.arvalid  <= 1'b0 ;
   end
endtask


task master_driver :: drive_read_data();
  master_seq_item pkt;
  bit rlast;

  forever begin
    rdata_mbx.get(pkt);
    rlast=0;
    do begin
      master_drv_intf.mas_drv_cb.rready <= 1'b1;
      @(master_drv_intf.mas_drv_cb);

      wait(master_drv_intf.mas_drv_cb.rvalid ==1'b1);
      pkt.rdata[0] = master_drv_intf.mas_drv_cb.rdata;
      pkt.rresp[0] = master_drv_intf.mas_drv_cb.rresp;
      master_drv_intf.mas_drv_cb.rready <= 1'b0;

      if(master_drv_intf.mas_drv_cb.rlast==1'b1)
        rlast=1'b1;

    end while (rlast==1'b0);
    `if CORE_EN == 0
      seq_item_port.put_response(pkt);
    `endif
    //`uvm_do_callbacks(master_driver,master_driver_callback,drive_rsp(pkt));
 end
endtask


