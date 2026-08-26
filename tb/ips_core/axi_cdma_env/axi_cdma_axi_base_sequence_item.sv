/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/sequence_item.sv                        */
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
//base sequence item


class axi_cdma_axi_base_seq_item extends uvm_sequence_item;
  //FACTORY REGISTRATION

  //MEMEBERS
  string str ; /// just for testing wrapper
   //Write address channel
   rand   logic  [ID_WIDTH-1:0]     awid;
   rand   logic  [ADDR_WIDTH-1:0]   awaddr;
   rand   logic  [BURST_LENGTH-1:0] awlen;
   rand   burst_type_t                awburst;
   rand   logic  [BURST_SIZE-1:0]   awsize;
          logic                     awvalid;
          logic                     awready;
   rand   logic                     awlock;
   rand   logic  [PROT_WIDTH-1:0]   awprot;
   rand   logic  [QOS_WIDTH-1:0]    awqos;
   rand   logic  [REGION_WIDTH-1:0] awregion;
   rand   logic  [CACHE_WIDTH-1:0]    awcache;
   //write response channel
   rand   logic  [ID_WIDTH-1:0]     bid;
   rand   response_t                 bresp;
          logic                     bvalid;
          logic                     bready;
   //write data channel
   rand   logic  [DATA_WIDTH-1:0]   wdata[];
   rand   logic  [STROBE_WIDTH-1:0] wstrobe[];
          logic                     wlast;
          logic                     wvalid;
          logic                     wready;
   // read address channel
   rand   logic  [ID_WIDTH-1:0]     arid;
   rand   logic  [ADDR_WIDTH-1:0]   araddr;
   rand   logic  [BURST_LENGTH-1:0] arlen;
   rand   burst_type_t                arburst;
   rand   logic  [BURST_SIZE-1:0]   arsize;
          logic                     arvalid;
          logic                     arready;
   rand   logic                     arlock;
   rand   logic  [PROT_WIDTH-1:0]   arprot;
   rand   logic  [QOS_WIDTH-1:0]    arqos;
   rand   logic  [REGION_WIDTH-1:0] arregion;
   rand   logic  [CACHE_WIDTH-1:0]  arcache;
   // read data channel
   rand   logic  [ID_WIDTH-1:0]     rid;
   rand   response_t                rresp[];
   rand   logic  [DATA_WIDTH-1:0]   rdata[];
          logic                     rlast;
          logic                     rvalid;
          logic                     rready;

   //Delays
   rand delay_t cmd2cmd_dly , add2data_dly;
   rand command_t operation;

   //Timestamps to store meaningfull events (capture whenever ready and valid are high )
   realtime radd_hndshk, rdata_hndshk[], wadd_hndshk, wdata_hndshk[], wresp_hndshk;  // to capture timing when handshakes happen
   reset_info_t reset_op = NO_RESET; //monitor signals reset info to sb using this enum //setting default value to be NO_RESET
   realtime reset_asserted, reset_deasserted;  //to hold reset timestamp info

   `uvm_object_utils_begin(axi_cdma_axi_base_seq_item)
    //field registration for write address channel signals
   `uvm_field_int(awid,UVM_ALL_ON)
   `uvm_field_int(awaddr,UVM_ALL_ON)
   `uvm_field_int(awlen,UVM_ALL_ON)
   `uvm_field_enum(command_t,operation,UVM_ALL_ON)
   `uvm_field_enum(burst_type_t,awburst,UVM_ALL_ON)
   `uvm_field_int(awsize,UVM_ALL_ON)
   `uvm_field_int(awvalid,UVM_ALL_ON)
   `uvm_field_int(awready,UVM_ALL_ON)
   `uvm_field_int(awlock,UVM_ALL_ON)
   `uvm_field_int(awprot,UVM_ALL_ON)
   `uvm_field_int(awqos,UVM_ALL_ON)
   `uvm_field_int(awregion,UVM_ALL_ON)
   `uvm_field_int(awcache,UVM_ALL_ON)
    //field registration for write response channel signals
   `uvm_field_int(bid,UVM_ALL_ON)
   `uvm_field_enum(response_t,bresp,UVM_ALL_ON)
   `uvm_field_int(bvalid,UVM_ALL_ON)
   `uvm_field_int(bready,UVM_ALL_ON)
    //field registration for write data channel signals
   `uvm_field_array_int(wdata,UVM_ALL_ON)
   `uvm_field_array_int(wstrobe,UVM_ALL_ON)
   `uvm_field_int(wlast,UVM_ALL_ON)
   `uvm_field_int(wvalid,UVM_ALL_ON)
   `uvm_field_int(wready,UVM_ALL_ON)
    //field registration for read address channel signals
   `uvm_field_int(arid,UVM_ALL_ON)
   `uvm_field_int(araddr,UVM_ALL_ON)
   `uvm_field_int(arlen,UVM_ALL_ON)
   `uvm_field_enum(burst_type_t,arburst,UVM_ALL_ON)
   `uvm_field_int(arsize,UVM_ALL_ON)
   `uvm_field_int(arvalid,UVM_ALL_ON)
   `uvm_field_int(arready,UVM_ALL_ON)
   `uvm_field_int(arlock,UVM_ALL_ON)
   `uvm_field_int(arprot,UVM_ALL_ON)
   `uvm_field_int(arqos,UVM_ALL_ON)
   `uvm_field_int(arregion,UVM_ALL_ON)
   `uvm_field_int(arcache,UVM_ALL_ON)
    //field registration for read data channel signals
   `uvm_field_int(rid,UVM_ALL_ON)
   `uvm_field_array_int(rdata,UVM_ALL_ON)
   `uvm_field_array_enum(response_t,rresp,UVM_ALL_ON)
   `uvm_field_int(rlast,UVM_ALL_ON)
   `uvm_field_int(wvalid,UVM_ALL_ON)
   `uvm_field_int(wready,UVM_ALL_ON)
   `uvm_object_utils_end
 

  function new (string name = "axi_cdma_axi_base_seq_item");
     super.new (name);
  endfunction

  extern function bit read_pkt_compare(axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit write_pkt_compare(axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_read_add   (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_read_data  (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_write_add  (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_write_data (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_write_resp (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_write_txn  (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function bit comp_read_txn   (axi_cdma_axi_base_seq_item obj1, obj2);
  extern function void print_read_txn      (axi_cdma_axi_base_seq_item obj);
  extern function void print_write_txn     (axi_cdma_axi_base_seq_item obj);
  extern function void print_write_resp    (axi_cdma_axi_base_seq_item obj);
  extern function void print_write_addr    (axi_cdma_axi_base_seq_item obj);
  extern function void print_write_data    (axi_cdma_axi_base_seq_item obj);
  extern function void print_read_addr     (axi_cdma_axi_base_seq_item obj);
  extern function void print_read_data     (axi_cdma_axi_base_seq_item obj);
  extern function void axi_protocol_check  (axi_cdma_axi_base_seq_item pkt);

  //CONSTRAINTS
  //write related
  //constraint wdata_hndshk_c {wdata_hndshk.size() == awlen+1;}
  //read related
  //constraint rdata_hndshk_c {rdata_hndshk.size() == arlen +1;}
  //delay related
  constraint cmd2cmd_dly_c {cmd2cmd_dly inside {[0:10]};}
  constraint add2data_dly_c{add2data_dly inside {[0:10]};}
endclass : axi_cdma_axi_base_seq_item

  //USER-DEFINED METHODS compare and print
function bit axi_cdma_axi_base_seq_item :: read_pkt_compare (axi_cdma_axi_base_seq_item obj1, obj2); // compare read address channel
   bit result =1;
   if (obj1.operation != obj2.operation)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] operation MISMATCH => %s != %s",obj1.operation.name,obj2.operation.name));
   result =0;
   end
   if ( obj1.araddr != obj2.araddr)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] araddr MISMATCH => %d != %d",obj1.araddr,obj2.araddr));
   result =0;
   end
   if (obj1.arlen != obj2.arlen)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arlen MISMATCH => %d != %d",obj1.arlen,obj2.arlen));
   result =0;
   end
   if (obj1.arburst != obj2.arburst)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arburst MISMATCH => %s != %s",obj1.arburst.name,obj2.arburst.name));
   result =0;
   end
   if (obj1.arsize != obj2.arsize)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arsize,obj2.arsize));
   result =0;
   end
   if (obj1.arprot != obj2.arprot)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arprot,obj2.arprot));
   result =0;
   end
   if (obj1.arcache != obj2.arcache)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arcache,obj2.arcache));
   result =0;
   end
   if (obj1.rlast != obj2.rlast)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arlast MISMATCH => %d != %d",obj1.rlast,obj2.rlast));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction

