/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/scoreboard.sv                                          */
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

class scoreboard extends uvm_component;
 
		`uvm_component_utils (scoreboard)
		uvm_tlm_analysis_fifo #(axi_4_lite_seq_item)	axi_fifo_h;
		uvm_tlm_analysis_fifo #(intc_seq_item)  			intc_fifo_h;

		axi_4_lite_seq_item 													axi_check;
		intc_seq_item																	intc_check;
		int			 																			axi_reg_block[int], axi_read_block[int],addr_range[$];
		int																						prev_intc, ivr_const;
		bit																						prev_irq, irq_gen, irq_ack;
		int 																					irq_count, ref_irq_count;
		

		function new (string name = "scoreboard" , uvm_component parent);
			super.new(name,parent);
   	endfunction  

   	extern function void build_phase              	(uvm_phase phase);
   	extern function void connect_phase            	(uvm_phase phase);
   	extern function void end_of_elaboration_phase 	(uvm_phase phase);
   	extern function void start_of_simulation_phase	(uvm_phase phase);
   	extern function void extract_phase            	(uvm_phase phase);
   	extern function void check_phase              	(uvm_phase phase);
   	extern function void report_phase             	(uvm_phase phase);
   	extern function void final_phase              	(uvm_phase phase);
   	extern task run_phase                         	(uvm_phase phase);
		extern task axi_ref_model												(axi_4_lite_seq_item axi_data);
		extern task isr_process													(int intc_data);
		extern task ivr_process													();
		extern task imr_process													();
		extern task read_compare												();
		extern task irq_detection												();
 
endclass :scoreboard


  function void scoreboard :: build_phase (uvm_phase phase);
  	super.build_phase (phase);
    axi_fifo_h = new ("axi_fifo_h",this);
    intc_fifo_h = new ("intc_fifo_h",this);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : build_phase

  function void scoreboard :: connect_phase (uvm_phase phase);
    super.connect_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void scoreboard :: end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void scoreboard :: start_of_simulation_phase (uvm_phase phase);
    super.start_of_simulation_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void scoreboard :: extract_phase (uvm_phase phase);
    super.extract_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void scoreboard :: check_phase (uvm_phase phase);
    super.check_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void scoreboard :: report_phase (uvm_phase phase);
    super.report_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void scoreboard :: final_phase (uvm_phase phase);
    super.final_phase (phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

  task scoreboard :: run_phase (uvm_phase phase);

		//-------------------- ARRAY OF VALID ADDRESS OF DUT REGISTERS --------------------//
		for(int i=0;i<42;i++)
			begin	
				if(i == 10)				addr_range.push_back('h100);
				else if(i>0)			addr_range.push_back(addr_range[i-1]+ 4'h4);
				else							addr_range[i] = 4'h0;
			end

		//-------------------- Initializing the AXI REF MODEL to 0 --------------------//
		foreach(addr_range[i])
			begin
				axi_reg_block[addr_range[i]] = 32'd0;
			end

		forever
			begin
				fork
					axi_fifo_h.get(axi_check);
					intc_fifo_h.get(intc_check);
				join_any

				fork
					if(axi_check != null)
						begin
							axi_ref_model(axi_check);
						end
					if(test_type != basic && intc_check != null)
						irq_detection();																									// IRQ DETECTION
				join
				
				if( (axi_check!= null) && (axi_check.axi_araddr == 'h04) && (axi_check.axi_rdata == 'h0) )
					begin
						foreach(axi_reg_block[i])
							begin
								if(i < 'h100)
									$display("REG_BLOCK----------------------------REG_BLOCK[%0h]:%0h",i,axi_reg_block[i]);
							end
					end
			end
  endtask : run_phase
	
	//=================================================== REFERENCE MODEL ===================================================//
	task scoreboard :: axi_ref_model(axi_4_lite_seq_item axi_data);
		bit waddr_in_range, raddr_in_range;
		int IER,ISR,SIE,CIE,IPR,IAR=0;
		int ILR = 32'hFFFF_FFFF;
		
		if(axi_data.trans_type == WRITE)
			waddr_in_range = axi_data.axi_awaddr inside {addr_range} ? 1 : 0;

		if(axi_data.trans_type == READ)
			raddr_in_range = axi_data.axi_araddr inside {addr_range} ? 1 : 0;

	//WRITE OPERATION BEGINS --------------------------------------------------------------------------------------------------
	
		if( (axi_data.trans_type == WRITE) )
			begin
				
				if(axi_data.axi_areset_n == 0 || ((intc_check != null) && (intc_check.intc_procss_rst == 1)) )
					begin
						`uvm_warning("AXI_REF_MODEL","--------------------------- RESET APPLIED")
						foreach(axi_reg_block[i])
							begin
								axi_reg_block[i] = 32'd0;
							end
					end
					
				else if(waddr_in_range == 0)
					`uvm_warning("SCOREBOARD_CHECKER","--------------------------- INVALID WRITE ADDRESS")

				else if( (axi_data.axi_awaddr == 'h04) || (axi_data.axi_awaddr =='h18) )
					begin
						`uvm_info("SCOREBOARD_CHECKER",$sformatf("-------------------- ADDRESS:%0h",axi_data.axi_awaddr),UVM_NONE)
						`uvm_warning("SCOREBOARD_CHECKER","--------------------------- WRITE ACCESS DENIED FOR ABOVE ADDRESS")
					end

				else
					begin
											
						if( (axi_data.axi_awaddr == 'h00) && (axi_reg_block['h1C] == 32'b01 || axi_reg_block['h1C] == 32'b00))
							axi_reg_block[axi_data.axi_awaddr] = axi_data.axi_wdata;

						if( (axi_reg_block['h1C] == 32'b11 || axi_reg_block['h1C] == 32'b10) )
							begin
								if(intc_check != null)
									isr_process(intc_check.intc_intr);														// Updating ISR based on the INTERRUPT INPUTS
							end

						if(axi_data.axi_awaddr inside {['h100:'h17C]})
							axi_reg_block[axi_data.axi_awaddr] = axi_data.axi_wdata;

						if(axi_data.axi_awaddr == 'h08 || 'h10 || 'h14 || 'h1C || 'h20)
							begin
								if(axi_data.axi_awaddr == 'h1C)
									axi_reg_block[axi_data.axi_awaddr] = axi_data.axi_wdata[1:0];
								else
									axi_reg_block[axi_data.axi_awaddr] = axi_data.axi_wdata;
							end

						if(axi_reg_block['h00] != 0)
							ivr_process();																										// IVR Updation

						

						if(axi_data.axi_awaddr == 'h10)
							begin
								axi_reg_block['h08] = axi_data.axi_wdata;												// Updating IER after SIE 
								axi_reg_block['h10] = 32'd0;
							end

						if(axi_data.axi_awaddr == 'h14)
							begin
								CIE 								= axi_data.axi_wdata;
								IER 								= axi_reg_block['h08] | CIE;
								IER 								= IER ^ CIE;																		
								axi_reg_block['h08] = IER;																			// Updating IER after CIE
								axi_reg_block['h14] = 32'd0;
							end
							
						if( (axi_data.axi_awaddr == 'h0C) && (axi_reg_block['h00] != 32'd0) )
							begin
								ISR 																= axi_reg_block['h00];
								axi_reg_block['h00] 								= ISR ^ axi_data.axi_wdata;	// Updating ISR based on IAR Acknowledgment
								axi_reg_block[axi_data.axi_awaddr] 	= 0;												// IAR Updates to 0 after any WRITE Operation
								irq_ack															= 1;
								ref_irq_count++;
							end
						
						if(axi_data.axi_awaddr == 'h24)
							begin
								ILR[6:0]														= axi_data.axi_wdata;
								axi_reg_block[axi_data.axi_awaddr]	= ILR;
							end

						if((axi_reg_block['h1C] == 2'b11) && (axi_reg_block['h20][ivr_const] == 1'b1) && (intc_check != null) && (intc_check.intc_procss_acklg == 2'b11))
							begin
								axi_reg_block['h00][ivr_const] = 1'b0;														// Updating ISR based on IMR Value & Ack from Processor
								irq_ack												 = 1'b1;
								ref_irq_count++;
							end

						begin	
							axi_reg_block['h04]	= axi_reg_block['h00] & axi_reg_block['h08];	// Updating IPR
						end

         end
			end
	//-------------------------------------------------------------------------------------------------- WRITE OPERATION ENDS
	
	//READ OPERATION BEGINS -------------------------------------------------------------------------------------------------- 

		if( (axi_data.trans_type == READ) )
			begin
				if(raddr_in_range == 0)
					`uvm_warning("SCOREBOARD_CHECKER","--------------------------- INVALID READ ADDRESS")
				else
					begin					
            axi_read_block[axi_data.axi_araddr] = axi_data.axi_rdata;

						if( (axi_reg_block['h1C] == 'h02) && ( test_type != basic) ) begin
							if(axi_reg_block[axi_data.axi_araddr] == axi_read_block[axi_data.axi_araddr])
                `uvm_info("SCOREBOARD_CHECKER",$sformatf("ARADDR:%h RDATA:%h READ SUCCESSFULL",axi_data.axi_araddr,axi_data.axi_rdata),UVM_NONE)
              else
                `uvm_error("SCOREBOARD_CHECKER",$sformatf("ARADDR:%h RDATA:%h REF_MODEL_DATA:%h READ FAILED",axi_data.axi_araddr,axi_data.axi_araddr,axi_reg_block[axi_data.axi_araddr]))
            end
							
						else if(test_type == basic)
							begin
                `uvm_info("SCOREBOARD_CHECKER", $sformatf("ADDRESS:%0h  REF DATA:%0h  DUT DATA:%0h",axi_data.axi_araddr,axi_reg_block[axi_data.axi_araddr],axi_data.axi_rdata),UVM_NONE)
								if(axi_reg_block[axi_data.axi_araddr] == axi_data.axi_rdata)
									`uvm_info("SCOREBOARD_CHECKER","--------------------------- DATA MATCHED",UVM_NONE)
								else
									`uvm_error("SCOREBOARD_CHECKER","--------------------------- DATA MATCH FAILED")
							end
					end
			end
	//-------------------------------------------------------------------------------------------------- READ OPERATION ENDS
	endtask

	//========================================================================================================================//


	//=================================================== ISR PROCESS ===================================================//
	task scoreboard :: isr_process(int intc_data);
		int isr_data = 0, temp_data =0 ;
		
		if(prev_intc == 0)
			begin
				axi_reg_block['h00] = intc_data;
				prev_intc						= intc_data;
			end

		else if(prev_intc != intc_data)
			begin
				temp_data = intc_data | prev_intc;
				foreach(intc_data[i])
					begin
						if(temp_data[i] != prev_intc[i])
							begin
								isr_data[i] = temp_data[i];
							end
						else
							begin
								isr_data[i] = axi_reg_block['h00][i];
							end
					end
				axi_reg_block['h00]	= isr_data;
				prev_intc 					= intc_data;
			end	
	endtask

	//=================================================== IVR PROCESS ===================================================//
	task scoreboard :: ivr_process();
		int ier_temp_data=0, isr_temp_data=0;

		isr_temp_data	= axi_reg_block['h00];
		ier_temp_data	= axi_reg_block['h08];

		for(int j=0;j<32;)
			begin
				if( (isr_temp_data[j] == 1'b1) && (ier_temp_data[j] == 1'b1) )
					begin
						axi_reg_block['h18] = j;																	// IVR Updation
						ivr_const						= j;
						j 									= 32;
					end
				else
					j++;
			end
	endtask

	//=================================================== READ COMPARE(CHECKER) ===================================================//
	task scoreboard :: read_compare();
		int IVAR_ADDR = 0;
		IVAR_ADDR = 'h100 + 'h4 * (ivr_const);
			
			if( test_type != basic)
				begin

				//IPR COMPARISION -------------------------------------------------------------------------------------------------------
					if(axi_read_block['h04] == axi_reg_block['h04])
						`uvm_info("SCOREBOARD_CHECKER","IPR READ SUCCESSFULL",UVM_NONE)
					else
						begin
              `uvm_info("SCOREBOARD_CHECKER",$sformatf("READ_BLOCK['h04]:%0h REF_BLOCK['h04]:%0h",axi_read_block['h04],axi_reg_block['h04]),UVM_NONE)
							`uvm_error("SCOREBOARD_CHECKER","READING FAILED")
						end

				//IVR COMPARISION -------------------------------------------------------------------------------------------------------
					if(axi_read_block['h18] == axi_reg_block['h18])
						`uvm_info("SCOREBOARD_CHECKER","IVR READ SUCCESSFULL",UVM_NONE)
					else
						begin
              `uvm_info("SCOREBOARD_CHECKER",$sformatf("READ_BLOCK['h18]:%0h REF_BLOCK['h18]:%0h",axi_read_block['h18],axi_reg_block['h18]),UVM_NONE)
							`uvm_error("SCOREBOARD_CHECKER","IVR READING FAILED")
						end

				//INTC ADDRESS COMPARISION -------------------------------------------------------------------------------------------------------
					if(intc_check.intc_intr_addr == axi_reg_block[IVAR_ADDR])
						`uvm_info("SCOREBOARD_CHECKER","INTC ADDRESS COMPARE SUCCESSFULL",UVM_NONE)
					else
						begin
              `uvm_info("SCOREBOARD_CHECKER",$sformatf("INTC_ADDRESS:%0h REF_BLOCK[%0h]:%0h",intc_check.intc_intr_addr,IVAR_ADDR,axi_reg_block[IVAR_ADDR]),UVM_NONE)
							`uvm_error("SCOREBOARD_CHECKER","INTC ADDRESS COMPARE FAILED")
						end
						
					axi_read_block['h04] = 32'd0;
					axi_read_block['h18] = 32'd0;
				end
	endtask

	//=================================================== IRQ DETECTION (CHECKER) ===================================================//

	task scoreboard :: irq_detection();

		// IRQ DETECTION & DUT IRQ COUNTING
		if(intc_check.intc_irq == 1 && prev_irq == 0)
			begin
				`uvm_info("SCOREBOARD_CHECKER","POSEDGE DETECTED IN THE IRQ",UVM_NONE)
				irq_count++;
				prev_irq = intc_check.intc_irq;
			end
		else if(intc_check.intc_irq == 0 && prev_irq == 1)
			prev_irq = 0;


		// IRQ OF REFERENCE MODEL AND DUT COMPARING
		if(axi_reg_block['h04] == 0)
			begin
				if(irq_count == ref_irq_count)
					`uvm_info("SCOREBOARD_CHECKER",$sformatf("IRQ COUNT MATCHED------------DUT_IRQ_COUNT:%0d		REF_MODEL_IRQ_COUNT:%0d",irq_count,ref_irq_count),UVM_NONE)
				else
					`uvm_info("SCOREBOARD_CHECKER",$sformatf("IRQ COUNT DID NOT MATCH------------DUT_IRQ_COUNT:%0d		REF_MODEL_IRQ_COUNT:%0d",irq_count,ref_irq_count),UVM_NONE)
			end
	
	endtask

	//===============================================================================================================================//





































/*  
	task scoreboard :: total_compare(axi_4_lite_seq_item axi_data);
		int IVR, IPR, IAR, IER, IVAR, IMR, SIE, CIE;
		if(axi_data.trans_type == WRITE)
			begin
				assoc_reg_block[axi_data.axi_awaddr] = axi_data.axi_wdata;
			end
		if(axi_data.trans_type == READ)
			begin
				assoc_reg_block[axi_data.axi_araddr] = axi_data.axi_rdata;
			end
			
		if(axi_data.axi_araddr == 'h04)
			begin
				intrs++;
				IVR = assoc_reg_block['h18];
				IPR = assoc_reg_block['h04];
				if(test_type == opt_reg_test)
					begin
						if(assoc_reg_block.exists('h10))
							begin
								SIE = assoc_reg_block['h10];
								IER = SIE;
							end
						if(assoc_reg_block.exists('h14))
							begin
								CIE = assoc_reg_block['h14];
								IER = IER | CIE;
								IER = IER ^ CIE;
							end
					end
				else
					IER = assoc_reg_block['h08];
				
				if(assoc_reg_block.exists('h0C)==1'b1)
					IAR = assoc_reg_block['h0C];

				if(assoc_reg_block.exists('h20))
					IMR = assoc_reg_block['h20];

				IVAR = 'h100 + 'h4*(IVR);
			
				if( (assoc_reg_block[IVAR] == intc_data.intc_intr_addr) && ( (IAR[IVR] == 1'b1) || IMR[IVR] == 1'b1) && (IPR[IVR] == 0) )
					begin
						if(IER[IVR] == 1)
							`uvm_info("SCOREBOARD","\n\n==================================================================================== INTERRUPT REQUEST SUCCESSFUL\n",UVM_NONE)
						else
							`uvm_error("SCOREBOARD","\n\n==================================================================================== [INVALID]MASKED INTERRUPT REQUEST\n")
					end
				else if(IVR == 'd31)
					`uvm_warning("SCOREBOARD","\n\n==================================================================================== INTERRUPT & INTRRUPT ADDRESS IS OUT OF BOUND\n")
				else
					begin
						`uvm_error("SCOREBOARD","\n\n==================================================================================== INTERRUPT REQUEST FAILED\n")
					end
			end
			`uvm_info("SCOREBOARD",$sformatf("INTRS RESPONSE COUNT:%0d",intrs),UVM_NONE)
			
			
	endtask
	*/
