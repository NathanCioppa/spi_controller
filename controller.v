
module spi_controller #(
	parameter CLK_FREQ = 50_000_000, 
	parameter SPI_FREQ = 1_000_000, 
	parameter CLK_DIV = CLK_FREQ / SPI_FREQ / 2,
       	parameter PERIFERAL_COUNT = 4,
	parameter DATA_SIZE = 8)(
	input clk,
        input [PERIFERAL_COUNT-1:0]sel,
	input [DATA_SIZE-1:0] in_buf,
	input cipo, // controller in, periferal out
	input start,
	output reg copi, // controller out, periferal in
	output reg pclk, // periferal clock
	output reg [PERIFERAL_COUNT-1:0] psel_low, // periferal select, active low
	output reg [DATA_SIZE-1:0] out_buf,
	output reg busy
);

localparam PCLK_INITIAL = 0;

reg [15:0] counter;
reg [15:0] pcounter;
initial pclk = PCLK_INITIAL;
reg [DATA_SIZE-1:0] in_shift;
reg [DATA_SIZE-1:0] out_shift;
initial busy = 0;

always @(posedge clk) begin
	if(start && !busy) begin
		busy <= 1;
		counter <= 0;
		pclk <= 0;
		in_shift <= in_buf;
		psel_low <= ~sel;
		pcounter <= 0;
		copi <= in_buf[0];
	end
	else if (counter >= CLK_DIV && busy) begin
		counter <= 0;
		pclk <= ~pclk;
	end
	else if (busy)
		counter <= counter+1;
end

always @(posedge pclk) begin
	out_shift <= {cipo, out_shift[DATA_SIZE-1:1]}; // read periferal transmission into shift
	copi <= in_shift[1]; // transmit the next bit
	in_shift <= in_shift >> 1;

	pcounter <= pcounter + 1;
	if(pcounter >= DATA_SIZE-1) begin
		out_buf <= {cipo, out_shift[DATA_SIZE-1:1]};
		busy <= 0;
	end

end

endmodule
