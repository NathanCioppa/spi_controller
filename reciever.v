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
	output reg in_ready,
	output reg [DATA_SIZE-1:0] in_shift
);

initial in_ready = 0;
reg [15:0] counter;
reg [DATA_SIZE-1:0] out_shift;

always @(posedge clk) begin
	if(!sel_low) begin
		cipo <= out_shift[0];
	
		in_shift <= {copi, in_shift[DATA_SIZE-1:1]};
	
		if(counter >= DATA_SIZE-1) begin
			counter <= 0;
			in_ready <= 1;
		end
		else begin
			in_ready <= 0;
			out_shift <= out_shift >> 1;
			counter <= counter + 1;
		end
	end
end

always @(result) begin
	$display("YYY");
	out_shift <= result;
end	
	
endmodule
