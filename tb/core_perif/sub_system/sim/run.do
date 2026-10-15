vlib work
vlib work/rtl_slave_model

vmap rtl_slave_model work/rtl_slave_model

vlog -work rtl_slave_model -uvmver 1.2 \
-l rtl_slave_model.log \
"../tb/rtl_slave_responder_tb.sv"

vsim -c -lib rtl_slave_model +access +rwc top \
-l sim.log
run -all
