class irq_agent_cfg extends uvm_object;
  `uvm_object_utils(irq_agent_cfg)

  function new(string name = "irq_agent_cfg");
    super.new(name);
  endfunction

  uvm_active_passive_enum     is_active = UVM_ACTIVE;
endclass
