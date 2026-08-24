/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_scoreboard.sv                           */
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
//    import axi_package::*;
class axi_cdma_axi_scoreboard extends uvm_component;

   `uvm_component_utils (axi_cdma_axi_scoreboard)
    uvm_tlm_analysis_fifo #(axi_cdma_axi_master_seq_item) m_af[];
    uvm_tlm_analysis_fifo #(axi_cdma_axi_slave_seq_item) s_af[];
    axi_cdma_axi_base_seq_item error_packets[$];
    axi_cdma_config_obj       obj;
    axi_cdma_axi_coverage         cvg;
    int successful_comparisons, failed_comparisons;
    int slave_width [4], master_width[4];
    axi_cdma_axi_slave_seq_item  actual_req[4][$]; //stores actual req transactions on slave side (one per slave)
    axi_cdma_axi_master_seq_item  actual_response_pkt; //stores actual req transactions on slave side (one per slave)
   function new (string name = "axi_cdma_axi_scoreboard" , uvm_component parent);
      super.new(name,parent);
   endfunction
   extern task main_phase                        (uvm_phase phase);
   extern function void build_phase              (uvm_phase phase);
   extern function void report_phase             (uvm_phase phase);
   extern function void extract_phase            (uvm_phase phase);
   extern task get_slave_packets                 ();
   extern task get_master_packets                ();
   extern function void predict_slave_pkt(output axi_cdma_axi_slave_seq_item exp_slave_pkts[4][$],output int slave_index, input axi_cdma_axi_master_seq_item act_master_pkt, input int master_index);
   extern function void compare_slave_exp_vs_actual(output axi_cdma_axi_slave_seq_item act_slave_pkts[$],input axi_cdma_axi_slave_seq_item exp_slave_pkts[4][$], input int slave_index);
   extern function void predict_master_pkt(output axi_cdma_axi_master_seq_item exp_master_pkt, input axi_cdma_axi_slave_seq_item act_slave_pkts[$], input axi_cdma_axi_master_seq_item act_master_pkt, input int master_index,slave_index);
   extern function void compare_master_exp_vs_actual(input axi_cdma_axi_master_seq_item exp_master_pkt ,input axi_cdma_axi_master_seq_item act_master_pkt); // compare all read/write phases
   extern function void process_packet(input axi_cdma_axi_master_seq_item act_master_pkt , input int master_index);

endclass :axi_cdma_axi_scoreboard

  function void axi_cdma_axi_scoreboard :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     if (!uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj))
     `uvm_fatal(get_full_name(),"Config_obj get Failure")
     m_af = new[obj.no_of_masters];
     s_af = new[obj.no_of_slaves];

     foreach(m_af[i])
     m_af[i]=new($sformatf("m_af[%d]",i),this);
     foreach(s_af[i])
     s_af[i]=new($sformatf("s_af[%d]",i),this);
     slave_width  = obj.slave_width;
     master_width = obj.master_width;
     cvg = axi_cdma_axi_coverage :: type_id :: create ("cvg");
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : build_phase

  function void axi_cdma_axi_scoreboard :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
     `uvm_info ("Scoreboard" ,"Extract_phase - End_of_Test_check", UVM_MEDIUM)
     //EOT check
     foreach(actual_req[i])
     assert(actual_req[i].size()==0) else `uvm_error("Scoreboard- Extract_phase EOT",$sformatf(" Assertion failed actual_req[%d].size = %d",i,actual_req[i].size())) //to ensure all packets consumed
  endfunction : extract_phase

  function void axi_cdma_axi_scoreboard :: report_phase (uvm_phase phase);
     super.report_phase (phase);
     `uvm_info ("Scoreboard" ,"Report_phase", UVM_MEDIUM)
     `uvm_info ("Scoreboard" ,$sformatf("\n Total number of comparisons = %d \n number_of_comparisons PASSED = %d \n number_of_comparisons FAILED = %d",successful_comparisons+failed_comparisons,successful_comparisons,failed_comparisons), UVM_MEDIUM)
  endfunction : report_phase


  task axi_cdma_axi_scoreboard :: main_phase (uvm_phase phase);
    `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
    fork
      get_master_packets();    //gets a packet from master_fifo one at a time and process it.(complete end to end checking for current master_pkt);
      get_slave_packets();     //forever loops to continuously get packets from slave fifos
    join
  endtask : main_phase

  task axi_cdma_axi_scoreboard :: get_slave_packets(); // get slave pkts from slave_analysis_fifos and put them to actual_req ques //continuously running loops
    realtime previous_slave_ts[]; //previous command timestamp
    previous_slave_ts =new[obj.no_of_slaves];
    `uvm_info ("Scoreboard :: get_slave_packets" ,"Triggred", UVM_MEDIUM)
    for(int i=0 ; i<obj.no_of_slaves ;i++)begin
    automatic int slv_idx = i;
      fork
        forever begin
        axi_cdma_axi_slave_seq_item pkt;
        `uvm_info ("Scoreboard :: get_slave_packets" ,$sformatf("Waiting at slave %d s_af.get ",slv_idx), UVM_MEDIUM)
        s_af[slv_idx].get(pkt);
        `uvm_info ("Scoreboard :: get_slave_packets" ,$sformatf("got pkt from slave %d s_af.get ",slv_idx), UVM_MEDIUM)
        if(pkt.operation==WRITE)pkt.print_write_txn(pkt);
        else pkt.print_read_txn(pkt);
        pkt.axi_protocol_check(pkt);
        cvg.sample_delays(previous_slave_ts[slv_idx],pkt); //pass previous pkt timestamp //just for testing kept same pkt.timestamp
        previous_slave_ts[slv_idx] = (pkt.operation==WRITE) ? pkt.wadd_hndshk: pkt.radd_hndshk;
        actual_req[slv_idx].push_front(pkt);
        end
      join_none
    end
  endtask

  task axi_cdma_axi_scoreboard :: get_master_packets(); // get slave pkts from slave_analysis_fifos and put them to actual_req ques //continuously running loops
    realtime previous_master_ts[];
    `uvm_info ("Scoreboard :: get_master_packets" ,"Triggred", UVM_MEDIUM)
    previous_master_ts =new[obj.no_of_masters]; //holds previous commadn timestamp
    for(int i=0 ; i<obj.no_of_masters ;i++)begin
    automatic int mas_idx = i;
    fork
      forever begin
        `uvm_info ("Scoreboard :: get_master_packets" ,$sformatf("Waiting at master %d m_af.get ",mas_idx), UVM_MEDIUM)
        m_af[mas_idx].get(actual_response_pkt);
        `uvm_info ("Scoreboard :: get_master_packets" ,$sformatf("got pkt from master m_af %d",mas_idx), UVM_MEDIUM)
        if(actual_response_pkt.operation==WRITE)actual_response_pkt.print_write_txn(actual_response_pkt);
        else actual_response_pkt.print_read_txn(actual_response_pkt);
        actual_response_pkt.axi_protocol_check(actual_response_pkt);
        cvg.sample_delays(previous_master_ts[mas_idx],actual_response_pkt); //pass previous pkt timestamp //just for testing kept same pkt time stamp
        process_packet(actual_response_pkt,mas_idx);
        previous_master_ts[mas_idx] = (actual_response_pkt.operation==WRITE) ? actual_response_pkt.wadd_hndshk: actual_response_pkt.radd_hndshk;
      end
    join_none
    end
  endtask

  function void axi_cdma_axi_scoreboard :: process_packet(input axi_cdma_axi_master_seq_item act_master_pkt , input int master_index);
    axi_cdma_axi_slave_seq_item  exp_slave_pkts[4][$] ,act_slave_pkts[$]; //stores expected/actual slave packet/packets in case of split.
    axi_cdma_axi_master_seq_item exp_master_pkt; // expected master packet (expected response pkt)
    int slave_index;
    predict_slave_pkt(exp_slave_pkts,slave_index,act_master_pkt,master_index);
    compare_slave_exp_vs_actual(act_slave_pkts,exp_slave_pkts,slave_index); //handle case when no pkt matches
    predict_master_pkt(exp_master_pkt,act_slave_pkts,act_master_pkt,master_index,slave_index); //input slave index also
    compare_master_exp_vs_actual(exp_master_pkt ,act_master_pkt); // compare all read/write phases
  endfunction

//Prediction and compare functions
function void axi_cdma_axi_scoreboard :: predict_slave_pkt(output axi_cdma_axi_slave_seq_item exp_slave_pkts[4][$], output int slave_index, input axi_cdma_axi_master_seq_item act_master_pkt, input int master_index);
    axi_cdma_axi_slave_seq_item pkt;
    int conversion_ratio, slave_aligned_adjustment;
    int exp_beats, master_size, slave_size, length,no_of_split_packets;
    id_t id;
    burst_type_t burst;
    address_t address;
    command_t operation;
    strobe_t  strobe_queue[$] ;
    data_t    data_queue[$];
    strobe_t exp_strobe;  //32 bit
    data_t exp_data; // 256 bits
    `uvm_info ("Scoreboard :: predict_slave_pkt triggred" ,$sformatf("master_index = %d",master_index)  , UVM_MEDIUM)

    // slave detection logic
    if(act_master_pkt.operation ==WRITE)begin
      address = act_master_pkt.awaddr;
      master_size = act_master_pkt.awsize;
      length = act_master_pkt.awlen;
      operation = WRITE;
      id = act_master_pkt.awid;
      burst = act_master_pkt.awburst;
      end
    else if(act_master_pkt.operation ==READ)begin
      address = act_master_pkt.araddr;
      master_size = act_master_pkt.arsize;
      length = act_master_pkt.arlen;
      operation = READ;
      id = act_master_pkt.arid;
      burst = act_master_pkt.arburst;
      end
    else `uvm_error("Scoreboard :: predict_slave_pkt","pkt.operation undefined")
    slave_index = decode_slave_index(address);
    `uvm_info ("Scoreboard :: predict_slave_pkt" ,$sformatf("decoded slave_index = %d",slave_index)  , UVM_MEDIUM)
    cvg.sample_address_decoding(master_index,slave_index);
    conversion_ratio = $ceil((2**master_size) / real'(slave_width[slave_index]));
    exp_beats = ((length+1) * conversion_ratio) ;
    no_of_split_packets = $ceil(exp_beats/256.00);
    slave_size =  (master_size<slave_width[slave_index]) ? master_size : slave_width[slave_index] ;
    slave_aligned_adjustment = (address &((2**master_size)-1) & ~(slave_width[slave_index] -1))/slave_width[slave_index]; //unaligned address adjustment
    `uvm_info ("Scoreboard :: predict_slave_pkt" ,$sformatf("conv_ratio = %d, exp_beats = %d, no_of_split_packets= %d, slave_size= %d",conversion_ratio,exp_beats,no_of_split_packets,slave_size)  , UVM_MEDIUM)
    for(int i=0;i<no_of_split_packets;i++) begin //generate number of split packets
    //add info per packet
      pkt = axi_cdma_axi_slave_seq_item :: type_id :: create("pkt");
      //WRITE address phase prediction
      if(operation == WRITE)begin
        pkt.awid     = id;
        pkt.awsize   = slave_size;
        pkt.awburst  = burst; // will change in case of wrap
        pkt.awlock   = act_master_pkt.awlock;
        pkt.awprot   = act_master_pkt.awprot;
        pkt.awqos    = act_master_pkt.awqos;
        pkt.awregion = act_master_pkt.awregion;
        pkt.awcache  = act_master_pkt.awcache;
        pkt.operation= operation;
        if(i==0)pkt.awaddr = address;
        else pkt.awaddr = (address & ~((2**master_size)-1)) + ((i) * 256 *slave_width[slave_index]);
        if(i==0) begin
          if(no_of_split_packets == 1) pkt.awlen = (exp_beats-1) - slave_aligned_adjustment; //no split case
          else pkt.awlen =255 - slave_aligned_adjustment;  //split case
        end else if(i==no_of_split_packets-1) pkt.awlen = (exp_beats-1) %256;  //last  beat
        else pkt.awlen = 255;
        //WRITE_Data_prediction beat by beat info
        strobe_queue ={}; //empty queues
        data_queue   ={};
        for(int j =0; j<=length; j++)begin //master_pkt beat selector
          for(int k=0; k<$ceil(master_width[master_index]/real'(slave_width[slave_index])) ; k++)begin  //sub_part_of_beat selector based on conversion ratio
            case(slave_width[slave_index])
            4 :   exp_strobe = act_master_pkt.wstrobe[j][3 :0];
            8 :   exp_strobe = act_master_pkt.wstrobe[j][7 :0];
            16 :  exp_strobe = act_master_pkt.wstrobe[j][15 :0];
            32 :  exp_strobe = act_master_pkt.wstrobe[j][31 :0];
            endcase
            act_master_pkt.wstrobe[j] =  act_master_pkt.wstrobe[j] >> slave_width[slave_index];
            if(exp_strobe != 0)begin
              case(slave_width[slave_index])
              4 :  exp_data = act_master_pkt.wdata[j][(4*8 -1) : 0];
              8 :  exp_data = act_master_pkt.wdata[j][(8*8 -1) : 0];
              16 : exp_data = act_master_pkt.wdata[j][(16*8 -1) : 0];
              32 : exp_data = act_master_pkt.wdata[j][(32*8 -1) : 0];
              endcase
              strobe_queue.push_front(exp_strobe);
              data_queue.push_front(exp_data);
            end
              act_master_pkt.wdata[j] =  act_master_pkt.wdata[j] >> (slave_width[slave_index]*8);
          end
        end
          pkt.wstrobe =new[pkt.awlen +1];
          pkt.wdata   =new[pkt.awlen +1];
          foreach(pkt.wstrobe[m])begin //beat selector
            pkt.wstrobe[m] = strobe_queue.pop_back();
            pkt.wdata[m] = data_queue.pop_back();
          end
      end
      //READ address_phase prediction
      if(operation == READ)begin
        pkt.arid     = id;
        pkt.arsize   = slave_size;
        pkt.arburst  = burst; // will change in case of wrap
        pkt.arlock   = act_master_pkt.arlock;
        pkt.arprot   = act_master_pkt.arprot;
        pkt.arqos    = act_master_pkt.arqos;
        pkt.arregion = act_master_pkt.arregion;
        pkt.arcache  = act_master_pkt.arcache;
        pkt.operation= operation;
        if(i==0)pkt.araddr = address;
        else pkt.araddr = (address & ~((2**master_size)-1)) + ((i-1) * 256 *slave_width[slave_index]);
        if(i==0) begin
          if(no_of_split_packets == 1) pkt.arlen = (exp_beats-1) - slave_aligned_adjustment; //no split case
          else pkt.arlen =255 - slave_aligned_adjustment;  //split case
        end else if(i==no_of_split_packets-1) pkt.arlen = (exp_beats-1) %256;  //last  beat
        else pkt.arlen = 255;
      end
    exp_slave_pkts[slave_index].push_front(pkt);
    end
    //axi_cdma_axi_coverage sampling
    cvg.sample_axi_features(slave_aligned_adjustment,no_of_split_packets,master_size,slave_size);
  endfunction



  function void axi_cdma_axi_scoreboard :: compare_slave_exp_vs_actual(output axi_cdma_axi_slave_seq_item act_slave_pkts[$],input axi_cdma_axi_slave_seq_item exp_slave_pkts[4][$],input int slave_index);
  int j;
    `uvm_info ("Scoreboard :: compare_slave_exp_vs_actual triggred" ,"", UVM_MEDIUM)
    //search in actual_req_queue of desired slave agent.(decode this based on address)
    // if exp pkt dosnt match with any actual pkts then store it somewhere so that later it can be reported.
    assert(exp_slave_pkts[slave_index].size >0) else `uvm_error("Scoreboard_Error","Assertion Failure :: slave_packet_prediction fail. No packets passed for comparison");
    foreach(exp_slave_pkts[slave_index][i])begin
      for(j=0;j<actual_req[slave_index].size();j++) begin
        if(exp_slave_pkts[slave_index][i].operation ==WRITE &&
        exp_slave_pkts[slave_index][i].operation == actual_req[slave_index][j].operation &&
        exp_slave_pkts[slave_index][i].awaddr == actual_req[slave_index][j].awaddr &&
        exp_slave_pkts[slave_index][i].awlen == actual_req[slave_index][j].awlen &&
        exp_slave_pkts[slave_index][i].awsize == actual_req[slave_index][j].awsize
        //exp_slave_pkts[slave_index][i].awid == actual_req[slave_index][j].awid
        //add data check later
        //add more fields if required (in case of multiple pkts with same address)// add conditional checking for id for slaves that support id
        ) begin
           act_slave_pkts.push_front(actual_req[slave_index][j]);
           actual_req[slave_index].delete(j);
           break;
        end
        if(exp_slave_pkts[slave_index][i].operation ==READ &&
        exp_slave_pkts[slave_index][i].operation == actual_req[slave_index][j].operation &&
        exp_slave_pkts[slave_index][i].araddr == actual_req[slave_index][j].araddr &&
        exp_slave_pkts[slave_index][i].arlen == actual_req[slave_index][j].arlen &&
        exp_slave_pkts[slave_index][i].arsize == actual_req[slave_index][j].arsize
       // exp_slave_pkts[slave_index][i].arid == actual_req[slave_index][j].arid
         //add more fields if required (in case of multiple pkts with same address)
        ) begin
           act_slave_pkts.push_front(actual_req[slave_index][j]);
           actual_req[slave_index].delete(j);
           break;
        end
      if((j == actual_req[slave_index].size() -1) && (act_slave_pkts.size()!=exp_slave_pkts[slave_index].size())) `uvm_error("Scoreboard :: compare_slave_exp_vs_actual"," didnt find all the expected slave packets")
      end
    end
  endfunction

  function void axi_cdma_axi_scoreboard :: predict_master_pkt(output axi_cdma_axi_master_seq_item exp_master_pkt, input axi_cdma_axi_slave_seq_item act_slave_pkts[$],input axi_cdma_axi_master_seq_item act_master_pkt,input int master_index,slave_index);
   response_t temp_rresp;
   data_t rdata_queue[$], temp_data;
   response_t rresp_queue[$];
   int conversion_ratio;
   `uvm_info ("Scoreboard :: predict_master_pkt triggred" ,$sformatf("master_index = %d",master_index)  , UVM_MEDIUM)
    exp_master_pkt = axi_cdma_axi_master_seq_item :: type_id :: create("exp_master_pkt");
    assert(act_slave_pkts.size()>0) else `uvm_error("Scoreboard_Error","Assertion Failure :: Slave_Packet_comparison fail. act_slave_pkts_queue passed for master_pkt prediction is Empty");
    if(act_slave_pkts[0].operation==WRITE) begin
      if(slave_index == 2)exp_master_pkt.bid = act_slave_pkts[0].bid[4:0]; //asigning bid from slave which uses id.
      else exp_master_pkt.bid = act_master_pkt.awid;
      exp_master_pkt.bresp = OKAY; //initially setting okay
      //add other phase info if required
      foreach(act_slave_pkts[i])begin
      exp_master_pkt.bresp = (act_slave_pkts[i].bresp.num()>exp_master_pkt.bresp.num())? act_slave_pkts[i].bresp : exp_master_pkt.bresp; //if any slave_pkt has worse response then update response in exp_master_pkt
      end
      act_slave_pkts={};  // empty the queue
    end else if(act_slave_pkts[0].operation==READ) begin
    //get rdata and rresp from all slave packets in one queue
      foreach(act_slave_pkts[i])begin
        foreach(act_slave_pkts[i].rdata[j])begin
          rdata_queue.push_front(act_slave_pkts[i].rdata[j]);
          rresp_queue.push_front(act_slave_pkts[i].rresp[j]);
        end
      end
      conversion_ratio = $ceil((act_master_pkt.arsize**2) / real'(slave_width[slave_index]));
      `uvm_info ("Scoreboard :: Test_expression" ,$sformatf("conversion_ratio = %d",conversion_ratio)  , UVM_MEDIUM)
      exp_master_pkt.rdata = new[act_master_pkt.arlen+1];  //rlength from initial master pkt//
      exp_master_pkt.rresp = new[act_master_pkt.arlen+1];
      if(slave_index == 2)exp_master_pkt.rid = act_slave_pkts[0].arid[4:0];
      else exp_master_pkt.rid = act_master_pkt.rid;
      foreach(exp_master_pkt.rdata[j])begin //mearging beats
        exp_master_pkt.rresp[j] = OKAY; //initially
        temp_data = 0;  //initially keeping 0 go avoid x
        exp_master_pkt.rdata[j] = 0; //initially
        for(int k =0 ; k<conversion_ratio; k++)begin
        case (2**act_slave_pkts[0].arsize)  //(slave_width[slave_index])
        8  : exp_master_pkt.rdata[j][(8*8*(k))  +: (8*8)] =rdata_queue.pop_back();
        16 : exp_master_pkt.rdata[j][(16*8*(k)) +: (16*8)] =rdata_queue.pop_back();
        32 : exp_master_pkt.rdata[j][(32*8)-1      : 0]      =rdata_queue.pop_back();
        4  : exp_master_pkt.rdata[j][(4*8*k)  +: (4*8)] =rdata_queue.pop_back();
        endcase
        //exp_master_pkt.rdata[j] = temp_data ;// exp_master_pkt.rdata[j] ; //add logic to shift beat data in case of narrow transfer/Byte_lane_stearing
        temp_rresp = rresp_queue.pop_back();
        exp_master_pkt.rresp[j]= (temp_rresp.num()>exp_master_pkt.rresp[j].num()) ? temp_rresp : exp_master_pkt.rresp[j]; //selecting worse response on merging beats
        end
      end
    end
  endfunction

  function void axi_cdma_axi_scoreboard :: compare_master_exp_vs_actual(input axi_cdma_axi_master_seq_item exp_master_pkt ,act_master_pkt);
    `uvm_info ("Scoreboard :: compare_master_exp_vs_actual triggred" ,"", UVM_MEDIUM)
    //compare write response/ read data phase
    if(act_master_pkt.operation ==WRITE)begin
       if(!act_master_pkt.comp_write_resp(act_master_pkt,exp_master_pkt))begin
      `uvm_error("Scoreboard :: compare_master_exp_vs_actual","Error-packet mismatch")
      failed_comparisons +=1;
      error_packets.push_front(act_master_pkt); //keeping error pkt for analysis later
      end else successful_comparisons +=1;
    end else begin
      if(!act_master_pkt.comp_read_data(act_master_pkt,exp_master_pkt))begin
      `uvm_error("Scoreboard :: compare_master_exp_vs_actual","Error-packet mismatch")
      failed_comparisons +=1;
      error_packets.push_front(act_master_pkt);
      end else successful_comparisons +=1;
    end
  endfunction
