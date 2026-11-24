# ==============================================================================
# File: assert_waves.tcl
# Description: Loads ONLY SystemVerilog assertions into the Riviera-PRO
#              Waveform Viewer using the -asserts filter flag.
# ==============================================================================

proc add_if_assertions {group_name inst_path} {
    add wave -divider $group_name
    set target $inst_path
    append target "/*"
    catch {add wave -asserts -r $target}
}

# --- 1. INTC Subsystem ---
add_if_assertions {INTC: AXI4 Lite Assertions}          {/top/lite_intc_if}
add_if_assertions {INTC: Interrupt Assertions}          {/top/intc_if}

# --- 2. CPU Subsystem ---
add_if_assertions {CPU: AXI4 Lite S00}                  {/top/axil_riscv_if[0]}
add_if_assertions {CPU: AXI4 Lite S02}                  {/top/axil_riscv_if[1]}
add_if_assertions {CPU: AXI4 S04}                       {/top/slave_if}

# --- 3. Memory & BRAM Subsystem ---
add_if_assertions {MEM: AXI4 Lite Memory Assertions}    {/top/mem_intf}
add_if_assertions {MEM: AXI4 BRAM Assertions}           {/top/axi4_bram_if}
add_if_assertions {MEM: AXI4 Memory Assertions}         {/top/mem4_intf}

# --- 4. CDMA Subsystem ---
add_if_assertions {CDMA: CDMA Reg INTF Assertions}      {/top/cdma_reg_intf}
add_if_assertions {CDMA: CDMA SG INTF}                  {/top/cdma_sg_intf}
add_if_assertions {CDMA: CDMA DM INTF}                  {/top/cdma_data_mov_intf}
add_if_assertions {CDMA: CDMA Interrupt}                {/top/cdma_interrupt_intf}

# --- 5. Core Peripheral ---
add_if_assertions {CORE_PERIF: CORE_PERIF Interrupt}    {/top/core_perif_if}

# Description: Loads SystemVerilog assert cover into the Riviera-PRO

proc add_if_coverage {group_name signal_path} {
    add wave -divider $group_name
    catch {add wave $signal_path}
}
# --- 1. AXI Features ---
add_if_coverage {AXI: Read In-Order Completion} \
                {/top/u_axi_read_ooo_checker/read_in_order_evt}

add_if_coverage {AXI: Read Out-of-Order Completion} \
                {/top/u_axi_read_ooo_checker/read_ooo_evt}

add_if_coverage {AXI: Read Data Interleaving} \
                {/top/u_axi_read_ooo_checker/read_interleave_evt}
