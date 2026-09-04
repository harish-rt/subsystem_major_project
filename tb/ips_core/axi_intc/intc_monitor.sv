class intc_monitor extends uvm_monitor;
    `uvm_component_utils(intc_monitor)
    `NEW_COMP
    
    uvm_event                           irq_event;
    intc_seq_item                       pkt;
    intc_config_obj                     cfg;

    virtual intc_intf                   mon_intc_intf;
    uvm_analysis_port #(intc_seq_item)  intc_ap;
    uvm_analysis_port #(bit)            resp_ap;

    bit                          [31:0] prev_intr;
    bit                                 prev_irq;

    extern function void build_phase    (uvm_phase phase);
    extern task main_phase              (uvm_phase phase);

endclass : intc_monitor

function void intc_monitor::build_phase(uvm_phase phase);
    `uvm_info("intc_monitor", "build_phase started", UVM_LOW)
    super.build_phase(phase);
    
    intc_ap = new("intc_ap",this);
    resp_ap = new("resp_ap",this);

    if (!uvm_config_db#(intc_config_obj)::get(this,"","intc_config_obj",cfg))
        `uvm_fatal("INTC_MON", "Failed to get intc_config_obj from config DB")

    `uvm_info("intc_monitor", "build_phase ended", UVM_LOW)
endfunction 

task intc_monitor::main_phase(uvm_phase phase);       
    // Wait for reset de-assertion
    if (mon_intc_intf.intc_procss_rst !== 0)
        @(negedge mon_intc_intf.intc_procss_rst);
    `uvm_info("intc_monitor", "main_phase started after reset", UVM_LOW)
    
    @(mon_intc_intf.intc_interface_monitor_cb);
    prev_intr = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
    prev_irq  = mon_intc_intf.intc_interface_monitor_cb.intc_irq;

    forever begin
        @(mon_intc_intf.intc_interface_monitor_cb);
        if(mon_intc_intf.intc_interface_monitor_cb.intc_irq === 1'b1 && prev_irq === 1'b0)begin
            resp_ap.write(1'b1);
            `uvm_info("INTC_MON","Hardware IRQ Asserted -> Triggering event",UVM_LOW)
        end

        if(mon_intc_intf.intc_interface_monitor_cb.intc_irq === 1'b0 && prev_irq === 1'b1)begin
            `uvm_info("INTC_MON","Hardware IRQ De-asserted",UVM_LOW)
        end

        if ((mon_intc_intf.intc_interface_monitor_cb.intc_intr != prev_intr) ||
            (mon_intc_intf.intc_interface_monitor_cb.intc_irq != prev_irq)) begin
            
            pkt = intc_seq_item::type_id::create("pkt");
            pkt.intc_intr = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
            pkt.intc_irq  = mon_intc_intf.intc_interface_monitor_cb.intc_irq;

            intc_ap.write(pkt);
            `uvm_info("intc_monitor_pkt", pkt.sprint(), UVM_MEDIUM)            

            prev_intr = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
            prev_irq  = mon_intc_intf.intc_interface_monitor_cb.intc_irq;
        end
    end
endtask : main_phase


















/*
class intc_monitor extends uvm_monitor;
    `uvm_component_utils(intc_monitor)
    `NEW_COMP
    
    uvm_event                           irq_event;
	intc_seq_item 					    pkt;

    bit                          [31:0] prev_intr;
    bit                                 prev_irq;

    virtual intc_intf                   mon_intc_intf;
<<<<<<< HEAD
	uvm_analysis_port #(intc_seq_item) 	mon_intc_ap;
=======
	uvm_analysis_port #(intc_seq_item) 	intc_ap;
>>>>>>> 169e3413009a18aaf60c1496503e57e630c46401

    extern function void build_phase	(uvm_phase phase);
    extern task main_phase				(uvm_phase phase);

endclass : intc_monitor

function void intc_monitor :: build_phase (uvm_phase phase);
    `uvm_info ("intc_monitor :: build_phase started ", "",UVM_LOW)
    super.build_phase(phase);
    
<<<<<<< HEAD
    mon_intc_ap = new("mon_intc_ap", this);
=======
    intc_ap = new("intc_ap", this);
>>>>>>> 169e3413009a18aaf60c1496503e57e630c46401
    `uvm_info ("intc_monitor  :: build_phase ended ", "",UVM_LOW)
endfunction 

task intc_monitor :: main_phase(uvm_phase phase);		
	wait(mon_intc_intf.intc_procss_rst==0);
    `uvm_info ("intc_monitor :: main_phase started ", "",UVM_LOW)
    
    forever begin
        `uvm_info("INTC_MON", "Before Triggering irq event", UVM_LOW)
        @(posedge mon_intc_intf.intc_interface_monitor_cb.intc_irq);
        `uvm_info("INTC_MON", "Hardware IRQ Asserted -> Triggering event", UVM_LOW)
        irq_event.trigger();

        //@(mon_intc_intf.intc_interface_monitor_cb);
        if((mon_intc_intf.intc_interface_monitor_cb.intc_intr != prev_intr) ||
            (mon_intc_intf.intc_interface_monitor_cb.intc_irq != prev_irq)) begin
	        
            pkt = intc_seq_item::type_id::create("pkt");

            pkt.intc_intr       = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
            pkt.intc_irq        = mon_intc_intf.intc_interface_monitor_cb.intc_irq;

<<<<<<< HEAD
            mon_intc_ap.write(pkt);
=======
            intc_ap.write(pkt);
>>>>>>> 169e3413009a18aaf60c1496503e57e630c46401
            `uvm_info("intc_monitor_pkt",pkt.sprint(),UVM_MEDIUM)            

            prev_intr   = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
            prev_irq    = mon_intc_intf.intc_interface_monitor_cb.intc_irq;
        end
        @(negedge mon_intc_intf.intc_interface_monitor_cb.intc_irq);
    end
    `uvm_info ("mon_intc :: main_phase ended ", "",UVM_LOW) 
endtask : main_phase




/*
class intc_monitor extends uvm_monitor;
    `uvm_component_utils(intc_monitor)
    `NEW_COMP
    
    virtual intc_intf 			            mon_intc_intf;
  
	uvm_analysis_port #(intc_seq_item) 	    intc_ap;
    uvm_analysis_port #(intc_seq_item) 	    mon_seqr_ap;

	intc_seq_item 						    tx_h;
	intc_seq_item						    dummy_seq;

	intc_config_obj 						cfg;

    extern function void build_phase		(uvm_phase phase);
    extern function void connect_phase 	    (uvm_phase phase);
    extern task main_phase					(uvm_phase phase);
    extern task collections					();
	extern task irq_capture					();
endclass 
      
    function void intc_monitor :: build_phase (uvm_phase phase);
        `uvm_info ("intc_monitor :: build_phase started  ", "",UVM_LOW)
        super.build_phase(phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",cfg))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")
        
        intc_ap = new("intc_ap", this);
		mon_seqr_ap = new("mon_seqr_ap", this);
        `uvm_info ("intc_monitor  :: build_phase ended ", "",UVM_LOW)
    endfunction 
   
    function void intc_monitor :: connect_phase (uvm_phase phase);
        `uvm_info ("intc_monitor :: connect_phase started  ", "",UVM_LOW)
        super.connect_phase(phase);
        `uvm_info ("intc_monitor  :: connect_phase ended ", "",UVM_LOW)
    endfunction

    task intc_monitor :: main_phase(uvm_phase phase);
		
	    wait(mon_intc_intf.intc_procss_rst==0)
        `uvm_info ("intc_monitor :: main_phase started  ", "",UVM_LOW)
    
		tx_h = intc_seq_item :: type_id :: create("tx_h");
		fork    
			forever
		        collections();
			forever
				irq_capture();
		join
		
        `uvm_info ("mon_intc :: main_phase ended ", "",UVM_LOW) 
    endtask


  task intc_monitor :: collections();
  	
    @(mon_intc_intf.intc_interface_monitor_cb);
		@(  mon_intc_intf.intc_procss_rst,
		    mon_intc_intf.intc_interface_monitor_cb.intc_intr,
			mon_intc_intf.intc_interface_monitor_cb.intc_irq);
		
        tx_h.intc_intr_addr     = mon_intc_intf.intc_interface_monitor_cb.intc_intr_addr;
        tx_h.intc_intr          = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
        tx_h.intc_irq           = mon_intc_intf.intc_interface_monitor_cb.intc_irq; 

<<<<<<< HEAD
        mon_intc_ap.write(tx_h);
=======
        intc_ap.write(tx_h);
>>>>>>> 169e3413009a18aaf60c1496503e57e630c46401

  endtask
	
	task intc_monitor :: irq_capture();
		@(mon_intc_intf.intc_interface_monitor_cb);
		@(posedge mon_intc_intf.intc_interface_monitor_cb.intc_irq)
			begin
				mon_seqr_ap.write(dummy_seq);
			end

		@(mon_intc_intf.intc_interface_monitor_cb);	
		@(negedge mon_intc_intf.intc_interface_monitor_cb.intc_irq)
			begin
				mon_seqr_ap.write(dummy_seq);
			end

	endtask
*/
