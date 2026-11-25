class mod12_gen;

    mod12_trans gen_trans;
    mod12_trans data2send;

    mailbox #(mod12_trans) gen2wr;

    function new(mailbox #(mod12_trans) gen2wr);
        this.gen2wr	= gen2wr;
        gen_trans 	= new();
    endfunction : new

    virtual task start();

        for(int i=0; i<no_of_transactions; i++) begin

            assert(gen_trans.randomize())
            else $fatal("Randomization failed");

            data2send = new gen_trans;
            //data2send.trans_id ++;
            gen2wr.put(data2send);

        end

    endtask : start

endclass : mod12_gen