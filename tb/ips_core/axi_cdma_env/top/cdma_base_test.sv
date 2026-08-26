class cdma_base_test extends uvm_test;
   `uvm_component_utils (cdma_base_test)					//factory registration
   //env          en_h;							//AXI_interconnect_env instantiation
   //virtual_sequence_base    vseq;					//virtual_sequence
   //virtual_sequencer        vseqr;					//virtual_sequencer				
   axi_cdma_config_obj               obj;					//config_object
    
   //cdma_base_test:: class_constructor
   function new (string name = "ic_base_test" , uvm_component parent);
      super.new(name,parent);
    endfunction

  //cdma_base_test:: build
  function void build_phase 			(uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("test::build_phase" , phase.get_name() , UVM_MEDIUM)
      //en_h = env :: type_id :: create ("en_h", this);					//creating axi_ic_env 
      //vseq  = virtual_sequence_base :: type_id :: create ("vseq");			//creating axi_ic_virtual_sequence_base
      //vseqr = virtual_sequencer :: type_id :: create ("vseqr",this);			//creating axi_ic_virtual_sequencer
  endfunction : build_phase

  //cdma_base_test:: elaboration
  function void end_of_elaboration_phase 	(uvm_phase phase);
     super.end_of_elaboration_phase (phase);
    `uvm_info ("test::end_of_elaboration"  , phase.get_name() , UVM_MEDIUM)
     uvm_top.print_topology();								//printing topology
  endfunction : end_of_elaboration_phase

  //cdma_base_test:: reset_phase
  /*task reset_phase (uvm_phase phase);
     `uvm_info(get_full_name(),"inside reset phase", UVM_MEDIUM)
     phase.raise_objection (this);  
     if(!uvm_config_db #(axi_cdma_config_obj) :: get(null, "*", "axi_cdma_config_obj", obj))
       `uvm_fatal (get_full_name(), "config_db not accessable");
     //wait (obj.mas_if[0].areset_n);
     phase.drop_objection (this);
  endtask: reset_phase*/

 /* task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    phase.drop_objection(this);
    `uvm_info ("test:: main_phase", "run_phse completed", UVM_MEDIUM)
  endtask: main_phase*/
endclass :cdma_base_test

//////////////////ral reset test //////////////////////////////

