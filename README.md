# 🏋️‍♂️ 2D Squat Simulator

A MATLAB-based biomechanics simulation tool designed to analyze the kinematics and kinetics of Squat exercises. This project models the human lower body as a rigid-body 2D-manipulator to calculate joint torques, visualize movement trajectories, and generate torque distribution heatmaps using parallel computing.

![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-orange) ![License](https://img.shields.io/badge/License-MIT-blue)

<p align="center">
  <img src="Squat_demo.gif" alt="Squat Simulation Demo" width="600">
</p>

## 📌 Features

* **Rigid Body Modeling:** Utilizes MATLAB's **Robotics System Toolbox** to create a 3-DOF kinematic chain representing the Foot, Tibia, Femur, and Torso.
* **Inverse Kinematics & Dynamics:** Solves for joint angles and torques required to maintain the barbell's center of mass directly over the mid-foot (Center of Pressure constraint).
* **Interactive GUI:** Input dialogs for customizing body dimensions (Femur, Tibia, Torso length), body mass, squat type (High-bar vs. Low-bar), and barbell weight.
* **Torque Heatmap Visualization:** Generates detailed heatmaps showing the integral of torque at the Knee and Hip across a range of motion.
    * **🚀 Parallel Computing:** Implements `parfor` and `DataQueue` with a custom UI progress bar to accelerate the heavy calculation of heatmaps.
* **Video Export:** Automatically generates `.mp4` animations of the squat movement.

## 🛠 Prerequisites

To run this project, you need **MATLAB** (R2020a or later recommended) with the following toolboxes:

* **Robotics System Toolbox** (Required for `rigidBodyTree` and `generalizedInverseKinematics`)
* **Parallel Computing Toolbox** (Required for accelerated heatmap generation)

## 🚀 How to Run

### Main Simulation
Run the master script to start the full simulation sequence:

```matlab
ItsLegDay
```

This script executes the following steps in order:

1.  **Input Setup (`Sim1`):** A dialog appears for body parameters (Lengths, Mass, Load).
2.  **Standard Simulation:** Performs a squat simulation based on the inputs and reports Peak Torque & ROM.
3.  **Heatmap Generation:** Calculates knee/hip torque integrals.
    > **Note:** This starts a Parallel Pool. It may take **30-60 seconds** to initialize. A progress bar will show the calculation status.
4.  **Trajectory Refinement (`Sim2`):** After the first pass, `Sim2` runs to allow you to test specific final joint angles.

## 📂 File Structure

| File Name | Description |
| :--- | :--- |
| **`ItsLegDay.m`** | **Master Wrapper.** The main entry point that orchestrates `Sim1` (setup) and `Sim2` (trajectory). |
| **`Sim1.m`** | Initial Setup GUI. Handles parameter inputs, runs the base simulation, and triggers heatmap generation. |
| **`Sim2.m`** | Secondary GUI. Allows users to specify target angles for the Femur and Tibia to analyze different squat depths. |
| **`squat_simulation.m`** | **Core Solver.** Handles trajectory generation, Generalized Inverse Kinematics (GIK), Inverse Dynamics, and video recording. |
| **`squat_robot.m`** | Defines the kinematic structure (Rigid Body Tree) and mass properties of the human model. |
| **`solveBarY_fixedTrunkFromFinal.m`** | Geometric solver ensuring the "Bar over Mid-foot" constraint is satisfied for any given depth. |
| **`plotLocalTorqueHeatmapUI.m`** | **Key Feature.** Generates torque heatmaps using **Parallel Computing** with a custom progress bar UI. |
| **`TorqueAnalysis.m`** | Headless function for calculating physics in the background (used by the heatmap generator). |

## 📊 Biomechanical Constraints

The simulation is based on the **Static Equilibrium** assumption:

1.  **Center of Pressure (CoP):** The projection of the system's Center of Mass (or Barbell) stays vertically aligned with the mid-foot ($x = Foot/6$).
2.  **Bar Positioning ($l$):**
    * **High-bar Squat:** Barbell is placed higher on the torso ($l \approx 0.7084$).
    * **Low-bar Squat:** Barbell is placed lower on the torso ($l \approx 0.6429$), typically forcing a more forward-leaning trunk angle.

## 📄 License

This project is licensed under the MIT License - see the text below for details.

```text
MIT License

Copyright (c) 2025 Sunghyun Park

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 📬 Contact

* **Author:** Sunghyun Park
* **Email:** edi_park@yonsei.ac.kr
* **GitHub:** [https://github.com/edipark](https://github.com/edipark)
