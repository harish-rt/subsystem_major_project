class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)
    `NEW_COMP

    uart_sequencer  sqr;
    uart_driver     drv;
    uart_monitor    mon;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uart_sequencer    ::type_id::create("sqr",this);
        drv = uart_driver       ::type_id::create("drv",this);
        mon = uart_monitor      ::type_id::create("mon",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
endclass
