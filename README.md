# Serial Integration Factory

A workspace that helps an AI coding agent build, for an RS232-controlled device:

1. **A serial library** — an async Python package that talks to the device over RS232.
2. **A Home Assistant custom integration** — a HACS-installable integration that
   vendors the library to integrate the device into Home Assistant.

## How to use

1. Clone this repo.
2. **Open a coding agent in this folder** (e.g. run `claude` in the repo root).
   The agent reads [`AGENTS.md`](AGENTS.md) for the full workflow.
3. Tell the agent which device you want to support and **where its RS232
   protocol documentation lives** (a path, URL, or PDF).

The agent will run `./setup.sh` to fetch reference repositories, then build both
deliverables into a `<device>/` folder. See [`AGENTS.md`](AGENTS.md) for details.
