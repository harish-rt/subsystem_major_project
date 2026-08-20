/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/virtual_sequence.sv                     */
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
class axi_cdma_virtual_sequence_base extends uvm_sequence ;
   `uvm_object_utils(axi_cdma_virtual_sequence_base)
   `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
 //List all the Sequences
 base_master_sequence m_seq;
 axi_cdma_axi_base_slave_sequence  s_seq;
 function new (string name = "virtual_sequence");
      super.new(name);
      //create all sequences here
      m_seq   = base_master_sequence :: type_id :: create ("m_seq");
      s_seq   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq");
   endfunction
  task body ();
   //Make all the pre-sets or configuration gets here;
   //write a scenario here if multiple sequences involved
   `uvm_info (get_full_name(), "Invoking Sequnece start in V-sequence" ,UVM_LOW)
   fork
   s_seq.start(p_sequencer.s_seqr[0]);
   join_none
   m_seq.start(p_sequencer.m_seqr[0]);
   endtask : body
endclass : axi_cdma_virtual_sequence_base

class virtual_sequence_1 extends axi_cdma_virtual_sequence_base;
  `uvm_object_utils(virtual_sequence_1)
  `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
 function new (string name = "virtual_sequence_1");
    super.new(name);
 endfunction
 task body ();
   `uvm_info (get_full_name(), "Invoking Sequnece start in V-virtual_sequence_1" ,UVM_LOW)
   fork
   s_seq.start(p_sequencer.s_seqr[0]);
   join_none
   m_seq.start(p_sequencer.m_seqr[3]);
 endtask : body
endclass : virtual_sequence_1

class priority_test_vsequence extends axi_cdma_virtual_sequence_base;//all masters targeting slave0 with 0 delays reads and slave2 with write transactions.

  `uvm_object_utils(priority_test_vsequence)
  `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
  master_priority_sequence_m0 m_p_seq0;
  master_priority_sequence_m1 m_p_seq1;
  master_priority_sequence_m2 m_p_seq2;
  master_priority_sequence_m3 m_p_seq3;
  axi_cdma_axi_base_slave_sequence  s_seq1,s_seq2;

function new (string name = "priority_test_vsequence");
    super.new(name);
 endfunction
 task body ();
   `uvm_info (get_full_name(), "Invoking Sequnece start in V-priority_test_vsequence" ,UVM_LOW)
   m_p_seq0   = master_priority_sequence_m0 :: type_id :: create ("m_p_seq0");
   m_p_seq1   = master_priority_sequence_m1 :: type_id :: create ("m_p_seq1");
   m_p_seq2   = master_priority_sequence_m2 :: type_id :: create ("m_p_seq2");
   m_p_seq3   = master_priority_sequence_m3 :: type_id :: create ("m_p_seq3");
   s_seq1   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq1");
   s_seq2   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq2");
   fork
   s_seq1.start(p_sequencer.s_seqr[0]);
   s_seq2.start(p_sequencer.s_seqr[2]);
   join_none

   fork
    m_p_seq0.start(p_sequencer.m_seqr[0]);
    m_p_seq1.start(p_sequencer.m_seqr[1]);
    m_p_seq2.start(p_sequencer.m_seqr[2]);
    m_p_seq3.start(p_sequencer.m_seqr[3]);
   join

 endtask : body
endclass : priority_test_vsequence

class virtual_sequence_3 extends axi_cdma_virtual_sequence_base;
  `uvm_object_utils(virtual_sequence_3)
  `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
  master_scb_sequence_m0 m_sb_seq0;
  master_scb_sequence_m1 m_sb_seq1;
  master_scb_sequence_m2 m_sb_seq2;
  master_scb_sequence_m3 m_sb_seq3;
  axi_cdma_axi_base_slave_sequence  s_seq0,s_seq1,s_seq2,s_seq3;

function new (string name = "virtual_sequence_3");
    super.new(name);
 endfunction
 task body ();
   `uvm_info (get_full_name(), "Invoking Sequnece start in V-sequence_3" ,UVM_LOW)
   m_sb_seq0   = master_scb_sequence_m0 :: type_id :: create ("m_sb_seq0");
   m_sb_seq1   = master_scb_sequence_m1 :: type_id :: create ("m_sb_seq1");
   m_sb_seq2   = master_scb_sequence_m2 :: type_id :: create ("m_sb_seq2");
   m_sb_seq3   = master_scb_sequence_m3 :: type_id :: create ("m_sb_seq3");
   s_seq0   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq0");
   s_seq1   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq1");
   s_seq2   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq2");
   s_seq3   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq3");
   fork
     s_seq0.start(p_sequencer.s_seqr[0]);
     s_seq1.start(p_sequencer.s_seqr[1]);
     s_seq2.start(p_sequencer.s_seqr[2]);
     s_seq3.start(p_sequencer.s_seqr[3]);
   join_none

   fork
    m_sb_seq0.start(p_sequencer.m_seqr[0]);  //downconversion/narrow_txn 64-32
    m_sb_seq1.start(p_sequencer.m_seqr[1]); //one_to_one with ids 128-128
    m_sb_seq2.start(p_sequencer.m_seqr[2]); //M3->S4 //same size txn 256-256
    m_sb_seq3.start(p_sequencer.m_seqr[3]); // upsizing 32_64
   join

 endtask : body
