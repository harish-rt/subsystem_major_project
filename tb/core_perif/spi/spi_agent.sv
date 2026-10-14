class spi_agent extends uvm_agent;
    `uvm_component_utils(spi_agent)
    `NEW_COMP

    spi_sequencer  sqr;
    spi_driver     drv;
    spi_monitor    mon;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("spi_agent::build", "inside_spi_agent", UVM_MEDIUM)
    	if(!uvm_config_db#(virtual spi_intf.SPI_MON)::get(this,"","SPI_MON",spi_if))begin
            `uvm_fatal(get_full_name(),"spi_intf get Failure in SPI Agent")
        end
        sqr = spi_sequencer    ::type_id::create("sqr",this);
        drv = spi_driver       ::type_id::create("drv",this);
        mon = spi_monitor      ::type_id::create("mon",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        //connect mon.intf = obj.intf
        mon.spi_if  = spi_if;
        drv.spi_if  = spi_if;
    endfunction
endclass : spi_agent
