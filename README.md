# Coccinelle Scripts for Linux Kernel Development

This repository contains a collection of Coccinelle (`.cocci`) scripts designed to automate and standardize code transformations in the Linux kernel.  
Coccinelle is a powerful tool used to match and refactor C code by describing code patterns and transformations through semantic patches.  
These scripts help kernel developers identify API changes, enforce coding conventions, and modernize legacy code.

---

##  Prerequisites

To run the Coccinelle scripts in this repository, ensure you have the following installed:

- Linux environment with `make` and standard development tools
- Python 3.x
- [Coccinelle](https://coccinelle.gitlabpages.inria.fr/website/) (includes the `spatch` tool)

###  Install Coccinelle on Debian/Ubuntu:

```bash
sudo apt install coccinelle

##  How to Run the Scripts

You can run the `.cocci` scripts on files, directories, or the full Linux kernel tree using the `spatch` tool provided by Coccinelle. Below are several common use cases:

---

### 📂 Run on a Directory (Recursively)

To apply a script to an entire codebase (e.g., kernel source or your project):

```bash
spatch --sp-file script.cocci --dir path/to/codebase --recursive-includes --in-place

