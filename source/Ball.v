// state
`define START 2'b00
`define SERVE 2'b01
`define PLAY 2'b10
`define DONE 2'b11

// ball start position
`define ORIGINX 10'd304
`define ORIGINY 10'd224

// ball status
`define PLAYING 2'b00
`define PLAYER1WIN 2'b01
`define PLAYER2WIN 2'b10

module Ball(clk, rst, state, serve, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ResetCollision, ballX, ballY, ballStatus);

input clk, rst;
input [1:0] state;
input serve;
input CollisionX1, CollisionX2, CollisionY1, CollisionY2;
input ResetCollision;
output reg [9:0] ballX;
output reg [9:0] ballY;
output reg [1:0] ballStatus;

reg [9:0] nextBallX;
reg [9:0] nextBallY;
reg ball_dirX, ball_dirY;
reg nextBall_dirX, nextBall_dirY;
reg [1:0] nextBallStatus;

reg [18:0] counter, next_counter;

wire UpdateBallPosition = ResetCollision;  // update the ball position at the same time that we reset the collision detectors

always @(posedge clk) begin
    if(rst==1'b1) begin
        ballX <= `ORIGINX;
        ballY <= `ORIGINY;
        ball_dirX <= 1'b0;
        ball_dirY <= 1'b0;
        ballStatus <= `PLAYING;
        counter <= 19'd0;
    end
    else begin
        ballX <= nextBallX;
        ballY <= nextBallY;
        ball_dirX <= nextBall_dirX;
        ball_dirY <= nextBall_dirY;
        ballStatus <= nextBallStatus;
        counter <= next_counter;
    end
end

always @(*) begin
    case(state) 
        `START: begin
            nextBallX = `ORIGINX;
            nextBallY = `ORIGINY;
            nextBall_dirX = 1'b0;
            nextBall_dirY = 1'b0;
            nextBallStatus = `PLAYING;
            next_counter = 19'd0;
        end
        `SERVE: begin
            nextBallX = `ORIGINX;
            nextBallY = `ORIGINY;
            nextBallStatus = `PLAYING;
            next_counter = 19'd0;
            if(serve==1'b0) begin
                nextBall_dirX = 1'b0;
                nextBall_dirY = (ball_dirY == 1'b1) ? 1'b0 : 1'b1;
            end
            else begin
                nextBall_dirX = 1'b1;
                nextBall_dirY = (ball_dirY == 1'b1) ? 1'b0 : 1'b1;
            end
        end
        `PLAY: begin
            nextBallX = ballX;
            nextBallY = ballY;
            nextBall_dirX = ball_dirX;
            nextBall_dirY = ball_dirY;
            nextBallStatus = ballStatus;
            next_counter = counter + 1'b1;

            if(counter==19'b111_1111_1111_1111_1111) begin
                if(UpdateBallPosition) begin
                    if(CollisionX2==1'b1) begin
                        nextBall_dirX = 1'b1;
                    end
                    else begin
                        nextBall_dirX = 1'b0;
                    end

                    if(CollisionY2==1'b1) begin
                        nextBall_dirY = 1'b1;
                    end
                    else begin
                        nextBall_dirY = 1'b0;
                    end
                
                    if(~(CollisionX1 & CollisionX2)) begin      // if collision on both X-sides, don't move in the X direction
                        if(nextBall_dirX==1'b0) begin
                            nextBallX = ballX + 1'b1;
                        end
                        else begin
                            nextBallX = ballX - 1'b1;
                        end
                    end
                    else begin
                        nextBallX = ballX;
                    end

                    if(~(CollisionY1 & CollisionY2)) begin       // if collision on both Y-sides, don't move in the Y direction
                        if(nextBall_dirY==1'b0) begin
                            nextBallY = ballY + 1'b1;
                        end
                        else begin
                            nextBallY = ballY - 1'b1;
                        end
                    end
                    else begin
                        nextBallY = ballY;
                    end
                end
                else begin
                    nextBallX = ballX;
                    nextBallY = ballY;
                    nextBall_dirX = ball_dirX;
                    nextBall_dirY = ball_dirY;
                end

                if(ballX==10'd0) begin
                    nextBallStatus = `PLAYER2WIN;
                end
                else if(ballX==10'd640) begin
                    nextBallStatus = `PLAYER1WIN;
                end
                else begin
                    nextBallStatus = `PLAYING;
                end
            end
            else begin
                nextBallX = ballX;
                nextBallY = ballY;
                nextBallX = ballX;
                nextBallY = ballY;
                nextBall_dirX = ball_dirX;
                nextBall_dirY = ball_dirY;
                nextBallStatus = ballStatus;
            end
        end
        `DONE: begin
            nextBallX = `ORIGINX;
            nextBallY = `ORIGINY;
            nextBall_dirX = 1'b0;
            nextBall_dirY = 1'b0;
            nextBallStatus = `PLAYING;
            next_counter = 19'd0;
        end
    endcase
end

endmodule
