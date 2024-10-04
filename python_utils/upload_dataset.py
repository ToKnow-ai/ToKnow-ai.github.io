'''Upload a data to a Hugging Face dataset.'''

import time
import pandas as pd
from datasets import Dataset
from huggingface_hub import HfApi, login

def upload_dataframe_to_huggingface(
    df: pd.DataFrame,
    *,
    repo_id: str,
    dataset_name: str = 'default',
    split: str = 'train',
    private: bool = False,
    preserve_index: bool = False,
    features = None
) -> None:
    """
    Upload a pandas DataFrame to a Hugging Face dataset.
    """
    # Convert DataFrame to Hugging Face Dataset
    hf_dataset = Dataset.from_pandas(df, preserve_index = preserve_index, features = features)

    # Initialize Hugging Face API
    api = HfApi()

    try:
        # Check if the dataset already exists
        repo_url = api.create_repo(
            repo_id=repo_id,
            private=private,
            repo_type="dataset",
            exist_ok=True
        )

        # Push the dataset to Hugging Face
        commit_info = hf_dataset.push_to_hub(
            repo_id=repo_url.repo_id,
            private=private,
            split=split,
            config_name=dataset_name,
            commit_message=f'Dataset updated at {time.strftime("%Y-%m-%d-%H-%M-%S GMT", time.gmtime())}')
        print(
            f"'{dataset_name}' dataset uploaded successfully.\n" +
            "\n".join([
                f"repo_id: '{repo_id}'",
                f"revision:'{commit_info.oid}'", 
                f"url: '{repo_url.url}'"]))
    except Exception as e:
        print(f"Error uploading dataset: {str(e)}")

def huggingface_login():
    return login()
