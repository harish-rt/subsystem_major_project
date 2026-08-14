package axi_slave_pkg;

    
    import uvm_pkg::*;
    import axi_parameter_pkg::*;
    import mem_model_pkg::*;
    import ibex_cosim_agent_pkg::*;

typedef logic [6:0]       id_t;
typedef logic [31:0]      address_t;
typedef logic [0:0]       valid_t;
typedef logic [0:0]       ready_t;
typedef logic [7:0]       burst_len_t;
typedef logic [2:0]       burst_size_t;
typedef logic [31:0]      data_t;
typedef logic [3:0]       strobe_t;
typedef logic [0:0]       last_t;
typedef logic [3:0]       region_t;
typedef logic [3:0]       cache_t;
typedef logic [2:0]       prot_t;
typedef logic [3:0]       qos_t;
typedef logic [0:0]       lock_t;;

typedef enum {OKAY,EXOKAY,SLVERR,DECERR}    response_t;
typedef enum {WRITE,READ}                   command_t;

typedef enum {FIXED,INCR,WRAP}              burst_type_t;
typedef int  delay_t;
typedef enum {NO_RESET,RESET_ASSERTED,RESET_DEASSERTED}    reset_info_t;
typedef enum bit {SIMPLE_DMA,SG_DMA}dma_mode_t;
typedef enum bit [1:0]{SA_INCR_DA_INCR=2'd0,SA_FIXED_DA_INCR=2'd1,SA_INCR_DA_FIXED=2'd2,SA_FIXED_DA_FIXED=2'd3}dma_burst_type_t;
typedef enum bit [31:0]{CNTRL_REG_ADDR    ='h00,
              STATUS_REG_ADDR   = 'h04,
              CURDESC_LSB_ADDR  = 'h08,
              CURDESC_MSB_ADDR  = 'h0C,
              TAILDESC_LSB_ADDR = 'h10,
              TAILDESC_MSB_ADDR = 'h14,
              SA_LSB_ADDR       = 'h18,
              SA_MSB_ADDR       = 'h1C,
              DA_LSB_ADDR       = 'h20,
              DA_MSB_ADDR       = 'h24,
              BTT_ADDR          = 'h28}offset_address_t;
    
    `include "uvm_macros.svh"
    //`include "axi_slave_intf.sv"
    `include "axi_base_seq_item.sv"
    `include "axi_slave_agent_cfg.sv"
    
    `include "axi_slave_seq_item.sv"
    
    `include "axi_slave_driver.sv"
    `include "axi_slave_monitor.sv"
    `include "axi_slave_sequencer.sv"
    `include "axi_slave_sequence.sv"
    `include "axi_slave_agent.sv"

endpackage
