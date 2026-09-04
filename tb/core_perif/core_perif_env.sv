class core_perif_env extends uvm_env;
    `uvm_component_utils(core_perif_env)
    `NEW_COMP

    uart_agent      uart_agt;
    spi_agent       spi_agt;
    gpio_agent      gpio_agt;
    timer_agent     timer_agt;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uart_agt  = uart_agent  ::type_id::create("uart_agt", this);
        spi_agt   = spi_agent   ::type_id::create("spi_agt", this);
        gpio_agt  = gpio_agent  ::type_id::create("gpio_agt", this);
        timer_agt = timer_agent ::type_id::create("timer_agt", this);
    endfunction
endclass : core_perif_env
