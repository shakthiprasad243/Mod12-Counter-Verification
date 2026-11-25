module mod12_counter (mod_12_if.DUT intf );

    always_ff@(posedge intf.clk) begin
        if (intf.rst)
            intf.count <= 4'd0;

        else if (intf.load)
	 begin
                intf.count <= intf.data_in;
        end

        else if (intf.mode) 
		begin
            if (intf.count == 4'd11)
                intf.count <= 4'd0;
            else
                intf.count = intf.count+1;
        end

        else begin
            if (intf.count == 4'd0)
                intf.count <= 4'd11;
            else
                intf.count <= intf.count -1;
        end

    end

endmodule