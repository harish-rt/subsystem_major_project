class core_wrapper_env extends uvm_env;
   `uvm_component_utils(core_wrapper_env)

   cpu_agent   cpu_agt;
   config_obj  obj;

   function new(string name="core_wrapper_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(config_obj)::get(null, "*", "config_obj", obj))
         `uvm_fatal(get_full_name(), "config_obj get failed!")
      cpu_agt = cpu_agent::type_id::create("cpu_agt", this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cpu_agt.mon.cpu_mon_intf = obj.cpu_i.MON_MOD_cpu;
      cpu_agt.drv.cpu_drv_intf = obj.cpu_i.DRV_MOD_cpu;
      cpu_agt.drv.seq_item_port.connect(cpu_agt.sqr.seq_item_export);
   endfunction

   virtual task main_phase(uvm_phase phase);
      `uvm_info("core_wrapper_env::main", phase.get_name(), UVM_MEDIUM)
   endtask
endclass:core_wrapper_env
