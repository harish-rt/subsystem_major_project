class lite_intc_monitor extends uvm_monitor;
    `uvm_component_utils(lite_intc_monitor)
    `NEW_COMP
    
    lite_intc_seq_item                          sq_itm_h;
    lite_intc_seq_item                          dummy_seq;

    intc_config_obj obj;

    uvm_analysis_port #(lite_intc_seq_item)     mon_ap;
	uvm_analysis_port #(lite_intc_seq_item)	    mon_seqr_ap;
   
	virtual axi4_lite_intc_intf					mon_if;
	virtual intc_intf							intc_if;
   lite_intc_seq_item wr_addr_queue[$],rd_addr_queue[$],wr_data_queue[$],rd_data_queue[$],wr_resp_queue[$];

   extern function void build_phase              	(uvm_phase phase);
   extern function void connect_phase            	(uvm_phase phase);
   extern function void end_of_elaboration_phase 	(uvm_phase phase);
   extern function void start_of_simulation_phase	(uvm_phase phase);
   extern function void extract_phase            	(uvm_phase phase);
   extern function void check_phase              	(uvm_phase phase);
   extern function void report_phase             	(uvm_phase phase);
   extern function void final_phase              	(uvm_phase phase);
   extern task main_phase                         	(uvm_phase phase);
   extern task mon_write_address									();
   extern task mon_write_data											();
   extern task mon_write_resp											();
   extern task mon_read_address										();
   extern task mon_read_data											();
   extern task merge_write												();
   extern task merge_read													();
	 extern task irq_capture												();

endclass 

  function void lite_intc_monitor :: build_phase (uvm_phase phase);
     super.build_phase (phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")
            mon_ap 			= new ("mon_ap",this);
		    mon_seqr_ap	    = new ("mon_seqr_ap",this);
		    dummy_seq		= lite_intc_seq_item :: type_id :: create("dummy_seq");
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
                @(posedge mon_if.aclk);        
                fork
                    mon_write_address();  
                    mon_write_data();
                    mon_write_resp();
                join
                merge_write();
            end
            forever begin
                @(posedge mon_if.aclk);   
                fork
                    mon_read_address();
                    mon_read_data();
                join
                merge_read();
            end
      		forever
      		    begin
      			    irq_capture();
      		    end
            join
 
    endtask:main_phase

    task lite_intc_monitor :: mon_write_address();
        wait(mon_if.axi_awvalid && mon_if.axi_awready) begin
            sq_itm_h = lite_intc_seq_item :: type_id :: create ("sq_itm_h");
            sq_itm_h.axi_awaddr = mon_if.axi_awaddr;
            sq_itm_h.write = lite_intc_seq_item::WRITE;
            //`uvm_info("axi_4_lite_mon_AW",$sformatf("write_address = %0h,write=%s",sq_itm_h.axi_awaddr,sq_itm_h.write.name),UVM_NONE)
            wr_addr_queue.push_back(sq_itm_h);
        end
    endtask

    task lite_intc_monitor :: mon_write_data();
        wait(mon_if.axi_wvalid && mon_if.axi_wready) begin
            sq_itm_h = lite_intc_seq_item :: type_id :: create ("sq_itm_h");
            sq_itm_h.axi_wdata = mon_if.axi_wdata;
            sq_itm_h.axi_wstrb = mon_if.axi_wstrb;
            //`uvm_info("axi_4_lite_mon_WD",$sformatf("write_data = %0d",sq_itm_h.axi_wdata),UVM_LOW)
            wr_data_queue.push_back(sq_itm_h);
        end
    endtask

    task lite_intc_monitor :: mon_write_resp();
        wait(mon_if.axi_bvalid && mon_if.axi_bready) begin
            sq_itm_h = lite_intc_seq_item :: type_id :: create ("sq_itm_h");
            sq_itm_h.axi_bresp = mon_if.axi_bresp;
            //`uvm_info("axi_4_lite_mon_bresp",$sformatf("write_bresp = %b",sq_itm_h.axi_bresp),UVM_LOW)
            wr_resp_queue.push_back(sq_itm_h);
        end
    endtask

    task lite_intc_monitor :: mon_read_address();
        wait(mon_if.axi_arvalid && mon_if.axi_arready) begin
            sq_itm_h = lite_intc_seq_item :: type_id :: create ("sq_itm_h");
            sq_itm_h.axi_araddr = mon_if.axi_araddr;
            sq_itm_h.write = lite_intc_seq_item::READ;
            //`uvm_info("axi_4_lite_mon_read_addr",$sformatf("read_address = %0h,write=%s",sq_itm_h.axi_araddr,sq_itm_h.write),UVM_LOW)
            rd_addr_queue.push_back(sq_itm_h); 
        end
    endtask

    task lite_intc_monitor :: mon_read_data();
        wait(mon_if.axi_rvalid && mon_if.axi_rready) begin
            sq_itm_h = lite_intc_seq_item :: type_id :: create ("sq_itm_h");
            sq_itm_h.axi_rdata = mon_if.axi_rdata;
            sq_itm_h.axi_rresp = mon_if.axi_rresp;
            //`uvm_info("axi_4_lite_mon_read_data",$sformatf("rdata = %0d",sq_itm_h.axi_rdata),UVM_LOW)
            rd_data_queue.push_back(sq_itm_h);
        end 
    endtask

    task lite_intc_monitor :: merge_write();
        lite_intc_seq_item s_merge_h = lite_intc_seq_item :: type_id :: create("s_merge_h");
        if(wr_addr_queue.size() > 0 && wr_data_queue.size() > 0 && wr_resp_queue.size() > 0 )
            begin
                s_merge_h.axi_areset_n	    = mon_if.areset_n;
                s_merge_h.axi_awaddr 		= wr_addr_queue[0].axi_awaddr;
                s_merge_h.axi_wdata 		= wr_data_queue[0].axi_wdata;
                s_merge_h.axi_wstrb 		= wr_data_queue[0].axi_wstrb;
                //s_merge_h.axi_wstrb 		= sq_itm_h.axi_wstrb;
                s_merge_h.axi_bresp 		= wr_resp_queue[0].axi_bresp;
                s_merge_h.write 		    = wr_addr_queue[0].write;
                void'(wr_addr_queue.pop_front);
                void'(wr_data_queue.pop_front);
                void'(wr_resp_queue.pop_front);
                `uvm_info("axi_4_lite_mon_WRITE",s_merge_h.sprint(),UVM_LOW)
                mon_ap.write(s_merge_h);
            end
    endtask

    task lite_intc_monitor :: merge_read();
        lite_intc_seq_item s_merge_h = lite_intc_seq_item :: type_id :: create("s_merge_h");
        if(rd_addr_queue.size() > 0 && rd_data_queue.size() > 0 )
            begin
                s_merge_h.axi_araddr    = rd_addr_queue[0].axi_araddr;
                s_merge_h.axi_rdata     = rd_data_queue[0].axi_rdata;
		        s_merge_h.axi_rresp 	= rd_data_queue[0].axi_rresp;
                s_merge_h.write         = rd_addr_queue[0].write;
                void'(rd_addr_queue.pop_front);
                void'(rd_data_queue.pop_front);
                `uvm_info("axi_4_lite_mon_READ",s_merge_h.sprint(),UVM_LOW)
                mon_ap.write(s_merge_h);
            end
    endtask

	task lite_intc_monitor :: irq_capture();
		@(posedge intc_if.intc_procss_clk);
		@(posedge intc_if.intc_irq)
			begin
				mon_seqr_ap.write(dummy_seq);
			end
	endtask
