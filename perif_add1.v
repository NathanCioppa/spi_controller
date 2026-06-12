
module add1_perif #(
	parameter DATA_SIZE = 8) (
	input [DATA_SIZE-1:0] in, 
	input in_ready, 
	output reg [DATA_SIZE-1:0] result
);


always @(posedge in_ready)begin
	result <= in + 1;
end

endmodule
