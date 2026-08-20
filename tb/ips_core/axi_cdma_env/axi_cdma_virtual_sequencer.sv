/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_virtual_sequencer.sv                    */
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
class axi_cdma_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils (axi_cdma_virtual_sequencer)
   axi_cdma_axi_master_sequencer   m_seqr[]; //list master and slave sequencers
   axi_cdma_axi_slave_sequencer    s_seqr[];
   uvm_component      sqr_q[$];
   axi_cdma_config_obj         obj;
   function new (string name = "axi_cdma_virtual_sequencer" , uvm_component parent);
      super.new(name,parent);
   endfunction
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      if (!uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj))
     `uvm_fatal(get_full_name(),"Config_obj get Failure");
      m_seqr = new[obj.no_of_masters];
      s_seqr = new[obj.no_of_slaves];
      /*for (int i = 0 ; i < obj.no_of_masters ; i++)
         m_seqr[i]= axi_cdma_axi_master_sequencer :: type_id :: create ($sformatf("m_sqr_h[%0d]",i), this);
      for (int i = 0 ; i < obj.no_of_slaves ; i++)
         s_seqr[i]= axi_cdma_axi_slave_sequencer :: type_id :: create ($sformatf("s_sqr_h[%0d]",i), this);*/
   endfunction : build_phase

  function void connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     for (int i = 0 ; i < obj.no_of_masters ; i++)
	if (obj.mas_is_active[i] == UVM_ACTIVE) begin
	        sqr_q.delete();
        	uvm_top.find_all ($sformatf ("*.m_agt[%0d].sqr",i),sqr_q);
	        if (sqr_q.size() > 1)
        	   `uvm_fatal (get_full_name , "Multiple sqr match")
	        else if (sqr_q.size() == 0)
        	   `uvm_fatal (get_full_name , "No sqr match")
	        else
        	    $cast(m_seqr[i],sqr_q[0]);
	end
     for (int i = 0 ; i < obj.no_of_slaves ; i++) begin
	if (obj.slv_is_active[i] == UVM_ACTIVE) begin
        	sqr_q.delete();
	        uvm_top.find_all ($sformatf ("*.s_agt[%0d].sqr",i),sqr_q);
        	if (sqr_q.size() > 1)
	           `uvm_fatal (get_full_name , "Multiple sqr match")
        	else if (sqr_q.size() == 0)
	           `uvm_fatal (get_full_name , "No sqr match")
        	else
	            $cast(s_seqr[i],sqr_q[0]);	
	end
endfunction : connect_phase

endclass : axi_cdma_virtual_sequencer
