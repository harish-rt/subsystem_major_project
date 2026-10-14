//`ifndef GPIO_SLAVE_RESPONDER_AGENT_SV
//`define GPIO_SLAVE_RESPONDER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class gpio_slave_seq_item extends uvm_sequence_item;
    `uvm_object_utils(gpio_slave_seq_item)

    rand bit [31:0] req_data;
    rand bit [31:0] gpio_out;
    rand bit [31:0] gpio_oe;
    rand int        latency_cycles;

    constraint c_latency { latency_cycles inside {[1:8]}; }

    function new(string name = "gpio_slave_seq_item");
        super.new(name);
    endfunction

    function void do_copy(uvm_object rhs);
        gpio_slave_seq_item rhs_;
        if (!$cast(rhs_, rhs)) `uvm_fatal("do_copy", "cast failed")
        super.do_copy(rhs);
        req_data = rhs_.req_data;
        gpio_out = rhs_.gpio_out;
        gpio_oe = rhs_.gpio_oe;
        latency_cycles = rhs_.latency_cycles;
    endfunction
endclass

class gpio_slave_sequencer extends uvm_sequencer #(gpio_slave_seq_item);
    `uvm_component_utils(gpio_slave_sequencer)

    function new(string name = "gpio_slave_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

class gpio_slave_driver extends uvm_driver #(gpio_slave_seq_item);
    `uvm_component_utils(gpio_slave_driver)

    virtual gpio_slave_if vif;

    function new(string name = "gpio_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("GPIO_DRV", "Virtual interface not found for GPIO slave responder")
        end
    endfunction

    task run_phase(uvm_phase phase);
        gpio_slave_seq_item req;

        vif.ack     = 1'b0;
        vif.gpio_out = '0;
        vif.gpio_oe  = '0;

        forever begin
            seq_item_port.get_next_item(req);

            // Wait for a request from the RTL or master-side GPIO logic.
            while (!(vif.req_valid)) begin
                @(posedge vif.clk);
            end

            // Acknowledge and drive the response to the RTL bus.
            vif.ack     = 1'b1;
            vif.gpio_out = req.gpio_out;
            vif.gpio_oe  = req.gpio_oe;

            repeat (req.latency_cycles) @(posedge vif.clk);

            vif.ack     = 1'b0;
            vif.gpio_out = '0;
            vif.gpio_oe  = '0;

            `uvm_info("GPIO_DRV", $sformatf("GPIO request accepted. req=0x%08h out=0x%08h oe=0x%08h",
                req.req_data, req.gpio_out, req.gpio_oe), UVM_LOW)

            seq_item_port.item_done();
        end
    endtask
endclass

class gpio_slave_agent extends uvm_agent;
    `uvm_component_utils(gpio_slave_agent)

    gpio_slave_driver driver;
    gpio_slave_sequencer sequencer;
    virtual gpio_slave_if vif;

    function new(string name = "gpio_slave_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual gpio_slave_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("GPIO_AGENT", "Virtual interface not found for GPIO slave responder")
        end

        uvm_config_db#(virtual gpio_slave_if)::set(this, "driver", "vif", vif);

        driver = gpio_slave_driver::type_id::create("driver", this);
        sequencer = gpio_slave_sequencer::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass

//`endif
