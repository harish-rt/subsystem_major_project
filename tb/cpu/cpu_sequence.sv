class base_cpu_sequence extends uvm_sequence#(cpu_seq_item);
    `uvm_object_utils(base_cpu_sequence)
    `NEW_OBJ
    
    uvm_phase           phase;
    //cdma_reg_block    reg_block;
    uvm_status_e        status;
    uvm_reg_data_t      tdata;
    cpu_seq_item        pkt,w_pkt,r_pkt;

    bit [31:0]          reg_data;
    bit [31:0]          isr_data;
    bit [31:0]          ipr_data;
    bit [31:0]          iar_data;
    bit [31:0]          cdmacr_data;
    bit [31:0]          cdmasr_data;
    bit [31:0]          sa_data;
    bit [31:0]          da_data;
    bit [31:0]          btt_data;

    task pre_body();
        phase   =   get_starting_phase();
        if(phase != null) begin
            phase.raise_objection(this);
            `uvm_info(get_full_name(),"inside_pre_body", UVM_LOW)
        end
    endtask
    
    task post_body();
        if(phase != null) begin
            `uvm_info(get_full_name(),"inside_post_body", UVM_LOW)
            phase.drop_objection(this);
        end
    endtask

    task body ();
        `uvm_info(get_full_name(),"inside base_cpu_sequence body", UVM_LOW)

        pkt = cpu_seq_item::type_id::create("pkt");
    endtask

    task write_reg(input bit [31:0]reg_addr, input bit [31:0]data);
        w_pkt   = cpu_seq_item::type_id::create("w_pkt");
        start_item(w_pkt);
        if(!w_pkt.randomize() with {
            AWADDR      == reg_addr;
            WDATA       == data;
            WSTRB       == 'hf;
            operation   == WRITE;
        })begin
            `uvm_fatal("REG_ACCESS", "write_reg randomization failed!")        
        end
        finish_item(w_pkt);
        get_response(w_pkt);
    endtask

    task read_reg(input bit [31:0]reg_addr, output bit [31:0]data);
        r_pkt   = cpu_seq_item::type_id::create("r_pkt");
        start_item(r_pkt);
        if(!r_pkt.randomize() with {
            ARADDR      == reg_addr;
            operation   == READ;
        })begin
            `uvm_fatal("REG_ACCESS", "read_reg randomization failed!")        
        end
        finish_item(r_pkt);
        get_response(r_pkt);
        data            = r_pkt.RDATA;
    endtask
endclass : base_cpu_sequence


class read_cdma_seq extends base_cpu_sequence;
    `uvm_object_utils(read_cdma_seq)
    `NEW_OBJ
    
    int addr;

    task body();
        super.body();
        `uvm_info("read_cdma_seq", "Start of Config CDMA Sequence", UVM_LOW)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        for (int i = 0; i < 11; i++) begin        
            addr = CDMA_BASE + (i*4);
            //addr = 'h7000_0000 + (i*4);
            start_item(pkt);
            if(!pkt.randomize() with {
                ARADDR  == addr;
                operation   == READ;
                })begin
                `uvm_error(get_full_name(), "randomization_failed")
            end
            finish_item(pkt);
            get_response(pkt);             
        end
        `uvm_info("read_cdma_seq", "End of Config CDMA Sequence", UVM_LOW)
    endtask

endclass : read_cdma_seq




class config_cdma_ral_seq extends base_cpu_sequence;
    `uvm_object_utils(config_cdma_ral_seq)
    `NEW_OBJ
    
    task body();
        super.body();
        `uvm_info("config_cdma_seq", "Start of Config CDMA RAL Sequence", UVM_LOW)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        //reg_block.cdmacr.read(status,tdata);
        `uvm_info("config_cdma_seq", "End of Config CDMA Sequence", UVM_LOW)
    endtask

endclass : config_cdma_ral_seq


