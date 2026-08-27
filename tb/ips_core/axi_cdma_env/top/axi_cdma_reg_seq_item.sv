class reg_seq_item extends uvm_sequence_item;
   rand bit[31:0] cdmacr;
   rand bit[31:0] cdmasr;
   rand bit[31:0] sa;
   rand bit[31:0] da;
   rand bit[31:0] da_msb;
   rand bit[31:0] sa_msb;
   rand bit[31:0] btt;
   rand bit[31:0]curdesc_pnt;
   rand bit[31:0] curdesc_pnt_msb;
   rand bit[31:0] taildesc_pnt;
   rand bit[31:0] taildesc_pnt_msb;
    function new(string name="reg_seq_item");
        super.new(name);
    endfunction
`uvm_object_utils_begin(reg_seq_item)
    `uvm_field_int(cdmacr, UVM_ALL_ON)
    `uvm_field_int(cdmasr, UVM_ALL_ON)
    `uvm_field_int(sa,     UVM_ALL_ON)
    `uvm_field_int(da,     UVM_ALL_ON)
    `uvm_field_int(sa_msb, UVM_ALL_ON)
    `uvm_field_int(da_msb, UVM_ALL_ON)
    `uvm_field_int(btt,UVM_ALL_ON)
    `uvm_field_int(curdesc_pnt,UVM_ALL_ON)

`uvm_object_utils_end

constraint c1{
        soft sa%16==0;
        soft da%16==0;
        soft sa_msb%16==0;
        soft da_msb%16==0;
        soft btt%16==0;
        soft curdesc_pnt%64==0;
        soft taildesc_pnt%64==0;
        }

constraint c2 {sa-da>btt ||da-sa>btt;}
  
constraint c3 {btt inside {[1:26'hA000]};}
endclass
