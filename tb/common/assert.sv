module axi_read_checker (
    input logic                ACLK,
    input logic                ARESETn,

    // AXI Read Address Channel
    input logic                ARVALID,
    input logic                ARREADY,
    input logic [ID_WIDTH-1:0] ARID,

    // AXI Read Data Channel
    input logic                RVALID,
    input logic                RREADY,
    input logic                RLAST,
    input logic [ID_WIDTH-1:0] RID
);

    // =====================================================
    // 1. Transaction-level scoreboard
    // =====================================================

    typedef struct {
        logic [ID_WIDTH-1:0] id;
        longint unsigned     seq;
    } transaction_t;

    // Each accepted AR transaction gets a unique entry.
    transaction_t outstanding[$];

    // Matching queue index
    int match_idx[$];

    longint unsigned next_sequence;

    // =====================================================
    // 2. Interleaving tracking
    // =====================================================

    logic previous_r_valid;
    logic previous_burst_open;
    logic [ID_WIDTH-1:0] previous_rid;

    // =====================================================
    // 3. Coverage events
    // =====================================================

    logic read_in_order_evt;
    logic read_ooo_evt;
    logic read_interleave_evt;

    // =====================================================
    // 4. Statistics
    // =====================================================

    int unsigned max_outstanding;

    // =====================================================
    // 5. Transaction scoreboard
    // =====================================================

    always @(posedge ACLK) begin

        // Coverage event pulses
        read_in_order_evt   <= 1'b0;
        read_ooo_evt        <= 1'b0;
        read_interleave_evt <= 1'b0;

        if (!ARESETn) begin

            outstanding.delete();

            next_sequence       = 0;
            max_outstanding     = 0;

            previous_r_valid    = 0;
            previous_burst_open = 0;
            previous_rid        = '0;

        end
        else begin

            // ---------------------------------------------
            // A. Accept read address transaction
            // ---------------------------------------------

            if (ARVALID && ARREADY) begin

                outstanding.push_back('{
                    id:       ARID,
                    seq: next_sequence
                });

                $display(
                    "[AXI OOO] AR ACCEPTED: ID=%0h SEQ=%0d",
                    ARID, next_sequence
                );

                next_sequence++;

                if (outstanding.size() > max_outstanding)
                    max_outstanding = outstanding.size();

            end

            // ---------------------------------------------
            // B. Accept read data beat
            // ---------------------------------------------

            if (RVALID && RREADY) begin

                // Find oldest outstanding transaction
                // matching this RID.
                //
                // Important: Multiple outstanding transactions
                // with the same ID are supported.

                match_idx = outstanding.find_index()
                            with (item.id == RID);

                if (match_idx.size() == 0) begin

                    $error(
                        "[AXI OOO] UNEXPECTED RESPONSE: RID=%0h",
                        RID
                    );

                end
                else begin

                    // -------------------------------------
                    // C. Detect actual beat interleaving
                    // -------------------------------------

                    if (previous_r_valid &&
                        previous_burst_open &&
                        (previous_rid != RID)) begin

                        read_interleave_evt <= 1'b1;

                        $display("[AXI INTERLEAVE] Previous RID=%0h | Current RID=%0h",previous_rid, RID);

                    end

                    // -------------------------------------
                    // D. Complete transaction on RLAST
                    // -------------------------------------

                    if (RLAST) begin

                        // Index zero = oldest globally
                        // outstanding transaction.
                        if (match_idx[0] == 0) begin

                            read_in_order_evt <= 1'b1;

                            $display("[AXI IN-ORDER] ID=%0h SEQ=%0d",RID,outstanding[match_idx[0]].seq);

                        end
                        else begin

                            read_ooo_evt <= 1'b1;

                            $display("[AXI OUT-OF-ORDER] ID=%0h SEQ=%0d | QUEUE_INDEX=%0d",RID,outstanding[match_idx[0]].seq,match_idx[0]);

                        end

                        // Delete the oldest matching transaction.
                        // Never delete another transaction with
                        // the same RID.

                        outstanding.delete(match_idx[0]);

                    end

                    // -------------------------------------
                    // E. Update previous R-channel beat
                    // -------------------------------------

                    previous_rid        = RID;
                    previous_r_valid    = 1'b1;
                    previous_burst_open = !RLAST;

                end
            end

        end
    end

    // =====================================================
    // 6. Cover properties
    // =====================================================

    cover_read_in_order:
        cover property (
            @(posedge ACLK)
            disable iff (!ARESETn)
            read_in_order_evt
        );

    cover_read_out_of_order:
        cover property (
            @(posedge ACLK)
            disable iff (!ARESETn)
            read_ooo_evt
        );

    cover_read_interleaving:
        cover property (
            @(posedge ACLK)
            disable iff (!ARESETn)
            read_interleave_evt
        );

endmodule
