/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_master_driver.sv                        */
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
class axi_cdma_axi_master_driver_callback extends uvm_callback;
   `uvm_object_utils(axi_cdma_axi_master_driver_callback)

   function new (string name = "axi_cdma_axi_master_driver_callback");
      super.new(name);
   endfunction

  
   virtual task pre_drive (axi_cdma_axi_master_seq_item pkt,mailbox #(axi_cdma_axi_master_seq_item) waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx);
     `uvm_info (get_full_name () , "pre_drive :: executing axi_cdma_axi_master_driver call back" , UVM_LOW)
   endtask : pre_drive

   virtual task post_drive (axi_cdma_axi_master_seq_item pkt,virtual axi_cdma_axi_master_intf.DRV_MOD_master vif,uvm_seq_item_pull_port #(axi_cdma_axi_master_seq_item) port);
     `uvm_info (get_full_name () , "post_drive :: executing axi_cdma_axi_master_driver call back" , UVM_LOW)
   endtask : post_drive
endclass : axi_cdma_axi_master_driver_callback

class axi_cdma_axi_master_driver extends uvm_driver #(axi_cdma_axi_master_seq_item,axi_cdma_axi_master_seq_item);
   `uvm_component_utils (axi_cdma_axi_master_driver)
   `uvm_register_cb (axi_cdma_axi_master_driver , axi_cdma_axi_master_driver_callback)

   virtual axi_cdma_axi_master_intf.DRV_MOD_master        master_drv_intf;

    mailbox #(axi_cdma_axi_master_seq_item) waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx; // mailboxes for read/write channels

   function new (string name = "axi_cdma_axi_master_driver" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern task main_phase  (uvm_phase phase);
   extern task reset_phase (uvm_phase phase);
   extern task get_packet ();
   extern task drive_write_add ();
   extern task drive_write_data ();
   extern task drive_read_add ();
   extern task drive_read_data ();
   extern task drive_write_resp ();
   extern task wait_trigger_put_response();

endclass :axi_cdma_axi_master_driver

task axi_cdma_axi_master_driver :: reset_phase (uvm_phase phase);
   `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)
   `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......reset_phase Driving initial values to interface", UVM_LOW);
     //drive initial values to 0
     //wait( master_drv_intf.areset_n );
     master_drv_intf.mas_drv_cb.awaddr <= 'b0;
     master_drv_intf.mas_drv_cb.awburst <= 'b0;
     master_drv_intf.mas_drv_cb.awcache <= 'b0;
     master_drv_intf.mas_drv_cb.awid <= 'b0;
     master_drv_intf.mas_drv_cb.awlen <= 'b0;
     master_drv_intf.mas_drv_cb.awlock <= 'b0;
     master_drv_intf.mas_drv_cb.awprot <= 'b0;
     master_drv_intf.mas_drv_cb.awqos <= 'b0;
     master_drv_intf.mas_drv_cb.awregion <= 'b0;
     master_drv_intf.mas_drv_cb.awsize <= 'b0;
     master_drv_intf.mas_drv_cb.awvalid <= 'b0;
     master_drv_intf.mas_drv_cb.bready <= 'b0;
     master_drv_intf.mas_drv_cb.rready <= 'b0;
     master_drv_intf.mas_drv_cb.wdata <= 'b0;
     master_drv_intf.mas_drv_cb.wlast <= 'b0;
     master_drv_intf.mas_drv_cb.wstrobe <= 'b0;
     master_drv_intf.mas_drv_cb.wvalid <= 'b0;
     master_drv_intf.mas_drv_cb.araddr <= 'b0;
     master_drv_intf.mas_drv_cb.arburst <= 'b0;
     master_drv_intf.mas_drv_cb.arcache <= 'b0;
     master_drv_intf.mas_drv_cb.arid <= 'b0;
     master_drv_intf.mas_drv_cb.arlen <= 'b0;
     master_drv_intf.mas_drv_cb.arlock <= 'b0;
     master_drv_intf.mas_drv_cb.arprot <= 'b0;
     master_drv_intf.mas_drv_cb.arqos <= 'b0;
     master_drv_intf.mas_drv_cb.arregion <= 'b0;
     master_drv_intf.mas_drv_cb.arsize <= 'b0;
     master_drv_intf.mas_drv_cb.arvalid <= 'b0;
   `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......reset_phase Driving initial values to interface is DONE", UVM_LOW);
endtask :reset_phase

