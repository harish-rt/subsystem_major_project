class s04_agent extends uvm_agent;
   `uvm_component_utils(s04_agent)

   s04_monitor      mon;
   s04_driver       drv;
   s04_sequencer    sqr;

   track_pkt        tkt;
   
   function new(string name="s04_agent", uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = s04_monitor::type_id::create("mon", this);
      drv = s04_driver::type_id::create("drv", this);
      sqr = s04_sequencer::type_id::create("sqr", this);
      tkt = track_pkt::type_id::create("tkt", this);
      uvm_config_db#(track_pkt)::set(this,"*","TKT",tkt);
   endfunction

   //function void connect_phase(uvm_phase phase);
   //     super.connect_phase(phase);
   //     drv.tkt = tkt;
   //     mon.tkt = tkt;
   //endfunction

endclass:s04_agent
