`define START 2'b00
`define SERVE 2'b01
`define PLAY 2'b10
`define DONE 2'b11

`define PLAYING 2'b00
`define PLAYER1WIN 2'b01
`define PLAYER2WIN 2'b10

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
   input [1:0]score1,
   input [1:0]score2,
   input [1:0]state,
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
/*wire zero = ((h_cnt<=250)&&(h_cnt>=236)&& (v_cnt==200)) || ((h_cnt<=250)&&(h_cnt>=236)&& (v_cnt==168));
wire zero2 = ((h_cnt<=358)&&(h_cnt>=344)&& (v_cnt==200)) || ((h_cnt<=358)&&(h_cnt>=344)&& (v_cnt==168));
wire one = ((v_cnt==168)&&(h_cnt<=250)&&(h_cnt>=242)) ||((v_cnt<=200)&&(v_cnt>=168)&&(h_cnt ==250));
wire one2 = ((v_cnt==168)&&(h_cnt<=358)&&(h_cnt>=350)) ||((v_cnt<=200)&&(v_cnt>=168)&&(h_cnt ==358));
wire two = ((h_cnt>=250)&&(h_cnt<=266)&&(v_cnt ==168)) ||((h_cnt == 274) && (v_cnt ==176)) || ((h_cnt<=266)&&(h_cnt>=258)&&(v_cnt==184)) ||((h_cnt == 250)&&(v_cnt == 192)) || ((h_cnt>=250)&&(h_cnt<=274)&&(v_cnt ==200));
wire two2 = ((h_cnt>=358)&&(h_cnt<=374)&&(v_cnt ==168)) ||((h_cnt == 382) && (v_cnt ==176)) || ((h_cnt<=374)&&(h_cnt>=366)&&(v_cnt==184)) ||((h_cnt == 358)&&(v_cnt == 192)) || ((h_cnt>=358)&&(h_cnt<=382)&&(v_cnt ==200));
wire three =((h_cnt>=250)&&(h_cnt<=266)&&(v_cnt==168)) || ((h_cnt == 274) && (v_cnt == 176)) || ((h_cnt<=266) && (h_cnt>=258) &&(v_cnt ==184)) || ((h_cnt ==274) && (v_cnt == 192))||((h_cnt<=274) && (h_cnt>=242) && (v_cnt == 200));
wire three2 =((h_cnt>=358)&&(h_cnt<=374)&&(v_cnt==168)) || ((h_cnt == 382) && (v_cnt == 176)) || ((h_cnt<=374) && (h_cnt>=366) &&(v_cnt ==184)) || ((h_cnt ==382) && (v_cnt == 192))||((h_cnt<=382) && (h_cnt>=350) && (v_cnt == 200));
*/
assign  BouncingObject = border | paddle1 | paddle2 ; // active if the border or paddle is redrawing itself
always @(posedge clk)
if(ball_inX==0) ball_inX <= (h_cnt==ballX) & ball_inY; else ball_inX <= !(h_cnt==ballX+8);

always @(posedge clk)
if(ball_inY==0) ball_inY <= (v_cnt==ballY); else ball_inY <= !(v_cnt==ballY+8);

wire ball = ball_inX & ball_inY;

always @(*) begin
if(valid && BouncingObject)
    {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
else if(valid && ball)
    {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
else 
    {vgaRed, vgaGreen, vgaBlue} = 12'h0;
end
/*250  304 358
 200 224
always @(*) begin
    case(state)
    `START: begin
            nextScore1 = 2'd0;
            nextScore2 = 2'd0;
        end
        `SERVE: begin
            nextScore1 = score1;
            nextScore2 = score2;
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
            if(ballStatus==`PLAYING) begin
                nextState = `PLAY;
            end
            else if(ballStatus==`PLAYER1WIN) begin
                nextScore1 = score1 + 1'b1;
                if(nextScore1<2'd3) begin
                    nextState = `SERVE;
                end
                else begin
                    nextState = `DONE;
                end
            end
            else begin
                nextScore2 = score2 + 1'b1;
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
            if(enter==1'b1) begin
                nextState = `START;
            end
            else begin
                nextState = `DONE;
            end
        end
    endcase
end
   
end
*/
endmodule
