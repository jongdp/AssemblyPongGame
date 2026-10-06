# ARM32 Pong

Single-player Pong written in ARM32 assembly for the DE1-SoC board. Every pixel is written directly to memory-mapped video buffers, with no graphics library, standard library, or operating system. It runs in the browser through the CPUlator simulator.

## Highlights

- **Direct hardware access.** Draws to the 320×240, 16-bit-color VGA pixel buffer and the 80×60 character buffer through memory-mapped I/O.
- **Sprite blitter.** Centers, clips, and draws pixel maps, skipping each sprite's transparent color.
- **Hardware input.** Reads the board's push buttons through a memory-mapped register.
- **Text and numbers without a library.** Renders strings and signed integers with no standard library and no hardware divide instruction.
- **Structured game state.** Ball and paddle state live in packed structs accessed by field offsets, and every subroutine follows ARM calling conventions.

## How to play

1. Open CPUlator for the DE1-SoC: https://cpulator.01xz.net/?sys=arm-de1soc
2. Paste the contents of `pong.s` into the editor.
3. Click **Compile and Load**, then **Continue**.
4. The ball bounces vertically, and the paddle slides along the bottom on its own. Press push button **KEY0** in the Devices panel to reverse the paddle's direction. Miss the ball and the game ends with "Game Over!"