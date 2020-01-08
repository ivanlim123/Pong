//////////////////////////////////////////////////////////////////////////////////
// Module Name: PWM_gen
// Description: This IP expects 100 MHz input clock and generates the desired output
// 				at PWM output with the configurable frequency (in Hz) and duty cycle.
// 				
//				The configurable frequency should be less or equal to 100 MHz and 
//				the duty cycle can vary in step of 1/1024, i.e. 0.0009765625 or 
//				approximately 0.1% 
//////////////////////////////////////////////////////////////////////////////////
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

wire [31:0] count_max = 100_000_000 / freq;
wire [31:0] count_duty = count_max * duty / 1024;
reg [31:0] count;
    
always @(posedge clk, posedge reset) begin
    if (reset) begin
        count <= 0;
        PWM <= 0;
    end else if (count < count_max) begin
        count <= count + 1;
		if(count < count_duty)
            PWM <= 1;
        else
            PWM <= 0;
    end else begin
        count <= 0;
        PWM <= 0;
    end
end

endmodule
