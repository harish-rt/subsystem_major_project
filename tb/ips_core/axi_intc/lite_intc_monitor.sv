class lite_intc_monitor extends uvm_monitor;
    `uvm_component_utils(lite_intc_monitor)
    `NEW_COMP
    
    uvm_analysis_port #(lite_intc_seq_item)         mon_ap;
	//virtual axi4_lite_intc_intf.axi4_lite_mon_mod	mon_if;
    virtual axi4_lite_tb_intf.MONITOR_MOD           mon_if;

    lite_intc_seq_item                              sq_itm_h,aw_pkt,w_pkt,b_pkt,ar_pkt,r_pkt;
    intc_config_obj                                 obj;

    lite_intc_seq_item  wr_addr_queue[$],rd_addr_queue[$],wr_data_queue[$],rd_data_queue[$],wr_resp_queue[$];

   extern function void build_phase              	(uvm_phase phase);
   extern function void connect_phase            	(uvm_phase phase);
   extern function void end_of_elaboration_phase 	(uvm_phase phase);
   extern function void start_of_simulation_phase	(uvm_phase phase);
   extern function void extract_phase            	(uvm_phase phase);
   extern function void check_phase              	(uvm_phase phase);
   extern function void report_phase             	(uvm_phase phase);
   extern function void final_phase              	(uvm_phase phase);
   extern task main_phase                         	(uvm_phase phase);
   extern task mon_write_address					();
   extern task mon_write_data						();
   extern task mon_write_resp						();
   extern task mon_read_address						();
   extern task mon_read_data						();
   extern task merge_write							();
   extern task merge_read							();

