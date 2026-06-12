`timescale 1ns/1ps

module spi_tb;

localparam WORD_SIZE = 8;
localparam CLK_FREQ = 50_000_000;
localparam SPI_FREQ = 1_000_000;
localparam PERIFERAL_COUNT = 1;

reg clk;
reg [PERIFERAL_COUNT-1:0] sel;
reg [DATA_SIZE-1:0] in_word_buf;
reg start;
wire cipo;
wire copi;
wire pclk;
wire [PERIFERAL_COUNT-1:0] psel_low;
reg [DATA_SIZE-1:0] out_word_buf;
wire controller_busy;

wire [WORD_SIZE-1:0] out_perif0_word;
wire perif0_word_ready;
wire in_perif0_word;

spi_controller #(.CLK_FREQ(CLK_FREQ), .SPI_FREQ(SPI_FREQ), .DATA_SIZE(WORD_SIZE), .PERIFERAL_COUNT(PERIFERAL_COUNT)) 
controller (
.clk(clk),
.sel(sel),
.in_buf(in_word_buf),
.cipo(cipo),
.start(start),
.copi(copi),
.pclk(pclk),
.psel_low(psel_low),
.out_buf(out_word_buf),
.busy(controller_busy)
);

spi_periferal #(.CLK_FREQ(CLK_FREQ), .SPI_FREQ(SPI_FREQ), .DATA_SIZE(WORD_SIZE))
perif0_reciever (
.clk(pclk),
.copi(copi),
.sel_low(psel_low[0]),
.result(out_perif0_word),
.cipo(cipo),
.in_ready(perif_word_ready),
.in_shift(in_perif0_word)
);

add1_perif #(.DATA_SIZE(WORD_SIZE)) 
perif0 (
.in(in_perif0_word), 
.in_ready(perif0_word_ready), 
.result(out_perif0_word)
);

always #(1_000_000_000 / CLK_FREQ / 2)
	clk = ~clk;



endmodule
