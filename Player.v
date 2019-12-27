`define UP 1'b0
`define DOWN 1'b1

module Player(clk, rst, keyboard, ballX, ballY, player, posX, posY);

// declare input output
input clk, rst, player;
input keyboard;
input [9:0] ballX;
input [8:0] ballY;
output wire [9:0] posX;
output reg [8:0] posY;

reg [8:0] nextPosY;

assign posX = (player == 1'b1) ? 10'd622: 9'd0;

always @(posedge clk) begin
    if(rst==1'b1) begin
        posY <= 9'd0;
    end
    else begin
        posY <= nextPosY;
    end
end

// player movement
always @(*) begin
    if(keyboard==`UP) begin
        if(|posY) begin
            nextPosY = posY - 1'b1;
        end
        else begin
            nextPosY = posY;
        end
    end
    else if(keyboard==`DOWN) begin
        if(posY < 9'd424) begin
            nextPosY = posY + 1'b1;
        end
        else begin
            nextPosY = posY;
        end
    end
    else begin
        nextPosY = posY;
    end
end


endmodule