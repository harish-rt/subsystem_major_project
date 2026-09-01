// default param config to AXI4_lite
interface axi4_lite_intf();
   parameter ADDR_WIDTH = 32;
   parameter DATA_WIDTH = 32;
    
   logic ACLK;
   logic ARESETn;

   // Write address channel signals (declared as wire to allow multi-module port connections)
   wire [ADDR_WIDTH-1:0]       AWADDR;
   wire                        AWREADY;
   wire                        AWVALID;
   wire [2:0]                  AWPROT;

   // Write data channel signals
   wire [DATA_WIDTH-1:0]       WDATA;
   wire [(DATA_WIDTH/8)-1:0]   WSTRB;
   wire                        WREADY;
   wire                        WVALID;

   // Write response channel signals
   wire [1:0]                  BRESP;
   wire                        BREADY;
   wire                        BVALID;

   // Read address channel signals
   wire [ADDR_WIDTH-1:0]       ARADDR;
   wire                        ARREADY;
   wire                        ARVALID;
   wire [2:0]                  ARPROT;
 
   // Read data channel signals
   wire [DATA_WIDTH-1:0]       RDATA;
   wire [1:0]                  RRESP;
   wire                        RREADY;
   wire                        RVALID;

   // -------------------------------------------------------------------------
   // Clocking Blocks (Verification / TB)
   // -------------------------------------------------------------------------
   clocking axil_drv_cb @(posedge ACLK);
      default input #1ns output #1ns;

      output ARADDR, ARPROT, ARVALID;
      output AWADDR, AWPROT, AWVALID;
      output WDATA,  WSTRB,  WVALID;
      output BREADY, RREADY;

      input  ARESETn;
      input  ARREADY;
      input  AWREADY;
      input  WREADY;
      input  BRESP,  BVALID;
      input  RDATA,  RRESP,  RVALID;
   endclocking

   clocking axil_mon_cb @(posedge ACLK);
      default input #1ns output #1ns;

      input  ARESETn;
      input  ARADDR, ARPROT, ARVALID, ARREADY;
      input  AWADDR, AWPROT, AWVALID, AWREADY;
      input  WDATA,  WSTRB,  WVALID,  WREADY;
      input  BRESP,  BVALID, BREADY;
      input  RDATA,  RRESP,  RVALID,  RREADY;
   endclocking

   // -------------------------------------------------------------------------
   // Modports
   // -------------------------------------------------------------------------
   // Testbench Modports
   modport DRIVER_MOD  (clocking axil_drv_cb, input ACLK, input ARESETn);
   modport MONITOR_MOD (clocking axil_mon_cb, input ACLK, input ARESETn);

   // RTL Slave Modport (e.g. Memory Unit, Peripherals)
   modport slave (
      input  ACLK, ARESETn,
      input  AWADDR, AWPROT, AWVALID,
      output AWREADY,
      input  WDATA, WSTRB, WVALID,
      output WREADY,
      output BRESP, BVALID,
      input  BREADY,
      input  ARADDR, ARPROT, ARVALID,
      output ARREADY,
      output RDATA, RRESP, RVALID,
      input  RREADY
   );

   // RTL Master Modport
   modport master (
      input  ACLK, ARESETn,
      output AWADDR, AWPROT, AWVALID,
      input  AWREADY,
      output WDATA, WSTRB, WVALID,
      input  WREADY,
      input  BRESP, BVALID,
      output BREADY,
      output ARADDR, ARPROT, ARVALID,
      input  ARREADY,
      input  RDATA, RRESP, RVALID,
      output RREADY
   );

endinterface

/*
//default param config to AXI4_lite
interface axi4_lite_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
    
   logic ACLK;
   logic ARESETn;
   //Write address channel signals
   logic [ADDR_WIDTH-1:0]	AWADDR	;
   logic  			AWREADY	;
   logic  			AWVALID	;
   logic [2:0] 		AWPROT	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic [(DATA_WIDTH/8)-1:0] 	WSTRB	;
   logic  			WREADY	;
   logic  			WVALID	;

   //Write response channel signals
   logic [1:0]		BRESP	;
   logic			BREADY	;
   logic 			BVALID	;

   //Read address channel signals
   logic [ADDR_WIDTH-1:0]	ARADDR	;
   logic 			ARREADY	;
   logic			ARVALID	;
   logic [2:0] 		ARPROT	;
 
   //Read data channel signals
   logic [DATA_WIDTH-1:0]	RDATA	;
   logic [1:0]		RRESP	;
   logic 			RREADY  ;
   logic 			RVALID	;

   clocking axil_drv_cb @(posedge ACLK);
      default input #1ns output #1ns;

      output ARADDR, ARPROT, ARVALID;
      output AWADDR, AWPROT, AWVALID;
      output WDATA,  WSTRB,  WVALID;
      output BREADY, RREADY;

      input ARESETn;
      input  ARREADY;
      input  AWREADY;
      input  WREADY;
      input  BRESP,  BVALID;
      input  RDATA,  RRESP,  RVALID;
   endclocking


   clocking axil_mon_cb @(posedge ACLK);
      default input #1ns output #1ns;

      input ARESETn;
      input ARADDR, ARPROT, ARVALID, ARREADY;
      input AWADDR, AWPROT, AWVALID, AWREADY;
      input WDATA,  WSTRB,  WVALID,  WREADY;
      input BRESP,  BVALID, BREADY;
      input RDATA,  RRESP,  RVALID,  RREADY;
   endclocking

   
   modport DRIVER_MOD  (clocking axil_drv_cb, input ACLK, input ARESETn);
   modport MONITOR_MOD (clocking axil_mon_cb, input ACLK, input ARESETn);

endinterface
/*
//default param config to AXI4_lite
interface axi4_lite_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;

   //Global signals
   logic 			ACLK	;
   logic 			ARESETn	;

   //Read address channel signals
   logic [ADDR_WIDTH-1:0]	ARADDR	;
   logic [2:0] 			ARPROT	;
   logic 			ARREADY	;
   logic			ARVALID	;
 
   //Write address channel signals
   logic [ADDR_WIDTH-1:0]	AWADDR	;
   logic [2:0] 			AWPROT	;
   logic  			AWREADY	;
   logic  			AWVALID	;

   //Write response channel signals
   logic			BREADY	;
   logic [1:0]			BRESP	;
   logic 			BVALID	;

   //Read data channel signals
   logic [DATA_WIDTH-1:0]	RDATA	;
   logic 			RREADY ;
   logic [1:0]			RRESP	;
   logic 			RVALID	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic  			WREADY	;
   logic [DATA_WIDTH>>3-1:0] 	WSTRB	;
   logic  			WVALID	;
endinterface
*/
