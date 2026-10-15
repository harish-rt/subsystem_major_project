class uart_seq_item extends uvm_sequence_item;

    rand bit [7:0]data;

    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end
    `NEW_OBJ

// Constraints

endclass : uart_seq_item
