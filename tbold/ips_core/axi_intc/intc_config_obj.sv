class intc_config_obj extends uvm_object();
    `uvm_object_utils(intc_config_obj)
    `NEW_OBJ

    uvm_active_passive_enum lite_intc_active;
    uvm_active_passive_enum intr_active;

endclass : intc_config_obj
