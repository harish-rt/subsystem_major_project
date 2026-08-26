import axi_cdma_regblock_pkg ::*;
class env extends uvm_env;

   `uvm_component_utils (env)
    master_agent        m_agt[];
    slave_agent         s_agt[];

   cdma_sbd    scb;
   cdma_cov    cov;
   
   axi_cdma_config_obj  obj;
   //data_mover_intf_cov axi_cov;
   

   //virtual_sequencer vseqr;
   reg_axi_cdma_adapter m_adapter;//adapter
   cdma_reg_block reg_model; //reg model
   uvm_reg_predictor#(master_seq_item) m_predictor;  
   axi_slave_mem_model mem_model;

   function new (string name = "env" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern task main_phase                        (uvm_phase phase);

endclass :env

  function void env :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     `uvm_info ("env::build" , phase.get_name() , UVM_MEDIUM)
     if (!uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj))
     `uvm_fatal(get_full_name(),"Config_obj get Failure");
        m_agt = new[obj.no_of_masters];
        s_agt = new[obj.no_of_slaves];
     for(int i = 0 ; i < obj.no_of_masters ; i++) begin
         m_agt[i] = master_agent :: type_id :: create ($sformatf("m_agt[%0d]",i),this);
        m_agt[i].agt_active = obj.mas_is_active[i];
     end
     for(int i = 0 ; i < obj.no_of_slaves ; i++) begin
        s_agt[i] = slave_agent :: type_id :: create ($sformatf("s_agt[%0d]",i),this);
        //s_sub[i] = slave_subscriber :: type_id :: create ($sformatf("s_sub[%0d]",i),this);
        s_agt[i].agt_active = obj.slv_is_active[i];
     end
     if(obj.enable_scoreboard==1)begin
        scb = cdma_sbd :: type_id :: create ("scb",this);
     end
     cov = cdma_cov :: type_id :: create ("cov",this);
     //axi_cov= data_mover_intf_cov::type_id::create("axi_cov",this); 
        
        reg_model=cdma_reg_block::type_id::create("reg_model");
        m_adapter=reg_axi_cdma_adapter::type_id::create("adapter");
        m_predictor=uvm_reg_predictor#(master_seq_item)::type_id::create("m_predictor",this);
        //vseqr = virtual_sequencer::type_id::create("vseqr", this);
        
        reg_model.build();
        reg_model.reset();
        reg_model.default_map.set_auto_predict(1);
        reg_model.print();
        reg_model.default_map.reset();
        mem_model=axi_slave_mem_model::type_id::create("mem_model"); 
        uvm_config_db#(axi_slave_mem_model)::set(this,"*","memory",mem_model);
  endfunction : build_phase

  function void env :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info ("env::connect" ,"inside env_connect phase", UVM_MEDIUM)

    
     for(int i = 0 ; i < obj.no_of_masters ; i++) begin
        m_agt[i].mon.master_mon_intf = obj.mas_if[i];
        if(obj.mas_is_active[i] == UVM_ACTIVE)  begin
            
          m_agt[i].drv.master_drv_intf = obj.mas_if[i];
          m_agt[i].drv.seq_item_port.connect(m_agt[i].sqr.seq_item_export);
          reg_model.bus_map.set_sequencer(m_agt[i].sqr,.adapter(m_adapter));
        end
          m_agt[i].mon.mon_ap.connect (cov.analysis_export);

          if(obj.enable_scoreboard==1'b1)begin
                m_agt[i].mon.mon_ap.connect (scb.m_af.analysis_export);
          end
     end
     for(int i = 0 ; i < obj.no_of_slaves ; i++) begin
        s_agt[i].mon.slave_mon_intf = obj.slv_if[i];
        if(obj.slv_is_active[i] == UVM_ACTIVE)  begin
          s_agt[i].drv.slave_drv_intf = obj.slv_if[i];
          s_agt[i].drv.seq_item_port.connect(s_agt[i].sqr.seq_item_export);
        end
        if(obj.enable_scoreboard==1'b1)begin
          s_agt[i].mon.mon_ap.connect (scb.s_af[i].analysis_export);
        end  
     end

         //assign register map
        m_predictor.map=reg_model.bus_map;
        //assign the adapter 
        m_predictor.adapter=m_adapter;
        //vseqr.reg_model=reg_model;

       
        //connect monitor analysis port to predictor 
        m_agt[0].mon.mon_ap.connect(m_predictor.bus_in);
        //connect reg_model handle in scorebaord to reg_model handle in env
        if(obj.enable_scoreboard==1)begin
            scb.reg_model=reg_model;
        end
        //s_agt[0].mem_model=mem_model; 
  endfunction : connect_phase

  function void env :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
     `uvm_info ("env::sim" , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  task env :: main_phase (uvm_phase phase);
     `uvm_info ("env::main" , phase.get_name() , UVM_MEDIUM)
  endtask : main_phase
