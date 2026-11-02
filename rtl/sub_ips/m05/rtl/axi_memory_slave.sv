//==========================================================
// File        : axi_memory_slave.sv
// Author      : Raveem
// Created     : 2026-03-08
// Description : RTL of the AXI memory slave
//==========================================================

module axi_memory_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter MEM_DEPTH  = 1024
)(
    axi4_intf axi4_mem
);
    //---------- Internal signals ----------    
    logic [ADDR_WIDTH-1: 0] waddr_index, raddr_index;
    logic [ID_WIDTH-1:0]    awid_reg, ARID_reg;
    logic [7:0]   awlen_reg;
    logic [3:0]   wstrb_reg;
    logic [2:0]   awsize_reg;

    //========== Internal Memory ==========
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    initial begin
        for (int i=0; i<MEM_DEPTH; ++i) begin
            mem[i] = 0; // initialize memory
        end
    end

    //========== initialization ==========
    //initial begin
    //    axi4_mem.ARREADY = 0;
    //    axi4_mem.RVALID  = 0;
    //    axi4_mem.RDATA   = 0;
    //    axi4_mem.RID     = 0;
    //    axi4_mem.RRESP   = 0;
    //    axi4_mem.RLAST   = 0;
    //
    //    axi4_mem.AWREADY = 0;
    //    axi4_mem.WREADY  = 0;
    //    axi4_mem.BVALID  = 0;
    //    axi4_mem.BID     = 0;
    //    axi4_mem.BRESP   = 0;
    //end

    //========== Write FSM ==========

    typedef enum {
        W_IDLE,
        W_DATA,
        W_RESP
    } wstate_t;

    wstate_t wstate, next_wstate;

    //---------- state register logic ----------
    always @(posedge axi4_mem.ACLK or negedge axi4_mem.ARESETn) begin
        if (!axi4_mem.ARESETn) begin
            wstate <= W_IDLE;
        end else begin
            wstate <= next_wstate;
        end
    end
    
    //---------- next state logic ----------
    always @(posedge axi4_mem.ACLK) begin

        next_wstate = wstate;

        case (wstate)
            W_IDLE : begin
                if (axi4_mem.AWVALID && axi4_mem.AWREADY)
                    next_wstate = W_DATA;
            end

            W_DATA : begin
                if (axi4_mem.WLAST && axi4_mem.WVALID && axi4_mem.WREADY)
                    next_wstate = W_RESP;
            end

            W_RESP : begin
                if (axi4_mem.BREADY && axi4_mem.BVALID)
                    next_wstate = W_IDLE;
            end
        endcase
    end

    //---------- Output logic ----------
    logic [31:0] curr_word;
    logic [1:0] bresp_reg;
    logic [7:0] wbeat_count;

    always @(posedge axi4_mem.ACLK or negedge axi4_mem.ARESETn) begin
        if (!axi4_mem.ARESETn) begin

            axi4_mem.AWREADY <= 0;
            axi4_mem.WREADY  <= 0;
            axi4_mem.BVALID  <= 0;
            axi4_mem.BID     <= 0;
            axi4_mem.BRESP   <= 0;
        end
        else begin
            case (wstate)
                W_IDLE  : begin
                    axi4_mem.AWREADY <= 1;
                    axi4_mem.WREADY  <= 0;
                    axi4_mem.BVALID  <= 0;
                    wbeat_count <= 0;
                    if (axi4_mem.AWVALID && axi4_mem.AWREADY) begin
                        waddr_index <= axi4_mem.AWADDR >> 2;
                        awid_reg    <= axi4_mem.AWID;
                        awlen_reg   <= axi4_mem.AWLEN;
                        awsize_reg  <= axi4_mem.AWSIZE;
                        bresp_reg   <= (axi4_mem.AWADDR < MEM_DEPTH * 4) ? 2'b00 : 2'b10;    // RESP OKAY -> 00, SLVERR -> 10
                    end
                end
                
                W_DATA  : begin
                    axi4_mem.AWREADY <= 0;
                    axi4_mem.WREADY  <= 1;
                    axi4_mem.BVALID  <= 0;
                    if (axi4_mem.WVALID && axi4_mem.WREADY) begin
                        curr_word = mem[waddr_index];

                        for (int i=0; i<4; ++i) begin
                            if (axi4_mem.WSTRB[i])
                                curr_word[8*i +: 8]  = axi4_mem.WDATA[8*i +: 8];
                        end
                        mem[waddr_index] <= curr_word;
                        
                        // $display("%t WRITE addr=%0h data=%h strb=%b result=%h WLAST=%0b wbeat_count=%0d / AWLEN=%0d",
                        //         $time, waddr_index, axi4_mem.WDATA, axi4_mem.WSTRB, curr_word, axi4_mem.WLAST, wbeat_count, awlen_reg);
                        
                        waddr_index <= waddr_index + 1;
                        wbeat_count <= wbeat_count + 1;
                    end
                end

                W_RESP  : begin
                    axi4_mem.AWREADY <= 0;
                    axi4_mem.WREADY  <= 0;
                    axi4_mem.BVALID  <= 1;
                    axi4_mem.BID     <= awid_reg;
                    axi4_mem.BRESP   <= bresp_reg;
                end

            endcase
        end 
    end

    // gated log
    // always @(posedge axi4_mem.ACLK or negedge axi4_mem.ARESETn) begin
    //     $display("%t [DUT-I/f] %s AWREADY=%0d AWVALID=%0b AWADDR=%0h AWID=%0h", $time, wstate.name(), axi4_mem.AWREADY, axi4_mem.AWVALID, axi4_mem.AWADDR, axi4_mem.AWID);
    //     $display("%t [DUT-I/f] %s WREADY=%0d WVALID=%0b WDATA=%0h WSTRB=%0d WLAST=%0b", $time, wstate.name(), axi4_mem.WREADY, axi4_mem.WVALID, axi4_mem.WDATA, axi4_mem.WSTRB, axi4_mem.WLAST);
    //     $display("%t [DUT] %s BVALID=%0b BRESP=%0d BID=%0h", $time, wstate.name(), axi4_mem.BVALID, axi4_mem.BRESP, axi4_mem.BID);
    //     // $display("address AWADDR=%0h waddr_reg=%0h", axi4_mem.AWADDR, addr_index);
    //     // $strobe("%t mem[%0h] = %h", $time, addr_index-1, mem[addr_index-1]);
    // end

    //========== Read FSM ==========

    logic [7:0] ARLEN_reg, rbeat_count;
    logic [31:0] mem_data;

    typedef enum {
        R_IDLE,
        R_DATA
    } rstate_t;

    rstate_t rstate, next_rstate;

    //---------- state register logic ----------
    always @(posedge axi4_mem.ACLK or negedge axi4_mem.ARESETn) begin
        if (!axi4_mem.ARESETn) begin
            rstate <= R_IDLE;
        end else begin
            rstate <= next_rstate;
        end
    end

    //---------- next state logic ----------
    always @(posedge axi4_mem.ACLK) begin
        
        next_rstate = rstate;

        case (rstate)
            R_IDLE  : begin
                if (axi4_mem.ARVALID && axi4_mem.ARREADY) begin
                    next_rstate = R_DATA;
                end
            end

            R_DATA  : begin
                if (axi4_mem.RLAST && axi4_mem.RVALID && axi4_mem.RREADY) begin
                    next_rstate = R_IDLE;
                end
            end
        endcase
    end

    //---------- Output logic ----------
    logic [31:0] curr_data;

    always @(posedge axi4_mem.ACLK or negedge axi4_mem.ARESETn) begin
        if (!axi4_mem.ARESETn) begin
            axi4_mem.ARREADY <= 0;
            axi4_mem.RVALID  <= 0;
            rbeat_count  <= 0;
            axi4_mem.RLAST   <= 0;
            axi4_mem.RDATA   <= 0;
            axi4_mem.RID     <= 0;
            axi4_mem.RRESP   <= 0;
        end else begin
            case (rstate)
                R_IDLE: begin
                    axi4_mem.ARREADY <= 1;
                    axi4_mem.RVALID  <= 0;
                    rbeat_count <= 0;
                    axi4_mem.RLAST   <= 0;   
                    if (axi4_mem.ARVALID && axi4_mem.ARREADY) begin
                        raddr_index <= axi4_mem.ARADDR >> 2;
                        ARID_reg    <= axi4_mem.ARID;    
                        ARLEN_reg   <= axi4_mem.ARLEN;
                        
                    end
                end

                R_DATA: begin

                    if (!axi4_mem.RVALID || axi4_mem.RREADY) begin
                        curr_data = mem[raddr_index];

                        axi4_mem.RDATA  <= curr_data;
                        axi4_mem.RRESP  <= (curr_data !== 'x) ? 2'b00 : 2'b10;
                        axi4_mem.RID    <= ARID_reg;
                        axi4_mem.RLAST  <= (rbeat_count == ARLEN_reg);
                        axi4_mem.RVALID <= 1;

                        raddr_index <= raddr_index + 1;
                        rbeat_count <= rbeat_count + 1;
                    end
                    // else HOLD when backpressure
                    
                end
            endcase
        end
    end

    // assign axi4_mem.RDATA = mem_data;

    // Log
    // always @(posedge axi4_mem.ACLK or negedge axi4_mem.ARESETn) begin
    //     // $display("%t [DUT] %s ARREADY=%0d ARVALID=%0b ARADDR=%0h ARID=%0h", $time, rstate.name(), axi4_mem.ARREADY, axi4_mem.ARVALID, axi4_mem.ARADDR, axi4_mem.ARID);
    //     // $display("%t [DUT] %s RREADY=%0d RVALID=%0b RDATA=%0h RLAST=%0b", $time, rstate.name(), axi4_mem.RREADY, axi4_mem.RVALID, axi4_mem.RDATA, axi4_mem.RLAST);
    //     // $display("%t [DUT] %s ARADDR=%0h raddr_index=%0h beat_count=%0d", $time, rstate.name(), axi4_mem.ARADDR, raddr_index, beat_count);
        
    //     if (rstate inside {R_IDLE, R_DATA}) begin
    //         $display("%t [DUT] %s beat_count=%0d RLAST=%0b", $time, rstate.name(), beat_count, axi4_mem.RLAST);
    //     end
    // end
    
    //========== Assertions ==========
    // WLAST burst counter validation
    assert property (@(posedge axi4_mem.ACLK)
        (wstate == W_DATA && axi4_mem.WVALID && axi4_mem.WREADY && axi4_mem.WLAST)
        |-> (wbeat_count == awlen_reg)
    ) else $error("%t [DUT] WLAST/AWLEN mismatch %0d != %0d", $time, wbeat_count, awlen_reg);

endmodule
