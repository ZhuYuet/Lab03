# 8051 Calculator V9 — Project 08 Animated Titles

Project 08 uses the supplied `CALCULATE V9` and `DISPLAY V9` sources as its
baseline. It preserves the V9 calculator, UART, backspace, advanced operations,
and credits trigger while adding rightward LCD animations.

## Firmware

| Controller | Source | Program this HEX |
|---|---|---|
| Process, keypad, and ALU | `CALCULATE V9.asm` | `CALCULATE V9.hex` |
| LCD and presentation | `DISPLAY V9.asm` | `DISPLAY V9.hex` |

Both files target an AT89C52 using an 11.0592 MHz oscillator and 9600-baud UART.

## Added animations

### Mode titles

After selecting Arithmetic, Logical, or Advance mode, its title continuously
scrolls to the right on LCD line 2:

- `ARITHMETIC`
- `LOGIC: 0/1 ONLY`
- `ADVANCE MODE`

Equation entry remains on line 1. The display temporarily hides the cursor
during each line-2 redraw and restores it to the tracked equation position.
Results and errors replace the marquee; Clear restarts it.

### Developer credits

The V9 credits trigger remains Advance-mode key `D`. LCD line 1 displays
`DEVELOPED BY:` while each developer name scrolls right on line 2. After one
complete 16-frame rotation, the next name begins:

1. Daniel Chee
2. Goh Shao Sean
3. Tan E-Ken
4. Then Mun Pin

Each developer name moves right once until it has completely disappeared beyond
the LCD edge. It does not wrap around or re-enter from the left. The next name
then begins. After the fourth name disappears, the complete four-name sequence
starts again from the first developer. A received keypad event exits the
credits sequence and returns to the active mode.

## Connections

### Process controller

- Keypad: `P1.0–P1.7`
- Backspace button: `P2.0`, active low
- UART TX to display RX: `P3.1/TXD → P3.0/RXD`
- UART RX from display TX: `P3.0/RXD ← P3.1/TXD`

### Display controller

- LCD data `D0–D7`: `P1.0–P1.7`
- LCD `RS`, `RW`, `EN`: `P2.0`, `P2.1`, `P2.2`
- UART RX from process TX: `P3.0/RXD`
- UART TX/ACK to process RX: `P3.1/TXD`

Both controllers and the LCD must share ground. Connect LCD `VEE` to a contrast
potentiometer, or directly to ground for a quick Proteus test.

## Build verification

Both sources were assembled with ASEM-51 V1.3 with zero errors. Their Intel HEX
files have matching `.lst` listings and fit within the AT89C52's 8 KB program
memory.
