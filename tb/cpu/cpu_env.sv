class cpu_env extends uvm_env;
    `uvm_component_utils(cpu_env)

    s04_agent        s04_agt;
    cpu_agent        cpu_agt[];
    cpu_config_obj   obj;

    function new(string name="cpu_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(cpu_config_obj)::get(this, "", "cpu_config_obj", obj))
            `uvm_fatal(get_full_name(), "cpu_config_obj get failed!")
        cpu_agt = new[obj.no_of_masters];
        foreach(cpu_agt[i])begin
            cpu_agt[i] = cpu_agent::type_id::create($sformatf("cpu_agt[%0d]",i), this);
        end
        uvm_config_db#(master_e)::set(this, "cpu_agt[0].*", "port_id", MST_S00);
        uvm_config_db#(master_e)::set(this, "cpu_agt[1].*", "port_id", MST_S02);
        //cpu_agt = cpu_agent::type_id::create("cpu_agt", this);
        s04_agt = s04_agent::type_id::create("s04_agt", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach(cpu_agt[i])begin
            cpu_agt[i].mon.cpu_mon_intf = obj.cpu_i[i].MONITOR_MOD;
            cpu_agt[i].drv.cpu_drv_intf = obj.cpu_i[i].DRIVER_MOD;
            cpu_agt[i].drv.seq_item_port.connect(cpu_agt[i].sqr.seq_item_export);
        end
        s04_agt.drv.seq_item_port.connect(s04_agt.sqr.seq_item_export);
    endfunction

   virtual task main_phase(uvm_phase phase);
      `uvm_info("cpu_env::main", phase.get_name(), UVM_MEDIUM)
   endtask
endclass:cpu_env
