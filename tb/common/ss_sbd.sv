class ss_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ss_scoreboard)
    `NEW_COMP

    sb_config               sb_cfg;
    master_e                port_id;

    uvm_tlm_analysis_fifo #(cpu_seq_item)               master_af[2];
    uvm_tlm_analysis_fifo #(s04_seq_item)               s04_af;
    uvm_tlm_analysis_fifo #(bram_seq_item)              bram_af;
    uvm_tlm_analysis_fifo #(mem_seq_item)               mem_af;
    uvm_tlm_analysis_fifo #(master_seq_item)            cdma_af;
    uvm_tlm_analysis_fifo #(lite_intc_seq_item)         intc_af;
    uvm_tlm_analysis_fifo #(core_perif_lite_seq_item)   core_perif_af;

// bram
    axi_base_sequence_item  exp_bram_wr_q[master_e][$];
    axi_base_sequence_item  exp_bram_rd_q[master_e][$];
    bram_seq_item           act_bram_wr_q[id_t][$];
    bram_seq_item           act_bram_rd_q[id_t][$];

// lite mem
    axi_base_sequence_item  exp_lite_wr_q[$];
    axi_base_sequence_item  exp_lite_rd_q[$];
    mem_seq_item            act_lite_wr_q[$];
    mem_seq_item            act_lite_rd_q[$];

// cdma
    axi_base_sequence_item  exp_cdma_wr_q[$];
    axi_base_sequence_item  exp_cdma_rd_q[$];
    master_seq_item         act_cdma_wr_q[$];
    master_seq_item         act_cdma_rd_q[$];

// interrupt controller
    axi_base_sequence_item  exp_intc_wr_q[$];
    axi_base_sequence_item  exp_intc_rd_q[$];
    lite_intc_seq_item      act_intc_wr_q[$];
    lite_intc_seq_item      act_intc_rd_q[$];

// core perif
    axi_base_sequence_item     exp_core_wr_q[$];
    axi_base_sequence_item     exp_core_rd_q[$];
    core_perif_lite_seq_item   act_core_wr_q[$];
    core_perif_lite_seq_item   act_core_rd_q[$];

    // 0 = Monitor sends the full address
    // 1 = Monitor sends offset address (AxADDR - BASE)
    bit                     addr_is_local = 1;
    int                     bram_wr_match,bram_wr_mismatch;
    int                     bram_rd_match,bram_rd_mismatch;
    int                     lite_wr_match,lite_wr_mismatch;
    int                     lite_rd_match,lite_rd_mismatch;
    
    extern function void    build_phase(uvm_phase phase);
    extern task             main_phase(uvm_phase phase);
    extern function void    report_phase(uvm_phase phase);

    extern task             master_traffic();
    extern task             s04_traffic();

    extern task             bram_traffic();
    extern function void    bram_wr_extract();
    extern function void    bram_rd_extract();
    extern function void    bram_wr_compare(axi_base_sequence_item exp, bram_seq_item act);
    extern function void    bram_rd_compare(axi_base_sequence_item exp, bram_seq_item act);

    extern task             mem_traffic();
    extern function void    match_lite_wr();
    extern function void    match_lite_rd();

    extern task             cdma_traffic();
    extern function void    match_cdma_wr();
    extern function void    match_cdma_rd();

    extern task             intc_traffic();
    extern function void    match_intc_wr();
    extern function void    match_intc_rd();

    extern task             core_perif_traffic();
    extern function void    match_core_wr();
    extern function void    match_core_rd();
endclass

function void ss_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db #(sb_config)::get(this,"","SB_CFG",sb_cfg))
        `uvm_fatal("SS_SBD_ERR","Failed to get sb_cfg!")
    foreach(master_af[i])begin
        master_af[i]       = new($sformatf("master_af[%0d]",i),this);
    end
    //master_af       = new("master_af",this);
    s04_af          = new("s04_af",this);
    bram_af         = new("bram_af",this);
    mem_af          = new("mem_af",this);
    cdma_af         = new("cdma_af",this);
    intc_af         = new("intc_af",this);
    core_perif_af   = new("core_perif_af",this);
endfunction

task ss_scoreboard::main_phase(uvm_phase phase);
    fork
    // Masters
        master_traffic();
        s04_traffic();
    // Slaves
        bram_traffic();
        mem_traffic();
        cdma_traffic();
        intc_traffic();
        core_perif_traffic();
    join
endtask

