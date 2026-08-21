/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* HOME/AXI_CDMA/tb/axi_cdma_interrupt_monitor.sv                                  */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2021                       */
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
class axi_cdma_interrupt_monitor extends uvm_monitor ;

    `uvm_component_utils(axi_cdma_interrupt_monitor)	
     virtual axi_cdma_interrupt_intf.MON_MOD_interrupt mon_if;
     uvm_analysis_port #(axi_cdma_interrupt_seq_item) mon_ap;
     axi_cdma_interrupt_seq_item collect_packet;

     function new(string name="axi_cdma_interrupt_monitor",uvm_component parent);
        super.new(name,parent);
        mon_ap = new("mon_ap",this);
     endfunction


     extern task main_phase(uvm_phase phase); 
     extern task capture_interrupt(axi_cdma_interrupt_seq_item seq_item);
     //extern task put_packet(axi_cdma_interrupt_seq_item seq_item);

endclass : axi_cdma_interrupt_monitor


task axi_cdma_interrupt_monitor::main_phase(uvm_phase phase);
   `uvm_info("Interrupt_MONITOR::main_phase","RUN Phase of MONITOR",UVM_NONE);
    super.main_phase(phase);
      forever begin 
        capture_interrupt(collect_packet);
      end
   

endtask : main_phase 

task axi_cdma_interrupt_monitor::capture_interrupt(axi_cdma_interrupt_seq_item seq_item);
    int no_of_interrupts,no_of_interrupts_bar;
    seq_item = axi_cdma_interrupt_seq_item::type_id::create("seq_item");
   `uvm_info("Interrupt_MONITOR::capture_interrupt","RUN Phase of MONITOR",UVM_NONE);
    forever begin
      @(posedge mon_if.int_mon_cb.interrupt_out)
      seq_item.interrupt_out = mon_if.int_mon_cb.interrupt_out;  
     no_of_interrupts++;
   `uvm_info("Interrupt_MONITOR:RUN",$sformatf("pkt.interrupt_out=%b interface.interface=%b no_of_interrupts=%0d",seq_item.interrupt_out,mon_if.int_mon_cb.interrupt_out,no_of_interrupts),UVM_NONE);
      mon_ap.write(seq_item);
      @(mon_if.int_mon_cb);
    end
    forever begin
      @(negedge mon_if.int_mon_cb.interrupt_out)
      seq_item.interrupt_out = mon_if.int_mon_cb.interrupt_out;
      no_of_interrupts_bar++;  
   `uvm_info("Interrupt_MONITOR:RUN",$sformatf("pkt.interrupt_out=%b interface.interface=%b no_of_interrupts_bar=%0d",seq_item.interrupt_out,mon_if.int_mon_cb.interrupt_out,no_of_interrupts_bar),UVM_NONE);
      mon_ap.write(seq_item);
      @(mon_if.int_mon_cb);
    end

endtask :capture_interrupt


