class slave_agent extends uvm_agent;

`uvm_component_utils(slave_agent)

function new(string name = "slave_agent",uvm_component parent = null);
   super.new(name,parent);
endfunction

//slave_driver s_drv;
//slave_sequencer s_sqr;
//slave_monitor s_mon;

//slave_config_obj obj;
config_obj obj;

function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if(!uvm_config_db#(config_obj)::get(this,"","config_obj",obj))
      `uvm_error("CONFIG_DB","Getting failed");
   
//   if(obj.is_active == UVM_ACTIVE)begin 
//      s_drv = slave_driver::type_id::create("drv",this);
//      s_sqr = slave_sequencer::type_id::create("s_sqr",this);
//      s_mon = slave_monitor::type_id::create("s_mon",this);
//   end
//
//   else if(obj.is_active == UVM_PASSIVE)begin
//      s_mon = slave_monitor::type_id::create("s_mon",this);
//   end
endfunction

function void connect_phase(uvm_phase phase);
 //  s_drv.seq_item_port.connect(s_sqr.seq_item_export);
endfunction
endclass
