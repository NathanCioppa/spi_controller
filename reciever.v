module spi_periferal #(
	parameter DATA_SIZE = 8, 
	parameter SPI_FREQ = 1_000_000, 
	parameter CLK_FREQ = 50_000_000, 
	parameter CLK_DIV = CLK_FREQ / SPI_FREQ / 2) (
	input clk,
	input copi,
	input sel_low,
	output reg cipo,
);

reg [15:0] counter;
reg [DATA_SIZE-1:0] in_shift;
reg [DATA_SIZE-1:0] out_shift;
reg [DATA_SIZE-1:0] out_buf;

always @(posedge clk) begin
	if(!sel_low) begin
		counter <= counter + 1;

		out_shift <= out_shift >> 1;
		cipo <= out_shift[0];

		in_shift <= {copi, in_shift[DATA_SIZE-1:1]};
		if(counter >= DATA_SIZE-1) begin
			counter <= 0;
			out_shift <= {copi, in_shift[DATA_SIZE-1:1]} * 3; // This specific periferal will just do multiplication by 3
		end
	end



end
	
endmodule
