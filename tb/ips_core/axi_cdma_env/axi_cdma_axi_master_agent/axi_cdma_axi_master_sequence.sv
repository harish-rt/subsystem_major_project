/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_sequence.sv                      */
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
//import axi_package :: *;
class axi_cdma_axi_base_master_sequence extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (axi_cdma_axi_base_master_sequence)

   axi_cdma_axi_master_seq_item pkt;

  function new (string name = "axi_cdma_axi_base_master_sequence");
     super.new (name);
  endfunction

  virtual task body ();
  /*
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awid ==5;
	  awaddr==32'h44A0_0000;
	  awlock==0;
	  awprot ==0;
	  awqos ==0;
	  awregion==0;
	  awcache==0;
	  awlen == 3;
	  awsize== 2;
	  awburst==INCR;
	  bid ==5;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
 foreach (pkt.wstrobe[i])
   pkt.wstrobe[i] = 32'h0000_000f;
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE ;
                                awid ==2 ;
	  awaddr==32'h44A0_00ff ;
	  awlock==0 ;
	  awprot ==0 ;
	  awqos ==0 ;
	  awregion==0 ;
	  awcache==0 ;
	  awlen == 2 ;
	  awsize==2 ;
	  awburst==INCR ;
	  bid==2;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
 foreach (pkt.wstrobe[i])
   pkt.wstrobe[i] = 32'h0000_000f;
  finish_item(pkt);
  //READ
  */
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==8;
	  araddr==32'h44A0_00ff;
	  arlock==0;
	  arprot ==0;
	  arqos ==0 ;
	  arregion==0;
	  arcache==0;
	  arlen ==5;
	  arsize==2;
	  arburst==INCR;
	  rid==8;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==9;
	  araddr==32'h44A0_0fff;
	  arlock==0;
	  arprot ==0;
	  arqos ==0 ;
	  arregion==0;
	  arcache==0;
	  arlen ==3;
	  arsize==2;
	  arburst==INCR;
	  rid==9;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  finish_item(pkt);

  endtask : body
  endclass : axi_cdma_axi_base_master_sequence

  function axi_cdma_axi_master_seq_item create_packet(
                                         input command_t operation,
	           input int slave_index,
	           input burst_size_t size[2],
	           input burst_len_t len[2],
	           input burst_type_t burst,
	           input bit alignment  //1-aligned//0-un_aligned
	           );
//Example->
//pkt = create_packet(WRITE,2,{4,2},{10,5},INCR,1);
  axi_cdma_axi_master_seq_item pkt;
  axi_cdma_config_obj obj;
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  obj = axi_cdma_config_obj :: type_id ::create ("obj");
  uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj);
  `uvm_info("Packet_generator",$sformatf("operation = %s ,slave_index =%d, size=%p, length =%p, burst =%s,alignment =%b",operation,slave_index,size,len,burst,alignment),UVM_MEDIUM)
  `uvm_info("Packet_generator",$sformatf("axi_cdma_config_obj = %p",obj),UVM_MEDIUM)
  case(operation)
    WRITE :begin
           assert (pkt.randomize() with {operation == WRITE;
                                //awaddr == 32'h44a0_0020;
	  awaddr[31:20]==12'h44A && awaddr[19:16]==slave_index && awaddr[15:12]==0;
	  awburst == burst;
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen inside {[len[1]:len[0]]};
	  awsize inside {[size[1]:size[0]]};})
           else  `uvm_error ("Packet_generator" ,"Packet Randomization Fail")
           if(alignment==1)begin
             case (obj.slave_width[decode_slave_index(pkt.awaddr)]) //address alignment
               32'd4  : pkt.awaddr[1:0]=0;
               32'd8  : pkt.awaddr[2:0]=0;
               32'd16 : pkt.awaddr[3:0]=0;
               32'd32 : pkt.awaddr[4:0]=0;
               default: `uvm_error("Packet_generator","slave_index_decode Fail")
             endcase
           end
           case(pkt.awsize) //setting valid strobe bits
           2 : foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_000f;
           3 : foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_00ff;
           4 : foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_ffff;
           5 : foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'hffff_ffff;
           default: `uvm_error("Packet_generator","Invalid awsize")
           endcase
//pkt.print_write_txn(pkt);
    end
    READ :begin
          assert (pkt.randomize() with {operation == READ;
                                araddr[31:20]==12'h44A && araddr[19:16]==slave_index && araddr[15:12]==0;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arburst==burst;
	  arlen inside {[len[1]:len[0]]};
	  arsize inside {[size[1]:size[0]]};
	  })
          else `uvm_error ("Packet_generator" ,"Packet Randomization Fail")
          case (obj.slave_width[decode_slave_index(pkt.araddr)]) //address alignment
               32'd4  : pkt.araddr[1:0]=0;
               32'd8  : pkt.araddr[2:0]=0;
               32'd16 : pkt.araddr[3:0]=0;
               32'd32 : pkt.araddr[4:0]=0;
          endcase
         //  foreach(pkt.rresp[i]) pkt.rresp[i] = OKAY;
