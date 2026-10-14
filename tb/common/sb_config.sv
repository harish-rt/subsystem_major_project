typedef enum {BRAM, LITE_MEM} slave_t;

typedef struct {
    slave_t                 slave_name;
    bit [ADDR_WIDTH-1:0]    base_address;
    bit [ADDR_WIDTH-1:0]    high_address;
} slave_config_s;

class sb_config extends uvm_object;
    `uvm_object_utils(sb_config)
    `NEW_OBJ

    slave_config_s perif_addr[];
    
endclass
