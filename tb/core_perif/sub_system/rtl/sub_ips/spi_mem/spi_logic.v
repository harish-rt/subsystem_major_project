/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* spi_design/rtl/spi_logic.v                                             */
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
module spi_control_logic #(parameter ADD_WIDTH_IN_BYTES= 3,DATA_WIDTH = 8,PG = 20 ,PG_S = 32)//parameter capital, data_width
               (input c,      // serial clock
                input d,      // serial data in
                input s,      // chip select active low
                input w_n,      // write protect active low
                input hold_n,   // hold active low
                input rst,    // power on reset
                output q,     // serial data output
             // ports to communicate with RAM
                input [DATA_WIDTH-1:0] read_data_in,  // Data From Ram
                output reg [DATA_WIDTH-1:0] data_out, // for increment addres for next byte of data
                output reg [(ADD_WIDTH_IN_BYTES << 3)-1:0] address_out, //address for RAM
                output reg we,          //read ==  0  write== 1
                output reg mem_or_page, //memory =1 id_page =0
                output inv_clk
                );

                //check for write address[] and w_n pin

parameter SIZE = 3;
integer count = ADD_WIDTH_IN_BYTES;   //address width in bytes
reg                  read_mem_page;   // reading from memory or identification pages
reg                  read_status_reg; // reading from status register
reg                  s_hold_n;          // synchronous HOLD signal
reg [1:0]            counter_enable;  // For Incrementing counter
reg                  data_valid;      // data in temp is valid
reg [7:0]            data_reg;
reg [3:0]            position;        // index of output data Q pin			//bug 4bits enough
reg [3:0]            instruction;     // instruction FSM working on
reg                  address_valid;   // address is valid in address_reg
reg [7:0]            status_reg;      // status register
reg [SIZE-1:0]       curr_st;         //current state
reg [SIZE-1:0]       next_st;         //next state
reg [DATA_WIDTH-1:0] bitdata;         //using as 8-bit shift register
reg [3:0]            counter;         // counter for 8 bit shift register
reg                  page_lock;       // page lock status
reg [7:0]            page_lock_reg;   // page lock status out reg
reg                  page_lock_instruction; //
reg                  lock_status;   // flage for output of page lock status
reg [(ADD_WIDTH_IN_BYTES << 3)-1:0] address; // address register


  parameter S0_IDLE        = 3'b000,
            S1_INSTRUCTION = 3'b001,
            S2_ADDRESS     = 3'b010,
            S3_DATA        = 3'b100;

   parameter WE  = 4'b0110, //6
             WD  = 4'b0100, //4
             RS  = 4'b0101, //5
             WS  = 4'b0001, //1
             RD  = 4'b0011, //3
             WR  = 4'b0010, //2
             RID = 4'b1011, //11
             WID = 4'b1010; //10
    //       RLS = 4'b1011, //11 check A10 bit of add 1 all other bits x || data out lsb[0]=1 lock is active
    //       LID = 4'b1010, //10 check A10 bit of add 1 all other bits x || data read= xxxx_xx1x

   parameter WREN = 8'd6,
             WRDI = 8'd4,
             READ = 8'd3,
             WRITE= 8'd2,
             WRSR = 8'd1,
             RDSR = 8'd5,
             RDID = 8'd131,
             WRID = 8'd130;



assign inv_clk = ~c;

////////////////////////////////////////////////////////  FSM LOGIC STARTS HERE  //////////////////////////////////////////////////////////////////////
  always @ (posedge c or posedge rst) //async rst ?
  begin
     if (rst === 1 || s === 1) begin	
        curr_st <= S0_IDLE;
        counter <= 0;
     end else if (hold_n === 1) begin	//condition bug
        curr_st <= next_st;

       `ifndef SYNTHESIS
          $display($time,"seq block next_state=%0b,counter=%0d,datain=%0b,bitdata=%8b,",next_st,counter,d,bitdata);
       `endif

        if (counter === 8)
           counter <= 1;
        else
           counter <= counter + 1;
     end else if (hold_n === 0) begin //condition bug
        counter <= counter;
        curr_st <= curr_st;
     end
  end


