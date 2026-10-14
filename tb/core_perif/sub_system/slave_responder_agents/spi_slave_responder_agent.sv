`ifndef SPI_SLAVE_RESPONDER_AGENT_SV
`define SPI_SLAVE_RESPONDER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

interface spi_slave_if(input logic clk, rst_n);
    logic        req_valid;
    logic        req_ready;
    logic        ack;
    logic        cs_n;
    logic        sclk;
    logic        mosi;
    logic        miso;
    logic [7:0]  req_data;
    logic [7:0]  rsp_data;
endinterface

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

    task run_phase(uvm_phase phase);
        spi_slave_seq_item req;

        vif.req_ready = 1'b0;
        vif.ack       = 1'b0;
        vif.miso      = 1'b0;

        forever begin
            seq_item_port.get_next_item(req);

            // Signal that the slave is ready to accept a request.
            vif.req_ready = 1'b1;

            // Wait for an actual request from the RTL master side.
            while (!(vif.req_valid && (vif.cs_n == 1'b0))) begin
                @(posedge vif.clk);
            end

            // Acknowledge and send response payload over MISO.
            vif.ack = 1'b1;
            for (int i = 0; i < 8; i++) begin
                @(posedge vif.sclk);
                vif.miso = req.rsp_data[7 - i];
            end

            repeat (req.latency_cycles) @(posedge vif.clk);

            vif.ack  = 1'b0;
            vif.miso = 1'b0;
            vif.req_ready = 1'b0;

            `uvm_info("SPI_DRV", $sformatf("SPI request accepted. req=0x%02h rsp=0x%02h",
                req.req_data, req.rsp_data), UVM_LOW)

            seq_item_port.item_done();
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

`endif
