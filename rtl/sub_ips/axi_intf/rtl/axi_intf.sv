//default param config to AXI
/*interface axi_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
   parameter ID_WIDTH 		= 4	;
   parameter LENGTH_WIDTH 	= 4	;
   parameter LOCK_WIDTH 	= 2	;
   parameter USER_SIGNAL_WIDTH 	= 8	;

   //Global signals
   logic			ACLK	;
   logic			ARESETn	;

   //Read address channel signals
   logic [ADDR_WIDTH-1:0]	ARADDR	;
   logic [1:0]  		ARBURST	;
   logic [3:0] 			ARCACHE	;
   logic [ID_WIDTH-1:0]		ARID	;
   logic [LENGTH_WIDTH-1:0]	ARLEN	;
   logic [LOCK_WIDTH-1:0]	ARLOCK	;
   logic [2:0] 			ARPROT	;
   logic [3:0] 			ARQOS	;
   logic 			ARREADY	;
   logic [3:0] 			ARREGION;
   logic [2:0]			ARSIZE	;
   logic			ARVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]ARUSER	;
   
   //Write address channel signals
   logic [ADDR_WIDTH-1:0]	AWADDR	;
   logic [1:0]  		AWBURST	;
   logic [3:0] 			AWCACHE	;
   logic [ID_WIDTH-1:0]		AWID	;
   logic [LENGTH_WIDTH-1:0]	AWLEN	;
   logic [LOCK_WIDTH-1:0]	AWLOCK	;
   logic [2:0] 			AWPROT	;
   logic [3:0] 			AWQOS	;
   logic  			AWREADY	;
   logic [3:0] 			AWREGION;
   logic [2:0]			AWSIZE	;
   logic  			AWVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]AWUSER	;
  
   //Write response channel signals
   logic [ID_WIDTH-1:0]		BID	;
   logic			BREADY	;
   logic [1:0]			BRESP	;
   logic 			BVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]BUSER	;
   
   //Read data channel signals
   logic [DATA_WIDTH-1:0]	RDATA	;
   logic [ID_WIDTH-1:0]		RID	;
   logic 			RLAST	;
   logic 			RREADY	;
   logic [1:0]			RRESP	;
   logic 			RVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]RUSER	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic [ID_WIDTH-1:0]		WID	;
   logic 			WLAST	;
   logic  			WREADY	;
   logic [DATA_WIDTH>>3-1:0] 	WSTRB	;
   logic  			WVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]WUSER	;
endinterface

//default param config to AXI3
interface axi3_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
   parameter ID_WIDTH 		= 4	;

   //Global signals
   logic 			ACLK	;
   logic 			ARESETn	;

   //Read address channel signals
   logic [ADDR_WIDTH-1:0]	ARADDR	;
   logic [1:0]  		ARBURST	;
   logic [3:0] 			ARCACHE	;
   logic [ID_WIDTH-1:0]		ARID	;
   logic [3:0]			ARLEN	;
   logic [1:0]			ARLOCK	;
   logic [2:0] 			ARPROT	;
   logic 			ARREADY	;
   logic [2:0]			ARSIZE	;
   logic			ARVALID	;
   
   //Write address channel signals
   logic [ADDR_WIDTH-1:0]	AWADDR	;
   logic [1:0]  		AWBURST	;
   logic [3:0] 			AWCACHE	;
   logic [ID_WIDTH-1:0]		AWID	;
   logic [3:0]			AWLEN	;
   logic [1:0]			AWLOCK	;
   logic [2:0] 			AWPROT	;
   logic  			AWREADY	;
   logic [2:0]			AWSIZE	;
   logic  			AWVALID	;

   //Write response channel signals
   logic [ID_WIDTH-1:0]		BID	;
   logic			BREADY	;
   logic [1:0]			BRESP	;
   logic 			BVALID	;
   
   //Read data channel signals
   logic [DATA_WIDTH-1:0]	RDATA	;
   logic [ID_WIDTH-1:0]		RID	;
   logic 			RLAST	;
   logic 			RREADY	;
   logic [1:0]			RRESP	;
   logic 			RVALID	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic [ID_WIDTH-1:0]		WID	;
   logic 			WLAST	;
   logic  			WREADY	;
   logic [DATA_WIDTH>>3-1:0] 	WSTRB	;
   logic  			WVALID	;
endinterface
*/
//default param config to AXI
interface axi4_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
   parameter ID_WIDTH 		= 4	;
   parameter USER_SIGNAL_WIDTH 	= 8	;

   //Global signals
   logic			ACLK	;
   logic 			ARESETn	;

   //Read address channel signals
   logic [ADDR_WIDTH-1:0]	ARADDR	;
   logic [1:0]  		ARBURST	;
   logic [3:0] 			ARCACHE	;
   logic [ID_WIDTH-1:0]		ARID	;
   logic [7:0]			ARLEN	;
   logic 			ARLOCK	;
   logic [2:0] 			ARPROT	;
   logic [3:0] 			ARQOS	;
   logic 			ARREADY	;
   logic [3:0] 			ARREGION;
   logic [2:0]			ARSIZE	;
   logic			ARVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]ARUSER	;
   
   //Write address channel signals
   logic [ADDR_WIDTH-1:0]	AWADDR	;
   logic [1:0]  		AWBURST	;
   logic [3:0] 			AWCACHE	;
   logic [ID_WIDTH-1:0]		AWID	;
   logic [7:0]			AWLEN	;
   logic 			AWLOCK	;
   logic [2:0] 			AWPROT	;
   logic [3:0] 			AWQOS	;
   logic  			AWREADY	;
   logic [3:0] 			AWREGION;
   logic [2:0]			AWSIZE	;
   logic  			AWVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]AWUSER	;

   //Write response channel signals
   logic [ID_WIDTH-1:0]		BID	;
   logic			BREADY	;
   logic [1:0]			BRESP	;
   logic 			BVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]BUSER	;
   
   //Read data channel signals
   logic [DATA_WIDTH-1:0]	RDATA	;
   logic [ID_WIDTH-1:0]		RID	;
   logic 			RLAST	;
   logic 			RREADY	;
   logic [1:0]			RRESP	;
   logic 			RVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]RUSER	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic 			WLAST	;
   logic  			WREADY	;
   logic [DATA_WIDTH>>3-1:0] 	WSTRB	;
   logic  			WVALID	;
   logic [USER_SIGNAL_WIDTH-1:0]WUSER	;
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
   logic 			RREADY	;
   logic [1:0]			RRESP	;
   logic 			RVALID	;

   //Write data channel signals
   logic [DATA_WIDTH-1:0]	WDATA	;
   logic  			WREADY	;
   logic [DATA_WIDTH>>3-1:0] 	WSTRB	;
   logic  			WVALID	;
endinterface
*/
