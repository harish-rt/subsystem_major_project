/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_driver.sv                        */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2022                       */
/*                                                                        */
/* All Rights Reserved                                                    */
/*                                                                        */
/* NOTICE: All information contained herein is, and remains the           */
/* property of Raiton semiconductor PVT. LTD. and its suppliers           */
/* ,if any.  The intellectual and  technical concepts contained           */
/* herein  are proprietary to  Raiton  semiconductor  PVT. LTD.           */
/* they are protected  by trade secrets and / or copyright law.           */
/* Dissemination of this  information  or reproduction of  this           */
/* material or code is strictly forbidden unless  prior written           */
/* permission is obtained from Raiton semiconductor PVT. LTD.             */
/*                                                                        */
/* RAITON_COPYRIGHT_END                                                   */
// callbacks--


/*class master_driver_callback extends uvm_callback;
   `uvm_object_utils(master_driver_callback)
	 

   function new (string name = "master_driver_callback");
      super.new(name);
   endfunction

   virtual task pre_drive (master_seq_item pkt);
     `uvm_info (get_full_name () , "pre_drive :: executing master_driver call back" , UVM_LOW)
   endtask : pre_drive
   virtual task post_drive (master_seq_item pkt);
     `uvm_info (get_full_name () , "post_drive :: executing master_driver call back" , UVM_LOW)
   endtask : post_drive
endclass : master_driver_callback

class master_driver extends uvm_driver #(master_seq_item,master_seq_item);
   `uvm_component_utils (master_driver)
   `uvm_register_cb (master_driver , master_driver_callback)
   virtual master_intf.DRV_MOD_master        master_drv_intf;
   mailbox #(master_seq_item) waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx; // mailboxes for read/write channels
	 bit bresp_trigger, rresp_trigger;

   function new (string name = "master_driver" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern task main_phase  (uvm_phase phase);
   extern task reset_phase (uvm_phase phase);
   extern task get_packet ();
   extern task drive_write_add ();
   extern task drive_write_data ();
   extern task drive_read_add ();
   extern task drive_read_data ();
   extern task drive_write_resp ();

endclass :master_driver


task master_driver :: reset_phase (uvm_phase phase);  //drive initial values to 0 at 0 time
   `uvm_info (get_full_name(), phase.get_name() , UVM_MEDIUM)
		@( master_drv_intf.mas_drv_cb);
   `uvm_info(get_full_name(),"........master_driver.......reset_phase Driving initial values to interface", UVM_LOW);
    phase.raise_objection(this);
     master_drv_intf.mas_drv_cb.awaddr 	<= 'b0;
     master_drv_intf.mas_drv_cb.awburst <= 'b0;
     master_drv_intf.mas_drv_cb.awcache <= 'b0;
     master_drv_intf.mas_drv_cb.awid 	<= 'b0;
     master_drv_intf.mas_drv_cb.awlen 	<= 'b0;
     master_drv_intf.mas_drv_cb.awlock 	<= 'b0;
     master_drv_intf.mas_drv_cb.awprot 	<= 'b0;
     master_drv_intf.mas_drv_cb.awqos 	<= 'b0;
     master_drv_intf.mas_drv_cb.awregion<= 'b0;
     master_drv_intf.mas_drv_cb.awsize 	<= 'b0;
     master_drv_intf.mas_drv_cb.awvalid <= 'b0;
     master_drv_intf.mas_drv_cb.bready 	<= 'b0;
     master_drv_intf.mas_drv_cb.rready 	<= 'b0;
     master_drv_intf.mas_drv_cb.wdata 	<= 'b0;
     master_drv_intf.mas_drv_cb.wlast 	<= 'b0;
     master_drv_intf.mas_drv_cb.wstrobe <= 'b0;
     master_drv_intf.mas_drv_cb.wvalid 	<= 'b0;
     master_drv_intf.mas_drv_cb.araddr 	<= 'b0;
     master_drv_intf.mas_drv_cb.arburst <= 'b0;
     master_drv_intf.mas_drv_cb.arcache <= 'b0;
     master_drv_intf.mas_drv_cb.arid 	<= 'b0;
     master_drv_intf.mas_drv_cb.arlen 	<= 'b0;
     master_drv_intf.mas_drv_cb.arlock 	<= 'b0;
     master_drv_intf.mas_drv_cb.arprot	<= 'b0;
     master_drv_intf.mas_drv_cb.arqos   <= 'b0;
     master_drv_intf.mas_drv_cb.arregion<= 'b0;
     master_drv_intf.mas_drv_cb.arsize  <= 'b0;
     master_drv_intf.mas_drv_cb.arvalid <= 'b0;
     wait(master_drv_intf.areset_n == 1);
     phase.drop_objection(this);
endtask :reset_phase


task master_driver :: main_phase (uvm_phase phase);
  `uvm_info (get_full_name(), "main_phase" , UVM_MEDIUM);
  fork
    get_packet();
    drive_write_add();
    drive_write_data();
    drive_read_add();
    drive_read_data();
    drive_write_resp();
  join
endtask : main_phase

task master_driver :: get_packet(); // to get new packets from seq and populate respective queues with relevent data.
    master_seq_item pkt,local_pkt;
    //axi4_lite_seq_item pkt,local_pkt;
    

    waddress_mbx =new();
    wdata_mbx    =new();
    raddress_mbx =new();
    rdata_mbx    =new();
    wresponse_mbx=new();

    `uvm_info(get_full_name(),"MI get_packet_task -- task triggred",  UVM_LOW);
    forever begin

    //wait( waddress_mbx.num() == 0 && wdata_mbx.num() == 0 && raddress_mbx.num() == 0 && rdata_mbx.num() == 0);
  	seq_item_port.get_next_item(pkt);
    	//pre_drive task to corrupt packet
    	`uvm_info("master_driver :: get_packet()",$sformatf("After get next item "),  UVM_LOW);
      
    	`uvm_do_callbacks(master_driver,master_driver_callback,pre_drive(pkt));
    	`uvm_info(get_full_name(),$sformatf("MI get_packet_task -- operation = %s",pkt.operation.name()),  UVM_LOW);
        //`uvm_info("driver_pkt",pkt.sprint(),UVM_MEDIUM) //------------- print all address
    	//DRIVE TO INTERFACE
    	//`uvm_info(get_full_name(), "pkt at master_driver  -- trying to print packet",UVM_LOW)
    	if(pkt.operation == WRITE ) begin
           $cast(local_pkt,pkt.clone());
        //   `uvm_info("after cast get_pkt ",local_pkt.sprint(),UVM_MEDIUM)  //--------------
      	    waddress_mbx.put(local_pkt);
            wdata_mbx.put(local_pkt);
						wait(bresp_trigger == 1'b1);

			      pkt.bresp= master_drv_intf.mas_drv_cb.bresp;
       			//$display("Driver:AWADDR:%0h --- WDATA:%0h",pkt.awaddr, pkt.wdata[0]);
            seq_item_port.put_response(pkt);


    	      seq_item_port.item_done(pkt);
						@( master_drv_intf.mas_drv_cb);
						bresp_trigger = 'b0;
						 //wait here bresp signal trigger
						// make that bit again 0
    	end
    	if(pkt.operation == READ) begin
           $cast(local_pkt,pkt.clone());
   	   raddress_mbx.put(local_pkt);
   	   rdata_mbx.put(local_pkt);
			 wait(rresp_trigger == 1'b1);
			 //rsp.araddr = pkt.araddr;
			 pkt.rdata = new[1];
			 pkt.rdata[0]= master_drv_intf.mas_drv_cb.rdata;

       pkt.rresp = new[1];
			 pkt.rresp[0]= master_drv_intf.mas_drv_cb.rresp;
      // $display("Driver:ARADDR:%0h --- RDATA:%0h",pkt.araddr, pkt.rdata[0]);
       seq_item_port.put_response(pkt);
    	 seq_item_port.item_done(pkt);
			 @(master_drv_intf.mas_drv_cb);
			 rresp_trigger = 'b0;
				//wait rresp trigger
    	end
      

    //wait( waddress_mbx.num() == 0 && wdata_mbx.num() == 0 && raddress_mbx.num() == 0 && rdata_mbx.num() == 0 && wresponse_mbx.num() == 0); 
    	`uvm_info(get_full_name(),"MI get_packet_task -- after item done", UVM_LOW);
   
   end
endtask

//drive tasks for phases

task master_driver :: drive_write_add();   //assert address information on write address channel
 master_seq_item pkt;
 `uvm_info(get_full_name(),"MI_drive_write_add -- task triggred",  UVM_LOW);
 forever begin
   pkt = master_seq_item :: type_id ::create("pkt");
   waddress_mbx.get(pkt); //blocking statement
  //repeat(pkt.cmd2cmd_dly) @( master_drv_intf.mas_drv_cb);
// $display("#######################################VALID IS HIGH before########################");
     repeat(pkt.add_valid_dly)  @( master_drv_intf.mas_drv_cb);
     `uvm_info(get_full_name(),"MI_drive_write_add -- Got pkt and then after cmd2cmd delay and then gonna drvive info and addr",  UVM_LOW);
    //`uvm_info("after getting pkt in driver write_add task",pkt.sprint(),UVM_MEDIUM)  //--------------
     master_drv_intf.mas_drv_cb.awaddr   <= pkt.awaddr;
  //   `uvm_info("master_driver_write_add",$sformatf("master_driver_write_address=%0h",master_drv_intf.mas_drv_cb.awaddr),UVM_LOW)
     master_drv_intf.mas_drv_cb.awburst  <= pkt.awburst;
     master_drv_intf.mas_drv_cb.awcache  <= pkt.awcache;
     master_drv_intf.mas_drv_cb.awid     <= pkt.awid;
     master_drv_intf.mas_drv_cb.awlen    <= pkt.awlen;
     master_drv_intf.mas_drv_cb.awlock   <= pkt.awlock;
     master_drv_intf.mas_drv_cb.awprot   <= pkt.awprot;
     master_drv_intf.mas_drv_cb.awqos    <= pkt.awqos;
     master_drv_intf.mas_drv_cb.awregion <= pkt.awregion;
     master_drv_intf.mas_drv_cb.awsize   <= pkt.awsize;   

    
    
//	 master_drv_intf.mas_drv_cb.awvalid  <= 1 ;
    // repeat(pkt.add_valid_dly) @( master_drv_intf.mas_drv_cb);
//	 $display("#######################################VALID IS HIGH########################");
     master_drv_intf.mas_drv_cb.awvalid  <= 1 ;
  //  repeat(4)
     //repeat(pkt.add_valid_dly) @( master_drv_intf.mas_drv_cb);
     @( master_drv_intf.mas_drv_cb);
     wait(master_drv_intf.mas_drv_cb.awready ==1);
     master_drv_intf.mas_drv_cb.awvalid  <= 0 ;
     `uvm_info(get_full_name(),"MI_drive_write_add -- got handshake",  UVM_LOW);
 end
endtask

task master_driver :: drive_read_add();
 master_seq_item pkt;
 `uvm_info(get_full_name(),"MI_drive_read_add -- task triggred",  UVM_LOW);
 forever begin
     pkt = master_seq_item :: type_id ::create("pkt");
     raddress_mbx.get(pkt); //must be blocking statement
     repeat(pkt.cmd2cmd_dly) @( master_drv_intf.mas_drv_cb);
     `uvm_info(get_full_name(),"MI_drive_read_add -- Got pkt and then cmd2cmd delay done and then gonna drive info and addr",  UVM_LOW);
     //assert address information on read address channel
     master_drv_intf.mas_drv_cb.araddr   <= pkt.araddr;
     //`uvm_info("master_driver_read_add",$sformatf("master_driver_read_address=%0h",master_drv_intf.mas_drv_cb.araddr),UVM_LOW)
     //`uvm_info("master_driver_read_add",$sformatf("master_driver_read_address=%0h",pkt.araddr),UVM_LOW)
     
     master_drv_intf.mas_drv_cb.arburst  <= pkt.arburst;
     master_drv_intf.mas_drv_cb.arcache  <= pkt.arcache;
     master_drv_intf.mas_drv_cb.arid     <= pkt.arid;
     master_drv_intf.mas_drv_cb.arlen    <= pkt.arlen;
     master_drv_intf.mas_drv_cb.arlock   <= pkt.arlock;
     master_drv_intf.mas_drv_cb.arprot   <= pkt.arprot;
     master_drv_intf.mas_drv_cb.arqos    <= pkt.arqos;
     master_drv_intf.mas_drv_cb.arregion <= pkt.arregion;
     master_drv_intf.mas_drv_cb.arsize   <= pkt.arsize;   

     

     //repeat(pkt.add_valid_dly) @( master_drv_intf.mas_drv_cb);
  //    @( master_drv_intf.mas_drv_cb);
     master_drv_intf.mas_drv_cb.arvalid  <= 1'b1 ;
     @( master_drv_intf.mas_drv_cb);
     wait(master_drv_intf.mas_drv_cb.arready ==1);
     master_drv_intf.mas_drv_cb.arvalid  <= 0 ;
     `uvm_info(get_full_name(),"MI_drive_read_add -- got handshake",  UVM_LOW);
 end
endtask

task master_driver :: drive_write_resp();  //will trigger after data phase  // figure out what to do when this phase is triggred multiple times without the last one completing.
  master_seq_item pkt;
  `uvm_info(get_full_name(),"MI_drive_write_resp --end task triggred",  UVM_LOW);
  forever begin
    pkt = master_seq_item :: type_id ::create("pkt");
    //wresponse_mbx.get(pkt);
    //repeat(pkt.resp_ready_dly) @( master_drv_intf.mas_drv_cb);
    @(master_drv_intf.mas_drv_cb);
    master_drv_intf.mas_drv_cb.bready <= 1;
    @(master_drv_intf.mas_drv_cb);
    `uvm_info(get_full_name(),"MI_drive_write_resp -- Got pkt and then driven ready and then gonna wait for valid",  UVM_LOW);
    wait(master_drv_intf.mas_drv_cb.bvalid ==1);

    //pkt.bresp = master_drv_intf.mas_drv_cb.bresp;
    //seq_item_port.put_response(pkt);

    `uvm_info(get_full_name(),"MI_drive_write_resp --  got handshake",  UVM_LOW);
    master_drv_intf.mas_drv_cb.bready <= 0;
		// make 1 bit as 1;
		bresp_trigger = 1'b1;
    //seq_item_port.put_response(pkt);
    `uvm_do_callbacks(master_driver,master_driver_callback,post_drive(pkt));    //post drive callback
    `uvm_info(get_full_name(),"MI_drive_write_resp --  task done",  UVM_LOW);
  end
endtask

task master_driver :: drive_write_data();
 master_seq_item pkt;
 `uvm_info(get_full_name(),"MI_drive_write_data -- task triggred",  UVM_LOW);
 forever begin
   pkt = master_seq_item :: type_id ::create("pkt");
   wdata_mbx.get(pkt); //must be blocking statement
   repeat(pkt.add2data_dly) @( master_drv_intf.mas_drv_cb);
   `uvm_info(get_full_name(),"MI_drive_write_data -- Got pkt and then after addr2data delay and then gonna drive data",  UVM_LOW);
   for(int i=0;i<=pkt.awlen;i++) begin
   	repeat(pkt.write_valid2valid_dly[i]) @( master_drv_intf.mas_drv_cb);
   	master_drv_intf.mas_drv_cb.wdata   <= pkt.wdata[i];
     //`uvm_info("master_driver_write_data",$sformatf("master_driver_write_data=%0h",master_drv_intf.mas_drv_cb.wdata ),UVM_LOW)
   	master_drv_intf.mas_drv_cb.wstrobe <= pkt.wstrobe[i];
   	master_drv_intf.mas_drv_cb.wlast   <= (i== pkt.awlen ) ? 1'b1 : 1'b0;
   	master_drv_intf.mas_drv_cb.wvalid  <= 1;
   	@( master_drv_intf.mas_drv_cb);
   	wait(master_drv_intf.mas_drv_cb.wready ==1);
   //	@( master_drv_intf.mas_drv_cb);
   	master_drv_intf.mas_drv_cb.wvalid  <= 0;
   	master_drv_intf.mas_drv_cb.wlast   <= 0;
   end
   wresponse_mbx.put(pkt);
   `uvm_info(get_full_name(),$sformatf("MI_drive_write_data -- After driving all data till last data for awlen=%d",pkt.awlen), UVM_LOW);
 end
endtask

task master_driver :: drive_read_data();
 master_seq_item pkt;
 int i;
 bit got_rlast;
 `uvm_info(get_full_name(),"MI_drive_read_data -- task triggred",  UVM_LOW);
 forever begin
   pkt = master_seq_item :: type_id ::create("pkt");
   rdata_mbx.get(pkt);
   i=0; got_rlast=0;
   `uvm_info(get_full_name(),"MI_drive_read_data -- Got pkt and gonna drive ready till got last data for SI handshake response",  UVM_LOW);
//   do begin
   	//repeat(pkt.read_ready2ready_dly[i]) @(master_drv_intf.mas_drv_cb);
   	repeat(5) @(master_drv_intf.mas_drv_cb);
    	master_drv_intf.mas_drv_cb.rready <= 1;
			@( master_drv_intf.mas_drv_cb);
    	wait(master_drv_intf.mas_drv_cb.rvalid ==1);

     //	master_drv_intf.mas_drv_cb.rready <= 1;		//doubt
    //	if(master_drv_intf.mas_drv_cb.rlast==1) got_rlast=1; // indicates last beat
        //@( master_drv_intf.mas_drv_cb);
    	master_drv_intf.mas_drv_cb.rready <= 0;
    	i=i+1;
//   end while (got_rlast==0);
	 rresp_trigger = 1'b1;
   `uvm_do_callbacks(master_driver,master_driver_callback,post_drive(pkt));   //post drive callback
   `uvm_info(get_full_name(),"MI_drive_read_data -- Last data read was done task ended",  UVM_LOW);
 end
endtask*/





