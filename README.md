![Logo](http://i.imgur.com/ykW0juV.png?1)
# _MNA-MAT_
A SPICE netlist simulation tool for MATLAB

## MNA-MAT in action
The netlist file being simulated is __example8.cir__ (included in this repository) using Standard analysis. As it is an RC circuit, the simulation type used is __Transient analysis__.

![alt tag](https://github.com/nik1106/MNA-MAT/blob/master/Schematics/example8.png)

![increment](http://imgur.com/OHJG8eu.gif)

## About MNA-MAT
MNA-MAT is a simulation tool designed in MATLAB for solving circuits described as SPICE netlists. It uses the algorithm of Modified Nodal Analysis (MNA). It accepts a file (.cir or .txt) with the SPICE netlist description of the circuit to be simulated. As of now, MNA-MAT supports the following circuit elements :-
- Resistors (R)
- Capacitors (C)
- Independent voltage sources (V)
- Independent current sources (I)
- Voltage controlled voltage sources (VCVS) (E)
- Voltage controlled current sources (VCCS) (I)

MNA-MAT supports the following simulation types as of present :-
* DC bias point (for purely resistive circuits)
* Transient analysis (for capacitive or RC circuits)
* Monte Carlo analysis (done using one of the above, again based on the type of circuit)

__Note :-__ This tool works only with versions of MATLAB from 2014b onwards.

## Features
1. Easy to use and then analyse results.
2. Accurate (a bunch of circuits were simulated on this tool and then on TopSpice, the results were always identical).
3. Saves the results of the previous run simulation.
4. No installation or initial setup required. You can start using the tool as soon as you download it.
5. No need to add SPICE commands like __.TRAN__ or __.DC__. A text description of the circuit is enough.
6. The written code is flexible - it allows room to make changes and add more features if necessary.

## Directions for use
1. Before you start using the tool, make sure you have read-write permissions in the folder where the tool files are stored. If you aren't sure about this, simply start up MATLAB as Administrator.
2. Place the netlist file (.cir or .txt) you wish to simulate in the folder where the tool files are stored.
3. Run the file Main.m.
4. Simply follow the on-screen instructions.

__Note :-__ It is also possible to run the 2 files - Standard_Analysis.m or MonteCarlo.m, independently. However, just make sure you don't have any figure windows open if you'd like to do this.

## What's included
1. The three MATLAB tool files.
2. A set of 10 examples (.cir SPICE netlists) along with schematics of the same.

## Just a Request
If you find this tool useful, or atleast think it to be ambitious, please consider leaving a star or suggesting changes.

__Thank You__
