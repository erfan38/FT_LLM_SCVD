# FT_LLM_SCVD
Fine-tuning a large language model for scmart contract vulnerability detection


## Dataset
### data/procerssed_data
In `data/procerssed_data`, there are 9 resources from various external datasets. The data in each directory is the processed data applied on the raw data (raw data is available in branch `DS_fewshots`).
Each directory contins `LOCs` and `contracts` folders. `LOCs` contains processed data while `contracts` includes the source contracts.
- This datasets provide enough information for the creating Fine-tuning dataset.

## Solidity Version Branch (`solidity-version`)
In this branch, we focus on analyzing the distribution of Solidity versions across our dataset and comparing our model's performance with static analysis tools.

### Evaluation
The `src/evaluation` folder contains:
- **Solidity Version Categorization**: Scripts and notebooks (`solidity-version.ipynb`) to classify contracts by their Solidity version (e.g., `^0.4.11`, `>=0.4.22 < newer`).
- **Plots**: Visualizations of the version distribution (e.g., `solidity_distribution_scaled.png`).
- **Slither Comparison**: We ran the test set on the **Slither** static analysis tool to compare its vulnerability detection capabilities with our results.
  - *Note*: As Slither is a static analysis tool and represents a different approach (state-of-the-art in its category), we did not include a direct performance comparison with our LLM-based model in the main paper scope, but the data is available here for reference.

### Dataset Location
The refined dataset used for this work is saved in:
`src/hugging-face/refineData/correced_v1/splitting_function/corrected_v2`
