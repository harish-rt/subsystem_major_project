class uart_driver extends uvm_driver#(uart_seq_item);
    `uvm_component_utils(uart_driver)
    `NEW_COMP

    virtual uart_intf.DRV_MOD   uart_if;
    uart_seq_item               pkt;
    
    realtime baud_period = 1000ns;
        
    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        `uvm_info ("uart_driver::build" , phase.get_name() , UVM_MEDIUM)
    endfunction : build_phase

    task main_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "uart_main_phase entered", UVM_LOW)
        uart_if.rx  <=   1'b1;
        forever begin
            seq_item_port.get_next_item(pkt);
            drive_byte(pkt);
            seq_item_port.item_done();
        end
    endtask

    task drive_byte(uart_seq_item pkt);
        uart_if.uart_drv_cb.rx <= 1'b0;
        #(baud_period);
    
        for (int i = 0; i < 8; i++) begin
            uart_if.uart_drv_cb.rx <= pkt.data[i];
            #(baud_period);
        end
    
        uart_if.uart_drv_cb.rx <= 1'b1;
        #(baud_period);
    endtask
endclass
