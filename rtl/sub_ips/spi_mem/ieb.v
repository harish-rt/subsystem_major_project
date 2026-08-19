/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* spi_design/rtl/ieb.v                                                   */
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
`define M1Kb  1
`define M2Kb  0
`define M4Kb  0
`define M8Kb  0
`define M16Kb  0
`define M32Kb  0
`define M64Kb  0
`define M128Kb  0
`define M256Kb  0
`define M512Kb  0
`define M1Mb  0
`define M2Mb  0
//`define MEM_ADDR_BITS 17
`include "M95XXX_Parameters.v"
//`include "/home/nagesh/Desktop/jayakumar_SPI/spi_cl_ieu/rtl/ram.v"
`include "ram.v"



module IEU(
   input write_protect,counter_enable,control_rst,ready_fr_output,data_in_valid,clk_ieb,
   input [`DATA_BITS-1:0]data_in,
   input [`DATA_BITS-1:0]memory_data_out,
   input valid_out_t_ieb,
   input ready_out_t_ieb,
   output reg valid_in_f_ieb,
   output reg [`DATA_BITS-1:0]memory_data_in,
   output reg ready_in_f_ieb,
   output reg ready_fr_input = 0,
   output reg data_out_valid = 0,
   output reg wr= 0,
   output reg memory_rst = 0,
   output reg instr_valid =0,
   output reg [`DATA_BITS-1:0]control_data_out = 0, //FOR READING the data from memory to the control register
   output reg [`MEM_ADDR_BITS-1:0]address_out = 0,
   input reg [`DATA_BITS-1:0]data_out_t_ieb
   );



   parameter WREN = 8'b0000_0110,
             WRDI = 8'b0000_0100,
             RDSR = 8'b0000_0101,
             WRSR = 8'b0000_0001,
             READ = 8'b0000_0011,
             WRITE = 8'b0000_0010,
             RDID = 8'b1000_0011,
             WRID = 8'b1000_0010;


   reg instruction_flag = 1'b0;
   reg address_h2_flag = 1'b0;
   reg address_h_flag = 1'b0;
   reg address_l_flag = 1'b0;
   reg [7:0]address_h2,address_h,address_l;
   reg collect_data_flag = 1'b0;
   reg collect_id_data_flag = 1'b0;
   reg collect_rd_id_data_flag = 1'b0;
   reg [7:0]status_reg = 8'b0;
   reg [`MEM_ADDR_BITS-1:0]address_reg = 0;
   reg [`DATA_BITS-1:0]data_in_reg = 0;
   reg byte_got = 1'b0;
   reg [39:0]instruction = 40'b0;
   reg [7:0]instruction_code = 8'b0;
   reg [`MEM_ADDR_BITS-1:0]temp_address_out = 0;
   reg [`DATA_BITS-1:0]temp_control_data_out = 0;
   reg [`DATA_BITS-1:0]temp_memory_data = 0;
   reg read_pageid_flag = 1'b0;
   reg write_pageid_flag = 1'b0;
   reg wrsr_flag = 1'b0;
   reg [2:0]x=3'b0;
   reg z = 0;//flag which make sures address in write instruction is collected
   reg z_id = 0;
   reg z_rd_id = 0;
   integer i = 0;
   integer counter = 0;
   reg write_flag = 1'b0;
   reg read_flag = 1'b0;
  // reg clk_ieb;

   memory insta(.clk(clk_ieb), .rst(memory_rst), .wr(wr),
             .valid_in_f_ieb(valid_in_f_ieb),
             .data_in_f_ieb(memory_data_in),
             .address_in_f_ieb(address_out),
             .ready_out_t_ieb(ready_out_t_ieb),
             .ready_in_f_ieb(ready_in_f_ieb),
             .valid_out_t_ieb(valid_out_t_ieb),
             .data_out_t_ieb(memory_data_out));

/////////////////clock sync////////////////
/*always @(posedge clk) begin
   #10 clk = ~clk;
   clk_ieb = clk;

end

*/

