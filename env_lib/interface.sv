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
endinterface : mod_12_if