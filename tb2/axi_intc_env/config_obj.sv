/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_config_obj.sv                                          */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2023                       */
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
class intc_config_obj extends uvm_object;

  //FACTORY REGISTRATION
  `uvm_object_utils (intc_config_obj) 
 
  virtual axi_4_lite_intf   a_if;
  virtual intc_intf         c_if;
  bit has_axi_agent                     = 1'b1;
  bit has_intc_agent                    = 1'b1;
  uvm_active_passive_enum   axi_active  = UVM_ACTIVE;
  uvm_active_passive_enum   intc_active = UVM_ACTIVE;

  function new (string name = "intc_config_obj");
     super.new (name);
  endfunction 


endclass : intc_config_obj
