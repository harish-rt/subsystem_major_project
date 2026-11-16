class axi_base_sequence_item extends uvm_sequence_item;
  //FACTORY REGISTRATION

  //MEMEBERS
  string str ; /// just for testing wrapper
   //Write address channel
   rand   logic  [ID_WIDTH-1:0]     AWID;
   rand   logic  [ADDR_WIDTH-1:0]   AWADDR;
   rand   logic  [BURST_LENGTH-1:0] AWLEN;
   rand   burst_type_t              AWBURST;
   rand   logic  [BURST_SIZE-1:0]   AWSIZE;
          logic                     AWVALID;
          logic                     AWREADY;
   rand   logic                     AWLOCK;
   rand   logic  [PROT_WIDTH-1:0]   AWPROT;
   rand   logic  [QOS_WIDTH-1:0]    AWQOS;
   rand   logic  [REGION_WIDTH-1:0] AWREGION;
   rand   logic  [CACHE_WIDTH-1:0]    AWCACHE;
   //write response channel
   rand   logic  [ID_WIDTH-1:0]     BID;
          response_t                BRESP;
          logic                     BVALID;
          logic                     BREADY;
   //write data channel
   rand   logic  [DATA_WIDTH-1:0]   WDATA[];
   rand   logic  [STROBE_WIDTH-1:0] WSTRB[];
          logic                     WLAST;
          logic                     WVALID;
          logic                     WREADY;
   // read address channel
   rand   logic  [ID_WIDTH-1:0]     ARID;
   rand   logic  [ADDR_WIDTH-1:0]   ARADDR;
   rand   logic  [BURST_LENGTH-1:0] ARLEN;
   rand   burst_type_t              ARBURST;
   rand   logic  [BURST_SIZE-1:0]   ARSIZE;
          logic                     ARVALID;
          logic                     ARREADY;
   rand   logic                     ARLOCK;
   rand   logic  [PROT_WIDTH-1:0]   ARPROT;
   rand   logic  [QOS_WIDTH-1:0]    ARQOS;
   rand   logic  [REGION_WIDTH-1:0] ARREGION;
   rand   logic  [CACHE_WIDTH-1:0]  ARCACHE;
   // read data channel
   rand   logic  [ID_WIDTH-1:0]     RID;
   rand   response_t                RRESP[];
   rand   logic  [DATA_WIDTH-1:0]   RDATA[];
          logic                     RLAST;
          logic                     RVALID;
          logic                     RREADY;
          master_e                  master_p = MST_UNKNOWN;

   //Delays
   rand delay_t cmd2cmd_dly , add2data_dly;
   rand command_t                   operation;

   //Timestamps to store meaningfull events (capture whenever ready and valid are high )
   realtime radd_hndshk, rdata_hndshk[], wadd_hndshk, wdata_hndshk[], wresp_hndshk;  // to capture timing when handshakes happen
   reset_info_t reset_op = NO_RESET; //monitor signals reset info to sb using this enum //setting default value to be NO_RESET
   realtime reset_asserted, reset_deasserted;  //to hold reset timestamp info

   //`uvm_object_utils_begin(axi_base_sequence_item)
   // //field registration for write address channel signals
   //`uvm_field_enum(master_e, master_p, UVM_ALL_ON)
   //`uvm_field_int(AWID,UVM_ALL_ON)
   //`uvm_field_int(AWADDR,UVM_ALL_ON)
   //`uvm_field_int(AWLEN,UVM_ALL_ON)
   //`uvm_field_enum(command_t,operation,UVM_ALL_ON)
   //`uvm_field_enum(burst_type_t,AWBURST,UVM_ALL_ON)
   //`uvm_field_int(AWSIZE,UVM_ALL_ON)
   //`uvm_field_int(AWVALID,UVM_ALL_ON)
   //`uvm_field_int(AWREADY,UVM_ALL_ON)
   //`uvm_field_int(AWLOCK,UVM_ALL_ON)
   //`uvm_field_int(AWPROT,UVM_ALL_ON)
   //`uvm_field_int(AWQOS,UVM_ALL_ON)
   //`uvm_field_int(AWREGION,UVM_ALL_ON)
   //`uvm_field_int(AWCACHE,UVM_ALL_ON)
   // //field registration for write response channel signals
   //`uvm_field_int(BID,UVM_ALL_ON)
   //`uvm_field_enum(response_t,BRESP,UVM_ALL_ON)
   //`uvm_field_int(BVALID,UVM_ALL_ON)
   //`uvm_field_int(BREADY,UVM_ALL_ON)
   // //field registration for write data channel signals
   //`uvm_field_array_int(WDATA,UVM_ALL_ON)
   //`uvm_field_array_int(WSTRB,UVM_ALL_ON)
   //`uvm_field_int(WLAST,UVM_ALL_ON)
   //`uvm_field_int(WVALID,UVM_ALL_ON)
   //`uvm_field_int(WREADY,UVM_ALL_ON)
   // //field registration for read address channel signals
   //`uvm_field_int(ARID,UVM_ALL_ON)
   //`uvm_field_int(ARADDR,UVM_ALL_ON)
   //`uvm_field_int(ARLEN,UVM_ALL_ON)
   //`uvm_field_enum(burst_type_t,ARBURST,UVM_ALL_ON)
   //`uvm_field_int(ARSIZE,UVM_ALL_ON)
   //`uvm_field_int(ARVALID,UVM_ALL_ON)
   //`uvm_field_int(ARREADY,UVM_ALL_ON)
   //`uvm_field_int(ARLOCK,UVM_ALL_ON)
   //`uvm_field_int(ARPROT,UVM_ALL_ON)
   //`uvm_field_int(ARQOS,UVM_ALL_ON)
   //`uvm_field_int(ARREGION,UVM_ALL_ON)
   //`uvm_field_int(ARCACHE,UVM_ALL_ON)
   // //field registration for read data channel signals
   //`uvm_field_int(RID,UVM_ALL_ON)
   //`uvm_field_array_int(RDATA,UVM_ALL_ON)
   //`uvm_field_array_enum(response_t,RRESP,UVM_ALL_ON)
   //`uvm_field_int(RLAST,UVM_ALL_ON)
   //`uvm_field_int(WVALID,UVM_ALL_ON)
   //`uvm_field_int(WREADY,UVM_ALL_ON)
   //`uvm_object_utils_end
 

  function new (string name = "axi_base_sequence_item");
     super.new (name);
  endfunction

  extern function bit read_pkt_compare(axi_base_sequence_item obj1, obj2);
  extern function bit write_pkt_compare(axi_base_sequence_item obj1, obj2);
  extern function bit comp_read_add   (axi_base_sequence_item obj1, obj2);
  extern function bit comp_read_data  (axi_base_sequence_item obj1, obj2);
  extern function bit comp_write_add  (axi_base_sequence_item obj1, obj2);
  extern function bit comp_write_data (axi_base_sequence_item obj1, obj2);
  extern function bit comp_write_resp (axi_base_sequence_item obj1, obj2);
  extern function bit comp_write_txn  (axi_base_sequence_item obj1, obj2);
  extern function bit comp_read_txn   (axi_base_sequence_item obj1, obj2);
  extern function void print_read_txn      (axi_base_sequence_item obj);
  extern function void print_write_txn     (axi_base_sequence_item obj);
  extern function void print_write_resp    (axi_base_sequence_item obj);
  extern function void print_write_addr    (axi_base_sequence_item obj);
  extern function void print_write_data    (axi_base_sequence_item obj);
  extern function void print_read_addr     (axi_base_sequence_item obj);
  extern function void print_read_data     (axi_base_sequence_item obj);
  extern function void axi_protocol_check  (axi_base_sequence_item pkt);

  //CONSTRAINTS
  //write related
  //constraint wdata_hndshk_c {wdata_hndshk.size() == AWLEN+1;}
  //read related
  //constraint rdata_hndshk_c {rdata_hndshk.size() == ARLEN +1;}
  //delay related
  constraint cmd2cmd_dly_c {cmd2cmd_dly inside {[0:10]};}
  constraint add2data_dly_c{add2data_dly inside {[0:10]};}
