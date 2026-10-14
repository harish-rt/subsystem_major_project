class cpu_base_test extends uvm_test;
    `uvm_component_utils(cpu_base_test)
    `NEW_COMP

    intc_config_obj                 obj;
    wrapper_env                     w_env;
    virtual axi4_lite_intc_intf     lite_intc_if;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))begin
            `uvm_fatal("OBJ_MISSING", "The intc_config_obj handle was not set in uvm_config_db!")
        end
        lite_intc_if = obj.lite_intc_intf;
        w_env = wrapper_env::type_id::create("w_env",this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase (phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        `uvm_info(get_full_name(),"inside_reset_phase", UVM_MEDIUM)
        phase.raise_objection(this);
            `uvm_info(get_full_name(),"inside_raise_objection", UVM_MEDIUM)
            if (lite_intc_if == null) begin
                `uvm_fatal("TEST_VIF_NULL", "lite_intc_intf is NULL inside reset_phase!")
            end
            wait (lite_intc_if.areset_n == 1'b1); 
        phase.drop_objection(this);
        `uvm_info(get_full_name(),"outside_drop_objection", UVM_MEDIUM)
    endtask: reset_phase

endclass : cpu_base_test

class intc_sw_irq_test extends cpu_base_test;
    `uvm_component_utils(intc_sw_irq_test)
    `NEW_COMP

    intc_sw_irq_vseq     intc_seq;

    task main_phase(uvm_phase phase);
        intc_seq = intc_sw_irq_vseq::type_id::create("intc_seq");

        phase.raise_objection(this);

            intc_seq.start(w_env.vsqr);

            phase.phase_done.set_drain_time(this, 100ns);
        phase.drop_objection(this);
    endtask
endclass : intc_sw_irq_test

class bram_multiple_write_read_test extends cpu_base_test;
    `uvm_component_utils(bram_multiple_write_read_test)
    `NEW_COMP

    task main_phase(uvm_phase phase);
        bram_multiple_wr_rd_seq multiple_wr_rd_seq=bram_multiple_wr_rd_seq::type_id::create("multiple_wr_rd_seq");
        phase.raise_objection(this);
            multiple_wr_rd_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass


class bram_upper_invalid_addr_test extends cpu_base_test;
    `uvm_component_utils(bram_upper_invalid_addr_test)

    `NEW_COMP
    task main_phase(uvm_phase phase);
        bram_upper_invalid_addr_seq bram_seq=bram_upper_invalid_addr_seq::type_id::create("bram_seq");
        phase.raise_objection(this);
            bram_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

class bram_lower_invalid_addr_test extends cpu_base_test;
    `uvm_component_utils(bram_lower_invalid_addr_test)

    `NEW_COMP
    task main_phase(uvm_phase phase);
        bram_lower_invalid_addr_seq bram_seq=bram_lower_invalid_addr_seq::type_id::create("bram_seq");
        phase.raise_objection(this);
            bram_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

class bram_address_range_test extends cpu_base_test;
    `uvm_component_utils(bram_address_range_test)

    `NEW_COMP
    task main_phase(uvm_phase phase);
        bram_address_range_seq bram_seq=bram_address_range_seq::type_id::create("bram_seq");
        phase.raise_objection(this);
            bram_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

class soc_master_test extends cpu_base_test;
    `uvm_component_utils(soc_master_test)
    `NEW_COMP

    soc_master_vseq master_vseq;

    task main_phase(uvm_phase phase);
        master_vseq = soc_master_vseq::type_id::create("master_vseq");

        phase.raise_objection(this);

            master_vseq.start(w_env.vsqr);

        phase.phase_done.set_drain_time(this, 500ns);
        phase.drop_objection(this);
    endtask
endclass : soc_master_test

class load_bram_256_test extends cpu_base_test;
    `uvm_component_utils(load_bram_256_test)
    `NEW_COMP

    load_bram_256_seq   load_seq;
    read_bram_256_seq   read_seq;   //axi4
    read_bram_vseq      lite_seq;   //axi4 lite

    task main_phase(uvm_phase phase);
        load_seq = load_bram_256_seq::type_id::create("load_seq");  //axi4

        read_seq = read_bram_256_seq::type_id::create("read_seq");  //axi4
        lite_seq = read_bram_vseq::type_id::create("lite_seq");     //axi4 lite

        phase.raise_objection(this);
            load_seq.start(w_env.c_env.s04_agt.sqr);
            `uvm_info("UVM_TEST","loading bram completed",UVM_LOW)
            //#1000ns;
        fork
            `uvm_info("UVM_TEST","entered fork",UVM_LOW)
            read_seq.start(w_env.c_env.s04_agt.sqr);
            lite_seq.start(w_env.vsqr);
        join
        `uvm_info("UVM_TEST","came out of fork",UVM_LOW)
        phase.phase_done.set_drain_time(this, 2000ns);
        phase.drop_objection(this);
    endtask
endclass : load_bram_256_test

class cdma_boundary_check_test extends cpu_base_test;
    `uvm_component_utils(cdma_boundary_check_test)
    `NEW_COMP

    cdma_boundary_check_seq cdma_seq;

    task main_phase(uvm_phase phase);
        cdma_seq = cdma_boundary_check_seq::type_id::create("cdma_seq");

        phase.raise_objection(this);
            cdma_seq.start(w_env.c_env.cpu_agt.sqr);
            //cdma_seq.start(w_env.c_env.s04_agt.sqr);
        phase.drop_objection(this);
    endtask
endclass : cdma_boundary_check_test


class cdma_wr_rd_test extends cpu_base_test;
    `uvm_component_utils(cdma_wr_rd_test)
    `NEW_COMP

    load_mem_seq mem_seq;
    cdma_read_write_seq seq;

    task main_phase(uvm_phase phase);
        seq = cdma_read_write_seq :: type_id :: create("seq");
        mem_seq = load_mem_seq :: type_id :: create("mem_seq");

        phase.raise_objection(this);

            mem_seq.start(w_env.c_env.cpu_agt.sqr);
            seq.start(w_env.c_env.cpu_agt.sqr);

        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : cdma_wr_rd_test

class mem_wr_rd_test extends cpu_base_test;
    `uvm_component_utils(mem_wr_rd_test)
    `NEW_COMP

    load_mem_seq mem_seq;
    read_mem_seq seq;

    task main_phase(uvm_phase phase);
        seq = read_mem_seq :: type_id :: create("seq");
        mem_seq = load_mem_seq :: type_id :: create("mem_seq");

        phase.raise_objection(this);

            mem_seq.start(w_env.c_env.cpu_agt.sqr);
            seq.start(w_env.c_env.cpu_agt.sqr);

        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : mem_wr_rd_test

class cdma_reg_read_test extends cpu_base_test;
    `uvm_component_utils(cdma_reg_read_test)
    `NEW_COMP

    cdma_reg_read_vseq   reg_vseq;
    task main_phase(uvm_phase phase);
        reg_vseq = cdma_reg_read_vseq::type_id::create("reg_vseq");
        phase.raise_objection(this);
            reg_vseq.start(w_env.vsqr);
        phase.drop_objection(this);
    endtask
endclass : cdma_reg_read_test

class reg_read_test extends cpu_base_test;
    `uvm_component_utils(reg_read_test)
    `NEW_COMP

    reg_read_vseq   reg_vseq;
    task main_phase(uvm_phase phase);
        reg_vseq = reg_read_vseq::type_id::create("reg_vseq");
        phase.raise_objection(this);
            reg_vseq.start(w_env.vsqr);
        phase.drop_objection(this);
    endtask
endclass : reg_read_test

class cdma_reg_write_read_test extends cpu_base_test;
    `uvm_component_utils(cdma_reg_write_read_test)
    `NEW_COMP

    cdma_reg_write_read_vseq   reg_vseq;

    task main_phase(uvm_phase phase);
        reg_vseq = cdma_reg_write_read_vseq::type_id::create("reg_vseq");
        phase.raise_objection(this);
            reg_vseq.start(w_env.vsqr);
        phase.drop_objection(this);
    endtask
endclass : cdma_reg_write_read_test

class intc_reg_write_read_test extends cpu_base_test;
    `uvm_component_utils(intc_reg_write_read_test)
    `NEW_COMP

    intc_reg_write_read_vseq   reg_vseq;

    task main_phase(uvm_phase phase);
        reg_vseq = intc_reg_write_read_vseq::type_id::create("reg_vseq");
        phase.raise_objection(this);
            reg_vseq.start(w_env.vsqr);
        phase.drop_objection(this);
    endtask
endclass : intc_reg_write_read_test

class perif_reg_read_test extends cpu_base_test;
    `uvm_component_utils(perif_reg_read_test)
    `NEW_COMP

    perif_reg_read_vseq   reg_vseq;
    task main_phase(uvm_phase phase);
        //w_env.c_env.cpu_agt.drv.disable_cpu_fork = 1;
        `SET_CPU_FORK_DISABLE(1);
        reg_vseq = perif_reg_read_vseq::type_id::create("reg_vseq");
        phase.raise_objection(this);
            reg_vseq.start(w_env.vsqr);
        phase.drop_objection(this);
    endtask
endclass : perif_reg_read_test

class uart_write_data_test extends cpu_base_test;
    `uvm_component_utils(uart_write_data_test)
    `NEW_COMP

    uart_write_data_vseq   reg_vseq;
    task main_phase(uvm_phase phase);
        `SET_CPU_FORK_DISABLE(1);
        reg_vseq = uart_write_data_vseq::type_id::create("reg_vseq");
        phase.raise_objection(this);
            reg_vseq.start(w_env.vsqr);
        phase.phase_done.set_drain_time(this, 6000ns);
        phase.drop_objection(this);
    endtask
endclass : uart_write_data_test

`define GAPS_TEST(TESTNAME,VSEQ_NAME,CFD)\
class TESTNAME extends cpu_base_test;\
    `uvm_component_utils(TESTNAME)\
    `NEW_COMP\
    VSEQ_NAME   vseq;\
    task main_phase(uvm_phase phase);\
        `SET_CPU_FORK_DISABLE(CFD);\
        vseq = VSEQ_NAME::type_id::create("vseq");\
        phase.raise_objection(this);\
            vseq.start(w_env.vsqr);\
        phase.phase_done.set_drain_time(this, 1000ns);\
        phase.drop_objection(this);\
    endtask\
endclass : TESTNAME

`GAPS_TEST(interconnect_gaps_test, interconnect_gaps_vseq,0)
`GAPS_TEST(perif_gap_interconnect_test, perif_gap_interconnect_vseq,1)

//`GAPS_TEST(core_perif_master_test, core_perif_master_vseq,1)
//`GAPS_TEST(spi_write_data_test, spi_write_data_vseq,1)

class spi_write_data_test extends cpu_base_test;
    `uvm_component_utils(spi_write_data_test)
    `NEW_COMP

    spi_write_data_vseq     reg_vseq;
    spi_slave_sequence      slv_seq;

    task main_phase(uvm_phase phase);
        `SET_CPU_FORK_DISABLE(1);
        reg_vseq = spi_write_data_vseq::type_id::create("reg_vseq");
        slv_seq = spi_slave_sequence::type_id::create("slv_seq");
        phase.raise_objection(this);
        fork
            reg_vseq.start(w_env.vsqr);
            slv_seq.start(w_env.cp_env.spi_agt.sequencer);
        join
        phase.phase_done.set_drain_time(this, 8000ns);
        phase.drop_objection(this);
    endtask
endclass : spi_write_data_test

class core_perif_master_test extends cpu_base_test;
    `uvm_component_utils(core_perif_master_test)
    `NEW_COMP

    core_perif_master_vseq   reg_vseq;
    uart_slave_sequence      slv_seq;
    task main_phase(uvm_phase phase);
        `SET_CPU_FORK_DISABLE(1);
        reg_vseq = core_perif_master_vseq::type_id::create("reg_vseq");
        slv_seq  = uart_slave_sequence  ::type_id::create("slv_seq");
        phase.raise_objection(this);
        fork
            reg_vseq.start(w_env.vsqr);
            slv_seq.start(w_env.cp_env.uart_agt.sequencer);
        join
        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : core_perif_master_test
