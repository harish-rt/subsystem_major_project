interface ip_intf(input clk_i, input rst_i);

   logic        spi_miso_i;
   logic        uart_rx_i;
   logic [31:0] gpio_input_i;
   logic        intr_o;
   logic        spi_clk_o;
   logic        spi_mosi_o;
   logic [7:0]  spi_cs_o;
   logic        uart_tx_o;
   logic [31:0] gpio_output_o;
   logic [31:0] gpio_output_enable_o;

   logic ext1_irq_i;
   logic ext2_irq_i;
   logic ext3_irq_i;


clocking ip_drv_cb@(posedge clk_i);
   output spi_miso_i;
   output uart_rx_i;
   output gpio_input_i;
   input intr_o;
   input spi_clk_o;
   input spi_mosi_o;
   input spi_cs_o;
   input uart_tx_o;
   input gpio_output_o;
   input gpio_output_enable_o;

   input ext1_irq_i;
   input ext2_irq_i;
   input ext3_irq_i;
endclocking

clocking ip_mon_cb@(posedge clk_i);
   input spi_miso_i;
   input uart_rx_i;
   input gpio_input_i;
   input intr_o;
   input spi_clk_o;
   input spi_mosi_o;
   input spi_cs_o;
   input uart_tx_o;
   input gpio_output_o;
   input gpio_output_enable_o;

   input ext1_irq_i;
   input ext2_irq_i;
   input ext3_irq_i;
endclocking
   modport ip_drv_mod (clocking ip_drv_cb, input rst_i);
   modport ip_mon_mod (clocking ip_mon_cb, input rst_i);
 
endinterface 