function bit axi_cdma_axi_base_seq_item :: write_pkt_compare (axi_cdma_axi_base_seq_item obj1, obj2); // compare read address channel
   bit result =1;
   if (obj1.operation != obj2.operation)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] operation MISMATCH => %s != %s",obj1.operation.name,obj2.operation.name));
   result =0;
   end
   if ( obj1.awaddr != obj2.awaddr)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awaddr MISMATCH => %d != %d",obj1.awaddr,obj2.awaddr));
   result =0;
   end
   if (obj1.awlen != obj2.awlen)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awlen MISMATCH => %d != %d",obj1.awlen,obj2.awlen));
   result =0;
   end
   if (obj1.awburst != obj2.awburst)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awburst MISMATCH => %s != %s",obj1.awburst.name,obj2.awburst.name));
   result =0;
   end
   if (obj1.awsize != obj2.awsize)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awsize,obj2.awsize));
   result =0;
   end
   if (obj1.awprot != obj2.awprot)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awprot,obj2.awprot));
   result =0;
   end
   if (obj1.awcache != obj2.awcache)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awcache,obj2.awcache));
   result =0;
   end
   if (obj1.wlast != obj2.wlast)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awlast MISMATCH => %d != %d",obj1.wlast,obj2.wlast));
   result =0;
   end
   if (obj1.wstrobe != obj2.wstrobe)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] wstrobe MISMATCH => %p != %p",obj1.wstrobe,obj2.wstrobe));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction


