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
                        `uvm_fatal("IRQ_ASSERT_TIMEOUT", "CDMA/Peripheral never asserted IRQ!")
                    end
                join_any
                disable fork;

                fork
                    begin
                        @(negedge intc_if.intc_irq);
                        `uvm_info("WAIT_IRQ", "ISR cleared IRQ!", UVM_LOW)
                    end
                    begin
                        #3000ns;
                        `uvm_fatal("IRQ_CLEAR_TIMEOUT", "ISR failed to clear IRQ! Pin stuck high")
                    end
                join_any
                disable fork;
                `uvm_info("WAIT_IRQ", "IRQ successfully asserted and cleared.", UVM_LOW)
            end
        join
    endtask
endclass : soc_base_virtual_sequence

class cpu_config_intc_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cpu_config_intc_vseq)
    `NEW_OBJ

    cpu_config_intc_seq intc_vseq;

    task body();
        intc_vseq    = cpu_config_intc_seq::type_id::create("intc_vseq");
        `uvm_info("intc_vseq", "Starting INTC configuration sequence...", UVM_LOW)
        intc_vseq.start(p_sequencer.cpu_sqr);
        `uvm_info("intc_vseq", "INTC configuration sequence complete.", UVM_LOW)
    endtask
endclass : cpu_config_intc_vseq

class intc_reg_read_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(intc_reg_read_vseq)
    `NEW_OBJ

    intc_reg_read_seq intc_vseq;

    task body();
        intc_vseq    = intc_reg_read_seq::type_id::create("intc_vseq");
        `uvm_info("intc_vseq", "Starting INTC reg read vsequence...", UVM_LOW)
        intc_vseq.start(p_sequencer.cpu_sqr);
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
        cdma_vseq.start(p_sequencer.cpu_sqr);
        `uvm_info("cdma_vseq", "CDMA reg read vsequence complete.", UVM_LOW)
    endtask
endclass : cdma_reg_read_vseq

class cpu_isr_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cpu_isr_vseq)
    `NEW_OBJ

    cpu_isr_seq isr_vseq;
    bit flag;

    task body();
        super.body();
        forever begin
            `uvm_info("isr_vseq", "Hardware IRQ wait", UVM_LOW)
            p_sequencer.intc_af.get(flag);
            `uvm_info("isr_vseq", "Hardware IRQ wait cleared, launching CPU ISR...", UVM_LOW)
            isr_vseq    = cpu_isr_seq::type_id::create("isr_vseq");
            `uvm_info("isr_vseq", "Starting ISR sequence...", UVM_LOW)
            isr_vseq.start(p_sequencer.cpu_sqr);
        end
    endtask
endclass : cpu_isr_vseq

class load_bram_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(load_bram_vseq)
    `NEW_OBJ

    load_bram_seq bram_vseq;

    task body();
        bram_vseq    = load_bram_seq::type_id::create("bram_vseq");
        `uvm_info("bram_vseq", "Starting BRAM configuration sequence...", UVM_LOW)
        bram_vseq.start(p_sequencer.cpu_sqr);
        `uvm_info("bram_vseq", "BRAM configuration sequence complete.", UVM_LOW)
    endtask
endclass : load_bram_vseq

class cdma_read_write_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cdma_read_write_vseq)
    `NEW_OBJ

    cdma_read_write_seq cdma_vseq;

    task body();
        cdma_vseq    = cdma_read_write_seq::type_id::create("cdma_vseq");
        `uvm_info("cdma_vseq", "Starting CDMA configuration sequence...", UVM_LOW)
        cdma_vseq.start(p_sequencer.cpu_sqr);
        `uvm_info("cdma_vseq", "CDMA configuration sequence complete.", UVM_LOW)
    endtask
endclass : cdma_read_write_vseq

class soc_master_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(soc_master_vseq)
    `NEW_OBJ

    cpu_config_intc_vseq    intc_vseq;
    load_bram_vseq          bram_vseq;
    cdma_read_write_vseq    cdma_vseq;
    cpu_isr_vseq            isr_vseq;

    task body();
        super.body();

        isr_vseq  = cpu_isr_vseq        ::type_id::create("isr_vseq");
        bram_vseq = load_bram_vseq      ::type_id::create("bram_vseq");
        intc_vseq = cpu_config_intc_vseq::type_id::create("intc_vseq");
        cdma_vseq = cdma_read_write_vseq::type_id::create("cdma_vseq");

        fork
            isr_vseq.start(p_sequencer);
        join_none

        bram_vseq.start(p_sequencer);
        intc_vseq.start(p_sequencer);
        cdma_vseq.start(p_sequencer);
        isr_clear();    // waits for irq down before ending soc_master_vseq
    endtask
endclass : soc_master_vseq
