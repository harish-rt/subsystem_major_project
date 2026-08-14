class base_lite_intc_seq extends uvm_sequence#(lite_intc_seq_item);
    `uvm_object_utils(base_lite_intc_seq)
    `NEW_OBJ

    uvm_phase               phase;
    lite_intc_seq_item      intc_pkt;
    
    task pre_body();
        phase   =   get_starting_phase();
        if(phase != null) begin
            phase.raise_objection(this);
            `uvm_info(get_full_name(),"inside_pre_body", UVM_MEDIUM)
        end
    endtask

    task post_body();
        if(phase != null) begin
            `uvm_info(get_full_name(),"inside_post_body", UVM_MEDIUM)
            phase.drop_objection(this);
        end
    endtask

    task body();
        intc_pkt = lite_intc_seq_item::type_id::create("intc_pkt");            
    endtask
endclass

class lite_intc_read_seq extends base_lite_intc_seq;
    `uvm_object_utils(lite_intc_read_seq)
    `NEW_OBJ

    task body();
        super.body();
        if(!intc_pkt.randomize()with{
            intc_pkt.araddr == 'h24;
            })begin
            `uvm_error(get_type_name(), "randomization_failed")
        end
    endtask
endclass
