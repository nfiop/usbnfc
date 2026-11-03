# STM32H753ZI Nucleo144 board

## Requirements

A 144-connections morpho daughterboard is required for ease of setting
up everything.

Advanced users might be able to locate specific I/O pins and connect
them with soldering iron, but this is not recommended for repeated use.

## Design & Peripherals

The design is quite simple - firmware initializes those 2 peripherals -
- USB 1.1 (Full Speed)
- FMC

A DMA transfer mechanism is established between these peripherals, to
ensure fastest data transfers.

## Compile & Installation

TODO.