class read_bram_seq extends base_cpu_sequence;
    `uvm_object_utils(read_bram_seq)
    `NEW_OBJ
    
    int addr;

    task body();
        super.body();
        `uvm_info("read_bram_seq", "Start of Read BRAM Sequence", UVM_LOW)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        for (int i = 0; i < 4; i++) begin        
            addr = 'h7100_0000 + (i*4);
            start_item(pkt);
            if(!pkt.randomize() with {
                ARADDR  == addr;
                operation   == READ;
                })begin
                `uvm_error(get_full_name(), "randomization_failed")
            end
            finish_item(pkt);
            get_response(pkt);             
        end
        `uvm_info("read_bram_seq", "End of Read BRAM Sequence", UVM_LOW)
    endtask

endclass : read_bram_seq


class load_bram_seq extends base_cpu_sequence;
    `uvm_object_utils(load_bram_seq)
    `NEW_OBJ

    task body();
        super.body();
        for(int i=0;i<8;i=i+4)begin
            start_item(pkt);
            if(!pkt.randomize() with {
                AWADDR  == 'h7100_0000 + i;
                WSTRB   == 'hf;
                operation   == WRITE;
                })begin
                `uvm_error(get_full_name(), "randomization_failed")
            end
            finish_item(pkt);
            get_response(pkt);             
        end
    endtask
endclass : load_bram_seq


class config_intc_seq extends base_cpu_sequence;
    `uvm_object_utils(config_intc_seq)
    `NEW_OBJ

    bit [31:0]intc_d;

    task body();
        super.body();
        
        intc_d      = 0;
        intc_d[26]  = 1; //CDMA
        intc_d[27]  = 0; //Peripherals

        start_item(pkt);
        if(!pkt.randomize() with {
            AWADDR  == 'h7000_1008; //Interrupt Enable Register
            WDATA   == intc_d;
            WSTRB   == 'hf;
            operation   == WRITE;
            })begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        get_response(pkt);

        intc_d      = 0;
        intc_d[0]   = 1;  //Master Irq en
        intc_d[1]   = 1;  //Hardware Interrupt en

        start_item(pkt);
        if(!pkt.randomize() with {
            AWADDR  == 'h7000_101c; //Master Enable Register
            WDATA   == intc_d;
            WSTRB   == 'hf;
            operation   == WRITE;
            })begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        get_response(pkt);
    endtask
endclass : config_intc_seq


class config_cdma_seq extends base_cpu_sequence;
    `uvm_object_utils(config_cdma_seq)
    `NEW_OBJ
    
    task body();
        super.body();
        `uvm_info("config_cdma_seq", "Start of Config CDMA Sequence", UVM_LOW)


        do begin
            //reg_block.cdmasr.read(status,tdata);
        end while(tdata[1]==1);
        
        //reg_block.cdmacr.operation(status,'h5000);
        //reg_block.sa.operation(status,'h7100_0000);
        //reg_block.da.operation(status,'h8000_0000);
        //reg_block.btt.operation(status,1);

        /*
        start_item(pkt);
        if(!pkt.randomize() with {
            AWADDR  == cdmacr;
            })begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        get_response(pkt);*/
        `uvm_info("config_cdma_seq", "End of Config CDMA Sequence", UVM_LOW)
    endtask

endclass : config_cdma_seq


