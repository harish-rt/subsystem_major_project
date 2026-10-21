typedef struct {
    master_e             master_p;
    bit [ADDR_WIDTH-1:0] addr;
    int                  num_beats;
    
    bit [31:0]           wdata[];
    bit [3:0]            wstrb[];
    bit [31:0]           rdata[];
    bit [1:0]            rresp[];
} sbd_bram_exp_s;

class ss_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ss_scoreboard)
    `NEW_COMP

    cpu_seq_item            cpu_pkt;
    s04_seq_item            s04_pkt;
    bram_seq_item           bram_pkt;
    mem_seq_item            mem_pkt;
    master_seq_item         cdma_pkt;

    sb_config               sb_cfg;

    uvm_tlm_analysis_fifo #(cpu_seq_item)       master_af;
    uvm_tlm_analysis_fifo #(s04_seq_item)       s04_af;
    uvm_tlm_analysis_fifo #(bram_seq_item)      bram_af;
    uvm_tlm_analysis_fifo #(mem_seq_item)       mem_af;
    uvm_tlm_analysis_fifo #(master_seq_item)    cdma_af;
    uvm_tlm_analysis_fifo #(lite_intc_seq_item) intc_af;
    uvm_tlm_analysis_fifo #(core_perif_lite_seq_item) core_perif_af;

    sbd_bram_exp_s          exp_bram_wr_q[$];
    sbd_bram_exp_s          exp_bram_rd_q[$];

    axi_base_sequence_item  exp_lite_wr_q[$];
    axi_base_sequence_item  exp_lite_rd_q[$];

    bram_seq_item           act_bram_wr_q[$];
    bram_seq_item           act_bram_rd_q[$];

    mem_seq_item            act_lite_wr_q[$];
    mem_seq_item            act_lite_rd_q[$];

    axi_base_sequence_item  exp_cdma_wr_q[$];
    axi_base_sequence_item  exp_cdma_rd_q[$];

    master_seq_item         act_cdma_wr_q[$];
    master_seq_item         act_cdma_rd_q[$];

    axi_base_sequence_item  exp_intc_wr_q[$];
    axi_base_sequence_item  exp_intc_rd_q[$];

    lite_intc_seq_item      act_intc_wr_q[$];
    lite_intc_seq_item      act_intc_rd_q[$];

    // 0 = BRAM monitor reports the full system address
    // 1 = BRAM monitor reports a local offset (addr - BRAM_BASE)
    bit                     addr_is_local = 1;
    
    extern function void    build_phase(uvm_phase phase);
    extern task             main_phase(uvm_phase phase);
    
    extern task             master_traffic();
    extern task             s04_traffic();

    extern task             bram_traffic();
    extern function void    match_bram_wr();
    extern function void    match_bram_rd();

    extern task             mem_traffic();
    extern function void    match_lite_wr();
    extern function void    match_lite_rd();

    extern task             cdma_traffic();
    extern function void    match_cdma_wr();
    extern function void    match_cdma_rd();

    extern task             intc_traffic();
    extern function void    match_intc_wr();
    extern function void    match_intc_rd();

endclass

function void ss_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db #(sb_config)::get(this,"","SB_CFG",sb_cfg))
        `uvm_fatal("SS_SBD_ERR","Failed to get sb_cfg!")
    master_af       = new("master_af",this);
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
    join
endtask

