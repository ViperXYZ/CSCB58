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
		6'b000001: lim = 28'd106249999;//hour 1
		6'b000010: lim = 28'd112499999;//hour2 
		6'b000011: lim = 28'd118749999;//hour 3
		6'b000100: lim = 28'd124999999;// hour4 
		6'b000101: lim = 28'd131249999;//hour5 
		6'b000110: lim = 28'd137499999;//hour6
		6'b000111: lim = 28'd143749999;//hour7
		6'b001000: lim = 28'd149999999;//hour8
		6'b001001: lim = 28'd156249999;//hour9
		6'b010000: lim = 28'd162499999;//hour10
		6'b010001: lim = 28'd168749999;//hour 11
		6'b010010: lim = 28'd174999999;//hour 12
		6'b010011: lim = 28'd181249998;//hour 13
		6'b010100: lim = 28'd187499998;//hour 14
		6'b010101: lim = 28'd193749998;//hour 15
		6'b010110: lim = 28'd199999998;//hour 16
		6'b010111: lim = 28'd206249998;//hour17
		6'b011000: lim = 28'd212499998;//hour 18
		6'b011001: lim = 28'd218749998;//hour 19
		6'b100000: lim = 28'd224999998;//hour 20
		6'b100001: lim = 28'd231249998;//hour 21
		6'b100010: lim = 28'd237499998;//hour 22
		6'b100011: lim = 28'd243749998;//hour 23 
		6'b100100: lim = 28'd249999998;//hour 24
		// d99999999+((d149999999/24)*hour)
		default lim = 28'd000000000;
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


	assign cout = ((count < stay_on) && !(lim == 28'd000000000)) ? 1'b0 : 1'b1