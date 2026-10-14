//`ifndef UART_SLAVE_RESPONDER_AGENT_SV
//`define UART_SLAVE_RESPONDER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(uart_slave_seq_item)

    rand bit [7:0] rx_data;
    rand bit [7:0] tx_data;

    function new(string name = "uart_slave_seq_item");
        super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
        uart_slave_seq_item rhs_;
        if (!$cast(rhs_, rhs)) `uvm_fatal("do_copy", "cast failed")
        super.do_copy(rhs);
        rx_data = rhs_.rx_data;
        tx_data = rhs_.tx_data;
    endfunction
endclass

class uart_slave_sequence extends uvm_sequence#(uart_slave_seq_item);
    `uvm_object_utils(uart_slave_sequence)
    `NEW_OBJ
    
    uart_slave_seq_item pkt;

    task body();
        pkt = uart_slave_seq_item::type_id::create("pkt");

        start_item(pkt);
            if(!pkt.randomize() with {
                tx_data == 'hba;
            })begin
                `uvm_fatal("UART_SEQ", "UART_SEQ randomization failed!")        
            end
            `uvm_info("UART_SLV_SEQ", $sformatf("Configured response payload: 0x%02h", pkt.tx_data), UVM_LOW)
        finish_item(pkt);
        get_response(pkt);
        
        //`uvm_info("UART_SLV_SEQ", $sformatf("[SEQ DONE] UART Received Byte: 0x%02h | Sent : 0x%02h", pkt.rx_data, pkt.tx_data), UVM_LOW)
    endtask
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
    realtime baud_period = 500ns;

    function new(string name = "uart_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("UART_DRV", "Virtual interface not found for UART slave responder")
        end
    endfunction

    task main_phase(uvm_phase phase);

        uart_slave_seq_item req;
        logic [7:0] received_byte;

        vif.tx_o     = 1'b1;
        vif.tx_valid = 1'b0;
        vif.ack      = 1'b0;

        forever begin
            seq_item_port.get_next_item(req);

            //received_data(received_byte);
            //req.rx_data = received_byte;

            //#(baud_period * 10);
            
            vif.ack      = 1'b1;
            vif.tx_valid = 1'b1;
            vif.tx_data  = req.tx_data;

            drive_tx_byte(req.tx_data);

            vif.tx_valid = 1'b0;
            vif.ack      = 1'b0;

            seq_item_port.item_done();
            seq_item_port.put_response(req);
        end
    endtask

    task received_data(output logic [7:0] received_byte);
        @(negedge vif.rx_i);

        `uvm_info("UART_DRV","[RX] Detected START bit on rx_i (falling edge)",UVM_HIGH)

        #(baud_period * 1.5);
        for (int i = 0; i < 8; i++) begin
            received_byte[i] = vif.rx_i;
            `uvm_info("UART_DRV_L", $sformatf("[RX] Sampled bit %0d = %b", i, received_byte[i]), UVM_DEBUG)
            #(baud_period);
        end

        `uvm_info("UART_DRV", $sformatf("[RX COMPLETE] Received Byte from SoC: 0x%02h (%08b)", received_byte, received_byte), UVM_LOW)

        #(baud_period * 0.5);
    endtask

    task drive_tx_byte(input logic [7:0] data);
    `uvm_info("UART_DRV", $sformatf("[TX START] Driving byte to SoC: 0x%02h (%08b)", data, data), UVM_LOW)
        vif.tx_o = 1'b1;
        #(baud_period);

        vif.tx_o = 1'b0;
        #(baud_period);

        for (int i = 0; i < 8; i++) begin
            vif.tx_o = data[i];
            #(baud_period);
        end

        vif.tx_o = 1'b1;
        #(baud_period);
        `uvm_info("UART_DRV", "[TX COMPLETE] Frame finished (STOP bit driven)", UVM_HIGH)
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

//`endif
