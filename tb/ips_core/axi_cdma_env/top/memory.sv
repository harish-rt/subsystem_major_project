class axi_slave_mem_model extends uvm_object;
    `uvm_object_utils(axi_slave_mem_model)
   
   //int mem[int];
   bit [31:0] mem [bit[63:0]];

     
     function new (string name ="memory");
       super.new(name);
     endfunction

   function void write( bit[63:0] cd,descriptor_seq_item desc );
    //descriptor_seq_item desc1=descriptor_seq_item::type_id::create("desc1");
   `uvm_info("memory_descriptor",desc.sprint(),UVM_LOW)
   if(desc==null)
   $display("desc content deleted");
   else begin
    $display("descriptor_current_address=%h",cd);
    $display("%h",desc.next_desc_pntr);
    mem[cd+0]  = desc.next_desc_pntr;
    $display("%h",desc.next_desc_pntr_msb);
    mem[cd+4]  = desc.next_desc_pntr_msb;
    $display("%h",desc.sa);
    mem[cd+8]  = desc.sa;
    $display("%h",desc.sa_msb);
    mem[cd+12] = desc.sa_msb;
    $display("%h",desc.da);
    mem[cd+16] = desc.da;
    $display("%h",desc.da_msb);
    mem[cd+20] = desc.da_msb;
    $display("%h",desc.control);
    mem[cd+24] = desc.control; // btt
    $display("%h",desc.status);
    mem[cd+28] = desc.status;

    $displayh("inside memory memory_content::%p",mem);
    end
endfunction
    endclass

