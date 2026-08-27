class memory_module extends uvm_object;
    `uvm_object_utils(memory_module)

    function new(string name="memory_module");
        super.new(name);
    endfunction

    int  mem[int];

    /*rand SA,DA;
    rand bit[31:0]btt;

    constraint sa_c{SA inside {[1:1000]};}
    constraint da_c{DA inside {[1:2000]};}
    constraint aligned_address{SA%16==0;DA%16==0;}
    constraint c1{DA-SA>btt || SA-DA>btt;}*/
endclass
