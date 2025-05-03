# FT_LLM_SCVD
Fine-tuning a large language model for scmart contract vulnerability detection


## Dataset
### data/procerssed_data
In `data/procerssed_data`, there are 9 resources from various external datasets. The data in each directory is the processed data applied on the raw data (raw data is available in branch `DS_fewshots`).
Each directory contins `LOCs` and `contracts` folders. `LOCs` contains processed data while `contracts` includes the source contracts.
- This datasets provide enough information for the creating Fine-tuning dataset.
