typedef enum {BRAM, LITE_MEM, CDMA, INTC, CORE_INTC, GPIO, SPI, UART} slave_t;

typedef struct {
    slave_t                 slave_name;
    bit [ADDR_WIDTH-1:0]    start_address;
    bit [ADDR_WIDTH-1:0]    end_address;
} slave_config_s;

class sb_config extends uvm_object;
    `uvm_object_utils(sb_config)
    `NEW_OBJ

    slave_config_s perif_addr[];

    function bit decode_slave(input bit[31:0]addr, output slave_t slave);
        foreach(perif_addr[i])begin
            if(addr inside {[perif_addr[i].start_address : perif_addr[i].end_address]}) begin
                slave = perif_addr[i].slave_name;
                return 1'b1;
            end
        end
        return 1'b0;
    endfunction

/*
    function bit decode_slave(input bit[31:0]addr, output slave_t slave);
        if(addr inside {[BRAM_BASE:BRAM_END]})begin
            slave = BRAM;
            return 1'b1;
        end
        if(addr inside {[LITE_MEM_BASE:LITE_MEM_END]})begin
            slave = LITE_MEM;
            return 1'b1;
        end
        if(addr inside {[CDMA_BASE:CDMA_END]})begin
            slave = CDMA;
            return 1'b1;
        end
        if(addr inside {[CORE_PERIF_BASE:CORE_PERIF_END]}) begin
            slave = CORE_PERIF;
            return 1'b1;
        end
        if(addr inside {[INTC_BASE:INTC_END]}) begin
            slave = INTC;
            return 1'b1;
        end
        return 1'b0;
    endfunction
*/
endclass
