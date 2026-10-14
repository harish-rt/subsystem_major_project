add wave /top/uart_if/clk
add wave /top/uart_if/rst_n

add wave -vgroup {UART/RX_Channel} \
    /top/uart_if/rx_i \
    #/top/uart_if/rx_valid \
    #/top/uart_if/rx_ready \
    /top/uart_if/rx_data

add wave -vgroup {UART/TX_Channel} \
    /top/uart_if/tx_o \
    #/top/uart_if/tx_valid \
    #/top/uart_if/tx_ready \
    /top/uart_if/tx_data

add wave -vgroup {UART/Control} \
    /top/uart_if/ack

wv.time.unit.auto.set
wv.zoom.fit