endclass : axi_base_sequence_item

  //USER-DEFINED METHODS compare and print
function bit axi_base_sequence_item :: read_pkt_compare (axi_base_sequence_item obj1, obj2); // compare read address channel
   bit result =1;
   if (obj1.operation != obj2.operation)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] operation MISMATCH => %s != %s",obj1.operation.name,obj2.operation.name));
   result =0;
   end
   if ( obj1.ARADDR != obj2.ARADDR)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] ARADDR MISMATCH => %d != %d",obj1.ARADDR,obj2.ARADDR));
   result =0;
   end
   if (obj1.ARLEN != obj2.ARLEN)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] ARLEN MISMATCH => %d != %d",obj1.ARLEN,obj2.ARLEN));
   result =0;
   end
   if (obj1.ARBURST != obj2.ARBURST)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] ARBURST MISMATCH => %s != %s",obj1.ARBURST.name,obj2.ARBURST.name));
   result =0;
   end
   if (obj1.ARSIZE != obj2.ARSIZE)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARSIZE,obj2.ARSIZE));
   result =0;
   end
   if (obj1.ARPROT != obj2.ARPROT)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARPROT,obj2.ARPROT));
   result =0;
   end
   if (obj1.ARCACHE != obj2.ARCACHE)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARCACHE,obj2.ARCACHE));
   result =0;
   end
   if (obj1.RLAST != obj2.RLAST)begin
   `uvm_error("compare_read_pkt",$sformatf("[COMPARE] arlast MISMATCH => %d != %d",obj1.RLAST,obj2.RLAST));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction

function bit axi_base_sequence_item :: write_pkt_compare (axi_base_sequence_item obj1, obj2); // compare read address channel
   bit result =1;
   if (obj1.operation != obj2.operation)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] operation MISMATCH => %s != %s",obj1.operation.name,obj2.operation.name));
   result =0;
   end
   if ( obj1.AWADDR != obj2.AWADDR)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] AWADDR MISMATCH => %d != %d",obj1.AWADDR,obj2.AWADDR));
   result =0;
   end
   if (obj1.AWLEN != obj2.AWLEN)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] AWLEN MISMATCH => %d != %d",obj1.AWLEN,obj2.AWLEN));
   result =0;
   end
   if (obj1.AWBURST != obj2.AWBURST)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] AWBURST MISMATCH => %s != %s",obj1.AWBURST.name,obj2.AWBURST.name));
   result =0;
   end
   if (obj1.AWSIZE != obj2.AWSIZE)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWSIZE,obj2.AWSIZE));
   result =0;
   end
   if (obj1.AWPROT != obj2.AWPROT)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWPROT,obj2.AWPROT));
   result =0;
   end
   if (obj1.AWCACHE != obj2.AWCACHE)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWCACHE,obj2.AWCACHE));
   result =0;
   end
   if (obj1.WLAST != obj2.WLAST)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] awlast MISMATCH => %d != %d",obj1.WLAST,obj2.WLAST));
   result =0;
   end
   if (obj1.WSTRB != obj2.WSTRB)begin
   `uvm_error("compare_write_pkt",$sformatf("[COMPARE] WSTRB MISMATCH => %p != %p",obj1.WSTRB,obj2.WSTRB));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction


