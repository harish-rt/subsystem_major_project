class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)
    `NEW_COMP

    virtual uart_intf.MON_MOD uart_if;
    
    uvm_analysis_port #(uart_seq_item) tx_mon_ap;
    uvm_analysis_port #(uart_seq_item) rx_mon_ap;
    
    realtime baud_period = 1000ns;
        
    extern function void build_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task mon_tx_frames();
    extern task mon_rx_frames();
endclass : uart_monitor

function void uart_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("uart_monitor::build", phase.get_name(), UVM_MEDIUM)
    
    tx_mon_ap = new("tx_mon_ap", this);
    rx_mon_ap = new("rx_mon_ap", this);
endfunction : build_phase

task uart_monitor::main_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "uart_run_phase entered", UVM_LOW)
  
    fork
        mon_tx_frames();
        mon_rx_frames();
    join
endtask : main_phase

task uart_monitor::mon_tx_frames();

    forever begin
        uart_seq_item tx_pkt;

        @(negedge uart_if.tx);
        
        tx_pkt = uart_seq_item::type_id::create("tx_pkt");

        for (int i = 0; i < 8; i++) begin
            tx_pkt.data[i] = uart_if.tx;
            #(baud_period);
        end

        if (uart_if.tx !== 1'b1) begin
            `uvm_error("UART_MON_TX", "Framing error: Stop bit not 1")
        end

        tx_mon_ap.write(tx_pkt);
    end
endtask : mon_tx_frames

task uart_monitor::mon_rx_frames();
  forever begin
    uart_seq_item rx_pkt;

    @(negedge uart_if.rx);
    
    rx_pkt = uart_seq_item::type_id::create("rx_pkt");

    for (int i = 0; i < 8; i++) begin
        rx_pkt.data[i] = uart_if.rx;
        #(baud_period);
    end

    if (uart_if.rx !== 1'b1) begin
        `uvm_error("UART_MON_RX", "Framing error: Stop bit not 1")
    end

    rx_mon_ap.write(rx_pkt);
  end
endtask : mon_rx_frames
