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


module top(clk,rst,PS2Data,PS2Clk,hsync, vsync, vgaRed, vgaGreen, vgaBlue,  pmod_1,  pmod_2,  pmod_4);

// declare input output
input clk;
output hsync, vsync;
output  [3:0] vgaRed;
output  [3:0] vgaGreen;
output  [3:0] vgaBlue;
output pmod_1, pmod_2, pmod_4;
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
wire [1:0] mode;

wire BouncingObject;
 
wire [1:0]score1;
wire [1:0]score2;
wire [1:0]state;

wire clk13;

wire up = (key_down[9'b0_0111_0101]  );
wire down = (key_down[9'b0_0111_0010] );
wire W = (key_down[9'b0_0001_1101] );
wire S = (key_down[9'b0_0001_1011] );
wire enter = (key_down[9'b0_0101_1010] );
wire [1:0] keyboard1 = {up, down};
wire [1:0] keyboard2 = {W, S};

wire one = key_down[9'b0_0001_0110];
wire two = key_down[9'b0_0001_1110];
wire three = key_down[9'b0_0010_0110];
wire four = key_down[9'b0_0010_0101];

wire de_one, de_two, de_three, de_four;
wire one_one, one_two, one_three, one_four;

wire de_enter;
wire [1:0] de_keyboard1;
wire [1:0] de_keyboard2;

wire one_enter;
wire serve;
wire [1:0]ballStatus;

wire [3:0] change = {one_one, one_two, one_three, one_four};

reg CollisionX1, CollisionX2, CollisionY1, CollisionY2;
 
 KeyboardDecoder key_de (
	  .key_down(key_down),
	  .last_change(last_change),
	  .key_valid(key_valid),
	  .PS2_DATA(PS2Data),
	  .PS2_CLK(PS2Clk),
	  .rst(rst),
	  .clk(clk)
  );


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
   vgaRed,
   vgaGreen,
   vgaBlue,
   BouncingObject
   );

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

debounce d0(clk, keyboard1[1], de_keyboard1[1]);
debounce d1(clk,keyboard1[0], de_keyboard1[0]);
debounce d2(clk, keyboard2[1], de_keyboard2[1]);
debounce d3(clk,keyboard2[0], de_keyboard2[0]);
debounce d4(clk, enter, de_enter);
onepulse o4(clk, de_enter, one_enter);

debounce d11(clk, one, de_one);
debounce d12(clk, two, de_two);
debounce d13(clk, three, de_three);
debounce d14(clk, four, de_four);

onepulse o11(clk, de_one, one_one);
onepulse o12(clk, de_two, one_two);
onepulse o13(clk, de_three, one_three);
onepulse o14(clk, de_four, one_four);


Player player1(clk, rst, state, mode, de_keyboard2, ballY, 1'b0, posX1, posY1);
Player player2(clk, rst, state, mode, de_keyboard1, ballY, 1'b1, posX2, posY2);

//always @(*)if(BouncingObject & (h_cnt==ballX   ) & (v_cnt==ballY+ 4)) CollisionX1=1'b1;else CollisionX1=1'b0;
//always @(*)if(BouncingObject & (h_cnt==ballX+8) & (v_cnt==ballY+ 4)) CollisionX2=1'b1;else CollisionX2=1'b0;
//always @(*)if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY   )) CollisionY1=1'b1;else CollisionY1=1'b0;
//always @(*)if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY+8)) CollisionY2=1'b1;else CollisionY2=1'b0;

reg enable1, enable2, enable3, enable4;
reg next_enable1, next_enable2, next_enable3, next_enable4;

reg enable5, enable6;
reg next_enable5, next_enable6;

wire direction = (enable5 | enable6) ? 1'b1 : 1'b0;
wire enable = enable1 | enable2 | enable3 | enable4 | enable5 | enable6;

reg [24:0] counter;
wire [24:0] next_counter;

always @(posedge clk) begin
    if(rst==1'b1) begin
        enable1 <= 1'b0;
        enable2 <= 1'b0;
        enable3 <= 1'b0;
        enable4 <= 1'b0;
        enable5 <= 1'b0;
        enable6 <= 1'b0;
    end
    else begin
        if(counter==25'b1111_1111_1111_1111_1111_1111_1) begin
            enable1 <= 1'b0;
            enable2 <= 1'b0;
            enable3 <= 1'b0;
            enable4 <= 1'b0;
            enable5 <= 1'b0;
            enable6 <= 1'b0;
        end
        else begin
            enable1 <= next_enable1;
            enable2 <= next_enable2;
            enable3 <= next_enable3;
            enable4 <= next_enable4;
            enable5 <= next_enable5;
            enable6 <= next_enable6;
        end
    end
end

always @(posedge clk) begin
    if(rst==1'b1) begin
        counter <= 25'd0;
    end
    else begin
        counter <= next_counter;
    end
end

assign next_counter = (enable==1'b1) ? (counter + 1'b1) : 25'd0;

always @(*) begin
    if(BouncingObject & (h_cnt==ballX   ) & (v_cnt==ballY+ 4)) begin
        CollisionX1=1'b1;
        next_enable1 = 1'b1;
    end
    else begin
        CollisionX1=1'b0;
        next_enable1 = enable1;
    end
end

always @(*) begin
    if(BouncingObject & (h_cnt==ballX+8) & (v_cnt==ballY+ 4)) begin
        CollisionX2=1'b1;
        next_enable2 = 1'b1;
    end
    else begin
        CollisionX2=1'b0;
        next_enable2 = enable2; 
    end
end

always @(*) begin
    if(BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY   )) begin
        CollisionY1=1'b1;
        next_enable3 = 1'b1;
    end
    else begin
        CollisionY1=1'b0;
        next_enable3 = enable3;
    end
end

always @(*) begin
    if((BouncingObject & (h_cnt==ballX+ 4) & (v_cnt==ballY+8))) begin
        CollisionY2=1'b1;
        next_enable4 = 1'b1;
    end
    else begin
        CollisionY2=1'b0;
        next_enable4 = enable4;
    end
end

always @(*) begin
    if(ballStatus==2'b01) begin
        next_enable5 = 1'b1;
    end
    else begin
        next_enable5 = enable5;
    end
end

always @(*) begin
    if(ballStatus==2'b10) begin
        next_enable6 = 1'b1;
    end
    else begin
        next_enable6 = enable6;
    end
end

Ball ball(clk, rst, state, serve, CollisionX1, CollisionX2, CollisionY1, CollisionY2, ballX, ballY, ballStatus);
Game game(clk, rst, ballStatus, change, one_enter, state, score1, score2,serve, mode);

music_top mt (
	clk,
	rst,
	enable,
	direction,
	pmod_1,
	pmod_2,
	pmod_4
);

endmodule
