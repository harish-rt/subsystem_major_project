/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_seq_item.sv                      */
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
class master_seq_item extends axi_base_seq_item;
  //FACTORY REGISTRATION
   `uvm_object_utils_begin(master_seq_item)
      `uvm_field_int(awid,UVM_ALL_ON)
      `uvm_field_int(awaddr,UVM_ALL_ON)
      `uvm_field_int(awlen,UVM_ALL_ON)
      `uvm_field_int(awsize,UVM_ALL_ON)
      `uvm_field_enum(burst_type_t,awburst,UVM_ALL_ON)
      `uvm_field_int(awlock,UVM_ALL_ON)
      `uvm_field_int(awregion,UVM_ALL_ON)
      `uvm_field_int(awcache,UVM_ALL_ON)
      `uvm_field_int(awvalid,UVM_ALL_ON)
      `uvm_field_int(awready,UVM_ALL_ON)
//-------------write data channel----------//  
      `uvm_field_array_int(wdata,UVM_ALL_ON)
      `uvm_field_array_int(wstrobe,UVM_ALL_ON | UVM_BIN)
      `uvm_field_int(wlast,UVM_ALL_ON)
      `uvm_field_int(wvalid,UVM_ALL_ON)
      `uvm_field_int(wready,UVM_ALL_ON)
//----------write response channel---------//
      `uvm_field_int(bid,UVM_ALL_ON)
      `uvm_field_enum(response_t,bresp,UVM_ALL_ON)
      `uvm_field_int(bvalid,UVM_ALL_ON)
      `uvm_field_int(bready,UVM_ALL_ON)
//-----------read address channel----------//  
      `uvm_field_int(arid,UVM_ALL_ON)
      `uvm_field_int(araddr,UVM_ALL_ON)
      `uvm_field_int(arlen,UVM_ALL_ON)
      `uvm_field_int(arsize,UVM_ALL_ON)
      `uvm_field_enum(burst_type_t,arburst,UVM_ALL_ON)
      `uvm_field_int(arlock,UVM_ALL_ON)
      `uvm_field_int(arprot,UVM_ALL_ON)
      `uvm_field_int(arqos,UVM_ALL_ON)
      `uvm_field_int(arregion,UVM_ALL_ON)
      `uvm_field_int(arcache,UVM_ALL_ON)
      `uvm_field_int(arvalid,UVM_ALL_ON)
      `uvm_field_int(arready,UVM_ALL_ON)
     //-----------read data channel-------------//
      `uvm_field_array_int(rdata,UVM_ALL_ON)
      `uvm_field_array_enum(response_t,rresp,UVM_ALL_ON)
      `uvm_field_int(rlast,UVM_ALL_ON)
      `uvm_field_int(rid,UVM_ALL_ON)
      `uvm_field_int(rvalid,UVM_ALL_ON)
      `uvm_field_int(rready,UVM_ALL_ON)
      `uvm_field_enum(slave_type,slave,UVM_ALL_ON)
      `uvm_field_enum(master_type,master,UVM_ALL_ON)
      //----------------------------------------//
      
      //uvm_field_int(align_unaligned,UVM_ALL_ON)
      `uvm_field_enum(command_t,operation,UVM_ALL_ON)
      //uvm_field_enum(master_type,master,UVM_ALL_ON)
       //uvm_field_enum(order_type_e_t,order_type,UVM_ALL_ON)
      //uvm_field_enum(cmmd,cmd,UVM_ALL_ON)
      //uvm_field_enum(burst_type,UVM_ALL_ON)
          
   `uvm_object_utils_end

  //MEMEBERS
  //delays
   rand delay_t add_valid_dly; // delay between writing address channel info and asserting valid
   rand delay_t resp_ready_dly; // delay in asserting ready while write response handshake.
   rand delay_t read_ready2ready_dly[]; // serves as ready2ready for ready
   rand delay_t write_valid2valid_dly[];// valid2valid delay for write txn
   
   int rmndr;

  function new (string name = "master_seq_item");
     super.new (name);
  endfunction

  /***************** constraint for wdata ****************/

   constraint awid_c { awid == 0;}
   constraint awlen_c { awlen == 0;}
   constraint awsize_c { awsize == 0;}
   constraint awburst_c { awburst == 0;}

    constraint awlock_c  {awlock == 0;}
   //constraint awport_c  {awport == 0;}
   constraint awqos_c   {awqos == 0;}
   constraint awregion_c {awregion == 0;}
   constraint awcache_c  {awcache == 0;}
   constraint wlast_c { wlast ==0;}
   constraint c_wdata{solve awlen before wdata;
                       wdata.size==1;}

   //constraint for wstrobe
   /*constraint wstrobe_c { //foreach(wstrobe[i]) {wstrobe[i] == 4'b1111;}
	                         solve awlen before wstrobe;
                            wstrobe.size() == awlen+1;
                            solve awsize before wstrobe;
                            foreach(wstrobe[i])
                           // {$countones(wstrobe[i])<= 2**awsize;} 	// for unaligned address
                              wstrobe[i] == (2**(2**awsize))-1;
															} */// only if address is aligned


   constraint bid_c {bid == 0;}

   constraint arid_c { arid == 0;}
   constraint arlen_c { arlen == 0;}
   constraint arsize_c { arsize == 0;}
   constraint arburst_c { arburst == 0;}

   constraint arlock_c  {arlock == 0;}
   //constraint arport_c  {arport == 0;}
   constraint arqos_c   {arqos == 0;}
   constraint arregion_c {arregion == 0;}
   constraint arcache_c  {arcache == 0;}

