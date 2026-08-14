class intc_config_obj extends uvm_object();
    `uvm_object_utils(intc_config_obj)
    `NEW_OBJ

    uvm_active_passive_enum         axi_lite_is_active;
    uvm_active_passive_enum         intc_is_active;

    virtual axi4_lite_intc_intf     lite_intc_intf;
    virtual intc_intf               intc_if;

endclass : intc_config_obj
