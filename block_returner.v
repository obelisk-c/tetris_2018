
// This module takes a tetromino type, rotation, and the coordinates of its central block to return 
// the coordinates of each of its four blocks.

module block_returner (
input [4:0]y,
input [3:0]x,
output wire[4:0]y1,
output wire[3:0]x1,
output wire[4:0]y2,
output wire[3:0]x2,
output wire[4:0]y3,
output wire[3:0]x3,
output wire[4:0]y4,
output wire[3:0]x4);

	// block 1
	assign y1 = y;
	assign x1 = x;
	 
	// block 2 top
	assign y2 = y + 1;
	assign x2 = x;
	
	// block 3 top right
	assign y3 = y + 1;
	assign x3 = x + 1;
	
	// block 4 right
	assign y4 = y;
	assign x4 = x + 1; 
 
endmodule