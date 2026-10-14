add wave /top/spi_if/clk
add wave /top/spi_if/rst_n

add wave -vgroup {SPI/Physical_Lines} \
    /top/spi_if/cs_n \
    /top/spi_if/sclk \
    /top/spi_if/mosi \
    /top/spi_if/miso

add wave -vgroup {SPI/Host_Interface} \
    /top/spi_if/req_valid \
    /top/spi_if/req_ready \
    /top/spi_if/ack \
    /top/spi_if/req_data \
    /top/spi_if/rsp_data

wv.time.unit.auto.set
wv.zoom.fit
