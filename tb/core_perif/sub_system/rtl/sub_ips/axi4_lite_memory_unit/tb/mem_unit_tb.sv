module mem_unit_tb;
  parameter ADDR_WIDTH 	= 32;
  parameter DATA_WIDTH 	= 32;
  
  bit                     clk;
  bit                     rst_n;
  bit   [ADDR_WIDTH-1:0]  awaddr, araddr;
  bit   [DATA_WIDTH-1:0]  wdata;
  logic [DATA_WIDTH-1:0]  rdata;
  time                    drive = 1ns;

  bit [ADDR_WIDTH-1:0] awaddr_q[$], araddr_q[$];
  bit [ADDR_WIDTH-1:0] wdata_q[$], rdata_q[$];

  always #5 clk = ~clk;
  
  axi4_lite_intf m_axi_intf();

  axi4_lite_memory_unit #(
    .AXI_AW        (ADDR_WIDTH),
    .AXI_DW        (DATA_WIDTH),
    .AXI_SW        (DATA_WIDTH >> 3),
    .MEM_BASE_ADDR (3'b100),
    .MEM_BYTES     (29)
    ) DUT (
    .s_axi_intf(m_axi_intf)
    );

  
  assign m_axi_intf.ACLK    = clk;
  assign m_axi_intf.ARESETn = rst_n;


  /*================================================================*/
  // Basic System Verilog TB Implementation to verify Main Memory Unit
  
  semaphore awaddr_sema = new(1);
  semaphore wdata_sema  = new(1);
  semaphore bresp_sema  = new(1);
  semaphore araddr_sema = new(1);
  semaphore rdata_sema  = new(1);

  task write_mem(bit[ADDR_WIDTH-1:0] addr, bit[DATA_WIDTH-1:0] data);
    addr[31:29] = 3'b100;      // Memory Unit only support BASE_ADDR of 100
    awaddr_q.push_back(addr);
    wdata_q.push_back(data);
    wait(rst_n == 1'b1);
    @(m_axi_intf.drive);
    
    fork
      begin
        awaddr_sema.get(1);
        m_axi_intf.drive.AWVALID  <= 1'b1;
        m_axi_intf.drive.AWADDR   <= awaddr_q.pop_front();
        @(m_axi_intf.drive);
        wait(m_axi_intf.drive.AWREADY == 1);
        m_axi_intf.drive.AWVALID  <= 1'b0;
        awaddr_sema.put(1);
      end
      begin
        wdata_sema.get(1);
        m_axi_intf.drive.WVALID   <= 1'b1;
        m_axi_intf.drive.WDATA    <= wdata_q.pop_front();
        m_axi_intf.drive.WSTRB    <= 4'b1111;
        @(m_axi_intf.drive);
        wait(m_axi_intf.drive.WREADY == 1);
        m_axi_intf.drive.WVALID   <= 1'b0;
        wdata_sema.put(1);
      end
      begin
        bresp_sema.get(1);
        m_axi_intf.drive.BREADY   <= 1'b1;
        @(m_axi_intf.drive);
        wait(m_axi_intf.drive.BVALID == 1);
        m_axi_intf.drive.BREADY   <= 1'b0;
        bresp_sema.put(1);
      end
    join_none
  endtask

  task read_mem(bit[ADDR_WIDTH-1:0] addr);
    bit[1:0] rresp;

    addr[31:29] = 3'b100;      // Memory Unit only support BASE_ADDR of 100
    araddr_q.push_back(addr);
    wait(rst_n == 1'b1);
    @(m_axi_intf.drive);
    fork
      begin
        araddr_sema.get(1);
        m_axi_intf.drive.ARVALID  <= 1'b1;
        m_axi_intf.drive.ARADDR   <= araddr_q.pop_front();
        @(m_axi_intf.drive);
        wait(m_axi_intf.drive.ARREADY == 1);
        m_axi_intf.drive.ARVALID  <= 1'b0;
        araddr_sema.put(1);
      end
      begin
        rdata_sema.get(1);
        m_axi_intf.drive.RREADY   <= 1'b1;
        @(m_axi_intf.drive);
        wait(m_axi_intf.drive.RVALID == 1);
        rdata_q.push_back(m_axi_intf.drive.RDATA);
        rresp                     =  m_axi_intf.drive.RRESP;
        m_axi_intf.drive.RREADY   <= 1'b0;
        rdata_sema.put(1);
        if(rresp != 2'b00)
          $display("ERROR OCUURED IN READ TRANSFER RRESP = %b",rresp);
      end
    join_none
  endtask
  
  task reset();
    $display("\n--------- Reset Activated ---------\n");
    rst_n = 1'b0;
      @(m_axi_intf.drive);
    rst_n = 1'b1;
    $display("\n--------- Reset de-Activated ---------\n");
  endtask

  task stop();
    $display("\n--------- $finish is Called ---------\n");
    #10 $finish;
  endtask
  
  task run_test(int transfers);
    int addr[],wdata[],rdata[];
    addr  = new[transfers];
    wdata = new[transfers];
    rdata = new[transfers];

    foreach(addr[i]) begin
      addr[i]   = $urandom;
      wdata[i]  = $urandom;
      $display("AWADDR:%h -------- WDATA:%h",addr[i],wdata[i]);
    end
    foreach(addr[i]) begin
      write_mem(addr[i],wdata[i]);
    end
    repeat(transfers)
      @(m_axi_intf.drive);

    foreach(addr[i]) begin
      read_mem(addr[i]);
    end
    forever begin
      if($size(rdata_q) != transfers)
        @(m_axi_intf.drive);
      else
        break;
    end

    //--------------------- COMPARE ---------------------//
    foreach(addr[i]) begin
      if(wdata[i] == rdata_q[i])
        $display("--------- Compare Succesfull --------- ");
      else
        $display("--------- Compare Un-Succesfull ---------\n ADDR:%h WDATA:%h RDATA:%h",addr[i],wdata[i],rdata[i]);
    end
  endtask

  initial begin
    reset();
    run_test(10);
    stop();
  end

endmodule
