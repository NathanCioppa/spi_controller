`timescale 1ns/1ps

module spi_tb;

localparam WORD_SIZE = 4;
localparam CLK_FREQ = 50_000_000;
localparam SPI_FREQ = 1_000_000;
localparam PERIFERAL_COUNT = 1;

localparam WORD_TIME = (1_000_000_000 / SPI_FREQ)*WORD_SIZE;

reg clk;
reg [PERIFERAL_COUNT-1:0] sel;
reg [WORD_SIZE-1:0] in_word_buf;
reg start;
wire cipo;
wire copi;
wire pclk;
wire [PERIFERAL_COUNT-1:0] psel_low;
wire [WORD_SIZE-1:0] out_word_buf;
wire controller_busy;

wire [WORD_SIZE-1:0] out_perif0_word;
wire perif0_word_ready;
wire [WORD_SIZE-1:0] in_perif0_word;

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

integer i;
reg [WORD_SIZE-1:0] out_exp;
always #(1_000_000_000 / CLK_FREQ / 2)
	clk = ~clk;

initial begin
	$display("Testing add1_module for all single word patterns ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		add1_module_test(i);


	$display("Testing all single word patterns ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		add1_single_test(i);

	$display("Testing 5 words without delay ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		add1_5_test(0);

	$display("DONE");
	$finish;
end

task add1_single_test;
input [WORD_SIZE-1:0] in;
begin
	out_exp = in + 1;
	in_word_buf = in;
	start = 1;

	#100
	start = 0;
	#(CLK_FREQ/2)
	in_word_buf = 0;
	start = 1;
	#100
	start = 0;
	#(CLK_FREQ/2)

	if(out_word_buf != out_exp) begin
		$display("FAILED add1_single_test with input:");
		$display(in);
		$display("got:");
		$display(out_word_buf);
		$display(" ");
	end
end
endtask

task add1_5_test;
input [(WORD_SIZE*5)-1:0] in_words;
begin
	in_word_buf = in_words[WORD_SIZE-1:0];
	start = 1;
	#(WORD_TIME)
	// use a shift register instead of i
	for(i=0; i<5; i=i+1) begin
		out_exp = in_words[(i*WORD_SIZE)+(WORD_SIZE-1):i*WORD_SIZE] + 1;
		if(out_word_buf != out_exp) begin
			$display("FAILED add1_5_test at word index:");
			$display(i);
			$display(" ");
		end
		in_word_buf = in_words[((i+1)*WORD_SIZE)+(WORD_SIZE-1):(i+1)*WORD_SIZE];
		#(WORD_TIME)
	end


end
endtask

reg [WORD_SIZE-1:0] in_a;
reg in_ready_a = 0;
wire [WORD_SIZE-1:0] out_a;
add1_perif #(.DATA_SIZE(WORD_SIZE)) a (.in(in_a), .in_ready(in_ready_a), .result(out_a));

task add1_module_test;
input [WORD_SIZE-1:0] in;
begin
	in_a = in;
	in_ready_a = 1;
	#100
	in_ready_a = 0;

	out_exp = in+1;
	if(out_a != out_exp) begin
		$display("FAILED add1_module_test with input:");
		$display(in);
		$display("got:");
		$display(out_a);
		$display(" ");
	end
end
endtask

endmodule
