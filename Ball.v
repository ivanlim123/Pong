module Ball(clk, rst, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ResetCollision, ballX, ballY);

input clk, rst;
input CollisionX1, CollisionX2, CollisionY1, CollisionY2;
input ResetCollision;
output reg [9:0] ballX;
output reg [8:0] ballY;

wire UpdateBallPosition = ResetCollision;  // update the ball position at the same time that we reset the collision detectors

reg ball_dirX, ball_dirY;

always @(posedge clk) begin
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
end

endmodule














endmodule