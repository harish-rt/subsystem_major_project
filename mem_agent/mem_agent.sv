class mem_agent extends uvm_agent;
    `uvm_component_utils(mem_agent);

    function new(string name = "mem_agent" ,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    //mem_driver mem_drv;
    mem_monitor mem_mon;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
  //      uvm_config_db#(uvm_active_passive_enum)::get(this,"","AGT",is_active);
  //      if(is_active == UVM_ACTIVE) begin
  //          mem_drv = mem_driver    :: type_id ::create ("mem_drv",this);
  //          mem_sqr = mem_sequencer   :: type_id ::create ("mem_sqr",this);
  //          end
  //      else
            mem_mon = mem_monitor   :: type_id ::create ("mem_mon",this);
     endfunction 

endclass
