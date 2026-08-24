/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_scoreboard.sv                  */
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

//import axi_package::*

parameter MAX_TRANSFER_BYTES    = 64,
          AXSIZE                = 2,
          NO_OF_BYTES_IN_A_BEAT = 4;      

          `define WIDTH 4
class axi_cdma_scoreboard extends uvm_component;

   `uvm_component_utils (axi_cdma_scoreboard)
    uvm_tlm_analysis_fifo #(axi_cdma_axi_master_seq_item) m_af[];
    uvm_tlm_analysis_fifo #(axi_cdma_axi_slave_seq_item)  s_af[];
    uvm_tlm_analysis_fifo #(axi_cdma_interrupt_seq_item)  i_af;

    axi_cdma_config_obj       obj;
    axi_cdma_descriptor_mem desc_mem;
    cdma_reg_block m_reg_block;

    bit wait_sg = 1;
    bit data_integrity_count;

    offset_address_t offset_addr;

    int            dma_rd_data_count,dma_wr_data_count;
    int            no_of_interrupt_status,no_of_interrupt_out_status;
    int            no_of_ioc_interrupt,no_of_DecErr_interrupt,no_of_SlvErr_interrupt,
                   no_of_IntErr_interrupt;

    axi_cdma_axi_slave_seq_item dma_rd_exp_pkt_q[$], dma_wr_exp_pkt_q[$],
                   		dma_rd_acc_pkt_q[$], dma_wr_acc_pkt_q[$],
                   		dma_exp_data_q[$],   dma_acc_data_q[$];

    logic [7:0]    rd_data_q[$], wr_data_q[$];

    uvm_reg_data_logic_t CR, SR,
                         CURDESC_PNTR,  CURDESC_PNTR_MSB,
                         TAILDESC_PNTR, TAILDESC_PNTR_MSB,
                         SA, SA_MSB,
                         DA, DA_MSB,
                         BTT;
    
   function new (string name = "axi_cdma_scoreboard" , uvm_component parent);
      super.new(name,parent);
   endfunction


   extern task main_phase                        (uvm_phase phase);
   extern function void build_phase              (uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern function void check_phase              (uvm_phase phase);

   extern task get_reg_module_pkt                ();
   extern task get_dma_module_pkt                ();
   extern task get_sg_engine_pkt                 ();
   extern task get_intrrupt_out_pkt              ();
   extern task dma_checker                       ();

   extern task register_module_prediction        (axi_cdma_axi_master_seq_item pkt);
   extern task register_check                    (axi_cdma_axi_master_seq_item pkt);   

   extern function void dma_control_signal_prediction (logic [31:0]local_SA,local_SA_MSB,local_DA,local_DA_MSB,local_BTT);
   extern function void axlen_prediction              (ref logic [63:0]addr,ref int btt,ref logic [7:0]axlen);

   extern task dma_data_checker                  (command_t type_rw);
   extern function void read_control_signal_checker   ();
   extern function void write_control_signal_checker  ();

   extern task get_mirrored_values               ();
   extern task interrupt_controller_check        (axi_cdma_interrupt_seq_item pkt);
endclass :axi_cdma_scoreboard

  function void axi_cdma_scoreboard :: build_phase (uvm_phase phase);
     super.build_phase (phase);

     
     if(!uvm_config_db #(axi_cdma_config_obj) :: get (this , "" , "axi_cdma_config_obj" , obj))
     `uvm_fatal(get_full_name(),"Config_obj get Failure")

     m_af = new[obj.no_of_masters];
     s_af = new[obj.no_of_slaves];

     foreach(m_af[i])
       m_af[i]=new($sformatf("m_af[%0d]",i),this);
     foreach(s_af[i]) begin 
	int a;
       s_af[i]=new($sformatf("s_af[%0d]",i),this);
      `uvm_info ("axi_cdma_scoreboard::build_phase", $sformatf("s_af[%0d] created",i ), UVM_NONE)
	//s_af[i].size();
      //`uvm_error("CDMA_SCRB::Check_phase",$sformatf("Slave[0] Analysis Fifo is not Empty SIZE=%0p",s_af[i].size))
     end
     i_af = new ("i_af",this);
     `uvm_info (get_full_name() , phase.get_name() , UVM_NONE)
  endfunction : build_phase

  function void axi_cdma_scoreboard :: start_of_simulation_phase(uvm_phase phase);
    `uvm_info ("cdma_scb::start_of_simulation" , phase.get_name() , UVM_NONE)
     if(!uvm_config_db #(cdma_reg_block) :: get (this, "","cdma_reg_block" , m_reg_block))
       `uvm_fatal("cdma_scb::start_of_simulation", "cdma_reg_block get Failure")

  endfunction : start_of_simulation_phase

  task axi_cdma_scoreboard :: main_phase (uvm_phase phase);
int a;
    `uvm_info ("CDMA_SCRB::main_phase" , phase.get_name() , UVM_NONE)
    get_mirrored_values();
    `uvm_info ("CDMA_SCRB::main_phase" , $sformatf("CR=%b",CR) , UVM_DEBUG)
    s_af[0].size();


    fork
      get_reg_module_pkt();    //gets a packet from master_fifo one at a time and process it.(complete end to end checking for current master_pkt);
      get_dma_module_pkt();     //forever loops to continuously get packets from slave fifos
      get_sg_engine_pkt();     
      get_intrrupt_out_pkt();
      dma_checker();
    join
  endtask : main_phase

  task axi_cdma_scoreboard::get_reg_module_pkt;
    axi_cdma_axi_master_seq_item m_seq_item,m_copied_packet;
    int no_of_reg_module_get;

    `uvm_info (get_full_name() , "Getting Register Module Packets" , UVM_NONE)
     forever begin
       m_seq_item = axi_cdma_axi_master_seq_item :: type_id :: create("m_seq_item");
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("BEFORE_GET_M0 packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
       m_af[0].get(m_seq_item); 
       no_of_reg_module_get++;
       m_copied_packet = axi_cdma_axi_master_seq_item :: type_id :: create("m_copied_packet");
       m_copied_packet.copy(m_seq_item);
      `uvm_info ("axi_cdma_scoreboard::get_reg_module_pkt", "printing Copied packet" , UVM_DEBUG)
       m_copied_packet.print;
       register_module_prediction(m_copied_packet);
       //register_check(m_copied_packet);
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("AFTER_GET_M0 packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
     end
  endtask : get_reg_module_pkt

  task axi_cdma_scoreboard::get_dma_module_pkt;
     axi_cdma_axi_slave_seq_item s_seq_item,s_copied_pkt;
    `uvm_info (get_full_name() , "Getting DMA Module Packets" , UVM_NONE)
     forever begin
       s_seq_item = axi_cdma_axi_slave_seq_item :: type_id :: create("s_seq_item");
       //s_copied_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("s_copied_pkt");
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("BEFORE_GET_S0 packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
       s_af[0].get(s_seq_item);
       if(s_seq_item.operation == READ) begin
         foreach(s_seq_item.rresp[i]) begin 
           if(s_seq_item.rresp[i]==DECERR) begin
             m_reg_block.CDMA_SR_h.DMADecErr.predict(.value(1'b1));
             m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
             m_reg_block.CDMA_SR_h.Idle.predict(.value(1'b0));
         //     no_of_interrupt_status++;
           //   no_of_DecErr_interrupt++;
           //   `uvm_info("CDMA_SCRB::interrupt_controller_check" , $sformatf("No of Interrupts=%0d No of Decode Error=%0d",no_of_interrupt_status,no_of_DecErr_interrupt),UVM_NONE)
           end else if(s_seq_item.rresp[i]==SLVERR) begin         
             m_reg_block.CDMA_SR_h.DMASlvErr.predict(.value(1'b1));
             m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
             m_reg_block.CDMA_SR_h.Idle.predict(.value(1'b0));
           end
         end
         //s_copied_pkt.print_read_data(s_seq_item);
         dma_rd_acc_pkt_q.push_back(s_seq_item);
         dma_exp_data_q.push_back(s_seq_item);
       end else if(s_seq_item.operation == WRITE) begin
             if(s_seq_item.bresp==DECERR) begin
               m_reg_block.CDMA_SR_h.DMADecErr.predict(.value(1'b1));
               m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
             end else if(s_seq_item.bresp==SLVERR) begin         
               m_reg_block.CDMA_SR_h.DMASlvErr.predict(.value(1'b1));
               m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
             end
          dma_wr_acc_pkt_q.push_back(s_seq_item);
          dma_acc_data_q.push_back(s_seq_item);
       end
     end
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("AFTER_GET_S0 packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
  endtask : get_dma_module_pkt  

  task axi_cdma_scoreboard::get_sg_engine_pkt;
     axi_cdma_axi_slave_seq_item sg_seq_item;
     int no_of_desc_get;
    `uvm_info ("CDMA_SCRB::get_sg_engine_pkt" , "Getting SG Engine Packets" , UVM_NONE)
     forever begin
       sg_seq_item = axi_cdma_axi_slave_seq_item :: type_id :: create("sg_seq_item");
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("BEFORE_GET_S1 packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
       s_af[1].get(sg_seq_item);
       if(!uvm_config_db #(axi_cdma_descriptor_mem) :: get (this , "" , "axi_cdma_descriptor_mem" , desc_mem))
        `uvm_fatal("CDMA_SCRB::get_sg_engine_pkt","desc_mem get Failure")
        
       desc_mem.compare_pkt(sg_seq_item);
       if(sg_seq_item.operation == READ) begin
         foreach(sg_seq_item.rresp[i]) begin
           if(sg_seq_item.rresp[i]==DECERR) begin
             m_reg_block.CDMA_SR_h.SGDecErr.predict(.value(1'b1));
             m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
           end else if(sg_seq_item.rresp[i]==SLVERR) begin         
             m_reg_block.CDMA_SR_h.SGSlvErr.predict(.value(1'b1));
             m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
           end
         end

         if(sg_seq_item.rdata[6]==0) begin
           m_reg_block.CDMA_SR_h.DMAIntErr.predict(.value(1'b1));
           m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
           m_reg_block.CDMA_SR_h.IOC_Irq.predict(.value(1'b1));
         end
         else begin
	   wait(wait_sg==1);
           get_mirrored_values();
           dma_control_signal_prediction(sg_seq_item.rdata[2],sg_seq_item.rdata[3],sg_seq_item.rdata[4],sg_seq_item.rdata[5],sg_seq_item.rdata[6]);
	   wait_sg=0;
         end
       end else if(sg_seq_item.operation == WRITE) begin
           desc_mem.mem[sg_seq_item.awaddr] = sg_seq_item.wdata[0];
       end
       
       desc_mem.print_descriptor;             
     end 

       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("AFTER_GET_S1 packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
  endtask : get_sg_engine_pkt  

  task axi_cdma_scoreboard::get_intrrupt_out_pkt;
     axi_cdma_interrupt_seq_item i_seq_item;
    `uvm_info (get_full_name() , "Getting Interrupt Out Packet" , UVM_NONE)
     forever begin
       i_seq_item = axi_cdma_interrupt_seq_item :: type_id :: create("i_seq_item");
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("BEFORE_GET_IRQ packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
       i_af.get(i_seq_item);
       interrupt_controller_check(i_seq_item); 
       `uvm_info ("axi_cdma_scoreboard::reg_block_sts", $sformatf("AFTER_GET_IRQ packet \n%0s",m_reg_block.sprint()) , UVM_DEBUG)
     end 
  endtask : get_intrrupt_out_pkt 

  task axi_cdma_scoreboard::register_module_prediction(axi_cdma_axi_master_seq_item pkt);
     static int no_of_btt_write;
    `uvm_info ("CDMA_SCRB::Reg_prediction" , "Predicting the Values for Register Module" , UVM_NONE)
    `uvm_info ("CDMA_SCRB::Reg_prediction" , $sformatf("operation=%s",pkt.operation) , UVM_DEBUG)
     if(pkt.operation == WRITE) begin
    `uvm_info ("CDMA_SCRB::Reg_prediction" , $sformatf("awaddr=%0d,wdata=%b araddr=%0d",pkt.awaddr,pkt.wdata[0][31:0],pkt.araddr) , UVM_DEBUG)
        offset_addr = offset_address_t'(pkt.awaddr);
       //case(pkt.awaddr)
       case(offset_addr)
         CNTRL_REG_ADDR : begin
                  if(pkt.wdata[0][23:16] == 0) begin
                    m_reg_block.CDMA_CR_h.IRQThreshold.predict    (.value(8'b1));
                    m_reg_block.CDMA_SR_h.IRQThresholdSts.predict (.value(8'b1));
                  end else begin
                    m_reg_block.CDMA_SR_h.IRQThresholdSts.predict (.value(pkt.wdata[0][23:16]));
                  end
                 
                    if(pkt.wdata[0][2]==1) begin
                      fork
                        begin
                          //repeat(8) @(obj.mas_if[0].DRV_MOD_master.mas_drv_cb) 
                          m_reg_block.reset();
                          get_mirrored_values();
                         `uvm_info ("CDMA_SCRB::Reg_prediction" , $sformatf("CDMA_CR=%b,m_reg_block.CDMA_CR_h.Reset=%0d",CR,m_reg_block.CDMA_CR_h.Reset) , UVM_MEDIUM)
                         `uvm_info ("CDMA_SCRB::Reg_prediction" , "m_reg_block got resetted" , UVM_NONE)
                        end
                        begin
                          dma_rd_exp_pkt_q.delete();
                          dma_wr_exp_pkt_q.delete();
                          dma_rd_acc_pkt_q.delete();
                          dma_wr_acc_pkt_q.delete();
                          dma_exp_data_q.delete();
                          dma_acc_data_q.delete();
                          rd_data_q.delete();
                          wr_data_q.delete();
                        end
                      join
                    end
                end

         STATUS_REG_ADDR : begin
                  /// Nothing to predict For Status Register
                end       
      
         CURDESC_LSB_ADDR : begin
                 // if(CR[3]==0 | SR[1]==0) 
                  //  m_reg_block.CURDESC_PNTR_h.predict(.value(CURDESC_PNTR));
                end

         CURDESC_MSB_ADDR : begin
                  //if(CR[3]==0 | SR[1]==0)
                    //m_reg_block.CURDESC_PNTR_MSB_h.predict(.value(CURDESC_PNTR_MSB));
                end
       
         TAILDESC_LSB_ADDR : begin
                //  if(CR[3]==0 | SR[1]==0)  
                  //  m_reg_block.TAILDESC_PNTR_h.predict(.value(TAILDESC_PNTR));
                end

         TAILDESC_MSB_ADDR : begin
                  //if(CR[3]==0 | SR[1]==0)
                  // m_reg_block.TAILDESC_PNTR_MSB_h.predict(.value(TAILDESC_PNTR_MSB));
                  m_reg_block.CDMA_SR_h.Idle.predict (.value(1'b0));
                end

         SA_LSB_ADDR : begin
                     //`uvm_info("CDMA_SCRB::register_module_prediction" , $sformatf("Got BTT Value = %0d",pkt.wdata),UVM_DEBUG)
                 // if(SR[1]==0)
                  // m_reg_block.SA_h.predict(.value(SA));
                end

         SA_MSB_ADDR : begin
                  //if(SR[1]==0)
                    //m_reg_block.SA_MSB_h.predict(.value(SA_MSB));
                end

         DA_LSB_ADDR : begin
                  //if(SR[1]==0)
                    //m_reg_block.DA_h.predict(.value(DA));
                end
 
         DA_MSB_ADDR : begin
                 // if(SR[1]==0)
                   // m_reg_block.DA_MSB_h.predict(.value(DA_MSB));
                end

         BTT_ADDR : begin
                     //`uvm_info("CDMA_SCRB::register_module_prediction" , $sformatf("Got BTT Value = %0d",pkt.wdata),UVM_DEBUG)
                  m_reg_block.CDMA_SR_h.Idle.predict(.value(1'b0));
                  get_mirrored_values();
                  if(SR[1]==0) begin
                     `uvm_info("CDMA_SCRB::register_module_prediction" ,"",UVM_DEBUG)
                    if(pkt.wdata[0]== 0) begin
                     `uvm_info("CDMA_SCRB::register_module_prediction" , $sformatf("No of BTT write = %0d",no_of_btt_write),UVM_DEBUG)
                      m_reg_block.CDMA_SR_h.DMAIntErr.predict(.value(1'b1));
                      m_reg_block.CDMA_SR_h.IOC_Irq.predict(.value(1'b1));
                      m_reg_block.CDMA_SR_h.Err_Irq.predict(.value(1'b1));
                      no_of_interrupt_status++;
                      no_of_IntErr_interrupt++;
                     `uvm_info("CDMA_SCRB::interrupt_controller_check" , $sformatf("No of Interrupts=%0d No of Internal Error=%0d",no_of_interrupt_status,no_of_IntErr_interrupt),UVM_NONE)
                    end 
                   else begin
                     `uvm_info("CDMA_SCRB::register_module_prediction" , $sformatf("No of BTT write = %0d",no_of_btt_write),UVM_DEBUG)
                      get_mirrored_values();
                     // dma_rd_data_count = BTT;
                      //dma_wr_data_count = BTT;
                      no_of_btt_write++;
                     `uvm_info("CDMA_SCRB::register_module_prediction" , $sformatf("No of BTT write = %0d",no_of_btt_write),UVM_DEBUG)
                      dma_control_signal_prediction(SA,SA_MSB,DA,DA_MSB,BTT);
                    end
                  end
                end 

         UNKNOWN : `uvm_info ("CDMA_SCRB::Reg_prediction","Address is unknown", UVM_DEBUG)
         default : `uvm_error("CDMA_SCRB::Reg_prediction","Address is not Valid")
       endcase
     end

  endtask : register_module_prediction

  task axi_cdma_scoreboard::register_check(axi_cdma_axi_master_seq_item pkt);
    uvm_status_e status_r;
    int r_data;

    `uvm_info ("CDMA_SCRB::Register_Check" , "Check the Mirrored value with DUT value Using Backdoor Check" , UVM_NONE)
     if(pkt.operation == WRITE) begin
       get_mirrored_values();
       case(pkt.awaddr)
         CNTRL_REG_ADDR : begin
                  m_reg_block.CDMA_CR_h.peek(.value(r_data),.status(status_r));
                  if(CR != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check",$sformatf("Mirrored Value=%b and DUT Control Register value=%b is mismatched ",CR,r_data) )
                end

         STATUS_REG_ADDR : begin
                  m_reg_block.CDMA_SR_h.peek(.value(r_data),.status(status_r));
                  if(SR != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check",$sformatf("Mirrored Value=%b and DUT Status Register value=%b is mismatched ",SR,r_data) )
                end       
       
         CURDESC_LSB_ADDR : begin
                  m_reg_block.CURDESC_PNTR_h.peek(.value(r_data),.status(status_r));
                  if(CURDESC_PNTR != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT CURDESC_PNTR value is mismatched " )
                end

         CURDESC_MSB_ADDR : begin
                  m_reg_block.CURDESC_PNTR_MSB_h.peek(.value(r_data),.status(status_r));
                  if(CURDESC_PNTR_MSB != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT CURDESC_PNTR_MSB value is mismatched " )
                end
       
         TAILDESC_LSB_ADDR : begin
                  m_reg_block.TAILDESC_PNTR_h.peek(.value(r_data),.status(status_r));
                  if(TAILDESC_PNTR != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT TAILDESC_PNTR value is mismatched " )
                end

         TAILDESC_MSB_ADDR : begin
                  m_reg_block.TAILDESC_PNTR_MSB_h.peek(.value(r_data),.status(status_r));
                  if(TAILDESC_PNTR_MSB != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT TAILDESC_PNTR_MSB value is mismatched " )
                end

         SA_LSB_ADDR : begin
                  m_reg_block.SA_h.peek(.value(r_data),.status(status_r));
                  if(SA != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT Source Address value is mismatched " )
                end

         SA_MSB_ADDR : begin
                  m_reg_block.SA_MSB_h.peek(.value(r_data),.status(status_r));
                  if(SA_MSB != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT Source Address  MSB value is mismatched " )
                end

         DA_LSB_ADDR : begin
                  m_reg_block.DA_h.peek(.value(r_data),.status(status_r));
                  if(DA != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT Destination Address value is mismatched " )
                end
 
         DA_MSB_ADDR : begin
                  m_reg_block.DA_MSB_h.peek(.value(r_data),.status(status_r));
                  if(DA_MSB != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT Destination Address MSB value is mismatched " )
                end

         BTT_ADDR : begin
                  m_reg_block.BTT_h.peek(.value(r_data),.status(status_r));
                  if(BTT != r_data)
                    `uvm_error("CDMA_SCRB::Register_Check","Mirrored Value and DUT Bytes to Transfer is mismatched " )
                end 

         default : `uvm_error("CDMA_SCRB::Reg_prediction","Address is not Valid")
       
       endcase
     end 
  endtask : register_check

  
  function void axi_cdma_scoreboard :: dma_control_signal_prediction(logic [31:0]local_SA,local_SA_MSB,local_DA,local_DA_MSB,local_BTT);

    bit            first_rd_transaction = 1;
    bit            first_wr_transaction = 1;
    logic [63:0]   local_awaddr,
                   local_araddr;
    logic [7:0]    local_arlen,
                   local_awlen;
    logic [31:0]   local_rd_btt,
                   local_wr_btt;
    int            no_of_rd_bytes_to_transfer,balance_rd_byte_to_transfer; 
    int            no_of_wr_bytes_to_transfer,balance_wr_byte_to_transfer; 
    int            wr_align_byte, rd_align_bytes;
    axi_cdma_axi_slave_seq_item wr_exp_pkt,
                   rd_exp_pkt;
    int no_of_rd_prediction;
    int no_of_push;
 
    `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , "Predicting the control signals of the DMA module" , UVM_NONE)
     balance_rd_byte_to_transfer = local_BTT;
     dma_rd_data_count = local_BTT;
     dma_wr_data_count = local_BTT;
    `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("dma_rd_data_count=%0d \n balance_rd_byte_to_transfer=%0d",dma_rd_data_count,balance_rd_byte_to_transfer) , UVM_DEBUG)
     while(balance_rd_byte_to_transfer > 0) begin
       rd_exp_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("rd_exp_pkt");
       if(first_rd_transaction==1) begin
         local_araddr = {local_SA_MSB,local_SA};////////For First transaction Address is same as Source Address
       end else begin
         local_araddr = local_araddr + (local_rd_btt - balance_rd_byte_to_transfer);////For nth Transaction Address will be added with 
                                                                                    ////no of bytes transfered in previous transaction 
       end
       
       local_rd_btt = balance_rd_byte_to_transfer;////Total BTT to be transfered in each transaction
       rd_align_bytes = MAX_TRANSFER_BYTES - (local_araddr % MAX_TRANSFER_BYTES);
       if(local_rd_btt >= rd_align_bytes) begin/////For btt less than 64
        no_of_rd_bytes_to_transfer= rd_align_bytes;
       end else begin
        no_of_rd_bytes_to_transfer= local_rd_btt;/////For btt greater than 64
       end


       balance_rd_byte_to_transfer = balance_rd_byte_to_transfer - no_of_rd_bytes_to_transfer;////Remaining bytes to be transfered in next transaction
      
       axlen_prediction(local_araddr,no_of_rd_bytes_to_transfer,local_arlen);
                       
       if(CR[4] == 1) begin
         rd_exp_pkt.arburst = FIXED;
         rd_exp_pkt.araddr  = {local_SA_MSB,local_SA};
       end else begin
         rd_exp_pkt.arburst = INCR;
         rd_exp_pkt.araddr  = local_araddr;
       end
       rd_exp_pkt.arsize    = 2; 
       rd_exp_pkt.arlen     = local_arlen;
       rd_exp_pkt.arcache   = 3;
       rd_exp_pkt.arprot    = 0;
       rd_exp_pkt.rlast     = 1; 
       rd_exp_pkt.operation = READ;
       
       dma_rd_exp_pkt_q.push_back(rd_exp_pkt);
       no_of_push++;
      `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("no_of_push=%0d",no_of_push) , UVM_DEBUG)
 
       first_rd_transaction = 0;
     end   

     balance_wr_byte_to_transfer = local_BTT;

     while(balance_wr_byte_to_transfer > 0) begin
       wr_exp_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("wr_exp_pkt");
       if(first_wr_transaction==1) begin
         local_awaddr = {local_DA_MSB,local_DA};////For First transaction Address is same as Destination Address
       end else begin
         local_awaddr = local_awaddr + (local_wr_btt - balance_wr_byte_to_transfer);////For nth Transaction Address will be added with 
                                                                                    ////no of bytes transfered in previous transaction 
       end
       
       local_wr_btt = balance_wr_byte_to_transfer;////Total BTT to be transfered
        wr_align_byte = MAX_TRANSFER_BYTES - (local_awaddr % MAX_TRANSFER_BYTES);/////For btt greater than 64

       if(local_wr_btt >= wr_align_byte) begin/////For btt less than 64
        no_of_wr_bytes_to_transfer= wr_align_byte;
       end else begin
        no_of_wr_bytes_to_transfer= local_wr_btt;/////For btt greater than 64
       end

       balance_wr_byte_to_transfer = balance_wr_byte_to_transfer - no_of_wr_bytes_to_transfer;////Remaining bytes to be transfered in next transaction
      
       axlen_prediction(local_awaddr,no_of_wr_bytes_to_transfer,local_awlen);
       
       wr_exp_pkt.wstrobe = new[local_awlen+1];
       foreach(wr_exp_pkt.wstrobe[i]) 
         wr_exp_pkt.wstrobe[i] = 4'hf;

         if(local_awaddr%4==1)
           wr_exp_pkt.wstrobe[0] = 14;
         else if(local_awaddr%4==2)
           wr_exp_pkt.wstrobe[0] = 12;
         else if(local_awaddr%4==3)
           wr_exp_pkt.wstrobe[0] = 8;

         //for(int i=0;i<NO_OF_BYTES_IN_A_BEAT;i++)begin
         //   int j = 0;
         //   if(local_awaddr%NO_OF_BYTES_IN_A_BEAT==i+1)
         //     //wr_exp_pkt.wstrobe[0][j:0] = 0;
         //     //`WIDTH 3;
         //     `ifdef WIDTH
         //         WIDTH j
         //      `endif
         //     wr_exp_pkt.wstrobe[0][`WIDTH:0] = 0;
         //   j++;
         //end


         if(first_wr_transaction==1 && balance_wr_byte_to_transfer==0 && wr_exp_pkt.wstrobe.size==1) begin
           if(integer'(local_awaddr%4)==0 && integer'(no_of_wr_bytes_to_transfer%4)==1)
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size -1] = 1;
           else if(integer'(local_awaddr%4)==0 && integer'(no_of_wr_bytes_to_transfer%4)==2) 
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size -1] = 3;
           else if(integer'(local_awaddr%4)==0 && integer'(no_of_wr_bytes_to_transfer%4)==3) 
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size -1] = 7;
           else if(integer'(local_awaddr%4)==1 && integer'(no_of_wr_bytes_to_transfer%4)==1) 
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size -1] = 2;
           /*else*/ if(integer'(local_awaddr%4)==1 && integer'(no_of_wr_bytes_to_transfer%4)==2) begin
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size -1] = 6;
                      `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("Only One Beat transfer local_awaddr=%0d,no_of_wr_bytes_to_transfer=%b,wstrobe=%b",local_awaddr,no_of_wr_bytes_to_transfer,wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size-1]) , UVM_DEBUG)
             end
           else if(integer'(local_awaddr%4)==2 && integer'(no_of_wr_bytes_to_transfer%4)==1) 
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size -1] = 4;
           `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("Only One Beat transfer local_awaddr=%0d,no_of_wr_bytes_to_transfer=%b,wstrobe=%b",local_awaddr,no_of_wr_bytes_to_transfer,wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size-1]) , UVM_DEBUG)

         end
        
         if(balance_wr_byte_to_transfer==0 && wr_exp_pkt.wstrobe.size > 1 ) begin
                      `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("before last byte prediction local_awaddr=%0d,no_of_wr_bytes_to_transfer=%b,wstrobe=%b",local_awaddr,no_of_wr_bytes_to_transfer,wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size-1]) , UVM_DEBUG)
           if((local_awaddr%4==0 && no_of_wr_bytes_to_transfer%4==1) ||
              (local_awaddr%4==1 && no_of_wr_bytes_to_transfer%4==0) ||
              (local_awaddr%4==2 && no_of_wr_bytes_to_transfer%4==3) ||
              (local_awaddr%4==3 && no_of_wr_bytes_to_transfer%4==2) 
             )
             wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size - 1] = 1;
           else if((local_awaddr%4==0 && no_of_wr_bytes_to_transfer%4==2) ||
                   (local_awaddr%4==1 && no_of_wr_bytes_to_transfer%4==1) ||
                   (local_awaddr%4==2 && no_of_wr_bytes_to_transfer%4==0) ||
                   (local_awaddr%4==3 && no_of_wr_bytes_to_transfer%4==3) 
                  )
                  wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size - 1] = 3;
           else if((local_awaddr%4==0 && no_of_wr_bytes_to_transfer%4==3) ||
                   (local_awaddr%4==1 && no_of_wr_bytes_to_transfer%4==2) || 
                   (local_awaddr%4==2 && no_of_wr_bytes_to_transfer%4==1) ||
                   (local_awaddr%4==3 && no_of_wr_bytes_to_transfer%4==0) 
                  )
                  wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size - 1] = 7;
                      `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("after last byte prediction local_awaddr=%0d,no_of_wr_bytes_to_transfer=%b,wstrobe=%b",local_awaddr,no_of_wr_bytes_to_transfer,wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size-1]) , UVM_DEBUG)

         end

          
       if(CR[5] == 1) begin
         wr_exp_pkt.awburst = FIXED;
         wr_exp_pkt.awaddr  = {local_DA_MSB,local_DA};
       end else begin
         wr_exp_pkt.awburst = INCR;
         wr_exp_pkt.awaddr  = local_awaddr;
       end
       wr_exp_pkt.awsize    = 2; 
       wr_exp_pkt.awlen     = local_awlen;
       wr_exp_pkt.awcache   = 3;
       wr_exp_pkt.awprot    = 0;
       wr_exp_pkt.wlast     = 1; 
       wr_exp_pkt.operation = WRITE;
       
                      `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("Before Pushing the pkt local_awaddr=%0d,no_of_wr_bytes_to_transfer=%b,wstrobe=%b",local_awaddr,no_of_wr_bytes_to_transfer,wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size-1]) , UVM_DEBUG)
       dma_wr_exp_pkt_q.push_back(wr_exp_pkt);
                      `uvm_info ("CDMA_SCRB::DMA_cntrl_sig_predict" , $sformatf("After Pushing the pkt local_awaddr=%0d,no_of_wr_bytes_to_transfer=%b,wstrobe=%b",local_awaddr,no_of_wr_bytes_to_transfer,wr_exp_pkt.wstrobe[wr_exp_pkt.wstrobe.size-1]) , UVM_DEBUG)
       first_wr_transaction = 0;
     end     
     
  endfunction : dma_control_signal_prediction

  function void axi_cdma_scoreboard::axlen_prediction(ref logic [63:0]addr,ref int btt,ref logic [7:0]axlen);
     int mod_axaddr_val;
     int mod_btt_val;
    `uvm_info ("CDMA_SCRB::axlen_prediction" , "AXLEN prediction" , UVM_LOW)
       ///if((addr%4 == 0) || 
       ///   (addr%4 == 1 &&  btt%4 != 0 ) ||
       ///   (addr%4 == 2 && (btt%4 == 1 ||  btt%4 == 2)) ||
       ///   (addr%4 == 3 &&  btt%4 == 1 )
       ///  )
       ///  axlen = $ceil(real'(btt)/4)-1;
       ///else if((addr%4 == 1 &&  btt%4 == 0 ) ||
       ///        (addr%4 == 2 && (btt%4 == 0 ||  btt%4 == 3)) ||
       ///        (addr%4 == 3 &&  btt%4 != 1 )
       ///       )
       ///       axlen = $ceil(real'(btt)/4);

       //for(int i=0;i<NO_OF_BYTES_IN_A_BEAT;i++)begin
          mod_axaddr_val = addr % NO_OF_BYTES_IN_A_BEAT;
          mod_btt_val    = btt % NO_OF_BYTES_IN_A_BEAT;

          if(NO_OF_BYTES_IN_A_BEAT-mod_axaddr_val >= mod_btt_val)
            axlen = $ceil(real'(btt)/NO_OF_BYTES_IN_A_BEAT)-1;
          else
            axlen = $ceil(real'(btt)/NO_OF_BYTES_IN_A_BEAT);

       //end


    `uvm_info ("CDMA_SCRB::axlen_prediction" , $sformatf("AXADDR=%0d BTT=%0d AXLEN=%0d",addr,btt,axlen ), UVM_LOW)
     
  endfunction : axlen_prediction



  task axi_cdma_scoreboard::dma_checker();
    `uvm_info ("CDMA_SCRB::DMA_Checker" , "Check the Predicted Packet with Actual Packet" , UVM_NONE)

     fork
       forever begin
         `uvm_info ("CDMA_SCRB::DMA_Checker" , $sformatf("Wait for dma_rd_exp_pkt_q.size=%0d and dma_rd_acc_pkt_q.size not equal to be 1",dma_rd_exp_pkt_q.size,dma_rd_acc_pkt_q.size ), UVM_DEBUG)
         wait( dma_rd_exp_pkt_q.size != 0 &&  dma_rd_acc_pkt_q.size !=0); 
         `uvm_info ("CDMA_SCRB::DMA_Checker" , "Wait satisfied for dma_rd_exp_pkt_q and dma_rd_acc_pkt_q size not equal to be 1" , UVM_DEBUG)
           read_control_signal_checker();
           dma_data_checker(READ);
       end

       forever begin
         wait( dma_wr_exp_pkt_q.size!=0 &&  dma_wr_acc_pkt_q.size !=0) ;
           write_control_signal_checker();           
           dma_data_checker(WRITE);
       end
     join
  endtask : dma_checker

  function void axi_cdma_scoreboard :: read_control_signal_checker();
    axi_cdma_axi_slave_seq_item check_rd_pkt,
                   rd_exp_pkt,rd_acc_pkt;

   `uvm_info ("CDMA_SCRB::rd_control_signal_check" , "Started Comparing the Control Signals of Read Expected Packet with Read Actual Packet" , UVM_NONE)
         rd_exp_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("rd_exp_pkt");
         rd_acc_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("rd_acc_pkt");

       if( dma_rd_exp_pkt_q.size!=0 &&  dma_rd_acc_pkt_q.size !=0) begin 
         rd_exp_pkt =  dma_rd_exp_pkt_q.pop_front();
         rd_acc_pkt =  dma_rd_acc_pkt_q.pop_front();
         rd_acc_pkt.read_pkt_compare(rd_exp_pkt,rd_acc_pkt);
        `uvm_info ("CDMA_SCRB::rd_control_signal_check" , $sformatf("rd_exp_pkt=%p \n rd_acc_pkt=%p",rd_exp_pkt,rd_acc_pkt) , UVM_DEBUG)
        `uvm_info ("CDMA_SCRB::rd_control_signal_check" , $sformatf("dma_rd_exp_pkt_q=%0d \n dma_rd_acc_pkt_q=%0d",dma_rd_exp_pkt_q.size,dma_rd_acc_pkt_q.size) , UVM_DEBUG)
       end else
        `uvm_info ("CDMA_SCRB::rd_control_signal_check" , $sformatf("dma_rd_exp_pkt_q=%0d \n dma_rd_acc_pkt_q=%0d",dma_rd_exp_pkt_q.size,dma_rd_acc_pkt_q.size) , UVM_DEBUG)

    
  endfunction : read_control_signal_checker

 function void axi_cdma_scoreboard :: write_control_signal_checker();
   axi_cdma_axi_slave_seq_item wr_exp_pkt,wr_acc_pkt;
  `uvm_info ("CDMA_SCRB::wr_control_signal_check" , "Started Comparing the Control Signals of Write Expected Packet with Write Actual Packet" , UVM_NONE)
         wr_exp_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("wr_exp_pkt");
         wr_acc_pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("wr_acc_pkt");

       if( dma_wr_exp_pkt_q.size!=0 &&  dma_wr_acc_pkt_q.size !=0) begin 
         wr_exp_pkt =  dma_wr_exp_pkt_q.pop_front();
         wr_acc_pkt =  dma_wr_acc_pkt_q.pop_front();
         wr_acc_pkt.write_pkt_compare(wr_exp_pkt,wr_acc_pkt);
        `uvm_info ("CDMA_SCRB::wr_control_signal_check" , $sformatf("wr_exp_pkt=%p \n wr_acc_pkt=%p",wr_exp_pkt,wr_acc_pkt) , UVM_DEBUG)
       end

    
  endfunction : write_control_signal_checker



  task axi_cdma_scoreboard :: get_mirrored_values();
    `uvm_info ("CDMA_SCRB::get_mirror_value" , "Get the Mirrored values of RAL" , UVM_NONE)

     CR                = m_reg_block.CDMA_CR_h.get_mirrored_value();
     SR                = m_reg_block.CDMA_SR_h.get_mirrored_value();
     CURDESC_PNTR      = m_reg_block.CURDESC_PNTR_h.get_mirrored_value();
     CURDESC_PNTR_MSB  = m_reg_block.CURDESC_PNTR_MSB_h.get_mirrored_value();
     TAILDESC_PNTR     = m_reg_block.TAILDESC_PNTR_h.get_mirrored_value();
     TAILDESC_PNTR_MSB = m_reg_block.TAILDESC_PNTR_MSB_h.get_mirrored_value();
     SA                = m_reg_block.SA_h.get_mirrored_value();
     SA_MSB            = m_reg_block.SA_MSB_h.get_mirrored_value();
     DA                = m_reg_block.DA_h.get_mirrored_value();
     DA_MSB            = m_reg_block.DA_MSB_h.get_mirrored_value();
     BTT               = m_reg_block.BTT_h.get_mirrored_value();
     m_reg_block.sprint();

  endtask : get_mirrored_values

  task axi_cdma_scoreboard::dma_data_checker(command_t type_rw);
     axi_cdma_axi_slave_seq_item data_pkt,wr_data_pkt;
    `uvm_info ("CDMA_SCRB::dma_data_checker" , "Started to Compare the Write data with Read data  " , UVM_NONE)
    `uvm_info ("CDMA_SCRB::dma_data_checker" , $sformatf("outside If dma_exp_data_q.size=%0d ",dma_exp_data_q.size) , UVM_DEBUG)
   if(type_rw==READ) begin
     if(dma_exp_data_q.size !=0) begin
      `uvm_info ("CDMA_SCRB::dma_data_checker" , $sformatf("inside If dma_exp_data_q.size=%0d,dma_rd_data_count=%0d ",dma_exp_data_q.size,dma_rd_data_count) , UVM_DEBUG)
       data_pkt = dma_exp_data_q.pop_front();
      `uvm_info ("CDMA_SCRB::dma_data_checker" , $sformatf("data_pkt=%p ",data_pkt) , UVM_DEBUG)
       if(data_integrity_count==0) begin    
         if(data_pkt.araddr%4==1) begin
           rd_data_q.push_back(data_pkt.rdata[0][15:8]);
           rd_data_q.push_back(data_pkt.rdata[0][23:16]);
           rd_data_q.push_back(data_pkt.rdata[0][31:24]);
           dma_rd_data_count = dma_rd_data_count - 3;
         end else if(data_pkt.araddr%4==2) begin
           rd_data_q.push_back(data_pkt.rdata[0][23:16]);
           rd_data_q.push_back(data_pkt.rdata[0][31:24]);
           dma_rd_data_count = dma_rd_data_count - 2;
         end else if(data_pkt.araddr%4==3) begin
           rd_data_q.push_back(data_pkt.rdata[0][31:24]);
           dma_rd_data_count = dma_rd_data_count - 1;
         end else begin
           rd_data_q.push_back(data_pkt.rdata[0][7:0]);
           rd_data_q.push_back(data_pkt.rdata[0][15:8]);
           rd_data_q.push_back(data_pkt.rdata[0][23:16]);
           rd_data_q.push_back(data_pkt.rdata[0][31:24]);
           dma_rd_data_count = dma_rd_data_count - 4;
         end

         foreach(data_pkt.rdata[i])
           if(i!=0) begin
             rd_data_q.push_back(data_pkt.rdata[i][7:0]);
             rd_data_q.push_back(data_pkt.rdata[i][15:8]);
             rd_data_q.push_back(data_pkt.rdata[i][23:16]);
             rd_data_q.push_back(data_pkt.rdata[i][31:24]);
             dma_rd_data_count = dma_rd_data_count - 4;
           end 
         data_integrity_count=1;
       end else begin
           foreach(data_pkt.rdata[i]) begin
             rd_data_q.push_back(data_pkt.rdata[i][7:0]);
             rd_data_q.push_back(data_pkt.rdata[i][15:8]);
             rd_data_q.push_back(data_pkt.rdata[i][23:16]);
             rd_data_q.push_back(data_pkt.rdata[i][31:24]);
             dma_rd_data_count = dma_rd_data_count - 4;
           end 
       end

       if(dma_rd_data_count <0)	begin	//deleting last few beats unwanted data
         repeat(dma_rd_data_count*(-1))
           rd_data_q = rd_data_q [0:$-1];   
         data_integrity_count=0;
         dma_rd_data_count=0;
       end
     end
     if(/*CR[3]==0 &&*/ dma_rd_data_count==0) m_reg_block.CDMA_SR_h.Idle.predict(.value(1'b1));
   end

   if(type_rw == WRITE) begin
     if(dma_acc_data_q.size != 0) begin
       wr_data_pkt = dma_acc_data_q.pop_front();
          `uvm_info ("CDMA_SCRB::dma_data_checker" , "Printing data_pkt " , UVM_DEBUG)
           wr_data_pkt.print;
       foreach(wr_data_pkt.wstrobe[i]) begin
         if(wr_data_pkt.wstrobe[i][0]==1)
           wr_data_q.push_back(wr_data_pkt.wdata[i][7:0]);
         if(wr_data_pkt.wstrobe[i][1]==1)
           wr_data_q.push_back(wr_data_pkt.wdata[i][15:8]);
         if(wr_data_pkt.wstrobe[i][2]==1)
           wr_data_q.push_back(wr_data_pkt.wdata[i][23:16]);
         if(wr_data_pkt.wstrobe[i][3]==1)
           wr_data_q.push_back(wr_data_pkt.wdata[i][31:24]);
          `uvm_info ("CDMA_SCRB::dma_data_checker" , $sformatf("Printing wr_data_q =%p",wr_data_q), UVM_DEBUG)
       end

       if(dma_wr_data_count == wr_data_q.size) begin
         if(rd_data_q == wr_data_q) begin
          `uvm_info ("CDMA_SCRB::dma_data_checker" , "Data Integrity is Check is PASSED " , UVM_NONE)
           get_mirrored_values();
           if(SR[14]==0) begin
             m_reg_block.CDMA_SR_h.IOC_Irq.predict(.value(1'b1));
             no_of_interrupt_status++;
             no_of_ioc_interrupt++;
            `uvm_info("CDMA_SCRB::interrupt_controller_check" , $sformatf("No of Interrupts=%0d No of IOC Interrupt=%0d",no_of_interrupt_status,no_of_ioc_interrupt),UVM_NONE)
           end
         end else  
              `uvm_warning("UVM_ERROR:CDMA_SCRB::dma_data_checker",$sformatf("DATA COMPARE FAILED \n wr_data_q.size=%0d rd_data_q.size=%0d dma_rd_data_count=%0d dma_wr_data_count=%0d \n\t wr_data_q=%p \n\t rd_data_q=%p",wr_data_q.size,rd_data_q.size,dma_rd_data_count,dma_wr_data_count,wr_data_q,rd_data_q));
         rd_data_q.delete();
         wr_data_q.delete();
         data_integrity_count = 0;
	 wait_sg=1;
       end else if(dma_wr_data_count < wr_data_q.size()) begin
        `uvm_warning ("UVM_ERROR:CDMA_SCRB::dma_data_checker",$sformatf("DATA INTEGRTY FAILED WR DATA=%0d MORE THAN EXPECTED=%0d ",wr_data_q.size,dma_wr_data_count))
        `uvm_warning ("UVM_ERROR:CDMA_SCRB::dma_data_checker",$sformatf("DATA INTEGRTY FAILED WR DATA = %p \n RD_DATA = %p \n Expected pkt=%0d",wr_data_q, rd_data_q,dma_rd_data_count))
         rd_data_q.delete();
         wr_data_q.delete();
         data_integrity_count = 0;
         wait_sg=1;
       end    
     end
   end

  endtask : dma_data_checker


  function void axi_cdma_scoreboard::check_phase(uvm_phase phase);
    if( dma_rd_exp_pkt_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Read Expected Queue is not Empty SIZE=%0d", dma_rd_exp_pkt_q.size));
    if( dma_wr_exp_pkt_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Write Expected Queue is not Empty SIZE=%0d", dma_wr_exp_pkt_q.size));
    if( dma_rd_acc_pkt_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Read Actual Queue is not Empty SIZE=%0d", dma_rd_acc_pkt_q.size));
    if( dma_wr_acc_pkt_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Write Actual Queue is not Empty SIZE=%0d", dma_wr_acc_pkt_q.size));
    if(dma_exp_data_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Expected Data Queue is not Empty SIZE=%0d",dma_exp_data_q.size));
    if(dma_acc_data_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Actual Data Queue is not Empty SIZE=%0d",dma_acc_data_q.size));
    if(rd_data_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Read Data Queue is not Empty SIZE=%0d",rd_data_q.size));
    if(wr_data_q.size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Write Data Queue is not Empty SIZE=%0d",wr_data_q.size));
    foreach(s_af[i])
    if(s_af[i].size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Slave[0] Analysis Fifo is not Empty SIZE=%0d",s_af[i].size));
    if(s_af[1].size != 0)
      `uvm_error("CDMA_SCRB::Check_phase",$sformatf("Slave[1] Analysis Fifo is not Empty SIZE=%0d",s_af[1].size));

  endfunction : check_phase


  task axi_cdma_scoreboard::interrupt_controller_check(axi_cdma_interrupt_seq_item pkt);
      `uvm_info ("CDMA_SCRB::interrupt_controller_check" , "Interrupt Out Signal Check " , UVM_NONE)
       get_mirrored_values();
       if(CR[12] || CR[13] || CR[14]) begin
         if(CR[14]) begin
           if(SR[14] && (SR[4] || SR[5] || SR[6] || SR[8] || SR[9] || SR[10])) begin
             if(pkt.interrupt_out==1) begin
               no_of_interrupt_out_status++;
              `uvm_info ("CDMA_SCRB::interrupt_controller_check" , $sformatf("Interrupt Out Signal working For Error Interrupt =%0d",no_of_interrupt_out_status) , UVM_NONE)
             end else begin
              `uvm_warning("UVM_ERROR:CDMA_SCRB::interrupt_controller_check" ,"Interrupt Out Signal is not working For Error Interrupt")
             end
           end else begin
              `uvm_info ("CDMA_SCRB::interrupt_controller_check" , "Error_event not occured is not occured" , UVM_LOW)
           end
         end else begin    
              `uvm_info ("CDMA_SCRB::interrupt_controller_check" , "Error_Interrupt is not Enabled" , UVM_LOW)
         end

         if(CR[12]) begin
           if(SR[12]) begin
             if(pkt.interrupt_out==1) begin
               if(SR[12] && SR[14])
                `uvm_info ("CDMA_SCRB::interrupt_controller_check" , $sformatf("Interrupt Out Signal working For Interrupt On Completion with Error =%0d",no_of_interrupt_out_status ), UVM_NONE)
               else begin
                 no_of_interrupt_out_status++;
                `uvm_info ("CDMA_SCRB::interrupt_controller_check" , $sformatf("Interrupt Out Signal working For Interrupt On Completion =%0d",no_of_interrupt_out_status ), UVM_NONE)
               end
             end else begin
              `uvm_warning("UVM_ERROR:CDMA_SCRB::interrupt_controller_check" , "Interrupt Out Signal is not working For Interrupt On Completion")
             end
           end else begin
              `uvm_info ("CDMA_SCRB::interrupt_controller_check" , "Interrupt On Completion is not Occured" , UVM_LOW)
           end
         end else begin 
          `uvm_info ("CDMA_SCRB::interrupt_controller_check" , "Interrupt On Completion is not Enabled" , UVM_LOW)
         end  
       end
  endtask : interrupt_controller_check
