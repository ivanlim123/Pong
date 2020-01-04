`define STOP 2'b00
`define WIN 2'b01
`define COLLIDE 2'b10

`define PLAYING 2'b00
`define PLAYER1WIN 2'b01
`define PLAYER2WIN 2'b10


module PlayerCtrl (
	input clk,
	input reset,
	input [1:0] ballStatus,
	input CollisionX1, 
	input CollisionX2, 
	input CollisionY1, 
	input CollisionY2,
	output reg [7:0] ibeat
);

reg [1:0] state, next_state;
reg [7:0] next_ibeat;

always @(posedge clk, posedge reset) begin
	if (reset) begin
		state <= `STOP;
		ibeat <= 8'd0;
	end
	else begin
		state <= next_state;
		ibeat <= next_ibeat;
	end
end

always @(*) begin
    if((ballStatus == `PLAYER1WIN || ballStatus == `PLAYER2WIN) && ibeat == 8'd0) begin
        next_state = `WIN;
        next_ibeat = 8'd8;
    end
    else begin
        if((CollisionX1 == 1'b1 || CollisionX2 == 1'b1 || CollisionY1 == 1'b1 || CollisionY2 == 1'b1) && ibeat == 8'd0) begin
            next_state = `COLLIDE;
            next_ibeat = 8'd6;
        end
        else begin
            if(state == `WIN) begin
                if(ibeat == 8'd13) begin
                    next_state = `STOP;
                    next_ibeat = 8'd0;
                end
                else begin
                    next_state = `WIN;
                    next_ibeat = ibeat + 1'b1;
                end
            end
            else if(state == `COLLIDE) begin
                if(ibeat == 8'd7) begin
                    next_state = `STOP;
                    next_ibeat = 8'd0;
                end
                else begin
                    next_state = `COLLIDE;
                    next_ibeat = ibeat + 1'b1;
                end
            end
            else begin
                next_state = `STOP;
                next_ibeat = 8'd0;
            end
        end
    end
end

endmodule