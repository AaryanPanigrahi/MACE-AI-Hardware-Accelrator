`timescale 1ns/1ps

// Import VIP packages
import axi_vip_0_pkg::*;
import axi_vip_0_slv_pkg::*;

// Testbench
module my_design_tb;

  logic ACLK;
  logic ARESETn;

  initial ACLK = 0;
  always #5 ACLK = ~ACLK;   // 100 MHz

  initial begin
    ARESETn = 0;
    #100;
    ARESETn = 1;
  end

  // AXI signals (master → slave)
  logic [31:0] awaddr;
  logic        awvalid;
  logic        awready;

  logic [31:0] wdata;
  logic        wvalid;
  logic        wready;

  logic        bvalid;
  logic        bready;

  logic [31:0] araddr;
  logic        arvalid;
  logic        arready;

  logic [31:0] rdata;
  logic        rvalid;
  logic        rready;


  // DUT (AXI master)
  my_design dut (
    .ACLK     (ACLK),
    .ARESETn  (ARESETn),

    .M_AXI_AWADDR  (awaddr),
    .M_AXI_AWVALID (awvalid),
    .M_AXI_AWREADY (awready),

    .M_AXI_WDATA   (wdata),
    .M_AXI_WVALID  (wvalid),
    .M_AXI_WREADY  (wready),

    .M_AXI_BVALID  (bvalid),
    .M_AXI_BREADY  (bready),

    .M_AXI_ARADDR  (araddr),
    .M_AXI_ARVALID (arvalid),
    .M_AXI_ARREADY (arready),

    .M_AXI_RDATA   (rdata),
    .M_AXI_RVALID  (rvalid),
    .M_AXI_RREADY  (rready)
  );

  // AXI VIP instance
  axi_vip_0 vip_i (
    .aclk    (ACLK),
    .aresetn (ARESETn),

    .s_axi_awaddr  (awaddr),
    .s_axi_awvalid (awvalid),
    .s_axi_awready (awready),

    .s_axi_wdata   (wdata),
    .s_axi_wvalid  (wvalid),
    .s_axi_wready  (wready),

    .s_axi_bvalid  (bvalid),
    .s_axi_bready  (bready),

    .s_axi_araddr  (araddr),
    .s_axi_arvalid (arvalid),
    .s_axi_arready (arready),

    .s_axi_rdata   (rdata),
    .s_axi_rvalid  (rvalid),
    .s_axi_rready  (rready)
  );

  // Slave agent (memory model)
  axi_vip_0_slv_mem_t slv_agent;

  // Bring-up sequence
  initial begin

    // Create agent
    slv_agent = new("SLAVE VIP", vip_i.inst.IF);

    // Start slave
    slv_agent.start_slave();

    // Verbose logging
    slv_agent.set_verbosity(400);

    // Preload memory
    slv_agent.mem_model.backdoor_memory_write(
      32'h0000_1000,
      32'hDEADBEEF
    );

    $display("VIP Slave started.");

  end

  initial begin
    #10_000;
    $finish;
  end

endmodule
