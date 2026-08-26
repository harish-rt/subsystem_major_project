class descriptor_seq_item extends uvm_sequence_item;
    rand bit[31:0] next_desc_pntr;
    rand bit[31:0] next_desc_pntr_msb;
    rand bit[31:0] sa;
    rand bit[31:0] sa_msb;
    rand bit[31:0] da;
    rand bit[31:0] da_msb;
    rand bit[31:0] control;
    rand bit[31:0] status;

    function new(string name="descriptor_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(descriptor_seq_item)
        `uvm_field_int(next_desc_pntr,UVM_ALL_ON)
        `uvm_field_int(next_desc_pntr_msb,UVM_ALL_ON)
        `uvm_field_int(sa,UVM_ALL_ON)
        `uvm_field_int(sa_msb,UVM_ALL_ON)
        `uvm_field_int(da,UVM_ALL_ON)
        `uvm_field_int(da_msb,UVM_ALL_ON)
        `uvm_field_int(control,UVM_ALL_ON)
        `uvm_field_int(status,UVM_ALL_ON)
    `uvm_object_utils_end

    //constraint for next_desc_pntr
    constraint c1{next_desc_pntr%64==0;}
    constraint c2{next_desc_pntr!=0;}
    constraint c3{sa-da>control || da-sa>control;}
    constraint c4{soft control inside {[26'h100:26'hA000]};}
    constraint c5{soft status==0;}
    constraint c6{sa%16==0;}
    constraint c7{da%16==0;}
endclass