//delay constraints
  constraint resp_ready_dly_c {soft resp_ready_dly inside {[2:10]};}
  constraint add_valid_dly_c{soft add_valid_dly inside {[2:10]};}
  constraint write_valid2valid_dly_c{solve awlen before write_valid2valid_dly;
                                    write_valid2valid_dly.size()==awlen+1;
                                    foreach(write_valid2valid_dly[i])
                                    {soft write_valid2valid_dly[i] inside {[2:20]};}
                                    }
  constraint read_ready2ready_dly_c{solve arlen before read_ready2ready_dly;
                                    read_ready2ready_dly.size()==arlen+1;
                                    foreach(read_ready2ready_dly[i])
                                    {read_ready2ready_dly[i] inside {[0:20]};}
                                    }

/*constraint c_wdata { solve awlen before wdata;
                       solve awsize before wdata;
                       wdata.size() == (awlen+1);
                       foreach(wdata[i]) {
                         if(master == 2'b11)
                          {
                           wdata[i] inside {['h0000_0000:'hffff_ffff]};
                           }
                         if(master == 2'b00)
                          {
                           wdata[i] inside {['h0000_0000_0000_0000:'hffff_ffff_ffff_ffff]};
                           }
                         if(master == 2'b01)
                          {
                           wdata[i] inside {['h0000_0000_0000_0000_0000_0000_0000_0000:'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff]};
                           }
                         if(master == 2'b10)
                          {
                           wdata[i] inside  {['h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 : 'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff]};
                          }
	                 }
                         }*/

   //constraint for awsize & arsize
  //constraint awsize_c{awsize inside {[0:5]};} //max 256 bit or 32 byte port
  /*constraint awsize_c{solve master before awsize;
                      master == m0 -> awsize inside {[0:3]};
                      master == m1 -> awsize inside {[0:4]};
                      master == m2 -> awsize inside {[0:5]};
                      master == m3 -> awsize inside {[0:2]};
                      }*/
  //constraint arsize_c{arsize inside {[0:5]};} //max 256 bit or 32 byte port
  /*constraint arsize_c{solve master before arsize;
		      master == m0 -> arsize inside {[0:3]};
		      master == m1 -> arsize inside {[0:4]};
                      master == m2 -> arsize inside {[0:5]};
                      master == m3 -> arsize inside {[0:2]};
                      }*/

  //constraint for rresp & rdata
  constraint rresp_c { rresp.size() == arlen +1;}
  constraint rdata_c { rdata.size() == arlen +1;}

  //constraint for arlen && awlen
  /*constraint arlen_c{solve arburst before arlen;
                             arburst==2'b00 -> {arlen inside{[0:15]};}	//FIXED
                             arburst==2'b01 -> {arlen inside {[0:255]};}	//INCR
                             arburst==2'b10 -> {arlen inside {1,3,7,15};} }	//WRAP
  constraint awlen_c{solve awburst before awlen;
                             awburst==2'b00 -> {awlen inside{[0:15]};}
                             awburst==2'b01 -> {awlen inside {[0:255]};}
                             awburst==2'b10 -> {awlen inside {1,3,7,15};} }*/
     //constraint for wstrobe
  /*constraint wstrobe_c {solve awlen before wstrobe;
                            wstrobe.size() == awlen+1;
                            solve awsize before wstrobe;
                            foreach(wstrobe[i])
                           // {$countones(wstrobe[i])<= 2**awsize;} 	// for unaligned address
                              wstrobe[i] == (2**(2**awsize))-1;} 	// only if address is aligned*/
                          
   /*constraint slave_araddr{ solve slave before araddr;
                        (slave==s0) -> soft araddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                        (slave==s1) -> soft araddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                        (slave==s2) -> soft araddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                        (slave==s3) -> soft araddr inside {[32'h44A3_0000:32'h44A3_1FFF]};
                        }*/



