`timescale 1ns/1ps

module adder_tb;

  logic [3:0] a;
  logic [3:0] b;
  logic [4:0] sum;

  // DUT
  adder dut (
    .a   (a),
    .b   (b),
    .sum (sum)
  );

  initial begin
    $display(" time   a    b   | sum");
    $display("----------------------");

    a = 0; b = 0;
    #5 $display("%4t  %2d   %2d  | %2d", $time, a, b, sum);

    a = 3; b = 4;
    #5 $display("%4t  %2d   %2d  | %2d", $time, a, b, sum);

    a = 7; b = 8;
    #5 $display("%4t  %2d   %2d  | %2d", $time, a, b, sum);

    a = 15; b = 15;
    #5 $display("%4t  %2d  %2d  | %2d", $time, a, b, sum);

    #5;
    $display("Done.");
    $finish;
  end

endmodule
