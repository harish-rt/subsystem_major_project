`include "M95XXX_Parameters.v"
`include "M95XXX_Macro_mux.v"
// designing spi control logic block
// will cover hold,poweron,select condition

module spi_cl #(parameter add_width_in_bytes= 3)
              (input c,      // serial clock
              input d,      // serial data in
              input s,      // chip select active low
              input w,      // write protect active low
              input hold,   // hold active low
              input vcc,     // supply voltage
              output reg q, // serial data output
             //ports to communicate with ieu
              input instr_valid, // valid instruction from ieu
              input data_in_valid,
              input ready_fr_output,
              input [7:0] data_in,
              output rst,
              output reg counter_enable,// for increment addres for next byte of data
              output reg data_out_valid,
              output reg ready_fr_input,
              output reg [7:0] data_out
              );

  M95XXX_Macro_mux M95XXX_SIM();
reg q_temp;  //to add delay in output
reg power;      // we can use this as reset if == 0
reg power_mode; // 1 means active mode 0 means standby mode
reg pnr;        // 1 means active 0 means inactive
reg hold_a;     // 0 means hold is active 1 means inactive
reg reset_h;    //rst gen in hold is active
reg data_load;
reg [2:0] pos;  // position of temp reg to Q pin
reg [7:0] temp; // load data from ieu into temp
reg r_w; //0 write 1 read

//internal sig for write blk
  parameter size=3;
  parameter N=8;
  parameter s0_idle = 3'b000,s1_instr = 3'b001,s2_address = 3'b010,s3_data=3'b100 ;
//reg [size-1:0] PS;//present state
  reg [size-1:0] state;//next state
  reg [N-1:0] bitdata; //using as 8-bit shift register
  integer i=0;
  integer count=add_width_in_bytes;

  reg decode_inst;//will use to only decode instruction not data or addres comming from input

assign rst = pnr | reset_h;