endclass : master_seq_item



///////////////////////////////////////////  Axi4_lite  ////////////////////////////////////////////////

class axi4_lite_seq_item extends master_seq_item;
   `uvm_object_utils(axi4_lite_seq_item)

   function new (string name = "axi4_lite_seq_item");
     super.new(name);
   endfunction :new

   constraint awid_c { awid == 0;}
   constraint awlen_c { awlen == 0;}
   constraint awsize_c { awsize == 0;}
   constraint awburst_c { awburst == 0;}

   constraint awlock_c  {awlock == 0;}
   //constraint awport_c  {awport == 0;}
   constraint awqos_c   {awqos == 0;}
   constraint awregion_c {awregion == 0;}
   constraint awcache_c  {awcache == 0;}

   //constraint wid_c { wid == 0;}
   constraint wlast_c { wlast == 0;}

   constraint bid_c {bid == 0;}

   constraint arid_c { arid == 0;}
   constraint arlen_c { arlen == 0;}
   constraint arsize_c { arsize == 0;}
   constraint arburst_c { arburst == 0;}

   constraint arlock_c  {arlock == 0;}
   //constraint arport_c  {arport == 0;}
   constraint arqos_c   {arqos == 0;}
   constraint arregion_c {arregion == 0;}
   constraint arcache_c  {arcache == 0;}


   constraint rid_c {rid == 0;}

endclass

///////////////////////////////////////////SMALL RANDOM SIZE & LENGTH/////////////////////////////////////

class burst_small_seq_item extends master_seq_item;

  `uvm_object_utils(burst_small_seq_item)

   function new (string name = "burst_small_seq_item");
     super.new(name);
   endfunction :new

  constraint arlen_c{solve arburst before arlen;
                             arburst==2'b00 -> {arlen inside{[0:15]};}	//FIXED
                             arburst==2'b01 -> {arlen inside {[0:15]};}	//INCR
                             arburst==2'b10 -> {arlen inside {1,3,7,15};} }	//WRAP

  constraint awlen_c{solve awburst before awlen;
                             awburst==2'b00 -> {awlen inside{[0:15]};}
                             awburst==2'b01 -> {awlen inside {[0:15]};}
                             awburst==2'b10 -> {awlen inside {1,3,7,15};} }

  //constraint for awsize & arsize
  //constraint awsize_c{awsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint awsize_c{solve master before awsize;
                      master == m0 -> awsize inside {[0:3]};
                      master == m1 -> awsize inside {[0:4]};
                      master == m2 -> awsize inside {[0:5]};
                      master == m3 -> awsize inside {[0:2]};
                      }
  //constraint arsize_c{arsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint arsize_c{solve master before arsize;
                      master == m0 -> arsize inside {[0:3]};
                      master == m1 -> arsize inside {[0:4]};
                      master == m2 -> arsize inside {[0:5]};
                      master == m3 -> arsize inside {[0:2]};
                      }
