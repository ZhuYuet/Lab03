# UGEA2633 Lab 3 - Serial Communication and Interrupts

This folder contains starting-point programs and a completion guide for the two
experiments. The source is written for Keil A51 and an AT89S52 using an
11.0592 MHz crystal. Both programs transmit `TRANSMIT OK!` at 9600 baud, 8 data
bits, no parity, and 1 stop bit.

The supplied `.LST` and `.hex` files were generated with Keil A51/BL51/OH51.
Both targets assembled and linked with 0 warnings and 0 errors.

## What you must submit

Fill the provided seven-page submission sheet with:

1. Experiment A assembly program.
2. Experiment A results and suitable Keil simulator screenshots.
3. Experiment B assembly program.
4. Experiment B results and suitable Keil simulator screenshots.
5. Experiment A circuit diagram.
6. Every group member's name and student ID on each requested page.

Also construct the Experiment A circuit from the approved equipment. The lab
sheet says hardware testing is not required.

## Program design

### Experiment A - polling

Use `Experiment_A_Polling.asm`.

- Timer 1 runs in mode 2 with `TH1 = TL1 = FDH`.
- `SCON = 50H` selects UART mode 1 and enables reception.
- Each byte is written to `SBUF`.
- The program waits for `TI = 1`, clears `TI`, and sends the next byte.
- After the terminating zero byte, the program remains in an idle loop.

### Experiment B - serial interrupt

Use `Experiment_B_Interrupt.asm`.

- The interrupt vector at `0023H` jumps to `SERIAL_ISR`.
- `ES` and `EA` enable the serial and global interrupts.
- The ISR clears `TI`, obtains the next code-memory character, and writes it to
  `SBUF`.
- The main loop independently increments `P1`, demonstrating that foreground
  work continues while the UART transmission is interrupt-driven.
- The ISR checks both `RI` and `TI` because they share one interrupt vector.

## Create and run each Keil project

Create separate projects for A and B so there is only one startup/source entry
point in each target.

1. Open Keil uVision and choose **Project > New uVision Project**.
2. Select **Atmel AT89S52** as the device. If Keil asks to copy `STARTUP.A51`,
   choose **No** because these files already contain the reset vector.
3. Add the matching `.asm` file to **Source Group 1**.
4. In **Options for Target > Target**, set the oscillator frequency to
   **11.0592 MHz**.
5. Build the target and require **0 errors**. Warnings should also be reviewed.
6. In **Options for Target > Debug**, select **Use Simulator**.
7. Start the debug session, open **View > Serial Windows > UART #1**, and run.

If your Keil installation labels the serial window as `Serial #1`, use that
equivalent window.

## Simulator evidence to capture

### Experiment A

Capture a screenshot that clearly shows:

- the source file or project name;
- the UART/Serial #1 window containing `TRANSMIT OK!`;
- the successful build result with zero errors; and
- optionally the key registers `SCON = 50H`, `TH1 = FDH`, `TR1 = 1`.

Suggested observation:

> The serial window displayed `TRANSMIT OK!`. Timer 1 mode 2 generated 9600
> baud from the 11.0592 MHz clock. The program polled TI after every byte and
> cleared TI before sending the next character.

### Experiment B

Open the UART window plus the SFR/Port view for `P1`. If useful, put a
breakpoint on `SERIAL_ISR` and single-step once to show execution through the
serial vector.

Capture evidence that shows:

- the UART/Serial #1 window containing `TRANSMIT OK!`;
- the successful build result with zero errors;
- `ES = 1` and `EA = 1` while transmission is active; and
- `P1` changing in the main loop while the ISR sends the string.

Suggested observation:

> The serial interrupt at vector 0023H transmitted the message one character
> per TI event. At the same time, the main loop continued changing Port 1,
> proving that the foreground program did not poll or block on the UART.

## Experiment A circuit wiring

Use a regulated +5 V supply and join all grounds.

### AT89S52 minimum circuit

- Pin 40 `VCC` to +5 V; pin 20 `GND` to ground.
- Pin 31 `EA/VPP` to +5 V so the MCU executes internal program memory.
- 11.0592 MHz crystal between pins 18 (`XTAL2`) and 19 (`XTAL1`).
- One 33 pF capacitor from pin 18 to ground and one 33 pF capacitor from pin 19
  to ground.
- Reset pin 9: 8.2 kohm to ground, 10 uF capacitor to +5 V, and push button from
  reset to +5 V. Observe electrolytic capacitor polarity.

### MAX232 and serial connector

- MAX232 pin 16 to +5 V and pin 15 to ground.
- MCU pin 11 `P3.1/TXD` to MAX232 pin 11 `T1IN`.
- MAX232 pin 14 `T1OUT` to DB-9 pin 2 (PC receive data).
- Optional receive path: DB-9 pin 3 to MAX232 pin 13 `R1IN`, then MAX232 pin 12
  `R1OUT` to MCU pin 10 `P3.0/RXD`.
- DB-9 pin 5 to circuit ground.
- For a classic MAX232 using 10 uF electrolytics: capacitor `C1` between pins
  1 (`C1+`) and 3 (`C1-`), positive at pin 1; capacitor `C2` between pins 4
  (`C2+`) and 5 (`C2-`), positive at pin 4; capacitor `C3` from pin 2 (`V+`) to
  ground, positive at pin 2; and capacitor `C4` from pin 6 (`V-`) to ground,
  positive at ground. Confirm these values and polarities against the exact
  datasheet for your MAX232 revision before powering the circuit.

Confirm whether the laboratory cable is straight-through or null-modem before
drawing the final DB-9/DB-25 endpoint. The MCU TX path must end at the receiving
pin of the PC or terminal device.

For a common straight-through DB-9-to-DB-25 cable, verify continuity before use:
DB-9 pin 2 normally maps to DB-25 pin 3 (receive), DB-9 pin 3 to DB-25 pin 2
(transmit), and DB-9 pin 5 to DB-25 pin 7 (signal ground).

## Circuit diagram checklist

Your final diagram should label:

- +5 V and common ground;
- AT89S52 pin numbers and signal names;
- crystal and both 33 pF capacitors;
- reset resistor, capacitor, and push button;
- MAX232 power, charge-pump capacitors, and TX signal path;
- DB-9/DB-25 pin numbers used by the actual cable; and
- UART settings: 9600 baud, 8-N-1, 11.0592 MHz.

Before submission, compare the finished diagram against the physical
breadboard one wire at a time.
