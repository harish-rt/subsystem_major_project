
class master_driver extends uvm_driver #(master_seq_item);
   `uvm_component_utils (master_driver)
   int  trans_count;
   virtual master_interface.mi_drv_mod        m_drv_if;
   master_seq_item  drv_txn;

    function new (string name = "master_driver" , uvm_component parent);
      super.new(name,parent);
   endfunction
   
   task main_phase(uvm_phase phase);
     super.main_phase(phase);
     //@(m_drv_if.mi_drv_cb);		 
     forever begin
        @(m_drv_if.mi_drv_cb);		 

        seq_item_port.get_next_item(drv_txn);    
            
           if(drv_txn.Trans_type == WR) begin
             fork
                write_addr_phase();
                write_data_phase();
                write_resp_phase();
	           join
           end
					 
           if(drv_txn.Trans_type == RD) begin
            fork
                read_addr_phase();
                read_data_phase();  
             join
           end
        seq_item_port.item_done(drv_txn);
     end
    
   endtask


   task  reset_phase(uvm_phase phase);
     super.reset_phase(phase);
     m_drv_if.mi_drv_cb.AWVALID  <=   0;
     m_drv_if.mi_drv_cb.AWADDR   <=   0;
     m_drv_if.mi_drv_cb.WVALID   <=   0;
     m_drv_if.mi_drv_cb.WDATA    <=   0;
     m_drv_if.mi_drv_cb.BREADY   <=   0;
     m_drv_if.mi_drv_cb.ARVALID  <=   0;
     m_drv_if.mi_drv_cb.ARADDR   <=   0;
     m_drv_if.mi_drv_cb.RREADY   <=   0;
      
     wait(m_drv_if.ARESETn == 1);

   endtask


   task  write_addr_phase ();
  

     `uvm_info ("drv_axi_4_lite  :: write_addr_started ","",UVM_NONE)
   	 
      m_drv_if.mi_drv_cb.AWVALID <= 1'b1;

      m_drv_if.mi_drv_cb.AWADDR <= drv_txn.AWADDR;
      
      @(m_drv_if.mi_drv_cb);
      wait(m_drv_if.mi_drv_cb.AWREADY == 1'b1 ); 
      m_drv_if.mi_drv_cb.AWVALID <= 1'b0; 
    /// `uvm_info ("drv_axi_4_lite  :: write_addr_ended ",$sformatf("AWVALID = %0b", m_drv_if.AWVALID),UVM_NONE)
     `uvm_info ("drv_axi_4_lite  :: write_addr_ended ","",UVM_NONE)

   endtask

   task write_data_phase();

     `uvm_info ("drv_axi_4_lite  :: write_data_started ","",UVM_NONE)
    
      m_drv_if.mi_drv_cb.WVALID <= 1'b1;
      m_drv_if.mi_drv_cb.WDATA  <= drv_txn.WDATA;
      wait(m_drv_if.mi_drv_cb.WREADY == 1'b1);
      @(m_drv_if.mi_drv_cb);
      m_drv_if.mi_drv_cb.WVALID <= 1'b0;
      `uvm_info ("drv_axi_4_lite  :: write_data_ended ","",UVM_NONE)

   endtask
  
   task write_resp_phase();
 
     `uvm_info ("drv_axi_4_lite  :: write_resp_started ","",UVM_NONE)
	      m_drv_if.mi_drv_cb.BREADY  <=  1;
      wait(m_drv_if.mi_drv_cb.BVALID);
      drv_txn.BRESP = m_drv_if.mi_drv_cb.BRESP;
      @(m_drv_if.mi_drv_cb);
      m_drv_if.mi_drv_cb.BREADY  <=  0;
      seq_item_port.put_response(drv_txn);
      
     `uvm_info ("drv_axi_4_lite  :: write_resp_ended ","",UVM_NONE)

   endtask

   task read_addr_phase();
 
     `uvm_info ("drv_axi_4_lite  :: read_addr_started ","",UVM_NONE)
          m_drv_if.mi_drv_cb.ARVALID <= 1'b1;
	  @(m_drv_if.mi_drv_cb);

      m_drv_if.mi_drv_cb.ARADDR  <= drv_txn.ARADDR; 
      wait(m_drv_if.mi_drv_cb.ARREADY == 1'b1)
      @(m_drv_if.mi_drv_cb);
      m_drv_if.mi_drv_cb.ARVALID <= 1'b0;
     `uvm_info ("drv_axi_4_lite  :: read_addr_ended ","",UVM_NONE)

   endtask
   
   task read_data_phase();

     `uvm_info ("drv_axi_4_lite  :: read_data_started ","",UVM_NONE)

       m_drv_if.mi_drv_cb.RREADY  <= 1'b1;
       @(m_drv_if.mi_drv_cb);

       wait( m_drv_if.mi_drv_cb.RVALID);
      drv_txn.RRESP = m_drv_if.mi_drv_cb.RRESP;
      drv_txn.RDATA = m_drv_if.mi_drv_cb.RDATA;
       @(m_drv_if.mi_drv_cb);
   
      m_drv_if.mi_drv_cb.RREADY  <= 1'b0;
     seq_item_port.put_response(drv_txn);
     `uvm_info ("drv_axi_4_lite  :: read_data_ended ","",UVM_NONE)

   endtask

endclass


/*

class master_driver extends uvm_driver #(master_seq_item);
   `uvm_component_utils (master_driver)
   int  trans_count;
   virtual master_interface.mi_drv_mod        m_drv_if;
   master_seq_item  drv_txn;

   master_seq_item                            wr_addr_queue[$];
   master_seq_item                            wr_data_queue[$];
   master_seq_item                            wr_rsp_queue[$];
   master_seq_item                            rd_addr_queue[$];
   master_seq_item                            rd_data_queue[$];

   function new (string name = "master_driver" , uvm_component parent);
      super.new(name,parent);
   endfunction
   
   extern function void build_phase (uvm_phase phase);
   extern task reset_phase (uvm_phase  phase);
   extern task main_phase (uvm_phase phase);
   extern task initiate_transaction();
   extern task drive_transaction();
   extern task reset_signals();
   extern task drive_seq(master_seq_item);
   extern task wr_addr(master_seq_item);
   extern task wr_data(master_seq_item);
   extern task wr_rsp(master_seq_item);
   extern task rd_addr(master_seq_item);
   extern task rd_data(master_seq_item);
   semaphore          wa_key;
   semaphore          wd_key;
   semaphore          wr_key;
   semaphore          ra_key;
   semaphore          rd_key;
endclass: master_driver

 function void master_driver :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     wa_key = new(1);
     wd_key = new(1);
     wr_key = new(1);
     ra_key = new(1);
     rd_key = new(1);
  endfunction : build_phase
 
  task master_driver :: reset_phase (uvm_phase  phase);
      begin
        `uvm_info("master_driver","Start of master interface reset",UVM_LOW);
       
        //Interface signals initialization
	wait(m_drv_if.mi_drv_cb.ARESETn);

        m_drv_if.mi_drv_cb.AWADDR <= 6'd0;
        m_drv_if.mi_drv_cb.AWVALID <= 1'd0; 
        m_drv_if.mi_drv_cb.WDATA <= 32'd0;
        m_drv_if.mi_drv_cb.WVALID <= 1'd0;
        m_drv_if.mi_drv_cb.BREADY <= 1'd0;
        m_drv_if.mi_drv_cb.ARADDR <= 6'd0;
        m_drv_if.mi_drv_cb.ARVALID <= 1'd0;
        m_drv_if.mi_drv_cb.RREADY <= 1'd0;
             
        `uvm_info("master_driver","End of master interface reset",UVM_LOW);
      end
 endtask :reset_phase
  
 task master_driver :: main_phase (uvm_phase phase);
      `uvm_info("MASTER DRIVER","MAIN-PHASE START",UVM_LOW)
      fork
        initiate_transaction();
        drive_transaction();
      join
      `uvm_info("MASTER DRIVER","MAIN-PHASE END",UVM_LOW)
 endtask : main_phase
    
 task master_driver :: initiate_transaction();
      forever begin
         wait(m_drv_if.mi_drv_cb.ARESETn);
        `uvm_info("master_driver", "Requesting sequence item...", UVM_LOW)
         @(m_drv_if.mi_drv_cb);
        seq_item_port.get_next_item (req);
        `uvm_info("Received transaction at master driver......", req.sprint(), UVM_LOW);
        trans_count+=1;
        `uvm_info("master_driver",$sformatf("..........Transaction count = %d......", trans_count), UVM_LOW);
        $cast(drv_txn, req.clone());
        `uvm_info("cloned transaction at driver.........", drv_txn.sprint(), UVM_HIGH);
        drive_seq(drv_txn);
        seq_item_port.item_done(rsp);
        `uvm_info("master...driver.......run.......phase", "after item done", UVM_LOW)
      end     
 endtask

   
 task master_driver :: drive_seq(master_seq_item  drv_txn);
     `uvm_info("master_driver", "Before items pushed into queue", UVM_LOW)
       if(!m_drv_if.mi_drv_cb.ARESETn) begin
            `uvm_info("MASTER DRIVER","RESET FROM MAIN-PHASE START",UVM_LOW)
             reset_signals();
            `uvm_info("MASTER DRIVER","RESET FROM MAIN-PHASE END",UVM_LOW)
       end
       else begin        
           if(drv_txn.Trans_type == WR) begin
              wr_addr_queue.push_front(drv_txn);
              wr_data_queue.push_front(drv_txn);
              wr_rsp_queue.push_front(drv_txn); 
           end
           else if(drv_txn.Trans_type == RD) begin
              rd_addr_queue.push_front(drv_txn);
              rd_data_queue.push_front(drv_txn);
           end
       end
      `uvm_info("master_driver", "After items pushed into queue", UVM_LOW)
 endtask

 task master_driver :: reset_signals ();
      begin
        `uvm_info("master_driver_main","Start of master interface reset",UVM_LOW);
        //Interface signals initialization
	 wait(m_drv_if.mi_drv_cb.ARESETn);

        m_drv_if.mi_drv_cb.AWADDR <= 6'd0;
        m_drv_if.mi_drv_cb.AWVALID <= 1'd0; 
        m_drv_if.mi_drv_cb.WDATA <= 32'd0;
        m_drv_if.mi_drv_cb.WVALID <= 1'd0;
        m_drv_if.mi_drv_cb.BREADY <= 1'd0;
        m_drv_if.mi_drv_cb.ARADDR <= 6'd0;
        m_drv_if.mi_drv_cb.ARVALID <= 1'd0;
        m_drv_if.mi_drv_cb.RREADY <= 1'd0;
               `uvm_info("master_driver_main","End of master interface reset",UVM_LOW);
      end
 endtask

  task master_driver :: drive_transaction();
      fork
         wr_addr(drv_txn);
         wr_data(drv_txn);
         wr_rsp(drv_txn);
         rd_addr(drv_txn);
         rd_data(drv_txn);
      join_none
  endtask

  
      task  master_driver :: wr_addr(master_seq_item  pkt);
        forever begin
          `uvm_info("master_driver","Start of write address phase at master",UVM_HIGH);
          wait(m_drv_if.mi_drv_cb.ARESETn == 1'b1);
          @(m_drv_if.mi_drv_cb);
          if(wr_addr_queue.size() > 0) begin
             wa_key.get(1);
	     
          `uvm_info("master_driver","before queue",UVM_HIGH);
             pkt = wr_addr_queue.pop_back();
	     `uvm_info("master_driver","after queue",UVM_HIGH);
             repeat(pkt.cmd_to_cmd )@(m_drv_if.mi_drv_cb);
             m_drv_if.mi_drv_cb.AWADDR <= pkt.AWADDR;
             m_drv_if.mi_drv_cb.AWVALID <= 1'b1;
             wait(m_drv_if.mi_drv_cb.AWREADY == 1'b1);
             @(m_drv_if.mi_drv_cb);
             m_drv_if.mi_drv_cb.AWVALID <= 1'b0;
          `uvm_info("master_driver","awvalid is slow",UVM_HIGH);
             wa_key.put(1);
          end
          `uvm_info("master_driver","End of write address phase at master",UVM_HIGH);
        end
    endtask 

    task master_driver :: wr_data(master_seq_item   pkt);
       forever begin
           `uvm_info("master_driver","Start of write data phase at master",UVM_HIGH);
           wait(m_drv_if.mi_drv_cb.ARESETn == 1'b1);
           @(m_drv_if.mi_drv_cb);
           if(wr_data_queue.size() > 0) begin
               wd_key.get(1);    
               pkt = wr_data_queue.pop_back();
               repeat(pkt.addr_to_data) @(m_drv_if.mi_drv_cb);
               m_drv_if.mi_drv_cb.WDATA <= pkt.WDATA;
               m_drv_if.mi_drv_cb.WVALID <= 1'b1;
               wait(m_drv_if.mi_drv_cb.WREADY == 1'b1);
               @(m_drv_if.mi_drv_cb);
               m_drv_if.mi_drv_cb.WVALID <= 1'b0;
               wd_key.put(1);
           end
           `uvm_info("master_driver","End of write data phase at master",UVM_HIGH);
       end
    endtask
              
    task master_driver :: wr_rsp(master_seq_item   pkt);
        forever begin 
          `uvm_info("master_driver","Start of write response phase at master",UVM_HIGH);
           wait(m_drv_if.mi_drv_cb.ARESETn == 1'b1);
           @(m_drv_if.mi_drv_cb);
           if(wr_rsp_queue.size() > 0) begin
               wr_key.get(1);
               pkt = wr_rsp_queue.pop_back();
               repeat(pkt.data_to_rsp) @(m_drv_if.mi_drv_cb);
               m_drv_if.mi_drv_cb.BREADY <= 1'b1; 
               wait(m_drv_if.mi_drv_cb.BVALID == 1'b1);
               @(m_drv_if.mi_drv_cb)
               m_drv_if.mi_drv_cb.BREADY <= 1'b0;
               wr_key.put(1); 
           end
           `uvm_info("master_driver","End of write response phase at master",UVM_HIGH)
        end
    endtask
    
    task master_driver :: rd_addr(master_seq_item   pkt);  
       forever begin
          `uvm_info("master_driver","Start of read address phase at master",UVM_HIGH);
          wait(m_drv_if.mi_drv_cb.ARESETn == 1'b1);
          @(m_drv_if.mi_drv_cb);
          if(rd_addr_queue.size() > 0) begin
             ra_key.get(1);
             pkt = rd_addr_queue.pop_back();
             repeat(pkt.cmd_to_cmd) @(m_drv_if.mi_drv_cb);
             m_drv_if.mi_drv_cb.ARADDR <= pkt.ARADDR;
             m_drv_if.mi_drv_cb.ARVALID <= 1'b1;
             wait(m_drv_if.mi_drv_cb.ARREADY == 1'b1);
             @(m_drv_if.mi_drv_cb);
             m_drv_if.mi_drv_cb.ARVALID <= 1'b0;
             ra_key.put(1);
          end
          `uvm_info("master_driver","End of read address phase at master",UVM_HIGH);
       end
    endtask
              
    task master_driver :: rd_data(master_seq_item   pkt);
       forever begin
          `uvm_info("master_driver","Start of read data phase",UVM_HIGH);
          wait(m_drv_if.mi_drv_cb.ARESETn == 1'b1);
	  #30;
          @(m_drv_if.mi_drv_cb);
          if(rd_data_queue.size() > 0) begin
                rd_key.get(1);
                pkt = rd_data_queue.pop_back();
                repeat(pkt.addr_to_data) @(m_drv_if.mi_drv_cb);
                m_drv_if.mi_drv_cb.RREADY <= 1'b1;
                wait(m_drv_if.mi_drv_cb.RVALID == 1'b1);
                @(m_drv_if.mi_drv_cb);
                m_drv_if.mi_drv_cb.RREADY <= 1'b0;
                rd_key.put(1);
          end
          `uvm_info("master_driver","End of read data phase",UVM_HIGH);
       end
    endtask

    */
