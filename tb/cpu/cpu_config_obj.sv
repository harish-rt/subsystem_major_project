class cpu_config_obj extends uvm_object();
    `uvm_object_utils(cpu_config_obj)
    `NEW_OBJ

    uvm_active_passive_enum         riscv_is_active;

    virtual axi4_lite_intf          riscv_lite_if;

endclass : cpu_config_obj
