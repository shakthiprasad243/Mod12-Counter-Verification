interface mod_12_if(input bit clk);

    bit [3:0] data_in;
    bit load;
    bit mode;
    bit rst;
    logic [3:0] count;

    clocking wr_drv_cb @(posedge clk);

        default input #1 output #1;

        output mode,rst,load;
        output data_in;

    endclocking : wr_drv_cb

    clocking wr_mon_cb @(posedge clk);

        default input #1 output #1;

        input mode;
        input rst;
        input load;
        input data_in;

    endclocking : wr_mon_cb

    clocking rd_mon_cb @(posedge clk);

        default input #1 output #1;

        input count;

    endclocking : rd_mon_cb

    // modport for the write driver
    modport WR_DRV(clocking wr_drv_cb);

    //modport for the writer monitor
    modport WR_MON(clocking wr_mon_cb);

    // modport for the read monitor
    modport RD_MON(clocking rd_mon_cb);

	// modport for the dut
	modport DUT(input clk,rst,mode,load,data_in,output count);

    // -------------------------------------------------------------------------
    // SystemVerilog Assertions (SVA)
    // -------------------------------------------------------------------------

    // 1. Synchronous reset has highest priority (count -> 0 on next posedge)
    property p_reset_priority;
        @(posedge clk) rst |=> (count == 4'd0);
    endproperty
    assert property (p_reset_priority)
        else $error("[SVA] Reset priority failed: expected count == 0, got %0d", count);

    // 2. Parallel load has second priority when reset is deasserted
    property p_parallel_load;
        @(posedge clk) (!rst && load) |=> (count == $past(data_in));
    endproperty
    assert property (p_parallel_load)
        else $error("[SVA] Parallel load failed: expected %0d, got %0d", $past(data_in), count);

    // 3. Up-count rollover: 11 -> 0
    property p_up_rollover;
        @(posedge clk) (!rst && !load && mode && (count == 4'd11)) |=> (count == 4'd0);
    endproperty
    assert property (p_up_rollover)
        else $error("[SVA] Up-count rollover failed: expected 0 after 11, got %0d", count);

    // 4. Up-count normal increment
    property p_up_increment;
        @(posedge clk) (!rst && !load && mode && !$isunknown(count) && (count < 4'd11))
            |=> (count == ($past(count) + 4'd1));
    endproperty
    assert property (p_up_increment)
        else $error("[SVA] Up-count increment failed: expected %0d, got %0d", $past(count) + 4'd1, count);

    // 5. Down-count underflow: 0 -> 11
    property p_down_underflow;
        @(posedge clk) (!rst && !load && !mode && (count == 4'd0)) |=> (count == 4'd11);
    endproperty
    assert property (p_down_underflow)
        else $error("[SVA] Down-count underflow failed: expected 11 after 0, got %0d", count);

    // 6. Down-count normal decrement
    property p_down_decrement;
        @(posedge clk) (!rst && !load && !mode && !$isunknown(count) && (count > 4'd0) && (count <= 4'd11))
            |=> (count == ($past(count) - 4'd1));
    endproperty
    assert property (p_down_decrement)
        else $error("[SVA] Down-count decrement failed: expected %0d, got %0d", $past(count) - 4'd1, count);

    // 7. Count must always stay within valid Mod-12 bounds [0:11] once known
    property p_valid_count_range;
        @(posedge clk) !$isunknown(count) |-> (count <= 4'd11);
    endproperty
    assert property (p_valid_count_range)
        else $error("[SVA] Out-of-range count detected: %0d", count);

endinterface : mod_12_if