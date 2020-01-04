// *******************************
// lab_SPEAKER_TOP
//
// ********************************

module MusicTop (
	input clk,
	input reset,
	input [1:0] ballStatus,
	input CollisionX1, 
	input CollisionX2, 
	input CollisionY1, 
	input CollisionY2,
	output pmod_1,
	output pmod_2,
	output pmod_4
);
parameter BEAT_FREQ = 32'd8;	//one beat=0.125sec
parameter DUTY_BEST = 10'd512;	//duty cycle=50%

wire [31:0] freq;
wire [7:0] ibeatNum;
wire beatFreq;

assign pmod_2 = 1'd1;	//no gain(6dB)
assign pmod_4 = 1'd1;	//turn-on

//Generate beat speed
PWM_gen btSpeedGen ( .clk(clk), 
					 .reset(reset),
					 .freq(BEAT_FREQ),
					 .duty(DUTY_BEST), 
					 .PWM(beatFreq)
);
	
//manipulate beat
PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
						   .reset(reset),
						   .ballStatus(ballStatus),
						   .CollisionX1(CollisionX1), 
	                       .CollisionX2(CollisionX2), 
	                       .CollisionY1(CollisionY1), 
	                       .CollisionY2(CollisionY2),
						   .ibeat(ibeatNum)
);	
	
//Generate variant freq. of tones
Music music00 ( .ibeatNum(ibeatNum),
				.tone(freq)
);

// Generate particular freq. signal
PWM_gen toneGen ( .clk(clk), 
				  .reset(reset), 
				  .freq(freq),
				  .duty(DUTY_BEST), 
				  .PWM(pmod_1)
);
endmodule