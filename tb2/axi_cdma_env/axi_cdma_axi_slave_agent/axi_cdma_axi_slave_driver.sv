/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_slave_driver.sv                         */
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
class axi_cdma_axi_slave_driver_callback extends uvm_callback;
   `uvm_object_utils(axi_cdma_axi_slave_driver_callback)

   function new (string name = "axi_cdma_axi_slave_driver_callback");
      super.new(name);
   endfunction

   virtual task pre_drive (axi_cdma_axi_slave_seq_item pkt);
     `uvm_info (get_full_name () , "pre_drive :: executing axi_cdma_axi_slave_driver call back" , UVM_LOW)
   endtask : pre_drive
   virtual task post_drive (axi_cdma_axi_slave_seq_item pkt);
     `uvm_info (get_full_name () , "post_drive :: executing axi_cdma_axi_slave_driver call back" , UVM_LOW)
   endtask : post_drive
endclass : axi_cdma_axi_slave_driver_callback

class axi_cdma_axi_slave_driver extends uvm_driver #(axi_cdma_axi_slave_seq_item,axi_cdma_axi_slave_seq_item);
   `uvm_component_utils (axi_cdma_axi_slave_driver)
   `uvm_register_cb (axi_cdma_axi_slave_driver , axi_cdma_axi_slave_driver_callback)

   virtual axi_cdma_axi_slave_intf.DRV_MOD_slave        slave_drv_intf;
   mailbox #(axi_cdma_axi_slave_seq_item) waddress_mbx,wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx; // mailboxes for read/write channels

   function new (string name = "axi_cdma_axi_slave_driver" , uvm_component parent);
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
endclass :axi_cdma_axi_slave_driver

task axi_cdma_axi_slave_driver :: reset_phase (uvm_phase phase);
     `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)
     //drive initial value to 0
     `uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......reset_phase Driving initial values to interface", UVM_LOW);
     slave_drv_intf.slv_drv_cb.arready <='b0;
     slave_drv_intf.slv_drv_cb.rdata <='b0;
     slave_drv_intf.slv_drv_cb.rid <='b0;
     slave_drv_intf.slv_drv_cb.rlast <='b0;
     slave_drv_intf.slv_drv_cb.rresp <='b0;
     slave_drv_intf.slv_drv_cb.rvalid <='b0;
     slave_drv_intf.slv_drv_cb.awready <='b0;
     slave_drv_intf.slv_drv_cb.bresp <='b0;
     slave_drv_intf.slv_drv_cb.bid <='b0;
     slave_drv_intf.slv_drv_cb.bvalid <='b0;
     slave_drv_intf.slv_drv_cb.wready <='b0;
endtask :reset_phase

task axi_cdma_axi_slave_driver :: main_phase (uvm_phase phase);
      `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)

   fork
    get_packet();
    drive_write_add();
    drive_write_data();
    drive_read_add();
    drive_write_resp();
    join

  endtask : main_phase

