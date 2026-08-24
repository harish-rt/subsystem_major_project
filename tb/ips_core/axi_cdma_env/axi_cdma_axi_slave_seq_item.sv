/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_slave_seq_item.sv                       */
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
class axi_cdma_axi_slave_seq_item extends axi_cdma_axi_base_seq_item;
  `uvm_object_utils(axi_cdma_axi_slave_seq_item)
  //MEMEBERS
  //delays
   rand delay_t write_ready2ready_dly[]; // serves as ready2ready for write
   rand delay_t read_valid2valid_dly[];// valid2valid delay for read txn
   rand delay_t add_ready_dly; //ar_ready or aw_ready delay
   rand delay_t data2resp_dly; //delay between write data and response phase


  function new (string name = "axi_cdma_axi_slave_seq_item");
     super.new (name);
  endfunction

  //CONSTRAINTS

  constraint arsize_c{arsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint awsize_c{awsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint rdata_c { rdata.size() == arlen +1;}
  constraint wdata_c { wdata.size() == awlen+1;}
  constraint bresp_c {soft bresp==OKAY;}
  constraint rresp_c {solve arlen before rresp;
                      rresp.size() == arlen+1;
                      foreach(rresp[i]) soft rresp[i]==OKAY;} //keeping default response okay
  //delay constraints
  constraint add_ready_dly_c{add_ready_dly inside {[0:10]};}
  constraint write_ready2ready_dly_c{solve awlen before write_ready2ready_dly;
                                    write_ready2ready_dly.size()==awlen+1;
                                    foreach(write_ready2ready_dly[i])
                                    {write_ready2ready_dly[i] inside {[0:20]};}
                                    }
  constraint read_valid2valid_dly_c{solve arlen before read_valid2valid_dly;
                                    read_valid2valid_dly.size()==arlen+1;
                                    foreach(read_valid2valid_dly[i])
                                    {read_valid2valid_dly[i] == 0;}
                                    }
  //USER-DEFINED METHODS
endclass : axi_cdma_axi_slave_seq_item
