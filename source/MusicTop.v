// *******************************
// lab_SPEAKER_TOP
//
// ********************************

module music_top (
	input clk,
	input reset,
	input enable,
	input direction,
	output pmod_1,
	output pmod_2,
	output pmod_4
);
parameter BEAT_FREQ = 32'd8;	//one beat=0.125sec
parameter DUTY_BEST = 10'd512;	//duty cycle=50%

wire [31:0] freq;
wire [31:0] freq1;
wire [31:0] freq2;
wire [7:0] ibeatNum1;
wire [7:0] ibeatNum2;
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
PlayerCtrl1 playerCtrl_00 ( .clk(beatFreq),
                            .en(enable),
						   .reset(reset),
						   .ibeat(ibeatNum1)
);	
PlayerCtrl2 playerCtrl_01 ( .clk(beatFreq),
                            .en(enable),
						   .reset(reset),
						   .ibeat(ibeatNum2)
);
	
//Generate variant freq. of tones
Music music00 ( .ibeatNum(ibeatNum1),
				.tone(freq1)
);

Music2 music01 ( .ibeatNum(ibeatNum2),
				.tone(freq2)
);
assign freq = (enable) ? (direction == 1'b0) ? freq1 : freq2 : 32'd20000;

// Generate particular freq. signal
PWM_gen toneGen ( .clk(clk), 
				  .reset(reset), 
				  .freq(freq),
				  .duty(DUTY_BEST), 
				  .PWM(pmod_1)
);
endmodule