task ss_scoreboard::master_traffic();
    //axi_base_sequence_item    pkt;
    cpu_seq_item    pkt;
    sbd_bram_exp_s  exp;
    slave_t         dec_slave;

    forever begin
        master_af.get(pkt);

        if(pkt.master_p != MST_S00)
            `uvm_error("SBD_MASTER",$sformatf("master_af packet stamped %s, expected MST_S00",pkt.master_p.name()))

        if(pkt.operation == WRITE) begin
            if(!sb_cfg.decode_slave(pkt.AWADDR, dec_slave)) begin
                if(pkt.BRESP !== 2'b11)
                    `uvm_error("SBD_DECERR",$sformatf("CPU Write to unmapped addr 0x%08h: BRESP=%0b, expected DECERR",pkt.AWADDR,pkt.BRESP))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        `uvm_info("SBD_CPU_BRAM_W", $sformatf("[%s] -> BRAM Write: Addr=0x%08h Data: %0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp.master_p  = master_e'(pkt.master_p); // MST_S00
                        exp.addr      = pkt.AWADDR;
                        exp.num_beats = 1;
                        exp.wdata     = new[1];
                        exp.wstrb     = new[1];
                        exp.wdata[0]  = pkt.WDATA[0];    // Scalar to Array index 0
                        exp.wstrb[0]  = pkt.WSTRB[0];
                        exp_bram_wr_q.push_back(exp);
                        match_bram_wr();   // write case
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_CPU_MEM_W",$sformatf("CPU -> LITE_MEM Write: Addr=0x%08h Data=0x%0h Strb=0x%0h",pkt.AWADDR,{>>{pkt.WDATA}},{>>{pkt.WSTRB}}),UVM_LOW)
                        exp_lite_wr_q.push_back(pkt);
                    end
                    CDMA: begin
                        `uvm_info("SBD_MST_CDMA_W", $sformatf("[%s] -> CDMA Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_cdma_wr_q.push_back(pkt); // For s04_traffic, push pkt_c
                    end
                    INTC: begin
                        `uvm_info("SBD_MST_INTC_W", $sformatf("[%s] -> INTC Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_intc_wr_q.push_back(pkt);
                    end
                    default: `uvm_info("SS_SBD","No Slave Selected",UVM_LOW)
                endcase
            end
        end
        else if(pkt.operation == READ) begin
            //`uvm_info("SBD_CPU_READ", $sformatf("[%s] ARADDR @0x%08h\n--- Expected CPU Packet ---\n%s", pkt.master_p.name(), pkt.ARADDR, pkt.sprint()),UVM_LOW)
            if(!sb_cfg.decode_slave(pkt.ARADDR, dec_slave)) begin
                if(pkt.RRESP[0] !== 2'b11)
                    `uvm_error("SBD_DECERR",$sformatf("CPU Read from unmapped addr 0x%08h: RRESP=%0h, expected DECERR",pkt.ARADDR,{>>{pkt.RRESP}}))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        `uvm_info("SBD_CPU_BRAM_R", $sformatf("[%s] -> BRAM Read: Addr=0x%08h Data: %0h", pkt.master_p.name(), pkt.ARADDR, {>>{pkt.RDATA}}), UVM_LOW)
                        exp.master_p  = master_e'(pkt.master_p); // MST_S00
                        exp.addr      = pkt.ARADDR;
                        exp.num_beats = 1;
                        exp.rdata     = new[1];
                        exp.rdata[0]  = pkt.RDATA[0];
                        exp_bram_rd_q.push_back(exp);
                        match_bram_rd();   // read case
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_CPU_MEM_R",$sformatf("LITE_MEM -> CPU Read: Addr=0x%08h Data=0x%0h",pkt.ARADDR,{>>{pkt.RDATA}}),UVM_LOW)
                        exp_lite_rd_q.push_back(pkt);
                    end
                    CDMA: begin
                        `uvm_info("SBD_MST_CDMA_R", $sformatf("[%s] -> CDMA Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                        exp_cdma_rd_q.push_back(pkt); // For s04_traffic, push pkt_c
                    end
                    INTC: begin
                        `uvm_info("SBD_MST_INTC_R", $sformatf("[%s] -> INTC Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                        exp_intc_rd_q.push_back(pkt);
                    end
                    default: `uvm_info("SS_SBD","No Slave Selected",UVM_LOW)
                endcase
            end
        end
    end
endtask : master_traffic

task ss_scoreboard::s04_traffic();
    //axi_base_sequence_item   pkt;
    //axi_base_sequence_item   pkt_c;
    s04_seq_item   pkt;
    slave_t        dec_slave;

    forever begin
        s04_af.get(pkt);

        if(pkt.master_p != MST_S04)
            `uvm_error("SBD_MASTER",$sformatf("s04_af packet stamped %s, expected MST_S04",pkt.master_p.name()))

        if(pkt.operation == WRITE) begin
            if(!sb_cfg.decode_slave(pkt.AWADDR, dec_slave)) begin
                if(pkt.BRESP !== 2'b11)
                    `uvm_error("SBD_DECERR",$sformatf("[%s] Write to unmapped addr 0x%08h: BRESP=%0b, expected DECERR", pkt.master_p.name(), pkt.AWADDR, pkt.BRESP))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        sbd_bram_exp_s exp;
                        `uvm_info("SBD_S04_BRAM_W", $sformatf("[%s] -> BRAM Write: Addr=0x%08h Len=%0d Data: %0h", pkt.master_p.name(), pkt.AWADDR, pkt.AWLEN, {>>{pkt.WDATA}}), UVM_LOW)
                        
                        // Translate AXI4 to Normalized BRAM Struct
                        exp.master_p  = master_e'(pkt.master_p); // MST_S04
                        exp.addr      = pkt.AWADDR;
                        exp.num_beats = pkt.AWLEN + 1;
                        exp.wdata     = new[exp.num_beats];
                        exp.wstrb     = new[exp.num_beats];
                        
                        foreach(pkt.WDATA[i]) begin
                            exp.wdata[i] = pkt.WDATA[i];
                            exp.wstrb[i] = pkt.WSTRB[i];
                        end
                        
                        exp_bram_wr_q.push_back(exp);
                        match_bram_wr();
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_S04_MEM_W",$sformatf("[%s] -> LITE_MEM Write: Addr=0x%08h Data: %0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_lite_wr_q.push_back(pkt);
                    end
                    CDMA: begin
                        `uvm_info("SBD_MST_CDMA_W", $sformatf("[%s] -> CDMA Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_cdma_wr_q.push_back(pkt); // s04_traffic push pkt_c
                    end
                    INTC: begin
                        `uvm_info("SBD_MST_INTC_W", $sformatf("[%s] -> INTC Write: Addr=0x%08h Data=0x%0h", pkt.master_p.name(), pkt.AWADDR, {>>{pkt.WDATA}}), UVM_LOW)
                        exp_intc_wr_q.push_back(pkt);
                    end
                    default: `uvm_info("SS_SBD","No Slave Selected", UVM_LOW)
                endcase
            end
        end
        else if(pkt.operation == READ) begin
            if(!sb_cfg.decode_slave(pkt.ARADDR, dec_slave)) begin
                // Check the first beat's response for DECERR
                if(pkt.RRESP[0] !== 2'b11) 
                    `uvm_error("SBD_DECERR",$sformatf("[%s] Read from unmapped addr 0x%08h: expected DECERR", pkt.master_p.name(), pkt.ARADDR))
            end
            else begin
                case (dec_slave)
                    BRAM: begin
                        sbd_bram_exp_s exp;
                        `uvm_info("SBD_S04_BRAM_R", $sformatf("[%s] -> BRAM Read: Addr=0x%08h Len=%0d Data: %0h", pkt.master_p.name(), pkt.ARADDR, pkt.ARLEN, {>>{pkt.RDATA}}), UVM_LOW)
                        
                        // Translate AXI4 to Normalized BRAM Struct
                        exp.master_p  = master_e'(pkt.master_p); // MST_S04
                        exp.addr      = pkt.ARADDR;
                        exp.num_beats = pkt.ARLEN + 1;
                        exp.rdata     = new[exp.num_beats];
                        exp.rresp     = new[exp.num_beats];
                        
                        foreach(pkt.RDATA[i]) begin
                            exp.rdata[i] = pkt.RDATA[i];
                            exp.rresp[i] = pkt.RRESP[i];
                        end
                        
                        exp_bram_rd_q.push_back(exp);
                        match_bram_rd();
                    end
                    LITE_MEM: begin
                        `uvm_info("SBD_S04_MEM_R",$sformatf("[%s] -> LITE_MEM Read: Addr=0x%08h Data: %0h", pkt.master_p.name(), pkt.ARADDR, {>>{pkt.RDATA}}), UVM_LOW)
                        exp_lite_rd_q.push_back(pkt);
                    end
                    CDMA: begin
                        `uvm_info("SBD_MST_CDMA_R", $sformatf("[%s] -> CDMA Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                        exp_cdma_rd_q.push_back(pkt); // s04_traffic push pkt
                    end
                    INTC: begin
                        `uvm_info("SBD_MST_INTC_R", $sformatf("[%s] -> INTC Read: Addr=0x%08h", pkt.master_p.name(), pkt.ARADDR), UVM_LOW)
                        exp_intc_rd_q.push_back(pkt);
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
            `uvm_info("SBD_BRAM_ACT_W",$sformatf("BRAM saw Write: Addr=0x%08h Data=0x%0h Strb=0x%0h",pkt.AWADDR,{>>{pkt.WDATA}},{>>{pkt.WSTRB}}),UVM_LOW)
            act_bram_wr_q.push_back(pkt);
            match_bram_wr();
        end
        else if(pkt.operation == READ) begin
            `uvm_info("SBD_BRAM_ACT_R",$sformatf("BRAM saw Read: Addr=0x%08h Data=0x%0h",pkt.ARADDR,{>>{pkt.RDATA}}),UVM_LOW)
            act_bram_rd_q.push_back(pkt);
            match_bram_rd();
        end
    end
endtask

function void ss_scoreboard::match_bram_wr();
    sbd_bram_exp_s  exp;
    bram_seq_item   act;
    bit [ADDR_WIDTH-1:0] exp_addr;
    int iter_beats;

    while(exp_bram_wr_q.size() && act_bram_wr_q.size()) begin
        exp = exp_bram_wr_q.pop_front();
        act = act_bram_wr_q.pop_front();
        
        exp_addr = addr_is_local ? (exp.addr - BRAM_BASE) : exp.addr;

        if(exp_addr !== act.AWADDR)
            `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp_addr, act.AWADDR))
        
        if(exp.num_beats !== act.WDATA.size()) begin
            `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] Burst Length mismatch @0x%08h! expected %0d beats, monitor saw %0d beats", exp.master_p.name(), exp_addr, exp.num_beats, act.WDATA.size()))
        end

        iter_beats = (exp.num_beats < act.WDATA.size()) ? exp.num_beats : act.WDATA.size();

        for(int b = 0; b < iter_beats; b++) begin
            if(exp.wstrb[b] !== act.WSTRB[b])
                `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] WSTRB mismatch @0x%08h beat %0d: exp=0x%0h act=0x%0h", exp.master_p.name(), exp_addr, b, exp.wstrb[b], act.WSTRB[b]))
            
            for(int i = 0; i < 4; i++) begin
                if(exp.wstrb[b][i] && (exp.wdata[b][8*i +: 8] !== act.WDATA[b][8*i +: 8]))
                    `uvm_error("SBD_BRAM_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h beat %0d byte %0d: exp=0x%02h act=0x%02h", exp.master_p.name(), exp_addr, b, i, exp.wdata[b][8*i +: 8], act.WDATA[b][8*i +: 8]))
            end
        end
    end
endfunction

function void ss_scoreboard::match_bram_rd();
    sbd_bram_exp_s  exp;
    bram_seq_item   act;
    bit [ADDR_WIDTH-1:0] exp_addr;
    int iter_beats;

    while(exp_bram_rd_q.size() && act_bram_rd_q.size()) begin
        exp = exp_bram_rd_q.pop_front();
        act = act_bram_rd_q.pop_front();
        
        exp_addr = addr_is_local ? (exp.addr - BRAM_BASE) : exp.addr;

        if(exp_addr !== act.ARADDR)
            `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] ARADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp_addr, act.ARADDR))
        
        if(exp.num_beats !== act.RDATA.size()) begin
            `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] Burst Length mismatch @0x%08h! expected %0d beats, returned %0d beats", exp.master_p.name(), exp_addr, exp.num_beats, act.RDATA.size()))
        end

        iter_beats = (exp.num_beats < act.RDATA.size()) ? exp.num_beats : act.RDATA.size();

        for(int b = 0; b < iter_beats; b++) begin
            if(exp.rdata[b] !== act.RDATA[b])
                `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] DATA mismatch @0x%08h beat %0d: CPU saw=0x%08h BRAM returned=0x%08h", exp.master_p.name(), exp_addr, b, exp.rdata[b], act.RDATA[b]))
            
            if(exp.rresp[b] !== act.RRESP[b])
                `uvm_error("SBD_BRAM_RD_ERR", $sformatf("[%s] RRESP mismatch @0x%08h beat %0d: exp=0x%0h act=0x%0h", exp.master_p.name(), exp_addr, b, exp.rresp[b], act.RRESP[b]))
        end
    end
endfunction

task ss_scoreboard::mem_traffic();
    mem_seq_item    pkt;
    forever begin
        mem_af.get(pkt);
        
        `uvm_info("SBD_LITE_MEM_ACT", $sformatf("Received packet from LITE_MEM monitor:\n%s", pkt.sprint()), UVM_LOW)

        if(pkt.operation == WRITE) begin
            act_lite_wr_q.push_back(pkt);
            match_lite_wr();
        end
        else if(pkt.operation == READ) begin
            act_lite_rd_q.push_back(pkt);
            match_lite_rd();
        end
    end
endtask : mem_traffic

function void ss_scoreboard::match_lite_wr();
    axi_base_sequence_item    exp;
    //cpu_seq_item    exp;
    mem_seq_item    act;
    bit [ADDR_WIDTH-1:0] exp_addr;
    bit match_failed;

    while(exp_lite_wr_q.size() && act_lite_wr_q.size()) begin
        exp = exp_lite_wr_q.pop_front();
        act = act_lite_wr_q.pop_front();
        match_failed = 0;
        
        `uvm_info("SBD_LITE_WR_TRACE", $sformatf("Starting comparison for [%s] LITE_MEM Write: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.AWADDR, act.awaddr), UVM_HIGH)

        if(exp.AWADDR !== act.awaddr) begin
            `uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.AWADDR, act.awaddr))
            match_failed = 1;
        end

        if(exp.WSTRB[0] !== act.wstrb) begin
            `uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] WSTRB mismatch @0x%08h: exp=0x%0h act=0x%0h\n--- Expected CPU Packet ---\n%s\n--- Actual MEM Packet ---\n%s", exp.master_p.name(), exp.AWADDR, {>>{exp.WSTRB}}, act.wstrb, exp.sprint(), act.sprint()))
            //`uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] WSTRB mismatch @0x%08h: exp=0x%0h act=0x%0h", exp.master_p.name(), exp.AWADDR, exp.WSTRB, act.wstrb))
            match_failed = 1;
        end
        
        for(int i = 0; i < 4; i++) begin
            if(exp.WSTRB[0][i] && (exp.WDATA[0][8*i +: 8] !== act.wdata[8*i +: 8])) begin
                `uvm_error("SBD_LITE_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h byte %0d: exp=0x%0h act=0x%02h", exp.master_p.name(), exp.AWADDR, i, {>>{exp.WDATA[8*i +: 8]}}, act.wdata[8*i +: 8]))
                match_failed = 1;
            end
        end

        if(!match_failed) begin
            `uvm_info("SBD_LITE_WR_PASS", $sformatf("[%s] LITE_MEM Write match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.AWADDR), UVM_LOW)
        end
    end
endfunction

function void ss_scoreboard::match_lite_rd();
    axi_base_sequence_item exp;
    //cpu_seq_item exp;
    mem_seq_item act;
    bit [ADDR_WIDTH-1:0] exp_addr;
    bit match_failed;

    while(exp_lite_rd_q.size() && act_lite_rd_q.size()) begin
        exp = exp_lite_rd_q.pop_front();
        act = act_lite_rd_q.pop_front();
        match_failed = 0;

        `uvm_info("SBD_LITE_RD_TRACE", $sformatf("Starting comparison for [%s] LITE_MEM Read: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.ARADDR, act.araddr), UVM_HIGH)

        if(exp.ARADDR !== act.araddr) begin
            `uvm_error("SBD_LITE_RD_ERR", $sformatf("[%s] ARADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.ARADDR, act.araddr))
            match_failed = 1;
        end

        if(exp.RDATA[0] !== act.rdata) begin
            `uvm_error("SBD_LITE_RD_ERR", $sformatf("[%s] DATA mismatch @0x%08h: exp=0x%0h act=0x%08h", exp.master_p.name(), exp.ARADDR, {>>{exp.RDATA}}, act.rdata))
            match_failed = 1;
        end

        if(!match_failed) begin
            `uvm_info("SBD_LITE_RD_PASS", $sformatf("[%s] LITE_MEM Read match SUCCESS at Addr=0x%08h", exp.master_p.name(), exp.ARADDR), UVM_LOW)
        end
    end
endfunction

task ss_scoreboard::cdma_traffic();
    master_seq_item pkt;
    forever begin
        cdma_af.get(pkt);
        
        `uvm_info("SBD_CDMA_ACT", $sformatf("Received packet from CDMA register monitor:\n%s", pkt.sprint()), UVM_HIGH)

        if(pkt.operation == WRITE) begin
            act_cdma_wr_q.push_back(pkt);
            match_cdma_wr();
        end
        else if(pkt.operation == READ) begin
            act_cdma_rd_q.push_back(pkt);
            match_cdma_rd();
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

        `uvm_info("SBD_CDMA_WR_TRACE", $sformatf("Starting comparison for [%s] CDMA Write: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.AWADDR, act.awaddr), UVM_HIGH)

        if(exp.AWADDR !== act.awaddr) begin
            `uvm_error("SBD_CDMA_WR_ERR", $sformatf("[%s] AWADDR mismatch exp=0x%08h act=0x%08h", exp.master_p.name(), exp.AWADDR, act.awaddr))
            match_failed = 1;
        end

        if(exp.WSTRB[0] !== act.wstrobe[0]) begin
            `uvm_info("SBD_CDMA_WR", $sformatf("[%s] WSTRB mismatch @0x%08h: exp=0x%0h act=0x%0h", exp.master_p.name(), exp.AWADDR, {>>{exp.WSTRB}}, {>>{act.wstrobe}}),UVM_LOW)
        end
        
        for(int i = 0; i < 4; i++) begin
            if(exp.WSTRB[0][i] && (exp.WDATA[0][8*i +: 8] !== act.wdata[0][8*i +: 8])) begin
                `uvm_error("SBD_CDMA_WR_ERR", $sformatf("[%s] DATA mismatch @0x%08h byte %0d: exp=0x%0h act=0x%0h\n--- Expected CPU Packet ---\n%s\n--- Actual CDMA Packet ---\n%s", exp.master_p.name(), exp.AWADDR, i, {>>{exp.WDATA[8*i +: 8]}}, {>>{act.wdata[8*i +: 8]}}, exp.sprint(), act.sprint()))
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

        `uvm_info("SBD_CDMA_RD_TRACE", $sformatf("Starting comparison for [%s] CDMA Read: Exp Addr=0x%08h, Act Addr=0x%08h", exp.master_p.name(), exp.ARADDR, act.araddr), UVM_HIGH)

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
        
        `uvm_info("SBD_INTC_ACT", $sformatf("Received packet from AXI INTC monitor:\n%s", pkt.sprint()), UVM_HIGH)

        if(pkt.operation == WRITE) begin
            act_intc_wr_q.push_back(pkt);
            match_intc_wr();
        end
        else if(pkt.operation == READ) begin
            act_intc_rd_q.push_back(pkt);
            match_intc_rd();
        end
    end
endtask : intc_traffic

function void ss_scoreboard::match_intc_wr();
    
endfunction
function void ss_scoreboard::match_intc_rd();
endfunction
