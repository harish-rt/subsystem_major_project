//default param config to AXI
interface axi4_tb_intf();
   parameter ADDR_WIDTH 	    = 32;
   parameter DATA_WIDTH 	    = 32;
   parameter ID_WIDTH 		    = 4	;
   parameter USER_SIGNAL_WIDTH 	= 8	;

   //Global signals
   wire			ACLK	;
   wire 			ARESETn	;

   //Read address channel signals
   wire [ID_WIDTH-1:0]		ARID	;
   wire [ADDR_WIDTH-1:0]	ARADDR	;
   wire [7:0]			    ARLEN	;
   wire [2:0]			    ARSIZE	;
   wire [1:0]  		    ARBURST	;
   wire			        ARVALID	;
   wire 			        ARREADY	;
   wire [3:0] 			    ARCACHE	;
   wire 			        ARLOCK	;
   wire [2:0] 			    ARPROT	;
   wire [3:0] 			    ARQOS	;
   wire [3:0] 			    ARREGION;
   wire [USER_SIGNAL_WIDTH-1:0]ARUSER	;
   
   //Write address channel signals
   wire [ID_WIDTH-1:0]		AWID	;
   wire [ADDR_WIDTH-1:0]	AWADDR	;
   wire [7:0]			    AWLEN	;
   wire [2:0]			    AWSIZE	;
   wire [1:0]  		    AWBURST	;
   wire  			        AWVALID	;
   wire  			        AWREADY	;
   wire [3:0] 			    AWCACHE	;
   wire 			        AWLOCK	;
   wire [2:0] 			    AWPROT	;
   wire [3:0] 			    AWQOS	;
   wire [3:0] 			    AWREGION;
   wire [USER_SIGNAL_WIDTH-1:0]AWUSER	;

   //Write response channel signals
   wire [ID_WIDTH-1:0]		BID	;
   wire [1:0]			    BRESP	;
   wire 			        BVALID	;
   wire			        BREADY	;
   wire [USER_SIGNAL_WIDTH-1:0]BUSER	;
   
   //Read data channel signals
   wire [ID_WIDTH-1:0]		RID	;
   wire [DATA_WIDTH-1:0]	RDATA	;
   wire 			        RLAST	;
   wire [1:0]			    RRESP	;
   wire 			        RVALID	;
   wire 			        RREADY	;
   wire [USER_SIGNAL_WIDTH-1:0]RUSER	;

   //Write data channel signals
   wire [DATA_WIDTH-1:0]	WDATA	;
   wire [DATA_WIDTH>>3-1:0]WSTRB	;
   wire 			        WLAST	;
   wire  			        WVALID	;
   wire  			        WREADY	;
   wire [USER_SIGNAL_WIDTH-1:0]WUSER	;

    clocking tb_master_cb @(posedge ACLK);
        default input #1ns output #1ns;
        output ARADDR, ARBURST, ARCACHE, ARID, ARLEN, ARLOCK, ARPROT, ARQOS, ARREGION, ARSIZE, ARVALID, ARUSER;
        input  ARREADY;
        output AWADDR, AWBURST, AWCACHE, AWID, AWLEN, AWLOCK, AWPROT, AWQOS, AWREGION, AWSIZE, AWVALID, AWUSER;
        input  AWREADY;
        output WDATA, WSTRB, WLAST, WVALID, WUSER;
        input  WREADY;
        input  BID, BRESP, BVALID, BUSER;
        output BREADY;
        input  RID, RDATA, RRESP, RLAST, RVALID, RUSER;
        output RREADY;
    endclocking

    clocking axi4_drv_cb @(posedge ACLK);
        default input #1ns output #1ns;
        output ARADDR, ARBURST, ARCACHE, ARID, ARLEN, ARLOCK, ARPROT, ARQOS, ARREGION, ARSIZE, ARVALID, ARUSER;
        input  ARREADY;
        output AWADDR, AWBURST, AWCACHE, AWID, AWLEN, AWLOCK, AWPROT, AWQOS, AWREGION, AWSIZE, AWVALID, AWUSER;
        input  AWREADY;
        output WDATA, WSTRB, WLAST, WVALID, WUSER;
        input  WREADY;
        input  BID, BRESP, BVALID, BUSER;
        output BREADY;
        input  RID, RDATA, RRESP, RLAST, RVALID, RUSER;
        output RREADY;
    endclocking

    clocking axi4_mon_cb @(posedge ACLK);
        default input #1ns output #1ns;

        input ARADDR, ARBURST, ARCACHE, ARID, ARLEN, ARLOCK, ARPROT, ARQOS, ARREADY, ARREGION, ARSIZE, ARVALID, ARUSER;

        input AWADDR, AWBURST, AWCACHE, AWID, AWLEN, AWLOCK, AWPROT, AWQOS, AWREADY, AWREGION, AWSIZE, AWVALID, AWUSER;

        input WDATA, WSTRB, WLAST, WVALID, WREADY, WUSER;

        input BID, BRESP, BVALID, BREADY, BUSER;

        input RID, RDATA, RRESP, RLAST, RVALID, RREADY, RUSER;
    endclocking

    modport TB_MASTER_MOD (clocking tb_master_cb, input ACLK, input ARESETn);
    modport MONITOR_MOD (clocking axi4_mon_cb, input ACLK, input ARESETn);
    modport DRIVER_MOD (clocking axi4_drv_cb, input ACLK, input ARESETn);

