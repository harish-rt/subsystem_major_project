interface timer(input clk_i,input rst_i);

    // Outputs
    logic           intr_o;

    clocking timer_drv_cb@(posedge clk_i);
        default input #1 output #0;

        input          intr_o;
    endclocking

    clocking timer_mon_cb@(posedge clk_i);
        default input #1 output #0;

        input          intr_o;
    endclocking

endinterface
