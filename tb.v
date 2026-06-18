`timescale 1ns/1ps

module spi_tb;

localparam WORD_SIZE = 3;
localparam CLK_FREQ = 50_000_000;
localparam SPI_FREQ = 1_000_000;
localparam PERIFERAL_COUNT = 2;

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
wire [WORD_SIZE-1:0] in_perif0_word;

wire [WORD_SIZE-1:0] out_perif1_word;
wire [WORD_SIZE-1:0] in_perif1_word;

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
.complete_word(in_perif0_word)
);

spi_periferal #(.CLK_FREQ(CLK_FREQ), .SPI_FREQ(SPI_FREQ), .DATA_SIZE(WORD_SIZE))
perif1_reciever (
.clk(pclk),
.copi(copi),
.sel_low(psel_low[1]),
.result(out_perif1_word),
.cipo(cipo),
.complete_word(in_perif1_word)
);

add1_perif #(.DATA_SIZE(WORD_SIZE)) 
perif0 (
.in(in_perif0_word), 
.result(out_perif0_word)
);

mul3_perif #(.DATA_SIZE(WORD_SIZE)) 
perif1 (
.in(in_perif1_word), 
.result(out_perif1_word)
);


integer i;
reg [WORD_SIZE-1:0] out_exp;
initial clk = 0;
always #(1_000_000_000 / CLK_FREQ / 2)
	clk = ~clk;

initial begin
	$display("Testing add1_module for all single word patterns ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		add1_module_test(i);


	$display("Testing all single word patterns ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		add1_single_test(i);

	$display("Testing all single word patterns 5 in a row ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		add1_same_5_in_a_row_test(i);

	$display("Testing some 5 word patterns ...");
	add1_5_test(0);
	add1_5_test(-1);
	add1_5_test(1);
	add1_5_test((2**(WORD_SIZE*5))/2);
	add1_5_test(WORD_SIZE);
	add1_5_test(((WORD_SIZE*5 + 3)*7) << WORD_SIZE * 3);

	$display("Testing two devices for all single word patterns ...");
	for(i=0; i < 2**WORD_SIZE; i=i+1)
		sel_switch_test(i);
	
	$display("DONE");
	$finish;
end

task add1_single_test;
input [WORD_SIZE-1:0] in;
begin
	sel = 1;
	out_exp = in + 1;
	in_word_buf = in;
	start = 1;

	@(posedge clk); #1;
	start = 0;
	wait(!controller_busy); #1;

	in_word_buf = 1;
	start = 1;
	@(posedge clk); #1;
	start = 0;
	wait(!controller_busy); #1;

	if(out_word_buf !== out_exp) begin
		$display("FAILED add1_single_test with input:");
		$display(in);
		$display("got:");
		$display(out_word_buf);
		$display(" ");
	end
end
endtask

integer j;

task add1_same_5_in_a_row_test;
input [WORD_SIZE-1:0] in;
begin
	sel = 1;
	out_exp = in+1;
	in_word_buf = in;
	for(j=0; j<=5; j=j+1)begin
		start = 1;
		@(posedge clk); #1;
		start = 0;
		wait(!controller_busy); 

		if(j>0 && out_word_buf !== out_exp) begin
			$display("FAILED add1_same_5_in_a_row with input:");
			$display(in);
			$display("got:");
			$display(out_word_buf);
			$display("from word index:");
			$display(j-1);
			$display(" ");
		end
	end
end
endtask


task add1_5_test;
input [(WORD_SIZE*5)-1:0] in_words;
begin
	sel = 1;
	start = 1;

	for(j=0; j<=5; j=j+1)begin
		in_word_buf = in_words[WORD_SIZE-1:0];
		@(posedge clk); #1;
		wait(!controller_busy);

		if(j>0 && out_word_buf !== out_exp) begin
			$display("FAILED add1_5_test at index:");
			$display(j);
			$display(" ");
		end

		out_exp = in_word_buf + 1;
		in_words = in_words >> WORD_SIZE;
	end
end
endtask

task sel_switch_test;
input [WORD_SIZE-1:0] in_word;
begin
	in_word_buf = in_word;

	// send input word for sel line b01
	sel = 1;
	start = 1;
	@(posedge clk); #1;
	start = 0;
	wait(!controller_busy); #1;
	
	start = 1;
	// recieve output word from sel line b01
	@(posedge clk); #1;
	start = 0;
	wait(!controller_busy); #1;
	out_exp = in_word + 1;
	if(out_exp !== out_word_buf) begin
		$display("FAILED sel_switch_test. The first operation was wrong.");
		$display("Expected: %d, Got: %d", out_exp, out_word_buf);
	end

	// send input word for sel line b10
	sel = 2;
	start = 1;
	@(posedge clk); #1;
	start = 0;
	wait(!controller_busy); #1;

	start = 1;
	// recieve output word from sel line b10
	@(posedge clk); #1;
	start = 0;
	wait(!controller_busy); #1;
	out_exp = in_word * 3;
	if(out_exp !== out_word_buf) begin
		$display("FAILED sel_switch_test. The second operation was wrong.");
		$display("Expected: %d, Got: %d", out_exp, out_word_buf);
	end
	
end
endtask

reg [WORD_SIZE-1:0] in_a;
reg in_ready_a = 0;
wire [WORD_SIZE-1:0] out_a;
add1_perif #(.DATA_SIZE(WORD_SIZE)) a (.in(in_a), .result(out_a));

task add1_module_test;
input [WORD_SIZE-1:0] in;
begin
	in_a = in;
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
