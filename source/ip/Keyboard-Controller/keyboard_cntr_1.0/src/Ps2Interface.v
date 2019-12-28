`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NTHU
// Engineer: Y.J Shih
// 
// Create Date: 2015/05/27 11:15:54
// Design Name: PS/2 interface
// Module Name: Ps2Interface
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
//  Original VHDL version is create by Ulrich Zolt.
// 
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
// ps2interface.vhd
////////////////////////////////////////////////////////////////////////
// Author : Ulrich Zolt
//          Copyright 2006 Digilent, Inc.
////////////////////////////////////////////////////////////////////////
// This file contains the implementation of a generic bidirectional
// ps/2 interface.
////////////////////////////////////////////////////////////////////////
//  Behavioral description
////////////////////////////////////////////////////////////////////////
// Please read the following article on the web for understanding how
// the ps/2 protocol works.
// http://www.computer/engineering.org/ps2protocol/

// This module implements a generic bidirectional ps/2 interface. It can
// be used with any ps/2 compatible device. It offers its clients a
// convenient way to exchange data with the device. The interface
// transparently wraps the byte to be sent into a ps/2 frame, generates
// parity for byte and sends the frame one bit at a time to the device.
// Similarly, when receiving data from the ps2 device, the interface
// receives the frame, checks for parity, and extract the usefull data
// and forwards it to the client. If an error occurs during receiving
// or sending a byte, the client is informed by settings the err output
// line high. This way, the client can resend the data or can issue
// a resend command to the device.

// The physical ps/2 interface uses 4 lines
// For the 6/pin connector pins are assigned as follows: 
// 1 - Data
// 2 - Not Implemented
// 3 - Ground
// 4 - Vcc (+5V)
// 5 - Clock
// 6 - Not Implemented

// The clock line carries the device generated clock which has a 
// frequency in range 10 / 16.7 kHz (30 to 50us). When line is idle
// it is placed in high impedance. The clock is only generated when
// device is sending or receiving data.
// The Data and Clock lines are both open/collector with pullup
// resistors to Vcc. An "open/collector" interface has two possible
// states: low('0') or high impedance('Z').

// When device wants to send a byte, it pulls the clock line low and the
// host(i.e. this interfaces) recognizes that the device is sending data
// When the host wants to send data, it maeks a request to send. This
// is done by holding the clock line low for at least 100us, then with
// the clock line low, the data line is brought low. Next the clock line
// is released (placed in high impedance). The devices begins generating
// clock signal on clock line.
// When receiving data, bits are read from the data line (ps2_data) on
// the falling edge of the clock (ps2_clk). When sending data, the
// device reads the bits from the data line on the rising edge of the
// clock.
// A frame for sending a byte is comprised of 11 bits as shown bellow:
// bits     10     9    8    7    6    5    4    3    2    1      0
//        -------------------------------------------------------------
//        | STOP| PAR | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | START |
//        -------------------------------------------------------------
// STOP  - stop  bit, always '1'
// PAR   - parity bit, odd parity for the 8 data bits.
//       - select in such way that the number of bits of '1' in the data
//       - bits together with parity bit is odd.
// D0/7  - data bits.
// START - start bit, always '0'
//
// Frame is sent bit by bit starting with the least significant bit
// (starting bit) and is received the same way. This is done, when
// receiving, by shifting the frame register to the left when a bit
// is available and placing the bit on data line on the most significant
// bit. This way the first bit sent will reach the least significant bit
// of the frame when all the bits have been received. When sending data
// the least significant bit of the frame is placed on the data line
// and the frame is shifted to the right when another bit needs to be
// sent. During the request to send, when releasing the clock line,
// the device reads the data line and interprets the data on it as the
// first bit of the frame. Data line is low at that time, at this is the
// way the start bit('0') is sent. Because of this, when sending, only
// 10 shifts of the frame will be made.
// While the interface is sending or receiving data, the busy output
// signal goes high. When interface is idle, busy is low.
// After sending all the bits in the frame, the device must acknowledge
// the data sent. This is done by the host releasing and data line
// (clock line is already released) after the last bit is sent. The
// devices brings the data line and the clock line low, in this order,
// to acknowledge the data. If data line is high when clock line goes
// low after last bit, the device did not acknowledge the data and
// err output is set.
// A FSM is used to manage the transitions the set all the command
// signals. States that begin with "rx_" are used to receive data
// from device and states begining with "tx_" are used to send data
// to the device.
// For the parity bit, a ROM holds the parity bit for all possible
// data (256 possible values, since 8 bits of data). The ROM has
// dimensions 256x1bit. For obtaining the parity bit of a value,
// the bit at the data value address is read. Ex: to find the parity
// bit of 174, the bit at address 174 is read.
// For generating the necessary delay, counters are used. For example,
// to generate the 100us delay a 14 bit counter is used that has the
// upper limit for counting 10000. The interface is designed to run
// at 100MHz. Thus, 10000x10ns = 100us.

///////////////////////////////////////////////////////////////////////
// If using the interface at different frequency than 100MHz, adjusting
// the delay counters is necessary!!!
///////////////////////////////////////////////////////////////////////

// Clock line(ps2_clk) and data line(ps2_data) are passed through a
// debouncer for the transitions of the clock and data to be clean.
// Also, ps2_clk_s and ps2_data_s hold the debounced and synchronized
// value of the clock and data line to the system clock(clk).
////////////////////////////////////////////////////////////////////////
//  Port definitions
////////////////////////////////////////////////////////////////////////
// ps2_clk        - inout pin, clock line of the ps/2 interface
// ps2_data       - inout pin, data line of the ps/2 interface
// clk            - input pin, system clock signal
// rst            - input pin, system reset signal
// tx_data        - input pin, 8 bits, from client
//                - data to be sent to the device
// tx_valid       - input pin, from client
//                - should be active for one clock period when then
//                - client wants to send data to the device and
//                - data to be sent is valid on tx_data
// rx_data        - output pin, 8 bits, to client
//                - data received from device
// read           - output pin, to client
//                - active for one clock period when new data is
//                - available from device
// busy           - output pin, to client
//                - active while sending or receiving data.
// err            - output pin, to client
//                - active for one clock period when an error occurred
//                - during sending or receiving.
////////////////////////////////////////////////////////////////////////
// Revision History:
// 09/18/2006(UlrichZ): created
////////////////////////////////////////////////////////////////////////


module Ps2Interface#(
    parameter SYSCLK_FREQUENCY_HZ = 100000000
  )(
  ps2_clk,
  ps2_data,

  clk,
  rst,

  tx_data,
  tx_valid,

  rx_data,
  rx_valid,

  busy,
  err
);
  inout ps2_clk, ps2_data;
  input clk, rst;
  input [7:0] tx_data;
  input tx_valid;
  output reg [7:0] rx_data;
  output reg rx_valid;
  output busy;
  output reg err;
  
  parameter CLOCK_CNT_100US = (100*1000) / (1000000000/SYSCLK_FREQUENCY_HZ);
  parameter CLOCK_CNT_20US = (20*1000) / (1000000000/SYSCLK_FREQUENCY_HZ);
  parameter DEBOUNCE_DELAY = 15;
  parameter BITS_NUM = 11;
  
  parameter [0:0] parity_table [0:255] = {    //(odd) parity bit table, used instead of logic because this way speed is far greater
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1
  };
  
  parameter IDLE                        = 4'd0;
  parameter RX_NEG_EDGE                 = 4'd1;
  parameter RX_CLK_LOW                  = 4'd2;
  parameter RX_CLK_HIGH                 = 4'd3;
  parameter TX_FORCE_CLK_LOW            = 4'd4;
  parameter TX_BRING_DATA_LOW           = 4'd5;
  parameter TX_RELEASE_CLK              = 4'd6;
  parameter TX_WAIT_FIRTS_NEG_EDGE      = 4'd7;
  parameter TX_CLK_LOW                  = 4'd8;
  parameter TX_WAIT_POS_EDGE            = 4'd9;
  parameter TX_CLK_HIGH                 = 4'd10;
  parameter TX_WAIT_POS_EDGE_BEFORE_ACK = 4'd11;
  parameter TX_WAIT_ACK                 = 4'd12;
  parameter TX_RECEIVED_ACK             = 4'd13;
  parameter TX_ERROR_NO_ACK             = 4'd14;
  
  
  reg [10:0] frame;
  wire rx_parity;
  
  wire ps2_clk_in, ps2_data_in;
  reg clk_inter, ps2_clk_s, data_inter, ps2_data_s;
  reg [3:0] clk_count, data_count;
  
  reg ps2_clk_en, ps2_clk_en_next, ps2_data_en, ps2_data_en_next;
  reg ps2_clk_out, ps2_clk_out_next, ps2_data_out, ps2_data_out_next;
  reg err_next;
  reg [3:0] state, state_next;
  reg rx_finish;
  
  reg [3:0] bits_count;
  
  reg [13:0] counter, counter_next;
  
  IOBUF IOBUF_inst_0(
    .O(ps2_clk_in),
    .IO(ps2_clk),
    .I(ps2_clk_out),
    .T(~ps2_clk_en)
  );
	
  IOBUF IOBUF_inst_1(
    .O(ps2_data_in),
    .IO(ps2_data),
    .I(ps2_data_out),
    .T(~ps2_data_en)
  );
  //assign ps2_clk = (ps2_clk_en)?ps2_clk_out:1'bz;
  //assign ps2_data = (ps2_data_en)?ps2_data_out:1'bz;
  assign busy = (state==IDLE)?1'b0:1'b1;
  
  always @ (posedge clk, posedge rst)begin
    if(rst)begin
	  rx_data <= 0;
	  rx_valid <= 1'b0;
	end else if(rx_finish==1'b1)begin                       // set read signal for the client to know
	  rx_data <= frame[8:1];                                // a new byte was received and is available on rx_data
	  rx_valid <= 1'b1;
	end else begin
	  rx_data <= rx_data;
	  rx_valid <= 1'b0;
	end
  end
  
  assign rx_parity = parity_table[frame[8:1]];
  assign tx_parity = parity_table[tx_data];
  
  always @ (posedge clk, posedge rst)begin
    if(rst)
	  frame <= 0;
	else if(tx_valid==1'b1 && state==IDLE) begin
	  frame[0] <= 1'b0;              //start bit
	  frame[8:1] <= tx_data;         //data
	  frame[9] <= tx_parity;         //parity bit
	  frame[10] <= 1'b1;             //stop bit
	end else if(state==RX_NEG_EDGE || state==TX_CLK_LOW)
	  frame <= {ps2_data_s, frame[10:1]};
	else
	  frame <= frame;
  end
    
  // Debouncer
  always @ (posedge clk, posedge rst) begin
    if(rst)begin
	  ps2_clk_s <= 1'b1;
	  clk_inter <= 1'b1;
	  clk_count <= 0;
	end else if(ps2_clk_in != clk_inter)begin
	  ps2_clk_s <= ps2_clk_s;
	  clk_inter <= ps2_clk_in;
	  clk_count <= 0;
	end else if(clk_count == DEBOUNCE_DELAY) begin
	  ps2_clk_s <= clk_inter;
	  clk_inter <= clk_inter;
	  clk_count <= clk_count;
	end else begin
	  ps2_clk_s <= ps2_clk_s;
	  clk_inter <= clk_inter;
	  clk_count <= clk_count + 1'b1;
	end
  end
  
  always @ (posedge clk, posedge rst) begin
    if(rst)begin
	  ps2_data_s <= 1'b1;
	  data_inter <= 1'b1;
	  data_count <= 0;
	end else if(ps2_data_in != data_inter)begin
	  ps2_data_s <= ps2_data_s;
	  data_inter <= ps2_data_in;
	  data_count <= 0;
	end else if(data_count == DEBOUNCE_DELAY) begin
	  ps2_data_s <= data_inter;
	  data_inter <= data_inter;
	  data_count <= data_count;
	end else begin
	  ps2_data_s <= ps2_data_s;
	  data_inter <= data_inter;
	  data_count <= data_count + 1'b1;
	end
  end
  
  // FSM
  always @ (posedge clk, posedge rst)begin
    if(rst)begin
	  state <= IDLE;
	  ps2_clk_en <= 1'b0;
	  ps2_clk_out <= 1'b0;
	  ps2_data_en <= 1'b0;
	  ps2_data_out <= 1'b0;
	  err <= 1'b0;
	  counter <= 0;
	end else begin
	  state <= state_next;
	  ps2_clk_en <= ps2_clk_en_next;
	  ps2_clk_out <= ps2_clk_out_next;
	  ps2_data_en <= ps2_data_en_next;
	  ps2_data_out <= ps2_data_out_next;
	  err <= err_next;
	  counter <= counter_next;
	end
  end
  
  always @ * begin
    state_next = IDLE;                                     // default values for these signals
	ps2_clk_en_next = 1'b0;                                // ensures signals are reset to default value
	ps2_clk_out_next = 1'b1;                               // when conditions for their activation are no
	ps2_data_en_next = 1'b0;                               // longer applied (transition to other state,
	ps2_data_out_next = 1'b1;                              // where signal should not be active)
	err_next = 1'b0;                                       // Idle value for ps2_clk and ps2_data is 'Z'
	rx_finish = 1'b0;
	counter_next = 0;
    case(state)
	  IDLE:begin                                           // wait for the device to begin a transmission
	      if(tx_valid == 1'b1)begin                        // by pulling the clock line low and go to state
		    state_next = TX_FORCE_CLK_LOW;                 // RX_NEG_EDGE or, if write is high, the
	      end else if(ps2_clk_s == 1'b0)begin              // client of this interface wants to send a byte
		    state_next = RX_NEG_EDGE;                      // to the device and a transition is made to state
	      end else begin                                   // TX_FORCE_CLK_LOW
		    state_next = IDLE;
		  end
	    end
		
	  RX_NEG_EDGE:begin                                    // data must be read into frame in this state
	      state_next = RX_CLK_LOW;                         // the ps2_clk just transitioned from high to low
	    end
		
	  RX_CLK_LOW:begin                                     // ps2_clk line is low, wait for it to go high
	      if(ps2_clk_s == 1'b1)begin
		    state_next = RX_CLK_HIGH;
		  end else begin
		    state_next = RX_CLK_LOW;
		  end
	    end
		
	  RX_CLK_HIGH:begin                                    // ps2_clk is high, check if all the bits have been read
	      if(bits_count == BITS_NUM)begin                  // if, last bit read, check parity, and if parity ok
		    if(rx_parity != frame[9])begin                 // load received data into rx_data.
			  err_next = 1'b1;                             // else if more bits left, then wait for the ps2_clk to
			  state_next = IDLE;                           // go low
			end else begin
			  rx_finish = 1'b1;
			  state_next = IDLE;
			end
		  end else if(ps2_clk_s == 1'b0)begin
		    state_next = RX_NEG_EDGE;
	      end else begin
		    state_next = RX_CLK_HIGH;
		  end		  
	    end
		
	  TX_FORCE_CLK_LOW:begin                               // the client wishes to transmit a byte to the device
	      ps2_clk_en_next = 1'b1;                          // this is done by holding ps2_clk down for at least 100us
		  ps2_clk_out_next = 1'b0;                         // bringing down ps2_data, wait 20us and then releasing
		  if(counter == CLOCK_CNT_100US)begin              // the ps2_clk.
		    state_next = TX_BRING_DATA_LOW;                // This constitutes a request to send command.
			counter_next = 0;                              // In this state, the ps2_clk line is held down and
		  end else begin                                   // the counter for waiting 100us is enabled.
		    state_next = TX_FORCE_CLK_LOW;                 // when the counter reached upper limit, transition
			counter_next = counter + 1'b1;                 // to TX_BRING_DATA_LOW
		  end                                              
	    end                              

	  TX_BRING_DATA_LOW:begin                              // with the ps2_clk line low bring ps2_data low
	      ps2_clk_en_next = 1'b1;                          // wait for 20us and then go to TX_RELEASE_CLK
		  ps2_clk_out_next = 1'b0;

		  // set data line low
		  // when clock is released in the next state
		  // the device will read bit 0 on data line
		  // and this bit represents the start bit.
		  ps2_data_en_next = 1'b1;
		  ps2_data_out_next = 1'b0;
	      if(counter == CLOCK_CNT_20US)begin
		    state_next = TX_RELEASE_CLK;
			counter_next = 0;
		  end else begin
		    state_next = TX_BRING_DATA_LOW;
			counter_next = counter + 1'b1;
		  end
	    end
		
      TX_RELEASE_CLK:begin                                 // release the ps2_clk line
	      ps2_clk_en_next = 1'b0;                          // keep holding data line low 
		  ps2_data_en_next = 1'b1;
		  ps2_data_out_next = 1'b0;
		  state_next = TX_WAIT_FIRTS_NEG_EDGE;
	    end
		
	  TX_WAIT_FIRTS_NEG_EDGE:begin                         // state is necessary because the clock signal
	      ps2_data_en_next = 1'b1;                         // is not released instantaneously and, because of debounce, 
		  ps2_data_out_next = 1'b0;                        // delay is even greater. 
		  if(counter == 14'd63)begin                       // Wait 63 clock periods for the clock line to release 
		    if(ps2_clk_s == 1'b0)begin                     // then if clock is low then go to tx_clk_l 
			  state_next = TX_CLK_LOW;                     // else wait until ps2_clk goes low. 
			  counter_next = 0;                            
			end else begin
			  state_next = TX_WAIT_FIRTS_NEG_EDGE;
			  counter_next = counter;
			end
		  end else begin
		    state_next = TX_WAIT_FIRTS_NEG_EDGE;
			counter_next = counter + 1'b1;
		  end
	    end
	  
	  TX_CLK_LOW:begin                                     // place the least significant bit from frame 
	      ps2_data_en_next = 1'b1;                         // on the data line
		  ps2_data_out_next = frame[0];                    // During this state the frame is shifted one
		  state_next = TX_WAIT_POS_EDGE;                   // bit to the right
	    end
	  
	  TX_WAIT_POS_EDGE:begin                               // wait for the clock to go high
	      ps2_data_en_next = 1'b1;                         // this is the edge on which the device reads the data
		  ps2_data_out_next = frame[0];                    // on ps2_data.
		  if(bits_count == BITS_NUM-1)begin                // keep holding ps2_data on frame(0) because else
		    ps2_data_en_next = 1'b0;                       // will be released by default value.
			state_next = TX_WAIT_POS_EDGE_BEFORE_ACK;      // Check if sent the last bit and if so, release data line
		  end else if(ps2_clk_s == 1'b1)begin              // and go to state that wait for acknowledge
		    state_next = TX_CLK_HIGH;
		  end else begin
		    state_next = TX_WAIT_POS_EDGE;
		  end
	    end
	
      TX_CLK_HIGH:begin                                    // ps2_clk is released, wait for down edge
	      ps2_data_en_next = 1'b1;                         // and go to tx_clk_l when arrived
		  ps2_data_out_next = frame[0];
		  if(ps2_clk_s == 1'b0)begin
		    state_next = TX_CLK_LOW;
		  end else begin
		    state_next = TX_CLK_HIGH;
		  end
	    end
	  
	  TX_WAIT_POS_EDGE_BEFORE_ACK:begin                    // release ps2_data and wait for rising edge of ps2_clk
	      if(ps2_clk_s == 1'b1)begin                       // once this occurs, transition to tx_wait_ack
		    state_next = TX_WAIT_ACK;
		  end else begin
		    state_next = TX_WAIT_POS_EDGE_BEFORE_ACK;
		  end
	    end
		
	  TX_WAIT_ACK:begin                                    // wait for the falling edge of the clock line
	      if(ps2_clk_s == 1'b0)begin                       // if data line is low when this occurs, the
		    if(ps2_data_s == 1'b0) begin                   // ack is received
			  state_next = TX_RECEIVED_ACK;                // else if data line is high, the device did not
			end else begin                                 // acknowledge the transimission
			  state_next = TX_ERROR_NO_ACK;
			end
		  end else begin
		    state_next = TX_WAIT_ACK;
		  end
	    end
	  
	  TX_RECEIVED_ACK:begin                                // wait for ps2_clk to be released together with ps2_data
	      if(ps2_clk_s == 1'b1 && ps2_clk_s == 1'b1)begin  // (bus to be idle) and go back to idle state
		    state_next = IDLE;
		  end else begin
		    state_next = TX_RECEIVED_ACK;
		  end
	    end
		
	  TX_ERROR_NO_ACK:begin
	      if(ps2_clk_s == 1'b1 && ps2_clk_s == 1'b1)begin  // wait for ps2_clk to be released together with ps2_data
		    err_next = 1'b1;                               // (bus to be idle) and go back to idle state
			state_next = IDLE;                             // signal error for not receiving ack
		  end else begin
		    state_next = TX_ERROR_NO_ACK;
		  end
	    end
	
	  default:begin                                        // if invalid transition occurred, signal error and
	      err_next = 1'b1;                                 // go back to idle state
		  state_next = IDLE;
	    end
		
    endcase
  end
  
  always @ (posedge clk, posedge rst)begin
    if(rst)
	  bits_count <= 0;
	else if(state==IDLE)
	  bits_count <= 0;
	else if(state==RX_NEG_EDGE || state==TX_CLK_LOW)
	  bits_count <= bits_count + 1'b1;
	else
	  bits_count <= bits_count;
  end
	
endmodule
