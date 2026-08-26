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
class virtual_sequence_base extends uvm_sequence ;
   `uvm_object_utils(virtual_sequence_base)

   `uvm_declare_p_sequencer(virtual_sequencer)	//p_sequencer

   //base_master_sequence m_seq;
   reg_sequence   m_seq;
   base_slave_sequence  s_seq;

   function new (string name = "virtual_sequence");
      super.new(name);
      //m_seq   = base_master_sequence :: type_id :: create ("m_seq");
      m_seq=reg_sequence::type_id::create("m_seq");
      s_seq   = base_slave_sequence :: type_id :: create ("s_seq");
   endfunction

   task body ();
     `uvm_info (get_full_name(), "Invoking Sequnece start in V-sequence" ,UVM_LOW)
     fork
       s_seq.start(p_sequencer.s_seqr[0]);
     join_none
       m_seq.start(p_sequencer.m_seqr[0]);
   endtask : body
endclass : virtual_sequence_base


/*class simple_dma_v_seq extends virtual_sequence_base;
    `uvm_object_utils(simple_dma_v_seq)
      
    `uvm_declare_p_sequencer(virtual_sequencer)
     
     base_slave_sequence seq1;
     simple_dma_transfer_seq m_seq1;
     function new(string name="simple_dma_vir_seq");
        super.new(name);
        m_seq1=simple_dma_transfer_seq::type_id::create("m_seq1");
        seq1=base_slave_sequence::type_id::create("seq1");
     endfunction

    task body();
      `uvm_info(get_full_name(),"starting virtual sequence",UVM_LOW)  
        
     fork
        begin
         #100;
         seq1.start(p_sequencer.s_seqr[1]);
         end
     join_none
       m_seq1.start(p_sequencer.m_seqr[0]);
    endtask
endclass*/
//////////////////simple_mode_incremental transfer_seq////////
class simple_mode_inc_v_seq extends virtual_sequence_base;
    `uvm_object_utils(simple_mode_inc_v_seq)

    `uvm_declare_p_sequencer(virtual_sequencer)

    base_slave_sequence seq2;
    simple_mode_inc_tr  m_seq2;

    function new(string name="simple_mode_inc_v_seq");
        super.new(name);
        seq2=base_slave_sequence::type_id::create("seq2");
        m_seq2=simple_mode_inc_tr::type_id::create("m_seq2");
    endfunction

    task body();
        m_seq2.reg_model=p_sequencer.reg_model;
        `uvm_info("virtual_sequence","virtual sequence started",UVM_LOW)
        fork
            seq2.start(p_sequencer.s_seqr[1]);
        join_none
        m_seq2.start(p_sequencer.m_seqr[0]);
    endtask

endclass
