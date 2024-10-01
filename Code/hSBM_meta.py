print("Importing libraries...")
import pandas as pd
from ast import literal_eval
import os
from multisbmtm import sbmmultilayer

print("Imports successful")
# Load data
# Narratives are in the "Story" column
# Titles are in the "Title" column
# Emotions are in the "Emotion" column
# Split for cross-validation is in the "split" column

# Read in base_path from config file
with open('config') as f:
    exec(f.read())

if not os.path.exists(base_path):
    print(f"Directory '{base_path}' does not exist.")
    exit()

data_name = "narratives_processed.csv"
data_path = f"{base_path}/{data_name}"

if not os.path.exists(data_path):
    print(f"File '{data_path}' does not exist.")
    exit()

data = pd.read_csv(data_path)

# Create output directory
output_path = f"{base_path}/Results"

if not os.path.exists(output_path):
    os.makedirs(output_path)
    print(f"Directory '{output_path}' created successfully.")

texts = data["Story"].values.tolist()
titles = data["Title"].values.tolist()
metadata_list = [literal_eval(x) for x in data["Emotion"]]
texts = [str(c).split() for c in texts]

def run_hSBM(texts, titles, metadata_list):
    # Function to run the hSBM given the data
    model = sbmmultilayer(random_seed=10)
    model.make_graph(texts,titles, metadata_list)
    model.fit()
    for level in range(0,model.n_levels+1):
        group_results = model.get_groupStats(l = level)
        p_w_tw = group_results['p_w_tw']
        p_m_tm = group_results['p_m_tm']
        p_tw_d = group_results['p_tw_d']
        p_tm_d = group_results['p_tm_d']
        p_td_d = group_results['p_td_d']
        pd.DataFrame.to_csv(pd.DataFrame(p_w_tw), "".join([output_path, "/p_w_tw", str(level), ".csv"]))
        pd.DataFrame.to_csv(pd.DataFrame(p_m_tm), "".join([output_path, "/p_m_tm", str(level), ".csv"]))
        pd.DataFrame.to_csv(pd.DataFrame(p_tw_d), "".join([output_path, "/p_tw_d", str(level), ".csv"]))
        pd.DataFrame.to_csv(pd.DataFrame(p_tm_d), "".join([output_path, "/p_tm_d", str(level), ".csv"]))
        pd.DataFrame.to_csv(pd.DataFrame(p_td_d), "".join([output_path, "/p_td_d", str(level), ".csv"]))
    pd.DataFrame.to_csv(pd.DataFrame(model.words), "".join([output_path, "/words_all.csv"]))
    pd.DataFrame.to_csv(pd.DataFrame(model.documents), "".join([output_path, "/docs_all.csv"]))
    pd.DataFrame.to_csv(pd.DataFrame(model.meta), "".join([output_path, "/meta_all.csv"]))

try:
  run_hSBM(texts, titles, metadata_list)
except Exception as e:
  print(f"An error occurred: {str(e)}")