function bit axi_base_sequence_item :: comp_read_add (axi_base_sequence_item obj1, obj2); // compare read address channel
   bit result =1;
   if (obj1.ARID != obj2.ARID)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARID MISMATCH => %d != %d",obj1.ARID,obj2.ARID));
   result =0;
   end
   if ( obj1.ARADDR != obj2.ARADDR)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARADDR MISMATCH => %d != %d",obj1.ARADDR,obj2.ARADDR));
   result =0;
   end
   if (obj1.ARLEN != obj2.ARLEN)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARLEN MISMATCH => %d != %d",obj1.ARLEN,obj2.ARLEN));
   result =0;
   end
   if (obj1.ARBURST != obj2.ARBURST)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARBURST MISMATCH => %b != %b",obj1.ARBURST,obj2.ARBURST));
   result =0;
   end
   if (obj1.ARSIZE != obj2.ARSIZE)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARSIZE,obj2.ARSIZE));
   result =0;
   end
   if (obj1.ARPROT != obj2.ARPROT)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARPROT,obj2.ARPROT));
   result =0;
   end
   if (obj1.ARQOS != obj2.ARQOS)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARQOS,obj2.ARQOS));
   result =0;
   end
   if (obj1.ARREGION != obj2.ARREGION)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARREGION,obj2.ARREGION));
   result =0;
   end
   if (obj1.ARCACHE != obj2.ARCACHE)begin
   `uvm_error("compare_read_address_phase",$sformatf("[COMPARE] ARSIZE MISMATCH => %d != %d",obj1.ARCACHE,obj2.ARCACHE));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction

function bit axi_base_sequence_item :: comp_read_data (axi_base_sequence_item obj1, obj2); // compare read data channel
   bit result=1;
   if (obj1.RID != obj2.RID)begin
   `uvm_error("compare_read_data_phase",$sformatf("[COMPARE] RID MISMATCH => %d != %d",obj1.RID,obj2.RID));
   result =0;
   end
 foreach (obj1.RDATA[i]) if (obj1.RDATA[i] != obj2.RDATA[i])begin
   `uvm_error("compare_read_data_phase",$sformatf("[COMPARE] RDATA MISMATCH => %p != %p",obj1.RDATA,obj2.RDATA));
   result =0;
   break;
   end
 foreach (obj1.RRESP[i]) if ( obj1.RRESP[i] != obj2.RRESP[i])begin
   `uvm_error("compare_read_data_phase",$sformatf("[COMPARE] RRESP MISMATCH => %p != %p",obj1.RRESP,obj2.RRESP));
   result =0;
   break;
   end
   return result;
