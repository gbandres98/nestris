# NEStris

<img width="594" height="613" alt="Screenshot 2025-07-29 142324" src="https://github.com/user-attachments/assets/f38a6505-e1fe-4bc9-835c-cf83a3eed821" />

## My own implementation of NES tetris

### Why?

I wanted to practice my assembly skills and thought it would be fun to learn how the NES and its 6502 CPU work.

This code is the result of my learning process and I don't recommend anyone to take it as an example of how to properly write NES games! There's bad patterns and inconsistencies everywhere, as my understanding of the platform evolved during the 2 months it took to build this. I avoided looking at other NES code so I could go through the problem solving process myself, so I'm sure there's more elegant solutions for everything.

### How to play the game

You can download to game ROM from github releases and play it on any NES emulator. I recommend [Mesen](https://www.mesen.ca/).

- Left/Right: Move piece
- A/B: Rotate piece
- Down: Drop piece
- Up: Store piece

### How to build the ROM

If you want to play around with the code and build a new ROM, you'll need to install [cc65](https://cc65.github.io/).

With cc65 installed and in your path, you can run the `./build.ps1` script on Windows, or run equivalent instructions on Linux.