//pkt.print_read_txn(pkt);
    end
    default : `uvm_error("Packet_generator","Invalid Instruction requested")
  endcase
  return pkt;
endfunction

class master_priority_sequence_m0 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_priority_sequence_m0)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_priority_sequence_m0");
     super.new (name);
  endfunction

  virtual task body ();
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a2_0020;
	  awid==0;
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;
	  awburst==INCR;
	  bid ==0;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
   pkt.write_valid2valid_dly[0] =0;
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==0;
	  araddr==32'h44A0_1000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==0;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_priority_sequence_m0

class master_priority_sequence_m1 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_priority_sequence_m1)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_priority_sequence_m1");
     super.new (name);
  endfunction

  virtual task body ();
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a2_0040;
	  awid==1; awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;
	  awburst==INCR;
	  bid ==1;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=0;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
   pkt.write_valid2valid_dly[0] =0;
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==10;
	  araddr==32'h44A0_2000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==10;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_priority_sequence_m1

class master_priority_sequence_m2 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_priority_sequence_m2)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_priority_sequence_m2");
     super.new (name);
  endfunction

  virtual task body ();
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a2_0060;
	  awid==2; awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;
	  awburst==INCR;
	  bid ==2;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=200;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
   pkt.write_valid2valid_dly[0] =0;
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==20;
	  araddr==32'h44A0_3000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==20;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_priority_sequence_m2

class master_priority_sequence_m3 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_priority_sequence_m3)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_priority_sequence_m3");
     super.new (name);
  endfunction

  virtual task body ();
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a2_0080;
	  awid==3; awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;
	  awburst==INCR;
	  bid ==3;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=0;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
   pkt.write_valid2valid_dly[0] =0;
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==30;
	  araddr==32'h44A0_4000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==30;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_priority_sequence_m3

// Scoreboard testing Sequences
class master_scb_sequence_m0 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_scb_sequence_m0)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_scb_sequence_m0");
     super.new (name);
  endfunction

  virtual task body ();

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a0_0000;
	  awid==1;
	  awlock==0;
	  awprot ==0;
	  awqos ==0;
	  awregion==0;
	  awcache==0;
	  awlen == 1;
	  awsize== 3;
	  awburst==INCR;
	  bid ==1;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_00ff;
   pkt.wstrobe[1] = 32'h0000_00ff;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
  /*
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==1;
	  araddr==32'h44A0_0020;
	  arlock==0;
	  arprot ==0;
	  arqos ==0 ;
	  arregion==0;
	  arcache==0;
	  arlen ==3;
	  arsize==3;
	  arburst==INCR;
	  rid==1;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);  */
 endtask : body
endclass : master_scb_sequence_m0

class master_scb_sequence_m1 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_scb_sequence_m1)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_scb_sequence_m1");
     super.new (name);
  endfunction

  virtual task body ();  //128 bit master
  /*
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a2_0000;
	  awid==2;
	  awlock==0;
	  awprot ==0;
	  awqos ==0;
	  awregion==0;
	  awcache==0;
	  awlen == 1;
	  awsize== 4;
	  awburst==INCR;
	  bid ==2;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_ffff;
   pkt.wstrobe[1] = 32'h0000_ffff;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=0;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt); */
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==2;
	  araddr==32'h44A2_0000;
	  arlock==0;
	  arprot ==0;
	  arqos ==0 ;
	  arregion==0;
	  arcache==0;
	  arlen ==1;
	  arsize==4;
	  arburst==INCR;
	  rid==2;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=00;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_scb_sequence_m1

class master_scb_sequence_m2 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_scb_sequence_m2)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_scb_sequence_m2");
     super.new (name);
  endfunction

  virtual task body (); //256 bit master
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a3_0000;
	  awid==3;
	  awlock==0;
	  awprot ==0;
	  awqos ==0;
	  awregion==0;
	  awcache==0;
	  awlen == 0;
	  awsize== 5;
	  awburst==INCR;
	  bid ==3;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'hffff_ffff;
   //pkt.wstrobe[1] = 32'h0000_ffff;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=0;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_scb_sequence_m2

class master_scb_sequence_m3 extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (master_scb_sequence_m3)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "master_scb_sequence_m3");
     super.new (name);
  endfunction

  virtual task body ();  //32 bit master
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a1_0000;
	  awid==4;
	  awlock==0;
	  awprot ==0;
	  awqos ==0;
	  awregion==0;
	  awcache==0;
	  awlen == 1;
	  awsize== 2;
	  awburst==INCR;
	  bid ==4;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
   pkt.wstrobe[1] = 32'h0000_000f;
   pkt.add_valid_dly =0;
   pkt.resp_ready_dly=0;
   pkt.cmd2cmd_dly=0;
   pkt.add2data_dly=0;
  finish_item(pkt);
 endtask : body
endclass : master_scb_sequence_m3

class access_test_sequence extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (access_test_sequence)
   axi_cdma_axi_master_seq_item pkt;

 function new (string name = "access_test_sequence");
     super.new (name);
  endfunction

  virtual task body ();


  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr== 32'h44a0_0020; //slave_0
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  pkt.wstrobe[0] = 32'h0000_000f;
  finish_item(pkt);
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr== 32'h44a1_0040;//slave 1
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a2_0000;//slave2
                                awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;
	  awid==0;
	})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  pkt.wstrobe[0] = 32'h0000_000f;
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
                                awaddr == 32'h44a3_0020;//slave3
                                awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 0;
	  awsize== 2;
	})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
   pkt.wstrobe[0] = 32'h0000_000f;
  finish_item(pkt);

//READ Stimulus

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==0;
	  araddr==32'h44A0_0000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==0;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==1;
	  araddr==32'h44A1_0000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==1;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==2;
	  araddr==32'h44A2_0000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==2;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == READ;
                                arid ==3;
	  araddr==32'h44A3_0000;
	  arlock==0; arprot ==0; arqos ==0 ; arregion==0; arcache==0;
	  arlen ==0;
	  arsize==2;
	  arburst==INCR;
	  rid==3;})
   else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  finish_item(pkt);

 endtask : body
endclass : access_test_sequence


class burst_test_sequence extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (burst_test_sequence)
   axi_cdma_axi_master_seq_item pkt;
   axi_cdma_config_obj obj;

 function new (string name = "burst_test_sequence");
     super.new (name);
  endfunction

  virtual task body (); //master 0 targeting random addresses total 4 64_bitwrite txns (3-test each burst type 1- incr burst with split) all addresses aligned
  obj = axi_cdma_config_obj :: type_id ::create ("obj");
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj);

  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
	  awburst == INCR;
                                awaddr[31:18] =={12'h44A,2'b00} && awaddr[15:12] == 0 ;
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen inside {[4:9]}; //5 to 10 beats
	  awsize== 3;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  case (obj.slave_width[decode_slave_index(pkt.awaddr)]) //address alignment
    32'd4  : pkt.awaddr[1:0]=0;
    32'd8  : pkt.awaddr[2:0]=0;
    32'd16 : pkt.awaddr[3:0]=0;
    32'd32 : pkt.awaddr[4:0]=0;
  endcase
 $display("slavewidth=%d",obj.slave_width[decode_slave_index (pkt.awaddr)]);
  foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_00ff;
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
	  awburst == FIXED;
                                awaddr[31:18] =={12'h44A,2'b00} && awaddr[15:12] == 0 ;
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen inside {[4:9]}; //5 to 10 beats
	  awsize== 3;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  case (obj.slave_width[decode_slave_index(pkt.awaddr)]) //address alignment
    32'd4  : pkt.awaddr[1:0]=0;
    32'd8  : pkt.awaddr[2:0]=0;
    32'd16 : pkt.awaddr[3:0]=0;
    32'd32 : pkt.awaddr[4:0]=0;
  endcase
 $display("slavewidth=%d",obj.slave_width[decode_slave_index (pkt.awaddr)]);
  foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_00ff;
  finish_item(pkt);

  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
	  awburst == WRAP;
                                awaddr[31:18] =={12'h44A,2'b00} && awaddr[15:12] == 0 ;
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen inside {[4:9]}; //5 to 10 beats
	  awsize== 3;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  case (obj.slave_width[decode_slave_index(pkt.awaddr)]) //address alignment
    32'd4  : pkt.awaddr[1:0]=0;
    32'd8  : pkt.awaddr[2:0]=0;
    32'd16 : pkt.awaddr[3:0]=0;
    32'd32 : pkt.awaddr[4:0]=0;
  endcase
 $display("slavewidth=%d",obj.slave_width[decode_slave_index (pkt.awaddr)]);
  foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_00ff;
  finish_item(pkt);

//Split packet m064bit to s0 32bit downconversion
  pkt = axi_cdma_axi_master_seq_item :: type_id :: create ("pkt");
  start_item(pkt);
  assert (pkt.randomize() with {operation == WRITE;
	  awburst == INCR;
                                awaddr[31:16] == 16'h44A0;
	  awlock==0; awprot ==0; awqos ==0; awregion==0; awcache==0;
	  awlen == 150;//inside {[15:20]}; //resulting into 2x beats to cause split
	  awsize== 3;})
  else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  case (obj.slave_width[decode_slave_index(pkt.awaddr)]) //address alignment
    32'd4  : pkt.awaddr[1:0]=0;
    32'd8  : pkt.awaddr[2:0]=0;
    32'd16 : pkt.awaddr[3:0]=0;
    32'd32 : pkt.awaddr[4:0]=0;
  endcase
  pkt.awaddr = 32'h44a0_0000;
 $display("slavewidth=%d",obj.slave_width[decode_slave_index (pkt.awaddr)]);
  foreach(pkt.wstrobe[i]) pkt.wstrobe[i] = 32'h0000_00ff;
  finish_item(pkt);
  endtask
endclass : burst_test_sequence

class width_conversion_test_sequence extends uvm_sequence #(axi_cdma_axi_master_seq_item);
  `uvm_object_utils (width_conversion_test_sequence)
   axi_cdma_axi_master_seq_item pkt;
   axi_cdma_config_obj obj;
   int target_master; //configure from vseq
 function new (string name = "width_conversion_test_sequence");
     super.new (name);
  endfunction

  virtual task body (); //all masters to all slaves with size equal to master width to see width conversion.
  int x;
  obj = axi_cdma_config_obj :: type_id ::create ("obj");
  uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj);

    x=  $clog2(obj.master_width[target_master]);
    for(int i=0; i<4;i++)begin
      pkt = create_packet(WRITE,i,{x,x},{0,0},INCR,1);
      start_item(pkt);
      finish_item(pkt);
      //pkt = create_packet(READ,i,{x,x},{0,0},FIXED,1);
      //start_item(pkt);
      //finish_item(pkt);
    end

  endtask :body
endclass : width_conversion_test_sequence
