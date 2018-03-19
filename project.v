`timescale 1ns / 1ns

module project(SW, HEX0, HEX1, CLOCK_50, GPIO_11, GPIO_12);
	input [7:0] SW;
	input CLOCK_50;
	input GPIO_11;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output GPIO_12;
	
		
	reg [27:0] lim; 
	wire [0:0]connect; 
	wire [7:0] out;
	wire [3:0] gpio;

	//Speed
	always@(*)
	begin
		case(SW[7:0])
		8'b00000000: lim = 28'd1199999999;//hour 0/ hour 24
		8'b00000001: lim = 28'd49999999;//hour 1
		8'b00000010: lim = 28'd99999999;//hour2 
		8'b00000011: lim = 28'd149999999;//hour 3
		8'b00000100: lim = 28'd199999999;// hour4 
		8'b00000101: lim = 28'd249999999;//hour5 
		8'b00000110: lim = 28'd299999999;//hour6
		8'b00000111: lim = 28'd349999999;//hour7
		8'b00001000: lim = 28'd399999999;//hour8
		8'b00001001: lim = 28'd449999999;//hour9
		8'b00001010: lim = 28'd499999999;//hour10
		8'b00001011: lim = 28'd549999999;//hour 11
		8'b00001100: lim = 28'd599999999;//hour 12
		8'b00001101: lim = 28'd649999999;//hour 13
		8'b00001110: lim = 28'd699999999;//hour 14
		8'b00001111: lim = 28'd749999999;//hour 15
		8'b00010000: lim = 28'd799999999;//hour 16
		8'b00010001: lim = 28'd849999999;//hour17
		8'b00010010: lim = 28'd899999999;//hour 18
		8'b00010011: lim = 28'd949999999;//hour 19
		8'b00010100: lim = 28'd999999999;//hour 20
		8'b00010101: lim = 28'd1049999999;//hour 21
		8'b00010110: lim = 28'd1099999999;//hour 22
		8'b00010111: lim = 28'd1149999999;//hour 23
		endcase
	end
	
	rateDivider rd(.lim(lim),.reset(SW[2]),.CLOCK_50(CLOCK_50),.cout(connect));
	displayCounter dc(.enable(connect),.reset(SW[3]),.CLOCK_50(CLOCK_50),.out(out));
	SevenSegmentDecoder ssd(.in(out[3:0]),.out(HEX0[6:0]));
	SevenSegmentDecoder ssd1(.in(out[7:4]),.out(HEX1[6:0]));
	
	
	
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
						count <= count - 1'b1;
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


