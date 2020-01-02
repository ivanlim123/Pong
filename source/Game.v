`define START 2'b00
`define SERVE 2'b01
`define PLAY 2'b10
`define DONE 2'b11

`define PLAYING 2'b00
`define PLAYER1WIN 2'b01
`define PLAYER2WIN 2'b10

`define PP 2'b00
`define PA 2'b01
`define AP 2'b10
`define AA 2'b11

module Game(clk, rst, ballStatus, change, enter, state, score1, score2, serve, mode);

input clk, rst;
input [1:0] ballStatus;
input [3:0] change;
input enter;
output reg [1:0] state;
output reg [1:0] score1, score2;
output reg serve;
output reg [1:0] mode;

// score: 0-3

// -- the state of our game; can be any of the following:
// -- 1. 'start' (the beginning of the game, before first serve)
// -- 2. 'serve' (waiting on a key press to serve the ball)
// -- 3. 'play' (the ball is in play, bouncing between paddles)
// -- 4. 'done' (the game is over, with a victor, ready for restart)


// state
// serve: Ball spawn in original point and cannot move
// play: Update score
// done: Print Score and Player move to original point

reg [1:0] nextState;
reg [1:0] nextScore1, nextScore2;
reg nextServe;

reg [1:0] next_mode;

// serve
// 0: player1 serve
// 1: player 2 serce

always @(posedge clk) begin
    if(rst==1'b1) begin
        state <= `START;
        score1 <= 2'd0;
        score2 <= 2'd0;
        serve <= 1'b0;
        mode <= `PP;
    end
    else begin
        state <= nextState;
        score1 <= nextScore1;
        score2 <= nextScore2;
        serve <= nextServe;
        mode <= next_mode;
    end
end

always @(*) begin
    case(state) 
        `START: begin
            nextState = `SERVE;
            nextScore1 = 2'd0;
            nextScore2 = 2'd0;
            nextServe = 1'b0;
            next_mode = mode;
        end
        `SERVE: begin
            nextScore1 = score1;
            nextScore2 = score2;
            nextServe = serve;
            if(change==4'b1000) begin
                next_mode = `PP;
            end
            else if(change==4'b0100) begin
                next_mode = `PA;
            end
            else if(change==4'b0010) begin
                next_mode = `AP;
            end
            else if(change==4'b0001) begin
                next_mode = `AA;
            end
            else begin
                next_mode = mode;
            end

            if(enter==1'b1) begin
                nextState = `PLAY;
            end
            else begin
                nextState = `SERVE;
            end
        end
        `PLAY: begin
            nextScore1 = score1;
            nextScore2 = score2;
            nextServe = serve;
            next_mode = mode;
            if(ballStatus==`PLAYING) begin
                nextState = `PLAY;
            end
            else if(ballStatus==`PLAYER1WIN) begin
                nextScore1 = score1 + 1'b1;
                nextServe = 1'b1;
                if(nextScore1<2'd3) begin
                    nextState = `SERVE;
                end
                else begin
                    nextState = `DONE;
                end
            end
            else begin
                nextScore2 = score2 + 1'b1;
                nextServe = 1'b0;
                if(nextScore2<2'd3) begin
                    nextState = `SERVE;
                end
                else begin
                    nextState = `DONE;
                end
            end
        end
        `DONE: begin
            nextScore1 = score1;
            nextScore2 = score2;
            nextServe = 1'b0;
            next_mode = mode;
            if(enter==1'b1) begin
                nextState = `START;
            end
            else begin
                nextState = `DONE;
            end
        end
    endcase
end


endmodule
