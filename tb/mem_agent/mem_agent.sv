class mem_agent extends uvm_agent;
    `uvm_component_utils(mem_agent);

    function new(string name = "mem_agent" ,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    mem_monitor     mem_mon;
    axi4_monitor    axi4_mon[];
    mem_config_obj  mem_obj;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(mem_config_obj)::get(this, "", "mem_config_obj", mem_obj))
           `uvm_fatal(get_full_name(), "mem_config_obj get failed!")
        axi4_mon = new[2];
        foreach(axi4_mon[i])begin
            axi4_mon[i] = axi4_monitor::type_id::create($sformatf("axi4_mon[%0d]",i), this);
        end
        mem_mon = mem_monitor   :: type_id ::create ("mem_mon",this);
        //axi4_mon = axi4_monitor   :: type_id ::create ("axi4_mon",this);
     endfunction 

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      mem_mon.mon_if        = mem_obj.mem_intf;
      axi4_mon[0].bram_if   = mem_obj.bram_intf;
      axi4_mon[1].bram_if   = mem_obj.mem4_intf;
   endfunction
endclass
