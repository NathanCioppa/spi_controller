
`timescale 1ns/1ps

module spi_periferal #(
	parameter DATA_SIZE = 8 
//	parameter SPI_FREQ = 1_000_000, 
//	parameter CLK_FREQ = 50_000_000, 
//	parameter CLK_DIV = CLK_FREQ / SPI_FREQ / 2
	
) (
	input pclk,
	input copi,
	input sel_low,
	input [DATA_SIZE-1:0] result,
	output cipo,
	output reg [DATA_SIZE-1:0] complete_word
);


integer pcounter;

reg [DATA_SIZE-1:0] out_shift;
reg [DATA_SIZE-1:0] in_shift;

assign cipo = sel_low ? 1'bz : out_shift[0];

// send data on positive edge
always @(posedge pclk) begin

	if(!sel_low) begin
		if(pcounter == 0)
			out_shift <= result;
		else
			out_shift <= out_shift >> 1;
	end
end

// recieve data on negative edge
always @(negedge pclk) begin
	if(!sel_low) begin
		in_shift <= {copi, in_shift[DATA_SIZE-1:1]};

		if(pcounter >= DATA_SIZE-1) begin
			complete_word <= {copi, in_shift[DATA_SIZE-1:1]};
			pcounter <= 0;
		end
		else 
			pcounter <= pcounter + 1;
	end
end

endmodule
