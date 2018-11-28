module tetris(
input clock_on_board,
input start_game,
input resetn,
input key_left,
input key_right,
input key_rotate,
output wire [229:0] board_flattened,
output wire [3:0] block1_x, block2_x, block3_x, block4_x,
output wire [4:0] block1_y, block2_y, block3_y, block4_y);

	// An array that contains the status of each location in the board, and whether there is an already dropped
	// block filling that coordinate.
	reg [9:0] board_state[0:22];
	// wire [229:0] board_flattened;
	
	// The location at which to load the central block.
	wire [3:0]LOAD_X;
	wire [4:0]LOAD_Y;
	assign LOAD_X = 4'd4;
	assign LOAD_Y = 5'd19;
	
	// The block type and rotation state.
	reg [2:0]block_type;
	reg [2:0]rotation;
	reg [2:0]rotation_test;
	
	// The x and y positions of the four blocks of the tetromino.
	// wire [4:0] block1_y, block2_y, block3_y, block4_y;
	// wire [3:0] block1_x, block2_x, block3_x, block4_x;
	
	// The x and y positions of the four blocks of the tetromino, if it were rotated.
	wire [4:0] block1_y_test, block2_y_test, block3_y_test, block4_y_test;
	wire [3:0] block1_x_test, block2_x_test, block3_x_test, block4_x_test;
	
	// The x and y positions of the tetromino's central block.
	reg [4:0] y;
	reg [3:0] x;
	
	// Used for the for loops.
	integer i, j;
	
	// The clocks used in the game.
	wire clock_framerate, clock_block_fall;
	
	
	// Initializes the board.
	initial begin
		for (i=0; i<23; i=i+1) begin
			for (j=0; j<10; j=j+1) begin
				board_state[i][j] <= 0;
			end 
		end
	end
	
	// Returns the four blocks of the current tetromino.
	block_returner b1(
	.x(x),
	.y(y),
	.block_type(block_type),
	.rotation(rotation),
	.x1(block1_x),
	.y1(block1_y),
	.x2(block2_x),
	.y2(block2_y),
	.x3(block3_x),
	.y3(block3_y),
	.x4(block4_x),
	.y4(block4_y));
	
	// Returns the four blocks of the next rotation
	block_returner b2(
	.x(x),
	.y(y),
	.block_type(block_type),
	.rotation(rotation_test),
	.x1(block1_x_test),
	.y1(block1_y_test),
	.x2(block2_x_test),
	.y2(block2_y_test),
	.x3(block3_x_test),
	.y3(block3_y_test),
	.x4(block4_x_test),
	.y4(block4_y_test));
	
	// Returns a 60Hz (approximately) clock.
	rate_divider r1(
	.resetn(resetn),
	//.load_value(20'd833333),
	.load_value(20'd3),
	.clock_in(clock_on_board),
	.clock_out(clock_framerate));
	
	// Returns a much slower clock for the rate of the block fall.
	rate_divider r2(
	.resetn(resetn),
	//.load_value(some arbitrary number),
	.load_value(20'd2),
	.clock_in(clock_framerate),
	.clock_out(clock_block_fall));

	// Moves the y coordinate of the central block down.
	task move_down(); 
		begin
		   y <= y - 1;
		end
	endtask
	
	// Moves the x coordinate of the central block left.
	task move_left(); 
		begin
		   x <= x - 1;
		end
	endtask
	
	// Moves the x coordinate of the central block right.
	task move_right(); 
		begin
		   x <= x + 1;
		end
	endtask
	
	// Rotates the tetromino clockwise.
	task rotate(); 
		begin
			rotation = rotation_test;
		end
	endtask
	
	// Fills in the board state with the current coordinates of the four blocks.
	task update_board();
		begin
			board_state[block1_y][block1_x] <= 1;
			board_state[block2_y][block2_x] <= 1;
			board_state[block3_y][block3_x] <= 1;
			board_state[block4_y][block4_x] <= 1;
			
		end
	endtask
	
	// Whether any of the four blocks have an already dropped block under them or are at the bottom row.
	wire filled_under = (block1_y == 0 || block2_y == 0 || block3_y == 0 || block4_y == 0) || 
	(board_state[block1_y - 1][block1_x] || board_state[block2_y - 1][block2_x] 
   || board_state[block3_y - 1][block3_x] || board_state[block4_y - 1][block4_x]);
	
	// Whether any of the four blocks have an already dropped block to the left of them or are at the leftmost row.
	wire filled_left = (block1_x == 0 || block2_x == 0 || block3_x == 0 || block4_x == 0) || 
	(board_state[block1_y][block1_x - 1] || board_state[block2_y][block2_x - 1] 
	|| board_state[block3_y][block3_x - 1] || board_state[block4_y][block4_x - 1]);
	
	// Whether any of the four blocks have an already dropped block under them or are at the bottom row.
	wire filled_right = (block1_x == 9 || block2_x == 9 || block3_x == 9 || block4_x == 9) || 
	(board_state[block1_y][block1_x + 1] || board_state[block2_y][block2_x + 1] 
	|| board_state[block3_y][block3_x + 1] || board_state[block4_y][block4_x + 1]);
	
	// Whether any of the four blocks that would result from a rotation would be out of bounds.
	wire rotation_out_of_bounds = (!(block1_y_test >= 0 && block1_y_test < 23)) || ((block2_y_test >= 0 && block2_y_test < 23) 
	|| !(block3_y_test >= 0 && block3_y_test < 23) || !(block4_y_test >= 0 && block4_y_test < 23))
	|| (!(block1_x_test >= 0 && block1_x_test < 10)) || ((block2_x_test >= 0 && block2_x_test < 10) 
	|| !(block3_x_test >= 0 && block3_x_test < 10) || !(block4_x_test >= 0 && block4_x_test < 10));
	
	// Whether any of the four blocks that would result from a rotation would be intersecting fallen blocks.
	wire rotation_intersects_existing = (board_state[block1_y_test][block1_x_test] || board_state[block2_y_test][block2_x_test] 
	|| board_state[block3_y_test][block3_x_test] || board_state[block4_y_test][block4_x_test]);
	
	// Whether any of the four blocks that would result from a rotation would conflict with boundaries.
	wire rotation_conflicts = rotation_out_of_bounds || rotation_intersects_existing;
	
	reg load_block, drop_block, update_board_state;
	control c1(.clock(clock_block_fall),
	.start_game(start_game),
	.resetn(resetn),
	.filled_under(filled_under),
	.load_block(load_block),
	.drop_block(drop_block),
	.update_board_state(update_board_state));
	
	// Continually generate a random block.
	wire [3:0] rand_id;
	lfsr_randomizer lfsr0(
		.clock(clock_on_board),
		.resetn(resetn),
		.out(rand_id)
		);
	
	assign board_flattened = {board_state[22], board_state[21], board_state[20], board_state[19],
	board_state[18], board_state[17], board_state[16], board_state[15], board_state[14], board_state[13], board_state[12],
	board_state[11], board_state[10], board_state[9], board_state[8], board_state[7], board_state[6], board_state[5],
	board_state[4], board_state[3], board_state[2], board_state[1], board_state[0]};
	
	
	// This sets the rotation_test value at all times.
	always@(*)begin
		if (rotation == 3)begin
			rotation_test = 0;
		end else begin
			rotation_test = rotation + 1;
		end
	end
	
	// Game logic.  Effectively datapath.
	always@(posedge clock_framerate) begin
		if (!resetn) begin
			y <= LOAD_Y;
			x <= LOAD_X;
			block_type <= 3'd0;
			rotation <= 3'd0;
		// Checks if the block is supposed to drop this cycle. Does that if it should.
		end else if (clock_block_fall) begin
			if (load_block) begin
				x <= LOAD_X;
				y <= LOAD_Y;
				block_type <= rand_id[2:0];
				rotation <= 3'd0;
			end
			if (drop_block && !filled_under) begin
				move_down();
			end
			if (update_board_state) begin
				update_board();
			end
		// Checks if the user wants to move to the left.
		end else if (key_left && !filled_left) begin
			move_left();
		// Checks if the user wants to move to the right.
		end else if (key_right && !filled_right) begin
			move_right();
		end else if (key_rotate && !rotation_conflicts) begin
			rotate();
		end
	end
endmodule

