interface irq_ctrl(input clk_i,rst_i);
    logic           interrupt0_i;
    logic           interrupt1_i;
    logic           interrupt2_i;
    logic           interrupt3_i;
    logic           interrupt4_i;
    logic           interrupt5_i;
    logic           interrupt6_i;
    logic           intr_o;

    clocking irq_drv_cb@(posedge clk_i);
        default input #1 output #0;

        output          interrupt0_i;
        output          interrupt1_i;
        output          interrupt2_i;
        output          interrupt3_i;
        output          interrupt4_i;
        output          interrupt5_i;
        output          interrupt6_i;
        input           intr_o;
    endclocking

    clocking irq_mon_cb@(posedge clk_i);
        default input #1 output #0;

        input           interrupt0_i;
        input           interrupt1_i;
        input           interrupt2_i;
        input           interrupt3_i;
        input           interrupt4_i;
        input           interrupt5_i;
        input           interrupt6_i;
        input           intr_o;
    endclocking

endinterface
