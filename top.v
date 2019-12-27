`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/27 22:08:54
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(clk,rst,PS2Data,PS2Clk,vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B);
input clk;
output vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B;
input rst;
inout PS2Data;
inout PS2Clk;

wire inDisplayArea;
wire [9:0] CounterX;
wire [8:0] CounterY;

hvsync_generator syncgen(.clk(clk), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), 
  .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
 reg ball_inX, ball_inY;
 wire [9:0]ballX;
 wire [9:0]ballY;
 wire [9:0]posX1;
 wire [9:0]posX2;
 wire [8:0]posY1;
 wire [8:0]posY2;
 
 KeyboardDecoder key_de (
	  .key_down(key_down),
	  .last_change(last_change),
	  .key_valid(key_valid),
	  .PS2_DATA(PS2Data),
	  .PS2_CLK(PS2Clk),
	  .rst(rst),
	  .clk(clk)
  );
  wire [511:0] key_down;
	wire [8:0] last_change;
	wire key_valid;
wire up = (key_down[9'b0_0111_0101] && key_valid);
wire down = (key_down[9'b0_0111_0010] && key_valid);
wire W = (key_down[9'b0_0001_1101] && key_valid);
wire S = (key_down[9'b0_0001_1011] && key_valid);
wire [1:0] keyboard1 = {up, down};
wire [1:0] keyboard2 = {W, S};

wire R = BouncingObject | ball | (CounterX[3] ^ CounterY[3]);
wire G = BouncingObject | ball;
wire B = BouncingObject | ball;

reg vga_R, vga_G, vga_B;
always @(posedge clk)
begin
	vga_R <= R & inDisplayArea;
	vga_G <= G & inDisplayArea;
	vga_B <= B & inDisplayArea;
end
hvsync_generator h1(clk, vga_h_sync, vga_v_sync, inDisplayArea, CounterX, CounterY);
Player player1(clk, rst, keyboard1, ballX, ballY, player, posX1, posY1);
Player player2(clk, rst, keyboard2, ballX, ballY, player, posX2, posY2);
 
wire border =  (CounterY[8:3]==0) || (CounterY[8:3]==59);
wire paddle1 = ((CounterX>=posX1+8) && (CounterX<=posX1+18) &&(CounterY>=posY1+8) && (CounterY<=posY1+48)) ;
wire paddle2 = ((CounterX>=posX2+8) && (CounterX<=posX2+18) &&(CounterY>=posY2+8) && (CounterY<=posY2+48)) ;
wire BouncingObject = border | paddle1 | paddle2; // active if the border or paddle is redrawing itself

reg ResetCollision;
always @(posedge clk) ResetCollision <= (CounterY==500) & (CounterX==0);  // active only once for every video frame

reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;
always @(posedge clk) if(ResetCollision) CollisionX1<=0; else if(BouncingObject & (CounterX==ballX   ) & (CounterY==ballY+ 8)) CollisionX1<=1;
always @(posedge clk) if(ResetCollision) CollisionX2<=0; else if(BouncingObject & (CounterX==ballX+16) & (CounterY==ballY+ 8)) CollisionX2<=1;
always @(posedge clk) if(ResetCollision) CollisionY1<=0; else if(BouncingObject & (CounterX==ballX+ 8) & (CounterY==ballY   )) CollisionY1<=1;
always @(posedge clk) if(ResetCollision) CollisionY2<=0; else if(BouncingObject & (CounterX==ballX+ 8) & (CounterY==ballY+16)) CollisionY2<=1;

Ball ball1(clk, rst, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ResetCollision, ballX, ballY);

always @(posedge clk)
if(ball_inX==0) ball_inX <= (CounterX==ballX) & ball_inY; else ball_inX <= !(CounterX==ballX+16);

always @(posedge clk)
if(ball_inY==0) ball_inY <= (CounterY==ballY); else ball_inY <= !(CounterY==ballY+16);

wire ball = ball_inX & ball_inY;
  
  
endmodule
