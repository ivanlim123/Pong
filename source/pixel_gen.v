module pixel_gen(
   input [9:0] h_cnt,
   input clk,
   input valid,
   input [9:0]v_cnt,
   input [9:0]ballX,
   input [9:0]ballY,
   input [9:0]posX1,
   input [9:0]posX2,
   input [8:0]posY1,
   input [8:0]posY2,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue,
   output BouncingObject
   );
reg ball_inX;
reg ball_inY;
wire border =  (v_cnt[8:3]==0) || (v_cnt[8:3]==59);
wire paddle1 = ((h_cnt>=posX1+8) && (h_cnt<=posX1+18) &&(v_cnt>=posY1+8)&& (v_cnt<=posY1+48));
wire paddle2 = ((h_cnt>=posX2+8) && (h_cnt<=posX2+18) &&(v_cnt>=posY2+8) && (v_cnt<=posY2+48)) ;
assign  BouncingObject = border | paddle1 | paddle2 ; // active if the border or paddle is redrawing itself
always @(posedge clk)
if(ball_inX==0) ball_inX <= (h_cnt==ballX) & ball_inY; else ball_inX <= !(h_cnt==ballX+16);

always @(posedge clk)
if(ball_inY==0) ball_inY <= (v_cnt==ballY); else ball_inY <= !(v_cnt==ballY+16);

wire ball = ball_inX & ball_inY;

       always @(*) begin
        if(valid && BouncingObject)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(valid && ball)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else 
            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
   end
endmodule