endclass : virtual_sequence_3

class access_test_vsequence extends axi_cdma_virtual_sequence_base;
  `uvm_object_utils(access_test_vsequence)
  `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
  access_test_sequence acc_m0,acc_m1,acc_m2,acc_m3;
  axi_cdma_axi_base_slave_sequence  s_seq0,s_seq1,s_seq2,s_seq3;

function new (string name = "access_test_vsequence");
    super.new(name);
 endfunction
 task body ();
   `uvm_info (get_full_name(), "Invoking Sequnece start in access_test_vsequence" ,UVM_LOW)
   acc_m0   = access_test_sequence :: type_id :: create ("acc_m0");
   acc_m1   = access_test_sequence :: type_id :: create ("acc_m1");
   acc_m2   = access_test_sequence :: type_id :: create ("acc_m2");
   acc_m3   = access_test_sequence :: type_id :: create ("acc_m3");
   s_seq0   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq0");
   s_seq1   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq1");
   s_seq2   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq2");
   s_seq3   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq3");
   fork
     s_seq0.start(p_sequencer.s_seqr[0]);
     s_seq1.start(p_sequencer.s_seqr[1]);
     s_seq2.start(p_sequencer.s_seqr[2]);
     s_seq3.start(p_sequencer.s_seqr[3]);
   join_none
   fork
     acc_m0.start(p_sequencer.m_seqr[0]);
     acc_m1.start(p_sequencer.m_seqr[1]);
     acc_m2.start(p_sequencer.m_seqr[2]);
     acc_m3.start(p_sequencer.m_seqr[3]);
   join

 endtask : body
endclass : access_test_vsequence


class burst_test_vsequence extends axi_cdma_virtual_sequence_base;
  `uvm_object_utils(burst_test_vsequence)
  `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
  burst_test_sequence  m_seq0;
  axi_cdma_axi_base_slave_sequence  s_seq0,s_seq1,s_seq2,s_seq3;

function new (string name = "burst_test_vsequence");
    super.new(name);
 endfunction
 task body ();
   `uvm_info (get_full_name(), "Invoking Sequnece start in burst_test_vsequence" ,UVM_LOW)
   m_seq0   = burst_test_sequence :: type_id :: create ("m_seq0");
   s_seq0   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq0");
   s_seq1   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq1");
   s_seq2   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq2");
   s_seq3   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq3");
   fork
     s_seq0.start(p_sequencer.s_seqr[0]);
     s_seq1.start(p_sequencer.s_seqr[1]);
     s_seq2.start(p_sequencer.s_seqr[2]);
     s_seq3.start(p_sequencer.s_seqr[3]);
   join_none
   fork
     m_seq0.start(p_sequencer.m_seqr[0]);
   join

 endtask : body
endclass : burst_test_vsequence

class width_conversion_test_vsequence extends axi_cdma_virtual_sequence_base;
  `uvm_object_utils(width_conversion_test_vsequence)
  `uvm_declare_p_sequencer(axi_cdma_virtual_sequencer)
  width_conversion_test_sequence  m_seq0,m_seq1,m_seq2,m_seq3;
  axi_cdma_axi_base_slave_sequence  s_seq0,s_seq1,s_seq2,s_seq3;

function new (string name = "width_conversion_test_vsequence");
    super.new(name);
 endfunction
 task body ();
   `uvm_info (get_full_name(), "Invoking Sequnece start in width_conversion_test_vsequence" ,UVM_LOW)
   m_seq0   = width_conversion_test_sequence :: type_id :: create ("m_seq0");
   m_seq1   = width_conversion_test_sequence :: type_id :: create ("m_seq1");
   m_seq2   = width_conversion_test_sequence :: type_id :: create ("m_seq2");
   m_seq3   = width_conversion_test_sequence :: type_id :: create ("m_seq3");
   s_seq0   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq0");
   s_seq1   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq1");
   s_seq2   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq2");
   s_seq3   = axi_cdma_axi_base_slave_sequence :: type_id :: create ("s_seq3");
   fork
     s_seq0.start(p_sequencer.s_seqr[0]);
     s_seq1.start(p_sequencer.s_seqr[1]);
     s_seq2.start(p_sequencer.s_seqr[2]);
     s_seq3.start(p_sequencer.s_seqr[3]);
   join_none
   m_seq0.target_master= 0; //passing master_index to seq for setting txn size.
   m_seq1.target_master= 1;
   m_seq2.target_master= 2;
   m_seq3.target_master= 3;
   fork
     m_seq0.start(p_sequencer.m_seqr[0]);
     m_seq1.start(p_sequencer.m_seqr[1]);
     m_seq2.start(p_sequencer.m_seqr[2]);
     m_seq3.start(p_sequencer.m_seqr[3]);
   join

 endtask : body
endclass : width_conversion_test_vsequence