function bit axi_cdma_axi_base_seq_item :: comp_read_add (axi_cdma_axi_base_seq_item obj1, obj2); // compare read address channel
   bit result =1;
   if (obj1.arid != obj2.arid)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arid MISMATCH => %d != %d",obj1.arid,obj2.arid));
   result =0;
   end
   if ( obj1.araddr != obj2.araddr)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] araddr MISMATCH => %d != %d",obj1.araddr,obj2.araddr));
   result =0;
   end
   if (obj1.arlen != obj2.arlen)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arlen MISMATCH => %d != %d",obj1.arlen,obj2.arlen));
   result =0;
   end
   if (obj1.arburst != obj2.arburst)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arburst MISMATCH => %b != %b",obj1.arburst,obj2.arburst));
   result =0;
   end
   if (obj1.arsize != obj2.arsize)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arsize,obj2.arsize));
   result =0;
   end
   if (obj1.arprot != obj2.arprot)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arprot,obj2.arprot));
   result =0;
   end
   if (obj1.arqos != obj2.arqos)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arqos,obj2.arqos));
   result =0;
   end
   if (obj1.arregion != obj2.arregion)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arregion,obj2.arregion));
   result =0;
   end
   if (obj1.arcache != obj2.arcache)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] arsize MISMATCH => %d != %d",obj1.arcache,obj2.arcache));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction

