interface intc_intf(input bit intc_procss_clk, logic intc_procss_rst);

    logic [31:0]    intc_intr;                                
    logic           intc_irq;                      

    clocking intc_interface_driver_cb @(posedge intc_procss_clk);
        default input #1 output #0;
        output intc_intr;                                
        input  intc_irq;                      
    endclocking

    clocking intc_interface_monitor_cb @(posedge intc_procss_clk);
        default input #1 output #0;
        input intc_intr;                                
        input intc_irq;                      
    endclocking

    modport intc_drv_mod(clocking intc_interface_driver_cb, input intc_procss_rst);
    modport intc_mon_mod(clocking intc_interface_monitor_cb, input intc_procss_rst);

endinterface

/*
	property irq;
		@(posedge intc_procss_clk) intc_irq |-> ##[0:$] (intc_procss_acklg==2'b01) ##[1:$] (!intc_irq) ##0 intc_procss_acklg==2'b01;
	endproperty

	INTR_IRQ: assert property(irq);
*/
