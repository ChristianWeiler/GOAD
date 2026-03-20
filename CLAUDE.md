# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GOAD (Game Of Active Directory) is a pentest Active Directory lab framework that deploys vulnerable AD environments for practicing attack techniques. It supports multiple virtualization providers and provisioning methods, orchestrated via Python CLI and Ansible playbooks.

## Running GOAD

```bash
# Interactive shell mode (default)
python3 goad.py

# CLI automation mode
python3 goad.py -t install -l GOAD -p virtualbox
python3 goad.py -t install -l GOAD -p vmware -m local
python3 goad.py -t check -p virtualbox

# Common CLI tasks: install, check, start, stop, destroy, status, show
# Common shell commands: help, check, create, provide, provision_lab, install_extension
```

Dependencies are managed with Poetry (`pyproject.toml`). Python 3.8+.

There is no test suite, CI/CD pipeline, or linting configuration.

## Architecture

### Entry Point & CLI

`goad.py` — an interactive `cmd.Cmd` shell with 50+ commands. Also supports one-shot CLI via `-t <task>` with argparse flags for lab, provider, method, ip_range, instance, and extensions.

### Core Package (`goad/`)

**LabManager** (`goad/lab_manager.py`) — Singleton orchestrator. Manages lab instances, settings, providers, and the full lifecycle.

**Provider System** (`goad/provider/`) — Factory pattern. Each provider implements `check()`, `install()`, `destroy()`, `start()`, `stop()`, `status()`.
- Vagrant-based: `virtualbox`, `vmware`, `vmware_esxi`
- Terraform-based: `aws`, `azure`, `proxmox`
- Direct: `ludus`

**Provisioner System** (`goad/provisioner/`) — Factory pattern. Controls how Ansible reaches the targets.
- `local` / `runner` — Direct Ansible execution (not on Windows)
- `remote` — Runs via jump box with WinRM
- `docker` — Docker-based Ansible
- `vm` — VM-based with local jump box

**Instance Management** (`goad/instance.py`) — Each deployment is a `LabInstance` with ID `{hex}-{lab}-{provider}`, persisted as JSON in `workspace/{id}/`. Status flow: CREATED → PROVIDED → READY.

**Configuration** (`goad/config.py`) — INI-based. User config at `~/.goad/goad.ini`, global overrides in `globalsettings.ini`. Sections for default and per-provider settings.

**Command System** (`goad/command/`) — Platform-aware (linux, windows, wsl) wrappers for vagrant, terraform, and cloud CLI operations.

**Dependencies** (`goad/dependencies.py`) — Runtime feature flags that enable/disable providers and provisioners based on platform.

### Labs (`ad/`)

Each lab has its own directory under `ad/{lab_name}/` containing provider configs, Ansible inventory (`data/inventory`), and documentation. Available labs: GOAD (5 VMs, 2 forests), GOAD-Light (3 VMs), MINILAB (2 VMs), SCCM (4 VMs), NHA (5 VMs, challenge), DRACARYS (3 VMs, challenge).

### Ansible Playbooks (`ansible/`)

40+ playbooks for AD domain setup, security configuration, and vulnerability injection. Orchestration order is defined in `playbooks.yml` per lab. Roles live in `ansible/roles/`. Inventory is composed from three tiers: lab inventory + provider inventory + `globalsettings.ini`.

### Extensions (`extensions/`)

Modular add-ons (elk, exchange, guacamole, lx01, wazuh, ws01). Each has `extension.json` for config/compatibility, `providers/` for provider-specific files, and `ansible/` with install/uninstall playbooks.

### Templates & Packer

`template/` — Jinja2 templates for provider-specific inventory and config generation.
`packer/` — Packer configurations for building VM images.

## Key Design Patterns

- **Singleton**: LabManager via SingletonMeta
- **Factory**: ProviderFactory, ProvisionerFactory, CommandFactory
- **Template Method**: Provider, Provisioner base classes define interface; subclasses implement
- **Three-tier inventory**: Lab-specific + provider-specific + global settings merged for Ansible

## Console Output

Uses the Rich library. Logging through `goad/utils.py` with levels: INFO, VERBOSE, DEBUG. Methods: `error()`, `warning()`, `success()`, `info()`, `basic()`, `cmd()`.
