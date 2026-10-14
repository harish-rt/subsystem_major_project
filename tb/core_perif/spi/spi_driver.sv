class spi_driver extends uvm_driver#(spi_seq_item);
    `uvm_component_utils(spi_driver)
    `NEW_COMP

    virtual spi_intf.DRV_MOD   spi_if;
    spi_seq_item               pkt;
    
    realtime baud_period = 1000ns;
        
    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        `uvm_info ("spi_driver::build" , phase.get_name() , UVM_MEDIUM)
    endfunction : build_phase

    task main_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "spi_main_phase entered", UVM_LOW)
        forever begin
            seq_item_port.get_next_item(pkt);
            drive_byte(pkt);
            seq_item_port.item_done();
        end
    endtask

    task drive_byte(spi_seq_item pkt);
    endtask
endclass : spi_driver
