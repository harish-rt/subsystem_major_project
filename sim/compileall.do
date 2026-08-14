echo "--- Compiling Xilinx IPs ---"
source compilexilinx.do

echo "--- Compiling Peripheral IPs ---"
source compileperi.do

echo "--- Compiling Testbench and Top Level ---"
source compiletb.do

#echo "--- Elaborating Design and Printing Topology ---"
#vsim -c top glbl
