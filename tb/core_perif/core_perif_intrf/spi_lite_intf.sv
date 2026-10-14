interface spi_lite(input clk_i,rst_i);
    // Inputs
    logic           spi_miso_i;

    // Outputs
    logic           spi_clk_o;
    logic           spi_mosi_o;
    logic [7:0]     spi_cs_o;
    logic           intr_o;

    clocking spi_drv_cb@(posedge clk_i);
        default input #1 output #0;

        input           spi_clk_o;
        input [7:0]     spi_cs_o;
        output          spi_miso_i;
        input           spi_mosi_o;
        input           intr_o;
    endclocking

    clocking spi_mon_cb@(posedge clk_i);
        default input #1 output #0;

        input           spi_clk_o;
        input [7:0]     spi_cs_o;
        input           spi_miso_i;
        input           spi_mosi_o;
        input           intr_o;
    endclocking
endinterface
