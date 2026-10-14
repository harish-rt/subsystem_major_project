interface uart_Aslave_intf(input clk_i,input rst_i);

   logic rx_i;
   logic tx_o;
   logic intr_o;

clocking aslv_drv_cb@(posedge clk_i);
   default input #1step output #0;
   input tx_o;
   input intr_o;
   output rx_i;
endclocking

clocking aslv_mon_cb@(posedge clk_i);
   default input #1step output #0;
   input tx_o;
   input intr_o;
   input rx_i;
endclocking

modport aslv_mon_mod(clocking aslv_mon_cb, input rst_i);
endinterface
