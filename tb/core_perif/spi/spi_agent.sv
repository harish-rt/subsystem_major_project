class spi_agent extends uvm_agent;
    `uvm_component_utils(spi_agent)
    `NEW_COMP

    spi_sequencer  sqr;
    spi_driver     drv;
    spi_monitor    mon;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = spi_sequencer    ::type_id::create("sqr",this);
        drv = spi_driver       ::type_id::create("drv",this);
        mon = spi_monitor      ::type_id::create("mon",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //connect mon.intf = obj.intf
    endfunction
endclass : spi_agent
