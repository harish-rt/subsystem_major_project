class master_agent extends uvm_agent;

`uvm_component_utils(master_agent)

function new(string name = "master_agent",uvm_component parent = null);
   super.new(name, parent);
endfunction

//master_driver m_drv;
//master_monitor m_mon;
//master_sequencer m_sqr;
config_obj obj;

function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(!uvm_config_db#(config_obj)::get(this,"","config_obj",obj))
      `uvm_error("CONFIG_DB","Getting failed");
//  m_drv = master_driver::type_id::create("m_drv",this);
//  m_sqr = master_sequencer::type_id::create("m_sqr",this);
//  m_mon = master_monitor::type_id::create("m_mon",this);
endfunction

function void connect_phase(uvm_phase phase);
//   m_drv.seq_item_port.connect(m_sqr.seq_item_export);
endfunction

endclass
