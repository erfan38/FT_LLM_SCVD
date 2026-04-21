# FT_LLM_SCVD — Fine-Tuned LLM for Smart Contract Vulnerability Detection

Research artifact for the paper:

> **Fine-Tuned Large Language Model and Comprehensive Dataset for Securing Ethereum Smart Contracts with Real-Time VSCode Auditing.**
> *Blockchain: Research and Applications*, Elsevier, March 2026.
> [DOI: 10.1016/j.bcra.2026.100466](https://doi.org/10.1016/j.bcra.2026.100466)

This repository contains the **comprehensive Solidity vulnerability dataset** and the **LLM fine-tuning pipeline** introduced in the paper. The companion VSCode plugin — which consumes the fine-tuned model for real-time smart contract auditing inside the editor — lives in a separate repository: [plugin](https://github.com/erfan38/plugin).

---

## Overview

Traditional smart contract analyzers (rule-based static analysis, symbolic execution) often miss context-dependent vulnerabilities and produce high false-positive rates. This work addresses these limitations by:

1. Building a **comprehensive Solidity vulnerability dataset** aggregated and processed from nine external sources.
2. Fine-tuning a **Large Language Model** on this dataset for smart contract vulnerability detection.
3. Evaluating the fine-tuned model against rule-based tools and traditional ML baselines.
4. Releasing a **VSCode plugin** that integrates the fine-tuned model into the developer workflow (see companion repo).

The vulnerability classes targeted include **reentrancy**, **timestamp dependency**, and **integer overflow / underflow**.

## Dataset

### `data/processed_data`

The `data/processed_data` directory contains nine sub-resources aggregated from external Solidity vulnerability datasets. The data in each directory is processed data derived from the raw sources (raw data is available on the `DS_fewshots` branch).

Each directory contains:

- `LOCs/` — processed, labeled data used for fine-tuning and evaluation
- `contracts/` — the underlying Solidity source contracts

Together, these resources provide the inputs needed to construct the fine-tuning dataset described in the paper.

### Refined dataset used in the paper

The final refined dataset used for fine-tuning and evaluation is located at:

```
src/hugging-face/refineData/correced_v1/splitting_function/corrected_v2
```

### Raw data

Raw, unprocessed versions of the source datasets are preserved on the **`DS_fewshots`** branch for reproducibility and for researchers who wish to apply alternative preprocessing.

## Solidity Version Analysis

This branch also includes analysis of the distribution of Solidity compiler versions across the dataset and a comparison between the fine-tuned LLM and a static analysis baseline.

The `src/evaluation` folder contains:

- **Solidity version categorization** — `solidity-version.ipynb` classifies contracts by compiler version (e.g., `^0.4.11`, `>=0.4.22 < newer`).
- **Plots** — visualizations of the version distribution (e.g., `solidity_distribution_scaled.png`).
- **Slither comparison** — the test set was run through the [Slither](https://github.com/crytic/slither) static analysis tool to compare its vulnerability detection against the fine-tuned LLM.
  - *Note:* Slither represents a fundamentally different approach (state-of-the-art static analysis). A direct head-to-head performance comparison was not included in the paper's main scope, but the data is available here for researchers interested in cross-paradigm benchmarking.

## Repository Structure

```
FT_LLM_SCVD/
├── config/                  # Configuration files
├── data/
│   └── processed_data/      # 9 processed external datasets (LOCs + contracts)
├── src/
│   ├── evaluation/          # Solidity version analysis, Slither comparison, plots
│   └── hugging-face/        # Refined dataset and fine-tuning artifacts
├── .gitignore
└── README.md
```

## Branches

This repository uses multiple branches to document distinct stages of the research pipeline:

- **`main`** — final, paper-aligned version
- **`fine-tuning-data-preparation`** — data preparation pipeline for fine-tuning
- **`DS_fewshots`** — raw external datasets before processing
- Additional branches preserve intermediate dataset construction and cleaning stages (`cleaning_DS`, `final_dataset`, `dataset1_completing`, etc.) for transparency.

## Requirements

- Python 3.x
- PyTorch
- Hugging Face Transformers
- Standard ML tooling (NumPy, Pandas, Scikit-Learn, Jupyter)

## Evaluation

The fine-tuned model was benchmarked against rule-based analyzers and traditional ML baselines on real-world Solidity contracts. Full precision/recall results, dataset statistics, and ablations are reported in the paper.

## Companion Repository

- **VSCode plugin** — real-time smart contract auditing tool that integrates the fine-tuned model into the developer workflow: [github.com/erfan38/plugin](https://github.com/erfan38/plugin)

## Citation

If you use this dataset or the fine-tuning pipeline in your work, please cite:

```
Erfan, F. et al. Fine-Tuned Large Language Model and Comprehensive Dataset
for Securing Ethereum Smart Contracts with Real-Time VSCode Auditing.
Blockchain: Research and Applications, Elsevier, 2026.
DOI: 10.1016/j.bcra.2026.100466
```

## Contributors

- Fatemeh Erfan — Polytechnique Montréal
- Mohammad Yahyatabar - Polytechnique Montréal

## Contact

Fatemeh Erfan — fatemeh.erfan@polymtl.ca
Postdoctoral Fellow, Polytechnique Montréal
