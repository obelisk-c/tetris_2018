module tetris(
input clock_on_board,
input start_game,
input resetn,
input key_left,
input key_right,
input key_rotate,
output wire [229:0] flat_board,
output wire [3:0] block1_x, block2_x, block3_x, block4_x,
output wire [4:0] block1_y, block2_y, block3_y, block4_y);

	// An array that contains the status of each location in the board, and whether there is an already dropped
	// block filling that coordinate. Also a flattened array.
	reg [9:0] board_state[0:22];
	assign flat_board = {board_state[22], board_state[21], board_state[20], board_state[19], board_state[18], 
	board_state[17], board_state[16], board_state[15], board_state[14], board_state[13], board_state[12], 
	board_state[11], board_state[10], board_state[9], board_state[8], board_state[7], board_state[6], 
	board_state[5], board_state[4], board_state[3], board_state[2], board_state[1], board_state[0]};
	
	// The x and y positions of the tetromino's central block.
	reg [4:0] y;
	reg [3:0] x;
	
	// Block type and rotation
	reg [2:0]block_type;
	reg [2:0]rotation;
	reg [2:0]rotation_test;
	
	// The x and y positions of the four blocks of the tetromino, if it were rotated. 
	wire [4:0] block1_y_test, block2_y_test, block3_y_test, block4_y_test; 
	wire [3:0] block1_x_test, block2_x_test, block3_x_test, block4_x_test; 

	
	// Used for the for loop to initialize the board.
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
	.load_value(20'd833333),
	//.load_value(20'd3),
	.clock_in(clock_on_board),
	.clock_out(clock_framerate));
	
	// Returns a much slower clock for the rate of the block fall.
	rate_divider r2(
	.resetn(resetn),
	.load_value(20'd30),
	.clock_in(clock_framerate),
	.clock_out(clock_block_fall));

	// Moves the y coordinate of the central block down.
	task move_down(); 
		begin
		   y <= y - 5'd1;
		end
	endtask
	
	// Moves the x coordinate of the central block left.
	task move_left(); 
		begin
		   x <= x - 4'd1;
		end
	endtask
	
	// Moves the x coordinate of the central block right.
	task move_right(); 
		begin
		   x <= x + 4'd1;
		end
	endtask
	
	// Rotates the tetromino clockwise. 
	task rotate();  
		begin 
			rotation <= rotation_test; 
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
	wire rotation_out_of_bounds = (!(block1_y_test >= 0 && block1_y_test < 23)) || (!(block2_y_test >= 0 && block2_y_test < 23)  
	|| !(block3_y_test >= 0 && block3_y_test < 23) || !(block4_y_test >= 0 && block4_y_test < 23)) 
	|| (!(block1_x_test >= 0 && block1_x_test < 10) || !(block2_x_test >= 0 && block2_x_test < 10)  
	|| !(block3_x_test >= 0 && block3_x_test < 10) || !(block4_x_test >= 0 && block4_x_test < 10)); 

	// Whether any of the four blocks that would result from a rotation would be intersecting fallen blocks. 
	wire rotation_intersects_existing = (board_state[block1_y_test][block1_x_test] || board_state[block2_y_test][block2_x_test]  
	|| board_state[block3_y_test][block3_x_test] || board_state[block4_y_test][block4_x_test]); 
	
	// Whether any of the four blocks that would result from a rotation would conflict with boundaries. 
	wire rotation_conflicts = rotation_out_of_bounds || rotation_intersects_existing; 

	
	// Array of lines filled, with each index corresponding to its row.
	wire [19:0] completed_lines = {&board_state[19], &board_state[18], &board_state[17], &board_state[16],
	&board_state[15], &board_state[14], &board_state[13], &board_state[12], &board_state[11], &board_state[10],
	&board_state[9], &board_state[8], &board_state[7], &board_state[6], &board_state[5], &board_state[4],
	&board_state[3], &board_state[2], &board_state[1], &board_state[0]};
	
	wire shift_down;
	wire [4:0] cleared_index;
	wire load_block, drop_block, update_board_state;
	
	control c1(.clock(clock_block_fall),
	.start_game(start_game),
	.resetn(resetn),
	.filled_under(filled_under),
	.completed_lines(completed_lines),
	.load_block(load_block),
	.drop_block(drop_block),
	.update_board_state(update_board_state),
	.shift_down(shift_down));
	
	first_high_index fhi0(
		.rows(completed_lines),
		.index(cleared_index)
		);
		
//	// Next block
//	wire [3:0] rand_out;
//	lfsr_randomizer lfsr0(
//		.clock(clock_on_board),
//		.resetn(resetn),
//		.out(rand_out)
//		);


	reg [2:0]random_id;
	// Counter for randomization
	always@(posedge clock_on_board) begin
		if (random_id != 6) begin
			random_id <= random_id + 1;
		end else begin
			random_id <= 3'd0;
		end
	end
	
	// This sets the rotation_test value at all times. 
	always@(*)begin 
		if (rotation == 3)begin 
			rotation_test = 0; 
		end else begin 
			rotation_test = rotation + 1; 
		end 
	end 

	
	// Game logic.  Effectively datapath.
	reg [3:0] left_counter, right_counter, rotate_counter;
	integer k;
	always@(posedge clock_framerate) begin
		if (!resetn) begin
			x <= 4'd4;
			y <= 5'd19;
			block_type <= 0;
			rotation <= 0;
			left_counter <= 4'b1111;
			right_counter <= 4'b1111;
			rotate_counter <= 4'b1111;
		// Checks if the block is supposed to drop this cycle. Does that if it should.
		end else if (clock_block_fall) begin
			if (load_block) begin
				x <= 4'd4;
				y <= 5'd19;
				block_type <= random_id; // temp value, fix the randomization
				rotation <= 0;
				left_counter <= 4'b1111;
				right_counter <= 4'b1111;
				rotate_counter <= 4'b1111;
			end
			if (drop_block && !filled_under) begin
				move_down();
			end
			if (update_board_state) begin
				update_board();
			end
		// Checks if a row needs to be cleared. Disgusting code courtesy of verilog variable limitations
		end else if (shift_down) begin
			if (cleared_index == 0) begin
				for (k=0; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 1) begin
				for (k=1; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 2) begin
				for (k=2; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 3) begin
				for (k=3; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 4) begin
				for (k=4; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 5) begin
				for (k=5; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 6) begin
				for (k=6; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 7) begin
				for (k=7; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 8) begin
				for (k=8; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 9) begin
				for (k=9; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 10) begin
				for (k=10; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 11) begin
				for (k=11; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 12) begin
				for (k=12; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 13) begin
				for (k=13; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 14) begin
				for (k=14; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 15) begin
				for (k=15; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 16) begin
				for (k=16; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 17) begin
				for (k=17; k<19; k=k+1) begin
					board_state[k] <= board_state[k+1];
				end
			end else if (cleared_index == 18) begin
				board_state[18] <= board_state[19];
			end
			board_state[19] <= 10'd0;
		// Checks if the user wants to move to the left.
		end else if (key_left && !filled_left && left_counter == 4'd15) begin
			left_counter <= 0;
			move_left();
		// Checks if the user wants to move to the right.
		end else if (key_right && !filled_right && right_counter == 4'd15) begin
			right_counter <= 0;
			move_right();
		end else if (key_rotate && rotate_counter == 4'd15 && !rotation_conflicts) begin 
			rotate_counter <= 0;
			rotate(); 
		end
		
		if (left_counter != 4'd15) begin
			left_counter <= left_counter + 1;
		end
		if (right_counter != 4'd15) begin
			right_counter <= right_counter + 1;
		end
		if (rotate_counter != 4'd15) begin
			rotate_counter <= rotate_counter + 1;
		end
	end
endmodule
