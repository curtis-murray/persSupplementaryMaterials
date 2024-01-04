# persSupplementaryMaterials

## Supplementary Materials for "Probabilistic Emotion and Sentiment Modelling of Patient-Reported Experiences"

This repository contains the hierarchical topic structure derived from the Care Opinion (AU) corpus. 

Each topic within the hierarchy is represented as a subfolder nested within parent topics. Users can navigate through the folders to explore topics and their respective subtopics. Each topic is named using the top three words from the topic. The word clouds reflect the frequency and relevance of terms within the topic, while the lolipop plots measure the likelihood of the topic under sentiments and emotions.

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

### Citation

Please cite this repository as follows: 

Murray, C., Mitchell, L., Tuke, J., & Mackay, M. (2024). Probabilistic Emotion and Sentiment Modelling of Patient-Reported Experiences. Manuscript in preparation.

BibTeX:
```bibtex
@unpublished{Murray2024Probabilistic,
  title={Probabilistic Emotion and Sentiment Modelling of Patient-Reported Experiences},
  author={Murray, Curtis and Mitchell, Lewis and Tuke, Jonathan and Mackay, Mark},
  note={Manuscript in preparation},
  year={2024}
}
```

### Contact

For questions or further information, please contact Curtis Murray at curtis@curtismurray.tech


---

These materials accompany the paper submitted for academic consideration and are intended for research and educational use.
