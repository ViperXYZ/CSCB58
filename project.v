`timescale 1ns / 1ns

module project(SW, HEX0, HEX1, CLOCK_50, GPIO, LEDR);
	input [17:0] SW;
	input CLOCK_50;
   output [20:0] GPIO;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [17:0] LEDR;
	
	reg [27:0] lim; 
	//Get interval delay between pulses
	always@(*)
	begin
		case(SW[5:0])
		6'b000001: lim = 28'd49999999;//hour 1
		6'b000010: lim = 28'd99999999;//hour2 
		6'b000011: lim = 28'd149999999;//hour 3
		6'b000100: lim = 28'd199999999;// hour4 
		6'b000101: lim = 28'd249999999;//hour5 
//		6'b000110: lim = 28'd299999999;//hour6
//		6'b000111: lim = 28'd349999999;//hour7
//		6'b001000: lim = 28'd399999999;//hour8
//		6'b001001: lim = 28'd449999999;//hour9
//		6'b010000: lim = 28'd499999999;//hour10
//		6'b010001: lim = 28'd549999999;//hour 11
//		6'b010010: lim = 28'd599999999;//hour 12
//		6'b010011: lim = 28'd649999999;//hour 13
//		6'b010100: lim = 28'd699999999;//hour 14
//		6'b010101: lim = 28'd749999999;//hour 15
//		6'b010110: lim = 28'd799999999;//hour 16
//		6'b010111: lim = 28'd849999999;//hour17
//		6'b011000: lim = 28'd899999999;//hour 18
//		6'b011001: lim = 28'd949999999;//hour 19
//		6'b100000: lim = 28'd999999999;//hour 20
//		6'b100001: lim = 28'd1049999999;//hour 21
//		6'b100010: lim = 28'd1099999999;//hour 22
//		6'b100011: lim = 28'd1149999999;//hour 23 
//		6'b100100: lim = 28'd1199999999;//hour 24

		endcase
	end
	SevenSegmentDecoder ssd(.in(SW[3:0]),
									.out(HEX0[6:0]));
									
	SevenSegmentDecoder ssd1(.in({2'b00,SW[5:4]}),
									 .out(HEX1[6:0]));
									 
	LED_PWM ldred(.clk(CLOCK_50),
					  .PWM_input({SW[17],SW[13:11]}),
					  .LED(GPIO[1]));
					  
	LED_PWM ldblue(.clk(CLOCK_50),
						.PWM_input(SW[17:14]),
						.LED(GPIO[0]));
						
   stay_on s1(.lim(lim),
				  .CLOCK_50(CLOCK_50),
				  .cout(GPIO[2]),
				  .reset(SW[7]),
				  .stay_on(28'd99999999));//keeps motor on for 2 seconds in between intervals

endmodule

module stay_on(lim, CLOCK_50, cout, reset, stay_on);
	input [27:0]lim;
	input [27:0] stay_on;
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
	assign cout = (count < stay_on) ? 1'b1 : 1'b0;
endmodule


	
module LED_PWM(clk, PWM_input, LED);
	input clk;
	input [3:0] PWM_input;
	output LED;

	reg [4:0] PWM;
	always @(posedge clk) PWM <= PWM[3:0]+PWM_input;
	assign LED = PWM[4];
	
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
