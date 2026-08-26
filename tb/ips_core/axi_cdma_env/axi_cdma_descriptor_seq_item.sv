/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_descriptor_seq_item.sv                  */
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
class axi_cdma_descriptor_seq_item extends uvm_sequence_item;
  rand logic [63:0] next_desc_pntr;
  rand logic [63:0] source_addr;
  rand logic [63:0] dest_addr;
  rand logic [31:0] control_word;
  rand logic [31:0] status_word;
  rand logic [63:0] curr_desc_addr;
  longint temp;

      `uvm_object_utils_begin(axi_cdma_descriptor_seq_item)
       `uvm_field_int(next_desc_pntr,UVM_ALL_ON)
       `uvm_field_int(source_addr,UVM_ALL_ON)
       `uvm_field_int(dest_addr,UVM_ALL_ON)
       `uvm_field_int(control_word,UVM_ALL_ON)
       `uvm_field_int(status_word,UVM_ALL_ON)
      `uvm_object_utils_end


      constraint nxt_pntr_val{soft next_desc_pntr%64 ==0;soft next_desc_pntr >0;soft next_desc_pntr<10000;}
      //constraint curr_desc_addr_val{soft curr_desc_addr == temp;}
      //constraint source_addr_val{soft source_addr inside {[0:500]};}
      //constraint dest_addr_val{soft dest_addr inside {[500:1000]};}
      constraint control_word_val{soft control_word inside {[1:1000]};}

      constraint da_val {soft dest_addr >= source_addr+control_word;
                          if(source_addr <= control_word)
                            soft dest_addr inside {[0:source_addr-control_word]};}
      constraint status_word_val{soft status_word == 0;}

      function new(string name="mem_seq_item");
        super.new(name);
      endfunction

     

endclass : axi_cdma_descriptor_seq_item

class cdma_transfer_desc_seq_item extends axi_cdma_descriptor_seq_item;
  `uvm_object_utils(cdma_transfer_desc_seq_item)
  `uvm_object_new

  int addr;
  rand  int ND;
  randc int ND_copy;
  rand 	int SA, DA;
  rand 	bit [25:0] BTT;
  rand 	int no_of_desc;
  int set_start_addr;
  int nd_q[$], nd_copy_q[$];
  
  constraint align 		{ ND % 'd64 == 0; SA%'d4 == 0; DA%'d4 == 0;}
  constraint addr_range { ND inside {[set_start_addr : (((no_of_desc)*64) + set_start_addr)]}; !(ND inside {nd_q});}
  constraint addr_range_2 { ND_copy inside {[set_start_addr : (((no_of_desc)*64) + set_start_addr)]};}
  constraint sa_da_range {SA inside {[32'h8000_0000 : 32'h9fff_ffff]}; DA inside {[32'h9001_0000 : 32'h9fff_e000]};}
  constraint btt_range	{ DA-SA > BTT || SA - DA > BTT; BTT inside {[50:5000]}; }
  constraint next_desc  { ND != addr; ND != set_start_addr; soft no_of_desc inside {[2:10]};}
  constraint next_desc_2  { ND_copy != addr; ND_copy != set_start_addr; soft no_of_desc inside {[2:10]};}

  function void post_randomize();
    nd_q.push_back(ND);
    nd_copy_q.push_back(ND_copy);
    if($size(nd_q) > no_of_desc) begin
      $displayh("ND_Q:%p",nd_q);
      nd_q.delete();
    end
  endfunction

endclass

