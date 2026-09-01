package soc_addr_pkg;
    parameter bit [31:0] CDMA_BASE        = 32'h7000_0000;
    parameter bit [31:0] INTC_BASE        = 32'h7000_1000;
    parameter bit [31:0] BRAM_BASE        = 32'h7100_0000;
    parameter bit [31:0] LITE_MEM_BASE    = 32'h8000_0000;
    parameter bit [31:0] CORE_PERIF_BASE  = 32'hA000_0000;

    // Core Peripherals Base Addresses (0xA000_0000 - 0xBFFF_FFFF)
    parameter bit [31:0] IRQ_BASE   = 32'hA000_0000;
    parameter bit [31:0] TIMER_BASE = 32'hA100_0000;
    parameter bit [31:0] UART_BASE  = 32'hA200_0000;
    parameter bit [31:0] SPI_BASE   = 32'hA300_0000;
    parameter bit [31:0] GPIO_BASE  = 32'hA400_0000;
endpackage : soc_addr_pkg
