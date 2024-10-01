# Probabilistic Emotion and Sentiment Modelling of Patient-Reported Experiences

This repository contains supplementary materials and code for reproducing the probabilistic emotion and sentiment models described in our paper.

## Citation
If you use this code or data in your research, please cite our paper:

```bibtex
@article{Murray2024Probabilistic,
  title={Probabilistic Emotion and Sentiment Modelling of Patient-Reported Experiences},
  author={Murray, Curtis and Mitchell, Lewis and Tuke, Jonathan and Mackay, Mark},
  year={2024}
}
```

## Repository Contents
1. Code to reproduce the probabilistic emotion and sentiment models
2. Hierarchical topic structure derived from the Care Opinion (AU) corpus
## Setup
### Prerequisites
- Anaconda or Miniconda (https://docs.conda.io/en/latest/miniconda.html)

### Environment Setup
1. Clone this repository:
```{bash}
git clone https://github.com/curtis-murray/persSupplementaryMaterials.git
cd persSupplementaryMaterials
```
2. Create and activate the conda environment:
```{bash}
conda env create -f environment.yml
conda activate pers
```
3. Verify the environment:
```{bash}
conda list
```

#### Removing the Environment
If you need to remove the environment:
```{bash}
conda remove --name pers --all
```

### Data Preparation
1.Place your text data in the ./Data/ directory.

2.Update the ./config file:
```{bash}
base_path="Data"
narratives_path="Data/narratives.csv"
```
3. Ensure your text data has three columns: Title, Story, and Emotion.
Example:

| Title | Story | Emotion |
| ----- | ----- | ------- |
| Hospital Visit | "The staff were very kind." | happy,grateful |
| Emergency | "Long wait times, but good care." | frustrated,thankful |

## Running the Model
1. From the project directory, run:
```{bash}
make
```
This will validate the data, preprocess narratives, perform topic modelling, and create the model.
2. Example usage of the model can be found in Code/model.R.

### Model Functions
The following functions are available for emotion and sentiment analysis:
- `model_emotions_tbl()`: Analyse emotions in a dataframe
- `model_emotions_text()`: Analyse emotions in a single text string
- `model_sentiment_tbl()`: Analyse sentiment in a dataframe
- `model_sentiment_text()`: Analyse sentiment in a single text string

Example usage (Code/model.R):
```{r}
data <- tibble(
  text_column = c(
    "The staff were very helpful and kind. I loved my experience.",
    "The wait was awful, the staff were rude and told me to stop complaining."
  )
)

# Analyse emotions in a dataframe
model_emotions_tbl(data, "text_column")

# Analyse emotions in a single text string
model_emotions_text("The staff were very helpful and kind.")

# Analyse sentiment in a dataframe
model_sentiment_tbl(data, "text_column")

# Analyse sentiment in a dataframe
model_sentiment_tbl(data, "text_column")

# Analyse sentiment in a single text string
model_sentiment_text(
  "The wait was awful, the staff were rude and told me to stop complaining."
)
```

## Hierarchical Topic Structure
In addition to the code to generate this model, we present the topic structure of the Care Opinion corpus presented in the corresponding paper.

Each topic within the hierarchy is represented as a subfolder nested within parent topics. Users can navigate through the folders to explore topics and their respective subtopics. Each topic is named using the top three words from the topic. The word clouds reflect the frequency and relevance of terms within the topic, while the lolipop plots measure the likelihood of the topic under sentiments and emotions.

### Topic Structure

### Repository Structure

- `/Topic_A`
  - `Topic_A.pdf`
  - `/Topic_B`
      - `Topic_B.pdf`
      - `/Topic_C`
          - `Topic_C.pdf`
      - ...
  - `/Topic_D`
    - `Topic_D.pdf`
    - ...

### Examples

#### Topic Word Cloud
This plot visualises the frequency and relevance of terms within a topic. This topic captures discussion relating to care for musculoskeletal and nervous system conditions.
![Topic Word Cloud](/.example/example_wordcloud_mri.png)

#### Positive and Negative Sentiments
This plot shows the likelihood of positive and negative sentiments given the above topic. We see that this topic is more likely in negative contexts.
![Emotion/Sentiment Associations](/.example/example_sentiments_mri.png)

#### Detailed Emotion Associations
This plot shows likelihood of each patient-reported emotions given the same topic. This topic is most likely under the emotion `free`, potentially reflecting a sense of relief patients may experience upon recovery from enduring pain or mobility limitations. Conversely, the negative emotion `embarrassed` also features prominently, potentially signalling the psychological distress or stigma that patients often confront when dealing with chronic illnesses.
![Emotion/Sentiment Associations](/.example/example_emotions_mri.png)

### Contact

For questions or further information, please contact Curtis Murray at curtis@curtismurray.tech

---

These materials accompany the paper submitted for academic consideration and are intended for research and educational use.
