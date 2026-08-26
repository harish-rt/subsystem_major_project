class cpu_agent extends uvm_agent;
    `uvm_component_utils(cpu_agent)
    `NEW_COMP

    cpu_driver                  cpu_drv;
    cpu_sequencer               cpu_sqr;
    cpu_monitor                 cpu_mon;
    uvm_active_passive_enum     is_active;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cpu_mon = cpu_monitor::type_id::create("cpu_mon",this);
        if(is_active == UVM_ACTIVE) begin
            cpu_drv = cpu_driver    ::type_id::create   ("cpu_drv",this);
            cpu_sqr = cpu_sequencer ::type_id::create   ("cpu_sqr",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
       // if(is_active == UVM_ACTIVE) begin
           // cpu_drv.seq_item_port.connect(cpu_sqr.seq_item_export);
      //  end
    endfunction

endclass