always @ (curr_st or counter ) begin //or instruction or s or count or counter_enable) begin

   case (curr_st)
   S0_IDLE    :begin
                  if( s === 0) begin//&& read_data_flag === 0 ) //read_data_flag optional
                     next_st = S1_INSTRUCTION;
                     bitdata = {d,7'b0}; //loading one bit in idle
                  end else
                     next_st = S0_IDLE;
                  counter_enable = 0;
                  data_reg = 0;
                  data_valid = 0;
                  address_valid = 0;
                  address = 'h0;
                  count  = ADD_WIDTH_IN_BYTES;
                  instruction = 0;
                  mem_or_page = 1; //pointing to memory
               end
S1_INSTRUCTION:begin
                  bitdata[DATA_WIDTH-counter] = d;//loading shift register
                  if(counter === 8)begin
                     data_reg = bitdata;
                   `ifndef SYNTHESIS
                      $display($time,"inside instr data_reg = %d",data_reg);
                   `endif             //instruction decoder logic
                     case (data_reg)
                       WREN : begin instruction = WE; next_st = S1_INSTRUCTION;   end
                       WRDI : begin instruction = WD; next_st = S1_INSTRUCTION;   end
                       RDID : begin instruction = RID;next_st = S2_ADDRESS; mem_or_page = 0;end
                       READ : begin instruction = RD; next_st = S2_ADDRESS; end
                       WRITE: begin instruction = WR; next_st = S2_ADDRESS; end
                       WRID : begin instruction = WID;next_st = S2_ADDRESS; mem_or_page = 0; end
                       RDSR : begin instruction = RS; next_st = S3_DATA;    end
                       WRSR : begin instruction = WS; next_st = S3_DATA;    end
                    default : begin instruction = 0;  next_st = S0_IDLE;    end
                     endcase
                  end else begin
                     next_st = S1_INSTRUCTION;
                  end
               end
   S2_ADDRESS :begin
                  bitdata[DATA_WIDTH-counter] = d;
                  if(counter === 8)begin
                     count = count-1;
                     if (count === 2)
                        address[23:16] = {6'b0,bitdata[1:0]}; //may bug corrrected 
                     else if (count === 1)
                        address[15:8] = bitdata;
                     else begin // count == 0
                        address[7:0] = bitdata;
                        address_valid = 1;
                        next_st = S3_DATA;

                        if (instruction === RD || instruction === RID) begin  // extra 3 line for read
                            counter_enable = 1;
                        end

                     end
                  `ifndef SYNTHESIS
                     $display($time,"inside addres data_reg = %24b and count=%0d",address,count);
                  `endif
                  end else begin
                     next_st = S2_ADDRESS;
                     address_valid = 1'b0;
                  end
               end
   S3_DATA    :begin
                  if (instruction === RD || instruction === RID || instruction === RS) begin
                     `ifndef SYNTHESIS
                        $display($time,"Read instruction");
                     `endif
                     // we can indicate counter == 8 8 bit read sucessfull
                     if(counter === 8) begin // add cycle 8 clk to rst
                        data_valid = 1; // to load new data for read
                        if (counter_enable == 1 || counter_enable == 2)  //for increment address of read
                           counter_enable = 2;
                        else
                           counter_enable = 1;//now u can increment address
                     end else begin
                        next_st = S3_DATA;
                        data_valid = 0;  // donot load new data
                     end
                  end else begin
                     bitdata[DATA_WIDTH-counter] = d;
                     if(counter === 8) begin // add cycle 8 clk to rst
                        data_reg = bitdata;
                      `ifndef SYNTHESIS
                         $display($time,"inside data data_reg = %h ",data_reg);
                      `endif
                        data_valid = 1;//send data out
                        next_st = S3_DATA;
                        if (counter_enable == 1 || counter_enable == 2)
                           counter_enable = 2;
                        else
                           counter_enable = 1;//now u can increment address
                     end else begin
                        if (data_valid === 1 && counter <= 2) begin  // to make we high for some time to write
                           data_valid = 1;
                        end else begin
                           data_valid = 0;
                           next_st = S3_DATA;
                        end
                     end
                  end
               end

   default    :begin
                  next_st = S0_IDLE;
               end
   endcase
end



////////////////////////////////////////////////////////  FSM LOGIC END HERE    //////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////// OUTPUT LOGIC START HERE //////////////////////////////////////////////////////////////////////

// write to q serial data out pin
// read block
always @ (posedge inv_clk or posedge rst) begin  // use another clk
   if (rst === 1 || s === 1) begin //condition bug
      position        <= 'd8;
      read_mem_page   <= 0;
      read_status_reg <= 0;
      s_hold_n        <= 1;
      lock_status     <= 0;
   end else if(hold_n === 1'b1) begin //condition bug
      s_hold_n <= 1;
      if((instruction === RID || instruction === RD) && address_valid ===1 ) begin
         if (page_lock_instruction === 1) begin
             lock_status <= 1;
         end else begin
             read_mem_page <= 1;
         end
         if (position !== 'b0) begin
            position <= position - 1;
         end else begin //pos == 0
            position <= 'd7;
         end
      end else if (instruction === RS) begin
         if (position !== 'b0) begin
            position <= position - 1;
         end else begin //pos == 0
            position <= 'd7;
         end
         read_status_reg <= 1;
      end else begin
         position <= 'd8;
         read_mem_page <= 0;
         read_status_reg <= 0;
      end
   end else if(hold_n === 1'b0) begin // what to do in this /condition bug
         position <= position;
         read_mem_page <= read_mem_page;
         read_status_reg <= read_status_reg;
         lock_status <= lock_status;
         s_hold_n <= 0;
//      end else begin
//      position <= 'd8;
//      read_mem_page <= 0;
//      read_status_reg <= 0;
//     s_hold_n <= 1;
//      lock_status <= 0;
   end
end

assign q = s_hold_n === 1 ? (read_mem_page ===1 ? read_data_in[position]:(read_status_reg===1 ? status_reg[position]:(lock_status === 1 ? page_lock_reg [position]:1'dz))):1'dz;

/////////////////////////////////////////////////////// OUTPUT LOGIC END HERE ////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////// OUTPUT FOR RAM LOGIC START HERE ////////////////////////////////////////////////////////////////////

always @(*)begin //(instruction,address_valid,data_valid,counter_enable,w_n,rst) begin
if(rst) begin
   status_reg = 0;
   address_out = 0;
   data_out = 0;
   page_lock = 0;
   page_lock_instruction = 0;
   page_lock_reg = 0;
end else begin
   case(instruction)

////////////////////////////////////////////////// WRITE ENABLE IN STATUS REGISTER ////////////////////////////////////////////////////////////////////

      WE : begin
//bug              if ((w_n === 1 && status_reg[7] === 0) || (w_n === 0 && status_reg[7] === 0) || (w_n === 1 && status_reg[7] === 1)) begin
                 if(status_reg[0] === 1'b0) begin //Write In Progress
                    status_reg[0] = 1'b1; //WIP
                    status_reg[1] = 1'b1; //WEL is set to 1
                   `ifndef SYNTHESIS
                      $display($time,"\t/////////////Write is enabled//////////////////////////");
                   `endif
                 end else begin
                   `ifndef SYNTHESIS
                      $display($time,"\t/////////////////////Internal Write is already in progress////////////////////");
                   `endif
                 end
               end
//bug              else begin
//bug                 `ifndef SYNTHESIS
//bug                     $display($time,"/////////////////WREN is disabled///////////////////////////");
//bug                 `endif
//bug              end
//bug           end


////////////////////////////////////////////////// WRITE DISABLE IN STATUS REGISTER ////////////////////////////////////////////////////////////////////

      WD : begin
//bug              if ((w_n === 1 && status_reg[7] === 0) || (w_n === 0 && status_reg[7] === 0) || (w_n === 1 && status_reg[7] === 1)) begin
                 if(status_reg[0] === 1'b0) begin  //Write In Progress
                    status_reg[0] = 1'b1; //WIP
                    status_reg[1] = 1'b0;     //WEL is set to 0
                    `ifndef SYNTHESIS
                       $display($time,"\t//////////////////////Write is disabled/////////////////////////////status register = %b",status_reg);
                    `endif
                 end else begin
                   `ifndef SYNTHESIS
                     $display($time,"\t/////////////////////Internal Write is already in progress/////////////////////////");
                   `endif
                 end
              end
//bug           end


////////////////////////////////////////////////// WRITE INTO STATUS REGISTER  /////////////////////////////////////////////////////////////////////////

      WS : begin
              if(data_valid === 1'b1) begin
                 if(status_reg[0] === 1 || status_reg[1] === 0) begin // WIP ==1
                    `ifndef SYNTHESIS
                       $display($time,"\t/////error: write is in progress,WRSR instruction is discarded//////////");
                    `endif
                    status_reg = status_reg;
                 end
                 else if(status_reg[7] === 1 && w_n === 0) begin
                  status_reg[0] = 1'b1; //WIP
                  `ifndef SYNTHESIS
                     $display($time,"\t///////////error: status register is hardware write protected,WRSR instruction is discarded///////");
                  `endif
                    status_reg = status_reg;
                 end
                 else begin
                    status_reg[0] = 1'b1; //WIP
                    status_reg[7] = data_reg[7]; //SRWD
                    status_reg[3] = data_reg[3]; //BP1
                    status_reg[2] = data_reg[2]; //BP0
                    `ifndef SYNTHESIS
                       $display($time,"\t////////////////info : status register is updated due to WRSR instruction////////////////// status reg=%b",status_reg);
                    `endif
                 end
              end
              else  status_reg[0] = 1'b0; //WIP
           end

///////////////////////////////////////////////////// READ FROM STATUS REGISTER  /////////////////////////////////////////////////////////////////////////

      RS : begin
              if(status_reg[0] == 0) begin
                 status_reg = status_reg;
              // add temp reg for read block
               `ifndef SYNTHESIS
                 $display($time,"\t////////////info: status register is read ststus_reg = %b///////////////",status_reg);
               `endif
              end else begin
                `ifndef SYNTHESIS
                   $display($time,"\t write in progress try again after some time");
                `endif
              end
           end


///////////////////////////////////////////////////// WRITE INTO MEMORY ///////////////////////////////////////////////////////////////////////////////////

      WR : begin
              if((address_valid === 1'b1) && (data_valid === 1'b1) && (address < PG*PG_S)) begin  
//bug           if((w_n === 1'b1 && status_reg[7]===0) || (w_n===1'b1 && status_reg[7]===1) || (w_n===1'b0 && status_reg[7]===0)) begin
//bug                   `ifndef SYNTHESIS
//bug                      $display($time,"/////passed the hadware and software modes////////////");
//bug                   `endif
                    if((status_reg[1] === 1) && (status_reg[0] === 0)) begin //WEL ==1 WIP = 0
                       status_reg[0] = 1'b1; //WIP
                       `ifndef SYNTHESIS
                          $display($time,"///////check the status register bits 3 and 2 = %b",status_reg);
                       `endif
                       case ({status_reg[3],status_reg[2]}) //BP1 and BP0
                       2'b00 :begin
				we = 1'b1;
				data_out = data_reg;
				if (counter_enable === 2) begin
                                    address_out = wrap(address_out);
		   		end else begin
	       				address_out = {address[23:16],address[15:8],address[7:0]};
	   			end
                              end
                       2'b01 :begin
                                if (counter_enable === 2) begin	//condition bug
                                    	address_out = wrap(address_out);
	   			end else begin
	      				address_out = address;
	   			end
	   			if (address_out[17:16] != 2'b11) begin // 16 and 17 bit not equal to 11  ///check this
		      		      we = 1'b1;
				      data_out = data_reg;
                                 end else begin
                                    `ifndef SYNTHESIS
				         $display($time," this location is read only memory address_out=%0b'b ",address_out);
				    `endif
				    address_out = 0;
				    we = 0;
				    data_out = 0;
	 			 end
                              end
                       2'b10 :begin
                                 if (counter_enable === 2) begin //condition bug
                                      address_out = wrap(address_out);
				 end else begin
				      address_out = {address[23:16],address[15:8],address[7:0]};
			 	 end
                                 if (address[17] === 0) begin // and else part and make we address and data zero
                                    we = 1'b1;
                                    data_out = data_reg;
                                 end else begin
				     `ifndef SYNTHESIS
				        $display($time," this location is read only memory address_out=%0b'b ",address_out);
                               	     `endif
				      address_out = 0;
				      we = 0;
				      data_out = 0;
				 end
                              end
                       default:begin
                             we = 0;
			     address_out = 0;
			     data_out = 0;
                             `ifndef SYNTHESIS
				       $display($time, "Whole memory is write protected, write operation is rejected");
                             `endif
                             end
                       endcase
                       `ifndef SYNTHESIS
                          $display($time,"\t//////////////////write operation is done//////////////// address_out=%d",address_out);
                       `endif
                    end else begin
                      `ifndef SYNTHESIS
                         $display($time, ">>>>>>>>>>>>>>>write is disabled<<<<<<<<<<<<<<<<");
                      `endif
		   end
//bug              end else begin
//bug                 status_reg[0] = 0;
//bug              end
		end else begin
                status_reg[0] = 1'b0; //WIP
                we = 0;
                `ifndef SYNTHESIS
                   $display($time, "**************address is out of range or data is not received or address is not received********************");
                `endif
		end
           end

///////////////////////////////////////////////////// READ FROM MEMORY ///////////// /////////////////////////////////////////////////////////////////////////
      RD : begin
              if(address_valid === 1) begin
//bug             if(address[10] === 0) begin  // address is valid for WID
//bug                 `ifndef SYNTHESIS
//bug               	   $display($time," address valid high and a10 is 0");
//bug                  `endif 
                    if(status_reg[0] == 0) begin //WEL ==1 and WIP = 0 //no need to check Write enable for read
                   //    status_reg[0] = 1'b1; //WIP
                       if (counter_enable === 1) begin
                          address_out = {6'd0,address[17:0]};
                       end else if (counter_enable === 2 && data_valid === 1 ) begin
                          address_out[17:0] = address_out[17:0] + 1; // this will work for page wrap too i guess around between 0 to 255
                          address_out = {6'd0,address_out[17:0]};
                       end else
                          address_out = address_out;
                    we = 0;
                    end else begin
                       `ifndef SYNTHESIS
                          $display($time,"/t <<<<<<<<<<<<<<<<<<<<<<<<WIP is ACTIVE 1>>>>>>>>>>>>>>>>>>>");
                       `endif
                    end
//bug                 end else begin
//bug                     `ifndef SYNTHESIS
//bug                       $display($time,"\t >>>>>>>>>>> A10 is not 0 >>>>>>>>>>  ");
//bug                     `endif
//bug                    we = 0;
//bug                 end
              end else begin
                  `ifndef SYNTHESIS
                     $display($time,"\t >>>>>>>>>>>>>> address valid is not 1 >>>>>>>>>>>>>>>>>>");
                  `endif
                 we = 0;
                 status_reg[0] = 1'b0; //WIP = 0
                 address_out = address_out;
              end
           end


///////////////////////////////////////////////////// WRITE INTO IDENTIFICATION PAGE  /////////////////////////////////////////////////////////////////////////

      WID: begin
              if((address_valid === 1) && (data_valid === 1)) begin
                 if(address[10] === 0) begin  // address is valid for WID
                    if(page_lock === 0 && status_reg[1] === 1 && status_reg[0] === 0) begin //WEL ==1 and WIP = 0
                       status_reg[0] = 1'b1; //WIP
                       if (counter_enable === 1) begin
                          address_out = {16'd0,address[7:0]};
                          data_out = data_reg;
                          we = 1;
                       end else begin //counter == 2
                          address_out[7:0] = address_out[7:0] + 1; // this will work for page wrap too i guess
                          address_out = {16'd0,address_out[7:0]};
                          data_out = data_reg;
                          we = 1;
                       end
                    end else begin
                       `ifndef SYNTHESIS
                          $display($time,"\t <<<<<<<<<<<<<<<<<<<<<<<<WEL pin is 1==%0d or page is lock %0d WIP is ACTIVE %0d==0>>>>>>>>>>>>>>>>>>>",status_reg[1],page_lock, status_reg[0]);
                       `endif
                    end
                 end else if (address[10]===1) begin
                    data_out = data_reg;
                    if (data_out[1]===1 && status_reg[0] === 0 && status_reg[3:2] !== 2'b11 ) begin
                       status_reg[0] = 1'b1; //WIP
                       page_lock = 1;
                       `ifndef SYNTHESIS
                           $display($time," identification page is locked");
                        `endif
                    end else begin
                       page_lock = page_lock;
                    end
                 end else begin
                     `ifndef SYNTHESIS
                        $display($time,"\t >>>>>>>>>>> A10 is not 0 >>>>>>>>>>  ");
                     `endif
                    we = 0;
                 end
              end else begin
                 `ifndef SYNTHESIS
                    $display($time,"\t >>>>>>>>>>>>>> data is not valid or address valid is not 1 >>>>>>>>>>>>>>>>>>");
                 `endif
                 we = 0;
                 status_reg[0] = 1'b0; //WIP = 0
                 address_out = address_out;
                 data_out = 0;// we can latch too but this will give half clk cycle to write into mem
              end
           end

///////////////////////////////////////////////////// READ FROM IDENTIFICATION PAGE  /////////////////////////////////////////////////////////////////////////

      RID: begin
              if(address_valid === 1) begin
                 if(address[10] === 0) begin  // address is valid for WID
                     `ifndef SYNTHESIS
                        $display($time," address valid high and a10 is 0");
                     `endif

                    if(status_reg[0] == 0) begin //WEL ==1 and WIP = 0
                   //    status_reg[0] = 1'b1; //WIP
                       if (counter_enable === 1) begin
                          address_out = {16'd0,address[7:0]};
                       end else if (counter_enable === 2 && data_valid === 1 ) begin
                          address_out[7:0] = address_out[7:0] + 1; // this will work for page wrap too i guess around between 0 to 255
                          address_out = {16'd0,address_out[7:0]};
                       end else
                          address_out = address_out;
                    we = 0;
                    end else begin
                       `ifndef SYNTHESIS
                          $display($time,"/t <<<<<<<<<<<<<<<<<<<<<<<< WIP is ACTIVE 1>>>>>>>>>>>>>>>>>>>");
                       `endif
                    end
                 end else if (address[10] === 1) begin
                     page_lock_reg = {7'b0,page_lock};
                     page_lock_instruction = 1;
                 end else begin
                    `ifndef SYNTHESIS
                       $display($time,"\t >>>>>>>>>>> A10 is not 0 >>>>>>>>>>  ");
                    `endif
                    we = 0;
                    page_lock_instruction = 0;
                 end
              end else begin
                  `ifndef SYNTHESIS
                     $display($time,"\t >>>>>>>>>>>>>> address valid is not 1 >>>>>>>>>>>>>>>>>>");
                  `endif
                 we = 0;
                 status_reg[0] = 1'b0; //WIP = 0
                 address_out = address_out;
              end
           end
   default:begin  // this is mostly for idle
              status_reg[0] = 0;
              we = 0;
              status_reg = status_reg;
              address_out = 0;
              data_out = 0;
              page_lock_instruction = 0;
              page_lock_reg = 0;

           end

   endcase
end
end


////////////////////////////////////////////////// OUTPUT FOR RAM LOGIC END HERE   ////////////////////////////////////////////////////////////////////

///////////////////////////////////////////  WRAP LOGIC FOR WRITE ADDRESS START HERE //////////////////////////////////////////////////////////////////
function [23:0] wrap( input [23:0]address_out);
begin
  integer a;
  // if(`M1Kb | `M2Kb | `M4Kb | `M8Kb | `M16Kb | `M32Kb | `M64Kb | `M128Kb | `M256Kb | `M512Kb | `M1Mb | `M2Mb) begin

      if((0 <= address_out) && (address_out < PG_S)) begin //logic for 1st page
         if (address_out  === (PG_S -1)) begin
            address_out = 0;
         end else begin
            address_out = address_out+1;
         end
         `ifndef SYNTHESIS
            $display($time," 1st page adress_out =%0d",address_out);
         `endif
      end else if(address_out == (PG * PG_S-1)) begin //wrap logic for last page
          address_out = (PG - 1) * PG_S;
           `ifndef SYNTHESIS
              $display($time," last page adress_out =%0d",address_out);
           `endif
      end else  begin
         for( a = 1; a <= (PG - 1) ; a = a + 1) begin  //wrap logic for pages except 1st and last page
            if((a * PG_S  <= address_out) && (address_out< ((a + 1) * PG_S))) begin
               if(address_out == ((a+1) * PG_S)-1) begin //wrap logic when address is equal to end of the page
                  address_out = a * PG_S;
                   `ifndef SYNTHESIS
                      $display($time," inbetween page = lastaddress  adress_out =%0d",address_out);
                   `endif
               end else begin
                  address_out = address_out+1;
               end
                `ifndef SYNTHESIS
                   $display($time," inside 1st if of forloop address_out = %0d",address_out);
                `endif
            end
          //  $display($time," inside for loop address_out = %0d",address_out);
         end
      end
       `ifndef SYNTHESIS
           $display($time," end else page counter_enable =1 adress_out =%0d",address_out);
           $display($time, "END of WRAP logic");
       `endif
     //return address_out;
     wrap = address_out;
end
endfunction: wrap

///////////////////////////////////////////  WRAP LOGIC FOR WRITE ADDRESS END HERE  /////////////////////////////////////////////////////////////////


endmodule:spi_control_logic

