class soc_env extends uvm_env;

`uvm_component_utils(soc_env)
config_obj obj;
master_agent m_agt[];
slave_agent s_agt[];

function new(string name = "soc_env",uvm_component parent = null);
   super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
   super.build_phase(phase);

   if(!uvm_config_db#(config_obj)::get(this,"","config_obj",obj))
      `uvm_error("ENV_CONFIG_DB","Getting failed");

 //     sbd = new[env_cfg.has_no_of_scoreboard];

     m_agt = new[obj.has_no_m_of_agents];
     s_agt = new[obj.has_no_s_of_agents];

 //     foreach(sbd[i]) 
   //         sbd[i] = soc_scoreboard::type_id::create($sformatf("sbd[%0d]",i),this);

      foreach(m_agt[i])
            m_agt[i] = master_agent::type_id::create($sformatf("m_agt[%0d]",i),this);

      foreach(s_agt[i])
            s_agt[i] = slave_agent::type_id::create($sformatf("s_agt[%0d]",i),this);

endfunction

function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);

endfunction

endclass









