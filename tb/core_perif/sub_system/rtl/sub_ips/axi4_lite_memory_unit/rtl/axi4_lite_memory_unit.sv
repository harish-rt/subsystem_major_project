module axi4_lite_memory_unit
#(
parameter           AXI_AW         = 32          , // address width
parameter           AXI_DW         = 32          , // data width (8,16,...,1024)
parameter           AXI_SW         = AXI_DW >> 3 , // strobe width - 1 bit for every data byte
parameter           MEM_BASE_ADDR  = 'h800     	 , //base address for this mem
parameter           MEM_BYTES      = 20     	   //2**MEM_BYTES will be the address space for this mem(with base address)
)
(axi4_lite_intf s_axi_intf);
//read/write channel reg signals
reg                  sys_ack_wr_i    ;  //!< system wr acknowledge signal.
reg                  sys_ack_rd_i    ;  //!< system rd acknowledge signal.

wire  [ AXI_AW-1: 0] sys_rd_addr_o;  //!< system read  address.
wire  [ AXI_DW-1: 0] sys_wdata_o  ;  //!< system write data.
wire  [ AXI_AW-1: 0] sys_wr_addr_o;  //!< system write address.

reg   [ AXI_AW-1: 0] rd_araddr    ;
reg                  rd_do        ;
reg                  rd_error_slv ;
reg                  rd_error_dec ;
wire                 rd_errorw    ;
reg   [ AXI_DW-1: 0] rd_rdata	  ;

reg   [ AXI_AW-1: 0] wr_awaddr    ;
reg   [        2: 0] wr_awsize	  ;
reg                  wr_do        ;
reg                  wr_data_do   ;
reg                  wr_error_slv ;
reg                  wr_error_dec ;
wire                 wr_errorw    ;
reg   [ AXI_DW-1: 0] wr_wdata     ;
reg   [ AXI_SW-1: 0] wr_wstrb	  ;

wire 		     ack_wr	  ;
reg   [      6-1: 0] ack_wr_cnt   ;

wire 		     ack_rd	  ;
reg   [      6-1: 0] ack_rd_cnt   ;

reg   [AXI_DW-1 : 0] mem [((2**MEM_BYTES)/AXI_SW)];

assign rd_errorw = 0; //(s_axi_intf.ARLEN != 'h0) || axsize_validation(s_axi_intf.ARSIZE); // error if  read burst and more/less than 4B transfer
assign wr_errorw = 0; //(s_axi_intf.AWLEN != 'h0) || axsize_validation(s_axi_intf.AWSIZE); // error if write burst and more/less than 4B transfer

