//`ifndef SPI_SLAVE_RESPONDER_AGENT_SV
//`define SPI_SLAVE_RESPONDER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(spi_slave_seq_item)

    rand bit [7:0] req_data;
    rand bit [7:0] rsp_data;
    rand int       latency_cycles;

    constraint c_latency { latency_cycles inside {[1:8]}; }

    function new(string name = "spi_slave_seq_item");
        super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
        spi_slave_seq_item rhs_;
        if (!$cast(rhs_, rhs)) `uvm_fatal("do_copy", "cast failed")
        super.do_copy(rhs);
        req_data = rhs_.req_data;
        rsp_data = rhs_.rsp_data;
        latency_cycles = rhs_.latency_cycles;
    endfunction
endclass

class spi_slave_sequencer extends uvm_sequencer #(spi_slave_seq_item);
    `uvm_component_utils(spi_slave_sequencer)

    function new(string name = "spi_slave_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

class spi_slave_sequence extends uvm_sequence#(spi_slave_seq_item);
    `uvm_object_utils(spi_slave_sequence)
    `NEW_OBJ

    spi_slave_seq_item pkt;
    bit [7:0] rx_pkt;

    task body();
        pkt = spi_slave_seq_item::type_id::create("pkt");

        start_item(pkt);
            if(!pkt.randomize() with{
                rsp_data == 'h00;
            }) begin
                `uvm_fatal("SPI_SEQ", "SPI_SEQ randomization failed!")        
            end
        finish_item(pkt);
        get_response(pkt);

        rx_pkt = pkt.req_data;
        `uvm_info("SPI_SLV_SEQ", $sformatf("[SEQ DONE] Received Byte: 0x%02h | Sent : 0x%02h", pkt.req_data, pkt.rsp_data), UVM_LOW)

        start_item(pkt);
            if(!pkt.randomize() with{
                rsp_data == rx_pkt;
            }) begin
                `uvm_fatal("SPI_SEQ", "SPI_SEQ randomization failed!")        
            end
        finish_item(pkt);
        get_response(pkt);
        `uvm_info("SPI_SLV_SEQ", $sformatf("[SEQ DONE] Received Byte: 0x%02h | Sent : 0x%02h", pkt.req_data, pkt.rsp_data), UVM_LOW)
    endtask
endclass

class spi_slave_driver extends uvm_driver #(spi_slave_seq_item);
    `uvm_component_utils(spi_slave_driver)

    virtual spi_slave_if vif;

    function new(string name = "spi_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SPI_DRV", "Virtual interface not found for SPI slave responder")
        end
    endfunction

    task main_phase(uvm_phase phase);
        spi_slave_seq_item req;
        logic [7:0] received_byte;

        vif.req_ready = 1'b0;
        vif.ack       = 1'b0;
        vif.miso      = 1'b0;

        forever begin
            seq_item_port.get_next_item(req);
                // Wait for an actual request from the RTL master side.
                while (!(vif.cs_n == 1'b0)) begin
                    @(posedge vif.clk);
                end
                
                vif.miso <= req.rsp_data[7];

                fork
                    begin
                        // receiving
                        for (int i = 0; i < 8; i++) begin
                            @(posedge vif.sclk);
                            received_byte[7-i] = vif.mosi;
                            //should collect 'haa
                        end
                        req.req_data = received_byte;
                        `uvm_info("SPI_DRV_L", $sformatf("SPI received data = %h | bin = %b", received_byte, received_byte), UVM_LOW)
                    end

                    // sending
                    for (int i = 0; i < 8; i++) begin
                        if(i>0) begin
                            @(negedge vif.sclk);
                            vif.miso = req.rsp_data[7 - i];
                        end
                        //should drive 'hab
                    end
                join
                repeat (req.latency_cycles) @(posedge vif.clk);

                @(posedge vif.cs_n);
                vif.ack  = 1'b0;
                vif.miso = 1'b0;
                vif.req_ready = 1'b0;

                `uvm_info("SPI_DRV", $sformatf("SPI request accepted. req=0x%02h rsp=0x%02h", req.req_data, req.rsp_data), UVM_LOW)

            seq_item_port.item_done();
            seq_item_port.put_response(req);
        end
    endtask
endclass

class spi_slave_agent extends uvm_agent;
    `uvm_component_utils(spi_slave_agent)

    spi_slave_driver driver;
    spi_slave_sequencer sequencer;
    virtual spi_slave_if vif;

    function new(string name = "spi_slave_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual spi_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SPI_AGENT", "Virtual interface not found for SPI slave responder")
        end

        uvm_config_db#(virtual spi_slave_if)::set(this, "driver", "vif", vif);

        driver = spi_slave_driver::type_id::create("driver", this);
        sequencer = spi_slave_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass

//`endif
