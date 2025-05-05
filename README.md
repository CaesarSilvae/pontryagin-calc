# MATLAB Code for "Chern-Simons potentials of higher-dimensional Pontryagin densities"

This repository contains the MATLAB code used in the calculation of Cherns-Simons-like potentials from gravitational Pontryagin densities in higher even dimensions
```math
P_{2n} = R^{i_1}_{i_2}\wedge R^{i_2}_{i_3}\wedge \dots \wedge R^{i_{2n-1}}_{i_{2n}},
```
presented in the paper:

> **Title:** *Chern-Simons potentials of higher-dimensional Pontryagin densities*<br>
> **Authors:** Onur Ayberk Çakmak, Bahtiyar Özgür Sarıoğlu<br>
> **arXiv:** [](https://arxiv.org/)

## Overview


## 🛠 Requirements
This code was developed and tested using:
- **MATLAB** R2023b or lateer
  
To check the version of your Matlab program, run
```matlab
ver
```

### How to Run
Extract the zip folder in a directory you choose in your computer, but <ins>**DO NOT**</ins> change the hierarchy of the folders and files inside!

## 📁 Repository Structure
```graphql
pontryagin-calc/
│
├── scripts/          # Folder containing .m files
│  ├── main.m           # Main function to be executed
│  ├── dec2sym.m        # Decimal number to symbolic text conversion
│  ├── derivGen.m       # Total derivative generator from event terms
│  ├── genCycPerm.m     # Cyclic permutation generator from input decimal
│  ├── genPerm.m        # 
│  ├── genPwrStr.m      #
│  ├── intByParts.m     # Function to apply integration by parts
│  ├── permSplit        #
│  ├── rpt2pwr          #
│  ├── saveMat          # Matrix saver
│  └── toLog            # Log keeper
│  
├── matrices/         # Folder to store the generated matrices
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
  author={Çakmak, Onur Ayberk and Sarıoğlu, Bahtiyar Özgür},  
  journal={},
  year={2025},
  doi={}
}
```

## 📬 Contact
- Onur Ayberk Çakmak – acakmak@metu.edu.tr
- GitHub: @CaesarSilvae

## License
This work is licensed under CC BY-SA 4.0.

You are free to use, modify, and distribute it, provided that appropriate credit is given to the original author(s).
