class soc_base_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(soc_base_virtual_sequence)
    `uvm_declare_p_sequencer(soc_virtual_sequencer)
    `NEW_OBJ

    intc_config_obj     obj;
    uvm_event           irq_event;
    virtual intc_intf   intc_if;

    task body();
        if(!uvm_config_db #(intc_config_obj)::get(null,get_full_name(),"intc_config_obj",obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")
        irq_event   = obj.irq_event;
    endtask

    task isr_clear();
        intc_if = p_sequencer.cfg.intc_if;

        fork
            begin
                fork
                    begin
                        if(intc_if.intc_irq !== 1'b1)begin
                            @(posedge intc_if.intc_irq);
                            `uvm_info("WAIT_IRQ", "IRQ asserted! Now waiting for ISR to clear...", UVM_LOW)
                        end
                    end
                    begin
                        #10000ns;
                        `uvm_fatal("IRQ_ASSERT_TIMEOUT","CDMA/Peripheral never asserted IRQ!")
                    end
                join_any
                disable fork;

                fork
                    begin
                        @(negedge intc_if.intc_irq);
                        `uvm_info("WAIT_IRQ", "ISR cleared IRQ!", UVM_LOW)
                    end
                    begin
                        #6000ns;
                        `uvm_fatal("IRQ_CLEAR_TIMEOUT", "ISR failed to clear IRQ! Pin stuck high")
                    end
                join_any
                disable fork;
                `uvm_info("WAIT_IRQ", "IRQ successfully asserted and cleared.", UVM_LOW)
            end
        join
    endtask : isr_clear
endclass : soc_base_virtual_sequence

class intc_reg_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(intc_reg_read_vseq)
    `NEW_OBJ

    intc_reg_read_seq intc_vseq;

    task body();
        intc_vseq    = intc_reg_read_seq::type_id::create("intc_vseq");
        `uvm_info("intc_vseq", "Starting INTC reg read vsequence...", UVM_LOW)
        intc_vseq.start(p_sequencer.s00_sqr);
        `uvm_info("intc_vseq", "INTC reg read vsequence complete.", UVM_LOW)
    endtask
endclass : intc_reg_read_vseq

class cdma_reg_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cdma_reg_read_vseq)
    `NEW_OBJ

    cdma_reg_read_seq cdma_vseq;

    task body();
        cdma_vseq    = cdma_reg_read_seq::type_id::create("cdma_vseq");
        `uvm_info("cdma_vseq", "Starting CDMA reg read vsequence...", UVM_LOW)
        cdma_vseq.start(p_sequencer.s00_sqr);
        `uvm_info("cdma_vseq", "CDMA reg read vsequence complete.", UVM_LOW)
    endtask
endclass : cdma_reg_read_vseq

class cpu_isr_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cpu_isr_vseq)
    `NEW_OBJ

    cpu_isr_seq     isr_vseq;
    bit flag;

    task body();
        super.body();
        forever begin
            `uvm_info("isr_vseq", "Hardware IRQ wait", UVM_LOW)
            p_sequencer.intc_af.get(flag);
            `uvm_info("isr_vseq", "Hardware IRQ wait cleared, launching CPU ISR...", UVM_LOW)
            isr_vseq    = cpu_isr_seq::type_id::create("isr_vseq");
            `uvm_info("isr_vseq", "Starting ISR sequence...", UVM_LOW)
            isr_vseq.start(p_sequencer.s00_sqr);
        end
    endtask
endclass : cpu_isr_vseq

class soc_master_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(soc_master_vseq)
    `NEW_OBJ

    cpu_config_intc_seq     intc_seq;
    load_bram_seq           bram_seq;
    cdma_read_write_seq     cdma_seq;
    cpu_isr_vseq            isr_vseq;

    task body();
        super.body();

        isr_vseq = cpu_isr_vseq        ::type_id::create("isr_vseq");
        bram_seq = load_bram_seq       ::type_id::create("bram_seq");
        intc_seq = cpu_config_intc_seq ::type_id::create("intc_seq");
        cdma_seq = cdma_read_write_seq ::type_id::create("cdma_seq");
        
        intc_seq.cdma_en = 1;

        fork
            isr_vseq.start(p_sequencer);
        join_none

        bram_seq.start(p_sequencer.s00_sqr);
        intc_seq.start(p_sequencer.s00_sqr);
        cdma_seq.start(p_sequencer.s00_sqr);
        isr_clear();    // waits for irq down before ending soc_master_vseq
    endtask
endclass : soc_master_vseq

class read_bram_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(read_bram_vseq)
    `NEW_OBJ

    read_bram_seq bram_vseq;

    task body();
        bram_vseq    = read_bram_seq::type_id::create("bram_vseq");
        `uvm_info("bram_vseq", "Starting BRAM configuration sequence...", UVM_LOW)
        bram_vseq.start(p_sequencer.s00_sqr);
        `uvm_info("bram_vseq", "BRAM configuration sequence complete.", UVM_LOW)
    endtask
endclass : read_bram_vseq


class reg_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(reg_read_vseq)
    `NEW_OBJ

    cdma_reg_read_vseq  cdma_vseq;
    intc_reg_read_vseq  intc_vseq;

    task body();
        cdma_vseq = cdma_reg_read_vseq::type_id::create("cdma_vseq");
        intc_vseq = intc_reg_read_vseq::type_id::create("intc_vseq");

        cdma_vseq.start(p_sequencer);
        intc_vseq.start(p_sequencer);
    endtask
endclass : reg_read_vseq

class intc_sw_irq_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(intc_sw_irq_vseq)
    `NEW_OBJ

    intc_sw_irq_seq     intc_seq;
    cpu_isr_vseq        isr_vseq;

    task body();
        intc_seq = intc_sw_irq_seq  ::type_id::create("intc_seq");
        isr_vseq = cpu_isr_vseq     ::type_id::create("isr_vseq");

        fork
            isr_vseq.start(p_sequencer);
        join_none
        intc_seq.start(p_sequencer.s00_sqr);
        isr_clear();
    endtask
endclass : intc_sw_irq_vseq

class cdma_reg_write_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cdma_reg_write_read_vseq)
    `NEW_OBJ

    cdma_reg_write_seq  cdma_wseq;
    cdma_reg_read_seq   cdma_rseq;

    task body();
        cdma_wseq = cdma_reg_write_seq  ::type_id::create("cdma_wseq");
        cdma_rseq = cdma_reg_read_seq   ::type_id::create("cdma_rseq");

        cdma_wseq.start(p_sequencer.s00_sqr);
        cdma_rseq.start(p_sequencer.s00_sqr);
    endtask
endclass : cdma_reg_write_read_vseq

class intc_reg_write_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(intc_reg_write_read_vseq)
    `NEW_OBJ

    intc_reg_write_seq  intc_wseq;
    intc_reg_read_seq   intc_rseq;

    task body();
        intc_wseq = intc_reg_write_seq  ::type_id::create("intc_wseq");
        intc_rseq = intc_reg_read_seq   ::type_id::create("intc_rseq");

        intc_wseq.start(p_sequencer.s00_sqr);
        intc_rseq.start(p_sequencer.s00_sqr);
    endtask
endclass : intc_reg_write_read_vseq

class perif_reg_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(perif_reg_read_vseq)
    `NEW_OBJ

    perif_reg_read_seq perif_vseq;

    task body();
        perif_vseq    = perif_reg_read_seq::type_id::create("perif_vseq");
        `uvm_info("perif_vseq", "Starting PERIF reg read vsequence...", UVM_LOW)
        perif_vseq.start(p_sequencer.s00_sqr);
        `uvm_info("perif_vseq", "PERIF reg read vsequence complete.", UVM_LOW)
    endtask
endclass : perif_reg_read_vseq

class uart_write_data_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(uart_write_data_vseq)
    `NEW_OBJ

    uart_write_data_seq uart_seq;

    task body();
        uart_seq    = uart_write_data_seq::type_id::create("uart_seq");
        `uvm_info("uart_seq", "Starting uart PERIF vsequence...", UVM_LOW)
        uart_seq.start(p_sequencer.s02_sqr);
        `uvm_info("uart_seq", "uart PERIF vsequence complete.", UVM_LOW)
    endtask
endclass : uart_write_data_vseq

`define GAPS_SEQ(VSEQ_NAME,SEQ_NAME)\
class VSEQ_NAME extends soc_base_virtual_sequence;\
    `uvm_object_utils(VSEQ_NAME)\
    `NEW_OBJ\
    SEQ_NAME seq;\
    task body();\
        seq    = SEQ_NAME::type_id::create("seq");\
        `uvm_info("seq", "Starting PERIF vsequence...", UVM_LOW)\
        seq.start(p_sequencer.s00_sqr);\
        `uvm_info("seq", "PERIF vsequence complete.", UVM_LOW)\
    endtask\
endclass:VSEQ_NAME

`GAPS_SEQ(gap_pre_system_vseq, gap_pre_system_seq)
`GAPS_SEQ(gap_mid_periph_vseq, gap_mid_periph_seq)
`GAPS_SEQ(gap_post_cdma_bram_vseq, gap_post_cdma_bram_seq)
`GAPS_SEQ(perif_gap_interconnect_vseq, perif_gap_interconnect_seq)

class interconnect_gaps_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(interconnect_gaps_vseq)
    `NEW_OBJ

    gap_pre_system_vseq      pre_vseq;
    gap_mid_periph_vseq      mid_vseq;
    gap_post_cdma_bram_vseq  post_vseq;
    //perif_gap_interconnect_vseq    intc_vseq;

    task body();
        pre_vseq     = gap_pre_system_vseq    ::type_id::create("pre_vseq");
        mid_vseq     = gap_mid_periph_vseq    ::type_id::create("mid_vseq");
        post_vseq    = gap_post_cdma_bram_vseq::type_id::create("post_vseq");
        //intc_vseq    = perif_gap_interconnect_vseq  ::type_id::create("intc_vseq");
        `uvm_info("gap_seq", "Starting gaps vsequence...", UVM_LOW)
        pre_vseq.start(p_sequencer);
        mid_vseq.start(p_sequencer);
        post_vseq.start(p_sequencer);
        //intc_vseq.start(p_sequencer);
        `uvm_info("gap_seq", "gaps vsequence complete.", UVM_LOW)
    endtask
endclass:interconnect_gaps_vseq

class core_perif_master_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(core_perif_master_vseq)
    `NEW_OBJ

    cpu_config_intc_seq     intc_seq;
    uart_write_data_vseq    uart_vseq;
    cpu_isr_vseq            isr_vseq;

    task body();
        super.body();

        isr_vseq = cpu_isr_vseq         ::type_id::create("isr_vseq");
        uart_vseq = uart_write_data_vseq  ::type_id::create("uart_vseq");
        intc_seq = cpu_config_intc_seq  ::type_id::create("intc_seq");
        
        intc_seq.core_en = 1;
      
        uart_vseq.start(p_sequencer);
        intc_seq.start(p_sequencer.s00_sqr);
        //isr_clear();    // waits for irq down before ending core_perif_master_vseq
    endtask
endclass : core_perif_master_vseq

//`GAPS_SEQ(spi_write_data_vseq, spi_write_data_seq)

class spi_write_data_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(spi_write_data_vseq)
    `NEW_OBJ

    cpu_config_intc_seq     intc_seq;
    spi_write_data_seq      spi_seq;
    cpu_isr_vseq            isr_vseq;

    task body();
        super.body();

        isr_vseq = cpu_isr_vseq         ::type_id::create("isr_vseq");
        spi_seq  = spi_write_data_seq   ::type_id::create("spi_seq");
        intc_seq = cpu_config_intc_seq  ::type_id::create("intc_seq");
        
        intc_seq.core_en = 1;

        fork
            //isr_vseq.start(p_sequencer);
        join_none

        spi_seq.start(p_sequencer.s00_sqr);
        intc_seq.start(p_sequencer.s00_sqr);
        //isr_clear();    // waits for irq down before ending spi_write_data_vseq
    endtask
endclass : spi_write_data_vseq


class intc_stress_lite_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(intc_stress_lite_vseq)
    `NEW_OBJ

    load_mem_lite_seq     write_seq;

    task body();
        super.body();
        write_seq = load_mem_lite_seq::type_id::create("write_seq");

        assert(write_seq.randomize() with {
            addr  == {LITE_MEM_BASE + $urandom_range(100,1000)};
            //addr inside {[LITE_MEM_BASE+100 : LITE_MEM_BASE+1000]};
            beats       == 10;
        });
        write_seq.start(p_sequencer.s00_sqr);
    endtask
endclass : intc_stress_lite_vseq

class intc_stress_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(intc_stress_vseq)
    `NEW_OBJ

    load_mem_seq     write_seq;

    task body();
        super.body();
        write_seq = load_mem_seq::type_id::create("write_seq");

        assert(write_seq.randomize() with {
            addr  == {LITE_MEM_BASE + $urandom_range(100,1000)};
            len   == 'hff;
            burst == INCR;
            is_write == 1;
        });
        write_seq.start(p_sequencer.s04_sqr);
    endtask
endclass : intc_stress_vseq

class wrap_burst_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(wrap_burst_vseq)
    `NEW_OBJ

    load_mem_seq    burst_seq;

    task body();
        super.body();
        burst_seq = load_mem_seq::type_id::create("burst_seq");
        assert(burst_seq.randomize()with{
            addr  == {BRAM_BASE + $urandom_range(100,1000)};
            len   == 'hf;
            burst == WRAP;
            is_write == 1;
        });
        burst_seq.start(p_sequencer.s04_sqr);
    endtask
endclass : wrap_burst_vseq

class uart_slave_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(uart_slave_vseq)
    `NEW_OBJ
    uart_slave_sequence uart_seq;

    task body();
        super.body();
        uart_seq = uart_slave_sequence::type_id::create("uart_seq");

        uart_seq.start(p_sequencer.uart_sqr);
    endtask
endclass : uart_slave_vseq

class concurrent_diff_slaves_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(concurrent_diff_slaves_vseq)
    `NEW_OBJ
    
    intc_stress_vseq        lite_vseq;  // s04
    uart_write_data_vseq    uart_vseq;  // s02
    load_mem_lite_seq       bram_seq;   // s00
    uart_slave_vseq         slv_vseq;   // uart
    cpu_config_intc_seq     intc_seq;   // s02
    cpu_isr_vseq            isr_vseq;   // s00

    task body();
        super.body();
        lite_vseq = intc_stress_vseq::type_id::create("lite_vseq");
        uart_vseq = uart_write_data_vseq::type_id::create("uart_vseq");
        bram_seq  = load_mem_lite_seq::type_id::create("bram_seq");
        slv_vseq  = uart_slave_vseq::type_id::create("slv_vseq");

        intc_seq = cpu_config_intc_seq  ::type_id::create("intc_seq");
        isr_vseq = cpu_isr_vseq         ::type_id::create("isr_vseq");
        intc_seq.core_en = 1;
        fork
            isr_vseq.start(p_sequencer);
        join_none

        assert(bram_seq.randomize() with {
            addr    == {BRAM_BASE + $urandom_range(100,1000)};
            beats   == 10;
        });

        fork
            lite_vseq.start(p_sequencer);
            bram_seq.start(p_sequencer.s00_sqr);
            uart_vseq.start(p_sequencer);
            slv_vseq.start(p_sequencer);
        join
        intc_seq.start(p_sequencer.s02_sqr);
        isr_clear();    // waits for irq down before ending spi_write_data_vseq
    endtask
endclass : concurrent_diff_slaves_vseq

class masters_load_bram_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(masters_load_bram_vseq)
    `NEW_OBJ

    load_mem_lite_seq       s00_seq;    // s00
    load_mem_lite_seq       s02_seq;    // s02
    load_mem_seq            s04_seq;    // s04

    task body();
        s00_seq  = load_mem_lite_seq::type_id::create("s00_seq");
        s02_seq  = load_mem_lite_seq::type_id::create("s02_seq");
        s04_seq  = load_mem_seq::type_id::create("s04_seq");
        assert(s00_seq.randomize() with {
            addr    == {BRAM_BASE + $urandom_range(100,1000)};
            beats   == 10;
        });
        assert(s02_seq.randomize() with {
            addr    == {BRAM_BASE + $urandom_range(1000,2000)};
            beats   == 10;
        });
        assert(s04_seq.randomize()with{
            addr  == {BRAM_BASE + $urandom_range(2000,3000)};
            len   == 'hf;
            burst == INCR;
            is_write == 1;
        });
        fork
            s02_seq.start(p_sequencer.s02_sqr);
            s04_seq.start(p_sequencer.s04_sqr);
            s00_seq.start(p_sequencer.s00_sqr);
        join
    endtask
endclass:masters_load_bram_vseq

class masters_load_lite_mem_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(masters_load_lite_mem_vseq)
    `NEW_OBJ

    load_mem_lite_seq       s00_seq;    // s00
    load_mem_lite_seq       s02_seq;    // s02
    load_mem_seq            s04_seq;    // s04

    task body();
        s00_seq  = load_mem_lite_seq::type_id::create("s00_seq");
        s02_seq  = load_mem_lite_seq::type_id::create("s02_seq");
        s04_seq  = load_mem_seq::type_id::create("s04_seq");
        assert(s00_seq.randomize() with {
            addr    == {LITE_MEM_BASE + $urandom_range(100,1000)};
            beats   == 20;
        });
        assert(s02_seq.randomize() with {
            addr    == {LITE_MEM_BASE + $urandom_range(1000,2000)};
            beats   == 10;
        });
        assert(s04_seq.randomize()with{
            addr  == {LITE_MEM_BASE + $urandom_range(2000,3000)};
            len   == 'hf;
            burst == INCR;
            is_write == 1;
        });
        fork
            s02_seq.start(p_sequencer.s02_sqr);
            s04_seq.start(p_sequencer.s04_sqr);
            s00_seq.start(p_sequencer.s00_sqr);
        join
    endtask
endclass:masters_load_lite_mem_vseq

class master_starve_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(master_starve_vseq)
    `NEW_OBJ

    load_mem_seq            s04_seq;
    load_mem_lite_seq       s02_seq;

    task body();
        s04_seq = load_mem_seq::type_id::create("s04_seq");
        s02_seq = load_mem_lite_seq::type_id::create("s02_seq");

        forever begin
            assert(s04_seq.randomize()with{
                //addr  == {BRAM_BASE + $urandom_range(2000,3000)};
                addr inside {[BRAM_BASE : BRAM_BASE+'h1000]};
                len   == 'hff;
                burst == INCR;
                is_write == 1;
            });
            s04_seq.start(p_sequencer.s04_sqr);
        end
        assert(s02_seq.randomize() with {
            addr    == {BRAM_BASE + $urandom_range(1000,2000)};
            beats   == 10;
        });
        s02_seq.start(p_sequencer.s02_sqr);
    endtask
endclass
