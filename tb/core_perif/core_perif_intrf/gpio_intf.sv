interface gpio_intf(input clk_i,input rst_i);
    // Inputs
    logic  [31:0]   gpio_input_i;

    // Outputs
    logic [31:0]    gpio_output_o;
    logic [31:0]    gpio_output_enable_o;
    logic           intr_o;

    clocking gpio_drv_cb@(posedge clk_i);
        default input #1 output #0;

        output[31:0]    gpio_input_i;
        input [31:0]    gpio_output_o;
        input [31:0]    gpio_output_enable_o;
        input           intr_o;
    endclocking

    clocking gpio_mon_cb@(posedge clk_i);
        default input #1 output #0;

        input [31:0]    gpio_input_i;
        input [31:0]    gpio_output_o;
        input [31:0]    gpio_output_enable_o;
        input           intr_o;
    endclocking
endinterface
