# LLaMA Fine-Tuning with LoRA or SoRA on Hugging Face GPU

This Space fine-tunes a LLaMA-based model (`TinyLlama/TinyLlama-1.1B-Chat-v1.0` or similar) using the `train-split.jsonl` dataset for smart contract vulnerability detection. You can switch between **LoRA** and **SoRA** by changing a flag inside `train.py`.

##  Run Instructions

This Space does not expose a UI. It performs training directly.

### To switch from LoRA to SoRA

Edit the first few lines of `train.py`:

```python
use_sora = True  # Use SoRA