function bit axi_cdma_axi_base_seq_item :: comp_read_data (axi_cdma_axi_base_seq_item obj1, obj2); // compare read data channel
   bit result=1;
   if (obj1.rid != obj2.rid)begin
   `uvm_error("compare_read_data_phase",$sformatf("[COMPARE] rid MISMATCH => %d != %d",obj1.rid,obj2.rid));
   result =0;
   end
 foreach (obj1.rdata[i]) if (obj1.rdata[i] != obj2.rdata[i])begin
   `uvm_error("compare_read_data_phase",$sformatf("[COMPARE] rdata MISMATCH => %p != %p",obj1.rdata,obj2.rdata));
   result =0;
   break;
   end
 foreach (obj1.rresp[i]) if ( obj1.rresp[i] != obj2.rresp[i])begin
   `uvm_error("compare_read_data_phase",$sformatf("[COMPARE] rresp MISMATCH => %p != %p",obj1.rresp,obj2.rresp));
   result =0;
   break;
   end
   return result;
endfunction

function bit axi_cdma_axi_base_seq_item :: comp_write_add (axi_cdma_axi_base_seq_item obj1, obj2); // compare write address channel
   bit result=1;
   if (obj1.awid != obj2.awid)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awid MISMATCH => %d != %d",obj1.awid,obj2.awid));
   result =0;
   end
   if ( obj1.awaddr != obj2.awaddr)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awaddr MISMATCH => %d != %d",obj1.awaddr,obj2.awaddr));
   result =0;
   end
   if (obj1.awlen != obj2.awlen)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awlen MISMATCH => %d != %d",obj1.awlen,obj2.awlen));
   result =0;
   end
   if (obj1.awburst != obj2.awburst)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awburst MISMATCH => %b != %b",obj1.awburst,obj2.awburst));
   result =0;
   end
   if (obj1.awsize != obj2.awsize)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awsize,obj2.awsize));
   result =0;
   end
   if (obj1.awprot != obj2.awprot)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awprot,obj2.awprot));
   result =0;
   end
   if (obj1.awqos != obj2.awqos)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awqos,obj2.awqos));
   result =0;
   end
   if (obj1.awregion != obj2.awregion)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awregion,obj2.awregion));
   result =0;
   end
   if (obj1.awcache != obj2.awcache)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] awsize MISMATCH => %d != %d",obj1.awcache,obj2.awcache));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction

function bit axi_cdma_axi_base_seq_item :: comp_write_data (axi_cdma_axi_base_seq_item obj1, obj2); // compare write data channel
   bit  result =1;
 foreach (obj1.wdata[i]) if ( obj1.wdata[i] != obj2.wdata[i])begin
   `uvm_error("compare_write_data_phase",$sformatf("[COMPARE] wdata MISMATCH => %p != %p",obj1.wdata,obj2.wdata));
   result =0;
   break;
   end
 foreach (obj1.wstrobe[i]) if ( obj1.wstrobe[i] != obj2.wstrobe[i])begin
   `uvm_error("compare_write_data_phase",$sformatf("[COMPARE] wstrobe MISMATCH => %p != %p",obj1.wstrobe,obj2.wstrobe));
   result =0;
   break;
   end
   return result;
endfunction

function bit axi_cdma_axi_base_seq_item :: comp_write_resp (axi_cdma_axi_base_seq_item obj1, obj2); // compare write response channel
   bit result =1;
   if (obj1.bid != obj2.bid)begin
   `uvm_error("compare_write_response_phase",$sformatf("[COMPARE] bid MISMATCH => %d != %d",obj1.bid,obj2.bid));
   result =0;
   end
    if (obj1.bresp != obj2.bresp)begin
   `uvm_error("compare_write_response_phase",$sformatf("[COMPARE] bresp MISMATCH => %b != %b",obj1.bresp,obj2.bresp));
   result =0;
   end
   return result;
endfunction


function bit axi_cdma_axi_base_seq_item :: comp_write_txn (axi_cdma_axi_base_seq_item obj1, obj2); // compare add data and resp phase for a write transaction
   bit result;
   if (comp_write_add(obj1,obj2) && comp_write_data(obj1,obj2) && comp_write_resp(obj1,obj2)) result = 1 ;
   else begin
   result = 0 ;
   `uvm_error("compare_write_transaction","[COMPARE] Write transaction MISMATCH");
   end
   return result;
endfunction

function bit axi_cdma_axi_base_seq_item :: comp_read_txn (axi_cdma_axi_base_seq_item obj1, obj2); // compare add and data phase for a read transaction
   bit result;
   if (comp_read_add(obj1,obj2) && comp_read_data(obj1,obj2) ) result = 1 ;
   else begin
   result = 0 ;
   `uvm_error("compare_read_transaction","[COMPARE] Read transaction MISMATCH");
   end
   return result;
endfunction

//print methods -- phase wise

function void axi_cdma_axi_base_seq_item :: print_write_data (axi_cdma_axi_base_seq_item obj); // print write response channel
   string str ,data_str,strobe_str;
   //str = $sformatf("\n Write_Data_phase_print \n wdata = %p , wstrobe =%p ",obj.wdata,obj.wstrobe);
   foreach(obj.wdata[i])begin
   data_str =$sformatf("%s \n %h",data_str,obj.wdata[i]);
   strobe_str =$sformatf("%s  %h,",strobe_str,obj.wstrobe[i]);
   end
   str = $sformatf("Write_Data_phase_print \n data  ->  %s \n strobe -> %s",data_str,strobe_str);
  `uvm_info("print_write_data",str,UVM_MEDIUM);
endfunction

