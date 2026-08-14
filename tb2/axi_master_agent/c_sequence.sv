class c_sequence extends uvm_sequence #(master_seq_item);

  `uvm_object_utils(c_sequence)

  bit [31:0] waddr, wdata;
  bit [31:0] raddr, rdata;

  command_t operation;

  function new(string name = "c_sequence");
    super.new(name);
  endfunction

  task body();
    req = master_seq_item :: type_id :: create("req");

    start_item(req);
    req.operation = operation;
    req.wdata = new[1];
    req.rdata = new[1];
    req.rresp = new[1];

    req.awaddr    = waddr;
    req.wdata[0]  = wdata;
    req.awlen     = 'd0;
    req.awburst   = INCR;
    req.wlast     = 'd1;
    
    req.araddr    = raddr;
    req.arlen     = 'd0; 
    req.arburst   = INCR;
    
    finish_item(req);

    get_response(rsp);

    if(operation == READ) begin
      if(rsp.rresp[0] != 0) begin
        `uvm_error("c_sequence",$sformatf("Read Response Error = %s",rsp.rresp[0].name()));
      end else begin
        rdata = rsp.rdata[0];
      end
    end
  endtask

endclass

class c_base_sequence extends uvm_sequence#(uvm_sequence_item);
  `uvm_object_utils(c_base_sequence)
  
  master_sequencer  m_sqr;
  c_sequence        c_seq;
  bit [31:0] waddr, wdata;
  bit [31:0] raddr, rdata;

  command_t operation;

  function new(string name = "c_base_sequence");
    super.new(name);
  endfunction

  task body();
    uvm_component temp[$];
    temp.delete();

    uvm_top.find_all("*env.axi_master_agt[0].sqr",temp);
    if(temp.size() == 0)
      `uvm_fatal("C_BASE_SEQ","Couldn't Find AXI Master Agent Sequencer")
    else if(temp.size() > 1)
      `uvm_fatal("C_BASE_SEQ","Found More than 1 AXI Master Agent Sequencer")
    else
      $cast(m_sqr,temp[0]);

    c_seq = c_sequence :: type_id :: create("c_seq");
    c_seq.waddr     = waddr;               
    c_seq.wdata     = wdata;
    c_seq.raddr     = raddr;
    c_seq.operation = operation;
    c_seq.start(m_sqr);
    rdata           = c_seq.rdata;
  endtask
endclass

