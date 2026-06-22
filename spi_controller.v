
`timescale 1ns/1ps

module spi_controller #(
	parameter CLK_FREQ = 50_000_000, 
	parameter SPI_FREQ = 1_000_000, 
	parameter CLK_DIV = CLK_FREQ / SPI_FREQ / 2,
       	parameter PERIFERAL_COUNT = 4,
	parameter DATA_SIZE = 8)
(
	input clk,
        input [PERIFERAL_COUNT-1:0]sel,
	input [DATA_SIZE-1:0] in_buf,
	input cipo, // controller in, periferal out
	input start,
	output  copi, // controller out, periferal in
	output reg pclk, // periferal clock
	output reg [PERIFERAL_COUNT-1:0] psel_low, // periferal select, active low
	output reg [DATA_SIZE-1:0] out_buf,
	output reg busy
);

localparam PCLK_INITIAL = 0;

integer counter;
integer pcounter;

initial pclk = PCLK_INITIAL;
initial busy = 0;

reg [DATA_SIZE-1:0] in_shift;
reg [DATA_SIZE-1:0] out_shift;

assign copi = in_shift[0];

always @(posedge clk) begin
	if(start && !busy) begin
		busy <= 1;
		counter <= 0;
		pclk <= PCLK_INITIAL;
		psel_low <= ~sel;
	end
	else if (counter >= CLK_DIV && busy) begin
		counter <= 0;
		pclk <= ~pclk;
	end
	else if (busy) begin
		counter <= counter+1;
	end
end

// send data on positive edge
always @(posedge pclk) begin
	if(pcounter == 0)
		in_shift <= in_buf;
	else
		in_shift <= in_shift >> 1;
end

// recieve data on negative edge
always @(negedge pclk) begin
	out_shift <= {cipo, out_shift[DATA_SIZE-1:1]};

	if(pcounter >= DATA_SIZE-1) begin
		out_buf <= {cipo, out_shift[DATA_SIZE-1:1]};
		pcounter <= 0;
		busy <= 0;
	end
	else
		pcounter <= pcounter + 1;

end

endmodule
