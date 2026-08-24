class config_obj extends uvm_object();
`uvm_object_utils(config_obj)

//config members
   virtual axi4_lite_intf    cpu_i;
   //virtual cpu_intf    cpu_i;
   bit mas_is_active; 
   //riscv_is_active in top

  function new (string name = "config_obj");
     super.new (name);
  endfunction
  
endclass :config_obj


