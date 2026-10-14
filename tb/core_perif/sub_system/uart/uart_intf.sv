interface uart_if (input logic clk_i, input logic rst_n_i);

    logic rx;      // Serial data input (to DUT)
    logic tx;      // Serial data output (from DUT)

    logic cts_n;   // Clear to Send (Active low)
    logic rts_n;   // Request to Send (Active low)

    clocking drv_cb @(posedge clk_i);
        default input #1step output #1ns;
        output rx;
        output cts_n;
        input  tx;
        input  rts_n;
    endclocking : drv_cb

    clocking mon_cb @(posedge clk_i);
        default input #1step output #1ns;
        input rx;
        input tx;
        input cts_n;
        input rts_n;
    endclocking : mon_cb

    modport DRV (clocking drv_cb, input clk_i, input rst_n_i);
    modport MON (clocking mon_cb, input clk_i, input rst_n_i);

endinterface : uart_if
