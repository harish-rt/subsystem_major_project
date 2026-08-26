class cdma_sbd extends uvm_scoreboard;
    `uvm_component_utils(cdma_sbd)
    
    //declare analysis fifo 
    uvm_tlm_analysis_fifo#(master_seq_item) m_af;
    uvm_tlm_analysis_fifo#(slave_seq_item) s_af[];
    
    axi_cdma_config_obj obj;
    cdma_reg_block reg_model;
    slave_seq_item read_predict[$],write_predict[$];
    function new(string name="cdma_sbd",uvm_component parent);
        super.new(name,parent);
    endfunction

    bit[31:0] cdmacr;
    bit[31:0] cdmasr;
    bit[31:0] curdesc_pnt;
    bit[31:0] curdesc_pnt_msb;
    bit[31:0] taildesc_pnt;
    bit[31:0] taildesc_pnt_msb;
    bit[31:0] sa;
    bit[31:0] sa_msb;
    bit[31:0] da;
    bit[31:0] da_msb;
    bit[31:0] btt;
    bit[31:0] next_desc;
    bit[31:0] next_desc_msb;
    bit[31:0] status;
    bit pre_internal_error,pre_slave_error,pre_decode_error,predict_sg_slave_err,predict_sg_decode_err,predict_sg_internal_err;
    bit [63:0] raddr,wraddr;
    bit [7:0] wr_data_predict[$];
    bit [7:0] act_wr_data[$];
    bit[31:0] wdata;
    bit cmplt,desc_decode_err,desc_slave_err,desc_internal_err;
    int pred_rd_cnt,pred_wr_cnt,act_rd_cnt,act_wr_cnt;
    int desc_rd_count;
    slave_seq_item wdata_queue[$],rdata_queue[$];
    slave_seq_item desc_queue[$];
    slave_seq_item read_data_queue[$];
    bit[7:0] exp_wdata[$];
    bit[63:0] raddrq[$];
    bit[26:0] btt_q[$];
    bit   desc_active = 0;
    int        remaining_desc_btt;
    bit [63:0] current_araddr;

    function void build_phase(uvm_phase phase);
        m_af=new("m_af",this);
        
        if(!uvm_config_db#(axi_cdma_config_obj)::get(this,"","axi_cdma_config_obj",obj))
            `uvm_error("cdma_sbd_build_phase","failed in getting config object")
        s_af=new[obj.no_of_slaves];
        foreach(s_af[i])begin
            s_af[i]=new($sformatf("s_af[%0d]",i),this);
        end
    endfunction
    
    task main_phase(uvm_phase phase);
        fork
            get_config_pkt();
            get_desc_pkt();
            get_data_pkt();
        join
    endtask

    extern task get_config_pkt();
    extern task get_desc_pkt();
    extern task get_data_pkt();
    extern function void read_prediction(bit[63:0]raddr);
    extern function void write_prediction(bit[63:0]wraddr);
    extern function void read_addr_compare(slave_seq_item pkt);
    extern function void write_data_prediction();
    extern function void write_addr_compare(slave_seq_item pkt);
    extern function void write_data_process();
    extern function void status_reg_check();
    extern function void descriptor_check(slave_seq_item pkt);
    //extern function void check_phase(uvm_phase phase);
endclass

