package core_perif_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    // Import the component VIP packages
    import uart_pkg::*;
    import spi_pkg::*;
    import gpio_pkg::*;
    import timer_pkg::*;

    // Include subsystem-level classes
    `include "core_perif_env_cfg.sv"
    `include "core_perif_env.sv"
    `include "core_perif_virtual_sequencer.sv"
    `include "core_perif_base_vseq.sv"
endpackage : core_perif_pkg
