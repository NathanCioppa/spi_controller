module spi_periferal #(
	parameter DATA_SIZE = 8, 
	parameter SPI_FREQ = 1_000_000, 
	parameter CLK_FREQ = 50_000_000, 
	parameter CLK_DIV = CLK_FREQ / SPI_FREQ / 2) (
	input clk,
	input copi,
	input sel_low,
	input [DATA_SIZE-1:0] result,
	output reg cipo,
	output reg [DATA_SIZE-1:0] complete_word
);


reg [15:0] counter = 0;
reg [DATA_SIZE-1:0] out_shift;
reg [DATA_SIZE-1:0] in_shift;

always @(posedge clk) begin
	if(!sel_low) begin
		in_shift <= {copi, in_shift[DATA_SIZE-1:1]}; // read transmission into shift
		cipo <= out_shift[1]; // transmit next bit
		out_shift <= out_shift >> 1;

		if(counter >= DATA_SIZE-1) begin
			counter <= 0;
			complete_word <= {copi, in_shift[DATA_SIZE-1:1]};

			// set out_shift to the last result again, since the
			// always @(result) block will not again fire if the same
			// word is sent multiple times in a row. 
			// If the next word is not identical, this will be 
			// overridden anyway. 
			out_shift <= result;
			cipo <= result[0];
		end
		else begin
			counter <= counter + 1;
		end
	end
	else
		cipo <= 0;
end

always @(result) begin
	out_shift <= result;
	cipo <= result[0];
end
	
endmodule
