class cpu_config_obj extends uvm_object;
   `uvm_object_utils(cpu_config_obj)
  `NEW_OBJ

   //virtual axi4_lite_tb_intf    cpu_i;
   virtual axi4_lite_tb_intf    cpu_i[];
   bit                          mas_is_active; 
   int                          no_of_masters;

endclass : cpu_config_obj
