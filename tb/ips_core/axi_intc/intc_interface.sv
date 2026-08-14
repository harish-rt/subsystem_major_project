interface intc_intf(input bit intc_procss_clk, logic intc_procss_rst);

    `include "uvm_macros.svh"
    import uvm_pkg :: *;


    logic [31:0]intc_intr;                                
    logic intc_irq;                      
    logic [1:0]intc_procss_acklg;             
    logic [31:0]intc_intr_addr;                 
    logic intc_irq_in;                   
    logic [31:0]intc_intr_addr_in;              
    logic [1:0]intc_procss_ack_out;            

    clocking intc_interface_driver_cb @(posedge intc_procss_clk);
        default input #1 output #0;
        output intc_intr;                                
        input  intc_irq;                      
        output intc_procss_acklg;             
        input  intc_intr_addr;                 
        output intc_irq_in;                   
        output intc_intr_addr_in;              
        input intc_procss_ack_out;            
    endclocking

    clocking intc_interface_monitor_cb @(posedge intc_procss_clk);
        default input #1 output #0;
        input intc_intr;                                
        input intc_irq;                      
        input intc_procss_acklg;             
        input intc_intr_addr;                 
        input intc_irq_in;                   
        input intc_intr_addr_in;              
        input intc_procss_ack_out;            
    endclocking

    modport intc_drv_mod(clocking intc_interface_driver_cb, input intc_procss_rst);
    modport intc_mon_mod(clocking intc_interface_monitor_cb, input intc_procss_rst);

	property irq;
		@(posedge intc_procss_clk) intc_irq |-> ##[0:$] (intc_procss_acklg==2'b01) ##[1:$] (!intc_irq) ##0 intc_procss_acklg==2'b01;
	endproperty

	INTR_IRQ: assert property(irq);
endinterface  
