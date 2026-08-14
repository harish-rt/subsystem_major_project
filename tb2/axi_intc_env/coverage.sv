/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/coverage.sv                                            */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2023                       */
/*                                                                        */
/* All Rights Reserved                                                    */
/*                                                                        */
/* NOTICE: All information contained herein is, and remains the           */
/* property of Raiton semiconductor PVT. LTD. and its suppliers           */
/* ,if any.  The intellectual and  technical concepts contained           */
/* herein  are proprietary to  Raiton  semiconductor  PVT. LTD.           */
/* they are protected  by trade secrets and / or copyright law.           */
/* Dissemination of this  information  or reproduction of  this           */
/* material or code is strictly forbidden unless  prior written           */
/* permission is obtained from Raiton semiconductor PVT. LTD.             */
/*                                                                        */
/* RAITON_COPYRIGHT_END                                                   */

class coverage extends uvm_component;
 
   `uvm_component_utils(coverage)
    
    uvm_tlm_analysis_fifo #(axi_4_lite_seq_item) 	axi_cvg_af;
    uvm_tlm_analysis_fifo #(intc_seq_item) 				intc_cvg_af;
    
		axi_4_lite_seq_item 													axi_data;
		intc_seq_item																	intc_data;

		int addr_range[$];
		
		covergroup axi_cg;
			option.per_instance = 1;
			option.name = "AXI_COVER_GROUP";

			AWADDR		: coverpoint axi_data.axi_awaddr	{bins waddr[] = addr_range; ignore_bins read_only = {'h04,'h18};}
			ARADDR		:	coverpoint axi_data.axi_araddr	{bins raddr[] = addr_range;}
			BRESP			: coverpoint axi_data.axi_bresp		{bins wresp 	= {2'b00};		illegal_bins wrresp 	= {2'b01,2'b10,2'b11};}
			RRESP			: coverpoint axi_data.axi_rresp		{bins rresp 	= {2'b00};		illegal_bins wrresp 	= {2'b01,2'b10,2'b11};}
			
		endgroup

		covergroup intc_cg;
			option.per_instance = 1;
			option.name = "INTC_COVER_GROUP";

			INTR			: coverpoint $countones(intc_data.intc_intr)	{bins no_of_intrs[] = {[0:32]};}
			ACK				: coverpoint intc_data.intc_procss_acklg			{bins ack[]					= {0,1,2,3};}
		endgroup

		covergroup func_reg_cg();
			option.per_instance = 1;
			option.name = "FUNC_REG_COVER_GROUP";
			
			ISR_0_31	: coverpoint $countones(intc_data.isr) 	{bins isr_ones[] = {[0:32]};}
			IER_0_31	: coverpoint $countones(intc_data.ier) 	{bins ier_ones[] = {[0:32]};}
			IPR_0_31	: coverpoint $countones(intc_data.ipr) 	{bins ipr_ones[] = {[0:31]};}
			IVR_CP		: coverpoint intc_data.ivr 							{bins ivr_values[] = {[0:31]};}
			MER_CP		: coverpoint intc_data.mer[1:0];
			
		endgroup
	
		covergroup iar_cg();
			option.per_instance = 1;
			option.name = "IAR_COVER_GROUP";

			IAR_0_7		: coverpoint intc_data.iar[7:0]	 	{bins b1[] = {1,2,4,8,16,32,64,128,256};}
			IAR_8_15	: coverpoint intc_data.iar[15:8] 	{bins b2[] = {1,2,4,8,16,32,64,128,256};}
			IAR_16_23	: coverpoint intc_data.iar[23:16] {bins b3[] = {1,2,4,8,16,32,64,128,256};}
			IAR_24_31	: coverpoint intc_data.iar[31:24] {bins b4[] = {1,2,4,8,16,32,64,128,256};}
		endgroup
		
	function new(string name = "coverage", uvm_component parent);
  	super.new(name , parent);

		//-------------------- ARRAY OF VALID ADDRESS OF DUT REGISTERS --------------------//
		for(int i=0;i<42;i++)
			begin	
				if(i == 10)				addr_range.push_back('h100);
				else if(i>0)			addr_range.push_back(addr_range[i-1]+ 4'h4);
				else							addr_range[i] = 4'h0;
			end
			
		axi_cg 			= new();
		intc_cg 		= new();
		func_reg_cg	= new();
		iar_cg 			= new();
	endfunction
    
	extern function void build_phase	(uvm_phase phase);
  extern task run_phase             (uvm_phase phase);
	extern function void report_phase	(uvm_phase phase);
  extern task sampling_of_values		();
	extern task func_axi_sample				();

endclass : coverage

	function void coverage :: build_phase (uvm_phase phase);
    super.build_phase (phase);
    axi_cvg_af   =   new ("axi_cvg_af",this);
    intc_cvg_af  =   new ("intc_cvg_af",this);
  	`uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)			
 	endfunction : build_phase

	task coverage :: run_phase (uvm_phase phase);
		intc_data = intc_seq_item :: type_id :: create("intc_data");

		forever
			begin
				fork
					axi_cvg_af.get(axi_data);
					intc_cvg_af.get(intc_data);
				join_any
	  		sampling_of_values();
			end
  endtask
   
	task coverage :: sampling_of_values();
  	if(axi_data != null)
			begin
				case(axi_data.axi_awaddr)
					'h00 : intc_data.isr = axi_data.axi_wdata;
					'h08 : intc_data.ier = axi_data.axi_wdata;
					'h0C : intc_data.iar = axi_data.axi_wdata;
					'h1C : intc_data.mer = axi_data.axi_wdata;
					'h20 : intc_data.imr = axi_data.axi_wdata;
					'h10 : begin intc_data.sie = axi_data.axi_wdata;	intc_data.ier = axi_data.axi_wdata; end
					'h14 : begin intc_data.cie = axi_data.axi_wdata;
											 intc_data.ier = intc_data.ier | intc_data.cie;
											 intc_data.ier = intc_data.ier ^ intc_data.cie; end
				endcase
				case(axi_data.axi_araddr)
					'h04 : intc_data.ipr = axi_data.axi_rdata;
					'h18 : intc_data.ivr = axi_data.axi_rdata;
				endcase
				
				func_axi_sample();
			end
		if(intc_data != null)
			intc_cg.sample();
  endtask

	task coverage :: func_axi_sample();
		axi_cg.sample();
		func_reg_cg.sample();
		iar_cg.sample();
	endtask
	
	function void coverage :: report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info("COVERAGE",$sformatf("AXI COVERAGE REPORT---------------- %0f",axi_cg.get_coverage()),UVM_NONE)
		`uvm_info("COVERAGE",$sformatf("INTC COVERAGE REPORT---------------- %0f",intc_cg.get_coverage()),UVM_NONE)
		`uvm_info("COVERAGE",$sformatf("IAR COVERAGE REPORT---------------- %0f",iar_cg.get_coverage()),UVM_NONE)
		`uvm_info("COVERAGE",$sformatf("FUNCTIONAL REGSTERS COVERAGE REPORT---------------- %0f",func_reg_cg.get_coverage()),UVM_NONE)		
	endfunction

























	/*
	covergroup ier_cg();
			option.per_instance = 1;
			option.name = "IER_COVER_GROUP";
			
			IER_0_4		: coverpoint intc_data.ier[4:0];
			IER_5_9		: coverpoint intc_data.ier[9:5];
			IER_10_15	: coverpoint intc_data.ier[15:10];
			IER_16_20	: coverpoint intc_data.ier[20:16];
			IER_21_25	: coverpoint intc_data.ier[25:21];
			IER_26_30	: coverpoint intc_data.ier[30:26];
			IER_30_31	: coverpoint intc_data.ier[31:30];
		endgroup
*/