endfunction

function bit axi_base_sequence_item :: comp_write_add (axi_base_sequence_item obj1, obj2); // compare write address channel
   bit result=1;
   if (obj1.AWID != obj2.AWID)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWID MISMATCH => %d != %d",obj1.AWID,obj2.AWID));
   result =0;
   end
   if ( obj1.AWADDR != obj2.AWADDR)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWADDR MISMATCH => %d != %d",obj1.AWADDR,obj2.AWADDR));
   result =0;
   end
   if (obj1.AWLEN != obj2.AWLEN)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWLEN MISMATCH => %d != %d",obj1.AWLEN,obj2.AWLEN));
   result =0;
   end
   if (obj1.AWBURST != obj2.AWBURST)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWBURST MISMATCH => %b != %b",obj1.AWBURST,obj2.AWBURST));
   result =0;
   end
   if (obj1.AWSIZE != obj2.AWSIZE)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWSIZE,obj2.AWSIZE));
   result =0;
   end
   if (obj1.AWPROT != obj2.AWPROT)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWPROT,obj2.AWPROT));
   result =0;
   end
   if (obj1.AWQOS != obj2.AWQOS)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWQOS,obj2.AWQOS));
   result =0;
   end
   if (obj1.AWREGION != obj2.AWREGION)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWREGION,obj2.AWREGION));
   result =0;
   end
   if (obj1.AWCACHE != obj2.AWCACHE)begin
   `uvm_error("compare_write_address_phase",$sformatf("[COMPARE] AWSIZE MISMATCH => %d != %d",obj1.AWCACHE,obj2.AWCACHE));
   result =0;
   end
   return result; //return 1 only if all matched
endfunction

function bit axi_base_sequence_item :: comp_write_data (axi_base_sequence_item obj1, obj2); // compare write data channel
   bit  result =1;
 foreach (obj1.WDATA[i]) if ( obj1.WDATA[i] != obj2.WDATA[i])begin
   `uvm_error("compare_write_data_phase",$sformatf("[COMPARE] WDATA MISMATCH => %p != %p",obj1.WDATA,obj2.WDATA));
   result =0;
   break;
   end
 foreach (obj1.WSTRB[i]) if ( obj1.WSTRB[i] != obj2.WSTRB[i])begin
   `uvm_error("compare_write_data_phase",$sformatf("[COMPARE] WSTRB MISMATCH => %p != %p",obj1.WSTRB,obj2.WSTRB));
   result =0;
   break;
   end
   return result;
endfunction

function bit axi_base_sequence_item :: comp_write_resp (axi_base_sequence_item obj1, obj2); // compare write response channel
   bit result =1;
   if (obj1.BID != obj2.BID)begin
   `uvm_error("compare_write_response_phase",$sformatf("[COMPARE] BID MISMATCH => %d != %d",obj1.BID,obj2.BID));
   result =0;
   end
    if (obj1.BRESP != obj2.BRESP)begin
   `uvm_error("compare_write_response_phase",$sformatf("[COMPARE] BRESP MISMATCH => %b != %b",obj1.BRESP,obj2.BRESP));
   result =0;
   end
   return result;
endfunction


function bit axi_base_sequence_item :: comp_write_txn (axi_base_sequence_item obj1, obj2); // compare add data and resp phase for a write transaction
   bit result;
   if (comp_write_add(obj1,obj2) && comp_write_data(obj1,obj2) && comp_write_resp(obj1,obj2)) result = 1 ;
   else begin
   result = 0 ;
   `uvm_error("compare_write_transaction","[COMPARE] Write transaction MISMATCH");
   end
   return result;
