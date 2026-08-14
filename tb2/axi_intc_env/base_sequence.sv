/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_sequence.sv                                       */
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

/******************************* BASE SEQUENCE *******************************/

class base_sequence extends uvm_sequence #(axi_4_lite_seq_item);
   
    `uvm_object_utils(base_sequence)

		int reg_block [$], size;
   
    extern function new(string name = "base_sequence");
    
    extern task body();

endclass : base_sequence

	function base_sequence :: new(string name = "base_sequence");
		super.new(name);
  endfunction
	
	task base_sequence :: body();
   	
		for(int i=0;i<42;i++)
			begin	
				if(i == 10)				reg_block.push_back('h100);
				else if(i>0)			reg_block.push_back(reg_block[i-1]+ 4'h4);
				else							reg_block[i] = 4'h0;
			end

		size = $size(reg_block);
		set_response_queue_depth(500);
		
		repeat(size)
			begin
				
		    req 						= axi_4_lite_seq_item :: type_id :: create("req");
				req.axi_awaddr 	= reg_block.pop_front();
				req.trans_type 	= WRITE;
				//------------------------------WRITE
  	  	start_item(req);
  		  assert (req.randomize());
				finish_item(req);

				//------------------------------READ
				req.axi_araddr	= req.axi_awaddr; 
				req.trans_type 	= READ;

  	  	start_item(req);
  		  assert (req.randomize());
				finish_item(req);

				if(req.axi_araddr == 9'h00 || req.axi_araddr == 9'h18 || req.axi_araddr ==  9'h04)
					get_response(req);

	    	`uvm_info("sq_item :base_sequence",$sformatf("req.axi_wdata= %0h",req.axi_wdata),UVM_LOW)
			end

			//INVALID ADRESSS WRITE & READ
			begin
				//------------------------------WRITE
		    req 						= axi_4_lite_seq_item :: type_id :: create("req");
				req.axi_awaddr 	= 9'h25;
				req.trans_type 	= WRITE;

  	  	start_item(req);
  		  assert (req.randomize());
				finish_item(req);
				
				//------------------------------WRITE
				req.axi_araddr 	= 9'h25;
				req.trans_type 	= READ;

  	  	start_item(req);
  		  assert (req.randomize());
				finish_item(req);
				
	    	`uvm_info("sq_item :base_sequence",$sformatf("req.axi_wdata= %0h",req.axi_wdata),UVM_LOW)
			end
			
  endtask :body


/******************************* TEST SEQUENCE 1 *******************************/
typedef axi_4_lite_seqr seqr;

class reg_config_seq extends uvm_sequence #(axi_4_lite_seq_item);

	`uvm_object_utils(reg_config_seq)
	`uvm_declare_p_sequencer(seqr)

	axi_4_lite_seq_item  	dummy_item;

	int 									ivar_block[$];
	int 									iar_data, no_of_actv_ier, count = 0;

	function new(string name = "reg_config_seq");
		super.new(name);
	endfunction

	extern task ivar_reg	();
	extern task mer_reg		(int mer_data=32'h03);
	extern task imr_reg 	();
	extern task ier_reg		();
	extern task sie_reg		();
	extern task cie_reg		();
	extern task ivr_reg		(int mer_data=32'h02);
	extern task iar_reg		();
	extern task ipr_reg		();
	extern task body	 		();

endclass
	
	task reg_config_seq :: body();
		
		if( (test_type == fast)||(test_type == nested_fast) )
			imr_reg();							//------------------------------IMR

		if(test_type == opt_reg_test)
			sie_reg();							//------------------------------IER
		else
			ier_reg();							//------------------------------SIE
		
		do 
			begin
				mer_reg();						//------------------------------MER

				begin
					p_sequencer.seqr_fifo_h.get(dummy_item);					
				end
				
				ivr_reg();						//------------------------------IVR & MER
				get_response(req);

				iar_data = 32'd0;
				iar_data[req.axi_rdata] = 1'b1;
				
				if( (imr_data[req.axi_rdata] == 0) )
					iar_reg();					//------------------------------IAR

				if(count == no_of_actv_ier && test_type == opt_reg_test)
					cie_reg();					//------------------------------CIE
				
				ipr_reg();						//------------------------------IPR	
				get_response(req);
				
				count++;
			end
			while(req.axi_rdata!=0);
			$display("=================================OUT OF THE SEQUENCE=================================");
	endtask

class ivar_config_seq extends reg_config_seq;
		
	`uvm_object_utils(ivar_config_seq)

	function new(string name = "ivar_config_seq");
		super.new(name);
	endfunction
	
	task body();
		ivar_reg();								//------------------------------IVAR
	endtask
