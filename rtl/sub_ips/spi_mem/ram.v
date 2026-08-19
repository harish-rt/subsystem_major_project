/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* spi_design/rtl/ram.v                                                   */
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
// Code your design here
module ram #(parameter WIDTH=8,ADDR=4)

  (data_o,data_in,wr,wrid,addr,clk,rst);


  input [WIDTH-1:0] data_in;
  input clk,rst,wr; //(wr/~rd) enable pin --> wr
  input wrid;//wrid=1 refers to memory || during simulation it can change so can't use as parameter
             //wrid=0 refers pages
  input [ADDR-1:0] addr;
  output reg [WIDTH-1 :0] data_o;

  reg [WIDTH-1:0] mem [(2**ADDR-1) : 0] ;//depth of memory
  reg [7:0] page [255:0];//depth of pages
  integer i,j;

  always@(posedge clk or posedge rst) begin
    if (rst) begin
       data_o <= 0;
       for (i=0;i<2**ADDR ;i=i+1) begin
          mem[i] <=0;
       end
      for (j=0;j<255 ;j=j+1) begin
        page[j] <=0;
       end
    end
    else begin
      if(wrid) begin
        if (wr)
          mem[addr] <= data_in;
        else
        mem[addr] <= mem[addr];
        if(!wr)
         data_o <= mem[addr];
        else
         data_o <= data_o;
      end
      else begin
        if (wr)
          page[addr[7:0]] <= data_in;
        else
          page[addr[7:0]] <= page[addr[7:0]];
        if(!wr)
          data_o <= page[addr[7:0]];
        else
         data_o <= data_o;
      end
    end
  end


endmodule
