`timescale 1ns / 1ns

module project(SW, HEX0, HEX1, CLOCK_50, GPIO, LEDR);
	input [17:0] SW;
	input CLOCK_50;
   	output [20:0] GPIO;
	output [6:0] HEX0;
	output [6:0] HEX1;	
	output [17:0] LEDR;	
	reg [27:0] lim; 

	//Get interval delay from switches 5:0 for assigning the interval for the motor to be triggered
	//from 1-24 intervals/hours
	always@(*)
	begin
		case(SW[5:0])
		// d99999999+((d149999999/24)*hour) <- formula for calculating interval time 
		//pumping time which is: d99999999 + ((d149999999/24)*hour) <- this is the interval 
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
		default lim = 28'd000000000;
		endcase
	end
	// we use the seven segment decoder to show our current interval for the motor to the user
	SevenSegmentDecoder ssd(.in(SW[3:0]),
				.out(HEX0[6:0]));
					
	SevenSegmentDecoder ssd1(.in({2'b00,SW[5:4]}),
				 .out(HEX1[6:0]));

	//we use GPIO[1] for dimming red led by turning the LED on and off at a specific clock speed too fast for our eyes to detect,
	// we can adjust this blinking rate to make the light dimmer(slow blinking rate) or brighter(fast blinking rate)  						 
	LED_PWM ldred(.clk(CLOCK_50),
		      .PWM_input({SW[17],SW[13:11]}),
		      .LED(GPIO[1]));

	//we use GPIO[0] for dimming blue led by turning the LED on and off at a specific clock speed too fast for our eyes to detect,
	// we can adjust this blinking rate to make the light dimmer(slow blinking rate) or brighter(fast blinking rate) 
	LED_PWM ldblue(.clk(CLOCK_50),
		       .PWM_input(SW[17:14]),
		       .LED(GPIO[0]));
				
	//we use GPIO[2] for motor   	
	stay_on s1(.lim(lim),
		  .CLOCK_50(CLOCK_50),
		  .cout(GPIO[2]),
		  .reset(SW[7]),
		  .stay_on(28'd99999999));//keeps motor on for 2 seconds in between intervals

endmodule

//This is our water pump subsystem of the irrigation system
// we use the stay_on module to turn the motor on for a certain amount of time which by defined by the lim input
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

	assign cout = ((count < stay_on) && !(lim == 28'd000000000)) ? 1'b0 : 1'b1;
endmodule

//takes in 7bit binary and converts it to 8bit binary for use by HEX display, we don't use Alphabets because we only
// count the time.
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

//This is our second subsystem of our irrigation system called the light controller

/*given the PWM_input we can cycle the LED at specific refresh rates making it seem dimmer or brighter.
if you make the interval taken in from switches from PWM_input you can use make the LED dimmer,
by making the refresh rate slower and brighter by making the refresh rate faster
so 4'b1111 is the brightest 4'b0000 would be complete off, we then add it to a register and assign the carrybit
to the LED output, so if the carry bit is 0 LED is off, and if it is 1 it is on.*/
module LED_PWM(clk, PWM_input, LED);
	input clk;
	input [3:0] PWM_input;
	output LED;

	reg [4:0] PWM;
	always @(posedge clk) PWM <= PWM[3:0]+PWM_input;
	assign LED = PWM[4];
	
endmodule 

