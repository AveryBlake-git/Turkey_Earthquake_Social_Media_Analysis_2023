# Turkey Earthquake Social Media Analysis 2023

## Project Overview

This project analyzes social media sentiment and topic evolution during the 2023 Turkey earthquake using Twitter data. The study employs various natural language processing (NLP) techniques to explore the dynamics of public sentiment and the evolution of topics during the disaster. By leveraging high-frequency word analysis, Latent Semantic Analysis (LSA), and Latent Dirichlet Allocation (LDA), this project provides insights into how public attention, emotional responses, and concerns shifted throughout the different phases of the earthquake.

## Key Findings

1. **Public Attention Evolution**: The study found that public attention during the earthquake followed a clear phase progression:
   - Initial focus on event information and basic earthquake details.
   - Transition to rescue needs and actions.
   - Emotional expression, gratitude, and international impact as the situation developed.
   
2. **Emotion Dynamics**: The analysis of sentiment over time revealed a pattern of "sharp rise - rapid decline - stabilization" in public emotions, reflecting the psychological adaptation to a disaster event.

3. **Topic Evolution**: Through topic modeling, the project identified four key themes that emerged throughout the event:
   - **Disaster Rescue**: Discussions focused on relief efforts, victims, and survivors.
   - **Society**: Public responses, community solidarity, and citizen actions.
   - **Media**: News, media coverage, and information dissemination.
   - **International Aid**: Attention on international support and cross-border assistance.

4. **Social Media's Role**: The research highlights the role of social media in disaster management, including its ability to serve as a platform for urgent information sharing, emotional support, and international cooperation.

## Data

- **Source**: The data used in this analysis was obtained from Twitter, focusing on posts related to the 2023 Turkey earthquake. The dataset was downloaded from Kaggle and merged from multiple sources to create a comprehensive dataset spanning from February 6, 2023, to February 10, 2023.
  
## Methodology

1. **Data Preprocessing**: 
   - Tokenization and stop-word removal were performed to clean the data.
   - Text normalization and stemming were applied to improve analysis accuracy.
   - A Document-Term Matrix (DTM) was created, retaining only terms that appeared at least 10 times.

2. **Topic Modeling**:
   - **Latent Semantic Analysis (LSA)**: Used to uncover the latent topics within the dataset, employing TF-IDF weighting to balance word frequency and document importance.
   - **Latent Dirichlet Allocation (LDA)**: An unsupervised technique used to identify four key themes related to the earthquake.

3. **Sentiment Analysis**:
   - The sentiment was analyzed through both frequency-based and time-series analysis.
   - Sentiment scores were calculated for each tweet, and trends over time were plotted to track emotional shifts (e.g., anger and fear).
   - NRC Sentiment Dictionary was employed for more detailed emotional classification.

## Visualization

The following visualizations are included in this project:
- **Word Cloud**: Visual representations of the top words in each identified theme.
- **Sentiment Time Series**: Graphs showing sentiment trends over time, including overall sentiment, anger, and fear.

## Conclusion

This project provides valuable insights into the emotional and thematic progression of public reactions during a natural disaster. By analyzing social media data, it demonstrates how people adapt emotionally to sudden events and how the discourse around disaster events evolves over time. The findings contribute to the broader understanding of social media's role in crisis communication and disaster management.

## Future Work

- Further research could explore differences in public reactions to various types of disasters (e.g., natural vs. man-made).
- The sentiment analysis models could be refined for even greater accuracy in future applications.
  
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Special thanks to Professor Huang Yifan for the guidance and reference materials.
- The dataset was sourced from Kaggle, and we acknowledge the original contributors for making the data available.

## Language
Chinese
