/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_sequence.sv                      */
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
//import axi_package :: *;
class axi_master_sequence extends uvm_sequence #(master_seq_item);
  `uvm_object_utils (axi_master_sequence)

    
  function new (string name = "axi_master_sequence");
    super.new (name);
  endfunction
    
   // master_seq_item pkt;
  //task body();

    //pkt=master_seq_item::type_id::create("pkt");
  //endtask

endclass : axi_master_sequence

class bram_access_seq extends axi_master_sequence;
    `uvm_object_utils(bram_access_seq)

    function new(string name="bram_access_seq");
       super.new(name);
    endfunction

    task body();
        
        master_seq_item pkt;
        pkt=master_seq_item::type_id::create("pkt");

        start_item(pkt);
            if(!pkt.randomize() with {operation==READ;araddr==32'h7100_0000;arid==7'h4;arlen==4;arburst==INCR;})
            `uvm_error("AXI4_MASTER_SEQUENCE","Randomization failed")
        finish_item(pkt);
        `uvm_info("MASTER_SEQUENCE",pkt.sprint(),UVM_LOW)
    endtask
endclass
