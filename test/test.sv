class test;

    virtual mod_12_if.WR_DRV wr_drv_if;
    virtual mod_12_if.WR_MON wr_mon_if;
    virtual mod_12_if.RD_MON rd_mon_if;

    mod_env env_h;

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

        env_h = new(wr_drv_if,wr_mon_if,rd_mon_if);
        env_h.build();

    endtask : build

    task run();

        build();
        env_h.run();
	$finish;

    endtask : run

endclass : test