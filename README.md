# Basys3 Poker Game

Welcome to the Basys3 Poker Game repository! This project aims to implement a simplified version of Texas Hold'em Poker using the Basys3 FPGA development board.

## Overview

The Basys3 Poker Game is a hardware implementation of the popular card game Texas Hold'em. It provides an interactive gaming experience using the Basys3 FPGA platform, allowing players to compete against each other in a virtual poker tournament.

## Features

- Support for up to two players
- Simplified Texas Hold'em gameplay
- Interactive user interface using LEDs and push buttons
- Real-time game state updates
- Basic hand evaluation and winner determination

## Limitations on Multiplayer Support

While our initial vision for the Basys3 Poker Game included support for more than two players, we encountered significant challenges when attempting to expand the game beyond this limitation. The primary obstacle we faced was the inherent size limitations and restrictions of Verilog, the hardware description language (HDL) used for programming the Basys3 FPGA module.

### Technical Explanation

Verilog imposes constraints on the size of hardware designs, including the number of logic gates, flip-flops, and memory elements that can be utilized. As we attempted to add support for additional players, we found that the complexity of the game logic increased exponentially, resulting in a significant expansion of the hardware design.

The addition of more players required the incorporation of additional if statement blocks, conditional logic, and memory elements to manage the game state and player interactions. However, as we approached the upper limits of the available hardware resources on the Basys3 FPGA, we encountered compilation errors and synthesis failures.

Verilog compilers and synthesis tools struggled to optimize the increasingly complex design, leading to excessive resource utilization, timing violations, and ultimately, failure to meet the project requirements. Despite our efforts to optimize the code and streamline the design, we were unable to overcome these limitations without sacrificing critical features and functionality.

### Decision to Limit Players

In light of these challenges, we made the strategic decision to limit the Basys3 Poker Game to support a maximum of two players. By focusing our efforts on optimizing the gameplay experience for a smaller player count, we were able to ensure the stability, performance, and reliability of the game within the constraints of the available hardware resources.

While we acknowledge that expanding multiplayer support would enhance the social dynamics and competitiveness of the game, we prioritized the quality and integrity of the gameplay experience over sheer player count. By maintaining a laser focus on the core features and functionality, we were able to deliver a polished and enjoyable gaming experience for our users.

Moving forward, we remain committed to exploring potential avenues for scalability and optimization, with the ultimate goal of enhancing the Basys3 Poker Game and unlocking new possibilities for multiplayer engagement on FPGA platforms.

## Resources

- [Texas Hold'em Poker Rules](https://www.pokerlistings.com/poker-rules-texas-holdem) - Learn the rules of Texas Hold'em Poker to understand the gameplay mechanics.
- [Verilog Documentation](https://verilog.com/) - Explore the official Verilog documentation to deepen your understanding of the hardware description language.
- [Basys3 Documentation](https://reference.digilentinc.com/reference/programmable-logic/basys-3/start) - Access the Basys3 documentation to learn more about the FPGA development board used for this project.
