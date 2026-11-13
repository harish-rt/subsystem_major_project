add wave /top/gpio_if/clk
add wave /top/gpio_if/rst_n

add wave -vgroup {GPIO/Pins} \
    /top/gpio_if/gpio_in \
    /top/gpio_if/gpio_out \
    /top/gpio_if/gpio_oe

wv.time.unit.auto.set
wv.zoom.fit
