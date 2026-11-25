class read_mon;

    virtual mod_12_if.RD_MON rd_mon_if;
    mailbox #(mod12_trans) mon2sb;

    mod12_trans data2sb;

    function new(virtual mod_12_if.RD_MON rd_mon_if, mailbox #(mod12_trans) mon2sb );

        this.rd_mon_if = rd_mon_if;
        this.mon2sb = mon2sb;

        data2sb = new();
    endfunction : new

    task monitor();


        @(rd_mon_if.rd_mon_cb);

        data2sb.count = rd_mon_if.rd_mon_cb.count;
	data2sb.display("DATA FROM DUT");
        mon2sb.put(data2sb);

    endtask : monitor

    task start();

        fork
		
            forever begin
                monitor();
            end
        join_none

    endtask : start

endclass : read_mon