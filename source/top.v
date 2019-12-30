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


module top(clk,rst,PS2Data,PS2Clk,hsync, vsync, vgaRed, vgaGreen, vgaBlue);


input clk;
output hsync, vsync;
output  [3:0] vgaRed;
output  [3:0] vgaGreen;
output  [3:0] vgaBlue;
input rst;
inout PS2Data;
inout PS2Clk;
 reg ball_inX, ball_inY;
 wire clk1;
 wire [9:0]ballX;
 wire [9:0]ballY;
 wire [9:0]posX1;
 wire [9:0]posX2;
 wire [8:0]posY1;
 wire [8:0]posY2;
 wire valid;
 wire [9:0]h_cnt;
 wire [9:0]v_cnt;
 wire [511:0] key_down;
wire [8:0] last_change;
wire key_valid;

 wire BouncingObject;
 KeyboardDecoder key_de (
	  .key_down(key_down),
	  .last_change(last_change),
	  .key_valid(key_valid),
	  .PS2_DATA(PS2Data),
	  .PS2_CLK(PS2Clk),
	  .rst(rst),
	  .clk(clk)
  );
wire [1:0]score1;
wire [1:0]score2;
wire [1:0]state;

pixel_gen pix1(
   h_cnt,
   clk1,
   valid,
   v_cnt,
   ballX,
   ballY,
   posX1,
   posX2,
   posY1,
   posY2,
   score1,
   score2,
   state,
   vgaRed,
   vgaGreen,
   vgaBlue,
   BouncingObject
   );
wire clk13;
clock_divisor clock_divisor1(clk1, clk,clk13);
vga_controller vga1
(
   clk1,
   rst,
   hsync,
   vsync,
   valid,
   h_cnt,
   v_cnt
  );

wire up = (key_down[9'b0_0111_0101]  );
wire down = (key_down[9'b0_0111_0010] );
wire W = (key_down[9'b0_0001_1101] );
wire S = (key_down[9'b0_0001_1011] );
wire enter = (key_down[9'b0_0101_1010] );
wire [1:0] keyboard1 = {up, down};
wire [1:0] keyboard2 = {W, S};

wire de_enter;
wire [1:0] de_keyboard1;
wire [1:0] de_keyboard2;

wire one_enter;
wire serve;
wire [1:0]ballStatus;
Game game(clk, rst, ballStatus, one_enter, state, score1, score2,serve);
debounce d0(clk, keyboard1[1], de_keyboard1[1]);
debounce d1(clk,keyboard1[0], de_keyboard1[0]);
debounce d2(clk, keyboard2[1], de_keyboard2[1]);
debounce d3(clk,keyboard2[0], de_keyboard2[0]);
debounce d4(clk, enter, de_enter);
onepulse o4(clk, de_enter, one_enter);


/*wire R = BouncingObject | ball | (CounterX[3] ^ CounterY[3]);
wire G = BouncingObject | ball;
wire B = BouncingObject | ball;
reg vga_R, vga_G, vga_B;
always @(posedge clk)
begin
	vga_R <= R & inDisplayArea;
	vga_G <= G & inDisplayArea;
	vga_B <= B & inDisplayArea;
end*/

Player player1(clk, rst,state, de_keyboard2, ballX, ballY, 1'b0, posX1, posY1);
Player player2(clk, rst,state, de_keyboard1, ballX, ballY, 1'b1, posX2, posY2);
 
/*wire border =  (h_cnt[8:3]==0) || (h_cnt[8:3]==59);
wire paddle1 = ((CounterX>=posX1+8) && (CounterX<=posX1+18) &&(h_cnt>=posY1+8) && (CounterY<=posY1+48)) ;
wire paddle2 = ((CounterX>=posX2+8) && (CounterX<=posX2+18) &&(CounterY>=posY2+8) && (CounterY<=posY2+48)) ;
wire BouncingObject = border | paddle1 | paddle2; // active if the border or paddle is redrawing itself
*/

//reg ResetCollision;
//always @(posedge clk) ResetCollision <= (v_cnt==480) & (h_cnt==0);  // active only once for every video frame

reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;
/*always @(posedge clk) if(ResetCollision) CollisionX1<=0; else if(BouncingObject & (h_cnt==ballX   ) & (v_cnt==ballY+ 4)) CollisionX1<=1;
always @(posedge clk) if(ResetCollision) CollisionX2<=0; else if(BouncingObject & (h_cnt==ballX+8) & (v_cnt==ballY+ 4)) CollisionX2<=1;
always @(posedge clk) if(ResetCollision) CollisionY1<=0; else if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY   )) CollisionY1<=1;
always @(posedge clk) if(ResetCollision) CollisionY2<=0; else if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY+8)) CollisionY2<=1;*/

always @(*)if(BouncingObject & (h_cnt==ballX   ) & (v_cnt==ballY+ 4)) CollisionX1=1;else CollisionX1=0;
always @(*)if(BouncingObject & (h_cnt==ballX+8) & (v_cnt==ballY+ 4)) CollisionX2=1;else CollisionX2=0;
always @(*)if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY   )) CollisionY1=1;else CollisionY1=0;
always @(*)if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY+8)) CollisionY2=1;else CollisionY2=0;

Ball ball(clk, rst, state, serve, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ballX, ballY, ballStatus);


/*always @(posedge clk)
if(ball_inX==0) ball_inX <= (h_cnt==ballX) & ball_inY; else ball_inX <= !(h_cnt==ballX+16);
always @(posedge clk)
if(ball_inY==0) ball_inY <= (v_cnt==ballY); else ball_inY <= !(v_cnt==ballY+16);
wire ball = ball_inX & ball_inY;
  
  */
endmodule