task axi_cdma_axi_master_driver :: main_phase (uvm_phase phase);
 //   axi_cdma_axi_master_seq_item pkt ;
    `uvm_info ("axi_cdma_axi_master_driver", "main_phase" , UVM_MEDIUM);

   fork
    get_packet();
    drive_write_add();
    drive_write_data();
    drive_read_add();
    drive_read_data();
    drive_write_resp();
    join

endtask : main_phase

task axi_cdma_axi_master_driver :: get_packet(); // to get new packets from seq and populate respective queues with relevent data.
    axi_cdma_axi_master_seq_item pkt;
    waddress_mbx=new();
    wdata_mbx=new();
    raddress_mbx=new();
    rdata_mbx=new();
    wresponse_mbx=new();
    `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......get packet task triggred",  UVM_LOW);
    forever begin
     //@( master_drv_intf.mas_drv_cb);
    seq_item_port.get_next_item(pkt);
    //pre_drive task to corrupt packet
    `uvm_do_callbacks(axi_cdma_axi_master_driver,axi_cdma_axi_master_driver_callback,pre_drive(pkt,waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx));
    `uvm_info(get_full_name(),$sformatf("........axi_cdma_axi_master_driver.......main_phase got packet -- operation = %s",pkt.operation.name()),  UVM_LOW);
    //DRIVE TO INTERFACE
    //`uvm_info(get_full_name(), "pkt at axi_cdma_axi_master_driver  -- trying to print packet",UVM_LOW)
    if(pkt.operation == WRITE ) begin
      waddress_mbx.put(pkt);
      wdata_mbx.put(pkt);
    end
    if(pkt.operation == READ) begin
      raddress_mbx.put(pkt);
      rdata_mbx.put(pkt);
    end
    wait_trigger_put_response();
    `uvm_do_callbacks(axi_cdma_axi_master_driver,axi_cdma_axi_master_driver_callback,post_drive(pkt,master_drv_intf, seq_item_port));
    seq_item_port.item_done(pkt);
    //`uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......main.......phase after item done", UVM_LOW);
   end
endtask

//drive tasks for phases

task axi_cdma_axi_master_driver :: drive_write_add();
axi_cdma_axi_master_seq_item pkt;
pkt = axi_cdma_axi_master_seq_item :: type_id ::create("pkt");
`uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_write_add task triggred",  UVM_LOW);
forever begin
   waddress_mbx.get(pkt); //blocking statement
   repeat(pkt.cmd2cmd_dly) @( master_drv_intf.mas_drv_cb);
   //assert address information on write address channel
     master_drv_intf.mas_drv_cb.awaddr   <= pkt.awaddr;
     master_drv_intf.mas_drv_cb.awburst  <= pkt.awburst;
     master_drv_intf.mas_drv_cb.awcache  <= pkt.awcache;
     master_drv_intf.mas_drv_cb.awid     <= pkt.awid;
     master_drv_intf.mas_drv_cb.awlen    <= pkt.awlen;
     master_drv_intf.mas_drv_cb.awlock   <= pkt.awlock;
     master_drv_intf.mas_drv_cb.awprot   <= pkt.awprot;
     master_drv_intf.mas_drv_cb.awqos    <= pkt.awqos;
     master_drv_intf.mas_drv_cb.awregion <= pkt.awregion;
     master_drv_intf.mas_drv_cb.awsize   <= pkt.awsize;
  // repeat(pkt.add_valid_dly) @( master_drv_intf.mas_drv_cb);
     master_drv_intf.mas_drv_cb.awvalid  <= 1 ;
     @( master_drv_intf.mas_drv_cb);
     wait(master_drv_intf.mas_drv_cb.awready ==1);
     master_drv_intf.mas_drv_cb.awvalid  <= 0 ;
    // `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_write_add got handshake",  UVM_LOW);
   end
endtask

task axi_cdma_axi_master_driver :: drive_read_add();
axi_cdma_axi_master_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_read_add task triggred",  UVM_LOW);
  forever begin
   raddress_mbx.get(pkt); //must be blocking statement
  // `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_read_add task mbx.get(pkt) done",  UVM_LOW);
   repeat(pkt.cmd2cmd_dly) @( master_drv_intf.mas_drv_cb);
   //assert address information on read address channel
     master_drv_intf.mas_drv_cb.araddr   <= pkt.araddr;
     master_drv_intf.mas_drv_cb.arburst  <= pkt.arburst;
     master_drv_intf.mas_drv_cb.arcache  <= pkt.arcache;
     master_drv_intf.mas_drv_cb.arid     <= pkt.arid;
     master_drv_intf.mas_drv_cb.arlen    <= pkt.arlen;
     master_drv_intf.mas_drv_cb.arlock   <= pkt.arlock;
     master_drv_intf.mas_drv_cb.arprot   <= pkt.arprot;
     master_drv_intf.mas_drv_cb.arqos    <= pkt.arqos;
     master_drv_intf.mas_drv_cb.arregion <= pkt.arregion;
     master_drv_intf.mas_drv_cb.arsize   <= pkt.arsize;

   //repeat(pkt.add_valid_dly) @( master_drv_intf.mas_drv_cb);
     master_drv_intf.mas_drv_cb.arvalid  <= 1 ;
     @( master_drv_intf.mas_drv_cb);
     wait(master_drv_intf.mas_drv_cb.arready ==1);
     master_drv_intf.mas_drv_cb.arvalid  <= 0 ;
   end
  endtask


