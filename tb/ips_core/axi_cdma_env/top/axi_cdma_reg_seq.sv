class reg_sequence extends uvm_sequence#(master_seq_item);
    `uvm_object_utils(reg_sequence)

    function new(string name="reg_sequence");
        super.new(name);
    endfunction
    
    cdma_reg_block reg_model;

    task body();
        uvm_status_e status;
        uvm_reg_data_t rdata;
       bit [31:0] write_val = 32'h8;

        reg_model.cdmacr.read(status,rdata);
        reg_model.cdmacr.write(status,write_val);
        reg_model.cdmacr.read(status,rdata);

        //reg_model.cdmacr.read(status, rdata);
        //reg_model.curdesc_pnt.read(status,rdata);
    if (status == UVM_IS_OK)
      `uvm_info("SEQ", $sformatf("Read value from cdma_sa: '%h",rdata), UVM_LOW)
      //`uvm_info("SEQ",$sformatf("Read value from_curdesc_pnt=%h",rdata),UVM_LOW)
    endtask
endclass



