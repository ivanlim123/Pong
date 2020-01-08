module PlayerCtrl1 (
	input clk,
	input reset,
	input en,
	output reg [7:0] ibeat
);
parameter BEATLEAGTH = 6;

always @(posedge clk, posedge reset) begin
	if (reset) begin
		ibeat <= 0;
    end
	else if ((ibeat < BEATLEAGTH) && en) begin 
		ibeat <= ibeat + 1;
	end
	else begin 
		ibeat <= 0;
	end
end

endmodule

module PlayerCtrl2 (
	input clk,
	input reset,
	input [2:0] en,
	output reg [7:0] ibeat
);
parameter BEATLEAGTH = 7;

always @(posedge clk, posedge reset) begin
	if (reset) begin
		ibeat <= 0;
    end
	else if ((ibeat < BEATLEAGTH) && en) begin 
		ibeat <= ibeat + 1;
	end
	else begin 
		ibeat <= 0;
	end
end

endmodule
