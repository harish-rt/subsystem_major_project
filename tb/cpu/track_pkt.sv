class track_pkt extends uvm_object;
    `uvm_object_utils(track_pkt)
    `NEW_OBJ

    int write_in,   read_in;
    int write_done, read_done;

    function bit tx_done();
        return (write_in == write_done)&&(read_in == read_done);
    endfunction
endclass
