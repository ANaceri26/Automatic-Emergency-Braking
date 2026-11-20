# RoadRunner Replay

Plays back a MATLAB run in RoadRunner as recorded trajectories. The controller still runs in MATLAB, so RoadRunner is only used for 3-D visualization, not co-simulation.

Needs RoadRunner and RoadRunner Scenario. The MATLAB import helper also needs Automated Driving Toolbox.

## Export

```matlab
aeb_export_roadrunner(aeb_simulate(aeb_config('dry')))
```

Pre-exported dry and wet cases are in `roadrunner/`.

| File | Contents |
|---|---|
| `straight_road.xodr` | straight two-lane OpenDRIVE 1.4 road |
| `ego.csv`, `lead.csv` | `time,x,y,z,yaw,pitch,roll` per simulation step (s, m, rad) |
| `replay_info.txt` | case, duration, coordinate notes |

Vehicles are 4.5 m long, positioned at their geometric center, in lane -1 (y = -1.75 m), facing +X.

## Manual import

1. Scene Editing: File > Import `straight_road.xodr` (OpenDRIVE), keep the original coordinates.
2. Scenario Editing: import `ego.csv` and `lead.csv` as CSV Trajectory.
3. Play. In the dry case the ego starts at x = 0 and the lead at x = 46.5.

## MATLAB import

```matlab
rr = import_aeb_roadrunner('C:\path\to\RoadRunnerProject', 'C:\Program Files\RoadRunner R2024a', 'dry');
```

Creates a new scene and scenario in the project and imports both trajectories.

Changing anything in RoadRunner does not change the braking. Edit `aeb_config`, rerun, and re-export.
