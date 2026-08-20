class base_test extends uvm_test;
   `uvm_component_utils (base_test)
   core_wrapper_env   env;							      
   config_obj         obj;		

   // base_test:: class_constructor
   function new (string name = "base_test" , uvm_component parent);
      super.new(name,parent);
    endfunction

  // base_test:: build
  function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("test::build_phase" , phase.get_name() , UVM_MEDIUM)
   env = core_wrapper_env:: type_id :: create ("env", this);					
  endfunction : build_phase

  // base_test:: elaboration
  function void end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
    `uvm_info ("test::end_of_elaboration"  , phase.get_name() , UVM_MEDIUM)
     uvm_top.print_topology();								//printing topology
  endfunction : end_of_elaboration_phase
  
  // base_test:: reset_phase
  task reset_phase (uvm_phase phase);
     `uvm_info(get_full_name(),"inside reset phase", UVM_MEDIUM)
     phase.raise_objection (this);  
if (!uvm_config_db #(config_obj)::get(this, "", "config_obj", obj))
    `uvm_fatal (get_full_name(), "config_db not accessable");
    `uvm_info("DEBUG", "Waiting for reset release", UVM_LOW)
     wait(obj.cpu_i.areset_n == 1);
     `uvm_info("DEBUG", "Reset released", UVM_LOW)
     phase.drop_objection (this);
  endtask: reset_phase

// base_test:: main_phase
  task main_phase (uvm_phase phase);
    phase.raise_objection(this);
    phase.drop_objection(this);
    `uvm_info ("test:: main_phase", "run_phse completed", UVM_MEDIUM)
  endtask: main_phase 
endclass : base_test 
