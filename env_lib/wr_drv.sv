class write_drv;
	virtual mod_12_if.WR_DRV wr_drv_if;
	mod12_trans data2duv;
	mailbox#(mod12_trans) gen2wr;

	function new(virtual mod_12_if.WR_DRV wr_drv_if, mailbox#(mod12_trans)gen2wr);
		this.wr_drv_if 	= wr_drv_if;
		this.gen2wr 	= gen2wr;
	endfunction : new
	
	virtual task drive();
		@(wr_drv_if.wr_drv_cb);
		
		wr_drv_if.wr_drv_cb.rst  	<= data2duv.rst;
		wr_drv_if.wr_drv_cb.mode 	<= data2duv.mode;
		wr_drv_if.wr_drv_cb.load 	<= data2duv.load;
		wr_drv_if.wr_drv_cb.data_in 	<= data2duv.data_in;
		data2duv.display("DATA IN WRITE DRIVER");
	//	@(wr_drv_if.wr_drv_cb);
	//	wr_drv_if.wr_drv_cb.load <='0;
		
	endtask : drive

	virtual task start();
		fork
			forever
				begin
					gen2wr.get(data2duv);
					drive();
					//data2duv.display("DATA ON PIN'S FROM WR_DRV");
				end
		
		join_none
	endtask : start
endclass : write_drv