function void axi_cdma_axi_base_seq_item :: print_write_addr (axi_cdma_axi_base_seq_item obj); // print write response channel
   string str;
   str = $sformatf("\n Write_Address_phase_print \n awid = %d ,awaddr = %h, awlen =%d, awsize =%d, awburst= %d ",obj.awid,obj.awaddr,obj.awlen,obj.awsize,obj.awburst);
  `uvm_info("print_write_addr",str,UVM_MEDIUM);
endfunction

function void axi_cdma_axi_base_seq_item :: print_write_resp (axi_cdma_axi_base_seq_item obj); // print write response channel
   string str;
   str = $sformatf("\n Write_response_phase_print \n bid = %d ,bresp = %p",obj.bid,obj.bresp);
  `uvm_info("print_write_resp",str,UVM_MEDIUM);
endfunction

function void axi_cdma_axi_base_seq_item :: print_read_data (axi_cdma_axi_base_seq_item obj); // print read data channel
   string str ,data_str;
   foreach(obj.rdata[i])
   data_str =$sformatf("%s \n %0d",data_str,obj.rdata[i]);
   str = $sformatf("Read_Data_phase_print \n rid -> %d \n data  ->  %s \n rresp -> %p",rid,data_str,obj.rresp);
  `uvm_info("print_read_data",str,UVM_MEDIUM);

endfunction

function void axi_cdma_axi_base_seq_item :: print_read_addr (axi_cdma_axi_base_seq_item obj); // print read address channel
   string str;
   str = $sformatf("\n Read_Address_phase_print \n arid = %d ,araddr = %h, arlen =%d, arsize =%d, arburst= %d ",obj.arid,obj.araddr,obj.arlen,obj.arsize,obj.arburst);
  `uvm_info("print_read_addr",str,UVM_MEDIUM);
endfunction

function void axi_cdma_axi_base_seq_item :: print_read_txn (axi_cdma_axi_base_seq_item obj);// print read arrdess and data phases
   `uvm_info("print_read_txn","Printing Read Transaction",UVM_MEDIUM);
   // call phase prints
   print_read_addr(obj);
   print_read_data(obj);
endfunction

function void axi_cdma_axi_base_seq_item :: print_write_txn (axi_cdma_axi_base_seq_item obj);// print write arrdess data and response phases
   `uvm_info("print_write_txn","Printing Write Transaction",UVM_MEDIUM);
   // call phase prints
   print_write_addr(obj);
   print_write_data(obj);
   print_write_resp(obj);
endfunction

//AXI Protocol checks
function void axi_cdma_axi_base_seq_item ::axi_protocol_check(axi_cdma_axi_base_seq_item pkt);
    if(pkt.operation==WRITE) begin
      assert(pkt.awid==pkt.bid) else `uvm_error("Axi_base :: AXI_Protocol_Check","awid != bid");
      assert((pkt.awlen +1) == pkt.wdata.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of beats != pkt.awlen");
      assert((pkt.awlen +1) == pkt.wstrobe.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of strobes != pkt.awlen");
      assert(pkt.awaddr>=32'h44A0_0000 && pkt.awaddr<=32'h44A3_ffff) else `uvm_error("Axi_base :: AXI_Protocol_Check","Write_Address_out_of_range"); //valid range that a master can address
      foreach(pkt.wstrobe[i])
      assert((2**pkt.awsize)>=$countones(pkt.wstrobe[i])) else `uvm_error("Axi_base :: AXI_Protocol_Check","Invalid_strobe. Strobe high for more bytes than required");
      assert(pkt.bresp ==OKAY) else `uvm_error("Axi_base :: AXI_Protocol_Check","Bresponse not OKAY");
    end else begin
      assert(pkt.arid==pkt.rid) else `uvm_error("Axi_base :: AXI_Protocol_Check","arid != rid");
      assert((pkt.arlen +1) == pkt.rdata.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of beats != pkt.arlen");
      assert((pkt.arlen +1) == pkt.rresp.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of read_responses != pkt.arlen");
      assert(pkt.araddr>=32'h44A0_0000 && pkt.araddr<=32'h44A3_ffff) else `uvm_error("Axi_base :: AXI_Protocol_Check","Read_Address_out_of_range");
      //assert(pkt.araddr %(2**pkt.arsize) ==0) else `uvm_error("Axi_base :: AXI_Protocol_Check","Unaligned Read_address is not allowed");//read address must be aligned
      foreach(pkt.rresp[i])
      assert(pkt.rresp[i]==OKAY) else `uvm_error("Axi_base :: AXI_Protocol_Check","Read_response not OKAY");
    end
endfunction