class load_mem_seq extends base_cpu_sequence;
    `uvm_object_utils(load_mem_seq)
    `NEW_OBJ
    
    int addr;

    task body();
        super.body();
    
        do begin
            start_item(pkt);
            if (!pkt.randomize() with {
                ARADDR    == 32'h7000_0004;
                operation == READ;
            }) begin
                `uvm_error(get_full_name(), "randomization_failed")
            end
            finish_item(pkt);
            get_response(pkt);
        end while (pkt.RDATA[1] == 0);

        `uvm_do_with(pkt, {
            AWADDR    == CDMA_BASE;
            operation == WRITE;
            WDATA     == 32'h5000;
        })

        `uvm_do_with(pkt, {
            AWADDR    == CDMA_BASE + 18; 
            operation == WRITE;
            WDATA     == 32'h7100_0000;
        })
        
        `uvm_do_with(pkt, {
            AWADDR    == 32'h7000_0020;
            operation == WRITE;
            WDATA     == 32'h8000_0000;
        })
              
       `uvm_do_with(pkt, {
            AWADDR    == 32'h7000_0028;
            operation == WRITE;
            WDATA     == 32'h8;
        })
        
        for(int i=0;i<8;i=i+4)begin
            `uvm_do_with(pkt, {
                ARADDR    == 32'h8000_0000 + i;
                operation == READ;
            })
        end
        
    endtask

endclass:cdma_read_write_seq

class cpu_config_intc_seq extends base_cpu_sequence;
    `uvm_object_utils(cpu_config_intc_seq)
    `NEW_OBJ

    task body();
        super.body();
        reg_data        = 0;
        reg_data[26]    = 1;
        reg_data[27]    = 0;
        write_reg(INTC_BASE + 'h8, reg_data);     //IER
        reg_data        = 0;
        reg_data[0]     = 1;
        reg_data[1]     = 1;
        write_reg(INTC_BASE + 'h1c, reg_data);    //MER
    endtask
endclass : cpu_config_intc_seq

class cpu_isr_seq extends base_cpu_sequence;
    `uvm_object_utils(cpu_isr_seq)
    `NEW_OBJ

    int loop_count = 0;

    task body();
        super.body();

        do begin
            read_reg(INTC_BASE + 'h4, ipr_data);
            
            if (ipr_data == 0) break; 

            if (ipr_data[26]) handle_cdma_isr();
            if (ipr_data[27]) handle_core_perif_isr();
            
            loop_count++;
            if (loop_count > 10) begin
                `uvm_error("cpu_isr_seq", "Interrupt loop timeout! IPR stuck high.")
                break;
            end
            
        end while (ipr_data != 0);

        `uvm_info("cpu_isr_seq", "All pending interrupts successfully cleared", UVM_LOW)
    endtask

    task handle_cdma_isr();
        read_reg(CDMA_BASE + 'h4, cdmasr_data);
        
        if (cdmasr_data[12]) begin
            `uvm_info("cpu_isr_seq", "CDMA IOC Asserted", UVM_LOW)
            write_reg(CDMA_BASE + 'h4, (1 << 12));    
        end 
        else if (cdmasr_data[14]) begin
            `uvm_warning("cpu_isr_seq", "CDMA ERR Asserted")
            read_reg(CDMA_BASE + 'h0, cdmacr_data);
            cdmacr_data[4] = 1'b1; 
            write_reg(CDMA_BASE + 'h0, cdmacr_data);
        end
        
        write_reg(INTC_BASE + 'hc, (1 << 26));
    endtask

    task handle_core_perif_isr();
        write_reg(INTC_BASE + 'hc, (1 << 27));
    endtask

endclass : cpu_isr_seq

class cdma_config_seq extends base_cpu_sequence;
    `uvm_object_utils(cdma_config_seq)
    `NEW_OBJ

    task body();
        super.body();
        cdmacr_data = 'h5000;
        sa_data     = 'h7100_0000;
        da_data     = 'h8000_0000;
        btt_data    = 'h8;

        do begin
            read_reg(CDMA_BASE + 'h4,cdmasr_data);
        end while(cdmasr_data[1]==1);
        `uvm_info("cdma_config_seq","idle cleared",UVM_LOW)
        write_reg(CDMA_BASE + 'h0,cdmacr_data);
        write_reg(CDMA_BASE + 'h18,sa_data);
        write_reg(CDMA_BASE + 'h20,da_data);
        write_reg(CDMA_BASE + 'h28,btt_data);
        `uvm_info("cdma_config_seq","btt written",UVM_LOW)
    endtask
endclass : cdma_config_seq
