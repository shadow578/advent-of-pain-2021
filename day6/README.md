# Day 6: 6502 Assembly

On day one, i started _with_ scratch. For day 6, i went a bit further and started _from_ scratch: with [the 6502](https://en.wikipedia.org/wiki/MOS_Technology_6502). <br>
The 6502 is a 8 bit microprocessor with a 8 bit data and 16 bit address bus. It could address up to 64K of memory, and ran at about 1-3 MHz. <br>
Pretty impressive for a processor that launched ~46 years ago, itn't it? <br>

While you may have never heard of the 6502 itself, you surely have heard from one of the system it powered, like the [Apple II](https://en.wikipedia.org/wiki/Apple_II), [Commodore 64](https://en.wikipedia.org/wiki/Commodore_64), and the classic [NES](https://en.wikipedia.org/wiki/Nintendo_Entertainment_System).<br>

Now, we're not running on any of those systems, but on a bare (virtual) 6502 with only RAM attached (the program is loaded into RAM before running). <br>
Since we lack any sort of input or output, the puzzle input is embedded into the program. <br>
The puzzle answer is only written to RAM, without anything like a screen (we don't have any). <br>


## Versions

There are two versions of the puzzle: a 16 bit and 64 bit version. <br>
16 and 64 bit doesn't refer to the processor architecture, but instead to the size of the variables used to keep track of the fish population. <br>
If you want to read into the source code, i'd suggest starting with the 16 bit version (as it's quite a bit easier to read). <br>
For actually calculating the puzzle answer, you'll have to use the 64 bit version.

## Running

To run the code, copy- paste the contents of any of the source files into the [virtual 6502 assembler](https://www.masswerk.at/6502/assembler.html) and hit 'Assemble'. <br>
Once it finished assembling, hit 'Show in Emulator' to load the code into the RAM of the emulator. <br>
On the emulator, start running the code using the 'Continuous Run' option. <br>
After a while, the CPU will halt and you can look up the result of the computation at RAM adress $0200.


## Note on Speed

The emulator of the virtual 6502 website does run kinda slow... <br>
If you want to know how long the code would run on a real 6502, you can take the 'total cycles' displayed by the virtual 6502 and divide them by the clock frequency in Hz (1.000.000 for 1MHz).
This gives you an estimate on how long it would actually take to run (btw. for the answer to puzzle 2, it's about 1 second).

---

Second note: it was actually harder for me to find a emulator + assembler that fit my requirements than to actually write the code...
