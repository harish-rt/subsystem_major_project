/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_parameters.sv                       */
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
//list of parameters and Typedefs here--
// signal data type typedefs  -- [ _t is suffix for all typedefs]
typedef logic [6:0]       id_t;
typedef logic [31:0]      address_t;
typedef logic [0:0]       valid_t;
typedef logic [0:0]       ready_t;
typedef logic [7:0]       burst_len_t;
typedef logic [2:0]       burst_size_t;
typedef logic [255:0]     data_t;
typedef logic [31:0]      strobe_t;
typedef logic [0:0]       last_t;
typedef logic [3:0]       region_t;
typedef logic [3:0]       cache_t;
typedef logic [2:0]       prot_t;
typedef logic [3:0]       qos_t;
typedef logic [0:0]       lock_t;

parameter ID_WIDTH = 7;
parameter ADDR_WIDTH = 64;
parameter BURST_LENGTH = 8;
parameter BURST_SIZE = 3;
parameter DATA_WIDTH = 255;
parameter STROBE_WIDTH = 4;
parameter REGION_WIDTH = 4;
parameter CACHE_WIDTH = 4;
parameter PROT_WIDTH = 3;
parameter QOS_WIDTH = 4;


typedef enum {FIXED,INCR,WRAP}              burst_type_t;
typedef enum {OKAY,EXOKAY,SLVERR,DECERR}    response_t;
typedef enum {WRITE,READ}                   command_t;
typedef int  delay_t;
typedef enum {NO_RESET,RESET_ASSERTED,RESET_DEASSERTED}    reset_info_t;
typedef enum bit {SIMPLE_DMA,SG_DMA}dma_mode_t;
typedef enum bit [1:0]{SA_INCR_DA_INCR=2'd0,SA_FIXED_DA_INCR=2'd1,SA_INCR_DA_FIXED=2'd2,SA_FIXED_DA_FIXED=2'd3}dma_burst_type_t;
typedef enum logic [31:0]{CNTRL_REG_ADDR    ='h00,
              STATUS_REG_ADDR   = 'h04,
              CURDESC_LSB_ADDR  = 'h08,
              CURDESC_MSB_ADDR  = 'h0C,
              TAILDESC_LSB_ADDR = 'h10,
              TAILDESC_MSB_ADDR = 'h14,
              SA_LSB_ADDR       = 'h18,
              SA_MSB_ADDR       = 'h1C,
              DA_LSB_ADDR       = 'h20,
              DA_MSB_ADDR       = 'h24,
              BTT_ADDR          = 'h28,
	      UNKNOWN   	= 'hx} offset_address_t;
