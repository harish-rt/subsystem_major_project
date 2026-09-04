class base_cpu_sequence extends uvm_sequence#(cpu_seq_item);
    `uvm_object_utils(base_cpu_sequence)
    `NEW_OBJ
    
    uvm_phase           phase;
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

    task write_reg(input bit [31:0]reg_addr, input bit [31:0]data=0);
        w_pkt   = cpu_seq_item::type_id::create("w_pkt");
        start_item(w_pkt);
        if(!w_pkt.randomize() with {
            AWADDR      == reg_addr;
            if(data != 0) {
                WDATA   == data;
            }
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

// READ REGISTER DEFAULT VALUES
class intc_reg_read_seq extends base_cpu_sequence;
    `uvm_object_utils(intc_reg_read_seq)
    `NEW_OBJ
    
    task body();
        super.body();
        `uvm_info("intc_reg_read_seq", "Start of INTC Read Reg Sequence", UVM_LOW)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        for (int i = 0; i < 10; i++) begin        
            read_reg(INTC_BASE + (i*4),reg_data);
        end
        `uvm_info("intc_reg_read_seq", "End of INTC Read Reg Sequence", UVM_LOW)
    endtask

endclass : intc_reg_read_seq


class cdma_reg_read_seq extends base_cpu_sequence;
    `uvm_object_utils(cdma_reg_read_seq)
    `NEW_OBJ
    
    task body();
        super.body();
        `uvm_info("cdma_reg_read_seq", "Start of CDMA Read Reg Sequence", UVM_LOW)

        for (int i = 0; i < 11; i++) begin        
            read_reg(CDMA_BASE + (i*4),reg_data);
        end
        `uvm_info("cdma_reg_read_seq", "End of CDMA Read Reg Sequence", UVM_LOW)
    endtask

endclass : cdma_reg_read_seq

// WRITE READ REGISTERS

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


class read_bram_seq extends base_cpu_sequence;
    `uvm_object_utils(read_bram_seq)
    `NEW_OBJ
    
    task body();
        super.body();
        `uvm_info("read_bram_seq", "Start of Read BRAM Sequence", UVM_LOW)

        for (int i = 0; i < 8; i=i+4)begin
            start_item(pkt);
            if(!pkt.randomize() with {
                ARADDR  == 'h7100_0000 + i;
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


class cdma_read_write_seq extends base_cpu_sequence;
    `uvm_object_utils(cdma_read_write_seq)
    `NEW_OBJ
    
    task body();
        super.body();
    
        do begin
            start_item(pkt);
            if (!pkt.randomize() with {
                ARADDR    == CDMA_BASE + 'h4;
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
            AWADDR    == CDMA_BASE + 'h18; 
            operation == WRITE;
            WDATA     == 32'h7100_0000;
        })
        
        `uvm_do_with(pkt, {
            AWADDR    == CDMA_BASE + 'h20;
            operation == WRITE;
            WDATA     == 32'h8000_0000;
        })
              
       `uvm_do_with(pkt, {
            AWADDR    == CDMA_BASE + 'h28;
            operation == WRITE;
            WDATA     == 32'h8;
        })
        
        for(int i=0;i<8;i=i+4)begin
            `uvm_do_with(pkt, {
                ARADDR    == LITE_MEM_BASE + i;
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
        reg_data[26]    = 1;                    //CDMA
        reg_data[27]    = 0;                    //Core Peripheral
        write_reg(INTC_BASE + 'h8, reg_data);   //IER
        reg_data        = 0;
        reg_data[0]     = 1;                    //Master En
        reg_data[1]     = 1;                    //Hardware IRQ En
        write_reg(INTC_BASE + 'h1c, reg_data);  //MER
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
                `uvm_error("cpu_isr_seq", "Interrupt loop timeout! IPR stuck high")
                break;
            end
            
        end while (ipr_data != 0);

        `uvm_info("cpu_isr_seq", "All pending interrupts successfully cleared", UVM_LOW)
    endtask

    task handle_cdma_isr();
        read_reg(CDMA_BASE + 'h4, cdmasr_data);
        
        if (cdmasr_data[12]) begin
            `uvm_info("cpu_isr_seq", "CDMA IOC Asserted", UVM_LOW)
            write_reg(CDMA_BASE + 'h4, 'h1000); // W1C
        end 

        if (cdmasr_data[14]) begin
            `uvm_warning("cpu_isr_seq", "CDMA ERR Asserted")
            write_reg(CDMA_BASE + 'h0, 'h4);    // CDMA Reset
            do begin
                read_reg(CDMA_BASE + 'h4,cdmasr_data);
            end while(cdmasr_data[2] == 1);     // Confirms reset cleared
        end
        
        write_reg(INTC_BASE + 'hc, 'h400_0000);      // INTC ACK
    endtask

    task handle_core_perif_isr();
        write_reg(INTC_BASE + 'hc, 'h2000);      // INTC ACK
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
        end while(cdmasr_data[1]==0);
        `uvm_info("cdma_config_seq","idle cleared",UVM_LOW)
        write_reg(CDMA_BASE + 'h0,cdmacr_data);
        write_reg(CDMA_BASE + 'h18,sa_data);
        write_reg(CDMA_BASE + 'h20,da_data);
        write_reg(CDMA_BASE + 'h28,btt_data);
        `uvm_info("cdma_config_seq","btt written",UVM_LOW)
    endtask
endclass : cdma_config_seq


class bram_multiple_wr_rd_seq extends base_cpu_sequence;
    `uvm_object_utils(bram_multiple_wr_rd_seq)

    `NEW_OBJ
    int  addr;
    task body();
        super.body();
            for (int i=0;i<64;i+=4)begin
                addr=32'h7100_0000+i;
                start_item(pkt);
                    if(!pkt.randomize() with {
                        AWADDR==addr;
                        operation==WRITE;
                        WSTRB==4'b1111;})
                    begin    
                   `uvm_error("RAND_ERR","Randomization failed")
                   end
                finish_item(pkt);
            end
            for (int i=0;i<64;i+=4)begin
                addr=32'h7100_0000+i;
                start_item(pkt);
                    if(!pkt.randomize() with {
                        ARADDR==addr;
                        operation==READ;})
                    begin    
                   `uvm_error("RAND_ERR","Randomization failed")
                   end
                finish_item(pkt);
            end

        endtask
endclass : bram_multiple_wr_rd_seq

class bram_lower_invalid_addr_seq extends base_cpu_sequence;
    `uvm_object_utils(bram_lower_invalid_addr_seq)
    `NEW_OBJ

    task body();
        super.body();
        start_item(pkt);
            if(!pkt.randomize() with {
                AWADDR      ==  32'h70FF_FFFC;
                operation   ==  WRITE;
                WSTRB       ==  4'b1111;})
            `uvm_error("RAND_FAIL","Randomization Fail")
        finish_item(pkt);
    endtask
endclass : bram_lower_invalid_addr_seq

class bram_upper_invalid_addr_seq extends base_cpu_sequence;
    `uvm_object_utils(bram_upper_invalid_addr_seq)
    `NEW_OBJ

    task body();
        super.body();

        start_item(pkt);
            if(!pkt.randomize() with  {
                AWADDR      ==  32'h7140_0000;
                operation   ==  WRITE;
                WSTRB       ==  4'b1111;})
                `uvm_error("RAND_FAIL","RANDOMIAZATION FAILED")
        finish_item(pkt);
    endtask
endclass : bram_upper_invalid_addr_seq

class bram_address_range_seq extends base_cpu_sequence;
    `uvm_object_utils(bram_address_range_seq)
    `NEW_OBJ

    task body();
        super.body();
        start_item(pkt);
            if(!pkt.randomize() with {operation ==WRITE;
            AWADDR==32'h7100_0100;
            WDATA==32'h5555_5555;
            WSTRB==4'b1111;})
            `uvm_error("RAND_FAIL","Randomization fail")

        finish_item(pkt);
        start_item(pkt);
            if(!pkt.randomize() with {operation ==WRITE;
            AWADDR==32'h7100_0100;
            WDATA==32'h1111_1111;
            WSTRB==4'b1111;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {
            operation ==WRITE;
            AWADDR==32'h7110_0000;
            WDATA==32'h2222_2222;
            WSTRB==4'b1111;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {
            operation ==WRITE;
            AWADDR==32'h7120_0000;
            WDATA==32'h3333_3333;
           WSTRB==4'b1111;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {operation == WRITE;
            AWADDR==32'h7130_0000;
            WDATA==32'h4444_4444;
            WSTRB==4'b1111;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {
            AWADDR      ==  32'h713F_FFFC;
            operation   ==  WRITE;
            WSTRB       ==  4'b1111;})
            `uvm_error("RAND_FAIL","RANDOMIZATION FAIL")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {operation ==READ;
            ARADDR==32'h7100_0000;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {operation ==READ;
            ARADDR==32'h7100_0100;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {operation ==READ; ARADDR == 32'h7110_0000;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

         start_item(pkt);
            if(!pkt.randomize() with {operation ==READ;
            ARADDR==32'h7120_0000;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with {operation ==READ;
            ARADDR==32'h7130_0000;})
            `uvm_error("RAND_FAIL","Randomization fail")
        finish_item(pkt);

        start_item(pkt);
            if(!pkt.randomize() with  {
            ARADDR      ==  32'h713F_FFFC;
            operation   ==  READ;})
            `uvm_error("RAND_FAIL","Randomization Fail")
        finish_item(pkt);

    endtask
endclass : bram_address_range_seq
