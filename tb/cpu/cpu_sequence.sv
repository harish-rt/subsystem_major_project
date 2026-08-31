class base_cpu_sequence extends uvm_sequence#(cpu_seq_item);
    `uvm_object_utils(base_cpu_sequence)
    `NEW_OBJ
    
    uvm_phase           phase;
    //cdma_reg_block      reg_block;
    uvm_status_e        status;
    uvm_reg_data_t      tdata;
    cpu_seq_item   pkt;

    task pre_body();
        phase   =   get_starting_phase();
        if(phase != null) begin
            phase.raise_objection(this);
            `uvm_info(get_full_name(),"inside_pre_body", UVM_MEDIUM)
        end
    endtask
    
    task post_body();
        if(phase != null) begin
            `uvm_info(get_full_name(),"inside_post_body", UVM_MEDIUM)
            phase.drop_objection(this);
        end
    endtask

    task body ();
        `uvm_info(get_full_name(),"inside base_cpu_sequence body", UVM_MEDIUM)

        pkt = cpu_seq_item::type_id::create("pkt");
    endtask
endclass : base_cpu_sequence


class read_cdma_seq extends base_cpu_sequence;
    `uvm_object_utils(read_cdma_seq)
    `NEW_OBJ
    
    int addr;

    task body();
        super.body();
        `uvm_info("read_cdma_seq", "Start of Config CDMA Sequence", UVM_MEDIUM)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        for (int i = 0; i < 11; i++) begin        
            addr = 'h7000_0000 + (i*4);
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
        `uvm_info("read_cdma_seq", "End of Config CDMA Sequence", UVM_MEDIUM)
    endtask

endclass : read_cdma_seq


class config_cdma_ral_seq extends base_cpu_sequence;
    `uvm_object_utils(config_cdma_ral_seq)
    `NEW_OBJ
    
    task body();
        super.body();
        `uvm_info("config_cdma_seq", "Start of Config CDMA RAL Sequence", UVM_MEDIUM)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        //reg_block.cdmacr.read(status,tdata);
        `uvm_info("config_cdma_seq", "End of Config CDMA Sequence", UVM_MEDIUM)
    endtask

endclass : config_cdma_ral_seq


class read_bram_seq extends base_cpu_sequence;
    `uvm_object_utils(read_bram_seq)
    `NEW_OBJ
    
    int addr;

    task body();
        super.body();
        `uvm_info("read_bram_seq", "Start of Read BRAM Sequence", UVM_MEDIUM)
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
        `uvm_info("read_bram_seq", "End of Read BRAM Sequence", UVM_MEDIUM)
    endtask

endclass : read_bram_seq

//config mem seq
//config intr seq
//config cdma seq
//config isr seq execute based on monitored event

class load_bram_seq extends base_cpu_sequence;
    `uvm_object_utils(load_bram_seq)
    `NEW_OBJ

    task body();
        super.body();
        start_item(pkt);
        if(!pkt.randomize() with {
            AWADDR  == 'h7100_0000;
            WDATA   == 'ha;
            WSTRB   == 'hf;
            operation   == WRITE;
            })begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        get_response(pkt);             

        start_item(pkt);
        if(!pkt.randomize() with {
            ARADDR  == 'h7100_0000;
            operation   == READ;
            })begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        get_response(pkt);             
/*
        start_item(pkt);
        if(!pkt.randomize() with {
            ARADDR  == 'h7100_0000;
            operation   == READ;
            })begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        get_response(pkt);*/
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
            reg_type== IER;
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
            reg_type== MER;
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
        `uvm_info("config_cdma_seq", "Start of Config CDMA Sequence", UVM_MEDIUM)


        do begin
            //reg_block.cdmasr.read(status,tdata);
        end while(tdata[1]==0);
        
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
        `uvm_info("config_cdma_seq", "End of Config CDMA Sequence", UVM_MEDIUM)
    endtask

endclass : config_cdma_seq

/*
class config_intc_seq extends base_cpu_sequence;
    `uvm_object_utils(config_intc_seq)
    `NEW_OBJ
    
    int addr;

    task body();
        super.body();
        `uvm_info("config_intc_seq", "Start of Config CDMA Sequence", UVM_MEDIUM)
        //KERNEL: UVM_ERROR Response queue overflow, response was dropped
        //this.set_response_queue_depth(20);         //clears

        for (int i = 0; i < 10; i++) begin        
            addr = 'h7000_1000 + (i*4);
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
        `uvm_info("config_intc_seq", "End of Config CDMA Sequence", UVM_MEDIUM)
    endtask

endclass : config_intc_seq
*/


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
endclass

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
endclass

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
endclass


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
endclass



