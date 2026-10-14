interface gpio_slave_if(input logic clk, rst_n);
    logic        req_valid;
    logic        ack;
    logic [31:0] req_data;
    logic [31:0] gpio_in;
    logic [31:0] gpio_out;
    logic [31:0] gpio_oe;
endinterface
