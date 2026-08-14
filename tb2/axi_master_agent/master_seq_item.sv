/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_seq_item.sv                      */
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
class master_seq_item extends axi_base_seq_item;
  //FACTORY REGISTRATION
 `uvm_object_utils(master_seq_item)
  //MEMEBERS
  //delays
   rand delay_t add_valid_dly; // delay between writing address channel info and asserting valid
   rand delay_t resp_ready_dly; // delay in asserting ready while write response handshake.
   rand delay_t read_ready2ready_dly[]; // serves as ready2ready for ready
   rand delay_t write_valid2valid_dly[];// valid2valid delay for write txn

  function new (string name = "master_seq_item");
     super.new (name);
  endfunction

  //CONSTRAINTS
  constraint wr_addr_channel_default {awid == 0;awlen == 0;awburst == 0; awsize == 0;
                                     awlock == 0;awprot == 0;awqos == 0;awregion ==0; awcache ==0;}
  constraint awaddr_offset {soft awaddr inside {'h00,'h04,'h08,'h0C,'h10,'h14,'h18,'h1C,'h20,'h24,'h28};}
  constraint wdata_channel_default{ foreach(wstrobe[i]) wstrobe[i] [31:5] == 0; 
                                    foreach(wdata[i]) wdata[i][255:32] == 0;}
  constraint wr_resp_channel_default {bid == 0;}
  constraint rd_addr_channel_default {arid == 0;arlen == 0;arburst == 0; arsize == 0;
                                     arlock == 0;arprot == 0;arqos == 0;arregion ==0; arcache ==0;}
  constraint araddr_offset {soft araddr inside {8'h00,8'h04,8'h08,8'h0C,8'h10,8'h14,8'h18,8'h1C,8'h20,8'h24,8'h28};}
  constraint rd_data_channel_default {rid == 0; foreach(rdata[i]) 
                                                  rdata[i] [255:32]==0;}

 
  //delay constraints
  constraint resp_ready_dly_c {resp_ready_dly ==0/*inside {[0:10]}*/;}
  constraint add_valid_dly_c{add_valid_dly ==0/*inside {[0:10]}*/;}
  constraint write_valid2valid_dly_c{solve awlen before write_valid2valid_dly;
                                    write_valid2valid_dly.size()==awlen+1;
                                    foreach(write_valid2valid_dly[i])
                                    {write_valid2valid_dly[i] == 0;}
                                    }
  constraint read_ready2ready_dly_c{solve arlen before read_ready2ready_dly;
                                    read_ready2ready_dly.size()==arlen+1;
                                    foreach(read_ready2ready_dly[i])
                                    {read_ready2ready_dly[i] ==1;}
                                    }
   //USER-DEFINED METHODS
endclass : master_seq_item
