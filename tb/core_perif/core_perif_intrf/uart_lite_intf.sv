interface uart_lite(input clk_i,input rst_i);
    // Inputs
    logic           rx_i;

    // Outputs
    logic           tx_o;
    logic           intr_o;

    clocking uart_drv_cb@(posedge clk_i);
        default input #1 output #0;

        input           tx_o;
        output          rx_i;
        input           intr_o;
    endclocking

    clocking uart_mon_cb@(posedge clk_i);
        default input #1 output #0;

        input           tx_o;
        input           rx_i;
        input           intr_o;
    endclocking
endinterface
