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
endclass

class cpu_config_intc_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cpu_config_intc_vseq)
    `NEW_OBJ

    cpu_config_intc_seq intc_vseq;

    task body();
        intc_vseq    = cpu_config_intc_seq::type_id::create("intc_vseq");
        `uvm_info("soc_vseq", "Starting INTC configuration sequence...", UVM_LOW)
        intc_vseq.start(p_sequencer.cpu_sqr);
        `uvm_info("soc_vseq", "INTC configuration sequence complete.", UVM_LOW)
    endtask
endclass

class cpu_isr_vseq extends soc_base_virtual_sequence;
    `uvm_object_utils(cpu_isr_vseq)
    `NEW_OBJ

    cpu_isr_seq isr_vseq;

    task body();
        super.body();
        forever begin
            `uvm_info("soc_vseq", "Hardware IRQ detected", UVM_LOW)
            irq_event.wait_trigger(); 
            `uvm_info("soc_vseq", "Hardware IRQ detected wait cleared, launching CPU ISR...", UVM_LOW)

            isr_vseq    = cpu_isr_seq::type_id::create("isr_vseq");
            `uvm_info("soc_vseq", "Starting ISR sequence...", UVM_LOW)
            isr_vseq.start(p_sequencer.cpu_sqr);
            `uvm_info("soc_vseq", "ISR sequence complete.", UVM_LOW)
        end
    endtask
endclass
