interface lite_intc_interface(input bit aclk, logic areset_n);

    logic [8:0] awaddr;
    logic awvalid;
    logic awready;
    logic [31:0] wdata;
    logic [3:0] wstrb;
    logic wvalid;
    logic wready;
    logic [1:0] bresp;
    logic bvalid;
    logic bready;
    logic [8:0] araddr;
    logic arvalid;
    logic arready;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic rvalid;
    logic rready;

    //logic [31:0] dut_isr, dut_iar, dut_ier, dut_imr;

//driver_clocking block//

    clocking lite_intc_driver_cb@(posedge aclk);
        default input #1 output #0;
    
        output awaddr;
        output awvalid;      
        input  awready;      
        output wdata;
        output wstrb;
        output wvalid;
        input  wready;
        output bready;
        input  bresp;
        input  bvalid;
        output araddr;  
        output arvalid;      
        input  arready;      
        input  rdata;   
        input  rresp;  
        input  rvalid;       
        output rready;
    endclocking 

//monitor clocking block//
    clocking lite_intc_monitor_cb@(posedge aclk);
        default input #1 output #0;
    
        input awaddr;
        input awvalid;      
        input awready;      
        input wdata;
        input wstrb;
        input wvalid;
        input wready;
        input bready;
        input bresp;
        input bvalid;
        input araddr;  
        input arvalid;      
        input arready;      
        input rdata;   
        input rresp;  
        input rvalid;       
        input rready;
    endclocking

    modport lite_intc_driver_modport    (clocking lite_intc_driver_cb, output areset_n);
    modport lite_intc_monitor_modport   (clocking lite_intc_monitor_cb, input areset_n);

endinterface

/*
	property aw_addr;
		@(posedge aclk) awvalid |=> $stable(awaddr) ##[1:$] awready ##1 (!awvalid); 
	endproperty

	property ar_addr;
		@(posedge aclk) arvalid |=> $stable(araddr) ##[1:$] arready ##1 (!arvalid); 
	endproperty
	
	property w_data;
		@(posedge aclk) wvalid |=> $stable(wdata) ##[1:$] wready ##1 (!wvalid); 
	endproperty

	property r_data;
		@(posedge aclk) rvalid |=> $stable(rdata) && $stable(rresp) ##[1:$] rready ##1 (!rvalid); 
	endproperty

	property b_resp;
		@(posedge aclk) bvalid |=> $stable(bresp) ##[1:$](bready) ##1 (!bready);
	endproperty


/*
	AWVALID:assert property (aw_addr)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================AWVALID ASSERTION PASSED\n",$time),UVM_MEDIUM)
	ARVALID:assert property (ar_addr)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================ARVALID ASSERTION PASSED\n",$time),UVM_MEDIUM)
	WVALID:assert property (w_data)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================WVALID  ASSERTION PASSED\n",$time),UVM_MEDIUM)
	RVALID:assert property (r_data)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================RVALID  ASSERTION PASSED\n",$time),UVM_MEDIUM)
	BVALID:assert property (b_resp)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================BVALID  ASSERTION PASSED\n",$time),UVM_MEDIUM)
	
	CG_AWVALID:cover property (aw_addr);*/