/*
 constraint araddr_boundary {solve arlen before arsize;
                              ((2**arsize)*(arlen+1))<=4096;
                              }*/

endclass : burst_small_seq_item


//////////////////////////////////////LARGE RANDOM SIZE & LENGTH///////////////////////////////////////////

class burst_large_seq_item extends master_seq_item;

  `uvm_object_utils(burst_large_seq_item)

   function new (string name = "burst_large_seq_item");
     super.new(name);
   endfunction :new


   constraint arlen_c{solve arburst before arlen;
                             arburst==2'b00 -> {arlen inside{[16:255]};}	//FIXED
                             arburst==2'b01 -> {arlen inside {[16:255]};}	//INCR
                             arburst==2'b10 -> {arlen inside {1,3,7,15};} }	//WRAP

   constraint awlen_c{solve awburst before awlen;
                             awburst==2'b00 -> {awlen inside{[16:255]};}
                             awburst==2'b01 -> {awlen inside {[16:255]};}
                             awburst==2'b10 -> {awlen inside {1,3,7,15};} }

  //constraint for awsize & arsize
  //constraint awsize_c{awsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint awsize_c{solve master before awsize;
                      master == m0 -> awsize inside {[0:3]};
                      master == m1 -> awsize inside {[0:4]};
                      master == m2 -> awsize inside {[0:5]};
                      master == m3 -> awsize inside {[0:2]};
                      }
  //constraint arsize_c{arsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint arsize_c{solve master before arsize;
                      master == m0 -> arsize inside {[0:3]};
                      master == m1 -> arsize inside {[0:4]};
                      master == m2 -> arsize inside {[0:5]};
                      master == m3 -> arsize inside {[0:2]};
                      }
/*
  constraint awaddr_boundary {solve awlen before awsize;
                              ((2**awsize)*(awlen+1))<=4096;
                             }

  constraint araddr_boundary {solve arlen before arsize;
                              ((2**arsize)*(arlen+1))<=4096;
                              }*/

endclass : burst_large_seq_item

//////////////////////////////////////////ALIGNED ADDRESS/////////////////////////////////
class aligned_address_seq_item extends master_seq_item;

 `uvm_object_utils(aligned_address_seq_item)

 function new (string name = "aligned_address_seq_item");
   super.new(name);
 endfunction :new

 constraint align_addr {awaddr%(2**awsize)==0;}

 constraint slave_align_addr {slave==s0 -> (awaddr%(2**awsize)==0);
                              slave==s1 -> (awaddr%(2**awsize)==0);
                              slave==s2 -> (awaddr%(2**awsize)==0);
                              slave==s3 -> (awaddr%(2**awsize)==0);
	}

endclass : aligned_address_seq_item

