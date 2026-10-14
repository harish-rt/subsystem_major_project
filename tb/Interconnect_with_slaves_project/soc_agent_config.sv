class soc_agent_config extends uvm_object;

`uvm_object_utils(soc_agent_config)

function new(string name = "soc_agent_config");
   super.new(name);
endfunction

//virtual intf declaration

uvm_active_passive_enum is_active = UVM_ACTIVE;

endclass
