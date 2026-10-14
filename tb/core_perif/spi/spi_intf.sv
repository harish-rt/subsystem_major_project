interface spi_slave_if(input logic clk, rst_n);
    logic        req_valid;
    logic        req_ready;
    logic        ack;
    logic        cs_n;
    logic        sclk;
    logic        mosi;
    logic        miso;
    logic [7:0]  req_data;
    logic [7:0]  rsp_data;
endinterface

/*
interface spi_intf ();

    logic spi_clk_o;
    logic spi_cs_o;
    logic spi_mosi_o;
    logic spi_miso_i;
    logic intr_o;

    clocking spi_drv_cb @(posedge clk_i);
        default input #0 output #0;

        input   spi_clk_o;
        input   spi_cs_o;
        input   spi_mosi_o;
        output  spi_miso_i;
        input   intr_o;
    endclocking : spi_drv_cb

    clocking spi_mon_cb @(posedge clk_i);
        default input #0 output #0;

        input   spi_clk_o;
        input   spi_cs_o;
        input   spi_mosi_o;
        input   spi_miso_i;
        input   intr_o;
    endclocking : spi_mon_cb

    modport SPI_DRV (clocking spi_drv_cb, input clk_i, input rst_n_i);
    modport SPI_MON (clocking spi_mon_cb, input clk_i, input rst_n_i);

endinterface : spi_if
*/
