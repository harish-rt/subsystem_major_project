class mem_agent extends uvm_agent;
    `uvm_component_utils(mem_agent);

    function new(string name = "mem_agent" ,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    mem_monitor     mem_mon;
    bram_monitor    bram_mon;
    mem_config_obj  obj;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(mem_config_obj)::get(this, "", "mem_config_obj", obj))
           `uvm_fatal(get_full_name(), "mem_config_obj get failed!")
        mem_mon = mem_monitor   :: type_id ::create ("mem_mon",this);
        bram_mon = bram_monitor   :: type_id ::create ("bram_mon",this);
  //      if(is_active == UVM_ACTIVE) begin
  //          mem_drv = mem_driver    :: type_id ::create ("mem_drv",this);
  //          mem_sqr = mem_sequencer   :: type_id ::create ("mem_sqr",this);
  //          end
  //      else
     endfunction 

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      mem_mon.mon_if        = obj.mem_intf.MONITOR_MOD;
      bram_mon.bram_if      = obj.bram_intf.MONITOR_MOD;
   endfunction
endclass