endfunction

function bit axi_base_sequence_item :: comp_read_txn (axi_base_sequence_item obj1, obj2); // compare add and data phase for a read transaction
   bit result;
   if (comp_read_add(obj1,obj2) && comp_read_data(obj1,obj2) ) result = 1 ;
   else begin
   result = 0 ;
   `uvm_error("compare_read_transaction","[COMPARE] Read transaction MISMATCH");
   end
   return result;
endfunction

//print methods -- phase wise

function void axi_base_sequence_item :: print_write_data (axi_base_sequence_item obj); // print write response channel
   string str ,data_str,strobe_str;
   //str = $sformatf("\n Write_Data_phase_print \n WDATA = %p , WSTRB =%p ",obj.WDATA,obj.WSTRB);
   foreach(obj.WDATA[i])begin
   data_str =$sformatf("%s \n %h",data_str,obj.WDATA[i]);
   strobe_str =$sformatf("%s  %h,",strobe_str,obj.WSTRB[i]);
   end
   str = $sformatf("Write_Data_phase_print \n data  ->  %s \n strobe -> %s",data_str,strobe_str);
  `uvm_info("print_write_data",str,UVM_MEDIUM);
endfunction

function void axi_base_sequence_item :: print_write_addr (axi_base_sequence_item obj); // print write response channel
   string str;
   str = $sformatf("\n Write_Address_phase_print \n AWID = %d ,AWADDR = %h, AWLEN =%d, AWSIZE =%d, AWBURST= %d ",obj.AWID,obj.AWADDR,obj.AWLEN,obj.AWSIZE,obj.AWBURST);
  `uvm_info("print_write_addr",str,UVM_MEDIUM);
endfunction

function void axi_base_sequence_item :: print_write_resp (axi_base_sequence_item obj); // print write response channel
   string str;
   str = $sformatf("\n Write_response_phase_print \n BID = %d ,BRESP = %p",obj.BID,obj.BRESP);
  `uvm_info("print_write_resp",str,UVM_MEDIUM);