task ss_scoreboard::master_traffic();

    foreach(master_af[i])begin
        automatic int id = i;

        fork
            forever begin
                cpu_seq_item    pkt;
                slave_t         dec_slave;

                master_af[id].get(pkt);

                if(id == 0) port_id = MST_S00;
                if(id == 1) port_id = MST_S02;

                if(pkt.master_p != port_id)
                    `uvm_error("SBD_MASTER",$sformatf("master_af packet stamped %s, expected %s",pkt.master_p.name(),port_id))

                if(pkt.operation == WRITE) begin
                    if(!sb_cfg.decode_slave(pkt.AWADDR, dec_slave)) begin
                        `uvm_info("WRITE_ADDR_DECODE", $sformatf("Successfully decoded address 0x%0h to slave: %s", pkt.AWADDR, dec_slave.name()), UVM_LOW)                        
                        if(pkt.BRESP !== 2'b11)
                            `uvm_error("SBD_DECERR",$sformatf("CPU Write to unmapped addr 0x%08h: BRESP=%0b, expected DECERR",pkt.AWADDR,pkt.BRESP))
                    end
                    else begin
                        case (dec_slave)
                            BRAM: begin
                                `uvm_info($sformatf("SBD_%s_BRAM_W",pkt.master_p.name()), $sformatf("[%s] -> BRAM Write: Addr=0x%08h Data: %0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                                exp_bram_wr_q[port_id].push_back(pkt);
                                bram_wr_extract();
                            end
                            LITE_MEM: begin
                                `uvm_info($sformatf("SBD_%s_MEM_W",pkt.master_p.name()),$sformatf("CPU -> LITE_MEM Write: Addr=0x%08h Data=0x%0h Strb=0x%0h",pkt.AWADDR,{>>{pkt.WDATA}},{>>{pkt.WSTRB}}),UVM_LOW)
                                exp_lite_wr_q.push_back(pkt);
                                match_lite_wr();
                            end
                            CDMA: begin
                                `uvm_info($sformatf("SBD_%s_CDMA_W",pkt.master_p.name()), $sformatf("[%s] -> CDMA Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                                exp_cdma_wr_q.push_back(pkt);
                                match_cdma_wr();
                            end
                            INTC: begin
                                `uvm_info($sformatf("SBD_%s_INTC_W",pkt.master_p.name()), $sformatf("[%s] -> INTC Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                                exp_intc_wr_q.push_back(pkt);
                                match_intc_wr();
                            end
                            CORE_INTC, UART, SPI: begin
                                `uvm_info($sformatf("SBD_%s_CORE_W",pkt.master_p.name()), $sformatf("[%s] -> %s Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), dec_slave.name(), {>>{pkt.WDATA}}), UVM_LOW)
                                exp_core_wr_q.push_back(pkt);
                                match_core_wr();
                            end
                            default: `uvm_info("SS_SBD","No Slave Selected",UVM_LOW)
                        endcase
                    end
                end
                else if(pkt.operation == READ) begin
                    //`uvm_info("SBD_CPU_READ", $sformatf("[%s] ARADDR @0x%08h\n--- Expected CPU Packet ---\n%s", pkt.master_p.name(), pkt.ARADDR, pkt.sprint()),UVM_LOW)
                    if(!sb_cfg.decode_slave(pkt.ARADDR, dec_slave)) begin
                        `uvm_info("READ_ADDR_DECODE", $sformatf("Successfully decoded address 0x%0h to slave: %s", pkt.ARADDR, dec_slave.name()), UVM_LOW)                        
                        if(pkt.RRESP[0] !== 2'b11)
                            `uvm_error("SBD_DECERR",$sformatf("CPU Read from unmapped addr 0x%08h: RRESP=%0h, expected DECERR",pkt.ARADDR,{>>{pkt.RRESP}}))
                    end
                    else begin
                        case (dec_slave)
                            BRAM: begin
                                `uvm_info($sformatf("SBD_%s_BRAM_R",pkt.master_p.name()), $sformatf("[%s] -> BRAM Read: Addr=0x%08h Data: %0h", pkt.master_p.name(), pkt.ARADDR, {>>{pkt.RDATA}}), UVM_LOW)
                                exp_bram_rd_q[port_id].push_back(pkt);
                                bram_rd_extract();
                            end
                            LITE_MEM: begin
                                `uvm_info($sformatf("SBD_%s_MEM_R",pkt.master_p.name()),$sformatf("LITE_MEM -> CPU Read: Addr=0x%08h Data=0x%0h",pkt.ARADDR,{>>{pkt.RDATA}}),UVM_LOW)
                                exp_lite_rd_q.push_back(pkt);
                                match_lite_rd();
                            end
                            CDMA: begin
                                `uvm_info($sformatf("SBD_%s_CDMA_R",pkt.master_p.name()), $sformatf("[%s] -> CDMA Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                                exp_cdma_rd_q.push_back(pkt);
                                match_cdma_rd();
                            end
                            INTC: begin
                                `uvm_info($sformatf("SBD_%s_INTC_R",pkt.master_p.name()), $sformatf("[%s] -> INTC Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                                exp_intc_rd_q.push_back(pkt);
                                match_intc_rd();
                            end
                            CORE_INTC, UART, SPI: begin
                                `uvm_info($sformatf("SBD_%s_CORE_R",pkt.master_p.name()), $sformatf("[%s] -> %s Read: Addr=0x%08h", pkt.master_p.name(), dec_slave.name(), pkt.ARADDR), UVM_LOW)
                                exp_core_rd_q.push_back(pkt);
                                match_core_rd();
                            end
                            default: `uvm_info("SS_SBD","No Slave Selected",UVM_LOW)
                        endcase
                    end
                end
            end
        join_none
    end
endtask : master_traffic

task ss_scoreboard::s04_traffic();
    s04_seq_item   pkt;
    slave_t        dec_slave;

    forever begin
        s04_af.get(pkt);
        //`uvm_info("SBD_S04_PKT", $sformatf("Received packet from S04 monitor:\n%s", pkt.sprint()), UVM_LOW)

        if(pkt.master_p != MST_S04)
            `uvm_error("SBD_MASTER",$sformatf("s04_af packet stamped %s, expected MST_S04",pkt.master_p.name()))
        else port_id = MST_S04;

        if(pkt.operation == WRITE) begin
            //`uvm_info("SBD_S04_PKT_W", $sformatf("Received packet from S04 monitor:\n%s", pkt.sprint()), UVM_LOW)
            if(!sb_cfg.decode_slave(pkt.AWADDR, dec_slave)) begin
                if(pkt.BRESP !== 2'b11)
                    `uvm_error("SBD_DECERR",$sformatf("[%s] Write to unmapped addr 0x%08h: BRESP=%0b, expected DECERR", pkt.master_p.name(), pkt.AWADDR, pkt.BRESP))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        `uvm_info("SBD_S04_BRAM_W", $sformatf("[%s] -> BRAM Write PKT:\n%s",pkt.master_p.name(), pkt.sprint()), UVM_LOW)
                        
                        exp_bram_wr_q[port_id].push_back(pkt);
                        bram_wr_extract();
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_S04_MEM_W",$sformatf("[%s] -> LITE_MEM Write PKT:\n%s",pkt.master_p.name(), pkt.sprint()), UVM_LOW)
                        exp_lite_wr_q.push_back(pkt);
                        match_lite_wr();
                    end
                    CDMA: begin
                        `uvm_info("SBD_S04_CDMA_W", $sformatf("[%s] -> CDMA Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_cdma_wr_q.push_back(pkt);
                        match_cdma_wr();
                    end
                    INTC: begin
                        `uvm_info("SBD_S04_INTC_W", $sformatf("[%s] -> INTC Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_intc_wr_q.push_back(pkt);
                        match_intc_wr();
                    end
                    CORE_INTC, UART, SPI: begin
                        `uvm_info("SBD_S04_CORE_W", $sformatf("[%s] -> %s Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), dec_slave.name(), {>>{pkt.WDATA}}), UVM_LOW)
                        exp_core_wr_q.push_back(pkt);
                        match_core_wr();
                    end
                    default: `uvm_info("SS_SBD","No Slave Selected", UVM_LOW)
                endcase
            end
        end
        else if(pkt.operation == READ) begin
            //`uvm_info("SBD_S04_PKT_R", $sformatf("Received packet from S04 monitor:\n%s", pkt.sprint()), UVM_LOW)
            if(!sb_cfg.decode_slave(pkt.ARADDR, dec_slave)) begin
                if(pkt.RRESP[0] !== 2'b11) 
                    `uvm_error("SBD_DECERR",$sformatf("Read from unmapped addr 0x%08h: expected DECERR", pkt.ARADDR))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        `uvm_info("SBD_S04_BRAM_R", $sformatf("[%s] -> BRAM Read PKT:\n%s",pkt.master_p.name(), pkt.sprint()), UVM_LOW)
                        
                        exp_bram_rd_q[port_id].push_back(pkt);
                        bram_rd_extract();
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_S04_MEM_R",$sformatf("[%s] -> LITE_MEM Read PKT:\n%s",pkt.master_p.name(), pkt.sprint()), UVM_LOW)
                        exp_lite_rd_q.push_back(pkt);
                        match_lite_rd();
                    end
                    CDMA: begin
                        `uvm_info("SBD_S04_CDMA_R", $sformatf("[%s] -> CDMA Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                        exp_cdma_rd_q.push_back(pkt);
                        match_cdma_rd();
                    end
                    INTC: begin
                        `uvm_info("SBD_S04_INTC_R", $sformatf("[%s] -> INTC Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                        exp_intc_rd_q.push_back(pkt);
                        match_intc_rd();
                    end
                    CORE_INTC, UART, SPI: begin
                        `uvm_info("SBD_S04_CORE_R", $sformatf("[%s] -> %s Read: Addr=0x%08h", pkt.master_p.name(), dec_slave.name(), pkt.ARADDR), UVM_LOW)
                        exp_core_rd_q.push_back(pkt);
                        match_core_rd();
                    end
                    default: `uvm_info("SS_SBD","No Slave Selected", UVM_LOW)
                endcase
            end
        end
    end
endtask : s04_traffic

task ss_scoreboard::bram_traffic();
    bram_seq_item pkt;

    forever begin
        bram_af.get(pkt);

        if(pkt.operation == WRITE) begin
            `uvm_info("SBD_BRAM_ACT_W",$sformatf("BRAM saw Write:\n%s",pkt.sprint()),UVM_LOW)
            act_bram_wr_q[pkt.AWID].push_back(pkt);
            //bram_wr_extract();
        end
        else if(pkt.operation == READ) begin
            `uvm_info("SBD_BRAM_ACT_R",$sformatf("BRAM saw Read:\n%s",pkt.sprint()),UVM_LOW)
            act_bram_rd_q[pkt.ARID].push_back(pkt);
            //bram_rd_extract();
        end
    end
endtask

function void ss_scoreboard::bram_wr_extract();
    axi_base_sequence_item  exp;
    bram_seq_item           act;
    bit [7:0] target_id;

    while (exp_bram_wr_q[MST_S00].size() > 0 && act_bram_wr_q['h00].size() > 0) begin
        exp = exp_bram_wr_q[MST_S00].pop_front();
        act = act_bram_wr_q['h00].pop_front();
        bram_wr_compare(exp, act);
    end

    while (exp_bram_wr_q[MST_S02].size() > 0 && act_bram_wr_q['h20].size() > 0) begin
        exp = exp_bram_wr_q[MST_S02].pop_front();
        act = act_bram_wr_q['h20].pop_front();
        bram_wr_compare(exp, act);
    end

    while (exp_bram_wr_q[MST_S04].size() > 0) begin
        exp = exp_bram_wr_q[MST_S04][0];
        target_id = exp.AWID | 'h40; 

        if (act_bram_wr_q.exists(target_id) && act_bram_wr_q[target_id].size() > 0) begin
            exp = exp_bram_wr_q[MST_S04].pop_front();
            act = act_bram_wr_q[target_id].pop_front();
            bram_wr_compare(exp, act);
        end else begin
            break; 
        end
    end
endfunction : bram_wr_extract

/*
function void ss_scoreboard::bram_wr_extract();
    axi_base_sequence_item  exp;
    bram_seq_item           act;
    
    act = act_bram_rd_q[0];
    if(act_bram_wr_q[act.AWID].size() > 0) begin
        case (port_id)
            MST_S00:begin
                if(exp_bram_wr_q[port_id].size() > 0) begin
                    exp = exp_bram_wr_q[port_id].pop_front();
                    act = act_bram_wr_q[act.AWID].pop_front();
                    bram_wr_compare(exp, act);
                end
            end
            MST_S02:begin
                if(exp_bram_wr_q[port_id].size() > 0) begin
                    exp = exp_bram_wr_q[port_id].pop_front();
                    act = act_bram_wr_q.pop_front();
                    bram_wr_compare(exp, act);
                end
            end
            MST_S04:begin
                if(exp_bram_wr_q[port_id].size() > 0) begin
                    exp = exp_bram_wr_q[port_id].pop_front();
                    act = act_bram_wr_q.pop_front();
                    bram_wr_compare(exp, act);
                end
            end
        endcase
    end
endfunction
*/

function void ss_scoreboard::bram_wr_compare(axi_base_sequence_item exp, bram_seq_item act);
    bit [ADDR_WIDTH-1:0] exp_addr;
    int iter_beats, exp_beats;
    bit is_match = 1;

    exp_addr = addr_is_local ? (exp.AWADDR - BRAM_BASE) : exp.AWADDR;

    if(exp_addr !== act.AWADDR) begin
        `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp_addr, act.AWADDR))
        is_match = 0;
    end
    
    exp_beats = (exp.master_p == MST_S04) ? (exp.AWLEN + 1) : 1;
    
    if(exp_beats !== act.WDATA.size()) begin
        `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] Burst Length mismatch @0x%08h! expected %0d beats, monitor saw %0d beats", exp.master_p.name(), exp_addr, exp_beats, act.WDATA.size()))
        is_match = 0;
    end

    iter_beats = (exp_beats < act.WDATA.size()) ? exp_beats : act.WDATA.size();

    for(int b = 0; b < iter_beats; b++) begin
        if(exp.WSTRB[b] !== act.WSTRB[b]) begin
            `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] WSTRB mismatch @0x%08h beat %0d: exp=0x%0h act=0x%0h", exp.master_p.name(), exp_addr, b, exp.WSTRB[b], act.WSTRB[b]))
            is_match = 0;
        end
        
        for(int i = 0; i < 4; i++) begin
            if(exp.WSTRB[b][i] && (exp.WDATA[b][8*i +: 8] !== act.WDATA[b][8*i +: 8])) begin
                `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h beat %0d byte %0d: exp=0x%02h act=0x%02h", exp.master_p.name(), exp_addr, b, i, exp.WDATA[b][8*i +: 8], act.WDATA[b][8*i +: 8]))
                is_match = 0;
            end
        end
    end

    if (is_match) begin
        bram_wr_match++;
        `uvm_info("SBD_BRAM_WR_PASS", $sformatf("[%s] BRAM Write match SUCCESS at Addr 0x%08h", exp.master_p.name(), exp_addr), UVM_HIGH)
    end else begin
        bram_wr_mismatch++;
    end
endfunction : bram_wr_compare

function void ss_scoreboard::bram_rd_extract();
    axi_base_sequence_item  exp;
    bram_seq_item           act;
    bit [7:0] target_id;

    while (exp_bram_rd_q[MST_S00].size() > 0 && act_bram_rd_q['h00].size() > 0) begin
        exp = exp_bram_rd_q[MST_S00].pop_front();
        act = act_bram_rd_q['h00].pop_front();
        bram_rd_compare(exp, act);
    end

    while (exp_bram_rd_q[MST_S02].size() > 0 && act_bram_rd_q['h20].size() > 0) begin
        exp = exp_bram_rd_q[MST_S02].pop_front();
        act = act_bram_rd_q['h20].pop_front();
        bram_rd_compare(exp, act);
    end

    while (exp_bram_rd_q[MST_S04].size() > 0) begin
        exp = exp_bram_rd_q[MST_S04][0];
        target_id = exp.ARID | 'h40; 

        if (act_bram_rd_q.exists(target_id) && act_bram_rd_q[target_id].size() > 0) begin
            exp = exp_bram_rd_q[MST_S04].pop_front();
            act = act_bram_rd_q[target_id].pop_front();
            bram_rd_compare(exp, act);
        end else begin
            break; 
        end
    end
endfunction : bram_rd_extract
/*
function void ss_scoreboard::bram_rd_extract();
    axi_base_sequence_item  exp;
    bram_seq_item           act;

    if(act_bram_rd_q.size() > 0) begin
        case (port_id)
            MST_S00:begin
                if(exp_bram_rd_q[port_id].size() > 0) begin
                    exp = exp_bram_rd_q[port_id].pop_front();
                    act = act_bram_rd_q.pop_front();
                    bram_rd_compare(exp,act);
                end
            end
            MST_S02:begin
                if(exp_bram_rd_q[port_id].size() > 0) begin
                    exp = exp_bram_rd_q[port_id].pop_front();
                    act = act_bram_rd_q.pop_front();
                    bram_rd_compare(exp,act);
                end
            end
            MST_S04:begin
                if(exp_bram_rd_q[port_id].size() > 0) begin
                    exp = exp_bram_rd_q[port_id].pop_front();
                    act = act_bram_rd_q.pop_front();
                    bram_rd_compare(exp,act);
                end
            end
        endcase
    end
endfunction
*/

function void ss_scoreboard::bram_rd_compare(axi_base_sequence_item exp, bram_seq_item act);
    bit [ADDR_WIDTH-1:0] exp_addr;
    int iter_beats, exp_beats;
    bit is_match = 1;

    exp_addr = addr_is_local ? (exp.ARADDR - BRAM_BASE) : exp.ARADDR;

    if(exp_addr !== act.ARADDR)begin
        `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] ARADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp_addr, act.ARADDR))
        is_match = 0;
    end
    
    exp_beats = (exp.master_p == MST_S04) ? (exp.ARLEN + 1) : 1;
    //$display("this_is_from_match_bram_rd: %s",port_id);

    if(exp_beats !== act.RDATA.size()) begin
        `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] Burst Length mismatch @0x%08h! expected %0d beats, monitor saw %0d beats", exp.master_p.name(), exp_addr, exp_beats, act.RDATA.size()))
    end

    iter_beats = (exp_beats < act.RDATA.size()) ? exp_beats : act.RDATA.size();

    for(int b = 0; b < iter_beats; b++) begin
        if(exp.RDATA[b] !== act.RDATA[b])begin
            `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] DATA mismatch @0x%08h beat %0d: CPU saw=0x%08h BRAM returned=0x%08h", exp.master_p.name(), exp_addr, b, exp.RDATA[b], act.RDATA[b]))
            is_match = 0;
        end
        
        if(exp.RRESP[b] !== act.RRESP[b])begin
            `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] RRESP mismatch @0x%08h beat %0d: exp=0x%0h act=0x%0h", exp.master_p.name(), exp_addr, b, exp.RRESP[b], act.RRESP[b]))
            is_match = 0;
        end
    end
    if (is_match) begin
        bram_rd_match++;
        `uvm_info("SBD_BRAM_RD_PASS", $sformatf("[%s] BRAM Read match SUCCESS at Addr 0x%08h", exp.master_p.name(), exp_addr), UVM_HIGH)
    end else begin
        bram_rd_mismatch++;
    end
endfunction:bram_rd_compare

task ss_scoreboard::mem_traffic();
    mem_seq_item    pkt;

    forever begin
        mem_af.get(pkt);
        
        `uvm_info("SBD_LITE_MEM_ACT", $sformatf("Received packet from LITE_MEM monitor:\n%s", pkt.sprint()), UVM_LOW)

        if(pkt.operation == WRITE) begin
            act_lite_wr_q.push_back(pkt);
            //match_lite_wr();
        end
        else if(pkt.operation == READ) begin
            act_lite_rd_q.push_back(pkt);
            //match_lite_rd();
        end
    end
endtask : mem_traffic

function void ss_scoreboard::match_lite_wr();
    axi_base_sequence_item  exp;
    mem_seq_item            act;
    bit [ADDR_WIDTH-1:0]    exp_beat_addr;
    bit [ADDR_WIDTH-1:0]    aligned_base_addr;
    bit                     is_match;
    int                     exp_beats;

    while(exp_lite_wr_q.size() > 0) begin
        exp = exp_lite_wr_q[0];
        exp_beats = (exp.master_p == MST_S04) ? (exp.AWLEN + 1) : 1;

        if(act_lite_wr_q.size() < exp_beats) return;

        exp = exp_lite_wr_q.pop_front();
        is_match = 1;
        
        aligned_base_addr = exp.AWADDR & ~(ADDR_WIDTH'(3));

        `uvm_info("SBD_LITE_WR_TRACE", $sformatf("Starting comparison for [%s] LITE_MEM Write (Beats: %0d)", exp.master_p.name(), exp_beats), UVM_LOW)

        for(int b = 0; b < exp_beats; b++) begin
            act = act_lite_wr_q.pop_front();

            if (b == 0) begin
                exp_beat_addr = exp.AWADDR;
            end else begin
                exp_beat_addr = aligned_base_addr + (b * 4);
            end

            if(exp_beat_addr !== act.awaddr) begin
                `uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] AWADDR mismatch on beat %0d: exp_beat_addr=0x%08h act=0x%08h", exp.master_p.name(), b, exp_beat_addr, act.awaddr))
                is_match = 0;
            end

            if(exp.WSTRB[b] !== act.wstrb) begin
                `uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] WSTRB mismatch on beat %0d @0x%08h: exp=0x%0h act=0x%0h", exp.master_p.name(), b, exp.AWADDR, exp.WSTRB[b], act.wstrb))
                is_match = 0;
            end
            
            for(int i = 0; i < 4; i++) begin
                if(exp.WSTRB[b][i] && (exp.WDATA[b][8*i +: 8] !== act.wdata[8*i +: 8])) begin
                    `uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] DATA mismatch on beat %0d @0x%08h byte %0d: exp=0x%02h act=0x%02h", exp.master_p.name(), b, exp.AWADDR, i, exp.WDATA[b][8*i +: 8], act.wdata[8*i +: 8]))
                    is_match = 0;
                end
            end
        end

        if (is_match) begin
            lite_wr_match++;
            `uvm_info("SBD_LITE_WR_PASS", $sformatf("[%s] LITE_MEM Write match SUCCESS at Base Addr 0x%08h", exp.master_p.name(), exp.AWADDR), UVM_LOW)
        end else begin
            lite_wr_mismatch++;
        end
    end
endfunction

function void ss_scoreboard::match_lite_rd();
    axi_base_sequence_item  exp;
    mem_seq_item            act;
    bit [ADDR_WIDTH-1:0]    exp_addr;
    bit                     is_match;
    int                     exp_beats;

    while(exp_lite_rd_q.size() > 0) begin
        exp = exp_lite_rd_q[0];
        exp_beats = (exp.master_p == MST_S04) ? (exp.ARLEN + 1) : 1;

        if(act_lite_rd_q.size() < exp_beats) return;

        exp = exp_lite_rd_q.pop_front();
        is_match = 1;

        `uvm_info("SBD_LITE_RD_TRACE", $sformatf("Starting comparison for [%s] LITE_MEM Read (Beats: %0d)", exp.master_p.name(), exp_beats), UVM_LOW)

        for(int b = 0; b < exp_beats; b++) begin
            act = act_lite_rd_q.pop_front();
            exp_addr = exp.ARADDR + (b * 4); // Calculate the beat-level address

            if(exp_addr !== act.araddr) begin
                `uvm_error("SBD_LITE_RD_ERR", $sformatf("[%s] ARADDR mismatch on beat %0d: exp=0x%08h act=0x%08h", exp.master_p.name(), b, exp_addr, act.araddr))
                is_match = 0;
            end

            if(exp.RDATA[b] !== act.rdata) begin
                `uvm_error("SBD_LITE_RD_ERR", $sformatf("[%s] DATA mismatch on beat %0d @0x%08h: exp=0x%08h act=0x%08h", exp.master_p.name(), b, exp_addr, exp.RDATA[b], act.rdata))
                is_match = 0;
            end
        end

        if (is_match) begin
            lite_rd_match++;
            `uvm_info("SBD_LITE_RD_PASS", $sformatf("[%s] LITE_MEM Read match SUCCESS at Base Addr 0x%08h", exp.master_p.name(), exp.ARADDR), UVM_LOW)
        end else begin
            lite_rd_mismatch++;
        end
    end
endfunction

task ss_scoreboard::cdma_traffic();
    master_seq_item pkt;
    forever begin
        cdma_af.get(pkt);
        
        `uvm_info("SBD_CDMA_ACT", $sformatf("Received packet from CDMA register monitor:\n%s", pkt.sprint()), UVM_LOW)

        if(pkt.operation == WRITE) begin
            act_cdma_wr_q.push_back(pkt);
            //match_cdma_wr();
        end
        else if(pkt.operation == READ) begin
            act_cdma_rd_q.push_back(pkt);
            //match_cdma_rd();
        end
    end
endtask : cdma_traffic

function void ss_scoreboard::match_cdma_wr();
    axi_base_sequence_item  exp;
    //cpu_seq_item            exp;
    master_seq_item         act;
    bit match_failed;

    while(exp_cdma_wr_q.size() && act_cdma_wr_q.size()) begin
        exp = exp_cdma_wr_q.pop_front();
        act = act_cdma_wr_q.pop_front();
        match_failed = 0;

        `uvm_info("SBD_CDMA_WR_TRACE", $sformatf("Starting comparison for [%s] CDMA Write: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.AWADDR, act.awaddr), UVM_LOW)

        if(exp.AWADDR !== act.awaddr) begin
            `uvm_error("SBD_CDMA_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.AWADDR, act.awaddr))
            match_failed = 1;
        end

        if(exp.WSTRB[0] !== act.wstrobe[0]) begin
            `uvm_info("SBD_CDMA_WR", $sformatf("[%s] WSTRB mismatch @0x%08h: exp=0x%0h act=0x%0h", exp.master_p.name(), exp.AWADDR, {>>{exp.WSTRB}}, {>>{act.wstrobe}}),UVM_LOW)
        end
        
        for(int i = 0; i < 4; i++) begin
            if(exp.WSTRB[0][i] && (exp.WDATA[0][8*i +: 8] !== act.wdata[0][8*i +: 8])) begin
                `uvm_error("SBD_CDMA_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h byte %0d: exp=0x%0h act=0x%0h\n--- Expected CPU Packet ---\n%s\n--- Actual CDMA Packet ---\n%s", exp.master_p.name(), exp.AWADDR, i, {>>{exp.WDATA[0][8*i +: 8]}}, {>>{act.wdata[8*i +: 8]}}, exp.sprint(), act.sprint()))
                match_failed = 1;
            end
        end

        if(!match_failed) begin
            `uvm_info("SBD_CDMA_WR_PASS", $sformatf("[%s] CDMA Write match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.AWADDR), UVM_LOW)
        end
    end
endfunction

function void ss_scoreboard::match_cdma_rd();
    axi_base_sequence_item    exp;
    //cpu_seq_item    exp;
    master_seq_item act;
    bit match_failed;

    while(exp_cdma_rd_q.size() && act_cdma_rd_q.size()) begin
        exp = exp_cdma_rd_q.pop_front();
        act = act_cdma_rd_q.pop_front();
        match_failed = 0;

        `uvm_info("SBD_CDMA_RD_TRACE", $sformatf("Starting comparison for [%s] CDMA Read: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.ARADDR, act.araddr), UVM_LOW)

        if(exp.ARADDR !== act.araddr) begin
            `uvm_error("SBD_CDMA_RD_ERR", $sformatf("[%s] ARADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.ARADDR, act.araddr))
            match_failed = 1;
        end

        if(exp.RDATA[0] !== act.rdata[0]) begin
            `uvm_error("SBD_CDMA_RD_ERR", $sformatf("[%s] DATA mismatch @0x%08h: CPU expected=0x%0h CDMA returned=0x%0h", exp.master_p.name(), exp.ARADDR, {>>{exp.RDATA}}, {>>{act.rdata}}))
            match_failed = 1;
        end

        if(!match_failed) begin
            `uvm_info("SBD_CDMA_RD_PASS", $sformatf("[%s] CDMA Read match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.ARADDR), UVM_LOW)
        end
    end
endfunction

task ss_scoreboard::intc_traffic();
    lite_intc_seq_item  pkt;

    forever begin
        intc_af.get(pkt);
        
        `uvm_info("SBD_INTC_ACT", $sformatf("Received packet from AXI INTC monitor:\n%s", pkt.sprint()), UVM_LOW)

        if(pkt.operation == WRITE) begin
            act_intc_wr_q.push_back(pkt);
            //match_intc_wr();
        end
        else if(pkt.operation == READ) begin
            act_intc_rd_q.push_back(pkt);
            //match_intc_rd();
        end
    end
endtask : intc_traffic

function void ss_scoreboard::match_intc_wr();
    axi_base_sequence_item      exp;
    lite_intc_seq_item          act;
    bit [ADDR_WIDTH-1:0] exp_addr;
    bit match_failed;

    while(exp_intc_wr_q.size() && act_intc_wr_q.size()) begin
        exp = exp_intc_wr_q.pop_front();
        act = act_intc_wr_q.pop_front();
        match_failed = 0;

        exp_addr = addr_is_local ? (exp.AWADDR - INTC_BASE) : exp.AWADDR;

        `uvm_info("SBD_INTC_WR_TRACE", $sformatf("Starting comparison for [%s] INTC Write: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.AWADDR, act.AWADDR), UVM_LOW)

        if(exp_addr !== act.AWADDR) begin
            `uvm_error("SBD_INTC_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp_addr, act.AWADDR))
            match_failed = 1;
        end

        if(exp.WSTRB[0]!== act.WSTRB) begin
            `uvm_error("SBD_INTC_WR_ERR", $sformatf("[%s] WSTRB mismatch @0x%08h: exp=0x%0h act=0x%0h", exp.master_p.name(), exp.AWADDR, {>>{exp.WSTRB}}, act.WSTRB))
            match_failed = 1;
        end
        
        for(int i = 0; i < 4; i++) begin
            if(exp.WSTRB[0][i] && (exp.WDATA[0][8*i +: 8] !== act.WDATA[8*i +: 8])) begin
                `uvm_error("SBD_INTC_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h byte %0d: exp=0x%02h act=0x%02h\n--- Expected Packet ---\n%s\n--- Actual Packet ---\n%s", exp.master_p.name(), exp.AWADDR, i, {>>{exp.WDATA[0][8*i +: 8]}}, act.WDATA[8*i +: 8], exp.sprint(), act.sprint()))
                match_failed = 1;
            end
        end

        if(!match_failed) begin
            `uvm_info("SBD_INTC_WR_PASS", $sformatf("[%s] INTC Write match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.AWADDR), UVM_LOW)
        end
    end
endfunction

function void ss_scoreboard::match_intc_rd();
    axi_base_sequence_item      exp;
    lite_intc_seq_item          act;
    bit [ADDR_WIDTH-1:0]        exp_addr;
    bit match_failed;

    while(exp_intc_rd_q.size() && act_intc_rd_q.size()) begin
        exp = exp_intc_rd_q.pop_front();
        act = act_intc_rd_q.pop_front();
        match_failed = 0;

        exp_addr = addr_is_local ? (exp.ARADDR - INTC_BASE) : exp.ARADDR;

        `uvm_info("SBD_INTC_RD_TRACE", $sformatf("Starting comparison for [%s] INTC Read: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.ARADDR, act.ARADDR), UVM_LOW)

        if(exp_addr !== act.ARADDR) begin
            `uvm_error("SBD_INTC_RD_ERR", $sformatf("[%s] ARADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp_addr, act.ARADDR))
            match_failed = 1;
        end

        if(exp.RDATA[0] !== act.RDATA) begin
            `uvm_error("SBD_INTC_RD_ERR", $sformatf("[%s] DATA mismatch @0x%08h: CPU expected=0x%08h INTC returned=0x%08h", exp.master_p.name(), exp.ARADDR, {>>{exp.RDATA}}, act.RDATA))
            match_failed = 1;
        end

        if(!match_failed) begin
            `uvm_info("SBD_INTC_RD_PASS", $sformatf("[%s] INTC Read match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.ARADDR), UVM_LOW)
        end
    end
endfunction

task ss_scoreboard::core_perif_traffic();
    core_perif_lite_seq_item pkt;

    forever begin
        core_perif_af.get(pkt);
        
        `uvm_info("SBD_CORE_ACT", $sformatf("Received packet from CORE_PERIF monitor:\n%s", pkt.sprint()), UVM_LOW)

        if(pkt.operation == WRITE) begin
            `uvm_info("SBD_CORE_ACT_W", $sformatf("Received WRITE packet from CORE_PERIF monitor:\n%s", pkt.sprint()), UVM_LOW)
            act_core_wr_q.push_back(pkt);
            //match_core_wr();
        end
        else if(pkt.operation == READ) begin
            `uvm_info("SBD_CORE_ACT_R", $sformatf("Received READ packet from CORE_PERIF monitor:\n%s", pkt.sprint()), UVM_LOW)
            act_core_rd_q.push_back(pkt);
            //match_core_rd();
        end
    end
endtask : core_perif_traffic

function void ss_scoreboard::match_core_wr();
    axi_base_sequence_item      exp;
    core_perif_lite_seq_item    act;
    bit [ADDR_WIDTH-1:0]        exp_addr;
    bit match_failed;

    while(exp_core_wr_q.size() && act_core_wr_q.size()) begin
        exp = exp_core_wr_q.pop_front();
        act = act_core_wr_q.pop_front();
        match_failed = 0;

        `uvm_info("SBD_CORE_WR_TRACE", $sformatf("Starting comparison for [%s] CORE_PERIF Write: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.AWADDR, act.AWADDR), UVM_LOW)

        if(exp.AWADDR !== act.AWADDR) begin
            `uvm_error("SBD_CORE_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.AWADDR, act.AWADDR))
            match_failed = 1;
        end

        if(exp.WSTRB[0] !== act.WSTRB) begin
            `uvm_error("SBD_CORE_WR_ERR", $sformatf("[%s] WSTRB mismatch @0x%08h: exp=0x%0h act=0x%0h", exp.master_p.name(), exp.AWADDR, {>>{exp.WSTRB}}, act.WSTRB))
            match_failed = 1;
        end
        
        for(int i = 0; i < 4; i++) begin
            if(exp.WSTRB[0][i] && (exp.WDATA[0][8*i +: 8] !== act.WDATA[8*i +: 8])) begin
                `uvm_error("SBD_CORE_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h byte %0d: exp=0x%02h act=0x%02h\n--- Expected Packet ---\n%s\n--- Actual Packet ---\n%s", 
                    exp.master_p.name(), exp.AWADDR, i, {>>{exp.WDATA[0][8*i +: 8]}}, act.WDATA[8*i +: 8], exp.sprint(), act.sprint()))
                match_failed = 1;
            end
        end

        if(!match_failed) begin
            `uvm_info("SBD_CORE_WR_PASS", $sformatf("[%s] CORE_PERIF Write match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.AWADDR), UVM_LOW)
        end
    end
endfunction

function void ss_scoreboard::match_core_rd();
    axi_base_sequence_item      exp;
    core_perif_lite_seq_item    act;
    bit [ADDR_WIDTH-1:0]        exp_addr;
    bit match_failed;

    while(exp_core_rd_q.size() && act_core_rd_q.size()) begin
        exp = exp_core_rd_q.pop_front();
        act = act_core_rd_q.pop_front();
        match_failed = 0;

        `uvm_info("SBD_CORE_RD_TRACE", $sformatf("Starting comparison for [%s] CORE_PERIF Read: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.ARADDR, act.ARADDR), UVM_LOW)

        if(exp.ARADDR !== act.ARADDR) begin
            `uvm_error("SBD_CORE_RD_ERR", $sformatf("[%s] ARADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.ARADDR, act.ARADDR))
            match_failed = 1;
        end

        if(exp.RDATA[0] !== act.RDATA) begin
            `uvm_error("SBD_CORE_RD_ERR", $sformatf("[%s] DATA mismatch @0x%08h: CPU expected=0x%08h CORE returned=0x%08h", exp.master_p.name(), exp.ARADDR, {>>{exp.RDATA}}, act.RDATA))
            match_failed = 1;
        end

        if(!match_failed) begin
            `uvm_info("SBD_CORE_RD_PASS", $sformatf("[%s] CORE_PERIF Read match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.ARADDR), UVM_LOW)
        end
    end
endfunction

function void ss_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SBD_BRAM_MATCH_REPORT", $sformatf("BRAM Writes : MATCHED = %0d | FAILED = %0d", bram_wr_match, bram_wr_mismatch), UVM_NONE)
    if (bram_wr_mismatch > 0) begin
        `uvm_error("SBD_BRAM_WR_ERR_REPORT", "Simulation FAILED due to Scoreboard mismatches.")
    end else begin
        `uvm_info("SBD_BRAM_WR_MATCH_REPORT", "Simulation PASSED without Scoreboard mismatches.", UVM_NONE)
    end
    if (bram_rd_mismatch > 0) begin
        `uvm_error("SBD_BRAM_RD_ERR_REPORT", "Simulation FAILED due to Scoreboard mismatches.")
    end else begin
        `uvm_info("SBD_BRAM_RD_MATCH_REPORT", "Simulation PASSED without Scoreboard mismatches.", UVM_NONE)
    end

    `uvm_info("SBD_LITE_MATCH_REPORT", $sformatf("LITE_MEM Writes : MATCHED = %0d | FAILED = %0d", lite_wr_match, lite_wr_mismatch), UVM_NONE)
    if (lite_wr_mismatch > 0) begin
        `uvm_error("SBD_LITE_MEM_WR_ERR_REPORT", "Simulation FAILED due to Scoreboard mismatches.")
    end else begin
        `uvm_info("SBD_LITE_MEM_WR_MATCH_REPORT", "Simulation PASSED without Scoreboard mismatches.", UVM_NONE)
    end
    if (lite_rd_mismatch > 0) begin
        `uvm_error("SBD_LITE_MEM_RD_ERR_REPORT", "Simulation FAILED due to Scoreboard mismatches.")
    end else begin
        `uvm_info("SBD_LITE_MEM_RD_MATCH_REPORT", "Simulation PASSED without Scoreboard mismatches.", UVM_NONE)
    end
endfunction