// how to check device reset condition
always @ (vcc) begin   // in power on s should follow vcc
   if (vcc === 1'b1 ) begin // s is to make proper power on condition && s === 1'b1
      power = 1'b1;
      $display ($time,"devide is powered on");
   end else begin
      power = 1'b0;
      $display ($time," device is off or s is not high when devide is powered on");
   end
end



// block to check mode of operation
always @ (s or power) begin
   case ({power,s})
   2'b11  :begin
             power_mode = 1'b0; //stand by mode
             if (pnr === 1)
                pnr  = 1'b0;
             else
                pnr = 1;
           end
   2'b10  :begin
             power_mode = 1'b1;// device is selected active mode
             pnr = 1'b0;
           end
   default:begin // we can make power_mode = x;
              $display($time,"default case of mode block"); // device os off so reset system i guess
           end
   endcase
end


// hold condition block
always @ (negedge c ) begin  // neg of clock and hold pin  or negedge hold
   if (c === 1'b0 && hold === 1'b0 && s == 1'b0) begin //c hold and select all should be low
      hold_a = 1'b0; // hold active
      reset_h = 1'b0;
   end else if (c === 1'b0 && hold === 1'b0 && s == 1'b1) begin
      hold_a = 1'b1; // hold inactive
      reset_h = 1'b1;
   end else begin
      hold_a = 1'b1;
      reset_h = 1'b0;
   end
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //reg [N-1:0] data_out;
 // reg instr_valid;
 // reg data_out_valid;
  //wire ready_fr_output;

// power 1 on || 0 off
// power_mode == 0 power is on && chip is not selected (standby mode) || power_mode==1 power is on chip is selected (active mode)

  //write_block
  always @(posedge c )begin //or posedge rst
  if(power_mode ===0 || rst === 1 )begin
      bitdata=8'b0;
      state=s0_idle;
      i = 0;// added
      decode_inst = 0;
      data_out = 0;
      count  = add_width_in_bytes;
      counter_enable = 0;
      r_w  = 0;
    end
    else begin
        if (state === s0_idle) begin
          if (r_w === 0 && ( d === 1'b0 || d === 1'b1))
            state = s1_instr;
          else
            state = s0_idle;
        end else begin
          state = state;
        end
    case(state)
        s0_idle: begin
          if( hold_a === 1 && r_w === 0 && ( d === 1'b0 || d === 1'b1))
            state=s1_instr;
          else
            state=s0_idle;
        end
        s1_instr:begin
          if(hold_a === 1  && pos === 3'd7)begin // pos is added  && pos == 3'd7
             bitdata[N-1-i]=d;//loading shift register
              i=i+1;
              if(i==N)begin
                ready(bitdata); //
                state=s2_address;
                decode_inst = 1;
                i = 0; // this was added
              end
              else begin
                not_ready;
                state=s1_instr;
                decode_inst = 0;
            end
          end
          else begin
            state=s1_instr;
          end
        end

        s2_address:begin
          decode_inst = 0;
          if(hold_a === 1 && pos === 3'd7)begin //pos is added
            if(instr_valid==1 )begin
              bitdata[N-1-i]=d;
              i=i+1;
              if(i==N)begin
                count=count-1; // add parameter for this
                ready(bitdata);
                i=0;
              end
              else begin
                not_ready;
              end
              if(count === 0)begin //use r_w pin here
                if (r_w == 1)
                  state=s0_idle;
                else
                  state=s3_data;
              end
              else begin
                state=s2_address;
              end
            end
            else begin
              state=s1_instr;
            end
          end
          else begin
            state=s2_address;
          end
        end



        s3_data:begin
         decode_inst = 0;
          if(hold_a===1 && pos === 3'd7)begin //pos is added
              if (d === 1'bx || d === 1'bz) begin
              $display($time,"invalid data= %0b",d);
                 state = s0_idle;
              end else begin
                 bitdata[7-i]=d;
                 i=i+1;
                 if(i==8)begin // add cycle 8 clk to rst
                    ready(bitdata);
                    i=0;
                    state=s3_data;
                    counter_enable = 1;//now u can increment address
                 end else begin
                    not_ready;
                    state=s3_data;
                 end
              end
          end
        end
        default:
          begin
            state=s0_idle;
          end
        endcase
    end
  end

 /* always @ (ready_fr_output) begin

  end*/

  function ready( input [7:0]bitdata);
   begin
  /*  if(ready_fr_output==1)begin*///not checking ready_fr_input because they have one clk (c) time to load data then it will automatically gets discard
     data_out_valid = 1'b1; //using nba will create problem in switching state
     data_out = bitdata;
   /* end
    else begin
      $display("IEB is not ready to take the byte");
      end*/
   end
  endfunction


   function not_ready;
   begin
     data_out_valid = 0;
     data_out = data_out;
   end
   endfunction

   parameter WREN=8'd6,
            WRDI=8'd4,
            READ=8'd3,
            WRITE=8'd2,
            WRSR=8'd1,
            RDSR=8'd5,
            RDID=8'd131,
            WRID=8'd130;


  always @(decode_inst)begin
    if (decode_inst === 1'b1 )begin
        if(data_out === WREN || data_out ===WRDI)begin
          state=s1_instr;
        //  $display($time,"display wren,wrdi");
        end else if(data_out === READ || data_out ===RDID) begin
          state=s2_address;
          r_w = 1;//data read
         //  $display($time,"display read,rdid");
        end else if (data_out === WRITE || data_out === WRID) begin
          state=s2_address;
          r_w = 0;//data write
         //  $display($time,"display write,wrid");
        end else if (data_out === RDSR) begin
          state=s0_idle;
          r_w = 1;//read
         //  $display($time,"display rdsr");
        end else if(data_out === WRSR)begin
        //  $display($time,"display wren,wrsr");
          state=s3_data;
        end
        else begin
          state=s0_idle;
          $display($time,"display wren else dataout =%0d",data_out);
        end
    end else begin
      state=state;
      $display($time,"display valid else");
    end
  end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



// write to q serial data out pin
// read block
always @ (negedge c) begin
   if(rst === 1'b0 && data_load === 1'b1 && power_mode === 1'b1 && hold_a === 1'b1) begin  //hold is inactive power_mode is active and data is loaded
      if (pos !== 3'b0) begin
        #(M95XXX_SIM.M95XXX_Macro_mux.tCLQV);//clock low to Output Valid
        q_temp = temp[pos];
         pos = pos - 1;
      end else begin //pos == 0
         #(M95XXX_SIM.M95XXX_Macro_mux.tCLQV);//clock low to Output Valid
         q_temp   = temp[pos];
         pos = 3'd7;
      end
   end else if(rst === 1'b0 && data_load === 1'b1 && power_mode === 1'b1 && hold_a === 1'b0) begin // what to do in this
      pos = pos;
      q_temp = 1'bz;
   end else begin
      pos = 3'd7;
      #(M95XXX_SIM.M95XXX_Macro_mux.tSHQZ);
      q_temp = 1'bz;
   end
end

/// adding delays in output pin
always @(negedge hold_a) begin
  q = #(M95XXX_SIM.M95XXX_Macro_mux.tHLQZ) 1'bz; // when hold is active
end

always @(posedge hold_a) begin
  q = #(M95XXX_SIM.M95XXX_Macro_mux.tHHQV) q_temp;//when hold is disable
end

always @(q_temp or power_mode) begin
 if (hold_a === 1'b1)
 q = q_temp; //not here because this delay is related to clk
end

always @(negedge power_mode) begin
 #(M95XXX_SIM.M95XXX_Macro_mux.tSHQZ); // when device is deselected delay
 q = 1'bz;
 q_temp = 1'bz;
end

// taking data from IEU block for writing on Q (data out pin)
always @(rst or data_in_valid or pos) begin// use rst here
  if (rst === 1'b1) begin
     ready_fr_input = 1'b1;
     data_load = 1'b0;
     temp = 0;
  end else begin
     if(data_in_valid === 1'b1 && pos === 3'd7) begin
        temp = data_in;
        data_load = 1'b1;
        ready_fr_input = 1'b0;
// ready fr_input
     end else if (data_in_valid === 1'b0 && pos === 3'd7) begin
        data_load = 1'b0;
        ready_fr_input = 1'b1;
        temp = 0;
     end else begin
        temp = temp;
     end
  end
end


endmodule:spi_cl
