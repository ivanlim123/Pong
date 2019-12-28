// state
`define START 2'b00
`define SERVE 2'b01
`define PLAY 2'b10
`define DONE 2'b11

module Ball(clk, rst, state, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ResetCollision, ballX, ballY);

input clk, rst;
input [1:0] state;
input CollisionX1, CollisionX2, CollisionY1, CollisionY2;
input ResetCollision;
output reg [9:0] ballX;
output reg [8:0] ballY;

wire UpdateBallPosition = ResetCollision;  // update the ball position at the same time that we reset the collision detectors

reg ball_dirX, ball_dirY;

always @(posedge clk) begin
    if(rst==1'b1) begin
        ballX <= 10'd304;
        ballY <= 10'd224;
    end
    else begin
        ballX <= 10'd304;
        ballY <= 10'd224;
    end

    /*
    if(UpdateBallPosition)
    begin
        if(~(CollisionX1 & CollisionX2))        // if collision on both X-sides, don't move in the X direction
        begin
            ballX <= ballX + (ball_dirX ? -1 : 1);
            if(CollisionX2) ball_dirX <= 1; else if(CollisionX1) ball_dirX <= 0;
        end

        if(~(CollisionY1 & CollisionY2))        // if collision on both Y-sides, don't move in the Y direction
        begin
            ballY <= ballY + (ball_dirY ? -1 : 1);
            if(CollisionY2) ball_dirY <= 1; else if(CollisionY1) ball_dirY <= 0;
        end
    end 
    */
end

endmodule
