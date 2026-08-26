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
class base_slave_sequence extends uvm_sequence #(slave_seq_item);
  `uvm_object_utils (base_slave_sequence)
  `uvm_declare_p_sequencer(slave_sequencer)
   slave_seq_item pkt,resp_pkt;

  function new (string name = "base_slave_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("slave_sequence :: body task","got_resp_pkt",UVM_LOW);

    if(resp_pkt.operation== WRITE) begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
      awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
	  awlen == resp_pkt.awlen;
	  awsize == resp_pkt.awsize;
	  awburst == resp_pkt.awburst;
	  bid == awid;
	  bresp == OKAY;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    finish_item(pkt);
    `uvm_info("slave_sequence_resp_write_packet",pkt.sprint(),UVM_DEBUG)
    get_response(pkt);
    end

    if(resp_pkt.operation==READ)begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    foreach (pkt.rresp[i])
    pkt.rresp[i] = OKAY;
    finish_item(pkt);
    `uvm_info("slave_sequence_resp_read_packet",pkt.sprint(),UVM_LOW)
    get_response(pkt);
    end
  end
  endtask : body
  endclass : base_slave_sequence
////////////////////////////////salve error sequence///////////
  class slave_error_sequence extends base_slave_sequence; 
  `uvm_object_utils (slave_error_sequence)
  `uvm_declare_p_sequencer(slave_sequencer)
   slave_seq_item pkt,resp_pkt;

  function new (string name = "base_slave_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("slave_sequence :: body task","got_resp_pkt",UVM_LOW);

    if(resp_pkt.operation== WRITE) begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
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
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    foreach (pkt.rresp[i])
    pkt.rresp[i] =SLVERR;
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass :slave_error_sequence

  ////////////////////////////slave error sequence////////////////////
  class slave_err_sequence extends base_slave_sequence; 
  `uvm_object_utils (slave_err_sequence)
  `uvm_declare_p_sequencer(slave_sequencer)
   slave_seq_item pkt,resp_pkt;

  function new (string name = "base_slave_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("slave_sequence :: body task","got_resp_pkt",UVM_LOW);

    if(resp_pkt.operation== WRITE) begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
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
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    foreach (pkt.rresp[i])
    pkt.rresp[i] =OKAY;
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass :slave_err_sequence


  ////////////////////////////////decode error sequence////////////////////////
class decode_err_sequence extends uvm_sequence #(slave_seq_item);
  `uvm_object_utils (decode_err_sequence)
  `uvm_declare_p_sequencer(slave_sequencer)
   slave_seq_item pkt,resp_pkt;

  function new (string name = "base_slave_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("slave_sequence :: body task","got_resp_pkt",UVM_LOW);

    if(resp_pkt.operation== WRITE) begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
	  awlen == resp_pkt.awlen;
	  awsize == resp_pkt.awsize;
	  awburst == resp_pkt.awburst;
	  bid == awid;
	  bresp ==DECERR;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    finish_item(pkt);
    get_response(pkt);
    end

    if(resp_pkt.operation==READ)begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    foreach (pkt.rresp[i])
    pkt.rresp[i] = OKAY;
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass : decode_err_sequence

  ////////////////////decode error sequence ////////////
class decode_err_sequence_1 extends uvm_sequence #(slave_seq_item);
  `uvm_object_utils (decode_err_sequence_1)
  `uvm_declare_p_sequencer(slave_sequencer)
   slave_seq_item pkt,resp_pkt;

  function new (string name = "base_slave_sequence");
     super.new (name);
  endfunction

  virtual task body ();
    `uvm_info("slave_sequence :: body task","Triggred",UVM_LOW);
  forever begin
    `uvm_info("slave_sequence :: body task","Waiting_for_resp_pkt",UVM_LOW);
    p_sequencer.resp_af.get(resp_pkt);
    `uvm_info("slave_sequence :: body task","got_resp_pkt",UVM_LOW);

    if(resp_pkt.operation== WRITE) begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == WRITE;
                                awid == resp_pkt.awid;
	  awaddr == resp_pkt.awaddr;
	  awlen == resp_pkt.awlen;
	  awsize == resp_pkt.awsize;
	  awburst == resp_pkt.awburst;
	  bid == awid;
	  bresp ==OKAY;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    finish_item(pkt);
    get_response(pkt);
    end

    if(resp_pkt.operation==READ)begin
    pkt = slave_seq_item :: type_id :: create ("pkt");
    start_item(pkt);
    assert (pkt.randomize() with {operation == READ;
                                arid ==resp_pkt.arid;
	  araddr==resp_pkt.araddr;
	  arlen ==resp_pkt.arlen;
	  arsize==resp_pkt.arsize;
	  arburst==resp_pkt.arburst;
	  rid==resp_pkt.arid;
	  })
    else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
    foreach (pkt.rresp[i])
    pkt.rresp[i] = DECERR;
    finish_item(pkt);
    get_response(pkt);
    end
  end
  endtask : body
  endclass : decode_err_sequence_1

///////////////sg mode base slave sequence////////////
class sg_slave_sequence extends base_slave_sequence;
    `uvm_object_utils(sg_slave_sequence)
    `uvm_declare_p_sequencer(slave_sequencer)
    slave_seq_item resp_pkt,pkt,sg_pkt;
    slave_seq_item read_packets[$];
    axi_slave_mem_model mem_model;
    bit[63:0] addr;
    function new(string name="sg_slave_sequence");
        super.new(name);
        mem_model=axi_slave_mem_model::type_id::create("mem_model");
    endfunction

    virtual task body();
        if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
            `uvm_error("SLAVE_SEQ","failed to get memory handle")
        end
        `uvm_info("sg_slave_sequence::body_task","Triggred",UVM_LOW)
        forever begin
         `uvm_info("sg_slave_seqence::body_task","waiting for slave_packet",UVM_LOW)
          p_sequencer.resp_af.get(resp_pkt);
          `uvm_info("sg_slave_sequnce::body_task","got_resp_packet",UVM_LOW)
          `uvm_info("sg_slave_sequence::printing_response_packet",resp_pkt.sprint(),UVM_LOW)

        if(resp_pkt.operation==READ)begin
        `uvm_info("read_packet_inread_operation",resp_pkt.sprint(),UVM_LOW)
        `uvm_info("read_packet_size",$sformatf("%0d",read_packets.size()),UVM_LOW)
        addr=resp_pkt.araddr;
           pkt=slave_seq_item::type_id::create("pkt");
           start_item(pkt);
           assert(pkt.randomize() with {operation==READ;
                                arid ==resp_pkt.arid;
	                            araddr==resp_pkt.araddr;
	                            arlen ==resp_pkt.arlen;
	                            arsize==resp_pkt.arsize;
	                            arburst==resp_pkt.arburst;
	                            rid==resp_pkt.arid;
            })
            foreach(pkt.rdata[i])begin
                pkt.rdata[i]=mem_model.mem[addr];
                $display("-------rdata=%0h---------",pkt.rdata[i]);
                addr=addr+4;
                $display("------addr=%0h------",addr);
            end  
            foreach(pkt.rresp[i])
            pkt.rresp[i]=OKAY;
           finish_item(pkt);
           `uvm_info("slave_sequence::inside resp packet",pkt.sprint(),UVM_LOW)
           get_response(pkt);
        end
         if(resp_pkt.operation== WRITE) begin
       	`uvm_info("slave_sequence :: inside the write op task",$sformatf("resp_pkt=%p ",resp_pkt),UVM_LOW);
          pkt = slave_seq_item :: type_id :: create ("pkt");
          start_item(pkt);
          assert (pkt.randomize() with {operation == WRITE;
                                      awid == resp_pkt.awid;
	        awaddr == resp_pkt.awaddr;
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
    end
    endtask
endclass

///////////////////////////sg mode decode error sequence////////////////////
class sg_decode_err_slave_sequence extends base_slave_sequence;
    `uvm_object_utils(sg_decode_err_slave_sequence)

     `uvm_declare_p_sequencer(slave_sequencer)
    slave_seq_item resp_pkt,pkt,sg_pkt;
    slave_seq_item read_packets[$];
    axi_slave_mem_model mem_model;
    bit[63:0] addr;

    function new(string name="sg_decode_err_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
            `uvm_error("SLAVE_SEQ","failed to get memory handle")
        end
        `uvm_info("sg_slave_sequence::body_task","Triggred",UVM_LOW)
        forever begin
         `uvm_info("sg_slave_seqence::body_task","waiting for slave_packet",UVM_LOW)
          p_sequencer.resp_af.get(resp_pkt);
          `uvm_info("sg_slave_sequence::printing_response_packet",resp_pkt.sprint(),UVM_LOW)
        
        if(resp_pkt.operation==READ)begin
        `uvm_info("read_packet",resp_pkt.sprint(),UVM_LOW)
           addr=resp_pkt.araddr;
           pkt=slave_seq_item::type_id::create("pkt");
           start_item(pkt);
           assert(pkt.randomize() with {operation==READ;arid ==resp_pkt.arid;
	                            araddr==resp_pkt.araddr;
	                            arlen ==resp_pkt.arlen;
	                            arsize==resp_pkt.arsize;
	                            arburst==resp_pkt.arburst;
	                            rid==resp_pkt.arid;
            })
            foreach(pkt.rdata[i])begin
                pkt.rdata[i]=mem_model.mem[addr];
                addr=addr+4;
            end  
            foreach(pkt.rresp[i])
            pkt.rresp[i]=DECERR;
           finish_item(pkt);
           get_response(pkt);
        end
         if(resp_pkt.operation== WRITE) begin
       	`uvm_info("slave_sequence :: inside the write op task",$sformatf("resp_pkt=%p ",resp_pkt),UVM_LOW);
          pkt = slave_seq_item :: type_id :: create ("pkt");
          start_item(pkt);
          assert (pkt.randomize() with {operation == WRITE;
                                      awid == resp_pkt.awid;
	        awaddr == resp_pkt.awaddr;
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
    end
    endtask
endclass

////////////////////////sg decode error sequence /////////////////////////
class sg_decode_err_slave_seq extends base_slave_sequence;
    `uvm_object_utils(sg_decode_err_slave_seq)

    `uvm_declare_p_sequencer(slave_sequencer)
    slave_seq_item resp_pkt,pkt,sg_pkt;
    slave_seq_item read_packets[$];
    axi_slave_mem_model mem_model;
    bit[63:0] addr;

    function new(string name="sg_decode_err_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
            `uvm_error("SLAVE_SEQ","failed to get memory handle")
        end
        `uvm_info("sg_slave_sequence::body_task","Triggred",UVM_LOW)
        forever begin
         `uvm_info("sg_slave_seqence::body_task","waiting for slave_packet",UVM_LOW)
          p_sequencer.resp_af.get(resp_pkt);
          `uvm_info("sg_slave_sequence::printing_response_packet",resp_pkt.sprint(),UVM_LOW)
        
        if(resp_pkt.operation==READ)begin
        `uvm_info("read_packet",resp_pkt.sprint(),UVM_LOW)
           addr=resp_pkt.araddr;
           pkt=slave_seq_item::type_id::create("pkt");
           start_item(pkt);
           assert(pkt.randomize() with {operation==READ;arid ==resp_pkt.arid;
	                            araddr==resp_pkt.araddr;
	                            arlen ==resp_pkt.arlen;
	                            arsize==resp_pkt.arsize;
	                            arburst==resp_pkt.arburst;
	                            rid==resp_pkt.arid;
            })
            foreach(pkt.rdata[i])begin
                pkt.rdata[i]=mem_model.mem[addr];
                $display("mem_model.mem=%0h",mem_model.mem[addr]);
                $display("assigned rdata=%0h",pkt.rdata[i]);
                addr=addr+4;
            end  
            foreach(pkt.rresp[i])
            pkt.rresp[i]=OKAY;
           finish_item(pkt);
           `uvm_info("sg_decode_err_seq",pkt.sprint(),UVM_LOW)
           get_response(pkt);
        end
         if(resp_pkt.operation== WRITE) begin
       	`uvm_info("slave_sequence :: inside the write op task",$sformatf("resp_pkt=%p ",resp_pkt),UVM_LOW);
          pkt = slave_seq_item :: type_id :: create ("pkt");
          start_item(pkt);
          assert (pkt.randomize() with {operation == WRITE;
                                      awid == resp_pkt.awid;
	        awaddr == resp_pkt.awaddr;
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
    end
    endtask
endclass

/////////////////////////SG SLAVE ERROR SEQENCE/////////////////////
class sg_slave_error_sequence extends base_slave_sequence;
    `uvm_object_utils(sg_slave_error_sequence)
    
    `uvm_declare_p_sequencer(slave_sequencer)
    slave_seq_item resp_pkt,pkt,sg_pkt;
    slave_seq_item read_packets[$];
    axi_slave_mem_model mem_model;
    bit[63:0] addr;

    function new(string name="sg_slave_error_sequence");
        super.new(name);
    endfunction
virtual task body();
        if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
            `uvm_error("SLAVE_SEQ","failed to get memory handle")
        end
        `uvm_info("sg_slave_sequence::body_task","Triggred",UVM_LOW)
        forever begin
         `uvm_info("sg_slave_seqence::body_task","waiting for slave_packet",UVM_LOW)
          p_sequencer.resp_af.get(resp_pkt);
          `uvm_info("sg_slave_sequence::printing_response_packet",resp_pkt.sprint(),UVM_LOW)
        
        if(resp_pkt.operation==READ)begin
        `uvm_info("read_packet",resp_pkt.sprint(),UVM_LOW)
           addr=resp_pkt.araddr;
           pkt=slave_seq_item::type_id::create("pkt");
           start_item(pkt);
           assert(pkt.randomize() with {operation==READ;arid ==resp_pkt.arid;
	                            araddr==resp_pkt.araddr;
	                            arlen ==resp_pkt.arlen;
	                            arsize==resp_pkt.arsize;
	                            arburst==resp_pkt.arburst;
	                            rid==resp_pkt.arid;
            })
            foreach(pkt.rdata[i])begin
                pkt.rdata[i]=mem_model.mem[addr];
                addr=addr+4;
            end  
            foreach(pkt.rresp[i])
            pkt.rresp[i]=SLVERR;
           finish_item(pkt);
           get_response(pkt);
        end
         if(resp_pkt.operation== WRITE) begin
       	`uvm_info("slave_sequence :: inside the write op task",$sformatf("resp_pkt=%p ",resp_pkt),UVM_LOW);
          pkt = slave_seq_item :: type_id :: create ("pkt");
          start_item(pkt);
          assert (pkt.randomize() with {operation == WRITE;
                                      awid == resp_pkt.awid;
	        awaddr == resp_pkt.awaddr;
	        awlen == resp_pkt.awlen;
	        awsize == resp_pkt.awsize;
	        awburst == resp_pkt.awburst;
	        bid == awid;
	        bresp ==OKAY;
	        })
       else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
       finish_item(pkt);
       get_response(pkt);
       end
    end
    endtask
endclass

///////////////////////////////SG SLAVE ERROR SEQUENCE//////////////////
class sg_slave_err_sequence extends base_slave_sequence;
    `uvm_object_utils(sg_slave_err_sequence)

   `uvm_declare_p_sequencer(slave_sequencer)
    slave_seq_item resp_pkt,pkt,sg_pkt;
    slave_seq_item read_packets[$];
    axi_slave_mem_model mem_model;
    bit[63:0] addr;
    
    function new(string name="sg_slave_err_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
            `uvm_error("SLAVE_SEQ","failed to get memory handle")
        end
        `uvm_info("sg_slave_sequence::body_task","Triggred",UVM_LOW)
        forever begin
         `uvm_info("sg_slave_seqence::body_task","waiting for slave_packet",UVM_LOW)
          p_sequencer.resp_af.get(resp_pkt);
          `uvm_info("sg_slave_sequence::printing_response_packet",resp_pkt.sprint(),UVM_LOW)
        
        if(resp_pkt.operation==READ)begin
        `uvm_info("read_packet",resp_pkt.sprint(),UVM_LOW)
           addr=resp_pkt.araddr;
           pkt=slave_seq_item::type_id::create("pkt");
           start_item(pkt);
           assert(pkt.randomize() with {operation==READ;arid ==resp_pkt.arid;
	                            araddr==resp_pkt.araddr;
	                            arlen ==resp_pkt.arlen;
	                            arsize==resp_pkt.arsize;
	                            arburst==resp_pkt.arburst;
	                            rid==resp_pkt.arid;
            })
            foreach(pkt.rdata[i])begin
                pkt.rdata[i]=mem_model.mem[addr];
                addr=addr+4;
            end  
            foreach(pkt.rresp[i])
            pkt.rresp[i]=OKAY;
           finish_item(pkt);
           get_response(pkt);
        end
         if(resp_pkt.operation== WRITE) begin
       	  `uvm_info("slave_sequence :: inside the write op task",$sformatf("resp_pkt=%p ",resp_pkt),UVM_LOW);
          pkt = slave_seq_item :: type_id :: create ("pkt");
          start_item(pkt);
          assert (pkt.randomize() with {operation == WRITE;
                                      awid == resp_pkt.awid;
	        awaddr == resp_pkt.awaddr;
	        awlen == resp_pkt.awlen;
	        awsize == resp_pkt.awsize;
	        awburst == resp_pkt.awburst;
	        bid == awid;
	        bresp ==SLVERR;
	        })
       else  `uvm_error (get_full_name() ,"Packet Randomization Fail")
       finish_item(pkt);
       get_response(pkt);
       end
    end
    endtask
endclass

