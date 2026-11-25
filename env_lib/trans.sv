class mod12_trans;

    // signals need to be randonmized
    rand bit mode;
    rand bit rst;
    rand bit load;
    rand bit [3:0] data_in;
    logic [3:0] count; // output
	int value_c = 0 ;//  to control the mode
    constraint rst_c {rst dist {0:=90,1:=10};}

    //constraint for mode
    constraint mode_c {
		if(value_c<=11)
		mode ==0;
		else 
		mode ==1;}
	constraint mode_c2{mode dist{0:=50,1:=50};}

    //constraint for the data_in
    constraint data_in_c {
		if(load==1)
			data_in inside {[0:11]};
		else 
			data_in == 0;}

    // constraint for the load
    constraint load_c {load dist {0:=60,1:=40};}

    // to get track of no.of.transactions
    int trans_id;

    function new();
        mode 	= 0;
        rst 	= 0;
        load 	= 0;
        data_in = 0;
        trans_id= 0;
    endfunction : new

	function void display(string s);
		$display("========================================================");
		$display("\t%s",s);
		$display($time,"\tTransaction NO : %0d",trans_id);
		$display("\tRESET		= %0d",rst);
		$display("\tMODE		= %0d",mode);
		$display("\tLOAD		= %0d",load);
		$display("\tInput Data		= %0d",data_in);  
		$display("\tCount		= %0d",count); 
		$display("========================================================");
	endfunction : display

	function void post_randomize();
		trans_id ++;
		if(value_c <23)
		value_c++;
		else
		value_c = 0;
		display("DATA RANDOMISED");
	endfunction : post_randomize
endclass : mod12_trans