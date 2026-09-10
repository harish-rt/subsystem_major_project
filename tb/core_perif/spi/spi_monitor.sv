class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)
    `NEW_COMP

    virtual spi_intf.MON_MOD spi_if;
    
    uvm_analysis_port #(spi_seq_item) tx_mon_ap;
    uvm_analysis_port #(spi_seq_item) rx_mon_ap;
    
    realtime baud_period = 1000ns;
        
    extern function void build_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task mon_tx_frames();
    extern task mon_rx_frames();
endclass : spi_monitor

function void spi_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("spi_monitor::build", phase.get_name(), UVM_MEDIUM)
    
    tx_mon_ap = new("tx_mon_ap", this);
    rx_mon_ap = new("rx_mon_ap", this);
endfunction : build_phase

task spi_monitor::main_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "spi_run_phase entered", UVM_LOW)
  
    fork
        mon_tx_frames();
        mon_rx_frames();
    join
endtask : main_phase

task spi_monitor::mon_tx_frames();

    forever begin
        spi_seq_item tx_pkt;

        @(negedge spi_if.tx);
        
        tx_pkt = spi_seq_item::type_id::create("tx_pkt");

        for (int i = 0; i < 8; i++) begin
            tx_pkt.data[i] = spi_if.tx;
            #(baud_period);
        end

        if (spi_if.tx !== 1'b1) begin
            `uvm_error("UART_MON_TX", "Framing error: Stop bit not 1")
        end

        tx_mon_ap.write(tx_pkt);
    end
endtask : mon_tx_frames

task spi_monitor::mon_rx_frames();
  forever begin
    spi_seq_item rx_pkt;

    @(negedge spi_if.rx);
    
    rx_pkt = spi_seq_item::type_id::create("rx_pkt");

    for (int i = 0; i < 8; i++) begin
        rx_pkt.data[i] = spi_if.rx;
        #(baud_period);
    end

    if (spi_if.rx !== 1'b1) begin
        `uvm_error("UART_MON_RX", "Framing error: Stop bit not 1")
    end

    rx_mon_ap.write(rx_pkt);
  end
endtask : mon_rx_frames
