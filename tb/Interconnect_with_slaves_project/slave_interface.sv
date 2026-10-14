interface slave_interface(input clk_i, input rst_i);
   
   //------------------WRITE ADDRESS CHANNEL SIGNALS--------------------//
   wire [31:0] awaddr;
   wire        awvalid;
    wire       awready;

   //-------------------WRITE DATA CHANNEL SIGNALS---------------------//
   wire [31:0] wdata;
   wire        wvalid;
   wire [3:0]  wstrb;
     wire      wready;

   //-------------------WRITE RESPONSE CHANNEL SIGNALS------------------//
   wire        bready;
     wire      bvalid;
   wire [1:0]  bresp;

   //------------------READ ADDRESS CHANNEL SIGNALS---------------------//
   wire        arvalid;
   wire [31:0] araddr;
   wire        arready;

   //------------------READ DATA CHANNEL SIGNALS-----------------------//
   wire        rready;
   wire      rvalid;
   wire [31:0] rdata;
   wire [1:0]  rresp;

   clocking si_drv_cb @(posedge clk_i);
      default input #1step output #0;
      //input         clk_i;
      //output        rst_i;
      input   awvalid;
      output  awready;
      input   awaddr;
      input   wvalid;
      output  wready;
      input   wdata;
      input   wstrb;
      input   bready;
      output  bvalid;
      output  bresp;
      input   arvalid;
      output  arready;
      input   araddr;
      output  rvalid;
      input   rready;
      output  rdata;
      output  rresp;
       
   endclocking

   clocking si_mon_cb @(posedge clk_i);
      default input #1step output #0;
      input awvalid;
      input awready;
      input awaddr;
      input wvalid;
      input wready;
      input wdata;
      input wstrb;
      input bready;
      input bvalid;
      input bresp;
      input arvalid;
      input arready;
      input araddr;
      input rvalid;
      input rready;
      input rdata;
      input rresp;

   endclocking

   modport si_drv_mod (clocking si_drv_cb, input rst_i);
   modport si_mon_mod (clocking si_mon_cb, input rst_i);


endinterface