class master_driver extends uvm_driver #(master_seq_item,master_seq_item);
   `uvm_component_utils (master_driver)
   virtual axi_cdma_axi_master_intf.DRV_MOD_master        master_drv_intf;
   mailbox #(master_seq_item)waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx;

    axi_cdma_config_obj          obj;
    master_seq_item     pkt;

   function new (string name = "master_driver", uvm_component parent);
      super.new(name,parent);
   endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(axi_cdma_config_obj) :: get(this, "", "axi_cdma_config_obj", obj))begin
            `uvm_fatal (get_full_name(), "config_db_not_accessable");
        end
        waddress_mbx   = new();
        wdata_mbx      = new();
        wresponse_mbx  = new();
        raddress_mbx   = new();
        rdata_mbx      = new();
    endfunction

    task reset_phase(uvm_phase phase);
      `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
      `uvm_info(get_full_name(),"AXI-Lite reset_phase: Driving initial values to interface", UVM_LOW);
      master_drv_intf.mas_drv_cb.awaddr  <= 'b0;
      master_drv_intf.mas_drv_cb.awvalid <= 'b0;
      master_drv_intf.mas_drv_cb.wdata   <= 'b0;
      master_drv_intf.mas_drv_cb.wstrobe <= 'b0;
      master_drv_intf.mas_drv_cb.wvalid  <= 'b0;
      master_drv_intf.mas_drv_cb.bready  <= 'b0;
      master_drv_intf.mas_drv_cb.araddr  <= 'b0;
      master_drv_intf.mas_drv_cb.arvalid <= 'b0;
      master_drv_intf.mas_drv_cb.rready  <= 'b0;
    endtask : reset_phase
    
    task main_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "main_phase", UVM_MEDIUM);
        wait(master_drv_intf.areset_n);
        forever begin
            @(master_drv_intf.mas_drv_cb);
            seq_item_port.get_next_item(pkt);
            if (pkt.operation == WRITE) begin
                fork
                    drive_write_add();
                    drive_write_data();
                    drive_write_resp();
                join
            end else begin
                fork
                    drive_read_add();
                    drive_read_data();
                join
            end
            seq_item_port.item_done(pkt);
        end
    endtask: main_phase
    
    task drive_write_add();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- task triggered", UVM_LOW);
        master_drv_intf.mas_drv_cb.awaddr  <= pkt.awaddr;
        master_drv_intf.mas_drv_cb.awvalid <= 1;
        wait(master_drv_intf.mas_drv_cb.awready == 1);
    
        //@(master_drv_intf.mas_drv_cb);
        master_drv_intf.mas_drv_cb.awvalid <= 0;
        master_drv_intf.mas_drv_cb.awaddr  <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- address handshake complete", UVM_LOW);
    endtask
    
    task drive_write_data();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- task triggered", UVM_LOW);
        master_drv_intf.mas_drv_cb.wdata   <= pkt.wdata[0];
        master_drv_intf.mas_drv_cb.wvalid  <= 1;
        wait(master_drv_intf.mas_drv_cb.wready == 1);
    
        //@(master_drv_intf.mas_drv_cb);
        master_drv_intf.mas_drv_cb.wvalid  <= 0;
        master_drv_intf.mas_drv_cb.wdata   <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- data handshake complete", UVM_LOW);
    endtask
    
    task drive_write_resp();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- task triggered", UVM_LOW);
        master_drv_intf.mas_drv_cb.bready <= 1;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- waiting for BVALID", UVM_LOW);
        wait(master_drv_intf.mas_drv_cb.bvalid == 1);
        pkt.bresp = response_t'(master_drv_intf.mas_drv_cb.bresp);
    
        @(master_drv_intf.mas_drv_cb);
        master_drv_intf.mas_drv_cb.bready <= 0;
        //seq_item_port.put_response(pkt);
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- transaction complete", UVM_LOW);
        `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_MEDIUM)
    endtask
    
    
    task drive_read_add();
        `uvm_info(get_full_name(),"MI_drive_read_add -- task triggered", UVM_LOW);
        master_drv_intf.mas_drv_cb.araddr  <= pkt.araddr;
        master_drv_intf.mas_drv_cb.arvalid <= 1;
        wait(master_drv_intf.mas_drv_cb.arready == 1);
    
        //@(master_drv_intf.mas_drv_cb);
        master_drv_intf.mas_drv_cb.arvalid <= 0;
        master_drv_intf.mas_drv_cb.araddr  <= 'h0;
        `uvm_info(get_full_name(),"MI_drive_read_add -- address handshake complete", UVM_LOW);
    endtask
    
    task drive_read_data();
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- task triggered", UVM_LOW);
        master_drv_intf.mas_drv_cb.rready <= 1;
       // wait (master_drv_intf.mas_drv_cb.rvalid == 1);

        do begin
           @(master_drv_intf.mas_drv_cb);
        end while(master_drv_intf.mas_drv_cb.rvalid != 1);
        if (pkt.rdata.size() == 0) pkt.rdata = new[1];

        //@(master_drv_intf.mas_drv_cb);
        pkt.rdata[0] = master_drv_intf.mas_drv_cb.rdata;
        pkt.rresp[0] = response_t'(master_drv_intf.mas_drv_cb.rresp);
    
        //@(master_drv_intf.mas_drv_cb);
        master_drv_intf.mas_drv_cb.rready <= 0;
        //seq_item_port.put_response(pkt);    
        //`uvm_info("driver_pkt_last",pkt.sprint(),UVM_MEDIUM)
    endtask
 endclass :master_driver


      

 
