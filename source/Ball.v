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

module Ball(clk, rst, state, serve, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ballX, ballY, ballStatus);

input clk, rst;
input [1:0] state;
input serve;
input CollisionX1, CollisionX2, CollisionY1, CollisionY2;
output reg [9:0] ballX;
output reg [9:0] ballY;
output reg [1:0] ballStatus;

reg [9:0] nextBallX;
reg [9:0] nextBallY;
reg ball_dirX, ball_dirY;
reg nextBall_dirX, nextBall_dirY;
reg [1:0] nextBallStatus;

reg [18:0] counter, next_counter;
reg [18:0] speed, next_speed;

always @(posedge clk) begin
    if(rst==1'b1) begin
        ballX <= `ORIGINX;
        ballY <= `ORIGINY;
        ball_dirX <= 1'b0;
        ball_dirY <= 1'b0;
        ballStatus <= `PLAYING;
        counter <= 19'd0;
        speed <= 19'b111_1111_1111_1111_1111;
    end
    else begin
        ballX <= nextBallX;
        ballY <= nextBallY;
        ball_dirX <= nextBall_dirX;
        ball_dirY <= nextBall_dirY;
        ballStatus <= nextBallStatus;
        counter <= next_counter;
        speed <= next_speed;
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
            next_speed = 19'b111_1111_1111_1111_1111;
        end
        `SERVE: begin
            nextBallX = `ORIGINX;
            nextBallY = `ORIGINY;
            nextBallStatus = `PLAYING;
            next_counter = 19'd0;
            next_speed = 19'b111_1111_1111_1111_1111;
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
            next_speed = speed;

            if(CollisionX1 & CollisionX2) begin
                nextBall_dirX = ~ball_dirX;
            end
            else if(CollisionX2==1'b1) begin
                nextBall_dirX = 1'b1;
                if(speed>19'b110_1111_1111_1111_1111) begin
                    next_speed = speed - 19'd12500;
                end
                else begin
                    next_speed = speed;
                end
                
            end
            else if(CollisionX1==1'b1) begin
                nextBall_dirX = 1'b0;
                if(speed>19'b110_1111_1111_1111_1111) begin
                    next_speed = speed - 19'd12500;
                end
                else begin
                    next_speed = speed;
                end
            end
            else begin
                nextBall_dirX = ball_dirX;
            end

            if(CollisionY1 & CollisionY2) begin
                nextBall_dirY = ~ball_dirY;
            end
            else if(CollisionY2==1'b1) begin
                nextBall_dirY = 1'b1;
            end
            else if(CollisionY1==1'b1) begin
                nextBall_dirY = 1'b0;
            end
            else begin
                nextBall_dirY = ball_dirY;
            end

            if(counter==speed) begin
                next_counter = 19'd0;
                if(ball_dirX==1'b0) begin
                    nextBallX = ballX + 1'b1;
                end
                else begin
                    nextBallX = ballX - 1'b1;
                end

                if(ball_dirY==1'b0) begin
                    nextBallY = ballY + 1'b1;
                end
                else begin
                    nextBallY = ballY - 1'b1;
                end

                if(ballX==10'd0) begin
                    nextBallStatus = `PLAYER2WIN;
                end
                else if(ballX==10'd631) begin
                    nextBallStatus = `PLAYER1WIN;
                end
                else begin
                    nextBallStatus = `PLAYING;
                end
            end
            else begin
                nextBallX = ballX;
                nextBallY = ballY;
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
            next_speed = speed;
        end
    endcase
end

endmodule