task cdma_sbd::get_config_pkt();
    master_seq_item pkt;
    forever begin
        `uvm_info("sbd::get_config_pkt","waiting for config packet",UVM_LOW)
            m_af.get(pkt);
        `uvm_info("sbd::get_config_pkt","got config pkt",UVM_LOW)
        if(pkt.operation==WRITE)begin
            pre_internal_error=1'b0;
            if(pkt.awaddr=='h28)begin
                cdmacr=reg_model.cdmacr.get_mirrored_value();
                sa=reg_model.sa.get_mirrored_value();
                sa_msb=reg_model.sa_msb.get_mirrored_value();
                da=reg_model.da.get_mirrored_value();
                da_msb=reg_model.da_msb.get_mirrored_value();
                btt=reg_model.btt.get_mirrored_value();
                raddr={sa_msb,sa};
                wraddr={da_msb,da};
                if(btt=='h0) begin
                    pre_internal_error =1'b1;
                    `uvm_info("sbd::get_config_pkt",$sformatf("Internal error predicted=%h",pre_internal_error),UVM_LOW)
                end
                else begin
                    read_prediction(raddr);
                    write_prediction(wraddr);
                end
            end
            else if(pkt.awaddr=='h14)begin
               cdmacr=reg_model.cdmacr.get_mirrored_value();
               curdesc_pnt=reg_model.curdesc_pnt.get_mirrored_value();
               curdesc_pnt_msb=reg_model.curdesc_pnt_msb.get_mirrored_value();
               taildesc_pnt=reg_model.curdesc_pnt.get_mirrored_value();
               taildesc_pnt_msb=reg_model.curdesc_pnt.get_mirrored_value();
            end
        end

        else if(pkt.operation==READ)begin
            if(pkt.araddr=='h04)begin
                cdmasr=pkt.rdata[0];
                status_reg_check();

            end
        end
    end
endtask


task cdma_sbd::get_desc_pkt();
    slave_seq_item pkt;
    forever begin
      `uvm_info("sbd::get_desc_pkt","waiting for desciptor packet",UVM_LOW)
        s_af[0].get(pkt);
      `uvm_info("sbd::get_desc_pkt","got descriptor packet",UVM_LOW)
      if(pkt.operation==READ)begin

        `uvm_info("sbd::get_desc_pkt_read_pkt",pkt.sprint(),UVM_DEBUG)
        predict_sg_slave_err=1'b0;
        predict_sg_decode_err=1'b0;
        //pre_internal_error=1'b0;
        predict_sg_internal_err=1'b0;
        //check for descriptor data correctness
        descriptor_check(pkt);

        foreach(pkt.rresp[i])begin
            if(pkt.rresp[i]==SLVERR)begin
                predict_sg_slave_err=1'b1;
                `uvm_info("sbd::ge_desc_pkt","predicted sg_slave error",UVM_LOW)
            end

            if(pkt.rresp[i]==DECERR)begin
                predict_sg_decode_err=1'b1;
                `uvm_info("sbd::get_desc_pkt","predicted sg decode error",UVM_LOW)
            end

            if(pkt.rdata[7]==32'h8000_0000)begin
            predict_sg_internal_err=1'b1;
            `uvm_info("sbd::get_desc_pkt",$sformatf("Predicted SGInternal error=%0b",predict_sg_internal_err),UVM_LOW)
         end

         if(pkt.rdata[6]==26'h000_0000)begin
            pre_internal_error=1'b1;
            `uvm_info("get_desc_pkt",$sformatf("Predicted DMA Internal error for descriptor"),UVM_LOW)
         end

        end
        if(predict_sg_slave_err==1'b0 && predict_sg_decode_err==1'b0 && predict_sg_internal_err==1'b0 && pre_internal_error==1'b0)
        begin
            //collect descripot data fields
            desc_rd_count++;
            next_desc=pkt.rdata[0];
            next_desc_msb=pkt.rdata[1];
            sa=pkt.rdata[2];
            sa_msb=pkt.rdata[3];
            da=pkt.rdata[4];
            da_msb=pkt.rdata[5];
            btt=pkt.rdata[6];
            status=pkt.rdata[7];
            desc_queue.push_back(pkt);
            raddr={sa_msb,sa};
            `uvm_info("get_desc_pkt",$sformatf("DESC_RDADDR=%0h",raddr),UVM_DEBUG)
            raddrq.push_back(raddr);
            btt_q.push_back(btt);
            wraddr={da_msb,da};
            `uvm_info("get_desc_pkt",$sformatf("DESC_WRADDR=%0h",wraddr),UVM_DEBUG)

            `uvm_info("get_desc_pkt",$sformatf("DESC_BTT=%0h",btt),UVM_DEBUG)

            //invoke read and write prediction functions
            read_prediction(raddr);
            write_prediction(wraddr);
        end
      end
      else if(pkt.operation==WRITE)begin
        `uvm_info("sbd::got_desc_pkt_wr_pkt",pkt.sprint(),UVM_DEBUG)
         wdata=pkt.wdata[0];
            //data_comparison();
         if(pkt.bresp==DECERR)begin
           predict_sg_decode_err=1'b1;
           `uvm_info("get_dec_pkt","predicted sg decode errror for write response",UVM_LOW)
          end 

         if(pkt.bresp==SLVERR)begin
            predict_sg_slave_err=1'b1;
            `uvm_info("get_desc_pkt","predicted sg_slave error for bresponse",UVM_LOW)
         end 

        cmplt=wdata[31];
        desc_decode_err=wdata[30];
        desc_slave_err=wdata[29];
        desc_internal_err=wdata[28];
      end
    end
endtask


task cdma_sbd::get_data_pkt();
    slave_seq_item pkt;
    forever begin
    `uvm_info("sbd::get_data_pkt","waiting for data packet",UVM_LOW)
     s_af[1].get(pkt);
    `uvm_info("sbd::get_data_pkt","got data packet",UVM_LOW)
    if(pkt.operation==READ)begin
        `uvm_info("sbd::get_rd_data_pkt",pkt.sprint(),UVM_LOW)

        pre_slave_error=1'b0;
        pre_decode_error=1'b0;
        
        foreach(pkt.rresp[i])begin
            if(pkt.rresp[i]==SLVERR)
            pre_slave_error=1'b1;

            if(pkt.rresp[i]==DECERR)
            pre_decode_error=1'b1;
        end

        //if(pre_decode_error==1'b0 && pre_slave_error==1'b0)begin
            act_rd_cnt++;
            rdata_queue.push_back(pkt);
            write_data_prediction();
            read_addr_compare(pkt);
        //end

    end

    else if(pkt.operation==WRITE)
        `uvm_info("sbd::get_wr_data_pkt",pkt.sprint(),UVM_LOW)
        
        if(pkt.bresp==SLVERR)
            pre_slave_error=1'b1;

        if(pkt.bresp==DECERR)
            pre_decode_error=1'b1;
        
        
          if(pkt.awaddr>0)begin
             wdata_queue.push_back(pkt);
             act_wr_cnt++;
             write_addr_compare(pkt);
             write_data_process();
            end

    end    
endtask

function void cdma_sbd::read_prediction(bit[63:0] raddr);
slave_seq_item pred_pkt;
bit[63:0] araddr;
bit[31:0] remaining_bytes;
int max_bytes;
int bytes_per_beat=16;
int offset;
int exp_bytes;
int per_tx_btt;
int no_of_tx;
remaining_bytes=btt;
max_bytes=4096;
araddr=raddr;

while(remaining_bytes>0)begin
    pred_pkt=slave_seq_item::type_id::create("pred_pkt");
   $display("raddr=%0h",raddr); 
    exp_bytes=max_bytes-raddr%max_bytes;
    `uvm_info("sbd::read_predict_expected_bytes",$sformatf("exp_bytes=%0h araddr=%0h",exp_bytes,raddr),UVM_DEBUG)

    pred_pkt.arsize=$clog2(bytes_per_beat);
    pred_pkt.araddr=araddr;
    pred_pkt.arburst=burst_type_t'((cdmacr[4]==0)? 2'b01: 2'b00); 

    //FIRST BURST
    if(no_of_tx==0)begin
        offset=raddr%bytes_per_beat;
        per_tx_btt=(remaining_bytes<=exp_bytes)?remaining_bytes:exp_bytes;
        `uvm_info("sbd",$sformatf("PER_TX_BTT=%0h",per_tx_btt),UVM_DEBUG)
        `uvm_info("sbd::read_prediction",$sformatf("per_tx_btt=%0h",per_tx_btt),UVM_LOW)
        pred_pkt.arlen=$ceil((per_tx_btt+offset)/real'(bytes_per_beat))-1;
        `uvm_info("sbd_read_prediction_arlen_first_beat",$sformatf("ARELEN=%0h addar=%0h",pred_pkt.arlen,pred_pkt.araddr),UVM_DEBUG)
    end
    //LAST BURST
    else if(remaining_bytes<exp_bytes)begin
        per_tx_btt=remaining_bytes;
        `uvm_info("sbd",$sformatf("PER_TX_BTT=%0h",per_tx_btt),UVM_DEBUG)
        pred_pkt.arlen=$ceil(per_tx_btt/real'(bytes_per_beat))-1;
        `uvm_info("sbd_read_prediction_arlen_last_beat",$sformatf("ARELEN=%0h addar=%0h",pred_pkt.arlen,pred_pkt.araddr),UVM_DEBUG)
    end
    //MIDDLE BURST
    else begin
        per_tx_btt=exp_bytes;
        `uvm_info("sbd",$sformatf("PER_TX_BTT=%0h",per_tx_btt),UVM_DEBUG)
        pred_pkt.arlen=$ceil(per_tx_btt/real'(bytes_per_beat))-1;
        `uvm_info("sbd_read_prediction_arlen_middle_beat",$sformatf("ARELEN=%0h addar=%0h",pred_pkt.arlen,pred_pkt.araddr),UVM_DEBUG)
    end
    `uvm_info("sbd::read_prediction_pushing_predicted_read_packet",pred_pkt.sprint(),UVM_DEBUG)
    read_predict.push_back(pred_pkt);
    pred_rd_cnt++;
    no_of_tx++;
    remaining_bytes=remaining_bytes-per_tx_btt;
    raddr+=per_tx_btt;
    `uvm_info("sbd_read_prediction_remaining_bytes",$sformatf("remaining_bytes=%0h",remaining_bytes),UVM_DEBUG)
    if(cdmacr[4]==1'b0)
        araddr=araddr+per_tx_btt;
    else
        araddr=araddr;
    `uvm_info("sbd::read_prediction",$sformatf("raddr=%0h",raddr),UVM_DEBUG)   
end
endfunction

function void cdma_sbd::write_prediction(bit [63:0] wraddr);
slave_seq_item pred_pkt;
int bytes_per_beat=16;
int remaining_bytes;
int max_btt;
int per_tx_btt;
int no_of_tx;
int exp_bytes;
int num_of_beats;
int offset;
bit[63:0]awaddr;
awaddr=wraddr;
max_btt=4096;
//offset=
remaining_bytes=btt;
no_of_tx=0;
`uvm_info("sbd::write_predict",$sformatf("remaining bytes=%0d btt=%0d",remaining_bytes,btt),UVM_DEBUG)
while(remaining_bytes>0)begin
    int last_bytes;
    pred_pkt=slave_seq_item::type_id::create("pred_pkt");

    exp_bytes=max_btt-wraddr%max_btt;
    `uvm_info("sbd::write_predict",$sformatf("EXP_bytes=%0d",exp_bytes),UVM_DEBUG)

    pred_pkt.awaddr=awaddr;
    `uvm_info("sbd::write_predict",$sformatf("predicted addrss for burst=%0h",pred_pkt.awaddr),UVM_DEBUG)

    pred_pkt.awsize=$clog2(bytes_per_beat);
    pred_pkt.awburst=burst_type_t'((cdmacr[5]==0)? 2'b01 : 2'b00);
    
    if(no_of_tx==0)begin
        offset=wraddr%bytes_per_beat;
        per_tx_btt=(remaining_bytes<=exp_bytes)?remaining_bytes:exp_bytes;
        `uvm_info("wr_pk_pred",$sformatf("per_tx_btt=%0h",per_tx_btt),UVM_LOW);
        num_of_beats=$ceil((per_tx_btt+offset)/real'(bytes_per_beat));
        $display("number of beats=%0h",num_of_beats);
        pred_pkt.awlen=num_of_beats-1;
        `uvm_info("sbd::write_predict",$sformatf("predicted awlen for first  burst=%0h",pred_pkt.awlen),UVM_DEBUG)
        
        pred_pkt.wstrobe=new[num_of_beats];
        foreach(pred_pkt.wstrobe[i])begin
            if(i==0)
                pred_pkt.wstrobe[i]=16'hFFFF<<offset;

            else if(i==pred_pkt.awlen)begin
                    last_bytes=per_tx_btt%bytes_per_beat;
                    if(last_bytes==0)
                        pred_pkt.wstrobe[i]=16'hFFFF;
                    else
                        pred_pkt.wstrobe[i]=16'hFFFF>>last_bytes;
            end

           else
                pred_pkt.wstrobe[i]=16'hFFFF;
        end
       `uvm_info("write_predict_strobe",$sformatf("%p",pred_pkt.wstrobe),UVM_DEBUG) 
    end
    else if(remaining_bytes<exp_bytes)begin
        per_tx_btt=remaining_bytes;
        num_of_beats=$ceil(per_tx_btt/real'(bytes_per_beat));
        pred_pkt.awlen=num_of_beats-1;
        `uvm_info("sbd::write_predict",$sformatf("predicted awlen for last burst=%0h",pred_pkt.awlen),UVM_DEBUG)
        pred_pkt.wstrobe=new[num_of_beats];
        foreach(pred_pkt.wstrobe[i])begin
            if(i==pred_pkt.awlen)begin
                last_bytes=per_tx_btt%bytes_per_beat;
                if(last_bytes==0)
                    pred_pkt.wstrobe[i]=16'hFFFF;
                else 
                    pred_pkt.wstrobe[i]=16'hFFFF<<(bytes_per_beat-last_bytes);
            end
            else
                pred_pkt.wstrobe[i]=16'hFFFF;
        end
       `uvm_info("write_predict_strobe",$sformatf("%p",pred_pkt.wstrobe),UVM_DEBUG) 
    end
    else begin
        per_tx_btt=exp_bytes;
        num_of_beats=$ceil(per_tx_btt/real'(bytes_per_beat));
        pred_pkt.awlen=num_of_beats-1;
        `uvm_info("sbd::write_predict",$sformatf("predicted awlen for middle burst=%0h",pred_pkt.awlen),UVM_DEBUG)
        pred_pkt.wstrobe=new[num_of_beats];
        foreach(pred_pkt.wstrobe[i])
            pred_pkt.wstrobe[i]=16'hFFFF;
        `uvm_info("sbd::write_predict",$sformatf("predicted_strobe_middle_packet=%p",pred_pkt.wstrobe),UVM_DEBUG)    
    end
    `uvm_info("sbd::write_predict",pred_pkt.sprint(),UVM_LOW)
    `uvm_info("sbd::write_predict","pushing predicted packet to queue",UVM_DEBUG)
    write_predict.push_front(pred_pkt);
    pred_wr_cnt++;
    wraddr+=per_tx_btt;
    remaining_bytes=remaining_bytes-per_tx_btt;
    if (cdmacr[5] == 1'b0)
        awaddr = awaddr + per_tx_btt;
    else
        awaddr = awaddr;
    `uvm_info("sbd::write_predict",$sformatf("ADDRESS predicted for next trasaction=%0h",wraddr),UVM_DEBUG)
    no_of_tx ++;
end
endfunction

function void cdma_sbd::read_addr_compare(slave_seq_item pkt);
    slave_seq_item pred_pkt;
    if(read_predict.size()>0)begin
       pred_pkt=read_predict.pop_front();

       //READ address comaprison
       if(pred_pkt.araddr==pkt.araddr)
        `uvm_info("sbd::read_addr_compare",$sformatf("ARADDR match found expectd_addr=%0h actual_addr=%0h",pred_pkt.araddr,pkt.araddr),UVM_LOW)
        else `uvm_error("sbd::read_addr_compare",$sformatf("ARADDR mismatch found expected_addr=%0h ctual_addr=%0h",pred_pkt.araddr,pkt.araddr))

        //arsize comaprison
        if(pred_pkt.arlen==pkt.arlen)
       `uvm_info("sbd::read_addr_compare",$sformatf("ARLEN match found expected_arlen=%0h actual_arlen=%0h",pred_pkt.arlen,pkt.arlen),UVM_LOW)
        else 
        `uvm_error("sbd::read_addr_compare",$sformatf("ARLEN mismatch found expected_arlen=%0h actual_arlen=%0h",pred_pkt.arlen,pkt.arlen))

        //arlen comparison
        if(pred_pkt.arsize==pkt.arsize)
        `uvm_info("sbd::read_addr_compare",$sformatf("ARSIZE macth found expected_arsize=%0h actual_arsize=%0h",pred_pkt.arsize,pkt.arsize),UVM_LOW)
        else 
        `uvm_error("sbd::read_addr_compare",$sformatf("ARSIZE mismatch found expected_asize=%0h actual_arsize=%0h",pred_pkt.arsize,pkt.arsize))

        //arburst comparison

    if (pkt.arburst == pred_pkt.arburst)
    `uvm_info("READ_COMPARE", $sformatf("ARBURST matched: actual=%0b predicted=%0b",pkt.arburst, pred_pkt.arburst), UVM_NONE)
    else
    `uvm_error("READ_COMPARE", $sformatf("ARBURST mismatch: actual=%0b predicted=%0b",pkt.arburst, pred_pkt.arburst))


    end
    else 
        `uvm_error("sbd::read_addr_comapre","Read predicted queue empty")
endfunction

function void cdma_sbd::write_data_prediction();
    int local_btt;
    int invalid_bytes_at_front;
    int invalid_bytes_at_last;
    int offset;
    int bytes_per_beat;
    bit[63:0] araddr;
    bit[7:0] temp_data;
    slave_seq_item pkt,desc_pkt;
    int pkt_bytes; 
    bytes_per_beat='d16;

    `uvm_info("write_data_prediction","Inside write data prediction",UVM_LOW)
     if(rdata_queue.size()>0) begin
        pkt=rdata_queue.pop_front();
        `uvm_info("write_data_prediction_po_rd_pkt",pkt.sprint(),UVM_DEBUG)
        //local_btt=(cdmacr[3]==1'b0)? btt : btt_q.pop_front();
        //araddr=(cdmacr[3]==1'b0)? raddr : raddrq.pop_front();
       
       if(cdmacr[3]) begin
            if(!desc_active) begin
                remaining_desc_btt = btt_q[0];
                current_araddr = raddrq[0];
                desc_active = 1;
            end
            local_btt = remaining_desc_btt;
            araddr    = current_araddr;
        end
        else begin
            local_btt = btt;
            araddr    = raddr;
        end
       
       for(int i=0;i<(pkt.arlen+1);i++)begin
           for(int j=0;j<(2**pkt.arsize);j++)begin
            wr_data_predict.push_back(pkt.rdata[i][(j*8) +:8]);
           end
       end

       `uvm_info("write_data_prediction",$sformatf("predicted write data queue =%0h",wr_data_predict.size()),UVM_DEBUG)
       `uvm_info("write_data_prediction",$sformatf("predicted write data %p",wr_data_predict),UVM_DEBUG)
        offset=araddr%bytes_per_beat;
        $display("read address inside the write data prediction task=%0h",araddr);
        `uvm_info("write_data_prediction",$sformatf("offset=%0h",offset),UVM_DEBUG)
        $display("local btt=%0h",local_btt);
        if(wr_data_predict.size()>local_btt)begin
            invalid_bytes_at_front=offset;
            `uvm_info("write_data_prediction",$sformatf("INVALID BYTES AT FRONT=%0h",invalid_bytes_at_front),UVM_DEBUG)
            if(offset!=0)begin
                for(int k=0;k<invalid_bytes_at_front;k++)begin
                   void'(wr_data_predict.pop_front());
                end
            end

         `uvm_info("sbd::wr_data_prediction",$sformatf("predicted write data queue size after poping inavlid bytes=%0h",
         wr_data_predict.size()),UVM_DEBUG)
         `uvm_info("sbd::wr_data_predcition",$sformatf("after poping invalid bytes at front=%p",wr_data_predict),UVM_DEBUG)

         invalid_bytes_at_last=wr_data_predict.size()-local_btt;
         `uvm_info("sbd::wr_data_prediction",$sformatf("invalid_bytes_at_last=%0h local_btt=%0h",invalid_bytes_at_last,local_btt),UVM_DEBUG)

         for(int j=0;j<invalid_bytes_at_last;j++)begin
            void'(wr_data_predict.pop_back());
         end

         `uvm_info("sbd::wr_data_predict",$sformatf("after poping invalid bytes at last=%p",wr_data_predict),UVM_DEBUG)
         `uvm_info("sbd::wr_data_predict",$sformatf("predicted_wr_data queue size=%0h",wr_data_predict.size()),UVM_DEBUG)

        end

         `uvm_info("sbd::wr_data_predict",$sformatf("final predicted queue=%p",wr_data_predict),UVM_DEBUG)
         if(cdmacr[3]) begin

            pkt_bytes =(pkt.arlen+1)*(2**pkt.arsize);
            remaining_desc_btt -= pkt_bytes;

            if(remaining_desc_btt <= 0) begin
                void'(btt_q.pop_front());
                void'(raddrq.pop_front());
                desc_active   = 0;
                remaining_desc_btt = 0;
            end
        end 

      end
      `uvm_info("DESC_DEBUG",$sformatf("Descriptor SA=0x%0hBTT=%0d",araddr, local_btt),UVM_LOW)
      `uvm_info("QUEUE_STATUS",$sformatf("final predicted queue_size=%h",wr_data_predict.size()),UVM_DEBUG)
    
  
        while(wr_data_predict.size() > 0) begin
            exp_wdata.push_back(wr_data_predict.pop_front());
        end
    $display("exp_wdata_size=%0h",exp_wdata.size());
    wr_data_predict.delete();
 endfunction


function void cdma_sbd::write_addr_compare(slave_seq_item pkt);
    slave_seq_item pre_pkt;
    $display("write predicted queue size=%0h",write_predict.size());
    if(write_predict.size()>0)begin
        pre_pkt=write_predict.pop_back();

        //compare write address
        if(pre_pkt.awaddr==pkt.awaddr)
       `uvm_info("sbd::write_addr_compare",$sformatf("AWADDR match predicted=%0h actual=%0h",pre_pkt.awaddr,pkt.awaddr),UVM_LOW)
        else
         `uvm_error("sbd::write_addr_compare",$sformatf("AWADDR mismatch predited=%0h actual=%0h",pre_pkt.awaddr,pkt.awaddr))

         //compare awburst 
        if(pre_pkt.awburst==pkt.awburst)
        `uvm_info("sbd::write_addr_compare",$sformatf("AWBURST match predicted=%0b actual=%0b",pre_pkt.awburst,pkt.awburst),UVM_LOW)
        else 
        `uvm_error("sbd::write_addr_compare",$sformatf("AWBURST mismatch predicted=%0b actual=%0b",pre_pkt.awburst,pkt.awburst))

        //compare arlen 
        if(pre_pkt.awlen==pkt.awlen)
         `uvm_info("sbd::write_addr_compare",$sformatf("AWLEN match found predicted=%0h actual=%0h",pre_pkt.awlen,pkt.awlen),UVM_LOW)
         else
         `uvm_error("sbd::write_addr_compare",$sformatf("AWLEN mismatch predicted=%0h actual=%0h",pre_pkt.awlen,pkt.awlen))

         //compare arsize
        if(pre_pkt.awsize==pkt.awsize)
        `uvm_info("sbd::write_addr_compare",$sformatf("AWSIZE match predicted=%0h actual=%0h",pre_pkt.awsize,pkt.awsize),UVM_LOW)
        else
        `uvm_error("sbd::write_addr_compare",$sformatf("AWSIZE mismatch predicted=%0h actual=%0h",pre_pkt.awsize,pkt.awsize))
    end
    else `uvm_error("sbd::write_add_compare","Predicted queue is empty")

endfunction

function void cdma_sbd::write_data_process();

   slave_seq_item pkt;
   bit [7:0] byte_data;
   bit [7:0] exp_wr_data;

   int count ;
   `uvm_info("SBD", "Inside write_data_process",UVM_DEBUG)
   pkt = wdata_queue.pop_front();
    `uvm_info("write_data_porcess::pop_wr_pkt",pkt.sprint(),UVM_DEBUG)
   for (int beat = 0; beat < pkt.wdata.size(); beat++) begin
      for (int byt = 0; byt < (2**pkt.awsize); byt++) begin
         if (pkt.wstrobe[beat][byt] == 1'b1) begin
            byte_data = pkt.wdata[beat][(byt*8) +: 8];
            exp_wr_data=exp_wdata.pop_front();
            if(exp_wr_data==byte_data)begin
            `uvm_info("data_check_pass",$sformatf("exp=%0h actual=%0h",exp_wr_data,byte_data),UVM_DEBUG)
             count++;
            end
            else
                `uvm_error("data_check_fail",$sformatf("exp=%0h actual=%0h",exp_wr_data,byte_data))

         end
      end
   end
   `uvm_info("SBD",$sformatf("count = %0d",count), UVM_DEBUG)
endfunction



/*function void cdma_sbd::data_comparison();
    
    bit[7:0] actual_wdata;
    bit[7:0] predicted_wdata;
    int count;

    `uvm_info("cdma_sbd::data_comparison","Inside data comparison task",UVM_LOW)
      if(wr_data_predict.size()>0 && act_wr_data.size()>0)begin
        $display("oustide loop predited size queue=%0h",wr_data_predict.size());
        $display("outside for loop actual write data queue size=%0h",act_wr_data.size());
        `uvm_info("Inside_write_data_pocess",$sformatf("actual write data=%p",act_wr_data),UVM_DEBUG)
        `uvm_info("Inside_write_data_process",$sformatf("predicted write data=%p",wr_data_predict),UVM_DEBUG)
        //for(int i=0;i<wr_data_predict.size();i++)begin
       for(int i=0;act_wr_data.size();i++)begin
            actual_wdata=act_wr_data.pop_front();
            predicted_wdata=wr_data_predict.pop_front();

            `uvm_info("cdma_sbd::data_comparison",$sformatf("actual_wr_data_queue size=%0h predicted write data queue sze=%0h",act_wr_data.size(),wr_data_predict.size()),UVM_DEBUG)

            if(actual_wdata==predicted_wdata)begin
                `uvm_info("cdma_sbd::data_comaprison","Data check pass",UVM_LOW)
                count++;
                `uvm_info("cdma_sbd::data_comparison",$sformatf("actual_wdata=%0h predicted_wdata=%0h",actual_wdata,predicted_wdata),UVM_DEBUG)
            end
            else begin
                `uvm_error("cdma_sbd::data_comaprison",$sformatf("data comparison fail actual_wdata=%0h predicted_wdata=%0h",actual_wdata,predicted_wdata))
            end
        end

        `uvm_info("scoreboard_passed_count",$sformatf("count=%0d",count),UVM_DEBUG)
     end
endfunction*/


function void cdma_sbd::status_reg_check();

   //check for DMA internal error 
    if(pre_internal_error==1)begin
        if(cdmasr[14]==1'b1 && cdmasr[4]==1'b1)
            `uvm_info("cdma_sbd::status_reg_check","DMA internal error has occured",UVM_LOW)
        else
           `uvm_error("cdma_sbd::status_reg_check","Failed to set DMA internal error even after writing zero to btt")
    end

 //check for DMA SLAVE error 
    if(pre_slave_error==1)begin
        if(cdmasr[14]==1'b1 && cdmasr[5]==1'b1)
            `uvm_info("cdma_sbd::status_reg_check","DMA slave error has occured",UVM_LOW)
        else
           `uvm_error("cdma_sbd::status_reg_check","Failed to set DMA slave error")
    end

//check for DMA DECODE error
    if(pre_decode_error==1)begin
        if(cdmasr[14]==1'b1 && cdmasr[6]==1'b1)
            `uvm_info("cdma_sbd::status_reg_check","DMA decode error has occured",UVM_LOW)
        else
           `uvm_error("cdma_sbd::status_reg_check","Failed to set DMA decode error")
    end

//check for SG slave error
   if(predict_sg_slave_err==1)begin
        if(cdmasr[14]==1'b1 && cdmasr[9]==1'b1)
            `uvm_info("cdma_sbd::status_reg_check","SG slave error has occured",UVM_LOW)
        else
           `uvm_error("cdma_sbd::status_reg_check","Failed to set SG slave error")
    end

//check for SG DECODE error
    if(predict_sg_decode_err==1)begin
        if(cdmasr[14]==1'b1 && cdmasr[10]==1'b1)
            `uvm_info("cdma_sbd::status_reg_check","SG DECODE error has occured",UVM_LOW)
        else
           `uvm_error("cdma_sbd::status_reg_check","Failed to set SG DECODE error")
    end
 
//check for SG Internal error
    if(predict_sg_internal_err==1)begin
        if(cdmasr[14]==1'b1 && cdmasr[8]==1'b1)
            `uvm_info("cdma_sbd::status_reg_check","SG Internal has occured",UVM_LOW)
        else
           `uvm_error("cdma_sbd::status_reg_check","Failed to set SG Internal error")
    end
endfunction

function void cdma_sbd::descriptor_check(slave_seq_item pkt);
   axi_slave_mem_model mem_model;
   int index=0;

    if(!uvm_config_db#(axi_slave_mem_model)::get(this,"","memory",mem_model))
        `uvm_error("sbd::descriptor_check","Failed to retrive memory handle from config db")

     foreach(pkt.rdata[i])begin

        if(pkt.rdata[i]==mem_model.mem[pkt.araddr+index])
            `uvm_info("sbd::descriptor_check",$sformatf("Descriptor match addr=%0h expected data=%0h actual_data=%0h",pkt.araddr,
        pkt.rdata[i],mem_model.mem[pkt.araddr+index]),UVM_LOW)
        
        else 
         `uvm_error("sbd::descriptor_check",$sformatf("Descriptor miss match addr=%0h expected data=%0h actual_data=%0h",pkt.araddr,pkt.rdata[i],mem_model.mem[pkt.araddr+index]))
         index+=4;
     end
endfunction

/*function void cdma_sbd::check_phase(uvm_phase phase);
   if(pred_rd_cnt==act_rd_cnt)
        `uvm_info("cdma_sbd::check_phase",$sformatf("Read Packet count match pred_rd_=%0d act_rd=%0d",pred_rd_cnt,act_rd_cnt),UVM_LOW)
   else
         `uvm_error("cdma_sbd::check_phase",$sformatf("Read Packet count mismatch pred_rd=%0d act_rd=%0d",pred_rd_cnt,act_rd_cnt))

    if(pred_wr_cnt==act_wr_cnt)
        `uvm_info("cdma_sbd::check_phase",$sformatf("Write Packet count match pred_wr=%0d act_wr=%0d",pred_wr_cnt,act_wr_cnt),UVM_LOW)
    else 
        `uvm_error("cdma_sbd::check_phase",$sformatf("Write Packet count mismatch pred_wr=%0d act_wr=%0d",pred_wr_cnt,act_wr_cnt))
endfunction*/
