`define DATA_WIDTH     32
`define ADDR_WIDTH     32
`define RESPONSE_WIDTH 2

interface cpu_intf (input aclk, areset_n);
   import  uvm_pkg :: *;   
   // ---------------- Write Channel ----------------
   logic [`ADDR_WIDTH-1 : 0] awaddr;
   logic                     awvalid;
   logic                     awready;
   logic [`DATA_WIDTH-1 : 0] wdata;
   logic [(`DATA_WIDTH/8)-1:0] wstrobe;  
   logic                     wvalid;
   logic                     wready;
   logic [`RESPONSE_WIDTH-1 : 0] bresp;
   logic                         bvalid;
   logic                         bready;
   // ---------------- Read Channel -----------------
   logic [`ADDR_WIDTH-1 : 0] araddr;
   logic                     arvalid;
   logic                     arready;
   logic [`DATA_WIDTH-1 : 0] rdata;
   logic [`RESPONSE_WIDTH-1:0] rresp;
   logic                        rvalid;
   logic                        rready;

   // ----------------  ClockingBlocks ----------------------
   clocking cpu_drv_cb @(posedge aclk);
      default input #1 output #0;
      output awaddr, awvalid;
      input  awready;
      output wdata, wstrobe, wvalid;
      input  wready;
      input  bresp, bvalid;
      output bready;
      output araddr, arvalid;
      input  arready;
      input  rdata, rresp, rvalid;
      output rready;
   endclocking: cpu_drv_cb

   clocking cpu_mon_cb @(posedge aclk);
      default input #1 output #0;
      input awaddr, awvalid, awready;
      input wdata, wstrobe, wvalid, wready;
      input bresp, bvalid, bready;
      input araddr, arvalid, arready;
      input rdata, rresp, rvalid, rready;
   endclocking: cpu_mon_cb

   // ---------------- Modports -----------------------------
   modport DRV_MOD_cpu (clocking cpu_drv_cb, input areset_n);
   modport MON_MOD_cpu (clocking cpu_mon_cb, input areset_n);

endinterface

