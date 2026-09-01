class soc_base_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(soc_base_virtual_sequence)
    `uvm_declare_p_sequencer(soc_virtual_sequencer)
    `NEW_OBJ

    intc_config_obj     obj;
    uvm_event           irq_event;

    task body();
        if(!uvm_config_db #(intc_config_obj)::get(null,get_full_name(),"intc_config_obj",obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")
        irq_event   = obj.irq_event;
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

class cpu_isr_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cpu_isr_vseq)
    `NEW_OBJ

    cpu_isr_seq isr_vseq;

    task body();
        super.body();
        forever begin
            `uvm_info("isr_vseq", "Hardware IRQ detected", UVM_LOW)
            irq_event.wait_trigger(); 
            `uvm_info("isr_vseq", "Hardware IRQ detected wait cleared, launching CPU ISR...", UVM_LOW)
            isr_vseq    = cpu_isr_seq::type_id::create("isr_vseq");
            `uvm_info("isr_vseq", "Starting ISR sequence...", UVM_LOW)
            isr_vseq.start(p_sequencer.cpu_sqr);
            `uvm_info("isr_vseq", "ISR sequence complete.", UVM_LOW)
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
    endtask
endclass : soc_master_vseq
