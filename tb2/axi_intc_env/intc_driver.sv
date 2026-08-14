/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_driver.sv                                         */
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
class intc_driver extends uvm_driver #(intc_seq_item,intc_seq_item);
    
    `uvm_component_utils(intc_driver)
    
		intc_config_obj 	cfg;
		int 				no_of_intrs,i=0;

    virtual intc_intf.intc_drv_mod intc_drv_intf;
		
    extern function new									(string name  = "intc_driver", uvm_component parent);
    extern function void build_phase 		(uvm_phase phase);
    extern function void connect_phase 	(uvm_phase phase);
    extern task run_phase								(uvm_phase phase);
    extern task reset_phase							(uvm_phase phase);
    extern task intr_send								(intc_seq_item req);

endclass :intc_driver

  function intc_driver :: new(string name = "intc_driver", uvm_component parent);
    
    super.new(name, parent);
  
  endfunction 
      
  function void intc_driver :: build_phase(uvm_phase phase);

    super.build_phase(phase);
    `uvm_info ("intc_driver :: build_phase", "",UVM_MEDIUM)
  	
  endfunction
    
  function void intc_driver :: connect_phase (uvm_phase phase);

    super.connect_phase(phase);
    `uvm_info ("intc_driver :: connect_phase ", "",UVM_MEDIUM)
  
  endfunction 

  task intc_driver :: run_phase(uvm_phase phase);
	
		wait(intc_drv_intf.intc_procss_rst==0)
    `uvm_info ("intc_driver :: run_phase", "",UVM_LOW)
    forever begin
      seq_item_port.get_next_item(req);

			fork
      	intr_send(req);
			join
 	
      seq_item_port.item_done();
    end

  endtask                                                                        

  task intc_driver ::reset_phase(uvm_phase phase);

    intc_drv_intf.intc_interface_driver_cb.intc_intr         <= 0;
    intc_drv_intf.intc_interface_driver_cb.intc_procss_acklg <= 0;
		
    `uvm_info ("intc_driver  :: reset_phase", "",UVM_LOW)

  endtask

  task intc_driver :: intr_send(intc_seq_item req);

			@(intc_drv_intf.intc_interface_driver_cb);
			if(req.seq_type == INTR_INPUT)
				begin
					intc_drv_intf.intc_interface_driver_cb.intc_intr 	<= req.intc_intr;
				end
			if(req.nested == 1 && i == (total_intr)/2)
				begin
					`uvm_info("INTC_DRIVER","/-------------------------NESTED-------------------------/",UVM_LOW)
					intc_drv_intf.intc_interface_driver_cb.intc_intr 	<= nest_intr;
				end
			if(req.seq_type == ACK)
				begin
					intc_drv_intf.intc_interface_driver_cb.intc_procss_acklg 	<= req.intc_procss_acklg;
				end	
			i++;
  endtask 
	

	/*

	task intc_driver :: intr_send(intc_seq_item req);
			
			int i;
			no_of_intrs = $countones(req.intc_intr);
			$display("/-----------------------------------NO OF INTERRUPTS:%0d",no_of_intrs);

			@(intc_drv_intf.intc_interface_driver_cb);
			intc_drv_intf.intc_interface_driver_cb.intc_intr 					<= req.intc_intr;
			intc_drv_intf.intc_interface_driver_cb.intc_procss_acklg 	<= 2'b11;
     	
			//for(int i=0;i<(no_of_intrs);i++)
			while(complete!=1)
				begin				
					if(req.nested == 1 && i == (no_of_intrs)/2 )
						begin
							$display("/-------------------------NESTED-------------------------/");
							req.intc_intr																			 = nest_intr;
							intc_drv_intf.intc_interface_driver_cb.intc_intr 	<= nest_intr;
							no_of_intrs	= $countones(nest_intr);
							wait(intc_drv_intf.intc_interface_driver_cb.intc_irq);
						end						
					else
						begin
							wait(intc_drv_intf.intc_interface_driver_cb.intc_irq);
						end
					
					ev1.trigger();
					@(intc_drv_intf.intc_interface_driver_cb);
					intc_drv_intf.intc_interface_driver_cb.intc_procss_acklg 	<= 2'b01;
					
					wait(!intc_drv_intf.intc_interface_driver_cb.intc_irq)
					intc_drv_intf.intc_interface_driver_cb.intc_procss_acklg 	<= 2'b11;
					@(intc_drv_intf.intc_interface_driver_cb);
					i++;
				end
			$display("================================= OUT OF DRIVER LOOP =================================");   
  endtask 
	*/
