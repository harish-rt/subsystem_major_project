`ifndef RTL_SLAVE_RESPONDER_TB_SV
`define RTL_SLAVE_RESPONDER_TB_SV

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../slave_responder_agents/spi_slave_responder_agent.sv"
`include "../slave_responder_agents/uart_slave_responder_agent.sv"
`include "../slave_responder_agents/gpio_slave_responder_agent.sv"

class spi_resp_seq extends uvm_sequence #(spi_slave_seq_item);
    `uvm_object_utils(spi_resp_seq)

    function new(string name = "spi_resp_seq");
        super.new(name);
    endfunction

    task body();
        spi_slave_seq_item req = spi_slave_seq_item::type_id::create("req");

        start_item(req);
        assert(req.randomize() with { req_data == 8'hA5; rsp_data == 8'h5A; latency_cycles == 2; });
        finish_item(req);
    endtask
endclass

class uart_resp_seq extends uvm_sequence #(uart_slave_seq_item);
    `uvm_object_utils(uart_resp_seq)

    function new(string name = "uart_resp_seq");
        super.new(name);
    endfunction

    task body();
        uart_slave_seq_item req = uart_slave_seq_item::type_id::create("req");

        start_item(req);
        assert(req.randomize() with { rx_data == 8'h3C; tx_data == 8'hC3; latency_cycles == 2; });
        finish_item(req);
    endtask
endclass

class gpio_resp_seq extends uvm_sequence #(gpio_slave_seq_item);
    `uvm_object_utils(gpio_resp_seq)

    function new(string name = "gpio_resp_seq");
        super.new(name);
    endfunction

    task body();
        gpio_slave_seq_item req = gpio_slave_seq_item::type_id::create("req");

        start_item(req);
        assert(req.randomize() with { req_data == 32'hDEAD_BEEF; gpio_out == 32'h1234_5678; gpio_oe == 32'hFFFF_FFFF; latency_cycles == 2; });
        finish_item(req);
    endtask
endclass

class responder_env extends uvm_env;
    `uvm_component_utils(responder_env)

    spi_slave_agent spi_agent;
    uart_slave_agent uart_agent;
    gpio_slave_agent gpio_agent;

    function new(string name = "responder_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        spi_agent = spi_slave_agent::type_id::create("spi_agent", this);
        uart_agent = uart_slave_agent::type_id::create("uart_agent", this);
        gpio_agent = gpio_slave_agent::type_id::create("gpio_agent", this);
    endfunction
endclass

class responder_test extends uvm_test;
    `uvm_component_utils(responder_test)

    responder_env env;

    function new(string name = "responder_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = responder_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        spi_resp_seq spi_seq;
        uart_resp_seq uart_seq;
        gpio_resp_seq gpio_seq;

        phase.raise_objection(this);

        spi_seq = spi_resp_seq::type_id::create("spi_seq");
        uart_seq = uart_resp_seq::type_id::create("uart_seq");
        gpio_seq = gpio_resp_seq::type_id::create("gpio_seq");

        fork
            begin
                spi_seq.start(env.spi_agent.sequencer);
            end
            begin
                uart_seq.start(env.uart_agent.sequencer);
            end
            begin
                gpio_seq.start(env.gpio_agent.sequencer);
            end
        join

        phase.drop_objection(this);
    endtask
endclass

module rtl_slave_model;
    logic clk = 0;
    logic rst_n = 0;

    spi_slave_if spi_if(clk, rst_n);
    uart_slave_if uart_if(clk, rst_n);
    gpio_slave_if gpio_if(clk, rst_n);

    initial begin
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
    end

    // Simple RTL request generator that drives request lines to the responder agents.
    initial begin
        wait (rst_n);

        repeat (3) @(posedge clk);

        // SPI request
        spi_if.req_valid = 1'b1;
        spi_if.req_data  = 8'hA5;
        spi_if.cs_n      = 1'b0;
        spi_if.sclk      = 1'b0;
        while (!spi_if.ack) @(posedge clk);
        repeat (2) @(posedge clk);
        spi_if.req_valid = 1'b0;
        spi_if.cs_n      = 1'b1;

        // UART request
        repeat (2) @(posedge clk);
        uart_if.rx_valid = 1'b1;
        uart_if.rx_data  = 8'h3C;
        while (!uart_if.ack) @(posedge clk);
        repeat (2) @(posedge clk);
        uart_if.rx_valid = 1'b0;

        // GPIO request
        repeat (2) @(posedge clk);
        gpio_if.req_valid = 1'b1;
        gpio_if.req_data  = 32'hDEAD_BEEF;
        while (!gpio_if.ack) @(posedge clk);
        repeat (2) @(posedge clk);
        gpio_if.req_valid = 1'b0;

        #100;
        $display("RTL slave responder TB complete");
        $finish;
    end

    // Monitor the responder outputs for proof of response.
    always @(posedge clk) begin
        if (spi_if.ack)
            $display("[%0t] SPI responder ack -> %0h", $time, spi_if.miso);
        if (uart_if.ack)
            $display("[%0t] UART responder ack -> %0h", $time, uart_if.tx_o);
        if (gpio_if.ack)
            $display("[%0t] GPIO responder ack -> 0x%08h", $time, gpio_if.gpio_out);
    end
endmodule

module top;
    rtl_slave_model dut();

    initial begin
        uvm_config_db#(virtual spi_slave_if)::set(uvm_root::get(), "uvm_test_top.env.spi_agent", "vif", dut.spi_if);
        uvm_config_db#(virtual uart_slave_if)::set(uvm_root::get(), "uvm_test_top.env.uart_agent", "vif", dut.uart_if);
        uvm_config_db#(virtual gpio_slave_if)::set(uvm_root::get(), "uvm_test_top.env.gpio_agent", "vif", dut.gpio_if);

        run_test("responder_test");
    end
endmodule

`endif
