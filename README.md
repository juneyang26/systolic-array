# Systolic Array for NxN matrices

<!-- ABOUT THE PROJECT -->
## About The Project
Brief intro for the time being

Creating an ASIC capable of performing NxN int8 matrix multiplication.
RTL and test bench generation is parameterizable by the dimension N.
Since the design is parameterizable, the controller is a mixture of a FSM and counters.

## Tools Used
- Icarus Verilog, Verilator, GTKWave
- Cadence Xcelium, Cadence SimVision

Note that Icarus Verilog has trouble with dumping unpacked arrays when viewing in waveform.
<!--
Here's a blank template to get started. To avoid retyping too much info, do a search and replace with your text editor for the following: `github_username`, `repo_name`, `twitter_handle`, `linkedin_username`, `email_client`, `email`, `project_title`, `project_description`, `project_license`
-->

<!-- ROADMAP -->
## Roadmap

- [x] Functioning Systolic Array Architecture
- [x] Functioning Controller FSM
- [x] Create test bench automation
- [x] Verification (N = 2, 3, 4)
- [ ] Start RTL to GDSII flow
- [ ] Convert handdrawn schematic into digital forma
- [ ] Incorporate SRAM

