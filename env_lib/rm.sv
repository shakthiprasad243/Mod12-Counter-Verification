class ref_model;

    mailbox #(mod12_trans) mon2rm;
    mailbox #(mod12_trans) rm2sb;

    logic [3:0] ref_count;

    mod12_trans data2sb, mon2data;

    function new(
        mailbox #(mod12_trans) mon2rm,
        mailbox #(mod12_trans) rm2sb
    );

        this.mon2rm = mon2rm;
        this.rm2sb = rm2sb;

        //ref_count = 4'd0;

    endfunction : new

    task model();
	
	if (mon2data.rst) 
		begin
   	 	ref_count <= 4'd0;
 		 end
  	else if (mon2data.load)
		 begin
  	 	 ref_count <= mon2data.data_in;
  		end
 	 else if (mon2data.mode) 
		begin
  	 	 if (ref_count == 4'd11)
   	   		ref_count <= 4'd0;
    		else
    	  	ref_count <= ref_count + 4'd1;
 		 end
 	 else 
		begin
  	  	if (ref_count == 4'd0)
    	  		ref_count <= 4'd11;
    		else
    	 		 ref_count <= ref_count - 4'd1;
 		 end
        data2sb = new mon2data;
        data2sb.count = ref_count;

    endtask : model

    virtual task start();

        fork
            forever begin

                mon2rm.get(mon2data);

                model();

                rm2sb.put(data2sb);

            end
        join_none

    endtask : start

endclass : ref_model