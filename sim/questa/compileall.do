echo "--- Compiling_XP ---"
source compilexp.do

echo "--- Compiling_Xilinx_IPs ---"
source compilexilinx.do

echo "--- Compiling_Peripheral_IPs ---"
source compileperi.do

echo "--- Compiling_Testbench_and_Top_Level ---"
source compiletb.do

#echo "--- Elaborating_Design_and_Printing_Topology ---"
#vsim -c top glbl
