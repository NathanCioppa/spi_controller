
module spi_controller #(
	parameter CLK_FREQ = 50_000_000, 
	parameter SPI_FREQ = 1_000_000, 
	parameter CLK_DIV = CLK_FREQ / SPI_FREQ / 2,
       	parameter PERIFERAL_COUNT = 4,
	parameter DATA_SIZE = 8)(
	input clk,
        input [PERIFERAL_COUNT-1:0]sel,
	input [DATA_SIZE-1:0] in_buf,
	input copi, // controller out, periferal in 
	input start,
	output reg cipo, // controller in, periferal out 
	output reg pclk, // periferal clock
	output reg [PERIFERAL_COUNT-1:0] psel_low // periferal select, active low
	output reg [DATA_SIZE-1:0] out_buf;
	output reg busy;
);

localparam PCLK_INITIAL

reg [15:0] counter;
initial pclk = PCLK_INITIAL;
reg [DATA_SIZE-1:0] in_shift;
reg [DATA_SIZE-1:0] out_shift;

always @(posedge clk) begin
	if(start && !busy) begin
		busy <= 1;
		counter <= 0;
		pclk <= PCLK_INITIAL;
		in_shift <= in_buf;
		psel_low <= ~sel;
	end
	else if (counter >= CLK_DIV && busy) begin
		counter <= 0;
		pclk <= ~pclk;
	end
	else if (busy)
		counter = counter+1;
end

always @(posedge pclk) begin

end


endmodule
