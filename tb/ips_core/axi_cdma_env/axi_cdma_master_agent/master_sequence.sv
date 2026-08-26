/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/master_sequence.sv                      */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2022                       */
/*                                                                        */
/* All Rights Reserved                                                    */
/*                                                                        */
/* NOTICE: All information contained herein is, and remains the           */
/* property of Raiton semiconductor PVT. LTD. and its suppliers           */
/* ,if any.  The intellectual and  technical concepts contained           */
/* herein  are proprietary to  Raiton  semiconductor  PVT. LTD.           */
/* they are protected  by trade secrets and / or copyright law.           */
/* Dissemination of this  information  or reproduction of  this           */
/* material or code is strictly forbidden unless  prior written           */
/* permission is obtained from Raiton semiconductor PVT. LTD.             */
/*                                                                        */
/* RAITON_COPYRIGHT_END                                                   */
//import axi_package :: *;

class base_master_sequence extends uvm_sequence #(reg_seq_item);
  `uvm_object_utils (base_master_sequence)

  //master_seq_item pkt;
  reg_seq_item pkt;
  axi_cdma_config_obj obj;
  cdma_reg_block reg_model;
  axi_slave_mem_model mem_model;
  uvm_status_e status;
  uvm_reg_data_t data;
  function new (string name = "base_master_sequence");
     super.new (name);
  endfunction

  task body ();
    `uvm_info(get_full_name(),"inside base_master_sequence body", UVM_MEDIUM)

    if (!uvm_config_db #(axi_cdma_config_obj) :: get (null ,get_full_name(), "axi_cdma_config_obj", obj))
    `uvm_fatal (get_full_name(),"axi_cdma_config_obj get FAILED,check if set")

    if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name,"memory",mem_model))
        `uvm_error("base_master_sequence","Failed to get memory handle from config db")
  endtask:body

endclass: base_master_sequence


//////////// sequence with btt equal to 1/////////
class btt_1_seq extends base_master_sequence;
    `uvm_object_utils(btt_1_seq)

    function new(string name="btt_1_seq");
        super.new(name);
    endfunction
    
   reg_seq_item pkt=reg_seq_item::type_id::create("pkt"); 
    task body();
    super.body();
    assert(pkt.randomize() with { pkt.btt == 32'h1;});
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,pkt.sa);
        reg_model.da.write(status,pkt.da);
        reg_model.btt.write(status,pkt.btt);
        wait(obj.mas_if[0].cdma_introut);
    endtask
endclass

///////// test with btt equal to 16 ////////
class master_seq_btt_16 extends base_master_sequence;
    `uvm_object_utils(master_seq_btt_16)

    function new(string name="master_seq_btt_16");
        super.new(name);
    endfunction
    
    task body();
        super.body();
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
       reg_model.cdmacr.write(status,32'h5000);
       reg_model.sa.write(status,32'hF000);
       reg_model.da.write(status,32'h500);
       reg_model.btt.write(status,32'h10);
       wait(obj.mas_if[0].cdma_introut);
    endtask
endclass

/////////// test with unaligned address and btt with 16 ////////////////
class master_seq_btt16 extends base_master_sequence;
    `uvm_object_utils(master_seq_btt16)
    
    function new(string name="master_seq_btt16");
        super.new(name);
    endfunction

    task body();
        super.body();
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,32'h1000_000F);
        reg_model.da.write(status,32'h500F);
        reg_model.btt.write(status,32'h10);
    endtask
endclass


/////////simple_dma_sequence_using_ral//////////
class simple_mode_inc_tr extends base_master_sequence;
    `uvm_object_utils(simple_mode_inc_tr)
       
        function new(string name="simple_mode_wr_rd");
            super.new(name);
        endfunction
         task body();
            super.body();

            do begin
               reg_model.cdmasr.read(status,data); 
            end while(data[1]==0);
           
            reg_model.cdmacr.write(status,32'h5000);

            reg_model.sa.write(status,32'h0001_0000);
            reg_model.da.write(status,32'd0002_0000);
            reg_model.btt.write(status,32'h110);

            wait(obj.mas_if[0].cdma_introut);
            reg_model.cdmasr.read(status,data);
           `uvm_info("STATUS_AFTER_INTRAOUT",$sformatf("----%h------",data),UVM_LOW)
           reg_model.cdmasr.write(status,32'h0000_1000);
           reg_model.cdmasr.read(status,data);
           if(data[12]!=0)begin
            `uvm_error("ERROR","STATUS_AFTER_CLEAR ::FAILED to clear the data")
           end

        endtask
endclass



///////////simple mode keyhole read incremental write ///////
class keyhole_read_inc_wr_seq extends base_master_sequence;
    `uvm_object_utils(keyhole_read_inc_wr_seq)

    function new(string name="keyhole_read_inc_wr_seq");
        super.new(name);
    endfunction
       
    task body();
        super.body();
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
        pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize());
        reg_model.cdmacr.write(status,32'h0000_5010);
        reg_model.cdmacr.read(status,data);
        reg_model.sa.write(status,pkt.sa);
        reg_model.sa_msb.write(status,pkt.sa_msb);
        reg_model.da_msb.write(status,pkt.da_msb);
        reg_model.da.write(status,pkt.da);
        reg_model.btt.write(status,pkt.btt);
            wait(obj.mas_if[0].cdma_introut);
    endtask
endclass

//////////////simple mode keyhole write seq ///////////
class keyhole_write_seq extends base_master_sequence;
    `uvm_object_utils(keyhole_write_seq)

    function new(string name="keyhole_write_seq");
        super.new(name);
    endfunction 
     task body();
        super.body();
       do begin
            reg_model.cdmasr.read(status,data);
       end while(data[1]==0);
       pkt=reg_seq_item::type_id::create("pkt");
       assert(pkt.randomize())
       reg_model.cdmacr.write(status,32'h0000_5020);
       reg_model.sa.write(status,pkt.sa);
       reg_model.da.write(status,pkt.da);
       reg_model.btt.write(status,pkt.btt);
            wait(obj.mas_if[0].cdma_introut);
    endtask
endclass

////////////////keyhole read  key hole write sequence///////////////
class keyhole_rd_wr_seq extends base_master_sequence;
    `uvm_object_utils(keyhole_rd_wr_seq)

    function new(string name="keyhole_rd_wr_seq");
        super.new(name);
    endfunction
   task body();

        super.body(); 
        reg_model.cdmacr.write(status,32'h0000_5030);
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
        pkt=reg_seq_item::type_id::create("pkt");
       reg_model.sa.write(status,pkt.sa);
       reg_model.sa_msb.write(status,pkt.sa_msb);
       reg_model.da.write(status,pkt.da);
       reg_model.da_msb.write(status,pkt.da_msb);
       reg_model.btt.write(status,pkt.btt);
            wait(obj.mas_if[0].cdma_introut);
        
    endtask
endclass
////////////// DMA slave error sequence ///////////////////
class simple_mode_slave_err_seq extends base_master_sequence;
    `uvm_object_utils(simple_mode_slave_err_seq);

    function new(string name="slave_error_seq");
        super.new(name);
    endfunction

    task body();
         super.body();
         pkt=reg_seq_item::type_id::create("pkt");
         assert(pkt.randomize())
            reg_model.cdmacr.write(status,32'h5000);
        
            reg_model.sa.write(status,pkt.sa);
            reg_model.sa_msb.write(status,pkt.sa_msb);
            reg_model.da.write(status,pkt.da);
            reg_model.da_msb.write(status,pkt.da_msb);
            reg_model.btt.write(status,pkt.btt);
            wait(obj.mas_if[0].cdma_introut);
            reg_model.cdmasr.read(status,data);
            if(data[5]!=1)begin
                `uvm_error("SLVERR","failed in setting slave error")
            end
    endtask
endclass

////////////////Simple mode decode error sequence//////////////
class decode_error_sequence extends base_master_sequence;
    `uvm_object_utils(decode_error_sequence)

    function new(string name="decode_error_sequence");
        super.new(name);
    endfunction

    task body();
        super.body();
        do begin
          reg_model.cdmasr.read(status,data); 
        end while(data[1]==0);
        pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize());
        reg_model.cdmacr.write(status,32'h5000);
      
            reg_model.sa.write(status,pkt.sa);
            reg_model.sa_msb.write(status,pkt.sa_msb);
            reg_model.da.write(status,pkt.da);
            reg_model.da_msb.write(status,pkt.da_msb);
            reg_model.btt.write(status,pkt.btt); 
        
        wait(obj.mas_if[0].cdma_introut);
        reg_model.cdmasr.read(status,data);
    endtask
endclass

///////////////simple mode incemental btt=4096///////////
class simple_inc_4k extends base_master_sequence;
`uvm_object_utils(simple_inc_4k)

function new(string name="simple_inc_4k");
super.new(name);
endfunction

reg_seq_item pkt;
task body();
super.body();
pkt=reg_seq_item::type_id::create("pkt");
assert(pkt.randomize() with {pkt.btt==32'h1000;pkt.sa==32'h3000;pkt.da==32'h2000;});

do begin
reg_model.cdmasr.read(status,data);
end while(data[1]==0);
reg_model.cdmacr.write(status,32'h5000);
reg_model.sa.write(status,pkt.sa);
reg_model.da.write(status,pkt.da);
reg_model.btt.write(status,pkt.btt);
        wait(obj.mas_if[0].cdma_introut);
endtask
endclass
////////////simple mode inc 4k crossing test//////////////
class simple_mode_inc4kcross extends base_master_sequence;
`uvm_object_utils(simple_mode_inc4kcross)

function new(string name="simple_mode_inc4kcross");
super.new(name);
endfunction
task body();
super.body();
pkt=reg_seq_item::type_id::create("pkt");
assert(pkt.randomize() with {pkt.btt==32'h2000;pkt.sa==32'h3000;pkt.da==32'h6000;});
do begin
reg_model.cdmasr.read(status,data);
end while(data[1]==0);
reg_model.cdmacr.write(status,32'h1000);
reg_model.sa.write(status,pkt.sa);
reg_model.da_msb.write(status,pkt.sa_msb);
reg_model.da.write(status,pkt.da);
reg_model.da_msb.write(status,pkt.da_msb);
reg_model.btt.write(status,pkt.btt);
        wait(obj.mas_if[0].cdma_introut);
endtask
endclass

////////////////////simple mode fixed btt 4k////////////////
class fixed_btt_4k extends base_master_sequence;
`uvm_object_utils(fixed_btt_4k)

function new(string name="fixed_btt_4k");
super.new(name);
endfunction

task body();
super.body();
pkt=reg_seq_item::type_id::create("pkt");
assert(pkt.randomize() with {pkt.btt==32'd4096;pkt.sa==32'h4000;pkt.da==32'h9000;} );
do begin
reg_model.cdmasr.read(status,data);
end while(data[1]==0);
reg_model.cdmacr.write(status,32'h5000);
reg_model.sa.write(status,pkt.sa);
reg_model.da.write(status,pkt.da);
reg_model.btt.write(status,pkt.btt);
wait(obj.mas_if[0].cdma_introut);
endtask
endclass

////////////simple mode dma internal error sequence/////
class dma_internal_err_seq extends base_master_sequence;
    `uvm_object_utils(dma_internal_err_seq)

    function new(string name="dma_internal_err_seq");
        super.new(name);
    endfunction

        task body();
            super.body();
        do begin
          reg_model.cdmasr.read(status,data); 
        end while(data[1]==0);
        reg_model.cdmacr.write(status,32'h4000);
        reg_model.sa.write(status,32'h2000);
        reg_model.da.write(status,32'h500);
        reg_model.btt.write(status,32'h000000);
        
        wait(obj.mas_if[0].cdma_introut);
        reg_model.cdmasr.read(status,data);
            
        endtask
endclass

//////////////simple mode unaligned sequence ///////////
class unaligned_sequence extends base_master_sequence;
    `uvm_object_utils(unaligned_sequence)

    function new(string name="unaligned_sequence");
        super.new(name);
    endfunction

    uvm_status_e status;
    cdma_reg_block  reg_model;
    uvm_reg_data_t data;
    axi_cdma_config_obj obj;

    task body();
        super.body();
        if(!uvm_config_db #(axi_cdma_config_obj) :: get(null, "", "axi_cdma_config_obj", obj))
        `uvm_fatal(get_full_name(), "config_db_not_accessable");

        do begin
          reg_model.cdmasr.read(status,data); 
        end while(data[1]==0);

        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,32'h2001);
        reg_model.da.write(status,32'h502);
        reg_model.btt.write(status,32'd32);
        
        wait(obj.mas_if[0].cdma_introut);
        reg_model.cdmasr.read(status,data);
            
    endtask

endclass

//////////decode error sequence////////////////
class decode_err_seq extends base_master_sequence;
    `uvm_object_utils(decode_err_seq)

    function new(string name="decode_err_seq");
        super.new(name);
    endfunction

    task body();
        super.body();
        do begin
          reg_model.cdmasr.read(status,data); 
        end while(data[1]==0);
        pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize())
        reg_model.cdmacr.write(status,32'h4000);
      reg_model.sa.write(status,pkt.sa);
      reg_model.da_msb.write(status,pkt.sa_msb);
      reg_model.da.write(status,pkt.da);
      reg_model.da_msb.write(status,pkt.da_msb);
      reg_model.btt.write(status,pkt.btt); 
        
        wait(obj.mas_if[0].cdma_introut);
        reg_model.cdmasr.read(status,data);
            
    endtask
endclass

//////////////////slave error sequence ///////////////
class slave_err_sequence_m extends base_master_sequence;
    `uvm_object_utils(slave_err_sequence_m)

    function new(string name="slave_err_sequence_m");
        super.new(name);
    endfunction

    task body();
        super.body();
        pkt=reg_seq_item::type_id::create("pkt");
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);

        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,pkt.sa);
        reg_model.da.write(status,pkt.da);
        reg_model.btt.write(status,pkt.btt);
        wait(obj.mas_if[0].cdma_introut);
        reg_model.cdmasr.read(status,data);
    endtask
endclass

/////////////////multiple transfer sequence//////////////////
class multiple_trans_sequence extends base_master_sequence;
    `uvm_object_utils(multiple_trans_sequence)

    function new(string name="multiple_trans_sequence");
        super.new(name);
    endfunction


    task body();
        super.body();
        if(!uvm_config_db#(axi_cdma_config_obj)::get(null,"","axi_cdma_config_obj",obj))
            `uvm_fatal(get_full_name(),"config_db not accessible")
        
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
        pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize());
        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,pkt.sa);
        reg_model.sa_msb.write(status,pkt.sa_msb);
        reg_model.da.write(status,pkt.da);
        reg_model.da_msb.write(status,pkt.da_msb);
        reg_model.btt.write(status,pkt.btt);
         do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);

      endtask

endclass
///////////////// mutiple transfer sequence////////////////
class multiple_trans_seq extends base_master_sequence;
    `uvm_object_utils(multiple_trans_seq)

    function new(string name="multiple_trans_seq");
        super.new(name);
    endfunction

    uvm_status_e status;
    uvm_reg_data_t data;
    cdma_reg_block reg_model;
    reg_seq_item pkt;
    task body();
    repeat(10)begin
    pkt=reg_seq_item::type_id::create("pkt");
    assert(pkt.randomize());
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);

        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,pkt.sa);
        reg_model.sa_msb.write(status,pkt.sa_msb);
        reg_model.da.write(status,pkt.da);
        //reg_model.da_msb.write(status,da_msb);
        reg_model.da_msb.write(status,pkt.da_msb);
        reg_model.btt.write(status,pkt.btt);
       
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);
        reg_model.cdmasr.read(status,data);
        end
    endtask
endclass



////////////check for soft reset test ///////////
class soft_res_sequence extends base_master_sequence;
    `uvm_object_utils(soft_res_sequence)

    function new(string name="soft_res_sequence");
         super.new(name);
    endfunction
    
    uvm_reg_data_t data;
    uvm_status_e status;
    cdma_reg_block reg_model;
    
    task body();
        do begin
            reg_model.cdmasr.read(status,data);
        end while(data[1]==0);

        reg_model.cdmacr.write(status,32'h5000);
        reg_model.sa.write(status,32'h0100_100F);
        reg_model.da.write(status,32'h2000_F00F);
        reg_model.btt.write(status,32'h10);
        reg_model.cdmacr.write(status,32'h4);
    endtask

endclass

//////////////////Randmoized sequence for simple mode////////////////
class random_sequence extends base_master_sequence;
    `uvm_object_utils(random_sequence)

    cdma_reg_block reg_model;

    function new(string name="random_sequence");
        super.new(name);
    endfunction

    task body();
        super.body();
        if (reg_model == null) begin
            `uvm_fatal("REG_MODEL_NULL", "Register model handle is null in random_sequence")
        end
        repeat(15) begin

            reg_seq_item pkt;
            pkt = reg_seq_item::type_id::create("pkt");
            if (!pkt.randomize()) begin
                `uvm_error("RAND_FAIL", "Randomization failed for pkt")
            end
            reg_model.sa.write(status, pkt.sa);
            reg_model.da.write(status, pkt.da);
            reg_model.btt.write(status, pkt.btt);
            do 
                reg_model.cdmasr.read(status,data);
            while(data[1]==0);
        end
    endtask
endclass
/////////////////maximium btt//////////////
class max_btt_sequence  extends base_master_sequence;
`uvm_object_utils(max_btt_sequence)

function new(string name="max_btt_sequence");
super.new(name);
endfunction

uvm_status_e status;
uvm_reg_data_t data;
cdma_reg_block reg_model;
reg_seq_item pkt;
task body();
pkt=reg_seq_item::type_id::create("pkt");
assert(pkt.randomize() with {pkt.btt==32'hFFFF_FFFF;pkt.sa==32'h2000_0000;pkt.da_msb==32'h000_0001;pkt.da==32'h0000_0000;});
do begin
reg_model.cdmasr.read(status,data);
end while(data[1]==0);
reg_model.cdmacr.write(status,32'h5000);
reg_model.sa.write(status,pkt.sa);
reg_model.da.write(status,pkt.da);
reg_model.da_msb.write(status,pkt.da_msb);
endtask
endclass

//////////////////sgmode///////////////
class sg_mode_seq extends base_master_sequence;
    `uvm_object_utils(sg_mode_seq)

    function new(string name="sg_mode");
        super.new(name);
    endfunction
    cdma_reg_block reg_model;
    uvm_reg_data_t data;
    reg_seq_item pkt;
    uvm_status_e status;
    bit[31:0] control_reg;
    descriptor_seq_item desc,desc1;
    axi_slave_mem_model mem_model;
    task body();
    super.body();
    pkt=reg_seq_item::type_id::create("pkt");
    desc=descriptor_seq_item::type_id::create("desc");
    desc1=descriptor_seq_item::type_id::create("desc1");

    if(!pkt.randomize() with {pkt.curdesc_pnt==32'h1000;})begin
        `uvm_error("SG_MEM","Failed to randomize register sequence item")
    end
    if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
        `uvm_error("SG_MEM","Failed in getting memory handle")
    end
    do begin
    reg_model.cdmasr.read(status,data);
    end while(data[1]==0);

    desc.next_desc_pntr=32'h1000;
    desc.next_desc_pntr_msb=32'h0000;
    desc.sa=32'h5000;
    desc.sa_msb=32'h00000;
    desc.da=32'h8_0000;
    desc.da_msb=32'h0000;
    desc.control=26'h2000;
    desc.status=32'h0000;

    mem_model.write(32'h3000,desc);

    desc1.next_desc_pntr=32'h0000;
    desc1.next_desc_pntr_msb=32'h0000;
    desc1.sa=32'hFF000;
    desc1.sa_msb=32'h0000;
    desc1.da=32'h80_0000;
    desc1.da_msb=32'h0000;
    desc1.control=26'h4000;
    desc1.status=32'h00;
    mem_model.write(32'h1000,desc1);

    control_reg[3]=1'b1;
    control_reg[12]=1'b1;
    control_reg[14]=1'b1;
    control_reg[23:16]=8'h2;

    reg_model.cdmacr.write(status,control_reg);
    reg_model.curdesc_pnt.write(status,32'h3000);
    reg_model.curdesc_pnt_msb.write(status,32'h0000);
    reg_model.taildesc_pnt.write(status,32'h1000);
    reg_model.taildesc_pnt_msb.write(status,32'h000);
    wait(obj.mas_if[0].cdma_introut);
    reg_model.cdmasr.read(status,data);
    endtask
endclass

////////////////SG fixed read incremental write sequence/////////////////////
class sg_fixed_read_inc_wr_seq extends base_master_sequence;
    `uvm_object_utils(sg_fixed_read_inc_wr_seq)

    function new(string name="sg_fixed_read_inc_wr_seq");
        super.new(name);
    endfunction
    bit[63:0] current_address;
    descriptor_seq_item desc;
    bit[31:0] control_reg;
    task body();
        super.body();

         pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize())
        else `uvm_error("master_sequence","Register sequence randomization failed")
        current_address={pkt.curdesc_pnt_msb,pkt.curdesc_pnt};
        for(int i=1;i<=100;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=99)
                assert(desc.randomize());
            else 
             assert(desc.randomize() with {desc.next_desc_pntr_msb==pkt.taildesc_pnt_msb;desc.next_desc_pntr==pkt.taildesc_pnt;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
        end

        control_reg[3]=1'b1;
        control_reg[4]=1'b1;
        control_reg[23:16]=32'd100;
        control_reg[12]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
        reg_model.curdesc_pnt_msb.write(status,pkt.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,pkt.taildesc_pnt);
        reg_model.taildesc_pnt_msb.write(status,pkt.taildesc_pnt_msb);
        wait(obj.mas_if[0].cdma_introut);
    endtask
endclass

////////////////////////sg incremantal read fixed write sequence////////////////////
class sg_inc_read_fixed_wr_seq extends base_master_sequence;
    `uvm_object_utils(sg_inc_read_fixed_wr_seq)

    function new(string name="sg_inc_read_fixed_wr_seq");
        super.new(name);
    endfunction
    bit[63:0] current_address;
    descriptor_seq_item desc;
    bit[31:0] control_reg;
    task body();
        super.body();

         pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize())
        else `uvm_error("master_sequence","Register sequence randomization failed")
        current_address={pkt.curdesc_pnt_msb,pkt.curdesc_pnt};
        for(int i=1;i<=150;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=149)
                assert(desc.randomize());
            else 
             assert(desc.randomize() with {desc.next_desc_pntr_msb==pkt.taildesc_pnt_msb;desc.next_desc_pntr==pkt.taildesc_pnt;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
        end

        control_reg[3]=1'b1;
        control_reg[4]=1'b1;
        control_reg[23:16]=8'd150;
        control_reg[12]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
        reg_model.curdesc_pnt_msb.write(status,pkt.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,pkt.taildesc_pnt);
        reg_model.taildesc_pnt_msb.write(status,pkt.taildesc_pnt_msb);
        wait(obj.mas_if[0].cdma_introut);
    endtask
endclass

//////////////////////////SG fixed read fixed write seq//////////////
class sg_fixed_rd_wr_seq extends base_master_sequence;
    `uvm_object_utils(sg_fixed_rd_wr_seq)

    function new(string name="sg_inc_read_fixed_wr_seq");
        super.new(name);
    endfunction
    bit[63:0] current_address;
    descriptor_seq_item desc;
    bit[31:0] control_reg;
    task body();
        super.body();

         pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize())
        else `uvm_error("master_sequence","Register sequence randomization failed")
        current_address={pkt.curdesc_pnt_msb,pkt.curdesc_pnt};
        for(int i=1;i<=50;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=49)
                assert(desc.randomize());
            else 
             assert(desc.randomize() with {desc.next_desc_pntr_msb==pkt.taildesc_pnt_msb;desc.next_desc_pntr==pkt.taildesc_pnt;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
        end

        control_reg[3]=1'b1;
        control_reg[4]=1'b1;
        control_reg[5]=1'b1;
        control_reg[23:16]=32'd50;
        control_reg[12]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
        reg_model.curdesc_pnt_msb.write(status,pkt.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,pkt.taildesc_pnt);
        reg_model.taildesc_pnt_msb.write(status,pkt.taildesc_pnt_msb);
        wait(obj.mas_if[0].cdma_introut);
    endtask
endclass



///////////////sg mode incremetal test//////////////
class sg_mode_inc_random_seq extends base_master_sequence;
    `uvm_object_utils(sg_mode_inc_random_seq)

    function new(string name="sg_mode_inc_random_seq");
        super.new(name);
    endfunction
     descriptor_seq_item desc;
    reg_seq_item reg_seq;
    bit[63:0] current_address;
    bit[31:0] control_reg;
    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("master_sequence","Register sequence randomization failed")
        current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
        for(int i=1;i<=3;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=2)
               assert(desc.randomize());
            else 
             assert(desc.randomize() with {desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;desc.next_desc_pntr==reg_seq.taildesc_pnt;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
        end

        control_reg[3]=1'b1;
        control_reg[23:16]=8'd3;
        control_reg[12]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
        reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
        reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
        wait(obj.mas_if[0].cdma_introut);
        reg_model.cdmasr.read(status,data);
    endtask
endclass

///////////////////////////SG Threshold seq //////////////////////////////
class sg_threshold_seq extends base_master_sequence;
    `uvm_object_utils(sg_threshold_seq)

    function new(string name="sg_threshold_seq");
        super.new(name);
    endfunction
    descriptor_seq_item desc;
    reg_seq_item reg_seq;
    bit[63:0] current_address;
    bit[31:0] control_reg;
    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("master_sequence","Register sequence randomization failed")
        current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
        for(int i=1;i<=10;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=9)
               assert(desc.randomize());
            else 
             assert(desc.randomize() with {desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;desc.next_desc_pntr==reg_seq.taildesc_pnt;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
        end

        control_reg[3]=1'b1;
        control_reg[23:16]=8'h2;
        control_reg[12]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
        reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
        reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
        repeat(5) begin
        wait(obj.mas_if[0].cdma_introut);
            reg_model.cdmasr.read(status,data);
            `uvm_info("master_sequnece",$sformatf("thresholdvaloe=%0d",data[23:16]),UVM_DEBUG)
            if(data[12]==1'b1)
            reg_model.cdmasr.IOC_Irq.write(status,1'b1);
        end
    endtask
endclass

///////////////////////////Dly interrupt sequence////////////////////////////
class delay_interrupt_sequence extends base_master_sequence;
    `uvm_object_utils(delay_interrupt_sequence)

    function new(string name="delay_interrupt_sequence");
        super.new(name);
    endfunction

    reg_seq_item reg_seq;
    descriptor_seq_item desc;
    bit[31:0] control_reg;
    bit[63:0] current_address;
    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("master_sequence","Register sequence randomization failed")
        current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
        for(int i=1;i<=10;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=9)
                assert(desc.randomize());
            else 
             assert(desc.randomize() with {desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;desc.next_desc_pntr==reg_seq.taildesc_pnt;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
        end

        control_reg[3]=1'b1;
        control_reg[23:16]=8'h24;
        control_reg[13]=1'b1;
        control_reg[31:24]=8'h6;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
        reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
        reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
        wait(obj.mas_if[0].cdma_introut);
            reg_model.cdmasr.read(status,data);

    endtask
endclass


/////////////////////////sg internal error sequenece/////////////////////////
class sg_internal_error_seq extends base_master_sequence;
`uvm_object_utils(sg_internal_error_seq)

function new(string name="sg_slave_error_seq");
super.new(name);
endfunction

cdma_reg_block reg_model;
uvm_status_e status;
uvm_reg_data_t data;
bit[31:0] control_reg;

descriptor_seq_item desc;
reg_seq_item pkt;
axi_slave_mem_model mem_model;

task body();
    super.body();
if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
`uvm_error("master_sequence","Failed to get memory handle from configdb")
end

pkt=reg_seq_item::type_id::create("pkt");
if(!pkt.randomize() with {curdesc_pnt_msb==32'h0000_0000;taildesc_pnt_msb==32'h0000_0000;})begin
`uvm_error("master_sequence","Failed to randomize register sequence")
end

desc=descriptor_seq_item::type_id::create("desc");
assert(desc.randomize() with {desc.next_desc_pntr_msb==32'h0000_0000;desc.status==32'h8000_0000;});

mem_model.write(pkt.curdesc_pnt,desc);

control_reg[3]=1'b1;
control_reg[14]=1'b1;

reg_model.cdmacr.write(status,control_reg);
reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
reg_model.taildesc_pnt.write(status,pkt.taildesc_pnt);
reg_model.taildesc_pnt_msb.write(status,32'h0000);
        wait(obj.mas_if[0].cdma_introut);
endtask
endclass

////////////////////SG DECODE ERROR/////////////////////////
class sg_decode_err_seq extends base_master_sequence;
    `uvm_object_utils(sg_decode_err_seq)

    function new(string name="sg_decode_err_seq");
        super.new(name);
    endfunction

descriptor_seq_item desc;
bit[31:0] current_addr,next_addr,control_reg;
task body();
    super.body();
    pkt=reg_seq_item::type_id::create("pkt");

    assert(pkt.randomize() with {pkt.curdesc_pnt_msb==32'h0000_0000;pkt.taildesc_pnt_msb==32'h0000_0000;})
    else `uvm_error("master_sequence","register sequence randomization failed")
    current_addr=pkt.curdesc_pnt; 
    repeat(2)begin
        desc=descriptor_seq_item::type_id::create("desc");
        assert(desc.randomize() with {desc.next_desc_pntr_msb==32'h0000_0000;desc.status==32'h0000_0000;})
        mem_model.write(current_addr,desc);
        current_addr=desc.next_desc_pntr;
    end
    control_reg[3]=1'b1;
    control_reg[14]=1'b1;
    control_reg[23:16]=8'h2;
    reg_model.cdmacr.write(status,control_reg);
    reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
    reg_model.taildesc_pnt.write(status,current_addr);
    reg_model.taildesc_pnt_msb.write(status,pkt.taildesc_pnt_msb);
    wait(obj.mas_if[0].cdma_introut);
    reg_model.cdmasr.read(status,data);
endtask

endclass

//////////////////////////////sg decode error sequence //////////////////////
class sg_mode_decode_seq extends base_master_sequence;
    `uvm_object_utils(sg_mode_decode_seq)

    function new(string name="sg_mode_inc_random_seq");
        super.new(name);
    endfunction
    bit[31:0] control_reg;
    bit[63:0] current_address;
    descriptor_seq_item desc;
    reg_seq_item reg_seq;
    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("sg_mode_slave_error_seq","Failed in randomize resgister sequence item")
         
         current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
         for(int i=1;i<=5;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=4)
            assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==reg_seq.taildesc_pnt;desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end
       
             control_reg[3]=1'b1;
             control_reg[14]=1'b1;
             reg_model.cdmacr.write(status,control_reg);
             reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
             reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
             reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
             reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
             wait(obj.mas_if[0].cdma_introut);
             reg_model.cdmasr.read(status,data);
    endtask
endclass

//////////////////////////////SG  SLAVE ERROR SEQUENCE///////////////////////
class sg_slave_error_seq extends base_master_sequence;
`uvm_object_utils(sg_slave_error_seq)

function new(string name="sg_slave_error_seq");
    super.new(name);
endfunction

 descriptor_seq_item desc;
 reg_seq_item reg_seq;
 bit[63:0] current_address;bit[31:0]control_reg;
 uvm_status_e status;
cdma_reg_block reg_model; 
 task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("sg_mode_slave_error_seq","Failed in randomize resgister sequence item")
         
         current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
         for(int i=1;i<=5;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=4)
            assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==reg_seq.taildesc_pnt;desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end
       
             control_reg[3]=1'b1;
             control_reg[14]=1'b1;
             reg_model.cdmacr.write(status,control_reg);
             reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
             reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
             reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
             reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
             wait(obj.mas_if[0].cdma_introut);
             reg_model.cdmasr.read(status,data);

      endtask
endclass

class sg_dma_internal_error_seq extends base_master_sequence;
    `uvm_object_utils(sg_dma_internal_error_seq)

    function new(string name="sg_dma_internal_error_seq");
        super.new(name);
    endfunction
   
    descriptor_seq_item desc;
    reg_seq_item reg_seq;
    bit[31:0] control_reg;
    bit[63:0] current_address;
    task body();
      super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("sg_mode_slave_error_seq","Failed in randomize resgister sequence item")
         
         current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
         for(int i=1;i<=5;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=4)
                assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==reg_seq.taildesc_pnt;desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;desc.control==32'h0000;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end


       control_reg[3]=1'b1;
       control_reg[14]=1'b1;
       reg_model.cdmacr.write(status,control_reg);
       reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
       reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
       reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
       reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
       wait(obj.mas_if[0].cdma_introut);
       reg_model.cdmasr.read(status,data);
    endtask
endclass

/////////////////sg mode dma slave error sequence ///////////////////////////
class sg_mode_slave_error_seq extends base_master_sequence;
    `uvm_object_utils(sg_mode_slave_error_seq)
    
    function new(string name="sg_mode_slave_error_seq");
        super.new(name);
    endfunction
    descriptor_seq_item desc;
    reg_seq_item reg_seq;
    bit[63:0] current_address;
    bit[31:0] control_reg;
    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("sg_mode_slave_error_seq","Failed in randomize resgister sequence item")
         
         current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
         for(int i=1;i<=5;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=4)
              assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==reg_seq.taildesc_pnt;desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end
       
             control_reg[3]=1'b1;
             control_reg[14]=1'b1;
             reg_model.cdmacr.write(status,control_reg);
             reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
             reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
             reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
             reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
             wait(obj.mas_if[0].cdma_introut);
             reg_model.cdmasr.read(status,data);
     endtask
endclass

///////////////////sg dma decode error sequence /////////////////////
class sg_dma_decode_seq extends base_master_sequence;
    `uvm_object_utils(sg_dma_decode_seq)

    function new(string name="sg_dma_decode_seq");
        super.new(name);
    endfunction
     descriptor_seq_item desc;
    reg_seq_item reg_seq;
    bit[63:0] current_address;
    bit[31:0] control_reg;
    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("sg_mode_slave_error_seq","Failed in randomize resgister sequence item")
         
         current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
         for(int i=1;i<=5;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=4)
            assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==reg_seq.taildesc_pnt;desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end
       
             control_reg[3]=1'b1;
             control_reg[14]=1'b1;
             reg_model.cdmacr.write(status,control_reg);
             reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
             reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
             reg_model.taildesc_pnt.write(status,reg_seq.taildesc_pnt);
             reg_model.taildesc_pnt_msb.write(status,reg_seq.taildesc_pnt_msb);
             wait(obj.mas_if[0].cdma_introut);
             reg_model.cdmasr.read(status,data);
    endtask
endclass

class cyclic_bd_seq extends base_master_sequence;
    `uvm_object_utils(cyclic_bd_seq)

    function new(string name="cyclic_bd_seq");
        super.new(name);
    endfunction
    descriptor_seq_item desc;
    reg_seq_item reg_seq;
    bit[31:0] control_reg;
    bit [63:0] current_address;
   /* task body();
        super.body();
        pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize()with{pkt.taildesc_pnt==pkt.curdesc_pnt;pkt.taildesc_pnt==pkt.taildesc_pnt_msb;});
        current_address={pkt.curdesc_pnt_msb,pkt.curdesc_pnt}; 
        for(int i=1;i<=3;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=2)
            assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==pkt.taildesc_pnt;desc.next_desc_pntr_msb==pkt.taildesc_pnt_msb;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end

        control_reg[3]=1'b1;
        control_reg[6]=1'b1;
        control_reg[12]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
        reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt_msb);
        reg_model.taildesc_pnt.write(status,32'h50);
        reg_model.taildesc_pnt_msb.write(status,32'h00);
        //repeat(2) begin
           wait(obj.mas_if[0].cdma_introut);
           //reg_model.cdmasr.IOC_Irq.write(status,1'b1);
       //end   
    endtask*/

    task body();
        super.body();
        reg_seq=reg_seq_item::type_id::create("reg_seq");
        assert(reg_seq.randomize())
        else `uvm_error("sg_mode_slave_error_seq","Failed in randomize resgister sequence item")
         
         current_address={reg_seq.curdesc_pnt_msb,reg_seq.curdesc_pnt};
         for(int i=1;i<=5;i++)begin
            desc=descriptor_seq_item::type_id::create("desc");
            if(i!=4)
            assert(desc.randomize());
            else 
            assert(desc.randomize() with {desc.next_desc_pntr==reg_seq.taildesc_pnt;desc.next_desc_pntr_msb==reg_seq.taildesc_pnt_msb;});
            mem_model.write(current_address,desc);
            current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
         end
       
             control_reg[3]=1'b1;
             control_reg[6]=1'b1;
             control_reg[14]=1'b1;
             reg_model.cdmacr.write(status,control_reg);
             reg_model.curdesc_pnt.write(status,reg_seq.curdesc_pnt);
             reg_model.curdesc_pnt_msb.write(status,reg_seq.curdesc_pnt_msb);
             reg_model.taildesc_pnt.write(status,32'h0000);
             reg_model.taildesc_pnt_msb.write(status,32'h50);
             wait(obj.mas_if[0].cdma_introut);
             reg_model.cdmasr.read(status,data);
    endtask

endclass


//////////////sequence for verifying scoreboard//////////
class sbd_verify_seq extends base_master_sequence;
    `uvm_object_utils(sbd_verify_seq)

    function new(string name="sbd_verify_seq");
        super.new(name);
    endfunction

cdma_reg_block reg_model;
    uvm_reg_data_t data;
    reg_seq_item pkt;
    uvm_status_e status;
    bit[31:0] control_reg;
    descriptor_seq_item desc,desc1;
    axi_slave_mem_model mem_model;
    task body();
    super.body();
    pkt=reg_seq_item::type_id::create("pkt");
    desc=descriptor_seq_item::type_id::create("desc");
    desc1=descriptor_seq_item::type_id::create("desc1");

    if(!pkt.randomize() with {pkt.curdesc_pnt==32'h1000;})begin
        `uvm_error("SG_MEM","Failed to randomize register sequence item")
    end
    if(!uvm_config_db#(axi_slave_mem_model)::get(null,get_full_name(),"memory",mem_model))begin
        `uvm_error("SG_MEM","Failed in getting memory handle")
    end
    do begin
    reg_model.cdmasr.read(status,data);
    end while(data[1]==0);

    desc.next_desc_pntr=32'h3000;
    desc.next_desc_pntr_msb=32'h0000;
    desc.sa=32'h5000;
    desc.sa_msb=32'h00000;
    desc.da=32'h8_0000;
    desc.da_msb=32'h0000;
    desc.control=26'h8001;
    desc.status=32'h0000;

    mem_model.write(32'h3000,desc);

    desc1.next_desc_pntr=32'h0000;
    desc1.next_desc_pntr_msb=32'h0000;
    desc1.sa=32'hFF000;
    desc1.sa_msb=32'h0000;
    desc1.da=32'hF000_0000;
    desc1.da_msb=32'h0000;
    desc1.control=26'h5000;
    desc1.status=32'h00;
    mem_model.write(32'h1000,desc1);

    control_reg[3]=1'b1;
    control_reg[12]=1'b1;
    control_reg[14]=1'b1;
    control_reg[23:16]=8'h1;

    reg_model.cdmacr.write(status,control_reg);
    reg_model.curdesc_pnt.write(status,32'h3000);
    reg_model.curdesc_pnt_msb.write(status,32'h0000);
    reg_model.taildesc_pnt.write(status,32'h1000);
    reg_model.taildesc_pnt_msb.write(status,32'h000);
    wait(obj.mas_if[0].cdma_introut);
    reg_model.cdmasr.read(status,data);
    endtask

endclass

class fixed_trans_seq extends base_master_sequence;
    `uvm_object_utils(fixed_trans_seq)

    function new(string name="fixed_trans_seq");
        super.new(name);
    endfunction
    
        bit[31:0] control_reg;
    task body();
        super.body();
        pkt=reg_seq_item::type_id::create("pkt");
        assert(pkt.randomize());
        control_reg[4]=1'b1;
        reg_model.cdmacr.write(status,control_reg);
        reg_model.sa.write(status,32'h1001);
        reg_model.da.write(status,32'h4000);
        reg_model.btt.write(status,26'd4097);
    endtask
endclass

////////////////////////back to back sg mode sequence//////////////////
class back_to_back_sg_mode_seq extends base_master_sequence;
    `uvm_object_utils(back_to_back_sg_mode_seq)

    function new(string name="back_to_back_sg_mode_seq");
        super.new(name);
    endfunction
    bit[31:0] control_reg;
    descriptor_seq_item desc;
    bit[63:0] current_address;
    task body();
        super.body();
            pkt=reg_seq_item::type_id::create("pkt");
            assert(pkt.randomize());

            desc=descriptor_seq_item::type_id::create("desc");

            control_reg[3]=1'b1;
            control_reg[23:16]=8'd5;
            control_reg[12]=1'b1;
            current_address={pkt.curdesc_pnt_msb,pkt.curdesc_pnt};
            for(int i=1;i<=5;i++)begin
                if(i!=4)
                     assert(desc.randomize());
                else 
             assert(desc.randomize() with {desc.next_desc_pntr==pkt.taildesc_pnt;desc.next_desc_pntr_msb==pkt.taildesc_pnt_msb;});
             current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
             mem_model.write(current_address,desc);
            end
            reg_model.cdmacr.write(status,control_reg);
            reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
            reg_model.curdesc_pnt_msb.write(status,pkt.curdesc_pnt_msb);
            reg_model.taildesc_pnt.write(status,pkt.taildesc_pnt);
            reg_model.taildesc_pnt_msb.write(status,pkt.taildesc_pnt_msb);


            assert(pkt.randomize());
            current_address={pkt.curdesc_pnt_msb,pkt.curdesc_pnt};
            for(int i=1;i<=5;i++)begin
                if(i!=4)
                     assert(desc.randomize());
                else 
             assert(desc.randomize() with {desc.next_desc_pntr==pkt.taildesc_pnt;desc.next_desc_pntr_msb==pkt.taildesc_pnt_msb;});
             current_address={desc.next_desc_pntr_msb,desc.next_desc_pntr};
                 mem_model.write(current_address,desc);
            end
            reg_model.curdesc_pnt.write(status,pkt.curdesc_pnt);
            reg_model.curdesc_pnt_msb.write(status,pkt.curdesc_pnt_msb);
            reg_model.taildesc_pnt.write(status,pkt.taildesc_pnt);
            reg_model.taildesc_pnt_msb.write(status,pkt.taildesc_pnt_msb);

            do begin
                reg_model.cdmasr.read(status,data);
           end while(data[1]==0);

    endtask
endclass

class cdma_random_sequence extends base_master_sequence;
    `uvm_object_utils(cdma_random_sequence)

    function new(string name="cmda_random_sequence");
        super.new(name);
    endfunction

    task body();
    endtask
endclass
