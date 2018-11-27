module lfsr_randomizer(
input clock,
input resetn,
output reg [3:0] out);

	always @(clock) begin
		if (!resetn) begin
			out <= 4'b1111;
		end else begin
			out <= {out[2:0], out[2] ^ out[3]};
		end
	end
endmodule
