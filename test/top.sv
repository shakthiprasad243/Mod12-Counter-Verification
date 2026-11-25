module top;
	import mod12_pkg::*;
   	 bit clk;

    	always #5 clk = ~clk;
	 
	mod_12_if intf(clk);
    	test test_h;
    	mod12_counter UUT (.intf(intf));

    	initial
	 begin
		
      		 test_h = new(intf.WR_DRV,intf.WR_MON,intf.RD_MON);
       		 test_h.run();
		
   	 end
	
	initial 
	begin
		$fsdbDumpfile("wave_file1.fsdb");
		$fsdbDumpvars(0,top);
	end

endmodule : top