class config_obj extends uvm_object;

`uvm_object_utils(config_obj)

function new(string name = "config_obj");
   super.new(name);
endfunction

//int has_no_of_scoreboard;
int has_no_m_of_agents;
int has_no_s_of_agents;
//int has_no_of_virtual_sequencer;


//virtual interfaces
virtual master_interface m_if;
virtual slave_interface s_if;
virtual dist_intf d_if;
virtual uart_Aslave_intf a_if;
virtual uart_Pslave_intf p_if;

//master_config_obj m_obj;
//slave_config_obj s_obj;

uvm_active_passive_enum is_m_active;
uvm_active_passive_enum is_s_active;

endclass

