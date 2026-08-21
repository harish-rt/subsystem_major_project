/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* SV/spi_ral/tb/ral_env.sv                                               */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2021                       */
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
/* RAITON_COPYRIGHT_END reg transaction - bus                                                   */
class axi_cdma_reg2axi_adaptor extends uvm_reg_adapter;
   `uvm_object_utils (axi_cdma_reg2axi_adaptor)

   function new (string name = "axi_cdma_reg2axi_adaptor");
   super.new (name);
   provides_responses = 0;
   supports_byte_enable = 1;
   endfunction

   virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
     axi_cdma_axi_master_seq_item pkt = axi_cdma_axi_master_seq_item ::type_id::create ("pkt");
     assert(pkt.randomize());
     if(rw.kind == UVM_WRITE)begin
       pkt.operation = WRITE;
       //pkt.channel_type = WRITE_DATA;
       pkt.awaddr = rw.addr;
       pkt.wdata = new[1];
       pkt.wdata[0] = rw.data;
       `uvm_info ("adapter_write", $sformatf ("reg2bus  rw data=0x%0h addr=0x%0h  kind=%s pkt data=%p ",rw.data,rw.addr,rw.kind.name,pkt.wdata), UVM_LOW)
     end
     else begin
       pkt.operation = READ;
       //pkt.channel_type = RD_ADDR;
       pkt.araddr = rw.addr;
       //pkt.rdata = 'hF;
       `uvm_info ("adapter_read", $sformatf ("reg2bus  rw data=0x%0h addr=0x%0h  kind=%s ",rw.data, rw.addr, rw.kind.name), UVM_LOW)
     end
     return pkt;	  
   endfunction

   virtual function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
     axi_cdma_axi_master_seq_item pkt;
     if (!$cast(pkt, bus_item)) begin
       `uvm_fatal ("axi_cdma_reg2axi_adaptor", "Failed to cast bus_item to pkt")
     end
     `uvm_info ("bus2reg", $sformatf ("Entry to bus2reg "), UVM_LOW)
     if(pkt.operation == WRITE)begin
       rw.data    =  pkt.wdata[0][31:0];
       rw.addr    =  pkt.awaddr;
       rw.kind    =  UVM_WRITE;
       if(pkt.bresp == OKAY) begin
         rw.status = UVM_IS_OK;
       end else if(pkt.bresp == SLVERR || pkt.bresp == DECERR) begin
         rw.status = UVM_NOT_OK;
       end else if(pkt.wdata[0] == 32'dx) begin
         rw.status = UVM_HAS_X;
       end

       `uvm_info ("adapter_write_mon", $sformatf ("bus2reg  rw data=0x%0h addr=0x%0h  kind=%s status=%s",rw.data, rw.addr, rw.kind.name , rw.status.name), UVM_LOW)
     end
     else if(pkt.operation == READ)begin
       rw.data    =  pkt.rdata[0][31:0];
       rw.addr    =  pkt.araddr;
       rw.kind    =  UVM_READ;
       if(pkt.rresp[0] == OKAY) begin
         rw.status = UVM_IS_OK;
       end else if(pkt.rresp[0] == SLVERR || pkt.rresp[0] == DECERR) begin
         rw.status = UVM_NOT_OK;
       end else if(pkt.rdata[0] == 32'dx) begin
         rw.status = UVM_HAS_X;
       end

       `uvm_info ("adapter_read_mon", $sformatf ("bus2reg  rw data=0x%0h addr=0x%0h  kind=%s status=%s",rw.data, rw.addr, rw.kind.name , rw.status.name), UVM_LOW)
     end
     else begin
       `uvm_fatal("wrong command", "axi_cdma_reg2axi_adaptor")
     end
     `uvm_info ("bus2reg", $sformatf ("Exit  from bus2reg "), UVM_LOW)
   endfunction
endclass

