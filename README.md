# MATLAB Code for "Chern-Simons potentials of higher-dimensional Pontryagin densities"

This repository contains the MATLAB code used in the calculation of Cherns-Simons-like potentials from gravitational Pontryagin densities in higher even dimensions
```math
P_{2n} = R^{i_1}_{i_2}\wedge R^{i_2}_{i_3}\wedge \dots \wedge R^{i_{2n-1}}_{i_{2n}},
```
presented in the paper:

> **Title:** *Chern-Simons potentials of higher-dimensional Pontryagin densities*<br>
> **Authors:** Onur Ayberk Çakmak, Özgür Sarıoğlu<br>
> **arXiv:** [](https://arxiv.org/)

## Overview


## 🛠 Requirements
This code was developed and tested using:
- **MATLAB** R2023b or later
  
To check the version of your Matlab program, run
```matlab
ver
```

### How to Run
- Extract the zip folder in a directory of your choice in your computer, but <ins>**DO NOT**</ins> change the hierarchy of the folders and files inside!
  - If the hierarchy needs to change, paths in params.paths should be updated accordingly.
- Adjust the input parameters:
  - <ins>dimMin:</ins> The starting dimension of the computation.
  - <ins>dimMax:</ins> The ending dimension of the computation.
  - <ins>enableLog:</ins> Set as 1 to enable log keeping, set as 0 otherwise.
  - <ins>enableMatrixWrite:</ins> Set as 1 to enable erroneous matrices to be written in the log                                   file, set as 0 otherwise. "enablaLog" flag must be raised.
  - <ins>txtForm:</ins> This variable is for adjusting the formatting of the log file. Set as 1                         if the log file is to be displayed in notepad, set as 2 for notepad++.
  - <ins>tolerance:</ins> Tolerance value below which a variable is considered as 0.
- Run the "main.m" file

### Output
The code first checks whether the folders in which the output files will be stored exist. These folders are 
- "matrices", which will hold the subfolders for different permutation classes ($P^{(\bar{a},n-a)}, a=1,\dots,n $);
  - "(a,n-a)"s, which will hold the relevant matrices for the $P^{\{\bar{a},n-a\}}, a=1,\dots,n$ permutation classes;
- "excel files", which will hold the excel tables for the given dimension;
- "backup", which will hold the previously generated outputs.

### Error Handling

### Backup

## 📁 Repository Structure
```graphql
pontryagin-calc/
│
├── scripts/          # Folder containing .m files
│  ├── main.m           # Main function to be executed
│  ├── dec2sym.m        # Decimal number to symbolic text conversion
│  ├── derivGen.m       # Total derivative generator from event terms
│  ├── genCycPerm.m     # Cyclic permutation generator from input decimal
│  ├── genPerm.m        # Unique cyclic permutation generator in D-dimension
│  ├── genPwrStr.m      # Function to convert decimal to superscript text
│  ├── intByParts.m     # Function to apply integration by parts
│  ├── permSplit.m      # Function to find consecutive binary digit repetitions
│  ├── rpt2pwr.m        # Function to convert repeated number to number raised to power
│  ├── saveMat.m        # Matrix saver
│  └── toLog.m          # Log keeper
│  
├── matrices/         # Folder to store the generated matrices
│  ├── D-2              # Folder containing subfolders corresponding to D=2
│  │  └── 1-0             # Folder containing matrices of P^(1,0) permutation class
│  ├── D-4              # Folder containing matrices corresponding to D=4
│  │  ├── 2-0             # Folder containing matrices of P^(2,0) permutation class
│  │  └── 1-1             # Folder containing matrices of P^(1,1) permutation class
│  │
│  └── ...
│
├── excel files/      # Folder to store the generated excel files
├── README.md         # Project documentation
└── LICENSE           # License file (MIT or other)
```

To run the main script, open MATLAB and execute:
```matlab
main.m
```

## 📝 Citation
```bibtex
@article{,
  title={Chern-Simons potentials of higher-dimensional Pontryagin densities},
  author={Çakmak, Onur Ayberk and Sarıoğlu, Özgür},  
  journal={},
  year={2025},
  doi={}
}
```

## 📬 Contact
- Onur Ayberk Çakmak – acakmak@metu.edu.tr
- GitHub: @CaesarSilvae

## License
This work is licensed under CC BY 4.0.

You are free to use, modify, and distribute it, provided that appropriate credit is given to the original author(s).
