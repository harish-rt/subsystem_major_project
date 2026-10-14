interface uart_Pslave_intf(input clk_i,input rst_i);
    logic          cfg_awvalid_i;  
    logic  [31:0]  cfg_awaddr_i; 
    logic          cfg_wvalid_i;
    logic  [31:0]  cfg_wdata_i;
    logic  [3:0]   cfg_wstrb_i;
    logic          cfg_bready_i;
    logic          cfg_arvalid_i;
    logic  [31:0]  cfg_araddr_i;
    logic          cfg_rready_i;

    logic          cfg_awready_o;
    logic          cfg_wready_o;
    logic          cfg_bvalid_o;
    logic  [1:0]   cfg_bresp_o;
    logic          cfg_arready_o;
    logic          cfg_rvalid_o;
    logic  [31:0]  cfg_rdata_o;
    logic  [1:0]   cfg_rresp_o;

clocking pslv_mon_cb@(posedge clk_i);
    default input #1step output #0;
    input cfg_awvalid_i; 
    input cfg_awaddr_i; 
    input cfg_wvalid_i;
    input cfg_wdata_i;
    input cfg_wstrb_i;
    input cfg_bready_i;
    input cfg_arvalid_i;
    input cfg_araddr_i;
    input cfg_rready_i;

    input cfg_awready_o; 
    input cfg_wready_o; 
    input cfg_bvalid_o;
    input cfg_bresp_o;
    input cfg_arready_o;
    input cfg_rvalid_o;
    input cfg_rdata_o;
    input cfg_rresp_o;
endclocking

modport pslv_mon_mod(clocking pslv_mon_cb, input rst_i);
endinterface
