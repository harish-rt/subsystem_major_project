interface master_interface(input clk_i, input rst_i);
   
   //------------------WRITE ADDRESS CHANNEL SIGNALS--------------------//
   wire [31:0] awaddr;
   wire        awvalid;
   wire        awready;

   //-------------------WRITE DATA CHANNEL SIGNALS---------------------//
   wire [31:0] wdata;
   wire        wvalid;
   wire [3:0]  wstrb;
   wire        wready;

   //-------------------WRITE RESPONSE CHANNEL SIGNALS------------------//
   wire        bready;
   wire        bvalid;
   wire [1:0]  bresp;

   //------------------READ ADDRESS CHANNEL SIGNALS---------------------//
   wire        arvalid;
   wire [31:0] araddr;
   wire        arready;

   //------------------READ DATA CHANNEL SIGNALS-----------------------//
   wire        rready;
   wire        rvalid;
   wire [31:0] rdata;
   wire [1:0]  rresp;



   clocking mi_drv_cb @(posedge clk_i);
      default input #1step output #0;
      //input         clk_i;
      //output        rst_i;
      output awvalid;
      input  awready;
      output awaddr;
      output wvalid;
      input  wready;
      output wdata;
      output wstrb;
      output bready;
      input  bvalid;
      input  bresp;
      output arvalid;
      input  arready;
      output araddr;
      input  rvalid;
      output rready;
      input  rdata;
      input  rresp;
   endclocking

   clocking mi_mon_cb @(posedge clk_i);
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

   modport mi_drv_mod (clocking mi_drv_cb, input rst_i);
   modport mi_mon_mod (clocking mi_mon_cb, input rst_i);


endinterface
