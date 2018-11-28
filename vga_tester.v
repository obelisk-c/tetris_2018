module vga_tester(
input [206:0]board_flattened);
  wire [9:0] board_state[0:22];

  assign {board_state[0], board_state[1], board_state[2], board_state[3], board_state[4],
	board_state[5], board_state[6], board_state[7], board_state[8], board_state[9], board_state[10], board_state[11],
	board_state[12], board_state[13], board_state[14], board_state[15], board_state[16], board_state[17], board_state[18],
	board_state[19], board_state[20], board_state[21], board_state[22]} = board_flattened;
endmodule