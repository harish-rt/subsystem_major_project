// -----------------------------------------------------------------------------
// axi4_memory_unit
// Simple AXI4 (full) slave memory model / RTL.
//  - Independent read and write FSMs (concurrent read + write supported)
//  - FIXED / INCR / WRAP bursts, any AxLEN (0..255), any AxSIZE <= bus width
//  - Narrow and unaligned transfers handled via WSTRB / byte lanes
//  - Out-of-window accesses return SLVERR (writes are dropped)
//  - One outstanding transaction per channel (AWREADY/ARREADY low while busy)
//  - Optional preload with $readmemh (INIT_FILE)
// Expects interface signals: ACLK, ARESETn,
//   AW{ID,ADDR,LEN,SIZE,BURST,VALID,READY}, W{DATA,STRB,LAST,VALID,READY},
//   B{ID,RESP,VALID,READY}, AR{ID,ADDR,LEN,SIZE,BURST,VALID,READY},
//   R{ID,DATA,RESP,LAST,VALID,READY}
// -----------------------------------------------------------------------------
module axi4_memory_unit #(
    parameter                 AXI_ID_WIDTH  = 7,
    parameter                 AXI_AW        = 32,
    parameter                 AXI_DW        = 32,
    parameter                 AXI_SW        = AXI_DW/8,
    parameter                 MEM_ADDR_BITS = 20,            // memory size = 2**MEM_ADDR_BITS bytes
    parameter [AXI_AW-1:0]    MEM_BASE      = 32'hC000_0000,
    parameter                 INIT_FILE     = ""             // optional $readmemh file (byte per line)
)(
    axi4_intf s_axi4_intf
);

    localparam integer LSB       = $clog2(AXI_SW);
    localparam integer MEM_DEPTH = 1 << MEM_ADDR_BITS;

    localparam [1:0] BURST_FIXED = 2'b00, BURST_INCR = 2'b01, BURST_WRAP = 2'b10;
    localparam [1:0] RESP_OKAY   = 2'b00, RESP_SLVERR = 2'b10;

    // Byte-addressable memory
    logic [7:0] mem [0:MEM_DEPTH-1];

    initial begin
        for (int k = 0; k < MEM_DEPTH; k++) mem[k] = 8'h00;
        if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
    end

    // -------------------------------------------------------------------------
    // Helper functions
    // -------------------------------------------------------------------------
    function automatic logic in_range(input logic [AXI_AW-1:0] a);
        return (a >= MEM_BASE) && ((a - MEM_BASE) < MEM_DEPTH);
    endfunction

    // Memory index of the bus-width-aligned word containing address a
    function automatic logic [MEM_ADDR_BITS-1:0] bus_base(input logic [AXI_AW-1:0] a);
        logic [AXI_AW-1:0] off;
        off = (a - MEM_BASE) & ({AXI_AW{1'b1}} << LSB);
        return off[MEM_ADDR_BITS-1:0];
    endfunction

    // Next beat address (AXI4 spec A3.4.1)
    function automatic logic [AXI_AW-1:0] next_addr(
        input logic [AXI_AW-1:0] addr,
        input logic [7:0]        len,
        input logic [2:0]        size,
        input logic [1:0]        burst);
        logic [AXI_AW-1:0] nb, aligned, inc, wmask;
        nb      = AXI_AW'(1) << size;
        aligned = addr & ~(nb - 1);
        inc     = aligned + nb;
        case (burst)
            BURST_FIXED: return addr;
            BURST_WRAP : begin
                wmask = (nb * (AXI_AW'(len) + 1)) - 1;      // total bytes - 1 (power of 2)
                return (addr & ~wmask) | (inc & wmask);
            end
            default    : return inc;
        endcase
    endfunction

    // -------------------------------------------------------------------------
    // Write channel
    // -------------------------------------------------------------------------
    typedef enum logic [1:0] {W_IDLE, W_DATA, W_RESP} w_state_t;
    w_state_t                w_state;
    logic [AXI_AW-1:0]       w_addr;
    logic [7:0]              w_len;
    logic [2:0]              w_size;
    logic [1:0]              w_burst;
    logic [AXI_ID_WIDTH-1:0] w_id;
    logic                    w_err;

    assign s_axi4_intf.AWREADY = (w_state == W_IDLE);
    assign s_axi4_intf.WREADY  = (w_state == W_DATA);
    assign s_axi4_intf.BVALID  = (w_state == W_RESP);
    assign s_axi4_intf.BID     = w_id;
    assign s_axi4_intf.BRESP   = w_err ? RESP_SLVERR : RESP_OKAY;

    wire                       w_beat   = (w_state == W_DATA) && s_axi4_intf.WVALID;
    wire                       w_ok     = in_range(w_addr);
    wire [MEM_ADDR_BITS-1:0]   w_base   = bus_base(w_addr);

    always @(posedge s_axi4_intf.ACLK) begin
        if (!s_axi4_intf.ARESETn) begin
            w_state <= W_IDLE;
            w_addr  <= '0;
            w_len   <= '0;
            w_size  <= '0;
            w_burst <= BURST_INCR;
            w_id    <= '0;
            w_err   <= 1'b0;
        end else begin
            case (w_state)
                W_IDLE: if (s_axi4_intf.AWVALID) begin
                    w_addr  <= s_axi4_intf.AWADDR;
                    w_len   <= s_axi4_intf.AWLEN;
                    w_size  <= s_axi4_intf.AWSIZE;
                    w_burst <= s_axi4_intf.AWBURST;
                    w_id    <= s_axi4_intf.AWID;
                    w_err   <= 1'b0;
                    w_state <= W_DATA;
                end

                W_DATA: if (s_axi4_intf.WVALID) begin
                    if (!w_ok) w_err <= 1'b1;
                    w_addr <= next_addr(w_addr, w_len, w_size, w_burst);
                    if (s_axi4_intf.WLAST) w_state <= W_RESP;
                end

                W_RESP: if (s_axi4_intf.BREADY) w_state <= W_IDLE;

                default: w_state <= W_IDLE;
            endcase
        end
    end

    // Memory write (no reset, kept separate from control FSM)
    always @(posedge s_axi4_intf.ACLK) begin
        if (w_beat && w_ok) begin
            for (int b = 0; b < AXI_SW; b++) begin
                if (s_axi4_intf.WSTRB[b])
                    mem[w_base + b] <= s_axi4_intf.WDATA[b*8 +: 8];
            end
        end
    end

    // -------------------------------------------------------------------------
    // Read channel
    // -------------------------------------------------------------------------
    typedef enum logic {R_IDLE, R_DATA} r_state_t;
    r_state_t                r_state;
    logic [AXI_AW-1:0]       r_addr;
    logic [7:0]              r_len;      // remaining beats - 1
    logic [2:0]              r_size;
    logic [1:0]              r_burst;
    logic [7:0]              r_total_len;
    logic [AXI_ID_WIDTH-1:0] r_id;

    wire                     r_ok   = in_range(r_addr);
    wire [MEM_ADDR_BITS-1:0] r_base = bus_base(r_addr);

    logic [AXI_DW-1:0] rdata_c;

    always @(*) begin
        rdata_c = '0;
        if (r_state == R_DATA && r_ok) begin
            for (int b = 0; b < AXI_SW; b++) begin
                rdata_c[b*8 +: 8] = mem[r_base + b];
            end
        end
    end

    assign s_axi4_intf.ARREADY = (r_state == R_IDLE);
    assign s_axi4_intf.RVALID  = (r_state == R_DATA);
    assign s_axi4_intf.RID     = (r_state == R_DATA) ? r_id : '0;
    assign s_axi4_intf.RDATA   = rdata_c;
    assign s_axi4_intf.RRESP   = (r_state == R_DATA) ? (r_ok ? RESP_OKAY : RESP_SLVERR) : RESP_OKAY;
    assign s_axi4_intf.RLAST   = (r_state == R_DATA) && (r_len == 8'd0);

    always @(posedge s_axi4_intf.ACLK) begin
        if (!s_axi4_intf.ARESETn) begin
            r_state     <= R_IDLE;
            r_addr      <= '0;
            r_len       <= '0;
            r_total_len <= '0;
            r_size      <= '0;
            r_burst     <= BURST_INCR;
            r_id        <= '0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    if (s_axi4_intf.ARVALID) begin
                        r_addr      <= s_axi4_intf.ARADDR;
                        r_len       <= s_axi4_intf.ARLEN;
                        r_total_len <= s_axi4_intf.ARLEN;
                        r_size      <= s_axi4_intf.ARSIZE;
                        r_burst     <= s_axi4_intf.ARBURST;
                        r_id        <= s_axi4_intf.ARID;
                        r_state     <= R_DATA;
                    end
                end

                R_DATA: begin
                    if (s_axi4_intf.RREADY) begin
                        if (r_len == 8'd0) begin
                            r_state <= R_IDLE;
                        end else begin
                            r_len  <= r_len - 8'd1;
                            r_addr <= next_addr(r_addr, r_total_len, r_size, r_burst);
                        end
                    end
                end

                default: r_state <= R_IDLE;
            endcase
        end
    end

    initial begin
        $display("%m: AXI_ID_WIDTH=%0d  bits(AWID)=%0d bits(BID)=%0d bits(ARID)=%0d bits(RID)=%0d",AXI_ID_WIDTH, $bits(s_axi4_intf.AWID), $bits(s_axi4_intf.BID),$bits(s_axi4_intf.ARID), $bits(s_axi4_intf.RID));
        if($bits(s_axi4_intf.BID) != AXI_ID_WIDTH || $bits(s_axi4_intf.AWID) != AXI_ID_WIDTH)
            $error("ID width mismatch between module and interface");
    end

endmodule
