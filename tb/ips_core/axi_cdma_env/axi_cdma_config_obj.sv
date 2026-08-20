/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_config_obj.sv                           */
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
class axi_cdma_config_obj extends uvm_object;
`uvm_object_utils(axi_cdma_config_obj)

//config members
   int no_of_masters, no_of_slaves;
   virtual axi_cdma_axi_master_intf mas_if[];
   virtual axi_cdma_axi_slave_intf  slv_if[];
   virtual axi_cdma_interrupt_intf intrpt_if;
   cdma_reg_block m_reg_block;

   bit scoreboard_enable;
   int total_trans;
   uvm_active_passive_enum mas_is_active[] ,slv_is_active[];
   int slave_width [4], master_width[4];
   bit [63:0] first_curr_desc_pntr,tail_desc_pntr;
   int no_of_descriptor;
   axi_cdma_descriptor_seq_item mem[int];

  function new (string name = "axi_cdma_config_obj");
     super.new (name);
  endfunction
endclass :axi_cdma_config_obj