task axi_cdma_axi_slave_driver :: get_packet(); // to get new packets from seq and populate respective queues with relevent data.
    axi_cdma_axi_slave_seq_item pkt;
    wdata_mbx=new();
    rdata_mbx=new();
    waddress_mbx=new();
    raddress_mbx=new();
    wresponse_mbx=new();
    `uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......get packet task triggred",  UVM_LOW);
   forever begin
    `uvm_info("axi_cdma_axi_slave_driver","get packet task waiting for getting pkt from sequencer",  UVM_LOW);
      seq_item_port.get_next_item(pkt);
      //pre_drive task to corrupt packet here
      `uvm_do_callbacks(axi_cdma_axi_slave_driver,axi_cdma_axi_slave_driver_callback,pre_drive(pkt));
      `uvm_info(get_full_name(),$sformatf("........axi_cdma_axi_slave_driver.......main_phase got packet -- operation = %s",pkt.operation.name()),  UVM_LOW);
    if(pkt.operation == WRITE ) begin
      wdata_mbx.put(pkt);
      waddress_mbx.put(pkt);
    end
    if(pkt.operation == READ) begin
      rdata_mbx.put(pkt);
      raddress_mbx.put(pkt);
    end
    seq_item_port.item_done(pkt);
    `uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......main.......phase after item done", UVM_LOW);
  end
endtask

task axi_cdma_axi_slave_driver :: drive_write_add();
axi_cdma_axi_slave_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_write_add task triggred",  UVM_LOW);
 forever begin
   waddress_mbx.get(pkt);
   wait(slave_drv_intf.slv_drv_cb.awvalid ==1);
   //repeat(pkt.add_ready_dly) @( slave_drv_intf.slv_drv_cb); // delay in asserting ready
   slave_drv_intf.slv_drv_cb.awready <='b1;
   @( slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.awready <='b0;
 end
endtask

task axi_cdma_axi_slave_driver :: drive_read_add();
axi_cdma_axi_slave_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_read_add task triggred",  UVM_LOW);
 forever begin
   raddress_mbx.get(pkt);
   wait(slave_drv_intf.slv_drv_cb.arvalid ==1);
   repeat(pkt.add_ready_dly) @( slave_drv_intf.slv_drv_cb); //delay in asserting ready
   slave_drv_intf.slv_drv_cb.arready <='b1;
   @( slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.arready <='b0;
   drive_read_data();
 end
endtask

task axi_cdma_axi_slave_driver :: drive_write_resp();  //will trigger after data phase  // figure out what to do when this phase is triggred multiple times without the last one completing.
axi_cdma_axi_slave_seq_item pkt;
    `uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_write_resp task triggred",  UVM_LOW);
  forever begin
   wresponse_mbx.get(pkt);
   //repeat(pkt.data2resp_dly) @( slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.bresp <= pkt.bresp;
   slave_drv_intf.slv_drv_cb.bid <= pkt.bid;
   slave_drv_intf.slv_drv_cb.bvalid <='b1;
   wait(slave_drv_intf.slv_drv_cb.bready ==1);
   @( slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.bvalid <='b0;
   //Post drive callback
   `uvm_do_callbacks(axi_cdma_axi_slave_driver,axi_cdma_axi_slave_driver_callback,post_drive(pkt));
  end
endtask

task axi_cdma_axi_slave_driver :: drive_write_data();
axi_cdma_axi_slave_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_write_data task triggred",  UVM_LOW);
 forever begin
   wdata_mbx.get(pkt);
   `uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_write_data task mbx.get(pkt) done",  UVM_LOW);
   //repeat(address2data_phase_delay) @( slave_drv_intf.mas_drv_cb);//controled by master
   for(int i=0;i<=pkt.awlen;i++)begin
   `uvm_info(get_full_name(),$sformatf("AWLEN %d, i=%0d",pkt.awlen,i),  UVM_LOW);
   //capture beat info if required
   //repeat(pkt.write_ready2ready_dly[i]) @(slave_drv_intf.slv_drv_cb);
   wait(slave_drv_intf.slv_drv_cb.wvalid ==1);
   repeat(pkt.write_ready2ready_dly[i]) @(slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.wready <= 1;
   @( slave_drv_intf.slv_drv_cb);
  // wait(slave_drv_intf.slv_drv_cb.wvalid ==0);
   slave_drv_intf.slv_drv_cb.wready <= 0;
   end
  wresponse_mbx.put(pkt);
 end
endtask

task axi_cdma_axi_slave_driver :: drive_read_data();
axi_cdma_axi_slave_seq_item pkt;
`uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_read_data task triggred",  UVM_LOW);
   rdata_mbx.get(pkt); //must be blocking statement
   `uvm_info(get_full_name(),"........axi_cdma_axi_slave_driver.......drive_read_data task mbx.get(pkt) done",  UVM_LOW);
   repeat(pkt.add2data_dly) @( slave_drv_intf.slv_drv_cb);
   for(int i=0;i<=pkt.arlen;i++) begin
   //assert beat data information on read data channel
   //assret rlast with last beat of data.
   slave_drv_intf.slv_drv_cb.rdata <= pkt.rdata[i];
   slave_drv_intf.slv_drv_cb.rid <= pkt.rid;
   slave_drv_intf.slv_drv_cb.rresp <= pkt.rresp[i];
   repeat(pkt.read_valid2valid_dly[i]) @( slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.rvalid <= 1;
   slave_drv_intf.slv_drv_cb.rlast <= (i== pkt.arlen ) ? 1'b1 : 1'b0;
   wait(slave_drv_intf.slv_drv_cb.rready ==1);
   @( slave_drv_intf.slv_drv_cb);
   slave_drv_intf.slv_drv_cb.rvalid <= 0;
   slave_drv_intf.slv_drv_cb.rlast  <= 0;
  //Post drive callback
  `uvm_do_callbacks(axi_cdma_axi_slave_driver,axi_cdma_axi_slave_driver_callback,post_drive(pkt));
 end
endtask


