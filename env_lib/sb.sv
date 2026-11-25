class sb;
    mailbox #(mod12_trans) rm2sb, mon2sb;
    mod12_trans rm_data, rcvd_data;

    event DONE;

    int data_verified = 0;
    int rm_data_count = 0;

    int pass_count = 0;
    int fail_count = 0;

    covergroup mod12_cg;

        option.per_instance = 1;

        // Reset coverage
        RESET: coverpoint rm_data.rst {
            bins reset_asserted = {1};
            bins reset_deasserted = {0};
        }

        // Mode coverage
        MODE: coverpoint rm_data.mode {
            bins down_count = {0};
            bins up_count = {1};
        }

        // Load coverage
        LOAD: coverpoint rm_data.load {
            bins load_disabled = {0};
            bins load_enabled = {1};
        }

        // Data input coverage
        DATA_IN: coverpoint rm_data.data_in {
            bins valid_data = {[0:4]};
            bins count_values1 = {[5:9]};
            bins count_values2	 = {[9:11]};
            illegal_bins invalid_data = {[12:15]};
        }

        // Output count coverage
        COUNT: coverpoint rm_data.count {
            bins count_values = {[0:11]};
            illegal_bins invalid_count = {[12:15]};
        }

        // Mode and load combinations
       // MODE_LOAD: cross MODE, LOAD;

        // Reset and load combinations
       // RESET_LOAD: cross RESET, LOAD;

	COUNT2 : cross MODE, COUNT; 

    endgroup : mod12_cg

    function new(
        mailbox #(mod12_trans) rm2sb,
        mailbox #(mod12_trans) mon2sb
    );

        this.rm2sb = rm2sb;
        this.mon2sb = mon2sb;

        mod12_cg = new();

    endfunction : new

    task start();

        fork
            forever begin

                rm2sb.get(rm_data);
                rm_data_count++;

                mon2sb.get(rcvd_data);

                check(rcvd_data);

                mod12_cg.sample();

                if(data_verified >= no_of_transactions)
		  begin
		    
		    $display("------------------------------------------------------------");
                    $display("Total Data Verified = %0d",data_verified);
                    $display("PASS COUNT = %0d",pass_count);
                    $display("FAIL COUNT = %0d",fail_count);

                    $display("Functional Coverage = %0.2f%%",mod12_cg.get_coverage());
		    $display("------------------------------------------------------------");

                    ->DONE;

                end

            end
        join_none

    endtask : start

  function bit check(mod12_trans rc_data);

    data_verified++;

    if(rm_data.count === rc_data.count) 
	begin

        pass_count++;
	$display("========================================================");
//	$display("\t Transaction id corresponding = %0d",mod12_trans.trans_id);
        $display("[%0t] Count is Correct | Actual = %0d | Expected = %0d",$time, rc_data.count, rm_data.count);
	$display("========================================================");

        return 1;

    	end

    else begin

        fail_count++;
	
	$display("========================================================");
//	$display("\t Transaction id corresponding = %0d",mod12_trans.trans_id);
        $display("[%0t] Count is Incorrect | Actual = %0d | Expected = %0d", $time, rc_data.count, rm_data.count);
	$display("========================================================");
        return 0;

    end

endfunction : check 

endclass : sb