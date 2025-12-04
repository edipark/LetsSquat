# Squat Biomechanics Simulation (MATLAB)

Biomechanics simulation tool for analyzing joint torques during Squat exercises.
This project calculates and visualizes the torque required at the knee and hip joints based on body dimensions and squat depth using inverse dynamics.

## Features
- **User Interface:** GUI for inputting body parameters (Femur, Tibia, Torso length, Mass, etc.).
- **Parallel Computing:** utilizes `parfor` to accelerate heatmap generation.
- **Visualization:** Generates torque heatmaps for Knee and Hip joints relative to limb angles.

## Requirements
- MATLAB R2020a or later
- Parallel Computing Toolbox (for `parfor` acceleration)

## How to Run
1. Run `ItsLegday.m` in MATLAB.
2. Enter the subject's body parameters in the dialog box.
3. The simulation will calculate the mechanics and display the results.
4. A heatmap will be generated showing the torque distribution.

## Files
- `Sim1.m`: Main entry point (GUI setup).
- `squat_simulation.m`: Core dynamics solver.
- `plotLocalTorqueHeatmapUI.m`: Heatmap visualization with parallel processing.
- `TorqueAnalysis.m`: Inverse dynamics calculation unit.
