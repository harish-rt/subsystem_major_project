class my_predictor extends uvm_reg_predictor #(master_seq_item);

  `uvm_component_utils(my_predictor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  /*virtual function void write(master_seq_item t);

    `uvm_info("TEST",
      $sformatf("Predictor got addr=%0h data=%0h",
      t.araddr, t.rdata[0]), UVM_LOW)

    super.write(t); // IMPORTANT: keep this
  endfunction*/

  virtual function void write(master_seq_item tr);
  uvm_reg rg;
  uvm_reg_bus_op rw;
	
    super.write(tr);
    adapter.bus2reg(tr,rw);
    rg=map.get_reg_by_offset(rw.addr,(rw.kind == UVM_READ));
    rg.sample_values();
  
    `uvm_info("TEST", $sformatf("Predictor got addr=%0h data=%0h",t.araddr, t.rdata[0]), UVM_LOW)


	endfunction

endclass
