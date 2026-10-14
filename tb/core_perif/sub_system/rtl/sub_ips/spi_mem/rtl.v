/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* spi_design/rtl/rtl.v                                                   */
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
module SPI #(parameter add_width_in_bytes= 3,reg_width = 8,PG = 20 ,PG_S = 32)
           (    input c,      // serial clock
                input d,      // serial data in
                input s,      // chip select active low
                input w,      // write protect active low
                input hold,   // hold active low
                input rst,     // power on reset
                output q  // serial data output
                );

wire [reg_width-1:0] data_from_ram;
wire [reg_width-1:0] data_to_ram;
wire [(add_width_in_bytes << 3)-1:0] address;
wire we;
wire mem_or_page;
wire inv_clk;


`ifndef SYNTHESIS
   initial $display($time," ==========================================================================address_width =%0d,reg_width=%0d,pages=%0d,page_size=%0d",add_width_in_bytes,reg_width,PG,PG_S);
`endif

spi_control_logic #(3,8,PG,PG_S) control_logic (
                                              .c(c),
	                .d(d),
	                .s(s),
	                .w_n(w),
	                .hold_n(hold),
	                .rst(rst),
	                .q(q),
	                .read_data_in(data_from_ram),
	                .data_out(data_to_ram),
	                .address_out(address),
	                .we(we),
	                .mem_or_page(mem_or_page),
	                .inv_clk(inv_clk)
	                );

ram #(reg_width,(add_width_in_bytes << 3)) RAM (
                                                .data_o(data_from_ram),
	                  .data_in(data_to_ram),
	                  .wr(we),
	                  .wrid(mem_or_page),
	                  .addr(address),
	                  .clk(inv_clk),
	                  .rst(rst)
	                  );


endmodule:SPI

