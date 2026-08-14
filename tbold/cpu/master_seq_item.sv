class master_seq_item extends uvm_sequence_item;

    rand byte awaddr;
    rand byte wdata;
    rand byte wstrobe;
    rand response_t bresp;
    rand byte araddr;
    rand byte rdata;
    rand response_t rresp;

    `uvm_object_utils_begin(master_seq_item)
        `uvm_field_int(awaddr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(wstrobe, UVM_ALL_ON)
        `uvm_field_enum(response_t, bresp, UVM_ALL_ON)
        `uvm_field_int(araddr, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_enum(response_t, rresp, UVM_ALL_ON)
    `uvm_object_utils_end

    rand delay_t add_valid_dly;
    rand delay_t resp_ready_dly;
    rand delay_t read_ready2ready_dly;
    rand delay_t write_valid2valid_dly;

    function new(string name = "master_seq_item");
        super.new(name);
    endfunction

    // Constraints

endclass : master_seq_item
