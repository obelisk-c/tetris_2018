
// A module that returns a clock that pulses once when the number of pulses indicated by load_value
// is detected from the clock_in.  Ex, load_value = 3 means that clock_out pulses in the 3rd, 6th, 9th, etc.

module rate_divider(
input resetn,
input [19:0]load_value,
input clock_in,
output reg clock_out);

reg [19:0]count;

initial begin
	count = load_value - 20'd1;
end

always @(posedge clock_in) begin
	if (count > 0 && resetn) begin
		count <= count - 20'd1;
	end else begin
		count <= load_value - 20'd1;
	end
end

always @(*) begin
	clock_out = 0;
	if (count == 0) begin
		clock_out = 1;
	end
end


endmodule