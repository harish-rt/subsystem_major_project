class s04_agent extends uvm_agent;
   `uvm_component_utils(s04_agent)

   s04_monitor    mon;
   s04_driver     drv;
   s04_sequencer  sqr;
   
   function new(string name="s04_agent", uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = s04_monitor::type_id::create("mon", this);
      drv = s04_driver::type_id::create("drv", this);
      sqr = s04_sequencer::type_id::create("sqr", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("s04_agent::connect", phase.get_name(), UVM_MEDIUM)
   endfunction
endclass:s04_agent
