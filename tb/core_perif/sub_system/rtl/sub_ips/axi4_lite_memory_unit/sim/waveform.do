onerror { resume }
set curr_transcript [transcript]
transcript off

add wave /mem_unit_tb/clk
add wave /mem_unit_tb/rst_n
add wave -expand -vgroup AXI_Lite_Intf \
	( -logic /mem_unit_tb/m_axi_intf/ACLK ) \
	( -logic /mem_unit_tb/m_axi_intf/ARESETn ) \
	( -vgroup AW_Channel \
		( -height 21 -logic /mem_unit_tb/m_axi_intf/AWVALID ) \
		( -logic /mem_unit_tb/m_axi_intf/AWREADY ) \
		( -literal /mem_unit_tb/m_axi_intf/AWADDR ) \
	) \
	( -vgroup WDATA_Channel \
		( -logic /mem_unit_tb/m_axi_intf/WVALID ) \
		( -logic /mem_unit_tb/m_axi_intf/WREADY ) \
		( -literal /mem_unit_tb/m_axi_intf/WDATA ) \
		( -literal /mem_unit_tb/m_axi_intf/WSTRB ) \
	) \
	( -vgroup BRESP_Channel \
		( -logic /mem_unit_tb/m_axi_intf/BVALID ) \
		( -logic /mem_unit_tb/m_axi_intf/BREADY ) \
		( -literal /mem_unit_tb/m_axi_intf/BRESP ) \
	) \
	( -vgroup AR_Channel \
		( -logic /mem_unit_tb/m_axi_intf/ARVALID ) \
		( -logic /mem_unit_tb/m_axi_intf/ARREADY ) \
		( -literal /mem_unit_tb/m_axi_intf/ARADDR ) \
	) \
	( -vgroup RDATA_Channel \
		( -logic /mem_unit_tb/m_axi_intf/RVALID ) \
		( -logic /mem_unit_tb/m_axi_intf/RREADY ) \
		( -literal /mem_unit_tb/m_axi_intf/RDATA ) \
		( -literal /mem_unit_tb/m_axi_intf/RRESP ) \
	)
add wave -vgroup {DUT Signals} \
	/mem_unit_tb/DUT/sys_ack_wr_i \
	/mem_unit_tb/DUT/sys_ack_rd_i \
	/mem_unit_tb/DUT/sys_rd_addr_o \
	/mem_unit_tb/DUT/sys_wdata_o \
	/mem_unit_tb/DUT/sys_wr_addr_o \
	/mem_unit_tb/DUT/rd_araddr \
	/mem_unit_tb/DUT/rd_do \
	/mem_unit_tb/DUT/rd_error_slv \
	/mem_unit_tb/DUT/rd_error_dec \
	/mem_unit_tb/DUT/rd_errorw \
	/mem_unit_tb/DUT/rd_rdata \
	/mem_unit_tb/DUT/wr_awaddr \
	/mem_unit_tb/DUT/wr_awsize \
	/mem_unit_tb/DUT/wr_do \
	/mem_unit_tb/DUT/wr_data_do \
	/mem_unit_tb/DUT/wr_error_slv \
	/mem_unit_tb/DUT/wr_error_dec \
	/mem_unit_tb/DUT/wr_errorw \
	/mem_unit_tb/DUT/wr_wdata \
	/mem_unit_tb/DUT/wr_wstrb \
	/mem_unit_tb/DUT/ack_wr \
	/mem_unit_tb/DUT/ack_wr_cnt \
	/mem_unit_tb/DUT/ack_rd \
	/mem_unit_tb/DUT/ack_rd_cnt \
	/mem_unit_tb/DUT/axsize_validation.size \
	/mem_unit_tb/DUT/axsize_validation.axsize_validation
add wave -vgroup TB_Signals \
	/mem_unit_tb/awaddr \
	/mem_unit_tb/araddr \
	/mem_unit_tb/wdata \
	/mem_unit_tb/rdata \
	/mem_unit_tb/write_mem.addr \
	/mem_unit_tb/write_mem.data \
	/mem_unit_tb/read_mem.addr \
	/mem_unit_tb/read_mem.data \
	/mem_unit_tb/read_mem.rresp \
	/mem_unit_tb/run_test.transfers
wv.cursors.add -time 115ps -name {Default cursor}
wv.cursors.setactive -name {Default cursor}
wv.zoom.range -from 87ps -to 183ps
wv.time.unit.auto.set
transcript $curr_transcript