//////////reset/////////////////////////

   always@(posedge clk_ieb or negedge control_rst) begin
      if(control_rst===1'b0) begin
         memory_rst <= 1'b1;
         control_data_out <= 8'b0;
         status_reg = {status_reg[7],0,0,0,status_reg[3],status_reg[2],0,0};
         instr_valid <= 1'b0;
         ready_fr_input <= 1'b0;
         valid_in_f_ieb <= 1'b0;
         ready_in_f_ieb <= 1'b0;
         address_out <= 0;
         memory_data_in <= 0;
         data_out_valid <= 0;
         instruction_flag = 1'b0;
         write_flag = 1'b0;
         $display($time,"\t//////////////////////////warning: control is reset/////////////////////////");
      end
      else begin
         ready_fr_input <= 1'b1;
      end
   end
/////////////////////////////////////////////////
always@(posedge clk_ieb) begin
 //  $display("//////////////////////////////memoery address bits is %d, data bits is %d///////////////////////////////////",`MEM_ADDR_BITS,`DATA_BITS);
   if (`MEM_ADDR_BITS <= 8) begin
     assign  x = 1;
   end
   else if (`MEM_ADDR_BITS == 9) begin
     assign x = 2;
   end
   else if (9 < `MEM_ADDR_BITS <= 16)
     assign x = 3;
   else if (16 < `MEM_ADDR_BITS <= 24)
    assign  x =4;
end
////////////////////fetching instruction////////////////////////////////

   always@(posedge clk_ieb)
      begin
         if(ready_fr_input && data_in_valid) begin
            data_in_reg = data_in;
            byte_got = 1'b1;
          //  $display($time, "@posedge clk_ieb data in =%b", data_in);
            //instruction_flag = 1'b1;
         end
        // else
          // data_in_reg = 0;
      end

    always@(posedge clk_ieb)
       begin
          if(!address_h2_flag && !address_l_flag && !address_h_flag && !instruction_flag && (wrsr_flag == 1'b0) &&(write_flag == 0) && (read_flag == 0)) begin //&&m
             instruction_flag=1;
 $display($time , "data in valid = %b, instruction_flag = %b,address_h2_flag=%b, collect_rd_id_data_flag = %d", data_in_valid,instruction_flag,address_h2_flag,collect_rd_id_data_flag);
          end
       end

/////////////////////////WRSR execution/////////////////////////////////////////

   always@(posedge clk_ieb) begin
      if(i == 1'b0)
         wrsr_flag = 1'b0;
   end

/////////////////////////////////////////WRITE instruction execution/////////////////////////////////////////////////////////////////

//////////////write address_byte collection////////////////////

   always@(posedge byte_got) begin
      if (z) begin
      z=0;
     // instruction_flag = 1'b0;
     // instruction_code = 1'b0;
    $display($time,"\t///////////////////entered the logic to collect address of write instruction///////address_h2_flag = %b, x=%b",address_h2_flag,x);
      case (x)
         4 : begin
               $display("////////entered address range from 17 to 24////////////////////");
               if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   $display($time, "address h2 = %b", address_h2);
                   byte_got = 1'b0;
                   collect_data_flag = 0;
                end
                else if (address_h_flag) begin
                    address_h_flag = 1'b0;
                    address_l_flag = 1'b1;
                    address_h = data_in_reg;
                    $display($time, "address h = %b", address_h);
                    byte_got = 1'b0;
                    collect_data_flag = 0;
                end
                else if (address_l_flag) begin
                   address_l_flag = 1'b0;
                   address_l = data_in_reg;
                   address_reg = {address_h2,address_h,address_l};
                   address_out = address_reg;
                   byte_got = 1'b0;
                   collect_data_flag = 1'b1;
                end
             end
         3 : begin
               $display("////////entered address range from 10 to 16 ////////////////////");
               if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_data_flag = 0;

                end
                else if (address_h_flag) begin
                    address_h_flag = 1'b0;
                    address_h = data_in_reg;
                    address_reg = {address_h2,address_h};
                    address_out = address_reg;
                    byte_got = 1'b0;
                    collect_data_flag = 1'b1;
                end
                end
          2 : begin
               $display("////////entered address range 9////////////////////");
                if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_data_flag = 1'b0;
                end
                else if (address_h_flag ) begin
                    address_h_flag = 1'b0;
                    address_h = data_in_reg;
                    address_reg = {address_h2[0],address_h};
                    address_out = address_reg;
                    byte_got = 1'b0;
                    collect_data_flag = 1'b1;
                end
              end
          1 : begin
                $display("////////entered address range less than equal to 8////////////////////");
                if(address_h2_flag) begin
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   $display("the address of write is pushed into address_h2= %b",address_h2);
                   address_reg = address_h2;
                   address_out = address_reg;
                   byte_got = 1'b0;
                   if(instruction == WRITE)
                      collect_data_flag = 1'b1;
                   else if (instruction == READ) begin
                      collect_data_flag = 1'b0;
                   end
                 //  instruction_flag =1'b0;
                //   instruction_code = 0;
                   $display("the address of write is pushed into collect_data_flag= %b, address out=%b",collect_data_flag,address_out);
                   //m =1;
                end
              end
     endcase
     end
    end


////////////////wrapping the page depending on page size for different memories/////////////////////////////////////////////////////

   task wrap();
  // if(`M1Kb || `M2Kb || `M4Kb || `M8Kb || `M16Kb || `M32Kb || `M64Kb || `M128Kb || `M256Kb || `M512Kb || `M1Mb || `M2Mb) begin
   if(`M1Kb | `M2Kb | `M4Kb | `M8Kb | `M16Kb | `M32Kb | `M64Kb | `M128Kb | `M256Kb | `M512Kb | `M1Mb | `M2Mb) begin
      $display("///////////////////////entered wrap logic//////////////////,address_reg =%b,data_in_reg=%b,data_in=%b,byte_got=%b",address_reg,data_in_reg,data_in,byte_got);
      if(000_0000 <= address_reg < `PAGE_SIZE) begin
         temp_address_out = address_reg;
         //temp_memory_data = data_in_reg;
         address_out = temp_address_out;
         //address_reg = address_reg + 1;
       //  collect_data_flag = 1'b1;
      end
      else if(address_reg == `PAGES * `PAGE_SIZE) begin
            address_reg = (`PAGES - 1) * `PAGE_SIZE + 1;
            temp_address_out = address_reg;
            //temp_memory_data = data_in_reg;
            address_out = temp_address_out;
           // address_reg = address_reg + 1;
         //   collect_data_flag = 1'b1;
      end
      else  begin
      for(integer a = 1; a<=(`PAGES - 1) ; a = a + 1) begin
      if(a * `PAGE_SIZE  <= address_reg < (a + 1) * `PAGE_SIZE) begin
         if(address_reg == a * `PAGE_SIZE) begin
            address_reg = (a - 1) * `PAGE_SIZE + 1;
            temp_address_out = address_reg;
            //temp_memory_data = data_in_reg;
            address_out = temp_address_out;
           // address_reg = address_reg + 1;
          //  collect_data_flag = 1'b1;
         end
         else begin
            temp_address_out = address_reg;
            temp_memory_data = data_in_reg;
            address_out = temp_address_out;
           // address_reg = address_reg + 1;
           // collect_data_flag = 1'b1;
         end
      end
      end
      end
      $display($time, "END of WRAP logic");
   end
  endtask

/////////////////////////write data collection//////////////////////////////////////////
   always@(data_in) begin
      if(collect_data_flag) begin
         temp_memory_data = data_in;
         wr = 1'b1;
         $display("/////////////////////data collection/////////data_in = %b",data_in);
         memory_data_in = temp_memory_data;
         valid_in_f_ieb = 1'b1;
         instruction_flag = 0;
         //write_flag = 1'b0;

      end
         data_in_reg = 0;
       //  collect_data_flag = 1'b0;
   end

    always@(collect_data_flag) begin
      if(collect_data_flag)
       instruction = WRITE;
       instruction_flag = 1'b0;
    end

    always@(read_flag) begin
       if(read_flag == 1'b1) begin
          instruction = READ;
          instruction_flag = 1'b0;
       end
       else
          instruction = 0;
    end

/*    always @(clk_ieb)
    if(data_flag)
     counter++;
     if(counter==15)
        instruction_flag=1;
     if(data_byte_got)
        counter = 0;
*/
   always@(posedge clk_ieb) begin
      if(write_flag) begin
         counter = counter+1;
       //  $display($time, "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ counter = %d  @@@@@@@@@@@@@@@@@@@@@@@@@@",counter);
      end
      if(counter == 4) begin
         instruction_flag = 1'b1;
         counter = 0;
         write_flag = 1'b0;
         data_in_reg = 0;
      end
   end

/////////////////////////////////////////////////end of WRITE instruction///////////////////////////////



/////////////////////////////////////READ identification execution(RDID)///////////////////////////////////
////////////////RDID address_byte collection////////////////////////////

   always@(posedge byte_got) begin
      if (z_rd_id) begin
      z_rd_id = 0;
      instruction_flag = 1'b0;
      instruction_code = 1'b0;
    $display($time,"\t///////////////////entered the logic to collect address of rdid instruction///////address_h2_flag = %b, x=%b",address_h2_flag,x);
      case (x)
         4 : begin
               if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_rd_id_data_flag = 0;
                end
                else if (address_h_flag) begin
                    address_h_flag = 1'b0;
                    address_l_flag = 1'b1;
                    address_h = data_in_reg;
                    byte_got = 1'b0;
                    collect_rd_id_data_flag = 0;
                end
                else if (address_l_flag) begin
                   address_l_flag = 1'b0;
                   address_l = data_in_reg;
                   address_reg = {address_h2,address_h,address_l};
                   address_out = address_reg;
                   byte_got = 1'b0;
                   collect_rd_id_data_flag = 1'b1;
                end
             end
         3 : begin
               if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_rd_id_data_flag = 0;

                end
                else if (address_h_flag) begin
                    address_h_flag = 1'b0;
                    address_h = data_in_reg;
                    address_reg = {address_h2,address_h};
                    address_out = address_reg;
                    byte_got = 1'b0;
                    collect_rd_id_data_flag = 1'b1;
                end
                end
          2 : begin
                if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_rd_id_data_flag = 1'b0;
                end
                else if (address_h_flag ) begin
                    address_h_flag = 1'b0;
                    address_h = data_in_reg;
                    address_reg = {address_h2[0],address_h};
                    address_out = address_reg;
                    byte_got = 1'b0;
                    collect_rd_id_data_flag = 1'b1;
                end
              end
          1 : begin
                if(address_h2_flag) begin
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   $display("the address of RDID write is pushed into address_h2= %b",address_h2);
                   address_reg = address_h2;
                   address_out = address_reg;
                   byte_got = 1'b0;
                   collect_rd_id_data_flag = 1'b1;
                   read_pageid_flag = 1'b1;
                 //  instruction_flag =1'b0;
                 //  instruction_code = 1'b0;
                   $display("the address of RDID write is pushed into collect_rd_id_data_flag= %b, address out=%b",collect_rd_id_data_flag,address_out);
                   //m =1;
                end
              end
     endcase
     end
     end

////////////////////////RDID data collection///////////////
always@(posedge clk_ieb) begin
if((read_pageid_flag == 1'b1))
   begin
       id_wrap();
       $display($time, "in read page id flag address reg[10] =%b, collect_rd_id_data_flag=%b",address_reg[10],collect_rd_id_data_flag);
       if((address_reg[10] === 1'bx) && (collect_rd_id_data_flag == 1'b1) ) begin
             control_data_out = memory_data_out;
             $display($time, "read identification is done>>>>>control data out =%b, address out =%b",memory_data_out,address_out);
       end
       //else
         // $display($time,"Read operation from identification page fail");
   end
//else
//   $display($time,"Read operation from identification page fail");
end



    always@(collect_rd_id_data_flag) begin
      if(collect_rd_id_data_flag)
       instruction = RDID;
       instruction_flag = 1'b0;
    end

////////////////////////////END OF RDID EXECUTION/////////////////////////////////////////////////////////

//////////////////////////////////////////////////WRID identification execution/////////////////////////////////////////////////////////////////////

////////////////WRID address_byte collection////////////////////////////

   always@(posedge byte_got) begin
      if (z_id) begin
      z_id = 0;
      instruction_flag = 1'b0;
      instruction_code = 1'b0;
    $display($time,"\t///////////////////entered the logic to collect address of write instruction///////address_h2_flag = %b, x=%b",address_h2_flag,x);
      case (x)
         4 : begin
               if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_id_data_flag = 0;
                end
                else if (address_h_flag) begin
                    address_h_flag = 1'b0;
                    address_l_flag = 1'b1;
                    address_h = data_in_reg;
                    byte_got = 1'b0;
                    collect_id_data_flag = 0;
                end
                else if (address_l_flag) begin
                   address_l_flag = 1'b0;
                   address_l = data_in_reg;
                   address_reg = {address_h2,address_h,address_l};
                   address_out = address_reg;
                   byte_got = 1'b0;
                   collect_id_data_flag = 1'b1;
                end
             end
         3 : begin
               if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_id_data_flag = 0;

                end
                else if (address_h_flag) begin
                    address_h_flag = 1'b0;
                    address_h = data_in_reg;
                    address_reg = {address_h2,address_h};
                    address_out = address_reg;
                    byte_got = 1'b0;
                    collect_id_data_flag = 1'b1;
                end
                end
          2 : begin
                if(address_h2_flag) begin
                   address_h_flag = 1'b1;
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   byte_got = 1'b0;
                   collect_id_data_flag = 1'b0;
                end
                else if (address_h_flag ) begin
                    address_h_flag = 1'b0;
                    address_h = data_in_reg;
                    address_reg = {address_h2[0],address_h};
                    address_out = address_reg;
                    byte_got = 1'b0;
                    collect_id_data_flag = 1'b1;
                end
              end
          1 : begin
                if(address_h2_flag) begin
                   address_h2_flag = 1'b0;
                   address_h2 = data_in_reg;
                   $display("the address of WRID write is pushed into address_h2= %b",address_h2);
                   address_reg = address_h2;
                   address_out = address_reg;
                   byte_got = 1'b0;
                   collect_id_data_flag = 1'b1;
                 //  instruction_flag =1'b0;
                 //  instruction_code = 1'b0;
                   $display("the address of WRID write is pushed into collect_id_data_flag= %b, address out=%b",collect_id_data_flag,address_out);
                   //m =1;
                end
              end
     endcase
     end
     end

//////////////////////////WRID DATA COLLECTION///////////////////////////

always@(posedge clk_ieb) begin
   if((write_pageid_flag == 1'b1) && (byte_got == 1'b1)) begin
      id_wrap();
      if ((`MEM_ADDR_BITS <= 8) || (`MEM_ADDR_BITS == 9)) begin
         memory_data_in = data_in_reg;
        // $display($time, " data in reg =%b,collect_id_data_flag=%b",data_in_reg,collect_id_data_flag);
         $display($time, "write identification is done >>>>>> memory data in =%b, address out =%b",memory_data_in,address_out);
         write_pageid_flag = 1'b0;
      end
      else if ((address_out[10] == 1'b0) && (collect_id_data_flag == 1'b1))begin
         memory_data_in = data_in_reg;
         $display($time, "write identification is done >>>>>> memory data in =%b, address out =%b",memory_data_in,address_out);
      end
      else
         $display($time, "write to identification fail");
       //  write_pageid_flag = 1'b0;
    end
end

   always@(data_in) begin
      if(collect_id_data_flag) begin
         temp_memory_data = data_in;
         wr = 1'b1;
        write_pageid_flag = 1'b1;
         $display("/////////////////////data collection/////////data_in = %b",data_in);
         memory_data_in = temp_memory_data;
         instruction_flag = 0;
         write_flag = 1'b0;
      end
         collect_id_data_flag = 1'b0;
         data_in_reg = 0;
   end

    always@(collect_id_data_flag) begin
      if(collect_id_data_flag)
       instruction = WRID;
       instruction_flag = 1'b0;
    end
/////////////////////////////////////////////////


////////////////////////WRID WRAP LOGIC////////////////////////////////////////

   task id_wrap();
   if(`M1Kb | `M2Kb | `M4Kb | `M8Kb | `M16Kb | `M32Kb | `M64Kb | `M128Kb | `M256Kb | `M512Kb | `M1Mb | `M2Mb) begin
      $display("///////////////////////entered id wrap logic//////////////////,address_reg =%b,data_in_reg=%b,data_in=%b,byte_got=%b",address_reg,data_in_reg,data_in,byte_got);
      if(000_0000 <= address_reg < `PAGE_SIZE) begin
         temp_address_out = address_reg;
         address_out = temp_address_out;
      end
      else if(address_reg == `PAGES * `PAGE_SIZE) begin
            address_reg = (`PAGES - 1) * `PAGE_SIZE + 1;
            temp_address_out = address_reg;
            address_out = temp_address_out;
      end
      else  begin
      for(integer a = 1; a<=(`PAGES - 1) ; a = a + 1) begin
      if(a * `PAGE_SIZE  <= address_reg < (a + 1) * `PAGE_SIZE) begin
         if(address_reg == a * `PAGE_SIZE) begin
            address_reg = (a - 1) * `PAGE_SIZE + 1;
            temp_address_out = address_reg;
            address_out = temp_address_out;
         end
         else begin
            temp_address_out = address_reg;
            temp_memory_data = data_in_reg;
            address_out = temp_address_out;
         end
      end
      end
      end
      $display($time, "END of WRID WRAP logic");
   end
  endtask

////////////////////////END OF WRID INSTRUCTION EXECUTION////////////////////////////////////

/////////////////////////////////////////////////

//DECODING  the instruction
   always @(posedge clk_ieb) begin
      if((instruction_flag===1'b1) && (i%2 == 0)) begin
         $display("/////////////////entered decoding stage //////////////////// ");
         instruction_code = data_in_reg;
         $display($time, "in decoding stage ////instruction code = %b", instruction_code);
         instruction_flag = 1'b0;
         casex (instruction_code)
         8'b0000_x110: begin  instruction = WREN; instr_valid=1'b1; $display("***********my name is nagesh **************************");  end
         8'b0000_x100: begin  instruction = WRDI; instr_valid=1'b1;  end
         8'b0000_x101: begin  instruction = RDSR; instr_valid=1'b1;  end
         8'b0000_x001: begin  instruction = WRSR; instr_valid=1'b1;  end
         8'b0000_x011: begin  instruction = READ; instr_valid=1'b1;address_h2_flag = 1'b1;$display("////////////enterred into read decoding stage/////////////");  end
         8'b0000_x010: begin  instruction = WRITE; instr_valid=1'b1;address_h2_flag = 1'b1;$display("////////////enterred into write decoding stage/////////////"); end
         8'b1000_x011: begin  instruction = RDID; instr_valid=1'b1;  end
         8'b1000_x010: begin  instruction = WRID; instr_valid=1'b1;  end
      default:
        $display($time,"\t//////////////////////////////Invalid instruction//////////////////////////");
      endcase
    end
   end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//executing the instructions
always @(posedge clk_ieb) begin
   case(instruction)
      WREN : begin
               instruction = 40'b0;
               $display("@@@@@@@@@@@@@@@@status_reg=%b, write_protect=%b",status_reg,write_protect);
                if ((write_protect == 1 && status_reg[7] == 0) || (write_protect == 0 && status_reg[7] == 0) || (write_protect == 1 && status_reg[7] == 1)) begin
                   if(status_reg[0] == 1'b1) //Write In Progress
                      $display($time,"\t/////////////////////Internal Write is already in progress////////////////////");
                   else begin
                      status_reg[1] = 1'b1; //WEL is set to 1
                      $display ($time,"\t/////////////Write is enabled//////////////////////////");
                   end
                 end
                else
                   $display($time,"/////////////////WREN is disabled///////////////////////////");
             end

      WRDI : begin
               instruction = 40'b0;
                if ((write_protect == 1 && status_reg[7] == 0) || (write_protect == 0 && status_reg[7] == 0) || (write_protect == 1 && status_reg[7] == 1)) begin
                   if(status_reg[0] == 1'b1)  //Write In Progress
                      $display ($time,"\t/////////////////////Internal Write is already in progress/////////////////////////");
                   else begin
                      status_reg[1] = 1'b0;     //WEL is set to 0
                      $display ($time,"\t//////////////////////Write is disabled/////////////////////////////status register = %b",status_reg);
                   end
                end
               end


      WRITE  :  begin
                 write_flag = 1'b1;
                 $display("/////ready_out_t_ieb is %b in write instruction",ready_out_t_ieb);
                 wr = 1'b1;
                 if(ready_out_t_ieb == 1) begin
               //  instruction = 40'b0;
                 z = 1;
                 byte_got = 1'b0;
                 $display($time,"\t/////////////////////entered into write execution stage//////////status_reg = %b,write_protect=%b,byte_got=%b,collect_data_flag = %b,",status_reg,write_protect,byte_got,collect_data_flag);
                //address_h2_flag = 1'b1;
               // if(collect_data_flag ) begin
                $display($time,"\t/////////////////////entered EVALUATING THE DATA IN WRITE INSTRUCTION///////////////////////");
                if((write_protect==1 && status_reg[7]==0)||(write_protect==0 && status_reg[7]==0)||(write_protect==1 && status_reg[7]==1)||(write_protect==0 && status_reg[7]==0)) begin
                   $display("/////passed the hadware and software modes////////////");
                   if(status_reg[1] == 1) begin //WEL ==1
                      status_reg[0] = 1'b1; //WIP
                     // wr = 1'b1; //WRITING to memory
                      $display("condtion in write execution, counter_enable = %b,collect_data_flag=%b,byte_got=%b,write_flag= %b",counter_enable,collect_data_flag,byte_got,write_flag);
                      if((counter_enable == 1) && (collect_data_flag == 1)) begin ///&byte_got//condition which i deleted
                         //collect_data_flag = 1'b0;
                         byte_got = 1'b0;
                       //  write_flag = 1'b1;
                         $display("///////check the status register bits 3 and 2 = %b",status_reg);
                            case ({status_reg[3],status_reg[2]}) //BP1 and BP0
                               2'b00 :  wrap();
                               2'b01 :  begin
                                          if (address_reg[20] == 0) begin
	            wrap();
	          end
	          end
                               2'b10 :  begin
                                     //    if (address_reg[21] == 0) begin
	             wrap();
	       //   end
	          end
                          endcase
                          $display($time,"\t//////////////////write operation is done/////////////////memory_data_in=%b, address_out=%b",memory_data_in,address_out);
                          instruction = 0;
                          status_reg[0] = 1'b0;
                          valid_in_f_ieb = 1'b0;
                          address_reg = address_reg + 1;
                          write_flag = 1'b0;
                         // data_in_reg =0;
                          collect_data_flag = 1'b0;
                    end
                 end
               end
               else
                    $display("write is disabled");
               end
               else
                  $display("///////////////ready signal is not received from ram block to ieb");
               end
   READ   :   begin
               z = 1;
               wr = 1'b0;
               read_flag = 1'b1;
             //  instruction = 40'b0;
              // instruction_flag = 1'b0;
               $display("/////////////entered into read instruction execution ,,wip = %b,ready_out_t_ieb = %b//////////////",status_reg[0],ready_out_t_ieb);
                 if(status_reg[0] == 1'b1)
                    $display($time, "An internal write cycle is in progress READ from memory is rejected ");
                 else if(ready_out_t_ieb == 1'b1) begin
                  //  wr <= 1'b0;
                  //  if(ready_out_t_ieb == 1'b1) begin
                       valid_in_f_ieb <= 1'b1;
                       $display("//////////////////entered into read instruction and we are about to enter wrap logic///////////////////");
                       wrap();
                       $display($time, "in read operation we are abt to enter valid out to ieb=%b", valid_out_t_ieb);
                   // end
                    ready_in_f_ieb = 1'b1;
                    if(valid_out_t_ieb==1'b1) begin
                       $display("//////////////in read memory data out is = %b////////////////////",memory_data_out);
                       temp_memory_data = memory_data_out;
                       control_data_out = temp_memory_data;
                     //  memory_data_out = temp_memory_data;
                        read_flag = 1'b0;
                       $display("READ from memory operation is done/////////////control_data_out = %b, address_reg = %b",control_data_out,address_reg);
                    end
                 end
                     //  address_reg = address_reg - 1;
               end


    WRSR   :  begin
               //instruction = 40'b0;
                 //address_h2_reg = 1'b1;
                 byte_got = 1'b0;
                 if(status_reg[0] == 1) begin // WIP ==1
                    $display($time,"\t/////error: write is in progress,WRSR instruction is discarded//////////");
                    status_reg = status_reg;
                 end
                 else if(status_reg[1] == 0) begin //WEL ==0
                    $display($time,"\t////////error: write enable is low,WRSR instruction is discarded///////////");
                    status_reg = status_reg;
                 end
                 else if(status_reg[7] == 1 && write_protect == 0) begin
                    $display($time,"\t///////////error: status register is hardware write protected,WRSR instruction is discarded///////");
                    status_reg = status_reg;
                 end
                 else begin
                    wrsr_flag = 1'b1;
                    i = i+1;
                    if(i%2 == 0) begin
                    status_reg[7] = data_in_reg[7]; //SRWD
                    status_reg[3] = data_in_reg[3]; //BP1
                    status_reg[2] = data_in_reg[2]; //BP0
                    $display($time,"\t////////////////info : status register is updated due to WRSR instruction////////////////// status reg=%b, i = %b",status_reg,i[3:0]);
                    i = 0;
                    instruction = 0;
                    //instruction_code = 0;
                 end
                 end
                 end
       RDSR    : begin
                  instruction = 40'b0;
                       temp_control_data_out = status_reg;
                       control_data_out = temp_control_data_out;
                       $display($time,"\t////////////info: status register is read , CONTROL_DATA_OUT = %b///////////////",control_data_out);
                 end

       RDID   : begin
                //  $display($time, "in RDID status_reg[0]=%b",status_reg[0]);
                  z_rd_id = 1'b1;
                  instruction = 0;
                  byte_got = 1'b0;
                 // read_pageid_flag = 1'b1;
                  if(status_reg[0] == 1'b1)
                     $display($time, "An internal write cycle is in progress, RDID instruction is rejected");
                  else if(status_reg[0] == 1'b0) begin
                     address_h2_flag = 1'b1;
                 //    idisplay($time, "in RDID address h2 flag=%b",address_h2_flag);
                  end
                 // $display($time, "read identification is done>>>>>control data out =%b, address out =%b",memory_data_out,address_out);
               end

       WRID   : begin
                   z_id = 1'b1;
                   $display($time, "Entered write identification status_reg=%b",status_reg);
                   instruction = 0;
                   byte_got = 1'b0;
                   instruction_flag = 1'b0;
                   if(status_reg[0] == 1'b1)
                      $display($time, "An internal write cycle is in progress, WRID instruction is rejected");
                   else if(status_reg[1] == 1'b1) begin
                     // write_pageid_flag = 1'b1;
                      address_h2_flag = 1'b1;
                     // $display($time, "*********************write page id flag = %b**************************",write_pageid_flag);
                     // wrap();
                   end
                //   $display($time, "write identification is done >>>>>> memory data in =%b, address out =%b",memory_data_in,address_out);
                end

          endcase

//$display($time, "???????????????memory_data_out =%b?????????????", memory_data_out);
end
//assign memory_data = temp_memory_data;

/////////////////////////////memory instantiation///////////////////////////////////
endmodule

//////////////////////////////////////////////////////**********************************/////////////////////////////////////////////


