/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/virtual_sequencer.sv                    */
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
class virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils (virtual_sequencer)
   master_sequencer   m_seqr[]; //master sequencers
   slave_sequencer    s_seqr[]; //slave sequencers
   uvm_component      sqr_q[$];
   axi_cdma_config_obj         obj;
   cdma_reg_block   reg_model;
   function new (string name = "virtual_sequencer" , uvm_component parent);
      super.new(name,parent);
   endfunction
  
   extern function void build_phase		(uvm_phase phase);
   extern function void connect_phase		(uvm_phase phase);

endclass: virtual_sequencer


function void virtual_sequencer:: build_phase 	(uvm_phase phase);
  super.build_phase (phase);
  if (!uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj))
  `uvm_fatal(get_full_name(),"Config_obj get Failure");
  m_seqr = new[obj.no_of_masters];						//4 master sequencer
  s_seqr = new[obj.no_of_slaves];						//4 slaves sequencer



  //creating  master sequencer
  for (int i = 0 ; i < obj.no_of_masters ; i++)
    m_seqr[i]= master_sequencer :: type_id :: create ($sformatf("m_sqr_h[%0d]",i), this);

      //creating  slave sequencer
  for (int i = 0 ; i < obj.no_of_slaves ; i++)
    s_seqr[i]= slave_sequencer :: type_id :: create ($sformatf("s_sqr_h[%0d]",i), this);
endfunction : build_phase


function void virtual_sequencer:: connect_phase 	(uvm_phase phase);
     super.connect_phase (phase);
     for (int i = 0 ; i < obj.no_of_masters ; i++) begin
       sqr_q.delete();								//reseting the queue
       uvm_top.find_all ($sformatf ("*.m_agt[%0d].sqr",i),sqr_q);
  if (obj.mas_is_active[i] == UVM_ACTIVE) begin
    `uvm_fatal("VIRTUAL_SEQUENCER","ENTERing into if  block")
       if (sqr_q.size() > 1)
         `uvm_fatal (get_full_name , "Multiple sqr match")
       else if (sqr_q.size() == 0)
           `uvm_fatal (get_full_name , "No sqr match")
       else
            $cast(m_seqr[i],sqr_q[0]);
     end
    end 
     for (int i = 0 ; i < obj.no_of_slaves ; i++) begin
        sqr_q.delete();
        uvm_top.find_all ($sformatf ("*.s_agt[%0d].sqr",i),sqr_q);
        if(obj.slv_is_active[i]==UVM_ACTIVE)begin
        if (sqr_q.size() > 1)
           `uvm_fatal (get_full_name , "Multiple sqr match")
        else if (sqr_q.size() == 0)
           `uvm_fatal (get_full_name , "No sqr match")
        else
            $cast(s_seqr[i],sqr_q[0]);
     end
     end
endfunction : connect_phase
