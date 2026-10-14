class soc_base_test extends uvm_test;
`uvm_component_utils(soc_base_test)

function new(string name="soc_base_test",uvm_component parent = null);
   super.new(name,parent);
endfunction

soc_env env;
//config_obj obj_cfg[];

int has_no_of_agents = 8;
int has_no_of_scoreboard = 2;

function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   env = soc_env::type_id::create("env",this);
//   obj_cfg = config_obj::type_id::create("obj_cfg");
//   config_soc();
//   uvm_config_db#(config_obj)::set(this,"*","config_obj",obj_cfg);
endfunction

/*function void config_soc();
   obj_cfg = new[has_no_of_agents];
  // env_cfg.agent_cfg = new[2];

   foreach(obj_cfg[i])begin
      obj_cfg = config_obj::type_id::create("obj_cfg[i]");
   //   if(!uvm_config_db#(virtual soc_    // get vif from top
      
      obj_cfg[i].is_active = UVM_ACTIVE;
      //env_cfg.agent_cfg[i] = agent_cfg[i];
   end

//   obj_cfg.has_no_of_agents = has_no_of_agents;
//   obj_cfg.has_no_of_scoreboard = has_no_of_scoreboard;

endfunction */

function void end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   uvm_top.print_topology();
endfunction
endclass

class soc_test extends soc_base_test;
`uvm_component_utils(soc_test)
function new(string name="soc_test",uvm_component parent = null);
   super.new(name,parent);
endfunction




task run_phase(uvm_phase phase);
//seq_name;
//seq_name = seq_name::type_id::create("",this);
phase.raise_objection(this);
   phase.phase_done.set_drain_time(this,100);
   //start seq
phase.drop_objection(this);
endtask

endclass

