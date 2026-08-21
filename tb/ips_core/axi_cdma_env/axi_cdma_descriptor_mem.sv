/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_descriptor_mem.sv                       */
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
class axi_cdma_descriptor_mem extends uvm_object;


   //typedef logic [63:0] addr_type;
   //logic [31:0] mem [longint unsigned];
   logic [31:0] mem [int];
   longint unsigned index;

`uvm_object_utils(axi_cdma_descriptor_mem)

  `uvm_object_new
 
   function void write_descriptor(axi_cdma_descriptor_seq_item pkt,axi_cdma_axi_slave_seq_item resp_pkt);

      index = resp_pkt.araddr;
      mem[index] = pkt.next_desc_pntr[31:0];
      mem[index+4] = pkt.next_desc_pntr[63:32];
      mem[index+8] = pkt.source_addr[31:0];
      mem[index+12] = pkt.source_addr[63:32];
      mem[index+16] = pkt.dest_addr[31:0];
      mem[index+20] = pkt.dest_addr[63:32];
      mem[index+24] = pkt.control_word;
      mem[index+28] = pkt.status_word;

   endfunction 

   function void print_descriptor();
      $info("mem = %p",mem);
   endfunction
   //function mem_seq_item read_descriptor ();


   function void compare_pkt(axi_cdma_axi_slave_seq_item pkt);

     index = pkt.araddr;

     foreach(pkt.rdata[i]) begin
       if(pkt.rdata[i] != mem[index+(i*4)])
          `uvm_error("sg_descriptor_read_checker","DATA not matched")
       else 
          `uvm_info("sg_descriptor_read_checker","Descriptor Check PASSED",UVM_DEBUG)
     end

   endfunction
    
         

endclass
