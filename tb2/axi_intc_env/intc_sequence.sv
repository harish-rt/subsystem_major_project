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

/******************************* BASE SEQUENCE & TEST 1 *******************************/
typedef intc_sequencer intc_seqr;
class intc_sequence extends uvm_sequence #(intc_seq_item);
   
    `uvm_object_utils(intc_sequence)
		`uvm_declare_p_sequencer(intc_seqr)

		intc_seq_item	dummy_item;
		int 					count = 0;
   
    extern function new(string name = "intc_sequence");
    
    extern task body();

endclass : intc_sequence

  function intc_sequence :: new(string name = "intc_sequence");
  	super.new(name);
  endfunction    
   
  task intc_sequence :: body();

		req 				= intc_seq_item :: type_id :: create("req");
		req.nested 	= nested_mode; 
		
		start_item(req);
    assert (req.randomize() with { $countones(intc_intr) == total_intr;seq_type == INTR_INPUT;});
    finish_item(req);

		if(nested_mode == 1'b1)
			begin
				count		=	(req.intc_intr) | (nest_intr);
				count		= $countones(count);
			end
		else
			count			= total_intr;

		repeat(count)
			begin			
				p_sequencer.seqr_fifo_h.get(dummy_item);

				start_item(req);
    		assert (req.randomize() with { intc_procss_acklg == 2'b01;seq_type == ACK;});
    		finish_item(req);

				p_sequencer.seqr_fifo_h.get(dummy_item);

				start_item(req);
    		assert (req.randomize() with { intc_procss_acklg == 2'b11;seq_type == ACK;});
    		finish_item(req);
			end

  endtask :body









/******************************* NESTED TEST SEQUENCE *******************************

class nest_intc_sequence extends uvm_sequence #(intc_seq_item);
	`uvm_object_utils(nest_intc_sequence)
	
	function new(string name = "nest_intc_sequence");
		super.new(name);
	endfunction

	task body();
    
		req = intc_seq_item :: type_id :: create("req");
		req.nested = 1'b1;
 		start_item(req);
   	assert (req.randomize() with {intc_intr == 32'hFFFF_0000;});
   	`uvm_info("sq_item :intc_sequence",$sformatf("req.intc_intr= %0h",req.intc_intr),UVM_LOW)
   	finish_item(req);
	endtask

endclass

*/























