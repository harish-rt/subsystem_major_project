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
typedef master_sequencer m_seqr;
class axi_master_sequence extends uvm_sequence #(master_seq_item);
  `uvm_object_utils (axi_master_sequence)
  `uvm_declare_p_sequencer(m_seqr)

  master_seq_item   pkt;
  int               seq_burst_count;
  string            binary;
    
  function new (string name = "axi_master_sequence");
    super.new (name);
  endfunction

  virtual task body ();
    int bin_fd, index, i;
    bit [31:0]  wdata;
    bit [31:0]  awlen;
    bit [7:0]   data;
    bit [31:0]  addr = 32'h`BOOT_ADDR;

    req = master_seq_item :: type_id :: create ("req");

    void'($value$plusargs("bin=%0s", binary));            // Accessing .bin file
    bin_fd = $fopen(binary,"rb");

    awlen = (4096 - addr[11:0]) / 4;                      // Burst Length Calculation
    if(awlen > 'd256)
      awlen = 'd256;

    req.wdata   = new[awlen];
    req.wstrobe = new[awlen];

    while(!$feof(bin_fd)) begin 
        for(i = 0; i<4; i++) begin
            if($fread(data, bin_fd))
              wdata[i*8 +: 8] = data;
            else break;
        end
      
        req.wdata[index]    = wdata;
        if($feof(bin_fd)) begin
          req.wstrobe[index]  = (2**i) - 1;
          awlen               = index + 1'b1;
          req.wdata           = new[awlen] (req.wdata);
          req.wstrobe         = new[awlen] (req.wstrobe);
        end
        else begin
          req.wstrobe[index]  = 4'b1111;
        end

        index++;

        if(index == awlen) begin
            start_item(req);
                req.awid    = 'd0;
                req.awaddr  = addr;
                req.awlen   = awlen - 1'b1;
                req.awburst = INCR;
                req.awsize  = 2'd2;
                seq_burst_count++;
                $display("BURST COUNT = %0d",seq_burst_count);
            finish_item(req);

            index = 0;
            wdata = 0;
            addr  = (awlen * 4) + addr;
            
            awlen = (4096 - addr[11:0]) / 4;              // Burst Length Calculation
            if(awlen > 'd256)
                awlen = 'd256;
            req.wdata   = new[awlen];
            req.wstrobe = new[awlen];
        end

    end

  endtask : body
endclass : axi_master_sequence


