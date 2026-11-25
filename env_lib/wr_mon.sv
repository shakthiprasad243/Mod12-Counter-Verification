class write_mon;

    virtual mod_12_if.WR_MON wr_mon_if;

    mod12_trans data2rm;
    mod12_trans cov_data;

    mailbox #(mod12_trans) mon2rm;

    function new(
        virtual mod_12_if.WR_MON wr_mon_if,
        mailbox #(mod12_trans) mon2rm
    );

        this.wr_mon_if = wr_mon_if;
        this.mon2rm = mon2rm;


        data2rm = new();
    endfunction : new

    task monitor();


        @(wr_mon_if.wr_mon_cb);
        data2rm.rst = wr_mon_if.wr_mon_cb.rst;
        data2rm.load = wr_mon_if.wr_mon_cb.load;
        data2rm.mode = wr_mon_if.wr_mon_cb.mode;
        data2rm.data_in = wr_mon_if.wr_mon_cb.data_in;
	data2rm.display("DATA FROM WRITE MONITOR");
	

    endtask : monitor

    task start();

        fork
		
            forever
		begin
                monitor();
        	mon2rm.put(data2rm);
		end
        join_none

    endtask : start

endclass : write_mon