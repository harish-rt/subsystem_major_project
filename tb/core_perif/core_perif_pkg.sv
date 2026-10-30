package core_perif_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "../common/config_tb.sv"
    // Import the component VIP packages
    import uart_pkg::*;
    import spi_pkg::*;
    import gpio_pkg::*;
    //import timer_pkg::*;

    //`include "uart/uart_slave_responder_agent.sv"
    //`include "spi/spi_slave_responder_agent.sv"
    //`include "gpio/gpio_slave_responder_agent.sv"

    // Include subsystem-level classes

    `include "parameters.sv"
    `include "core_perif_lite_seq_item.sv"
    `include "core_perif_monitor.sv"
    `include "core_perif_env.sv"
endpackage : core_perif_pkg
