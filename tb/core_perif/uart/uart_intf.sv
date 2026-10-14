interface uart_if (input logic clk_i, input logic rst_n_i);

    logic rx;      // Serial data input (to DUT)
    logic tx;      // Serial data output (from DUT)

    clocking drv_cb @(posedge clk_i);
        default input #1step output #1ns;
        output rx;
        input  tx;
    endclocking : drv_cb

    clocking mon_cb @(posedge clk_i);
        default input #1step output #1ns;
        input rx;
        input tx;
    endclocking : mon_cb

    modport DRV (clocking drv_cb, input clk_i, input rst_n_i);
    modport MON (clocking mon_cb, input clk_i, input rst_n_i);

endinterface : uart_if
