//
//
//
//

`define NM1 32'd466 //bB_freq
`define NM2 32'd523 //C_freq
`define NM3 32'd587 //D_freq
`define NM4 32'd622 //bE_freq
`define NM5 32'd698 //F_freq
`define NM6 32'd784 //G_freq
`define NM7 32'd880 //A_freq
`define ti 32'd987 //A_freq
`define e 32'd659
`define NM0 32'd20000 //slience (over freq.)

module Music (
	input [7:0] ibeatNum,	
	output reg [31:0] tone
);

always @(*) begin
	case (ibeatNum)		// 1/4 beat
	   // no sound
	   8'd0 : tone = `NM0;
	
	   //paddle
		8'd1 : tone = `NM1;
		8'd2 : tone = `NM1;
		8'd3 : tone = `NM3;
		8'd4 : tone = `NM3;
		8'd5 : tone = `NM3;
		

		//border
		8'd6 : tone = `ti;
		8'd7 : tone = `e;
		
		//win
		8'd8 : tone = `NM1;
		8'd9: tone = `NM2;
		8'd10 : tone = `NM3;
		8'd11 : tone = `NM1;
		8'd12 : tone = `NM3;
		8'd13 : tone = `NM4;
		
		default : tone = `NM0;
	endcase
end

endmodule