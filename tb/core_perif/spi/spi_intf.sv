interface spi_if (input logic clk_i, input logic rst_n_i);

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