task axi_cdma_axi_master_driver :: drive_write_resp();  //will trigger after data phase  // figure out what to do when this phase is triggred multiple times without the last one completing.
axi_cdma_axi_master_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_write_resp task triggred",  UVM_LOW);
  forever begin
    wresponse_mbx.get(pkt);
 //  repeat(pkt.resp_ready_dly) @( master_drv_intf.mas_drv_cb);
     master_drv_intf.mas_drv_cb.bready <= 1;
    wait(master_drv_intf.mas_drv_cb.bvalid ==1);
    @( master_drv_intf.mas_drv_cb);
    master_drv_intf.mas_drv_cb.bready <= 0;
    //post drive callback
    //`uvm_do_callbacks(axi_cdma_axi_master_driver,axi_cdma_axi_master_driver_callback,post_drive(pkt,master_drv_intf,seq_item_port));
  end
endtask


task axi_cdma_axi_master_driver :: drive_write_data();
axi_cdma_axi_master_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_write_data task triggred",  UVM_LOW);
 forever begin
   wdata_mbx.get(pkt); //must be blocking statement
  // `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_write_data task mbx.get(pkt) done",  UVM_LOW);
   repeat(pkt.add2data_dly) @( master_drv_intf.mas_drv_cb);
   for(int i=0;i<=pkt.awlen;i++) begin
   repeat(pkt.write_valid2valid_dly[i]) @( master_drv_intf.mas_drv_cb);
   master_drv_intf.mas_drv_cb.wdata <= pkt.wdata[i];
   master_drv_intf.mas_drv_cb.wstrobe <= pkt.wstrobe[i];
   master_drv_intf.mas_drv_cb.wvalid <= 1;
   master_drv_intf.mas_drv_cb.wlast <= (i== pkt.awlen ) ? 1'b1 : 1'b0;
   wait(master_drv_intf.mas_drv_cb.wready ==1);
   master_drv_intf.mas_drv_cb.wvalid <= 0;
   master_drv_intf.mas_drv_cb.wlast  <= 0;
   @( master_drv_intf.mas_drv_cb);
   end
     wresponse_mbx.put(pkt);
 end
endtask

task axi_cdma_axi_master_driver :: drive_read_data();
axi_cdma_axi_master_seq_item pkt;
   int i;
   bit got_rlast;
`uvm_info("axi_cdma_axi_master_driver::drive_read_data","........axi_cdma_axi_master_driver.......drive_read_data task triggred",  UVM_LOW);
forever begin
   rdata_mbx.get(pkt);
   i=0; got_rlast=0;
 //  `uvm_info(get_full_name(),"........axi_cdma_axi_master_driver.......drive_read_data task mbx.get(pkt) done",  UVM_LOW);
`uvm_info("axi_cdma_axi_master_driver::drive_read_data",$sformatf("before do_while loop pkt.read_ready2ready_dly[i]=%0d",pkt.read_ready2ready_dly[i]),  UVM_DEBUG);
   do begin
   repeat(pkt.read_ready2ready_dly[i]) @(master_drv_intf.mas_drv_cb);
   `uvm_info("axi_cdma_axi_master_driver::drive_read_data",$sformatf("inside do_while loop pkt.read_ready2ready_dly[i]=%0d",pkt.read_ready2ready_dly[i]),  UVM_DEBUG);
    //`uvm_info("axi_cdma_axi_master_driver::drive_read_data",$sformatf("Before Handshake master_drv_intf.mas_drv_cb.rvalid=%b master_drv_intf.mas_drv_cb.araddr=%0h",master_drv_intf.mas_drv_cb.rvalid,master_drv_intf.mas_drv_cb.araddr),  UVM_DEBUG);
    wait(master_drv_intf.mas_drv_cb.rvalid ==1);
    //`uvm_info("axi_cdma_axi_master_driver::drive_read_data",$sformatf("master_drv_intf.mas_drv_cb.rvalid=%b master_drv_intf.mas_drv_cb.araddr=%0h",master_drv_intf.mas_drv_cb.rvalid,master_drv_intf.mas_drv_cb.araddr),  UVM_DEBUG);
    master_drv_intf.mas_drv_cb.rready <= 1;
    if(master_drv_intf.mas_drv_cb.rlast==1) got_rlast=1; // indicates last beat
    @( master_drv_intf.mas_drv_cb);
    master_drv_intf.mas_drv_cb.rready <= 0;
    i=i+1;
   end while (got_rlast==0);
   //post drive callback
   //`uvm_do_callbacks(axi_cdma_axi_master_driver,axi_cdma_axi_master_driver_callback,post_drive(pkt,master_drv_intf,seq_item_port));
 end
endtask

task axi_cdma_axi_master_driver :: wait_trigger_put_response();
    uvm_event wait_trigger_event;
    uvm_event_pool m_event_pool;

    `uvm_info("axi_cdma_axi_master_driver :: wait_trigger_put_response","waiting for trigger_put_response ",UVM_NONE);
     m_event_pool = uvm_event_pool::get_global_pool;
     wait_trigger_event = m_event_pool.get("put_response_trigger");
     wait_trigger_event.wait_trigger();
    `uvm_info("axi_cdma_axi_master_driver :: wait_trigger_put_response","GOT trigger_put_response event ",UVM_LOW);

endtask : wait_trigger_put_response
