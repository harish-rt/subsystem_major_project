class cpu_config_obj extends uvm_object;
   `uvm_object_utils(cpu_config_obj)
  `NEW_OBJ

   virtual axi4_lite_intf   cpu_i;
   bit                      mas_is_active; 

endclass : cpu_config_obj
