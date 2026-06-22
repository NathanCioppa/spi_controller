
`timescale 1ns/1ps 

module add1_perif #(
	parameter DATA_SIZE = 8) (
	input [DATA_SIZE-1:0] in, 
	output [DATA_SIZE-1:0] result
);

assign result = in + 1;

endmodule