endfunction

function void axi_base_sequence_item :: print_read_data (axi_base_sequence_item obj); // print read data channel
   string str ,data_str;
   foreach(obj.RDATA[i])
   data_str =$sformatf("%s \n %0d",data_str,obj.RDATA[i]);
   str = $sformatf("Read_Data_phase_print \n RID -> %d \n data  ->  %s \n RRESP -> %p",RID,data_str,obj.RRESP);
  `uvm_info("print_read_data",str,UVM_MEDIUM);

endfunction

function void axi_base_sequence_item :: print_read_addr (axi_base_sequence_item obj); // print read address channel
   string str;
   str = $sformatf("\n Read_Address_phase_print \n ARID = %d ,ARADDR = %h, ARLEN =%d, ARSIZE =%d, ARBURST= %d ",obj.ARID,obj.ARADDR,obj.ARLEN,obj.ARSIZE,obj.ARBURST);
  `uvm_info("print_read_addr",str,UVM_MEDIUM);
endfunction

function void axi_base_sequence_item :: print_read_txn (axi_base_sequence_item obj);// print read arrdess and data phases
   `uvm_info("print_read_txn","Printing Read Transaction",UVM_MEDIUM);
   // call phase prints
   print_read_addr(obj);
   print_read_data(obj);
endfunction

function void axi_base_sequence_item :: print_write_txn (axi_base_sequence_item obj);// print write arrdess data and response phases
   `uvm_info("print_write_txn","Printing Write Transaction",UVM_MEDIUM);
   // call phase prints
   print_write_addr(obj);
   print_write_data(obj);
   print_write_resp(obj);
endfunction

//AXI Protocol checks
function void axi_base_sequence_item ::axi_protocol_check(axi_base_sequence_item pkt);
    if(pkt.operation==WRITE) begin
      assert(pkt.AWID==pkt.BID) else `uvm_error("Axi_base :: AXI_Protocol_Check","AWID != BID");
      assert((pkt.AWLEN +1) == pkt.WDATA.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of beats != pkt.AWLEN");
      assert((pkt.AWLEN +1) == pkt.WSTRB.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of strobes != pkt.AWLEN");
      assert(pkt.AWADDR>=32'h44A0_0000 && pkt.AWADDR<=32'h44A3_ffff) else `uvm_error("Axi_base :: AXI_Protocol_Check","Write_Address_out_of_range"); //valid range that a master can address
      foreach(pkt.WSTRB[i])
      assert((2**pkt.AWSIZE)>=$countones(pkt.WSTRB[i])) else `uvm_error("Axi_base :: AXI_Protocol_Check","Invalid_strobe. Strobe high for more bytes than required");
      assert(pkt.BRESP ==OKAY) else `uvm_error("Axi_base :: AXI_Protocol_Check","Bresponse not OKAY");
    end else begin
      assert(pkt.ARID==pkt.RID) else `uvm_error("Axi_base :: AXI_Protocol_Check","ARID != RID");
      assert((pkt.ARLEN +1) == pkt.RDATA.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of beats != pkt.ARLEN");
      assert((pkt.ARLEN +1) == pkt.RRESP.size()) else `uvm_error("Axi_base :: AXI_Protocol_Check","number of read_responses != pkt.ARLEN");
      assert(pkt.ARADDR>=32'h44A0_0000 && pkt.ARADDR<=32'h44A3_ffff) else `uvm_error("Axi_base :: AXI_Protocol_Check","Read_Address_out_of_range");
      //assert(pkt.ARADDR %(2**pkt.ARSIZE) ==0) else `uvm_error("Axi_base :: AXI_Protocol_Check","Unaligned Read_address is not allowed");//read address must be aligned
      foreach(pkt.RRESP[i])
      assert(pkt.RRESP[i]==OKAY) else `uvm_error("Axi_base :: AXI_Protocol_Check","Read_response not OKAY");
    end
endfunction
