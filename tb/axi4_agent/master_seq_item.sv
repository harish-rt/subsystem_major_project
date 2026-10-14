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
