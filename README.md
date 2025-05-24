![MATINA 6G Logo](https://github.com/steve-pla/6G-MATINA/blob/main/resources/images/matina_6g_logo.png)

# 6G-MATINA: 6G Maritime Aerial Terrestrial Intelligent Network Access

**6G-MATINA** is a fully open-source, MATLAB-based simulator developed in the context of a PhD research project at the **University of the Aegean**. It serves as an **Intelligent Network Analyzer** for evaluating emerging 6G wireless communication architectures, focusing on **maritime communications**, **aerial relays**, and **distributed intelligent networking**.



## 🌊 Project Context

Developed under the **Computer and Communication Systems Laboratory (CCSL)** of the University of the Aegean, and under the supervision of **Dr. Dimitrios N. Skoutas** (d.skoutas@aegean.gr), this simulator investigates the unique challenges and requirements of the **Aegean Sea maritime communication ecosystem**.

Key challenges addressed include:

- High vessel density and unpredictable traffic
- Connectivity gaps in open-sea areas
- Dynamic environmental interference
- Bandwidth demands for IoT and autonomous navigation

## 🛰️ Research Focus

**6G-MATINA** introduces and evaluates a novel architecture where **Unmanned Aerial Vehicles (UAVs)** operate as **Non-Terrestrial Network (NTN)** relays to support unserved maritime vessels.

The simulator explores:

- 📡 **Dynamic vessel traffic modeling** and communication load forecasting  
- 🧠 **Unsupervised Machine Learning** techniques to determine optimal UAV deployment zones  
- 🧬 **Heuristic-Genetic Algorithms** for efficient UAV spectrum allocation  
- 📶 **Downlink throughput maximization** and **interference minimization** for UAV-vessel communications  

## 🚀 Features
- 📡 6G system-level simulation
- 🌐 Vessels hotposts distribution analysis
- 🤖 AI-enhanced network intelligence
- ⚙️ Modular and customizable scenarios
- 📈 Built-in visualization tools

## 📁 Project Structure
```
6G-matina-source/
├── channel/         # Wireless channel models (e.g., path loss, fading)
├── clustering/      # Unsupervised learning algorithms for UAV deployment
├── config/          # Simulation configuration files and parameters
├── logging/         # Logging utilities and structured output handlers
├── logs/            # Output logs from simulation runs
├── optimizers/      # Heuristic/Genetic algorithms for spectrum allocation
├── simulation/      # Core simulation logic and event processing
├── test/            # Unit tests and verification scripts
├── visualization/   # Plotting and visualization utilities
├── main.m           # Main simulation entry point
```


## 🧰 Requirements
- MATLAB R2042b version 64-bit (win64) or later
- OS: Windows 11
- Machine Learning toolbox

## 🔧 Installation & Usage

1. **Clone the repository**
   ```bash
   git clone https://github.com/steve-pla/6G-MATINA.git
   cd 6G-MATINA

## 📚 Citation

If you use **6G-MATINA** in your academic work, please cite it as:

```bibtex
@misc{6GMATINA,
  author       = {Stefanos Plastras},
  title        = {6G-MATINA: 6G Maritime Aerial Terrestrial Intelligent Network Access},
  year         = {2025},
  publisher    = {GitHub},
  journal      = {GitHub repository},
  howpublished = {\url{https://github.com/steve-pla/6G-MATINA}}
}

