# Truncate/reset compile.log so it overwrites
close [open compile.log w]

# Compilation
vlog -l compile.log \
  +incdir+C:/UVM/uvm-1.2/src \
  list.svh

# Truncate/reset sim.log so it overwrites
close [open sim.log w]

# Simulation
vsim -l sim.log \
  -novopt -suppress 12110 top \
  -sv_lib D:/Softwares/VLSI/QuestaSimSetup/uvm-1.2/win64/uvm_dpi

# Run simulation
run -all
