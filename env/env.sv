class mod_env;

    virtual mod_12_if.WR_DRV wr_drv_if;
    virtual mod_12_if.WR_MON wr_mon_if;
    virtual mod_12_if.RD_MON rd_mon_if;

    mailbox #(mod12_trans) gen2wr = new();
    mailbox #(mod12_trans) mon2rm = new();
    mailbox #(mod12_trans) mon2sb = new();
    mailbox #(mod12_trans) rm2sb = new();

    mod12_gen gen_h;
    write_drv wr_drv_h;
    write_mon wr_mon_h;
    read_mon rd_mon_h;
    ref_model ref_mod_h;
    sb sb_h;

    function new(
        virtual mod_12_if.WR_DRV wr_drv_if,
        virtual mod_12_if.WR_MON wr_mon_if,
        virtual mod_12_if.RD_MON rd_mon_if
    );

        this.wr_drv_if = wr_drv_if;
        this.wr_mon_if = wr_mon_if;
        this.rd_mon_if = rd_mon_if;

    endfunction : new

    task build();

        gen_h = new(gen2wr);
        wr_drv_h = new(wr_drv_if,gen2wr);
        wr_mon_h = new(wr_mon_if,mon2rm);
        rd_mon_h = new(rd_mon_if,mon2sb);
        ref_mod_h = new(mon2rm,rm2sb);
        sb_h = new(rm2sb,mon2sb);

    endtask : build

    task start();

        sb_h.start();
        ref_mod_h.start();

        wr_mon_h.start();
        rd_mon_h.start();

        wr_drv_h.start();
	gen_h.start();
	
	/*gen_h.start();
	wr_drv_h.start();
	wr_mon_h.start();
	rd_mon_h.start();
	ref_mod_h.start();
	sb_h.start();*/

    endtask : start

    task stop();

        wait(sb_h.DONE.triggered);

    endtask : stop

    task run();

        start();
        stop();

    endtask : run

endclass : mod_env