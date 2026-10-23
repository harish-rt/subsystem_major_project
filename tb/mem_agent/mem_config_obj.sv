class mem_config_obj extends uvm_object;
    `uvm_object_utils(mem_config_obj)
    `NEW_OBJ

    uvm_active_passive_enum         mem_is_active;
    uvm_active_passive_enum         bram_is_active;

    virtual axi4_lite_tb_intf       mem_intf;
    virtual axi4_tb_intf            bram_intf;

endclass : mem_config_obj
