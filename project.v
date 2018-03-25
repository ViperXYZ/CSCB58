`timescale 1ns / 1ns

module project(SW, HEX0, HEX1, CLOCK_50, GPIO, LEDR);
	input [17:0] SW;
	input CLOCK_50;
   output [20:0] GPIO;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [17:0] LEDR;
//	assign GPIO[0] = SW[10];//blue
//	assign GPIO[1] = SW[11];//red
//	assign GPIO[2] = SW[12];//green
		
	reg [27:0] lim; 
	wire [0:0]connect; 
	wire [7:0] out;
	wire [3:0] gpio;
	wire LEDinput;
	//Speed
	always@(*)
	begin
		case(SW[4:0])
//		5'b00000: lim = 28'd1199999999;//hour 0/ hour 24
		5'b00001: lim = 28'd49999999;//hour 1
		5'b00010: lim = 28'd99999999;//hour2 
		5'b00011: lim = 28'd149999999;//hour 3
		5'b00100: lim = 28'd199999999;// hour4 
		5'b00101: lim = 28'd249999999;//hour5 
//		5'b00110: lim = 28'd299999999;//hour6
//		5'b00111: lim = 28'd349999999;//hour7
//		5'b01000: lim = 28'd399999999;//hour8
//		5'b01001: lim = 28'd449999999;//hour9
//		5'b01010: lim = 28'd499999999;//hour10
//		5'b01011: lim = 28'd549999999;//hour 11
//		5'b01100: lim = 28'd599999999;//hour 12
//		5'b01101: lim = 28'd649999999;//hour 13
//		5'b01110: lim = 28'd699999999;//hour 14
//		5'b01111: lim = 28'd749999999;//hour 15
//		5'b10000: lim = 28'd799999999;//hour 16
//		5'b10001: lim = 28'd849999999;//hour17
//		5'b10010: lim = 28'd899999999;//hour 18
//		5'b10011: lim = 28'd949999999;//hour 19
//		5'b10100: lim = 28'd999999999;//hour 20
//		5'b10101: lim = 28'd1049999999;//hour 21
//		5'b10110: lim = 28'd1099999999;//hour 22
//		5'b10111: lim = 28'd1149999999;//hour 23 EP4CE115F29C7
		endcase
	end
	rateDivider rd(.lim(lim),.reset(SW[8]),.CLOCK_50(CLOCK_50),.cout(connect));
	displayCounter dc(.enable(connect),.reset(SW[9]),.CLOCK_50(CLOCK_50),.out(out));
	SevenSegmentDecoder ssd(.in(out[3:0]),.out(HEX0[6:0]));
	SevenSegmentDecoder ssd1(.in(out[7:4]),.out(HEX1[6:0]));
	LED_PWM ldred(.clk(CLOCK_50),.PWM_input({SW[17], SW[13:11]}),.LED(GPIO[1]));
	LED_PWM ldblue(.clk(CLOCK_50),.PWM_input(SW[17:14]),.LED(GPIO[0]));
	stay_on s1(.lim(lim),.CLOCK_50(CLOCK_50), .cout(GPIO[2]),.reset(SW[7]));




endmodule

module stay_on(lim, CLOCK_50, cout, reset);
	input [27:0]lim;
	input [0:0]reset;
	input CLOCK_50;
	output cout;
	reg [27:0]count;
	always@(posedge CLOCK_50)
	begin 
		if (reset == 1'b0)
			count <= lim;
		else
			begin
			
				if (count == 0)
						count <= lim;
				else
						count <= count - 1'b1;
			end
	end
	assign cout = (count < ((lim+1) * 0.5)) ? 1'b1 : 1'b0;
endmodule


	
module LED_PWM(clk, PWM_input, LED);
	input clk;
	input [3:0] PWM_input;     // 16 intensity levels
	output LED;

	reg [4:0] PWM;
	always @(posedge clk) PWM <= PWM[3:0]+PWM_input;
	assign LED = PWM[4];
endmodule


module rateDivider(lim, reset, CLOCK_50, cout);
	input [27:0]lim;
	input [0:0]reset;
	input CLOCK_50;
	output cout;
	reg [27:0]count;
	
	always@(posedge CLOCK_50)
	begin 
		if (reset == 1'b0)
			count <= lim;
		else
			begin
			
				if (count == 0)
						count <= lim;
				else
						count <= count - 1'd1;
			end
	end
	
	assign cout = (count == 0) ? 1 : 0;
endmodule 

module displayCounter(enable, reset, CLOCK_50,out);
	input [0:0]enable;
	input [0:0]reset;
	input CLOCK_50;
	output reg [7:0]out;
	
	
	always@(posedge CLOCK_50)
	begin 
		if (reset == 1'b0)
			out <= 0;
		else if (enable == 1'b1)
					out <= out + 1'b1;
	end
	
endmodule

module SevenSegmentDecoder(in, out);
	input[7:0]in;
	output reg [6:0]out;
	
	
	always @*
		case(in)
			8'b0000 : out = ~7'b0111111; //0
			8'b0001 : out = ~7'b0000110; //1
			8'b0010 : out = ~7'b1011011; //2
			8'b0011 : out = ~7'b1001111; //3
			8'b0100 : out = ~7'b1100110; //4
			8'b0101 : out = ~7'b1101101; //5 
			8'b0110 : out = ~7'b1111101; //6
			8'b0111 : out = ~7'b0000111; //7
			8'b1000 : out = ~7'b1111111; //8
			8'b1001 : out = ~7'b1101111; //9
			

		endcase
endmodule 