/*class ral_reset_test extends cdma_base_test;
    `uvm_component_utils(ral_reset_test)

    function new(string name="ral_res_test",uvm_component parent);
      super.new(name,parent);
    endfunction
    uvm_status_e status;
    uvm_reg_data_t data;
    axi_cdma_config_obj obj;
    task main_phase(uvm_phase phase);
        uvm_reg_hw_reset_seq res_seq;
        res_seq=uvm_reg_hw_reset_seq::type_id::create("res_seq");
        phase.raise_objection(this);
            uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.cdmacr.get_full_name()},"NO_REG_TESTS",1,this);
            en_h.reg_model.cdmacr.write(status,32'h8);
            en_h.reg_model.cdmacr.read(status,data);

            if(data[3]!=1)begin
                `uvm_error("ral_reset_test","Failed to configure ")
            end
            res_seq.model=en_h.reg_model;
            fork
                res_seq.start(null);
                begin
                #2;
                  res_seq.set_response_queue_error_report_disabled(1);  
                end
            join_none
            #1600ns;
            phase.drop_objection(this);
    endtask
endclass


////////////////////////// ral_intermediate_reset_test//////////////////////////////////////
class ral_reset_inter_test extends cdma_base_test;
    `uvm_component_utils(ral_reset_inter_test)

    virtual master_intf  master_drv_intf;
    uvm_status_e status;
    uvm_reg_data_t data;
    axi_cdma_config_obj obj;

    function new(string name="ral_reset_inter_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    

    task main_phase(uvm_phase phase);

        uvm_reg_hw_reset_seq reset_seq;
        reset_seq=uvm_reg_hw_reset_seq::type_id::create("reset_seq");

        phase.raise_objection(this);
        reset_seq.model = en_h.reg_model;

         en_h.reg_model.cdmacr.write(status,32'h8);
         en_h.reg_model.sa.write(status,32'hFFFF_FFFF);
         en_h.reg_model.da.write(status,32'hFFFF_FFFF);
         en_h.reg_model.curdesc_pnt.write(status,32'hFFFF_FFFF);
         en_h.reg_model.curdesc_pnt_msb.write(status,32'hFFFF_FFFF);
         en_h.reg_model.taildesc_pnt.write(status,32'hFFFF_FFFF);
         en_h.reg_model.taildesc_pnt_msb.write(status,32'hFFFF_FFFF);
         en_h.reg_model.sa_msb.write(status,32'hFFFF_FFFF);
         en_h.reg_model.da_msb.write(status,32'hFFFF_FFFF);
         
         en_h.reg_model.reset();
           fork
                reset_seq.start(en_h.m_agt[0].sqr);
                begin
                    #5;
                    reset_seq.set_response_queue_error_report_disabled(1);

                end
           join
          repeat (200) @ (posedge obj.mas_if[0].aclk);
         phase.drop_objection(this);
    endtask
endclass

/////////////////////////// Bit bash test //////////////////////
/*class bit_bash_test extends cdma_base_test;
    `uvm_component_utils(bit_bash_test)
    uvm_status_e status;
    uvm_reg_data_t data;
    bit[31:0] data_t;
    function new(string name="bit_bash_seq",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
       uvm_reg_bit_bash_seq bit_bash_seq;
       bit_bash_seq=uvm_reg_bit_bash_seq::type_id::create("bit_bash_seq");
       phase.raise_objection(this);

        bit_bash_seq.model=en_h.reg_model;
        uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.cdmacr.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.cdmasr.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.taildesc_pnt.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.taildesc_pnt_msb.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.curdesc_pnt.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.curdesc_pnt_msb.get_full_name()},"NO_REG_TESTS",1,this);
       // uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.sa.get_full_name()},"NO_REG_TESTS",1,this);
       // uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.sa_msb.get_full_name()},"NO_REG_TESTS",1,this);
       // uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.da.get_full_name()},"NO_REG_TESTS",1,this);
       // uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.da_msb.get_full_name()},"NO_REG_TESTS",1,this);
        uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.btt.get_full_name()},"NO_REG_TESTS",1,this);
        en_h.reg_model.cdmacr.Reset.set_compare(UVM_NO_CHECK);
        #100;
        
            en_h.reg_model.cdmacr.write(status,32'b0000_0000_0000_0000_0000_1000);
            #20;
            en_h.reg_model.cdmacr.read(status,data);
        fork
            #10;
            en_h.reg_model.cdmacr.read(status,data_t);
            bit_bash_seq.start(en_h.m_agt[0].sqr);
            begin
               #2;
               bit_bash_seq.reg_seq.set_response_queue_error_report_disabled(1);
            end
        join
        #1000000;
       phase.drop_objection(this);
    endtask
        
endclass


////////////////ral register access test using uvm_reg_access_seq ///////////

/*class cdma_reg_access_test extends cdma_base_test;
    `uvm_component_utils(cdma_reg_access_test)
    uvm_status_e status;
    bit[31:0] rdata;
    function new(string name="cdma_reg_access_test",uvm_component parent);
        super.new(name,parent);
    endfunction 

        uvm_reg_access_seq seq1;
    task main_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq1=uvm_reg_access_seq::type_id::create("seq1");

        seq1.model=en_h.reg_model;

        en_h.reg_model.cdmacr.write(status,32'h8);
        en_h.reg_model.cdmacr.read(status,rdata);
        #10;
        `uvm_info("REG_ACCESS_TEST",$sformatf("------cdmacr=%h--------",rdata),UVM_LOW);

        uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.cdmacr.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.cdmasr.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.taildesc_pnt.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.taildesc_pnt_msb.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.curdesc_pnt.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.curdesc_pnt_msb.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.sa.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.sa_msb.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.da.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.da_msb.get_full_name()},"NO_REG_TESTS",1,this);
        //uvm_resource_db#(bit)::set({"REG::",en_h.reg_model.btt.get_full_name()},"NO_REG_TESTS",1,this);

        en_h.reg_model.cdmasr.read(status,rdata);
        `uvm_info("read_for_idle",$sformatf("----cdmasr[1]=%0h",rdata),UVM_LOW)
         do begin
            @(posedge obj.mas_if[0].aclk);
        end while(rdata[1]==0);
        //seq1.start(null);

        seq1.start(en_h.m_agt[0].sqr);
        #100000;
        phase.drop_objection(this);
    endtask
endclass


//////////////Register read and write via ral/////////
/*class config_sa_test extends cdma_base_test;
    `uvm_component_utils(config_sa_test)

    function new(string name="config_sa_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        reg_sequence seq1;
        seq1=reg_sequence::type_id::create("seq1");
        phase.raise_objection(this);
        seq1.reg_model=en_h.reg_model;
        seq1.start(en_h.m_agt[0].sqr);
        #10ns;
        phase.drop_objection(this);
    endtask
endclass

///////test with btt val equal to 1////////
/*class btt_1_test extends cdma_base_test;
    `uvm_component_utils(btt_1_test)

    function new(string name="btt_1_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
       btt_1_seq m_seq=btt_1_seq::type_id::create("m_seq");
       base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
       phase.raise_objection(this);
       fork 
        s_seq.start(en_h.s_agt[1].sqr);
       join_none
       m_seq.reg_model=en_h.reg_model;
       m_seq.start(en_h.m_agt[0].sqr);
       #100ns;
       phase.drop_objection(this);
    endtask
endclass


////////////simple mode wr_rd test /////////////
/*class simple_mode_inc_test extends cdma_base_test;
    `uvm_component_utils(simple_mode_inc_test)

    function new(string name="simple_mode_inc_test",uvm_component parent);
            super.new(name,parent);
    endfunction

    simple_mode_inc_v_seq inc_seq;
   task main_phase(uvm_phase phase);
   inc_seq=simple_mode_inc_v_seq::type_id::create("inc_seq");
    phase.raise_objection(this);
    inc_seq.start(en_h.vseqr);
    #100ns;
    phase.drop_objection(this);
   endtask
endclass

///////// simple mode keyhole read incremental write test ////////////////
/*class keyhole_read_inc_write_test extends cdma_base_test;
    `uvm_component_utils(keyhole_read_inc_write_test)

    function new(string name="keyhole_read_inc_write_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        keyhole_read_inc_wr_seq keyhole_read_seq;
        base_slave_sequence  s_seq;

        phase.raise_objection(this);
            s_seq=base_slave_sequence::type_id::create("s_seq");
            keyhole_read_seq=keyhole_read_inc_wr_seq::type_id::create("keyhole_read_seq");
            keyhole_read_seq.reg_model=en_h.reg_model;

            fork
                begin
                #10;
                s_seq.start(en_h.s_agt[1].sqr);
                end
            join_none
            keyhole_read_seq.start(en_h.m_agt[0].sqr);


            #100ns;
        phase.drop_objection(this);
    endtask
endclass

///////////////////simple mode keyhole write test ///////////////
/*class keyhole_write_test extends cdma_base_test;
    `uvm_component_utils(keyhole_write_test)

    function new(string name="keyhole_write_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        keyhole_write_seq keyhole_wr_seq=keyhole_write_seq::type_id::create("keyhole_wr_seq");
        base_slave_sequence slave_seq=base_slave_sequence::type_id::create("slave_seq");
        phase.raise_objection(this);
            keyhole_wr_seq.reg_model=en_h.reg_model;
            fork
                slave_seq.start(en_h.s_agt[1].sqr);
            join_none
            keyhole_wr_seq.start(en_h.m_agt[0].sqr);
            #500ns;
        phase.drop_objection(this);
    endtask
endclass


///////////////// keyhole read write test /////////////////
/*class keyhole_rd_wr_test extends cdma_base_test;
    `uvm_component_utils(keyhole_rd_wr_test)

    function new(string name="keyhole_rd_wr_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        keyhole_rd_wr_seq keyhole_mseq;
        base_slave_sequence slave_seq;
        phase.raise_objection(this);
            keyhole_mseq=keyhole_rd_wr_seq::type_id::create("keyhole_mseq");
            slave_seq=base_slave_sequence::type_id::create("slave_seq");
            keyhole_mseq.reg_model=en_h.reg_model;
            fork
                slave_seq.start(en_h.s_agt[1].sqr);
            join_none
            keyhole_mseq.start(en_h.m_agt[0].sqr);
            #100ns;
        phase.drop_objection(this);
    endtask
endclass

/////////////simple mode incremental 4k test ///////////
/*class simple_mode_inc_4k_test extends cdma_base_test;
`uvm_component_utils(simple_mode_inc_4k_test)

function new(string name="simple_mode_inc_4k_test",uvm_component parent);
super.new(name,parent);
endfunction

task main_phase(uvm_phase phase);
    simple_inc_4k m_seq=simple_inc_4k::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    phase.raise_objection(this);
        m_seq.reg_model=en_h.reg_model;
        fork
            s_seq.start(en_h.s_agt[1].sqr);
        join_none
            m_seq.start(en_h.m_agt[0].sqr);
    phase.drop_objection(this);
endtask
endclass

///////////////////Simple mode inc 4kcross////////////
/*class simple_mode_inc_4kcross_test extends cdma_base_test;
`uvm_component_utils(simple_mode_inc_4kcross_test)

function new(string name="simple_mode_inc_4kcross_test",uvm_component parent);
super.new(name,parent);
endfunction

task main_phase(uvm_phase phase);
    simple_mode_inc4kcross m_seq=simple_mode_inc4kcross::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    phase.raise_objection(this);
        m_seq.reg_model=en_h.reg_model;
        fork
            s_seq.start(en_h.s_agt[1].sqr);
        join_none
        m_seq.start(en_h.m_agt[0].sqr);
        #10000ns;
    phase.drop_objection(this);
endtask
endclass

//////////simple mode fixed 4k test ///////////////
/*class simple_mode_fixed_4ktest extends cdma_base_test;
`uvm_component_utils(simple_mode_fixed_4ktest)

function new(string name="simple_mode_fixed_4ktest",uvm_component parent);
super.new(name,parent);
endfunction

task main_phase(uvm_phase phase);
    fixed_btt_4k m_seq=fixed_btt_4k::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    phase.raise_objection(this);
    m_seq.reg_model=en_h.reg_model;
    fork
        s_seq.start(en_h.s_agt[1].sqr);
    join_none
    m_seq.start(en_h.m_agt[0].sqr);
    #100ns;
    phase.drop_objection(this);
endtask
endclass

////////////////////slave error test //////////////
/*class slave_err_test extends cdma_base_test;
    `uvm_component_utils(slave_err_test)

    function new(string name="slave_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        simple_mode_slave_err_seq m_seq;
         slave_error_sequence slave_seq;
        phase.raise_objection(this);
            m_seq=simple_mode_slave_err_seq::type_id::create("m_seq");
            slave_seq=slave_error_sequence::type_id::create("slave_seq");
           m_seq.reg_model=en_h.reg_model;
           fork
            slave_seq.start(en_h.s_agt[1].sqr);
           join_none
           m_seq.start(en_h.m_agt[0].sqr);
           #2000ns;
        phase.drop_objection(this);
    endtask
endclass

//////////////////////////slave error test///////////////////
/*class slave_error_test extends cdma_base_test;
    `uvm_component_utils(slave_error_test)

    function new(string name="slave_error_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
            slave_err_sequence s_seq;
            slave_err_sequence_m m_seq;
            s_seq=slave_err_sequence::type_id::create("s_seq");
            m_seq=slave_err_sequence_m::type_id::create("m_seq");
            phase.raise_objection(this);
                m_seq.reg_model=en_h.reg_model;
                fork
                    s_seq.start(en_h.s_agt[1].sqr);
                join_none
                    m_seq.start(en_h.m_agt[0].sqr);
                #100ns;
            phase.drop_objection(this);
    endtask
endclass


//////////////////////////DECODE ERROR TEST //////////////
/*class decode_err_test extends cdma_base_test;
    `uvm_component_utils(decode_err_test)

    function new(string name="decode_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        decode_error_sequence m_dec_seq;
        decode_err_sequence s_dec_seq;

        m_dec_seq=decode_error_sequence::type_id::create("m_dec_seq");
        s_dec_seq=decode_err_sequence::type_id::create("s_dec_seq");

        phase.raise_objection(this);
            m_dec_seq.reg_model=en_h.reg_model;
            fork 
                s_dec_seq.start(en_h.s_agt[1].sqr);
            join_none
            m_dec_seq.start(en_h.m_agt[0].sqr);
            #200ns;
        phase.drop_objection(this);
    endtask
endclass

//////////////////////DMA decode error test ////////////////////
/*class dma_decode_err_test extends cdma_base_test;
    `uvm_component_utils(dma_decode_err_test)

    function new(string name="dma_decode_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        decode_err_seq m_seq;
        decode_err_sequence_1 s_seq;

        phase.raise_objection(this);
        m_seq=decode_err_seq::type_id::create("m_seq");
        s_seq=decode_err_sequence_1::type_id::create("s_seq");
        m_seq.reg_model=en_h.reg_model;
        fork
            s_seq.start(en_h.s_agt[1].sqr);
        join_none
            m_seq.start(en_h.m_agt[0].sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

//////////////////////////DMA internal error test//////////////////////
/*class dma_internal_err_test extends cdma_base_test;
    `uvm_component_utils(dma_internal_err_test)

    function new(string name="dma_internal_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
         dma_internal_err_seq  inter_err_seq;
         inter_err_seq=dma_internal_err_seq::type_id::create("inter_err_seq");
        phase.raise_objection(this);
            inter_err_seq.reg_model=en_h.reg_model;
            inter_err_seq.start(en_h.m_agt[0].sqr);
            phase.phase_done.set_drain_time(this,200ns);
        phase.drop_objection(this);
    endtask
endclass


////////////////////////////unaligned transfer test///////////////////////

/*class unaligned_test extends cdma_base_test;
    `uvm_component_utils(unaligned_test)

    function new(string name="unaligned_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    
    task main_phase(uvm_phase phase);
        unaligned_sequence unaligned_seq;
        base_slave_sequence slave_seq;
        slave_seq=base_slave_sequence::type_id::create("slave_seq");
        unaligned_seq=unaligned_sequence::type_id::create("unaligned_seq");
        unaligned_seq.reg_model=en_h.reg_model;
        phase.raise_objection(this);
            fork
                slave_seq.start(en_h.s_agt[1].sqr);
            join_none
            unaligned_seq.start(en_h.m_agt[0].sqr);
            #1000ns;
        phase.drop_objection(this);
    endtask

endclass


/////////////////////multiple transfer test////////////////////////////
/*class multiple_transfer_test extends cdma_base_test;
    `uvm_component_utils(multiple_transfer_test)

    function new(string name="mutiple_trans_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    task main_phase(uvm_phase phase);
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        multiple_trans_sequence m_seq=multiple_trans_sequence::type_id::create("m_seq");
        phase.raise_objection(this);
            fork
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
            m_seq.reg_model=en_h.reg_model;
            m_seq.start(en_h.m_agt[0].sqr);
        #100000ns;
        phase.drop_objection(this);
    endtask
endclass




//////////////////test with btt 16 bytes and aligned sa and da/////////
/*class btt_16_test extends cdma_base_test;
    `uvm_component_utils(btt_16_test)

    function new(string name="btt_16_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
         master_seq_btt_16 m_seq=master_seq_btt_16::type_id::create("m_seq");
         base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
            fork
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
            m_seq.reg_model=en_h.reg_model;
            m_seq.start(en_h.m_agt[0].sqr);
            phase.phase_done.set_drain_time(this,200ns);
            
        phase.drop_objection(this);
    endtask
endclass

////////////////test with btt 16 unaligned sa and da///////////
/*class btt_16_test1 extends cdma_base_test;
    `uvm_component_utils(btt_16_test1)

    function new(string name="btt_16_test1",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        master_seq_btt16 m_seq=master_seq_btt16::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
        fork 
            s_seq.start(en_h.s_agt[1].sqr);
        join_none
            m_seq.reg_model=en_h.reg_model;
            m_seq.start(en_h.m_agt[0].sqr);
            #500ns;
        phase.drop_objection(this);
    endtask
endclass


////////////////////soft reset test //////////////
/*class soft_reset_test extends cdma_base_test;
    `uvm_component_utils(soft_reset_test)

     function new(string name="soft_reset_test",uvm_component parent);
        super.new(name,parent);
     endfunction

     task main_phase(uvm_phase phase);
        uvm_reg_hw_reset_seq rest_seq=uvm_reg_hw_reset_seq::type_id::create("rest_seq");
        soft_res_sequence m_seq=soft_res_sequence::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
        fork
            s_seq.start(en_h.s_agt[1].sqr);
        join_none
            rest_seq.model=en_h.reg_model;
            m_seq.reg_model=en_h.reg_model;
            m_seq.start(en_h.m_agt[0].sqr);
            #300ns;
            fork
                rest_seq.start(null);
                    begin
                        #2;
                        rest_seq.set_response_queue_error_report_disabled(1);
                    end   
            join    
            #100ns;
        phase.drop_objection(this);
     endtask
endclass


//////////////////RANDOM TEST//////////////
/*class random_test extends cdma_base_test;
`uvm_component_utils(random_test)

function new(string name="random_test",uvm_component parent);
super.new(name,parent);
endfunction

task main_phase(uvm_phase phase);
    random_sequence m_seq=random_sequence::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    m_seq.reg_model=en_h.reg_model;
    phase.raise_objection(this);
    fork
    s_seq.start(en_h.s_agt[1].sqr);
    join_none
    m_seq.start(en_h.m_agt[0].sqr);
    #100ns;
    phase.drop_objection(this);
endtask
endclass

///////////////max btt test //////////////
/*class max_btt_test extends cdma_base_test;
`uvm_component_utils(max_btt_test)

function new(string name="max_btt_test",uvm_component parent);
super.new(name,parent);
endfunction

task main_phase(uvm_phase phase);
    max_btt_sequence m_seq=max_btt_sequence::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    phase.raise_objection(this);
    m_seq.reg_model=en_h.reg_model;
    fork
    s_seq.start(en_h.s_agt[1].sqr);
    join_none
    m_seq.start(en_h.m_agt[1].sqr);
    #10000ns;
    phase.drop_objection(this);
endtask
endclass
///////////////////mutiple trans test////////////
/*class multiple_trans_test extends cdma_base_test;
        `uvm_component_utils(multiple_trans_test)

        function new(string name="multiple_trans_test",uvm_component parent);
            super.new(name,parent);
        endfunction

        task main_phase(uvm_phase phase);
            multiple_trans_seq m_seq=multiple_trans_seq::type_id::create("m_seq");
            base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
            phase.raise_objection(this);
            fork 
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
                m_seq.reg_model=en_h.reg_model;
                m_seq.start(en_h.m_agt[0].sqr);
                #100000ns;
            phase.drop_objection(this);
        endtask
endclass
//////////////////////sg mode test///////////////
/*class sg_mode_test extends cdma_base_test;
    `uvm_component_utils(sg_mode_test)

    function new(string name="sg_mode_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    uvm_status_e status;
    uvm_reg_data_t data;

    task main_phase(uvm_phase phase);

    sg_mode_seq m_seq=sg_mode_seq::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");

    phase.raise_objection(this);

    m_seq.reg_model=en_h.reg_model;
    fork
    sg_seq.start(en_h.s_agt[0].sqr);
    s_seq.start(en_h.s_agt[1].sqr);
    join_none
    m_seq.start(en_h.m_agt[0].sqr);
    #15000ns;
    //en_h.reg_model.cdmasr.read(status,data);
    phase.drop_objection(this);
    endtask
endclass


////////////////////////SG mode incremental random test /////////////////
/*class sg_mode_random_test extends cdma_base_test;
`uvm_component_utils(sg_mode_random_test)

function new(string name="sg_mode_random_test",uvm_component parent);
    super.new(name,parent);
endfunction

task main_phase(uvm_phase phase);
    sg_mode_inc_random_seq m_seq=sg_mode_inc_random_seq::type_id::create("m_seq");
    base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
    sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
    phase.raise_objection(this);
    fork
        sg_seq.start(en_h.s_agt[0].sqr);
        s_seq.start(en_h.s_agt[1].sqr);
    join_none
    m_seq.reg_model=en_h.reg_model;
    m_seq.start(en_h.m_agt[0].sqr);
    #1000ns;
    phase.drop_objection(this);
endtask
endclass

//////////////////////SG mode fixed read incremental write test//////////////
/*class sg_mode_fixed_rd_inc_wr_test extends cdma_base_test;
    `uvm_component_utils(sg_mode_fixed_rd_inc_wr_test )

    function new(string name="sg_mode_fixed_rd_inc_wr_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_fixed_read_inc_wr_seq m_seq=sg_fixed_read_inc_wr_seq::type_id::create("m_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
           m_seq.reg_model=en_h.reg_model;
            fork 
               sg_seq.start(en_h.s_agt[0].sqr);
               s_seq.start(en_h.s_agt[1].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
            phase.phase_done.set_drain_time(this,100ns);    
        phase.drop_objection(this);
    endtask
endclass
/////////////////////////SG MODE incremantal read fixed write test//////////
/*class sg_inc_read_fixed_wr_test extends cdma_base_test;
    `uvm_component_utils(sg_inc_read_fixed_wr_test)

    function new(string name="sg_inc_read_fixed_wr_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_inc_read_fixed_wr_seq m_seq=sg_inc_read_fixed_wr_seq::type_id::create("m_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork
                
               sg_seq.start(en_h.s_agt[0].sqr);
               s_seq.start(en_h.s_agt[1].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
            phase.phase_done.set_drain_time(this,100ns);    
        phase.drop_objection(this);

    endtask
endclass
//////////////////////////SG MODE fixed read fixed write seq////////////////
/*class sg_fixed_rd_wr_test extends cdma_base_test;
    `uvm_component_utils(sg_fixed_rd_wr_test)

    function new(string name="sg_fixed_rd_wr_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_fixed_rd_wr_seq  m_seq=sg_fixed_rd_wr_seq::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        sg_slave_sequence  sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork
                sg_seq.start(en_h.s_agt[0].sqr);
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
            m_seq.start(en_h.m_agt[0].sqr);
            #100ns;
        phase.drop_objection(this);


    endtask
endclass


////////////////////////SG MODE Threshold interrupt test////////////////////
/*class sg_threshold_interrupt_test extends cdma_base_test;
    `uvm_component_utils(sg_threshold_interrupt_test)

    function new(string name="sg_threshold_interrupt_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_threshold_seq m_seq=sg_threshold_seq::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        sg_slave_sequence  sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork
                sg_seq.start(en_h.s_agt[0].sqr);
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
            m_seq.start(en_h.m_agt[0].sqr);
            #100ns;
        phase.drop_objection(this);
    endtask
endclass

///////////////////////DLY INTERRUPT TEST ////////////////////////////////
/*class dly_interrupt_test extends cdma_base_test;
    `uvm_component_utils(dly_interrupt_test)

    function new(string name="dly_interrupt_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        delay_interrupt_sequence m_seq=delay_interrupt_sequence::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");

        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork
                sg_seq.start(en_h.s_agt[0].sqr);
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
        phase.phase_done.set_drain_time(this,100ns);        
        phase.drop_objection(this);
    endtask
endclass

//////////////////////////SG internal error//////////////////////////////
/*class sg_internal_err_test extends cdma_base_test;
`uvm_component_utils(sg_internal_err_test)

function new(string name="sg_internal_err_test",uvm_component parent);
    super.new(name,parent);
endfunction

uvm_status_e status;
uvm_reg_data_t data;

task main_phase(uvm_phase phase);

   sg_internal_error_seq m_seq=sg_internal_error_seq::type_id::create("m_seq");
   sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
   base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
   
   phase.raise_objection(this);
   m_seq.reg_model=en_h.reg_model;
   fork
    s_seq.start(en_h.s_agt[1].sqr);
    sg_seq.start(en_h.s_agt[0].sqr);
   join_none
    m_seq.start(en_h.m_agt[0].sqr);
   en_h.reg_model.cdmasr.read(status,data);
   #200ns;
   phase.drop_objection(this);
endtask
endclass

////////////////////////SG decode error test /////////////////////////
/*class sg_decode_err_test extends cdma_base_test;
    `uvm_component_utils(sg_decode_err_test)

    function new(string name="sg_decode_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    uvm_status_e status;
    uvm_reg_data_t data;
    task main_phase(uvm_phase phase);

        sg_decode_err_seq m_seq=sg_decode_err_seq::type_id::create("m_seq");
        sg_decode_err_slave_sequence sg_seq=sg_decode_err_slave_sequence::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");

        phase.raise_objection(this);
        m_seq.reg_model=en_h.reg_model;

        fork
           sg_seq.start(en_h.s_agt[0].sqr); 
           s_seq.start(en_h.s_agt[1].sqr);
        join_none
         m_seq.start(en_h.m_agt[0].sqr);
        //en_h.reg_model.cdmasr.read(status,data);
        #100ns; 
        phase.drop_objection(this);
    endtask
endclass

/*class sg_decode_error_test extends cdma_base_test;
    `uvm_component_utils(sg_decode_error_test)

    function new(string name="sg_decode_error_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    
     uvm_status_e status;
     uvm_reg_data_t data;
    task main_phase(uvm_phase phase);

        sg_mode_decode_seq m_seq=sg_mode_decode_seq::type_id::create("m_seq");
        sg_decode_err_slave_seq sg_seq=sg_decode_err_slave_seq::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");

        phase.raise_objection(this);
        m_seq.reg_model=en_h.reg_model;
        fork
        sg_seq.start(en_h.s_agt[0].sqr);
        s_seq.start(en_h.s_agt[1].sqr);
        join_none
        m_seq.start(en_h.m_agt[0].sqr);
        //en_h.reg_model.curdesc_pnt.read(status,data);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

////////////////////////////SG SLAVE ERROR TEST///////////////////////
/*class sg_slave_error_test extends cdma_base_test;
    `uvm_component_utils(sg_slave_error_test)

    function new(string name="sg_slave_error_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    uvm_status_e status;
    uvm_reg_data_t data;
    task main_phase(uvm_phase phase);
       base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
       sg_slave_error_sequence sg_seq=sg_slave_error_sequence::type_id::create("sg_seq");
       sg_slave_error_seq m_seq=sg_slave_error_seq::type_id::create("m_seq");

       phase.raise_objection(this);
             m_seq.reg_model=en_h.reg_model;
                
                fork
                    s_seq.start(en_h.s_agt[1].sqr);
                    sg_seq.start(en_h.s_agt[0].sqr);
                join_none
            m_seq.start(en_h.m_agt[0].sqr);
            en_h.reg_model.cdmasr.read(status,data);
            #100ns;
      phase.drop_objection(this);
      
    endtask
endclass


/*class sg_slave_err_test extends cdma_base_test;
    `uvm_component_utils(sg_slave_err_test)

    function new(string name="sg_slave_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    uvm_status_e status;
    uvm_reg_data_t data;
    task main_phase(uvm_phase phase);
        sg_slave_err_sequence sg_seq=sg_slave_err_sequence::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        sg_slave_error_seq m_seq=sg_slave_error_seq::type_id::create("m_seq");

        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
                fork 
                    s_seq.start(en_h.s_agt[1].sqr);
                    sg_seq.start(en_h.s_agt[0].sqr);
                join_none
                    m_seq.start(en_h.m_agt[0].sqr);
             #100ns
        phase.drop_objection(this);
    endtask
endclass

//////////////////SG MODE DMA INTERNAL ERROR TEST////////////////////////
/*class sg_dma_internal_error_test extends cdma_base_test;
    `uvm_component_utils(sg_dma_internal_error_test)

    function new(string name="sg_dma_internal_error_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    uvm_status_e status;
    uvm_reg_data_t data;
    task main_phase(uvm_phase phase);
        sg_dma_internal_error_seq m_seq=sg_dma_internal_error_seq::type_id::create("m_seq");
        sg_slave_sequence  sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");

        phase.raise_objection(this);
        m_seq.reg_model=en_h.reg_model;
        fork 
            sg_seq.start(en_h.s_agt[0].sqr);
            s_seq.start(en_h.s_agt[1].sqr);
        join_none
           m_seq.start(en_h.m_agt[0].sqr);
        //en_h.reg_model.cdmasr.read(status,data);
        #2000ns;
        phase.drop_objection(this);
    endtask
endclass

////////////////////////SG DMA SLAVE ERROR TEST /////////////////////////
/*class sg_dma_slave_err_test extends cdma_base_test;
    `uvm_component_utils(sg_dma_slave_err_test)

    function new(string name="sg_dma_slave_err_tets",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_mode_slave_error_seq m_seq=sg_mode_slave_error_seq::type_id::create("m_seq");
        slave_error_sequence  s_seq=slave_error_sequence::type_id::create("s_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork 
                s_seq.start(en_h.s_agt[1].sqr);
                sg_seq.start(en_h.s_agt[0].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
                #100ns;
           phase.drop_objection(this);
    endtask
endclass

/*class sg_dma_slave_error_test extends cdma_base_test;
    `uvm_component_utils(sg_dma_slave_error_test)

    function new(string name="sg_dma_slave_err_tets",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_mode_slave_error_seq m_seq=sg_mode_slave_error_seq::type_id::create("m_seq");
        slave_err_sequence  s_seq=slave_err_sequence::type_id::create("s_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork 
                s_seq.start(en_h.s_agt[1].sqr);
                sg_seq.start(en_h.s_agt[0].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
                #100ns;
           phase.drop_objection(this);
    endtask
endclass

///////////////////////SG DECODE ERROR TEST///////////////////////
/*class sg_dma_decode_error_test extends cdma_base_test;
    `uvm_component_utils(sg_dma_decode_error_test)

    function new(string name="sg_dma_decode_error_test",uvm_component parent);
            super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sg_dma_decode_seq m_seq=sg_dma_decode_seq::type_id::create("m_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        decode_err_sequence s_seq=decode_err_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork
                sg_seq.start(en_h.s_agt[0].sqr);
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
                phase.phase_done.set_drain_time(this,100000ns);
        phase.drop_objection(this);
    endtask
endclass

/*class sg_dma_decode_err_test extends cdma_base_test;
    `uvm_component_utils(sg_dma_decode_err_test)

    function new(string name="sg_dma_decode_err_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
       sg_dma_decode_seq m_seq=sg_dma_decode_seq::type_id::create("m_seq");
       sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
       decode_err_sequence_1 s_seq=decode_err_sequence_1::type_id::create("s_seq"); 
       phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
        fork
            s_seq.start(en_h.s_agt[1].sqr);
            sg_seq.start(en_h.s_agt[0].sqr);
        join_none
        m_seq.start(en_h.m_agt[0].sqr);
        phase.phase_done.set_drain_time(this,100ns);
       phase.drop_objection(this);
    endtask
endclass

/*class sbd_verify_test extends cdma_base_test;
    `uvm_component_utils(sbd_verify_test)

    function new(string name="sbd_verify_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        sbd_verify_seq m_seq=sbd_verify_seq::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        sg_slave_sequence  sg_seq=sg_slave_sequence::type_id::create("sg_seq");

        phase.raise_objection(this);
               m_seq.reg_model=en_h.reg_model;
        fork
            s_seq.start(en_h.s_agt[1].sqr);
            sg_seq.start(en_h.s_agt[0].sqr);
        join_none
            m_seq.start(en_h.m_agt[0].sqr);
        phase.phase_done.set_drain_time(this,100ns);

        phase.drop_objection(this);

    endtask
endclass


/*class cyclic_bd_test extends cdma_base_test;
    `uvm_component_utils(cyclic_bd_test)

    function new(string name="cyclic_bd_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
       cyclic_bd_seq m_seq=cyclic_bd_seq::type_id::create("m_seq");
       base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
       sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
       phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
                fork
                    sg_seq.start(en_h.s_agt[0].sqr);
                    s_seq.start(en_h.s_agt[1].sqr);
                join_none
            m_seq.start(en_h.m_agt[0].sqr);
            #100000ns;
       phase.drop_objection(this);
    endtask
endclass

/////////fixed trans test////////
/*class fixed_trans_test extends cdma_base_test;
    `uvm_component_utils(fixed_trans_test)

    function new(string name="fixed_trans_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        fixed_trans_seq m_seq=fixed_trans_seq::type_id::create("m_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");
        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork
                s_seq.start(en_h.s_agt[1].sqr);
            join_none
            m_seq.start(en_h.m_agt[0].sqr);
           #100000ns; 
        phase.drop_objection(this);
    endtask
endclass


/*class multiple_sg_mode_trans_test extends cdma_base_test;
    `uvm_component_utils(multiple_sg_mode_trans_test)

    function new(string name="mutiple_sg_mode_trans_test",uvm_component parent);
        super.new(name,parent);
    endfunction

    task main_phase(uvm_phase phase);
        back_to_back_sg_mode_seq m_seq=back_to_back_sg_mode_seq::type_id::create("m_seq");
        sg_slave_sequence sg_seq=sg_slave_sequence::type_id::create("sg_seq");
        base_slave_sequence s_seq=base_slave_sequence::type_id::create("s_seq");

        phase.raise_objection(this);
            m_seq.reg_model=en_h.reg_model;
            fork 
               sg_seq.start(en_h.s_agt[0].sqr);
               s_seq.start(en_h.s_agt[1].sqr);
            join_none
                m_seq.start(en_h.m_agt[0].sqr);
        phase.drop_objection(this);

    endtask
endclass*/
