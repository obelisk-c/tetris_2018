module position_decoder(
input [3:0] x_pivot,
input [4:0] y_pivot,
input [2:0] id,
input [1:0] rotation,
output reg [3:0] x1_pos,
output reg [3:0] x2_pos,
output reg [3:0] x3_pos,
output reg [3:0] x4_pos,
output reg [4:0] y1_pos,
output reg [4:0] y2_pos,
output reg [4:0] y3_pos,
output reg [4:0] y4_pos);

always @(*) begin
	// default values
	x1_pos <= x_pivot;
	x2_pos <= x_pivot;
	x3_pos <= x_pivot;
	x4_pos <= x_pivot;
	y1_pos <= y_pivot;
	y2_pos <= y_pivot;
	y3_pos <= y_pivot;
	y4_pos <= y_pivot;
	if (id == 0) begin  // O
		x2_pos <= x_pivot - 1;
		x3_pos <= x_pivot - 1;
		y3_pos <= y_pivot + 1;
		y4_pos <= y_pivot + 1;
	end else if (id == 1) begin  // T
		if (rotation == 0) begin
		x2_pos <= x_pivot - 1;
		x3_pos <= x_pivot + 1;
		y4_pos <= y_pivot + 1;
		end
		else if (rotation == 1) begin
		x2_pos <= x_pivot - 1;
		y3_pos <= y_pivot + 1;
		y4_pos <= y_pivot - 1;
		end
		else if (rotation == 2) begin
		x2_pos <= x_pivot - 1;
		x3_pos <= x_pivot + 1;
		y4_pos <= y_pivot - 1;
		end
		else if (rotation == 3) begin
		y2_pos <= y_pivot - 1;
		y3_pos <= y_pivot + 1;
		x4_pos <= x_pivot + 1;
		end
	end else if (id == 2) begin  // S
		if (rotation == 0) begin
		x2_pos <= x_pivot + 1;
		x3_pos <= x_pivot - 1;
		y3_pos <= y_pivot + 1;
		y4_pos <= y_pivot + 1;
		end
		else if (rotation == 1) begin
		y2_pos <= y_pivot + 1;
		x3_pos <= x_pivot - 1;
		x4_pos <= x_pivot - 1;
		y4_pos <= y_pivot - 1;
		end
	end else if (id == 3) begin  // Z
		if (rotation == 0) begin
		x2_pos <= x_pivot - 1;
		y3_pos <= y_pivot + 1;
		x4_pos <= x_pivot + 1;
		y4_pos <= y_pivot + 1;
		end
		else if (rotation == 1) begin
		x2_pos <= x_pivot - 1;
		y3_pos <= y_pivot - 1;
		x4_pos <= x_pivot - 1;
		y4_pos <= y_pivot + 1;
		end
	end else if (id == 4) begin  // L
		if (rotation == 0) begin
		x2_pos <= x_pivot + 1;
		x3_pos <= x_pivot - 1;
		x4_pos <= x_pivot - 1;
		y4_pos <= y_pivot + 1;
		end
		else if (rotation == 1) begin
		y2_pos <= y_pivot + 1;
		y3_pos <= y_pivot - 1;
		x4_pos <= x_pivot - 1;
		y4_pos <= y_pivot - 1;
		end
		else if (rotation == 2) begin
		x2_pos <= x_pivot + 1;
		x3_pos <= x_pivot - 1;
		x4_pos <= x_pivot + 1;
		y4_pos <= y_pivot - 1;
		end
		else if (rotation == 3) begin
		y2_pos <= y_pivot + 1;
		y3_pos <= y_pivot - 1;
		x4_pos <= x_pivot + 1;
		y4_pos <= y_pivot + 1;
		end
	end else if (id == 5) begin  // J
		if (rotation == 0) begin
		x2_pos <= x_pivot - 1;
		x3_pos <= x_pivot + 1;
		x4_pos <= x_pivot + 1;
		y4_pos <= y_pivot + 1;
		end
		else if (rotation == 1) begin
		y2_pos <= y_pivot - 1;
		y3_pos <= y_pivot + 1;
		x4_pos <= x_pivot - 1;
		y4_pos <= y_pivot + 1;
		end
		else if (rotation == 2) begin
		x2_pos <= x_pivot - 1;
		x3_pos <= x_pivot + 1;
		x4_pos <= x_pivot - 1;
		y4_pos <= y_pivot - 1;
		end
		else if (rotation == 3) begin
		y2_pos <= y_pivot - 1;
		y3_pos <= y_pivot + 1;
		x4_pos <= x_pivot + 1;
		y4_pos <= y_pivot - 1;
		end
	end else begin  //  I TODO: rotation 1
		if (rotation == 0) begin
		x2_pos <= x_pivot - 1;
		x3_pos <= x_pivot - 2;
		x4_pos <= x_pivot + 1;
		end
		else if (rotation == 1) begin
		y2_pos <= y_pivot - 1;
		y3_pos <= y_pivot + 1;
		y4_pos <= y_pivot + 2;
		end
	end
end
endmodule
