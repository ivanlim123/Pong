// state
`define START 2'b00
`define SERVE 2'b01
`define PLAY 2'b10
`define DONE 2'b11

`define PP 2'b00
`define PA 2'b01
`define AP 2'b10
`define AA 2'b11

module Player(clk, rst, state, mode, keyboard, ballY, player, posX, posY);

// declare input output
input clk, rst, player;
input [1:0] state;
input [1:0] mode;
input [1:0] keyboard;
//input [9:0] ballX;
input [9:0] ballY;
output wire [9:0] posX;
output reg [8:0] posY;

reg [18:0] counter, next_counter;
reg [8:0] nextPosY;

assign posX = (player == 1'b1) ? 10'd614: 9'd0;

always @(posedge clk) begin
    if(rst==1'b1) begin
        posY <= 9'd232;
        counter <= 19'd0;
    end
    else begin
        posY <= nextPosY;
        counter <= next_counter;
    end
end

// player movement
always @(*) begin
    case(state) 
        `START: begin
            nextPosY = 9'd232;
            next_counter =19'd0;
        end
        `DONE: begin
            nextPosY = 9'd232;
            next_counter = 19'd0;
        end
        default: begin
            next_counter = counter + 1'b1;

            if(mode==`PP) begin
                if(counter==19'b111_1111_1111_1111_1111) begin
                    if(keyboard==2'b01) begin
                        if(posY < 9'd424) begin
                            nextPosY = posY + 1'b1;
                        end
                        else begin
                            nextPosY = posY;
                        end
                    end
                    else if(keyboard==2'b10) begin
                        if(posY > 9'd0) begin
                            nextPosY = posY - 1'b1;
                        end
                        else begin
                            nextPosY = posY;
                        end
                    end
                    else begin
                        nextPosY = posY;
                    end
                end
                else begin
                    nextPosY = posY;
                end
            end
            else if(mode==`PA) begin
                if(player==1'b0) begin
                    if(counter==19'b111_1111_1111_1111_1111) begin
                        if(keyboard==2'b01) begin
                            if(posY < 9'd424) begin
                                nextPosY = posY + 1'b1;
                            end
                            else begin
                                nextPosY = posY;
                            end
                        end
                        else if(keyboard==2'b10) begin
                            if(posY > 9'd0) begin
                                nextPosY = posY - 1'b1;
                            end
                            else begin
                                nextPosY = posY;
                            end
                        end
                        else begin
                            nextPosY = posY;
                        end
                    end
                    else begin
                        nextPosY = posY;
                    end
                end
                else begin
                    if(ballY+4>posY+20 && posY < 9'd424) begin
                        nextPosY = posY + 1;
                    end
                    else if(ballY+4<posY+20 && posY > 9'd0) begin
                        nextPosY = posY - 1;
                    end
                    else begin
                        nextPosY = posY;
                    end
                end
            end
            else if(mode==`AP) begin
                if(player==1'b1) begin
                    if(counter==19'b111_1111_1111_1111_1111) begin
                        if(keyboard==2'b01) begin
                            if(posY < 9'd424) begin
                                nextPosY = posY + 1'b1;
                            end
                            else begin
                                nextPosY = posY;
                            end
                        end
                        else if(keyboard==2'b10) begin
                            if(posY > 9'd0) begin
                                nextPosY = posY - 1'b1;
                            end
                            else begin
                                nextPosY = posY;
                            end
                        end
                        else begin
                            nextPosY = posY;
                        end
                    end
                    else begin
                        nextPosY = posY;
                    end
                end
                else begin
                    if(ballY+4>posY+20 && posY < 9'd424) begin
                        nextPosY = posY + 1;
                    end
                    else if(ballY+4<posY+20 && posY > 9'd0) begin
                        nextPosY = posY - 1;
                    end
                    else begin
                        nextPosY = posY;
                    end
                end
            end
            else begin
                if(ballY+4>posY+20 && posY < 9'd424) begin
                    nextPosY = posY + 1;
                end
                else if(ballY+4<posY+20 && posY > 9'd0) begin
                    nextPosY = posY - 1;
                end
                else begin
                    nextPosY = posY;
                end
            end
        end
    endcase
end

endmodule
