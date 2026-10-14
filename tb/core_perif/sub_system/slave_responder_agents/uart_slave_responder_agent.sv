`ifndef UART_SLAVE_RESPONDER_AGENT_SV
`define UART_SLAVE_RESPONDER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

interface uart_slave_if(input logic clk, rst_n);
    logic        rx_valid;
    logic        rx_ready;
    logic        tx_valid;
    logic        tx_ready;
    logic        ack;
    logic        tx_o;
    logic        rx_i;
    logic [7:0]  rx_data;
    logic [7:0]  tx_data;
endinterface

class uart_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(uart_slave_seq_item)

    rand bit [7:0] rx_data;
    rand bit [7:0] tx_data;
    rand int       latency_cycles;

    constraint c_latency { latency_cycles inside {[1:8]}; }

    function new(string name = "uart_slave_seq_item");
        super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
        uart_slave_seq_item rhs_;
        if (!$cast(rhs_, rhs)) `uvm_fatal("do_copy", "cast failed")
        super.do_copy(rhs);
        rx_data = rhs_.rx_data;
        tx_data = rhs_.tx_data;
        latency_cycles = rhs_.latency_cycles;
    endfunction
endclass

class uart_slave_sequencer extends uvm_sequencer #(uart_slave_seq_item);
    `uvm_component_utils(uart_slave_sequencer)

    function new(string name = "uart_slave_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

class uart_slave_driver extends uvm_driver #(uart_slave_seq_item);
    `uvm_component_utils(uart_slave_driver)

    virtual uart_slave_if vif;

    function new(string name = "uart_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("UART_DRV", "Virtual interface not found for UART slave responder")
        end
    endfunction

    task run_phase(uvm_phase phase);
        uart_slave_seq_item req;

        vif.tx_valid = 1'b0;
        vif.ack      = 1'b0;
        vif.tx_o     = 1'b0;

        forever begin
            seq_item_port.get_next_item(req);

            // Wait for an incoming request from the RTL UART RX path.
            while (!(vif.rx_valid)) begin
                @(posedge vif.clk);
            end

            // Acknowledge and send a response byte on the UART TX path.
            vif.ack      = 1'b1;
            vif.tx_valid = 1'b1;
            vif.tx_data  = req.tx_data;

            for (int i = 0; i < 8; i++) begin
                vif.tx_o = req.tx_data[i];
                repeat (req.latency_cycles) @(posedge vif.clk);
            end

            // Hold tx valid until RTL consumes it.
            while (!vif.tx_ready) begin
                @(posedge vif.clk);
            end

            vif.tx_valid = 1'b0;
            vif.ack      = 1'b0;
            vif.tx_o     = 1'b0;

            `uvm_info("UART_DRV", $sformatf("UART request accepted. rx=0x%02h tx=0x%02h",
                req.rx_data, req.tx_data), UVM_LOW)

            seq_item_port.item_done();
        end
    endtask
endclass

class uart_slave_agent extends uvm_agent;
    `uvm_component_utils(uart_slave_agent)

    uart_slave_driver driver;
    uart_slave_sequencer sequencer;
    virtual uart_slave_if vif;

    function new(string name = "uart_slave_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual uart_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("UART_AGENT", "Virtual interface not found for UART slave responder")
        end

        uvm_config_db#(virtual uart_slave_if)::set(this, "driver", "vif", vif);

        driver = uart_slave_driver::type_id::create("driver", this);
        sequencer = uart_slave_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass

`endif
