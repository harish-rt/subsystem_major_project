class base_s04_sequence extends uvm_sequence#(s04_seq_item);
    `uvm_object_utils(base_s04_sequence)
    `NEW_OBJ
    
    uvm_phase           phase;
    uvm_status_e        status;
    uvm_reg_data_t      tdata;
    s04_seq_item        pkt,w_pkt,r_pkt;

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
        `uvm_info(get_full_name(),"inside base_s04_sequence body", UVM_LOW)

        pkt = s04_seq_item::type_id::create("pkt");
    endtask

    task write_reg(input bit [31:0]reg_addr, input bit [31:0]data = 0);
        w_pkt   = s04_seq_item::type_id::create("w_pkt");
        start_item(w_pkt);
        if(!w_pkt.randomize() with {
            AWADDR      == reg_addr;
            if(data != 0) {   
                WDATA[0]    == data;
            }
            WSTRB[0]    == 'hf;
            write   == WRITE;
        })begin
            `uvm_fatal("REG_ACCESS", "write_reg randomization failed!")        
        end
        finish_item(w_pkt);
        get_response(w_pkt);
    endtask

    task read_reg(input bit [31:0]reg_addr, output bit [31:0]data);
        r_pkt   = s04_seq_item::type_id::create("r_pkt");
        start_item(r_pkt);
        if(!r_pkt.randomize() with {
            ARADDR      == reg_addr;
            write   == READ;
        })begin
            `uvm_fatal("REG_ACCESS", "read_reg randomization failed!")        
        end
        finish_item(r_pkt);
        get_response(r_pkt);
        data            = r_pkt.RDATA;
    endtask
endclass : base_s04_sequence

class load_bram_256_seq extends base_s04_sequence;
    `uvm_object_utils(load_bram_256_seq)
    `NEW_OBJ

    task body();
        super.body();
        start_item(pkt);
        if(!pkt.randomize() with{
            AWADDR  == 'h7100_0100;
            AWLEN   == 'hf;
            AWBURST == INCR;
            AWID    == 'h2;
            write   == WRITE;
            }) begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        //get_response(pkt);
    endtask
endclass : load_bram_256_seq

class read_bram_256_seq extends base_s04_sequence;
    `uvm_object_utils(read_bram_256_seq)
    `NEW_OBJ

    task body();
        super.body();
        start_item(pkt);
        if(!pkt.randomize() with{
            ARADDR  == 'h7100_0100;
            ARLEN   == 'h7;
            ARBURST == INCR;
            ARID    == 'h1;
            write   == READ;
            }) begin
            `uvm_error(get_full_name(), "randomization_failed")
        end
        finish_item(pkt);
        //get_response(pkt);
    endtask
endclass : read_bram_256_seq
