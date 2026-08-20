class cpu_agent extends uvm_agent;
   `uvm_component_utils(cpu_agent)
   cpu_monitor    mon;
   cpu_driver     drv;
   cpu_sequencer  sqr;
   
   function new(string name="cpu_agent", uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = cpu_monitor::type_id::create("mon", this);
      drv = cpu_driver::type_id::create("drv", this);
      sqr = cpu_sequencer::type_id::create("sqr", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("cpu_agent::connect", phase.get_name(), UVM_MEDIUM)
   endfunction
endclass:cpu_agent