//////////////////////////////////////////UNALIGNED ADDRESS/////////////////////////////////
class unaligned_address_seq_item extends master_seq_item;

 `uvm_object_utils(unaligned_address_seq_item)

 function new (string name = "unaligned_address_seq_item");
   super.new(name);
 endfunction :new

 constraint unalign_addr {awaddr%(2**awsize)!=0;}

/* constraint slave_unalign_addr {slave==s0 -> (awaddr%(2**awsize)!=0);
                              slave==s1 -> (awaddr%(2**awsize)!=0);
                              slave==s2 -> (awaddr%(2**awsize)!=0);
                              slave==s3 -> (awaddr%(2**awsize)!=0);
	}
*/
endclass : unaligned_address_seq_item



//////////////////////////////////////RANDOM MASTER AND SLAVE AND LENGTH///////////////////////////////////////////

class random_mas_slv_len_seq_item extends master_seq_item;

  `uvm_object_utils(random_mas_slv_len_seq_item)

   function new (string name = "random_mas_slv_len_seq_item");
     super.new(name);
   endfunction :new


   constraint arlen_c{solve arburst before arlen;
                             arburst==2'b00 -> {arlen inside{[0:255]};}	//FIXED
                             arburst==2'b01 -> {arlen inside {[0:255]};}	//INCR
                             arburst==2'b10 -> {arlen inside {1,3,7,15};} }	//WRAP

   constraint awlen_c{solve awburst before awlen;
                             awburst==2'b00 -> {awlen inside{[0:255]};}
                             awburst==2'b01 -> {awlen inside {[0:255]};}
                             awburst==2'b10 -> {awlen inside {1,3,7,15};} }

  //constraint for awsize & arsize
  //constraint awsize_c{awsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint awsize_c{solve master before awsize;
                      master == m0 -> awsize inside {[0:3]};
                      master == m1 -> awsize inside {[0:4]};
                      master == m2 -> awsize inside {[0:5]};
                      master == m3 -> awsize inside {[0:2]};
                      }
  //constraint arsize_c{arsize inside {[0:5]};} //max 256 bit or 32 byte port
  constraint arsize_c{solve master before arsize;
                      master == m0 -> arsize inside {[0:3]};
                      master == m1 -> arsize inside {[0:4]};
                      master == m2 -> arsize inside {[0:5]};
                      master == m3 -> arsize inside {[0:2]};
                      }

  constraint awaddr_boundary {solve awlen before awsize;
                              ((2**awsize)*(awlen+1))<=4096;
                             }

  constraint araddr_boundary {solve arlen before arsize;
                              ((2**arsize)*(arlen+1))<=4096;
                              }

endclass : random_mas_slv_len_seq_item


///////////////////////////////////////////////////////////////RANDOM SEQ ITEM /////////////////////////////

class random_seq_item extends master_seq_item;

 `uvm_object_utils(random_seq_item)

 rand bit legal,aligned;
 rand bit[2:0] s_addr;
 typedef enum {s0,s1,s2,s3,s4}    slave_type;

 rand slave_type slave;

 function new (string name = "random_seq_item");
   super.new(name);
 endfunction
/*
constraint slave_awaddr{ solve slave before awaddr;
                           if      (slave==s0) soft awaddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                           else if (slave==s1) soft awaddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                           else if (slave==s2) soft awaddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                           else if (slave==s3) soft awaddr inside {[32'h44A3_0000:32'h44A3_1FFF]};
                           else if (slave==s4) soft awaddr inside {[32'h44B3_0000:32'h44B3_1FFF]};
                        }

constraint slave_awaddr{ solve slave before awaddr;
                           if      (slave==s0) soft !awaddr inside {[32'h44A0_0000:32'h44A0_FFFF],
                                                                   [32'h44A1_0000:32'h44A1_7FFF]};
                           else if (slave==s2) soft awaddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                           else if (slave==s3) soft awaddr inside {[32'h44A3_0000:32'h44A3_1FFF]};
                           else if (slave==s4) soft awaddr inside {[32'h44B3_0000:32'h44B3_1FFF]};
                        }
*/
/* constraint addr {
                 //if(legal==1) soft {slave==s0 || slave==s1 || slave==s2 || slave==s3 };
                 if(legal==1) soft awaddr inside {slave};

                  }
  constraint ad { if(slave==(s0 || s1 || s2 || s3)) soft legal==1 ;
                  else if (slave==s4) soft legal==0; }
*/
 /*constraint address {
                     if(legal)
                     {
                       slave==s0 -> awaddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                       slave==s1 -> awaddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                       slave==s2 -> awaddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                       slave==s3 -> awaddr inside {[32'h44A3_0000:32'h44A3_1FFF]};

                       if(aligned)
                         awaddr%(2**awsize)==0;
                       else
                         awaddr%(2**awsize)!=0;

                     } else {
                             slave==s0 -> !awaddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                             slave==s1 -> !awaddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                             slave==s2 -> !awaddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                             slave==s3 -> !awaddr inside {[32'h44A3_0000:32'h44A3_1FFF]};
                            }

                     }

// constraint align_addr {awaddr%(2**awsize)==0;}
/*
 constraint valid_addr { slave == addr_cal(s_addr);}

 function bit [1:0] addr_cal(bit [1:0] s_addr);
   if(legal==1) begin
     s_addr = 0 | 1 | 2 | 3;
   end else begin
     s_addr = 4;
   end
 endfunction :addr_cal*/
/*
 function void post_randomize();
   if(legal==1) begin
     slave = s0 | s1 |s2 | s3:
   end else
      legal==0;
 endfunction
*/
endclass :random_seq_item


////////////////////////////////////RANDOM MASTER AND SLAVE AND LENGTH SEQ_ITEM ////////////////////////////////////

class random_all_seq_item extends master_seq_item;

 `uvm_object_utils(random_all_seq_item)

 rand bit legal,aligned;
// typedef enum {s0,s1,s2,s3}    slave_type;

 //rand slave_type slave;

 function new (string name = "random_all_seq_item");
   super.new(name);
 endfunction

 constraint address_write {
                     if(legal)
                     {
                       slave==s0 -> awaddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                       slave==s1 -> awaddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                       slave==s2 -> awaddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                       slave==s3 -> awaddr inside {[32'h44A3_0000:32'h44A3_1FFF]};

                       if(aligned)
                         awaddr%(2**awsize)==0;
                       else
                         awaddr%(2**awsize)!=0;

                     } else {
                             !awaddr inside {[32'h44A0_0000:32'h44A0_FFFF],
                                             [32'h44A1_0000:32'h44A1_7FFF],
                                             [32'h44A2_0000:32'h44A2_3FFF],
                                             [32'h44A3_0000:32'h44A3_1FFF]};
                            }

                     }

 constraint address_read {
                         if(legal)
                         {
                          slave==s0 -> araddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                          slave==s1 -> araddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                          slave==s2 -> araddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                          slave==s3 -> araddr inside {[32'h44A3_0000:32'h44A3_1FFF]};

                         if(aligned)
                           araddr%(2**arsize)==0;
                         else
                           araddr%(2**arsize)!=0;

                         } else {
                             slave==s0 -> !araddr inside {[32'h44A0_0000:32'h44A0_FFFF]};
                             slave==s1 -> !araddr inside {[32'h44A1_0000:32'h44A1_7FFF]};
                             slave==s2 -> !araddr inside {[32'h44A2_0000:32'h44A2_3FFF]};
                             slave==s3 -> !araddr inside {[32'h44A3_0000:32'h44A3_1FFF]};
                            }

                     }


 constraint awsize_fixed{
                             if(awburst==2'b00)	//FIXED
                               {slave==s0 -> (2**awsize)%2==0;
                                slave==s1 -> (2**awsize)%3==0;
                                slave==s2 -> (2**awsize)%4==0;
                                slave==s3 -> (2**awsize)%5==0;
	  }
                          }
constraint awsize_wrap{
                             if(awburst==2'b10)	//WRAP
                              {slave==s0 -> (2**awsize)%2==0;
                                slave==s1 -> (2**awsize)%3==0;
                                slave==s2 -> (2**awsize)%4==0;
                                slave==s3 -> (2**awsize)%5==0;
	  }
                        }

endclass :random_all_seq_item

//`endif
