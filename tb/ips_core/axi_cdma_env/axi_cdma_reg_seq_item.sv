/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/reg_seq_item.sv                         */
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
class reg_seq_item extends uvm_sequence_item;
  
  rand logic [31:0] control_register;
  rand logic [31:0] status_register;
  rand logic [31:0] curdesc_lsb;
  rand logic [31:0] curdesc_msb;
  rand logic [31:0] taildesc_lsb;
  rand logic [31:0] taildesc_msb;
  rand logic [31:0] sa_lsb;
  rand logic [31:0] sa_msb;
  rand logic [31:0] da_lsb;
  rand logic [31:0] da_msb;
  rand logic [31:0] btt;
  rand bit [63:0] curdesc_pntr;
  rand bit [63:0] taildesc_pntr;
  rand bit [63:0] source_addr;
  rand bit [63:0] dest_addr; 
  rand dma_mode_t  dma_mode;
  rand dma_burst_type_t burst_type;
  rand logic reset;
  rand logic cyclic_bd_enable;
  rand logic ioc_intrpt_mask;
  rand logic dly_intrpt_mask;
  rand logic err_intrpt_mask;
  rand logic [7:0] irq_threshold;
  rand logic [7:0] irq_delay;
  rand logic [255:0] sa_da_non_overlap;
 
       `uvm_object_utils_begin(reg_seq_item)
        `uvm_field_enum(dma_mode_t,dma_mode,UVM_ALL_ON)
        `uvm_field_enum(dma_burst_type_t,burst_type,UVM_ALL_ON)
        `uvm_field_int(reset,UVM_ALL_ON)
        `uvm_field_int(cyclic_bd_enable,UVM_ALL_ON)
        `uvm_field_int(ioc_intrpt_mask,UVM_ALL_ON)
        `uvm_field_int(dly_intrpt_mask,UVM_ALL_ON)
        `uvm_field_int(err_intrpt_mask,UVM_ALL_ON)
        `uvm_field_int(irq_threshold,UVM_ALL_ON)
        `uvm_field_int(irq_delay,UVM_ALL_ON)
        `uvm_field_int(control_register,UVM_ALL_ON)
        `uvm_field_int(status_register,UVM_ALL_ON)
        `uvm_field_int(curdesc_pntr,UVM_ALL_ON)
        `uvm_field_int(curdesc_lsb,UVM_ALL_ON)
        `uvm_field_int(curdesc_msb,UVM_ALL_ON)
        `uvm_field_int(taildesc_pntr,UVM_ALL_ON)
        `uvm_field_int(taildesc_lsb,UVM_ALL_ON)
        `uvm_field_int(taildesc_msb,UVM_ALL_ON)
        `uvm_field_int(source_addr,UVM_ALL_ON)
        `uvm_field_int(sa_lsb,UVM_ALL_ON)
        `uvm_field_int(sa_msb,UVM_ALL_ON)
        `uvm_field_int(dest_addr,UVM_ALL_ON) 
        `uvm_field_int(da_lsb,UVM_ALL_ON)
        `uvm_field_int(da_msb,UVM_ALL_ON)
        `uvm_field_int(btt,UVM_ALL_ON)
       `uvm_object_utils_end
   
  `uvm_object_new

 
       //constraint dma_modes {soft dma_mode i; }
       //constraint burst_types{soft burst_type }
       constraint soft_reset {soft reset==0;}
       constraint cyclic_bd_val {soft cyclic_bd_enable==1'b0;}
       constraint ioc_intrpt_mask_val {soft ioc_intrpt_mask inside {1'b0,1'b1};}
       constraint dly_intrpt_mask_val {if(dma_mode==SG_DMA)
                                         soft dly_intrpt_mask inside {1'b0,1'b1};
                                       else 
                                         soft dly_intrpt_mask==0;}
       constraint err_intrpt_mask_val {soft err_intrpt_mask inside {1'b0,1'b1};}
       constraint threshold_val {if(dma_mode==SG_DMA)
                                   soft irq_threshold inside {[1:256]};
                                 else irq_threshold==0;}
       constraint delay_val {if(dma_mode==SG_DMA)
                               soft irq_threshold inside {[0:256]};
                             else irq_delay==0;}

       constraint cntrl_reg {if(reset==0){control_register[2:0]==0; control_register[3]==dma_mode;
                             control_register[5:4]==burst_type; control_register[6]==cyclic_bd_enable;
                             control_register[11:7]==0; control_register[12]==ioc_intrpt_mask;
                             control_register[13]==dly_intrpt_mask; control_register[14]==err_intrpt_mask;
                             control_register[15]==0;
                             control_register[23:16]==irq_threshold;control_register[31:24]==irq_delay;}
                             else if(reset==1)
                             {control_register[31:3]==0;control_register[2]==reset;control_register[1:0]==0;}
                            }

       constraint status_reg{status_register==0;}

       constraint curdesc_val{if(dma_mode==SG_DMA)
                                curdesc_pntr%64 == 0;}
       constraint curdesc_lsb_val {soft curdesc_lsb == curdesc_pntr[31:0];}
       constraint curdesc_msb_val {soft curdesc_msb == curdesc_pntr[63:32];}
       constraint taildesc_val{if(dma_mode==SG_DMA)
                                 taildesc_pntr%64 == 0;}
       constraint taildesc_lsb_val {soft taildesc_lsb == taildesc_pntr[31:0];}
       constraint taildesc_msb_val {soft taildesc_msb == taildesc_pntr[63:32];}
       constraint sa_val {if(dma_mode==SIMPLE_DMA) 
                            soft source_addr >=0; }
       constraint sa_lsb_val {sa_lsb == source_addr[31:0];}
       constraint sa_msb_val {sa_msb == source_addr[63:32];}
       constraint btt_val {if(dma_mode==SIMPLE_DMA)
                             soft btt inside {[1:67108864]};}
       //constraint overlap_val {sa_da_non_overlap == source_addr+btt;}
       constraint da_val {soft dest_addr >= source_addr+btt;
                          if(source_addr <= btt){
                            soft dest_addr inside {[0:source_addr-btt]};
                          }
                         }
       
endclass : reg_seq_item 
