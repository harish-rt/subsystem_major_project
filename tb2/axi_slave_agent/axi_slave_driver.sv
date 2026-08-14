/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_slave_driver.sv                         */
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
class axi_slave_driver_callback extends uvm_callback;
   `uvm_object_utils(axi_slave_driver_callback)

   function new (string name = "axi_slave_driver_callback");
      super.new(name);
   endfunction

   virtual task pre_drive (axi_slave_seq_item pkt);
     `uvm_info (get_full_name () , "pre_drive :: executing axi_slave_driver call back" , UVM_LOW)
   endtask : pre_drive

   virtual task post_drive (axi_slave_seq_item pkt);
     `uvm_info (get_full_name () , "post_drive :: executing axi_slave_driver call back" , UVM_LOW)
   endtask : post_drive

endclass : axi_slave_driver_callback

class axi_slave_driver extends uvm_driver #(axi_slave_seq_item,axi_slave_seq_item);
   `uvm_component_utils (axi_slave_driver)
   `uvm_register_cb (axi_slave_driver , axi_slave_driver_callback)

   virtual axi_slave_intf.DRV_MOD_slave         slave_drv_intf;
   mailbox #(axi_slave_seq_item)                waddress_mbx,wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx; // mailboxes for read/write channels

   function new (string name = "axi_slave_driver" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern task main_phase       (uvm_phase phase);
   extern task reset_phase      (uvm_phase phase);
   extern task get_packet       ();
   extern task drive_write_add  ();
   extern task drive_write_data ();
   extern task drive_read_add   ();
   extern task drive_read_data  ();
   extern task drive_write_resp ();
   
endclass :axi_slave_driver

task axi_slave_driver :: reset_phase (uvm_phase phase);
     `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)
     //drive initial value to 0
     `uvm_info(get_full_name(),"........axi_slave_driver.......reset_phase Driving initial values to interface", UVM_LOW);
     slave_drv_intf.slv_drv_cb.arready  <='b0;
     slave_drv_intf.slv_drv_cb.rdata    <='b0;

     slave_drv_intf.slv_drv_cb.rresp    <='b0;
     slave_drv_intf.slv_drv_cb.rvalid   <='b0;
     slave_drv_intf.slv_drv_cb.awready  <='b0;
     slave_drv_intf.slv_drv_cb.bresp    <='b0;

     slave_drv_intf.slv_drv_cb.bvalid   <='b0;
     slave_drv_intf.slv_drv_cb.wready   <='b0;
endtask :reset_phase

task axi_slave_driver :: main_phase (uvm_phase phase);
      `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)

   fork
     get_packet       ();
     drive_write_add  ();
     drive_write_data ();
     drive_write_resp ();    
     drive_read_add   ();
     drive_read_data  ();
   join

  endtask : main_phase

task axi_slave_driver :: get_packet(); // to get new packets from seq and populate respective queues with relevent data.
    axi_slave_seq_item pkt;
    wdata_mbx     = new();
    rdata_mbx     = new();
    waddress_mbx  = new();
    raddress_mbx  = new();
    wresponse_mbx = new();
    `uvm_info(get_full_name(),"........axi_slave_driver.......get packet task triggred",  UVM_LOW);
    forever begin
      seq_item_port.get_next_item(req);
      if(!$cast(pkt,req.clone()))
        `uvm_fatal("axi_slave_driver","Packet casting failed");
      //pre_drive task to corrupt packet here
      `uvm_do_callbacks(axi_slave_driver,axi_slave_driver_callback,pre_drive(pkt));
      `uvm_info(get_full_name(),$sformatf("........axi_slave_driver.......main_phase got packet -- operation = %s",pkt.operation.name()),  UVM_LOW);
      if(pkt.operation == WRITE ) begin
        wresponse_mbx.put(pkt);
      end
      if(pkt.operation == READ) begin
        rdata_mbx.put(pkt);
      end
      seq_item_port.item_done();
    end
endtask

task axi_slave_driver :: drive_write_add();
    axi_slave_seq_item pkt;
      
    forever begin
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.areset_n == 1);
      slave_drv_intf.slv_drv_cb.awready <='b1;
      
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.slv_drv_cb.awvalid ==1 && slave_drv_intf.areset_n == 1);
      slave_drv_intf.slv_drv_cb.awready <='b0;
    end
endtask

task axi_slave_driver :: drive_read_add();
    axi_slave_seq_item pkt;
    
    forever begin
      @(slave_drv_intf.slv_drv_cb); //delay in asserting ready
      wait(slave_drv_intf.areset_n == 1);
      slave_drv_intf.slv_drv_cb.arready <='b1;
   
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.slv_drv_cb.arvalid == 1 && slave_drv_intf.areset_n == 1);
      slave_drv_intf.slv_drv_cb.arready <='b0;
    end
endtask

task axi_slave_driver :: drive_write_resp();  
    axi_slave_seq_item pkt;
    
    forever begin
      wresponse_mbx.get(pkt);
      wait(slave_drv_intf.areset_n == 1);
      @(slave_drv_intf.slv_drv_cb);
      slave_drv_intf.slv_drv_cb.bresp   <= pkt.bresp;
      slave_drv_intf.slv_drv_cb.bvalid  <='b1;
      
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.slv_drv_cb.bready ==1);
      slave_drv_intf.slv_drv_cb.bvalid  <='b0;
      //Post drive callback
      `uvm_do_callbacks(axi_slave_driver,axi_slave_driver_callback,post_drive(pkt));
    end
endtask

task axi_slave_driver :: drive_write_data();
    axi_slave_seq_item pkt;

    forever begin   
      @(slave_drv_intf.slv_drv_cb);
      slave_drv_intf.slv_drv_cb.wready <= 1;
      
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.slv_drv_cb.wvalid ==1 && slave_drv_intf.areset_n == 1);
      slave_drv_intf.slv_drv_cb.wready <= 0;
    end
endtask

task axi_slave_driver :: drive_read_data();
    axi_slave_seq_item pkt;
    
    forever begin
      rdata_mbx.get(pkt); //must be blocking statement
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.areset_n == 1);
      slave_drv_intf.slv_drv_cb.rdata   <= pkt.rdata;
      slave_drv_intf.slv_drv_cb.rresp   <= pkt.rresp;
      slave_drv_intf.slv_drv_cb.rvalid  <= 1;
      
      @(slave_drv_intf.slv_drv_cb);
      wait(slave_drv_intf.slv_drv_cb.rready == 1 && slave_drv_intf.areset_n == 1); 
      slave_drv_intf.slv_drv_cb.rvalid  <= 0;
      slave_drv_intf.slv_drv_cb.rdata   <= 32'b0;
      //Post drive callback
      `uvm_do_callbacks(axi_slave_driver,axi_slave_driver_callback,post_drive(pkt));
    end
endtask


