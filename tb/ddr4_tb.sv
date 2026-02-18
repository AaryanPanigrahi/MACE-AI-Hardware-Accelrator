module ddr4_tb;

  logic sys_clk_p = 0;
  logic sys_clk_n = 1;
  logic sys_rst   = 1;

  // Clock generation
  always #5 begin
    sys_clk_p = ~sys_clk_p;
    sys_clk_n = ~sys_clk_n;
  end

  initial begin
    #100 sys_rst = 0;
  end

  // Calibration monitor
  wire init_calib_complete;

  // AXI wires (tie off for now)
  wire [255:0] s_axi_wdata = '0;
  wire s_axi_awvalid = 0;
  wire s_axi_wvalid  = 0;
  wire s_axi_arvalid = 0;

  // Instantiate DDR4 IP
  ddr4_0 u_ddr4 (
    .c0_sys_clk_p(sys_clk_p),
    .c0_sys_clk_n(sys_clk_n),
    .sys_rst(sys_rst),

    .c0_init_calib_complete(init_calib_complete)

    // AXI ports can remain unconnected for smoke test
  );

endmodule
