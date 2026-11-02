class core_perif_env extends uvm_env;
    `uvm_component_utils(core_perif_env)
    //`NEW_COMP

    virtual axi4_lite_tb_intf  cp_if;

    function new(string name="",uvm_component parent);
        super.new(name,parent);
    	if(!uvm_config_db#(virtual axi4_lite_tb_intf)::get(this,"","CP_MON",cp_if))begin
            `uvm_fatal("CP_ENV", "Virtual interface not found for core peripherals lite monitor")
        end
    endfunction

    uart_slave_agent        uart_agt;
    spi_slave_agent         spi_agt;
    gpio_slave_agent        gpio_agt;
    core_perif_monitor      lite_mon;
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        lite_mon  = core_perif_monitor::type_id::create("lite_mon", this);
        uart_agt  = uart_slave_agent  ::type_id::create("uart_agt", this);
        spi_agt   = spi_slave_agent   ::type_id::create("spi_agt", this);
        gpio_agt  = gpio_slave_agent  ::type_id::create("gpio_agt", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        lite_mon.cp_mon_intf = cp_if;
    endfunction
endclass : core_perif_env