endclass 

  function void lite_intc_monitor :: build_phase (uvm_phase phase);
     super.build_phase (phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")

        mon_ap 			= new ("mon_ap",this);
        `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : build_phase

  function void lite_intc_monitor :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void lite_intc_monitor :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void lite_intc_monitor :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void lite_intc_monitor :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void lite_intc_monitor :: check_phase (uvm_phase phase);
     super.check_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void lite_intc_monitor :: report_phase (uvm_phase phase);
     super.report_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void lite_intc_monitor :: final_phase (uvm_phase phase);
     super.final_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

    task lite_intc_monitor :: main_phase (uvm_phase phase);
        `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)

        fork
            forever begin
                @(mon_if.axil_mon_cb);        
                fork
                    mon_write_address();
                    mon_write_data();
                    mon_write_resp();
                join
                merge_write();
            end
            forever begin
                @(mon_if.axil_mon_cb);   
                fork
                    mon_read_address();
                    mon_read_data();
                join
                merge_read();
            end
        join
 
    endtask:main_phase

    task lite_intc_monitor :: mon_write_address();
        wait(mon_if.axil_mon_cb.AWVALID && mon_if.axil_mon_cb.AWREADY) begin
            aw_pkt = lite_intc_seq_item :: type_id :: create ("aw_pkt");
            aw_pkt.AWADDR       = mon_if.axil_mon_cb.AWADDR;
            aw_pkt.operation        = lite_intc_seq_item::WRITE;
            `uvm_info("axi4_lite_intc_mon_AW",$sformatf("write_address = %0h,operation=%s",aw_pkt.AWADDR,aw_pkt.operation.name),UVM_NONE)
            wr_addr_queue.push_back(aw_pkt);
        end
    endtask

    task lite_intc_monitor :: mon_write_data();
        wait(mon_if.axil_mon_cb.WVALID && mon_if.axil_mon_cb.WREADY) begin
            w_pkt = lite_intc_seq_item :: type_id :: create ("w_pkt");
            w_pkt.WDATA      = mon_if.axil_mon_cb.WDATA;
            w_pkt.WSTRB      = mon_if.axil_mon_cb.WSTRB;
            `uvm_info("axi4_lite_intc_mon_WD",$sformatf("write_data = %0h",w_pkt.WDATA),UVM_LOW)
            wr_data_queue.push_back(w_pkt);
        end
    endtask

    task lite_intc_monitor :: mon_write_resp();
        wait(mon_if.axil_mon_cb.BVALID && mon_if.axil_mon_cb.BREADY) begin
            b_pkt = lite_intc_seq_item :: type_id :: create ("b_pkt");
            b_pkt.BRESP      = mon_if.axil_mon_cb.BRESP;
            `uvm_info("axi4_lite_intc_mon_BR",$sformatf("write_bresp = %b",b_pkt.BRESP),UVM_LOW)
            wr_resp_queue.push_back(b_pkt);
        end
    endtask

    task lite_intc_monitor :: mon_read_address();
        wait(mon_if.axil_mon_cb.ARVALID && mon_if.axil_mon_cb.ARREADY) begin
            ar_pkt = lite_intc_seq_item :: type_id :: create ("ar_pkt");
            ar_pkt.ARADDR       = mon_if.axil_mon_cb.ARADDR;
            ar_pkt.operation        = lite_intc_seq_item::READ;
            `uvm_info("axi4_lite_intc_mon_AR",$sformatf("read_address = %0h,operation=%s",ar_pkt.ARADDR,ar_pkt.operation),UVM_LOW)
            rd_addr_queue.push_back(ar_pkt); 
        end
    endtask

    task lite_intc_monitor :: mon_read_data();
        wait(mon_if.axil_mon_cb.RVALID && mon_if.axil_mon_cb.RREADY) begin
            r_pkt = lite_intc_seq_item :: type_id :: create ("r_pkt");
            r_pkt.RDATA      = mon_if.axil_mon_cb.RDATA;
            r_pkt.RRESP      = mon_if.axil_mon_cb.RRESP;
            `uvm_info("axi4_lite_intc_mon_RD",$sformatf("rdata = %0h",r_pkt.RDATA),UVM_LOW)
            rd_data_queue.push_back(r_pkt);
        end 
    endtask

    task lite_intc_monitor :: merge_write();
        lite_intc_seq_item w_merge = lite_intc_seq_item :: type_id :: create("w_merge");
        if(wr_addr_queue.size() > 0 && wr_data_queue.size() > 0 && wr_resp_queue.size() > 0 )
            begin
                w_merge.ARESETn	= mon_if.ARESETn;
                w_merge.AWADDR 	= wr_addr_queue[0].AWADDR;
                w_merge.WDATA 	= wr_data_queue[0].WDATA;
                w_merge.WSTRB 	= wr_data_queue[0].WSTRB;
                w_merge.BRESP 	= wr_resp_queue[0].BRESP;
                //w_merge.operation 		= wr_addr_queue[0].operation;
                w_merge.operation       = lite_intc_seq_item::WRITE;
                void'(wr_addr_queue.pop_front);
                void'(wr_data_queue.pop_front);
                void'(wr_resp_queue.pop_front);
                `uvm_info("AXI4_Lite_INTC_MON_MERGE_WRITE",w_merge.sprint(),UVM_LOW)
                mon_ap.write(w_merge);
            end
    endtask

    task lite_intc_monitor :: merge_read();
        lite_intc_seq_item r_merge = lite_intc_seq_item :: type_id :: create("r_merge");
        if(rd_addr_queue.size() > 0 && rd_data_queue.size() > 0 )
            begin
                r_merge.ARADDR    = rd_addr_queue[0].ARADDR;
                r_merge.RDATA     = rd_data_queue[0].RDATA;
		        r_merge.RRESP 	  = rd_data_queue[0].RRESP;
                //r_merge.operation         = rd_addr_queue[0].operation;
                r_merge.operation         = lite_intc_seq_item::READ;
                void'(rd_addr_queue.pop_front);
                void'(rd_data_queue.pop_front);
                `uvm_info("AXI4_Lite_INTC_MON_MERGE_READ",r_merge.sprint(),UVM_LOW)
                mon_ap.write(r_merge);
            end
    endtask