endinterface
/*interface axi_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
   parameter ID_WIDTH 		= 4	;
   parameter LENGTH_WIDTH 	= 4	;
   parameter LOCK_WIDTH 	= 2	;
   parameter USER_SIGNAL_WIDTH 	= 8	;

   //Global signals
   wire			ACLK	;
   wire			ARESETn	;

   //Read address channel signals
   wire [ADDR_WIDTH-1:0]	ARADDR	;
   wire [1:0]  		ARBURST	;
   wire [3:0] 			ARCACHE	;
   wire [ID_WIDTH-1:0]		ARID	;
   wire [LENGTH_WIDTH-1:0]	ARLEN	;
   wire [LOCK_WIDTH-1:0]	ARLOCK	;
   wire [2:0] 			ARPROT	;
   wire [3:0] 			ARQOS	;
   wire 			ARREADY	;
   wire [3:0] 			ARREGION;
   wire [2:0]			ARSIZE	;
   wire			ARVALID	;
   wire [USER_SIGNAL_WIDTH-1:0]ARUSER	;
   
   //Write address channel signals
   wire [ADDR_WIDTH-1:0]	AWADDR	;
   wire [1:0]  		AWBURST	;
   wire [3:0] 			AWCACHE	;
   wire [ID_WIDTH-1:0]		AWID	;
   wire [LENGTH_WIDTH-1:0]	AWLEN	;
   wire [LOCK_WIDTH-1:0]	AWLOCK	;
   wire [2:0] 			AWPROT	;
   wire [3:0] 			AWQOS	;
   wire  			AWREADY	;
   wire [3:0] 			AWREGION;
   wire [2:0]			AWSIZE	;
   wire  			AWVALID	;
   wire [USER_SIGNAL_WIDTH-1:0]AWUSER	;
  
   //Write response channel signals
   wire [ID_WIDTH-1:0]		BID	;
   wire			BREADY	;
   wire [1:0]			BRESP	;
   wire 			BVALID	;
   wire [USER_SIGNAL_WIDTH-1:0]BUSER	;
   
   //Read data channel signals
   wire [DATA_WIDTH-1:0]	RDATA	;
   wire [ID_WIDTH-1:0]		RID	;
   wire 			RLAST	;
   wire 			RREADY	;
   wire [1:0]			RRESP	;
   wire 			RVALID	;
   wire [USER_SIGNAL_WIDTH-1:0]RUSER	;

   //Write data channel signals
   wire [DATA_WIDTH-1:0]	WDATA	;
   wire [ID_WIDTH-1:0]		WID	;
   wire 			WLAST	;
   wire  			WREADY	;
   wire [DATA_WIDTH>>3-1:0] 	WSTRB	;
   wire  			WVALID	;
   wire [USER_SIGNAL_WIDTH-1:0]WUSER	;
endinterface

//default param config to AXI3
interface axi3_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
   parameter ID_WIDTH 		= 4	;

   //Global signals
   wire 			ACLK	;
   wire 			ARESETn	;

   //Read address channel signals
   wire [ADDR_WIDTH-1:0]	ARADDR	;
   wire [1:0]  		ARBURST	;
   wire [3:0] 			ARCACHE	;
   wire [ID_WIDTH-1:0]		ARID	;
   wire [3:0]			ARLEN	;
   wire [1:0]			ARLOCK	;
   wire [2:0] 			ARPROT	;
   wire 			ARREADY	;
   wire [2:0]			ARSIZE	;
   wire			ARVALID	;
   
   //Write address channel signals
   wire [ADDR_WIDTH-1:0]	AWADDR	;
   wire [1:0]  		AWBURST	;
   wire [3:0] 			AWCACHE	;
   wire [ID_WIDTH-1:0]		AWID	;
   wire [3:0]			AWLEN	;
   wire [1:0]			AWLOCK	;
   wire [2:0] 			AWPROT	;
   wire  			AWREADY	;
   wire [2:0]			AWSIZE	;
   wire  			AWVALID	;

   //Write response channel signals
   wire [ID_WIDTH-1:0]		BID	;
   wire			BREADY	;
   wire [1:0]			BRESP	;
   wire 			BVALID	;
   
   //Read data channel signals
   wire [DATA_WIDTH-1:0]	RDATA	;
   wire [ID_WIDTH-1:0]		RID	;
   wire 			RLAST	;
   wire 			RREADY	;
   wire [1:0]			RRESP	;
   wire 			RVALID	;

   //Write data channel signals
   wire [DATA_WIDTH-1:0]	WDATA	;
   wire [ID_WIDTH-1:0]		WID	;
   wire 			WLAST	;
   wire  			WREADY	;
   wire [DATA_WIDTH>>3-1:0] 	WSTRB	;
   wire  			WVALID	;
endinterface
*/
//default param config to AXI
/*
//default param config to AXI4_lite
interface axi4_lite_tb_intf();
   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;

   //Global signals
   wire 			ACLK	;
   wire 			ARESETn	;

   //Read address channel signals
   wire [ADDR_WIDTH-1:0]	ARADDR	;
   wire [2:0] 			ARPROT	;
   wire 			ARREADY	;
   wire			ARVALID	;
 
   //Write address channel signals
   wire [ADDR_WIDTH-1:0]	AWADDR	;
   wire [2:0] 			AWPROT	;
   wire  			AWREADY	;
   wire  			AWVALID	;

   //Write response channel signals
   wire			BREADY	;
   wire [1:0]			BRESP	;
   wire 			BVALID	;

   //Read data channel signals
   wire [DATA_WIDTH-1:0]	RDATA	;
   wire 			RREADY	;
   wire [1:0]			RRESP	;
   wire 			RVALID	;

   //Write data channel signals
   wire [DATA_WIDTH-1:0]	WDATA	;
   wire  			WREADY	;
   wire [DATA_WIDTH>>3-1:0] 	WSTRB	;
   wire  			WVALID	;
endinterface
*/
