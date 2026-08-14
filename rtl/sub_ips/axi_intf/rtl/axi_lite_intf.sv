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
