module first_high_index(
input [19:0] rows,
output reg [4:0] index);

	always @(*) begin
		casex(rows)
			20'b0000_0000_0000_0000_0001: index = 5'd0;
			20'b0000_0000_0000_0000_001x: index = 5'd1;
			20'b0000_0000_0000_0000_01xx: index = 5'd2;
			20'b0000_0000_0000_0000_1xxx: index = 5'd3;
			20'b0000_0000_0000_0001_xxxx: index = 5'd4;
			20'b0000_0000_0000_001x_xxxx: index = 5'd5;
			20'b0000_0000_0000_01xx_xxxx: index = 5'd6;
			20'b0000_0000_0000_1xxx_xxxx: index = 5'd7;
			20'b0000_0000_0001_xxxx_xxxx: index = 5'd8;
			20'b0000_0000_001x_xxxx_xxxx: index = 5'd9;
			20'b0000_0000_01xx_xxxx_xxxx: index = 5'd10;
			20'b0000_0000_1xxx_xxxx_xxxx: index = 5'd11;
			20'b0000_0001_xxxx_xxxx_xxxx: index = 5'd12;
			20'b0000_001x_xxxx_xxxx_xxxx: index = 5'd13;
			20'b0000_01xx_xxxx_xxxx_xxxx: index = 5'd14;
			20'b0000_1xxx_xxxx_xxxx_xxxx: index = 5'd15;
			20'b0001_xxxx_xxxx_xxxx_xxxx: index = 5'd16;
			20'b001x_xxxx_xxxx_xxxx_xxxx: index = 5'd17;
			20'b01xx_xxxx_xxxx_xxxx_xxxx: index = 5'd18;
			20'b1xxx_xxxx_xxxx_xxxx_xxxx: index = 5'd19;
			20'b0000_0000_0000_0000_0000: index = 5'd20;  // should never be used
		endcase
	end
endmodule
