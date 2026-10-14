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
            @(negedge spi_if.spi_cs_o);
            while(spi_if.spi_cs_o == 0)begin
                seq_item_port.get_next_item(pkt);
                    for(int i = 0; i < 8; i++)begin
                        @(negedge spi_if.clk_i);
                        spi_if.spi_miso_i <= pkt.data[i];
                        if(spi_if.spi_cs_o == 1) break;
                    end
                seq_item_port.item_done();
            end
            spi_if.spi_miso_i <= 1'bz;
        end
    endtask

endclass : spi_driver
