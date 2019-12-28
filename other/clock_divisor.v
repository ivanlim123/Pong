module clock_divisor(clk1, clk,clk13);
input clk;
output clk1;
output clk13;

reg [12:0] num;
wire [12:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[1];
assign clk13 = num[12];
endmodule