always @(posedge s_axi_intf.ACLK)
  if (s_axi_intf.ARESETn == 1'b0) begin
      rd_do    	   <= 1'b0 ;
      rd_error_slv <= 1'b0 ;
      rd_error_dec <= 1'b0 ;
  end else begin
      if (s_axi_intf.ARVALID && s_axi_intf.ARREADY) begin // latch ID and address
         rd_do        <= 1'b1 ;
         rd_araddr    <= s_axi_intf.ARADDR ;
         rd_error_slv <= (rd_errorw || (s_axi_intf.ARADDR[(AXI_AW-1):MEM_BYTES] != MEM_BASE_ADDR));
         rd_error_dec <= (s_axi_intf.ARADDR[(AXI_AW-1):MEM_BYTES] != MEM_BASE_ADDR);
      end else if (s_axi_intf.RREADY && s_axi_intf.RVALID)
         rd_do        <= 1'b0 ;
  end

always @(posedge s_axi_intf.ACLK)
  if (s_axi_intf.ARESETn == 1'b0) begin
      wr_do    	   <= 1'b0 ;
      wr_data_do   <= 1'b0 ;
      wr_error_slv <= 1'b0 ;
      wr_error_dec <= 1'b0 ;
      wr_wstrb     <= {AXI_SW{1'b0}} ;
  end else begin
      if (s_axi_intf.AWVALID && s_axi_intf.AWREADY) begin // latch ID and address
         wr_do 	      <= 1'b1 ;
         wr_awaddr    <= s_axi_intf.AWADDR ;
     //  wr_awsize    <= s_axi_intf.AWSIZE ;
         wr_error_slv <= (wr_errorw || (s_axi_intf.AWADDR[(AXI_AW-1):MEM_BYTES] != MEM_BASE_ADDR));
         wr_error_dec <= (s_axi_intf.AWADDR[(AXI_AW-1):MEM_BYTES] != MEM_BASE_ADDR) ;
      end else if (s_axi_intf.BREADY && s_axi_intf.BVALID)
         wr_do        <= 1'b0 ;

      if (s_axi_intf.WVALID && s_axi_intf.WREADY) begin // latch ID and write data
         wr_wdata   <= s_axi_intf.WDATA ;
	 wr_wstrb   <= s_axi_intf.WSTRB ;
	 wr_data_do <= 1;
      end else if(s_axi_intf.BREADY && s_axi_intf.BVALID) wr_data_do <=0;
  end

assign s_axi_intf.AWREADY = !wr_do ;
assign s_axi_intf.ARREADY = !rd_do ;

assign s_axi_intf.WREADY  = !wr_data_do;

assign s_axi_intf.BVALID  = wr_do && wr_data_do && ack_wr ;

//assign s_axi_intf.BRESP   = {( wr_error_slv || ack_wr_cnt[5]),wr_error_dec}   ;
assign s_axi_intf.BRESP   = 0   ;

assign s_axi_intf.RVALID  = rd_do && ack_rd  ;
assign s_axi_intf.RDATA   = rd_rdata   ;
//assign s_axi_intf.RLAST   = rd_do && ack_wr   ;
//assign s_axi_intf.RRESP   = {( rd_error_slv || ack_wr_cnt[5]),rd_error_dec}   ;
assign s_axi_intf.RRESP   = 0   ;


// rd_acknowledge protection
always @(posedge s_axi_intf.ACLK)
  if (s_axi_intf.ARESETn == 1'b0) begin
      ack_rd_cnt   <= 6'h0 ;
  end else begin
      if ((s_axi_intf.ARVALID && s_axi_intf.ARREADY) || (s_axi_intf.AWVALID && s_axi_intf.AWREADY))  // rd || wr request
         ack_rd_cnt <= 6'h1 ;
      else if (ack_rd)
         ack_rd_cnt <= 6'h0 ;
      else if (|ack_rd_cnt)
         ack_rd_cnt <= ack_rd_cnt + 6'h1 ;
  end

// wr_acknowledge protection
always @(posedge s_axi_intf.ACLK)
  if (s_axi_intf.ARESETn == 1'b0) begin
      ack_wr_cnt   <= 6'h0 ;
  end else begin
      if ((s_axi_intf.AWVALID && s_axi_intf.AWREADY))  //wr request
         ack_wr_cnt <= 6'h1 ;
      else if (ack_wr)
         ack_wr_cnt <= 6'h0 ;
      else if (|ack_wr_cnt)
         ack_wr_cnt <= ack_wr_cnt + 6'h1 ;
  end

assign ack_rd = sys_ack_rd_i || ack_rd_cnt[5] || (rd_do && rd_errorw) ;			// bus ack_wrnowledge or timeout or error
assign ack_wr = sys_ack_wr_i || ack_wr_cnt[5] || (wr_do && wr_data_do && wr_errorw) ; 	// bus ack_wrnowledge or timeout or error

assign sys_wr_addr_o  = wr_awaddr ;
assign sys_rd_addr_o  = rd_araddr ;
assign sys_wdata_o    = wr_wdata ;


always @(posedge s_axi_intf.ACLK)
  if (s_axi_intf.ARESETn == 1'b0) begin
	for(int i=0; i<((2**MEM_BYTES)/AXI_SW); i++) mem[i] <= '0;	//initializing or reseting mem

        rd_rdata  	<= 0;
        sys_ack_rd_i 	<= 0;
  end else begin
	if((rd_do && !rd_errorw) && sys_rd_addr_o [(AXI_AW-1):MEM_BYTES] == MEM_BASE_ADDR) begin
          rd_rdata  	<= mem[{sys_rd_addr_o[(MEM_BYTES-1):2],2'b00}/4];
	  sys_ack_rd_i 	<= 1;
        end else if(rd_do && !rd_errorw) sys_ack_rd_i <= 1;
	else sys_ack_rd_i <= 0;
  end

always @(posedge s_axi_intf.ACLK)
  if (s_axi_intf.ARESETn == 1'b0) begin
	//for(int i=0; i<(MEM_BYTES/AXI_SW); i++) mem [i] = '0;	//initializing or reseting mem
        rd_rdata  <= 0;
        sys_ack_wr_i <= 0;
  end else begin
	if(wr_do && wr_data_do && !wr_errorw && sys_wr_addr_o [(AXI_AW-1):MEM_BYTES] == MEM_BASE_ADDR) begin
/*
	  for(int i=0;i<AXI_SW; i++)
	   	//if(wr_wstrb[i]==1) mem [{sys_wr_addr_o[(MEM_BYTES-1):2],2'b00}/AXI_SW] [(i*8)+7: (i*8)] <= sys_wdata_o[(i*8)+7: (i*8)];
genvar wr_stb;
	generate for (wr_stb=0; wr_stb<=AXI_SW; wr_stb++) begin
	  if(wr_wstrb[wr_stb]==1) mem [{sys_wr_addr_o[(MEM_BYTES-1):2],2'b00}/4] [ ((wr_stb*8)+7): (wr_stb*8)]<= sys_wdata_o[ ((wr_stb*8)+7): (wr_stb*8)];
  	endgenerate

*/

	  if(wr_wstrb[0]==1) mem [{sys_wr_addr_o[(MEM_BYTES-1):2],2'b00}/4] [ 7: 0]<= sys_wdata_o[ 7: 0];
	  if(wr_wstrb[1]==1) mem [{sys_wr_addr_o[(MEM_BYTES-1):2],2'b00}/4] [15: 8]<= sys_wdata_o[15: 8];
	  if(wr_wstrb[2]==1) mem [{sys_wr_addr_o[(MEM_BYTES-1):2],2'b00}/4] [23:16]<= sys_wdata_o[23:16];
 	  if(wr_wstrb[3]==1) mem [{sys_wr_addr_o[(MEM_BYTES-1):2],2'b00}/4] [31:24]<= sys_wdata_o[31:24];

	  sys_ack_wr_i <= 1;
        end else if((wr_do && wr_data_do && !wr_errorw)) sys_ack_wr_i <= 1;
	else sys_ack_wr_i <= 0;
  end

function bit axsize_validation (bit [2:0] size);
	if     ((AXI_SW <=   4 && size <= AXI_SW>>1) ||
		(AXI_SW ==   8 && size <= 3'b011) ||
		(AXI_SW ==  16 && size <= 3'b100) ||
		(AXI_SW ==  32 && size <= 3'b101) ||
		(AXI_SW ==  64 && size <= 3'b110) ||
		(AXI_SW == 128 && size <= 3'b111)) return 0;
	else return 1;
endfunction

endmodule
