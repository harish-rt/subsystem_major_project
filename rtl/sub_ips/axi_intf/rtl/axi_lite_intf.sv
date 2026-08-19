//default param config to AXI4_lite
interface axi4_lite_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
    
   logic ACLK;
   logic ARESETn;
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
   logic 			RREADY  ;
   logic [1:0]			RRESP	;
   logic 			RVALID	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic  			WREADY	;
   logic [(DATA_WIDTH/8)-1:0] 	WSTRB	;
   logic  			WVALID	;


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
