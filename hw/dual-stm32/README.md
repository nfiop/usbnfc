# dual-stm32 - USB NAND flash controller based on dual STM32 model

A custom printed circuit board which contains two MCUs - one as the USB
(master) controller and a (slave) controller connected to a NAND flash
chip.

## Design

There are 2 STM32 MCUs:
- The first STM32 MCU (called "master") is handling the connection to a
  USB host via USB3300 PHY. It fetches commands, parse them and actually
  communicate them to the slave MCU via an SPI link.

- The second STM32 MCU (called "slave") is handling the connection to a
  NAND flash chip.
  It gets its commands via the SPI link from the master and answers
  accordingly.

The master MCU controls the slave MCU completely - also in terms of the
VDDIO voltage level - the master configures the appropriate voltage and
ensures a proper power up and power down sequences of the slave MCU when
required.

The SPI link passes through a voltage translation so we keep the two
voltage domains - the master voltage domain and the slave voltage domain
completely separated.

In addition to that, to make processing more efficient and prevent any
excessive polling on the SPI bus, we have 3 inputs from the slave to
the master (IRQ,READY,ERR signals) and a RESET to reset the slave MCU
immediately.
