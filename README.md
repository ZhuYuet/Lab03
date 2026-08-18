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

## Backspace behavior

- After `=` is accepted, backspace performs the existing Clear action. It
  clears the completed equation/result and returns to the selected mode's empty
  input screen with the LCD and cursor enabled.
- When a previous result is reused as `ANS`, the process controller sends one
  dedicated token-delete request. The display removes all of `ANS` atomically
  instead of treating `S`, `N`, and `A` as separate characters.
- Deleting the operator in `ANS+` stops exactly after `+`; an ANS boundary guard
  prevents a stale two-character operator width from also deleting `S`.
- The display cursor is prevented from moving before LCD line 1, so deleting an
  operand cannot wrap around and overwrite `ANS` or another LCD position.
- After the complete `ANS` token is deleted, both the tracked cursor and the
  physical LCD DDRAM cursor return to the first position of line 1.
- In logical mode, every backspace recalculates whether the new final character
  is an operator. Consequently, changing an operator after deletion replaces
  the operator and never overwrites the `S` in `ANS`.
- Backspace reports whether it exposed or removed an operator. This keeps the
  replacement state correct in both arithmetic and logical modes, so changing
  an operator after `ANS+` cannot overwrite the `S`.
- If deletion leaves an incomplete expression such as `ANS-`, `=` is ignored
  until a new second operand is entered.
- If the operator is also deleted and only `ANS` remains, number keys are
  ignored until a new operator is inserted; numbers are never appended directly
  to form an invalid expression such as `ANS5`.

## Division result format

Division results use `R` to separate the quotient and remainder. Fractions and
the custom fraction glyph are no longer used:

```text
1/2=0R1
4/2=2R0
```

The process controller sends only the sign, quotient, and remainder for a
division result. The display controller right-aligns the resulting `qRr` text
on LCD line 2.

## DEL power control

The calculator starts in software-off mode with the LCD blank. DEL controls
power while no calculator mode is active:

1. After reset, press DEL once to turn the calculator on, show `READY`, and open
   the mode-selection menu.
2. At the mode-selection menu, press DEL to turn the display off. While off,
   the process controller ignores every key except DEL.
3. Press DEL again to restart the calculator and return to mode selection.

DEL continues to act as backspace or post-result Clear while a calculator mode
is active.

## Added animations

### Mode titles

After selecting Arithmetic, Logical, or Advance mode, its title continuously
scrolls to the right on LCD line 2:

- `ARITHMETIC`
- `8bit-LOGIC`
- `ADVANCE MODE`

Equation entry remains on line 1. The display temporarily hides the cursor
during each line-2 redraw and restores it to the tracked equation position.
Results and errors replace the marquee; Clear restarts it.

### Developer credits

The V9 credits trigger remains Advance-mode key `D`. LCD line 1 displays
`DEVELOPED BY:` while all four names form one continuous right-moving credit
line on LCD line 2:

1. Daniel Chee
2. Goh Shao Sean
3. Tan E-Ken
4. Then Mun Pin

The first frame starts with `DANIEL CHEE` centered. The names are separated by
eight blank spaces without separator symbols. The line continues through all
four developers and then loops. A received keypad event exits the credits
sequence and returns to the active mode.

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

Both restored targets were assembled with ASEM-51 V1.3 with zero errors. The
generated firmware fits the AT89C52's 8 KB Flash memory:

| Target | Code size | Highest code address |
|---|---:|---:|
| Process | 1,879 bytes | `0756H` |
| Display | 2,264 bytes | `08D7H` |

The process and display HEX files use the same UART protocol, including the
remainder-result packet and atomic `ANS` deletion request. Always program both
updated HEX files together.
