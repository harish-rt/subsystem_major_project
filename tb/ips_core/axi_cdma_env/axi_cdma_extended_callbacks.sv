/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/uvm_callback.sv                         */
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
class axi_cdma_extended_master_driver_callback extends axi_cdma_axi_master_driver_callback;
   `uvm_object_utils(axi_cdma_extended_master_driver_callback)
   

   function new (string name = "axi_cdma_extended_master_driver_callback");
      super.new(name);
   endfunction

   virtual task pre_drive (axi_cdma_axi_master_seq_item pkt,mailbox #(axi_cdma_axi_master_seq_item) waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx);
     `uvm_info ("axi_cdma_extended_master_driver_callback::pre_drive" , "pre_drive :: executing axi_cdma_axi_master_driver call back" , UVM_LOW)
       if(pkt.operation==WRITE) begin
          wait(waddress_mbx.num == 0 & wdata_mbx.num == 0);
        end else begin
          wait(raddress_mbx.num == 0 & rdata_mbx.num == 0);
        end

   endtask : pre_drive

   virtual task post_drive (axi_cdma_axi_master_seq_item pkt,virtual axi_cdma_axi_master_intf.DRV_MOD_master vif, uvm_seq_item_pull_port#(axi_cdma_axi_master_seq_item) port);
     `uvm_info ("axi_cdma_extended_master_driver_callback::post_drive" , "post_drive :: executing axi_cdma_axi_master_driver call back" , UVM_LOW)
        if(pkt.operation==WRITE) begin
          //wait(vif.mas_drv_cb.bvalid );
          pkt.bresp = response_t'(vif.mas_drv_cb.bresp);
          @(vif.mas_drv_cb);
        end else begin
          //wait(vif.mas_drv_cb.rvalid);
          pkt.rdata = new[1];
          pkt.rresp = new[1];
          pkt.rdata[0] = vif.mas_drv_cb.rdata;
          pkt.rresp[0] = response_t'(vif.mas_drv_cb.rresp);
          @(vif.mas_drv_cb);
        end
       `uvm_info ("axi_cdma_extended_master_driver_callback::post_drive" , "Print before put response" , UVM_LOW)
          pkt.print();
          port.put_response(pkt);
   endtask : post_drive

endclass : axi_cdma_extended_master_driver_callback

