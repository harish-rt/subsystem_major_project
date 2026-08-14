/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_interface.sv                                      */
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
interface intc_intf(input bit intc_procss_clk, logic intc_procss_rst);

 `include "uvm_macros.svh"

 import uvm_pkg :: *;


  logic [31:0]intc_intr;                                
  logic intc_irq;                      
  logic [1:0]intc_procss_acklg;             
  logic [31:0]intc_intr_addr;                 
  logic intc_irq_in;                   
  logic [31:0]intc_intr_addr_in;              
  logic [1:0]intc_procss_ack_out;            

  clocking intc_interface_driver_cb @(posedge intc_procss_clk);
  default input #1 output #0;
  output intc_intr;                                
  input  intc_irq;                      
  output intc_procss_acklg;             
  input  intc_intr_addr;                 
  output intc_irq_in;                   
  output intc_intr_addr_in;              
  input intc_procss_ack_out;            
  endclocking

  clocking intc_interface_monitor_cb @(posedge intc_procss_clk);
  default input #1 output #0;
  input intc_intr;                                
  input intc_irq;                      
  input intc_procss_acklg;             
  input intc_intr_addr;                 
  input intc_irq_in;                   
  input intc_intr_addr_in;              
  input intc_procss_ack_out;            
  endclocking

  modport intc_drv_mod(clocking intc_interface_driver_cb, input intc_procss_rst);
  modport intc_mon_mod(clocking intc_interface_monitor_cb, input intc_procss_rst);

	property irq;
		@(posedge intc_procss_clk) intc_irq |-> ##[0:$] (intc_procss_acklg==2'b01) ##[1:$] (!intc_irq) ##0 intc_procss_acklg==2'b01;
	endproperty

	INTR_IRQ: assert property(irq);
endinterface  
