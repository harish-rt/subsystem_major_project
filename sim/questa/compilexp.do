echo "--- Creating and Compiling Dedicated Xilinx Primitives ---"

set XILINX_VIVADO "D:/opt/xilinx/2025.1/Vivado"

# 1. Create distinct physical library folders
vlib unisim
vlib unisims_ver
vlib unimacro
vlib unimacro_ver
vlib secureip

# 2. Map distinct logical names
vmap unisim       ./unisim
vmap unisims_ver  ./unisims_ver
vmap unimacro     ./unimacro
vmap unimacro_ver ./unimacro_ver
vmap secureip     ./secureip

# 3. Compile unisim (VHDL Packages)
echo "Compiling UNISIM (VHDL)..."
vcom -work unisim -93 "$XILINX_VIVADO/data/vhdl/src/unisims/unisim_VPKG.vhd"
vcom -work unisim -93 "$XILINX_VIVADO/data/vhdl/src/unisims/unisim_retarget_VCOMP.vhd"

# 4. Compile unimacro (VHDL)
echo "Compiling UNIMACRO (VHDL)..."
vcom -work unimacro -93 "$XILINX_VIVADO/data/vhdl/src/unimacro/unimacro_VCOMP.vhd"

# 5. Compile unisims_ver (Verilog Primitives) via Generated Filelist
echo "Generating filelist and compiling UNISIMS_VER (Verilog)..."
set fp [open "unisims_files.f" "w"]
puts $fp "+incdir+$XILINX_VIVADO/data/verilog/src"
puts $fp "\"$XILINX_VIVADO/data/verilog/src/glbl.v\""
foreach file [glob -nocomplain "$XILINX_VIVADO/data/verilog/src/unisims/*.v"] {
    puts $fp "\"$file\""
}
close $fp

vlog -work unisims_ver -vlog01compat -f unisims_files.f

# 6. Compile unimacro_ver (Verilog Macros) via Generated Filelist
echo "Generating filelist and compiling UNIMACRO_VER (Verilog)..."
set fp [open "unimacro_files.f" "w"]
puts $fp "+incdir+$XILINX_VIVADO/data/verilog/src"
foreach file [glob -nocomplain "$XILINX_VIVADO/data/verilog/src/unimacro/*.v"] {
    puts $fp "\"$file\""
}
close $fp

vlog -work unimacro_ver -vlog01compat -f unimacro_files.f

# 7. Compile secureip (Encrypted Verilog IPs) via Generated Filelist
echo "Generating filelist and compiling SECUREIP..."
set fp [open "secureip_files.f" "w"]
puts $fp "+incdir+$XILINX_VIVADO/data/secureip"

# Match any nested encrypted or wrapper source files
set secureip_files [glob -nocomplain "$XILINX_VIVADO/data/secureip/*/*.vp" \
                                    "$XILINX_VIVADO/data/secureip/*/*.v" \
                                    "$XILINX_VIVADO/data/secureip/*/*.sv" \
                                    "$XILINX_VIVADO/data/secureip/*.vp"]

foreach file $secureip_files {
    puts $fp "\"$file\""
}
close $fp

if {[llength $secureip_files] > 0} {
    vlog -work secureip -vlog01compat -f secureip_files.f
} else {
    echo "Note: No secureip source files found or needed. Skipping secureip compilation."
}
echo "--- Primitive Compilation Complete ---"
