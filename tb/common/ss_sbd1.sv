class ss_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ss_scoreboard)
    `NEW_COMP

    cpu_seq_item            info_pkt;
    bram_seq_item           bram_pkt;
    mem_seq_item            mem_pkt;

    sb_config               sb_cfg;

    uvm_tlm_analysis_fifo #(cpu_seq_item)       master_af;
    uvm_tlm_analysis_fifo #(s04_seq_item)       s04_af;
    uvm_tlm_analysis_fifo #(bram_seq_item)      bram_af;
    uvm_tlm_analysis_fifo #(mem_seq_item)       mem_af;
    uvm_tlm_analysis_fifo #(lite_intc_seq_item) intc_af;

    cpu_seq_item            exp_bram_wr_q[$];
    cpu_seq_item            exp_bram_rd_q[$];
    cpu_seq_item            exp_lite_wr_q[$];
    cpu_seq_item            exp_lite_rd_q[$];

    extern function void    build_phase(uvm_phase phase);
    extern task             main_phase(uvm_phase phase);
    extern task             master_traffic();
    //extern function bit     decode_slave(bit [ADDR_WIDTH-1:0]addr,output slave_t slave);
    extern function void    axi_write_burst(cpu_seq_item pkt);
    extern function void    axi_read_burst(cpu_seq_item pkt);
    extern task             bram_traffic();
endclass

function void ss_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db #(sb_config)::get(this,"","SB_CFG",sb_cfg))
        `uvm_fatal("SS_SBD_ERR","Failed to get sb_cfg!")
    master_af       = new("master_af",this);
    s04_af          = new("s04_af",this);
    cdma_reg_af     = new("cdma_reg_af",this);
    bram_af         = new("bram_af",this);
    lite_mem_af     = new("lite_mem_af",this);
    lite_intc_af    = new("lite_intc_af",this);
endfunction

task ss_scoreboard::main_phase(uvm_phase phase);
    fork
        master_traffic();
    join
endtask

//function bit ss_scoreboard::decode_slave(bit [ADDR_WIDTH-1:0] addr, output slave_t slave);
//    foreach (perif_addr[i]) begin
//        if (addr >= perif_addr[i].base_address && addr <= perif_addr[i].high_address) begin
//            slave = perif_addr[i].slave_name;
//            return 1'b1;
//        end
//    end
//    return 1'b0;
//endfunction

task ss_scoreboard::master_traffic();
    cpu_seq_item    pkt;
    slave_t         dec_slave;

    forever begin
        master_af.get(pkt);

        if(pkt.operation == WRITE) begin
            if(!sb_cfg.decode_slave(pkt.AWADDR, dec_slave)) begin
                `uvm_error("DECERR",$sformatf("CPU Write to unmapped address: 0x%08h",pkt.AWADDR))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        `uvm_info("SBD_BRAM_W",$sformatf("CPU -> BRAM Write: Addr=0x%08h Data=0x%08h",pkt.AWADDR,pkt.WDATA),UVM_LOW)
                        axi_write_burst(pkt);
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_LITE_MEM_W",$sformatf("CPU -> LITE_MEM Write: Addr=0x%08h Data=0x%08h",pkt.AWADDR,pkt.WDATA),UVM_LOW)
                        exp_lite_wr_q.push_back(pkt);
                    end
                endcase
            end
        end
        else if(pkt.operation == READ) begin
            if (!sb_cfg.decode_slave(pkt.ARADDR, dec_slave)) begin
                `uvm_error("DECERR",$sformatf("CPU Read to unmapped address: 0x%08h",pkt.ARADDR))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        `uvm_info("SBD_BRAM_R",$sformatf("BRAM -> CPU Read: Addr=0x%08h Data=0x%08h",pkt.AWADDR,pkt.WDATA),UVM_LOW)
                        axi_read_burst(pkt);
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_LITE_MEM_R",$sformatf("LITE_MEM -> CPU Read: Addr=0x%08h Data=0x%08h",pkt.ARADDR,pkt.RDATA),UVM_LOW)
                    end
                endcase
            end
        end
    end
endtask

function void ss_scoreboard::axi_write_burst(cpu_seq_item pkt);
    exp_bram_wr_q.push_back(pkt);
endfunction

function void ss_scoreboard::axi_read_burst(cpu_seq_item pkt);
endfunction

task ss_scoreboard::bram_traffic();
    bram_seq_item pkt;
    forever begin
        bram_af.get(pkt);
    end
endtask