endclass	
	






	
	
	
	/******************************* ALL TASKS *******************************/

	task reg_config_seq :: ivar_reg();											//------------------------------IVAR
		int q_size, addr;
		
		for(int i=0;i<32;i++)
			begin	
				if(i == 0)				ivar_block.push_back('h100);
				else							ivar_block.push_back(ivar_block[i-1]+ 4'h4);
			end

		q_size = $size(ivar_block);

		repeat(q_size)
			begin
				req 						= axi_4_lite_seq_item :: type_id :: create("req");
				req.axi_awaddr 	= ivar_block.pop_front();
				req.trans_type 	= WRITE;
		
				start_item(req);
				assert(req.randomize with {axi_wdata == addr;register == IVAR;});
				finish_item(req);
				addr = addr + 4;
			end

	endtask

	task reg_config_seq :: mer_reg(int mer_data=32'h03);		//------------------------------MER
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_awaddr 	= 9'h1C;
			req.trans_type 	= WRITE;
		
			start_item(req);
			assert(req.randomize with {req.axi_wdata == mer_data;register == MER;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: imr_reg();		//------------------------------IMR
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_awaddr 	= 9'h20;
			req.trans_type 	= WRITE;
		
			start_item(req);
			assert(req.randomize with {req.axi_wdata == imr_data;register == IMR;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: ier_reg();		//------------------------------IER
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_awaddr 	= 9'h08;
			req.trans_type 	= WRITE;
		
			start_item(req);
			assert(req.randomize with {req.axi_wdata == ier_data;register == IER;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: sie_reg();		//------------------------------SIE
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_awaddr 	= 9'h10;
			req.trans_type 	= WRITE;
			no_of_actv_ier	= $countones(ier_data)/2;
			
			start_item(req);
			assert(req.randomize() with {req.axi_wdata == ier_data;register == SIE;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: cie_reg();		//------------------------------CIE
		int cie_data;
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_awaddr 	= 9'h14;
			req.trans_type 	= WRITE;
			cie_data				= $urandom;

			start_item(req);
			assert(req.randomize() with {req.axi_wdata == cie_data;register == CIE;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: ivr_reg(int mer_data=32'b10);		//------------------------------IVR & MER
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_awaddr 	= 9'h1C;
			req.axi_araddr 	= 9'h18;
			req.trans_type 	= READ_WRITE;
		
			start_item(req);
			assert(req.randomize() with {req.axi_wdata==mer_data;register == IVR;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: iar_reg();		//------------------------------IAR
		begin
			req.axi_awaddr 	= 9'h0C;
			req.trans_type 	= WRITE;

			start_item(req);
			assert(req.randomize with {req.axi_wdata == iar_data;register == IAR;});
			finish_item(req);
		end
	endtask

	task reg_config_seq :: ipr_reg();		//------------------------------IPR
		begin
			req 						= axi_4_lite_seq_item :: type_id :: create("req");
			req.axi_araddr 	= 9'h04;
			req.trans_type 	= READ;
		
			start_item(req);
			assert(req.randomize() with {register == IPR;});
			finish_item(req);
		end
	endtask

	
/*
	class error_seq extends reg_config_seq;
		
		`uvm_object_utils(error_seq)

		function new(string name = "error_seq");
			super.new(name);
		endfunction

		task body();
			ev1 					= uvm_event_pool::get_global("ev1_irq");
			ev2 					= uvm_event_pool::get_global("ev2_ivar");
			
			ivar_reg();
			//ISR
			begin
				req 						= axi_4_lite_seq_item :: type_id :: create("req");
				req.axi_awaddr 	= 9'h00;
				req.trans_type 	= WRITE;
		
				start_item(req);
				assert(req.randomize with {register == ISR;});
				finish_item(req);
			end

			ier_reg();
			mer_reg(2'b11);
			ev1.wait_ptrigger();
			ivr_reg(2'b11);
			get_response(req);

			iar_data = 32'd0;
			iar_data[req.axi_rdata] = 1'b1;

			iar_reg();
				
			ipr_reg();
			complete = 1;

		endtask
	endclass
*/
