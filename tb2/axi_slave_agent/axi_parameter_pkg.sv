package axi_parameter_pkg;
    parameter ID_WIDTH = 0;
    parameter ADDR_WIDTH = 32;
    parameter BURST_LENGTH = 0;
    parameter BURST_SIZE = 0;
    parameter DATA_WIDTH = 32;
    parameter STROBE_WIDTH = 4;
    parameter REGION_WIDTH = 0;
    parameter CACHE_WIDTH = 0;
    parameter PROT_WIDTH = 0;
    parameter QOS_WIDTH = 0;
    parameter LEN_WIDTH = 0;
    parameter BURST_WIDTH = 0;
    parameter SIZE_WIDTH = 0;
    parameter RESPONSE_WIDTH = 2;

/*property valid_handshake(logic clk,reset_n,valid,ready);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> valid;
endproperty
property signal_stable(logic clk,reset_n,valid,ready, logic [32:0] signal);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> $stable(signal);
endproperty */

endpackage
