/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/slave_sequence.sv                       */
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
class axi_cdma_axi_base_slave_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (axi_cdma_axi_base_slave_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;

  function new (string name = "axi_cdma_axi_base_slave_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("slave_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);

    if(resp_pkt.operation== WRITE) begin
    pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
	  awlock == resp_pkt.awlock;
	  awprot == resp_pkt.awprot;
	  awqos == resp_pkt.awqos;
	  awregion == resp_pkt.awregion;
	  awcache == resp_pkt.awcache;
	  awlen == resp_pkt.awlen;
	  awsize == resp_pkt.awsize;
	  awburst == resp_pkt.awburst;
	  bid == awid;
	  bresp == OKAY;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    finish_item(pkt);
    get_response(pkt);
    end

    if(resp_pkt.operation==READ)begin
    pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlock==resp_pkt.arlock;
	  arprot ==resp_pkt.arprot;
	  arqos ==resp_pkt.arqos ;
	  arregion==resp_pkt.arregion;
	  arcache==resp_pkt.arcache;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
          foreach (rresp[i])
            rresp[i] == OKAY;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    //foreach (pkt.rresp[i])
    //pkt.rresp[i] dist {DECERR:=3,SLVERR:=1};
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass : axi_cdma_axi_base_slave_sequence

class dma_decode_error_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (dma_decode_error_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;

  function new (string name = "dma_decode_error_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("dma_decode_error_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("dma_decode_error_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("dma_decode_error_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);

    if(resp_pkt.operation== WRITE) begin
    pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
	  awlock == resp_pkt.awlock;
	  awprot == resp_pkt.awprot;
	  awqos == resp_pkt.awqos;
	  awregion == resp_pkt.awregion;
	  awcache == resp_pkt.awcache;
	  awlen == resp_pkt.awlen;
	  awsize == resp_pkt.awsize;
	  awburst == resp_pkt.awburst;
	  bid == awid;
	  bresp == DECERR;
	  })
    else  `uvm_error ("dma_decode_error_sequence::body" ,"Packet Randomization Fail")
    finish_item(pkt);
    get_response(pkt);
    end

    if(resp_pkt.operation==READ)begin
    pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlock==resp_pkt.arlock;
	  arprot ==resp_pkt.arprot;
	  arqos ==resp_pkt.arqos ;
	  arregion==resp_pkt.arregion;
	  arcache==resp_pkt.arcache;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
          foreach (rresp[i])
            rresp[i] == OKAY;
	  })
    else  `uvm_error ("dma_decode_error_sequence::body" ,"Packet Randomization Fail")
    //foreach (pkt.rresp[i])
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass : dma_decode_error_sequence

class dma_slave_error_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (dma_slave_error_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;

  function new (string name = "dma_slave_error_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("dma_slave_error_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("dma_slave_error_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("dma_slave_error_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);

    if(resp_pkt.operation== WRITE) begin
    pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
	  awlock == resp_pkt.awlock;
	  awprot == resp_pkt.awprot;
	  awqos == resp_pkt.awqos;
	  awregion == resp_pkt.awregion;
	  awcache == resp_pkt.awcache;
	  awlen == resp_pkt.awlen;
	  awsize == resp_pkt.awsize;
	  awburst == resp_pkt.awburst;
	  bid == awid;
	  bresp == SLVERR;
	  })
    else  `uvm_error ("dma_slave_error_sequence::body" ,"Packet Randomization Fail")
    finish_item(pkt);
    get_response(pkt);
    end

    if(resp_pkt.operation==READ)begin
    pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlock==resp_pkt.arlock;
	  arprot ==resp_pkt.arprot;
	  arqos ==resp_pkt.arqos ;
	  arregion==resp_pkt.arregion;
	  arcache==resp_pkt.arcache;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
          foreach (rresp[i])
            rresp[i] == OKAY;
	  })
    else  `uvm_error ("dma_slave_error_sequence::body" ,"Packet Randomization Fail")
    //foreach (pkt.rresp[i])
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass : dma_slave_error_sequence


class sg_base_slave_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (sg_base_slave_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;
   bit [63:0] temp_curr_desc_pntr;
   bit [63:0] next_desc_pntr;
   axi_cdma_config_obj obj;

  function new (string name = "sg_base_slave_sequence");
     super.new (name);
  endfunction


  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
     forever begin
      `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
       p_sequencer.resp_af.get(resp_pkt);
      `uvm_info("slave_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);
       if(!uvm_config_db #(axi_cdma_config_obj)::get(null,"","axi_cdma_config_obj",obj))
        `uvm_fatal("sg_slave_sequence::body","Get Config db FAILED")

       if(resp_pkt.operation== WRITE) begin
         pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
         start_item(pkt);
         assert (pkt.randomize() with {operation == WRITE;
                                       awid == resp_pkt.awid;
	                               awaddr == resp_pkt.awaddr;
	                               awlock == resp_pkt.awlock;
	                               awprot == resp_pkt.awprot;
	                               awqos == resp_pkt.awqos;
	                               awregion == resp_pkt.awregion;
	                               awcache == resp_pkt.awcache;
	                               awlen == resp_pkt.awlen;
	                               awsize == resp_pkt.awsize;
	                               awburst == resp_pkt.awburst;
	                               bid == awid;
	                               bresp == OKAY;
	                              })
         else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
         finish_item(pkt);
         get_response(pkt);
       end

       if(resp_pkt.operation==READ)begin
         pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
         start_item(pkt);
         temp_curr_desc_pntr = obj.tail_desc_pntr -64;
      `uvm_info("sg_slave_sequence :: body task",$sformatf("tail_desc_pntr=%0d,temp_curr_desc_pntr=%0d,araddr=%0d ",obj.tail_desc_pntr,temp_curr_desc_pntr,resp_pkt.araddr),UVM_DEBUG);
         if(resp_pkt.araddr== temp_curr_desc_pntr) begin
      `uvm_info("sg_slave_sequence :: body task",$sformatf("Before Randomization \n resp_pkt.araddr=%0d,temp_curr_desc_pntr=%0d ",resp_pkt.araddr,temp_curr_desc_pntr),UVM_DEBUG);
           assert (pkt.randomize() with {operation == READ;
                                         arid ==resp_pkt.arid;
	                                 araddr==resp_pkt.araddr;
	                                 arlock==resp_pkt.arlock;
	                                 arprot ==resp_pkt.arprot;
	                                 arqos ==resp_pkt.arqos ;
	                                 arregion==resp_pkt.arregion;
	                                 arcache==resp_pkt.arcache;
	                                 arlen ==resp_pkt.arlen;
	                                 arsize==resp_pkt.arsize;
	                                 arburst==resp_pkt.arburst;
	                                 rid==resp_pkt.arid;
                                         rdata.size == resp_pkt.arlen + 1;
                                         rdata[0] == obj.tail_desc_pntr[31:0];
                                         rdata[1] == obj.tail_desc_pntr[63:32];
                                         rdata[2] inside {[0:500]};
                                         rdata[3] inside {[500:700]};
                                         rdata[4] inside {[700:900]};
                                         rdata[5] inside {[900:1000]};
                                         rdata[6] inside {[4:1000]};
                                         rdata[7] == 32'h0;
	                                })
           else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
      `uvm_info("sg_slave_sequence :: body task",$sformatf("After Randomization araddr=%0d , arlen=%0d , rdata=%p",pkt.araddr,pkt.arlen,pkt.rdata),UVM_DEBUG);
         end else begin
           next_desc_pntr = resp_pkt.araddr +64;
           assert (pkt.randomize() with {operation == READ;
                                         arid ==resp_pkt.arid;
	                                 araddr==resp_pkt.araddr;
	                                 arlock==resp_pkt.arlock;
	                                 arprot ==resp_pkt.arprot;
	                                 arqos ==resp_pkt.arqos ;
	                                 arregion==resp_pkt.arregion;
	                                 arcache==resp_pkt.arcache;
	                                 arlen ==resp_pkt.arlen;
	                                 arsize==resp_pkt.arsize;
	                                 arburst==resp_pkt.arburst;
	                                 rid==resp_pkt.arid;
                                         rdata.size == resp_pkt.arlen + 1;
                                         rdata[0] == next_desc_pntr[31:0];
                                         rdata[1] == next_desc_pntr[63:32];
                                         rdata[2] inside {[0:500]};
                                         rdata[3] inside {[500:700]};
                                         rdata[4] inside {[700:900]};
                                         rdata[5] inside {[900:1000]};
                                         rdata[6] inside {[4:1000]};
                                         rdata[7] == 32'h0;
	                                })
           else  `uvm_error (get_full_name() ,"Packet Randomization Fail")           
         end
         foreach (pkt.rresp[i])
             pkt.rresp[i] = OKAY;
           finish_item(pkt);
           get_response(pkt);
       end
     end
  endtask : body

  endclass : sg_base_slave_sequence


class sg_desc_slave_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (sg_desc_slave_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;
   axi_cdma_descriptor_seq_item desc_seq_item;
   axi_cdma_config_obj obj;
   axi_cdma_descriptor_mem desc_mem;
   //uvm_analysis_port #(axi_cdma_descriptor_seq_item) sg_ap;
   static int no_of_randomize;

  function new (string name = "sg_desc_slave_sequence");
     super.new (name);
     desc_seq_item = axi_cdma_descriptor_seq_item :: type_id :: create("desc_seq_item");
     desc_mem = axi_cdma_descriptor_mem :: type_id :: create("desc_mem");
  endfunction

  virtual task body ();
      `uvm_info("sg_desc_slave_sequence :: body task","Triggred",UVM_LOW);
    forever begin
      `uvm_info("sg_desc_slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
      p_sequencer.resp_af.get(resp_pkt);
      `uvm_info("sg_desc_slave_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);
  
      if(!uvm_config_db #(axi_cdma_config_obj)::get(null,"","axi_cdma_config_obj",obj))
          `uvm_fatal("sg_slave_sequence::body","Get Config db FAILED")

 
         if(resp_pkt.operation== WRITE) begin
           pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
           start_item(pkt);
           assert (pkt.randomize() with {operation == WRITE;
                                         awid == resp_pkt.awid;
  	                               awaddr == resp_pkt.awaddr;
  	                               awlock == resp_pkt.awlock;
  	                               awprot == resp_pkt.awprot;
  	                               awqos == resp_pkt.awqos;
  	                               awregion == resp_pkt.awregion;
  	                               awcache == resp_pkt.awcache;
  	                               awlen == resp_pkt.awlen;
  	                               awsize == resp_pkt.awsize;
  	                               awburst == resp_pkt.awburst;
  	                               bid == awid;
  	                               bresp == OKAY;
  	                              })
           else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
           finish_item(pkt);
           get_response(pkt);
         end
         
          if(resp_pkt.operation==READ)begin
            pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
            
            //desc_seq_item.obj = obj;
            start_item(pkt);
            descriptor_generation(desc_seq_item,obj,resp_pkt);
            assert (pkt.randomize() with {operation == READ;
                                          arid ==resp_pkt.arid;
                                          araddr==resp_pkt.araddr;
                                          arlock==resp_pkt.arlock;
                                          arprot ==resp_pkt.arprot;
                                          arqos ==resp_pkt.arqos ;
                                          arregion==resp_pkt.arregion;
                                          arcache==resp_pkt.arcache;
                                          arlen ==resp_pkt.arlen;
                                          arsize==resp_pkt.arsize;
                                          arburst==resp_pkt.arburst;
                                          rid==resp_pkt.arid;
                                          rdata.size == resp_pkt.arlen + 1;
                                          rdata[0] == desc_seq_item.next_desc_pntr[31:0];
                                          rdata[1] == desc_seq_item.next_desc_pntr[63:32];
                                          rdata[2] == desc_seq_item.source_addr[31:0];
                                          rdata[3] == desc_seq_item.source_addr[63:32];
                                          rdata[4] == desc_seq_item.dest_addr[31:0];
                                          rdata[5] == desc_seq_item.dest_addr[63:32];
                                          rdata[6] == desc_seq_item.control_word;
                                          rdata[7] == desc_seq_item.status_word;
                                         })
            else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  
            foreach (pkt.rresp[i])
              pkt.rresp[i] = OKAY;
            finish_item(pkt);
            get_response(pkt);
          end
    end
  endtask : body

  function void descriptor_generation(axi_cdma_descriptor_seq_item desc_seq_item,axi_cdma_config_obj obj,axi_cdma_axi_slave_seq_item resp_pkt);
     
     assert(desc_seq_item.randomize() with {control_word ==2;})
     no_of_randomize++;
    `uvm_info("sg_desc_slave_sequence :: body task",$sformatf("After randomization no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     
   
     if(no_of_randomize == (obj.no_of_descriptor-1)) begin
       desc_seq_item.next_desc_pntr = obj.tail_desc_pntr;
      `uvm_info("sg_desc_slave_sequence :: body task",$sformatf("Fixing Tail pointer no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     end

     desc_mem.write_descriptor(desc_seq_item,resp_pkt);

     uvm_config_db #(axi_cdma_descriptor_mem) :: set(null,"*","axi_cdma_descriptor_mem",desc_mem);


     //sg_ap.write(desc_seq_item);
    // obj.mem[resp_pkt.araddr] = desc_seq_item;
     
  endfunction : descriptor_generation

  endclass : sg_desc_slave_sequence


class sg_decode_error_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (sg_decode_error_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;
   axi_cdma_descriptor_seq_item desc_seq_item;
   axi_cdma_config_obj obj;
   axi_cdma_descriptor_mem desc_mem;
   //uvm_analysis_port #(axi_cdma_descriptor_seq_item) sg_ap;
   static int no_of_randomize;

  function new (string name = "sg_decode_error_sequence");
     super.new (name);
     desc_seq_item = axi_cdma_descriptor_seq_item :: type_id :: create("desc_seq_item");
     desc_mem = axi_cdma_descriptor_mem :: type_id :: create("desc_mem");
  endfunction

  virtual task body ();
      `uvm_info("sg_decode_error_sequence :: body task","Triggred",UVM_LOW);
    forever begin
      `uvm_info("sg_decode_error_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
      p_sequencer.resp_af.get(resp_pkt);
      `uvm_info("sg_decode_error_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);
  
      if(!uvm_config_db #(axi_cdma_config_obj)::get(null,"","axi_cdma_config_obj",obj))
          `uvm_fatal("sg_slave_sequence::body","Get Config db FAILED")

 
         if(resp_pkt.operation== WRITE) begin
           pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
           start_item(pkt);
           assert (pkt.randomize() with {operation == WRITE;
                                         awid == resp_pkt.awid;
  	                               awaddr == resp_pkt.awaddr;
  	                               awlock == resp_pkt.awlock;
  	                               awprot == resp_pkt.awprot;
  	                               awqos == resp_pkt.awqos;
  	                               awregion == resp_pkt.awregion;
  	                               awcache == resp_pkt.awcache;
  	                               awlen == resp_pkt.awlen;
  	                               awsize == resp_pkt.awsize;
  	                               awburst == resp_pkt.awburst;
  	                               bid == awid;
  	                               bresp == DECERR;
  	                              })
           else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
           finish_item(pkt);
           get_response(pkt);
         end
         
          if(resp_pkt.operation==READ)begin
            pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
            
            //desc_seq_item.obj = obj;
            start_item(pkt);
            descriptor_generation(desc_seq_item,obj,resp_pkt);
            assert (pkt.randomize() with {operation == READ;
                                          arid ==resp_pkt.arid;
                                          araddr==resp_pkt.araddr;
                                          arlock==resp_pkt.arlock;
                                          arprot ==resp_pkt.arprot;
                                          arqos ==resp_pkt.arqos ;
                                          arregion==resp_pkt.arregion;
                                          arcache==resp_pkt.arcache;
                                          arlen ==resp_pkt.arlen;
                                          arsize==resp_pkt.arsize;
                                          arburst==resp_pkt.arburst;
                                          rid==resp_pkt.arid;
                                          rdata.size == resp_pkt.arlen + 1;
                                          rdata[0] == desc_seq_item.next_desc_pntr[31:0];
                                          rdata[1] == desc_seq_item.next_desc_pntr[63:32];
                                          rdata[2] == desc_seq_item.source_addr[31:0];
                                          rdata[3] == desc_seq_item.source_addr[63:32];
                                          rdata[4] == desc_seq_item.dest_addr[31:0];
                                          rdata[5] == desc_seq_item.dest_addr[63:32];
                                          rdata[6] == desc_seq_item.control_word;
                                          rdata[7] == 32'h0;
                                          foreach (pkt.rresp[i])
                                            rresp[i] == OKAY;
                                         })
            else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  
              //pkt.rresp[2] = DECERR;
            finish_item(pkt);
            get_response(pkt);
          end
    end
  endtask : body

  function void descriptor_generation(axi_cdma_descriptor_seq_item desc_seq_item,axi_cdma_config_obj obj,axi_cdma_axi_slave_seq_item resp_pkt);
     
     assert(desc_seq_item.randomize() with {control_word inside {[5000:10000]};})
     no_of_randomize++;
    `uvm_info("sg_decode_error_sequence :: descriptor_generation",$sformatf("After randomization no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     
   
     if(no_of_randomize == (obj.no_of_descriptor-1)) begin
       desc_seq_item.next_desc_pntr = obj.tail_desc_pntr;
      `uvm_info("sg_decode_error_sequence :: descriptor_generation",$sformatf("Fixing Tail pointer no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     end

     desc_mem.write_descriptor(desc_seq_item,resp_pkt);

     uvm_config_db #(axi_cdma_descriptor_mem) :: set(null,"*","axi_cdma_descriptor_mem",desc_mem);


     //sg_ap.write(desc_seq_item);
    // obj.mem[resp_pkt.araddr] = desc_seq_item;
     
  endfunction : descriptor_generation

  endclass : sg_decode_error_sequence

class sg_slave_error_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (sg_slave_error_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;
   axi_cdma_descriptor_seq_item desc_seq_item;
   axi_cdma_config_obj obj;
   axi_cdma_descriptor_mem desc_mem;
   //uvm_analysis_port #(axi_cdma_descriptor_seq_item) sg_ap;
   static int no_of_randomize;

  function new (string name = "sg_slave_error_sequence");
     super.new (name);
     desc_seq_item = axi_cdma_descriptor_seq_item :: type_id :: create("desc_seq_item");
     desc_mem = axi_cdma_descriptor_mem :: type_id :: create("desc_mem");
  endfunction

  virtual task body ();
      `uvm_info("sg_slave_error_sequence :: body task","Triggred",UVM_LOW);
    forever begin
      `uvm_info("sg_slave_error_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
      p_sequencer.resp_af.get(resp_pkt);
      `uvm_info("sg_slave_error_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);
  
      if(!uvm_config_db #(axi_cdma_config_obj)::get(null,"","axi_cdma_config_obj",obj))
          `uvm_fatal("sg_slave_sequence::body","Get Config db FAILED")

 
         if(resp_pkt.operation== WRITE) begin
           pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
           start_item(pkt);
           assert (pkt.randomize() with {operation == WRITE;
                                         awid == resp_pkt.awid;
  	                               awaddr == resp_pkt.awaddr;
  	                               awlock == resp_pkt.awlock;
  	                               awprot == resp_pkt.awprot;
  	                               awqos == resp_pkt.awqos;
  	                               awregion == resp_pkt.awregion;
  	                               awcache == resp_pkt.awcache;
  	                               awlen == resp_pkt.awlen;
  	                               awsize == resp_pkt.awsize;
  	                               awburst == resp_pkt.awburst;
  	                               bid == awid;
  	                               bresp == SLVERR;
  	                              })
           else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
           finish_item(pkt);
           get_response(pkt);
         end
         
          if(resp_pkt.operation==READ)begin
            pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
            
            //desc_seq_item.obj = obj;
            start_item(pkt);
            descriptor_generation(desc_seq_item,obj,resp_pkt);
            assert (pkt.randomize() with {operation == READ;
                                          arid ==resp_pkt.arid;
                                          araddr==resp_pkt.araddr;
                                          arlock==resp_pkt.arlock;
                                          arprot ==resp_pkt.arprot;
                                          arqos ==resp_pkt.arqos ;
                                          arregion==resp_pkt.arregion;
                                          arcache==resp_pkt.arcache;
                                          arlen ==resp_pkt.arlen;
                                          arsize==resp_pkt.arsize;
                                          arburst==resp_pkt.arburst;
                                          rid==resp_pkt.arid;
                                          rdata.size == resp_pkt.arlen + 1;
                                          rdata[0] == desc_seq_item.next_desc_pntr[31:0];
                                          rdata[1] == desc_seq_item.next_desc_pntr[63:32];
                                          rdata[2] == desc_seq_item.source_addr[31:0];
                                          rdata[3] == desc_seq_item.source_addr[63:32];
                                          rdata[4] == desc_seq_item.dest_addr[31:0];
                                          rdata[5] == desc_seq_item.dest_addr[63:32];
                                          rdata[6] == desc_seq_item.control_word;
                                          rdata[7] == 32'h0;
                                          foreach (pkt.rresp[i])
                                            rresp[i] == OKAY;

                                         })
            else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  
              //pkt.rresp[6] = SLVERR;
            finish_item(pkt);
            get_response(pkt);
          end
    end
  endtask : body

  function void descriptor_generation(axi_cdma_descriptor_seq_item desc_seq_item,axi_cdma_config_obj obj,axi_cdma_axi_slave_seq_item resp_pkt);
     
     assert(desc_seq_item.randomize() with {control_word inside {[1000:2000]};})
     no_of_randomize++;
    `uvm_info("sg_slave_error_sequence :: descriptor_generation",$sformatf("After randomization no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     
   
     if(no_of_randomize == (obj.no_of_descriptor-1)) begin
       desc_seq_item.next_desc_pntr = obj.tail_desc_pntr;
      `uvm_info("sg_slave_error_sequence :: descriptor_generation",$sformatf("Fixing Tail pointer no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     end

     desc_mem.write_descriptor(desc_seq_item,resp_pkt);

     uvm_config_db #(axi_cdma_descriptor_mem) :: set(null,"*","axi_cdma_descriptor_mem",desc_mem);


     //sg_ap.write(desc_seq_item);
    // obj.mem[resp_pkt.araddr] = desc_seq_item;
     
  endfunction : descriptor_generation

  endclass : sg_slave_error_sequence

class sg_int_error_sequence extends uvm_sequence #(axi_cdma_axi_slave_seq_item);
  `uvm_object_utils (sg_int_error_sequence)
  `uvm_declare_p_sequencer(axi_cdma_axi_slave_sequencer)
   axi_cdma_axi_slave_seq_item pkt,resp_pkt;
   axi_cdma_descriptor_seq_item desc_seq_item;
   axi_cdma_config_obj obj;
   axi_cdma_descriptor_mem desc_mem;
   //uvm_analysis_port #(axi_cdma_descriptor_seq_item) sg_ap;
   static int no_of_randomize;

  function new (string name = "sg_int_error_sequence");
     super.new (name);
     desc_seq_item = axi_cdma_descriptor_seq_item :: type_id :: create("desc_seq_item");
     desc_mem = axi_cdma_descriptor_mem :: type_id :: create("desc_mem");
  endfunction

  virtual task body ();
      `uvm_info("sg_int_error_sequence :: body task","Triggred",UVM_LOW);
    forever begin
      `uvm_info("sg_int_error_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
      p_sequencer.resp_af.get(resp_pkt);
      `uvm_info("sg_int_error_sequence :: body task",$sformatf("got_resp_pkt=%p ",resp_pkt),UVM_DEBUG);
  
      if(!uvm_config_db #(axi_cdma_config_obj)::get(null,"","axi_cdma_config_obj",obj))
          `uvm_fatal("sg_slave_sequence::body","Get Config db FAILED")

 
         if(resp_pkt.operation== WRITE) begin
           pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
           start_item(pkt);
           assert (pkt.randomize() with {operation == WRITE;
                                         awid == resp_pkt.awid;
  	                               awaddr == resp_pkt.awaddr;
  	                               awlock == resp_pkt.awlock;
  	                               awprot == resp_pkt.awprot;
  	                               awqos == resp_pkt.awqos;
  	                               awregion == resp_pkt.awregion;
  	                               awcache == resp_pkt.awcache;
  	                               awlen == resp_pkt.awlen;
  	                               awsize == resp_pkt.awsize;
  	                               awburst == resp_pkt.awburst;
  	                               bid == awid;
  	                               bresp == OKAY;
  	                              })
           else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
           finish_item(pkt);
           get_response(pkt);
         end
         
          if(resp_pkt.operation==READ)begin
            pkt = axi_cdma_axi_slave_seq_item :: type_id :: create ("pkt");
            
            //desc_seq_item.obj = obj;
            start_item(pkt);
            descriptor_generation(desc_seq_item,obj,resp_pkt);
            assert (pkt.randomize() with {operation == READ;
                                          arid ==resp_pkt.arid;
                                          araddr==resp_pkt.araddr;
                                          arlock==resp_pkt.arlock;
                                          arprot ==resp_pkt.arprot;
                                          arqos ==resp_pkt.arqos ;
                                          arregion==resp_pkt.arregion;
                                          arcache==resp_pkt.arcache;
                                          arlen ==resp_pkt.arlen;
                                          arsize==resp_pkt.arsize;
                                          arburst==resp_pkt.arburst;
                                          rid==resp_pkt.arid;
                                          rdata.size == resp_pkt.arlen + 1;
                                          rdata[0] == desc_seq_item.next_desc_pntr[31:0];
                                          rdata[1] == desc_seq_item.next_desc_pntr[63:32];
                                          rdata[2] == desc_seq_item.source_addr[31:0];
                                          rdata[3] == desc_seq_item.source_addr[63:32];
                                          rdata[4] == desc_seq_item.dest_addr[31:0];
                                          rdata[5] == desc_seq_item.dest_addr[63:32];
                                          rdata[6] == desc_seq_item.control_word;
                                          rdata[7] == desc_seq_item.status_word;
                                          foreach (pkt.rresp[i])
                                            rresp[i] == OKAY;

                                         })
            else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
  
              pkt.rresp[1] = OKAY;
            finish_item(pkt);
            get_response(pkt);
          end
    end
  endtask : body

  function void descriptor_generation(axi_cdma_descriptor_seq_item desc_seq_item,axi_cdma_config_obj obj,axi_cdma_axi_slave_seq_item resp_pkt);
     
     assert(desc_seq_item.randomize() with {status_word[31]==1;control_word == 0;})
     no_of_randomize++;
    `uvm_info("sg_int_error_sequence :: descriptor_generation",$sformatf("After randomization no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     
   
     if(no_of_randomize == (obj.no_of_descriptor-1)) begin
       desc_seq_item.next_desc_pntr = obj.tail_desc_pntr;
      `uvm_info("sg_int_error_sequence :: descriptor_generation",$sformatf("Fixing Tail pointer no_of_randomize=%0d desc_seq_item=%p ",no_of_randomize,desc_seq_item),UVM_DEBUG);
     end

     desc_mem.write_descriptor(desc_seq_item,resp_pkt);

     uvm_config_db #(axi_cdma_descriptor_mem) :: set(null,"*","axi_cdma_descriptor_mem",desc_mem);


     //sg_ap.write(desc_seq_item);
    // obj.mem[resp_pkt.araddr] = desc_seq_item;
     
  endfunction : descriptor_generation

  endclass : sg_int_error_sequence

  
