class soc_config extends uvm_object;
    `uvm_object_utils(soc_config)

    function new(string name="soc_config");
        super.new(name);
    endfunction
    
    cpu_config_obj          cpu_obj;
    axi_cdma_config_obj     cdma_config_obj;
    intc_config_obj         intc_obj;
endclass
