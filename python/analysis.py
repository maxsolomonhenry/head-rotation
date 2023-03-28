import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd


def calculate_metrics(tp, fp, tn, fn):
    precision = tp / (tp + fp)
    accuracy = (tp + tn) / (tp + fp + tn + fn)
    sensitivity = tp / (tp + fn)
    f1_score = 2 * ((precision * sensitivity) / (precision + sensitivity))
    return precision, accuracy, sensitivity, f1_score

def main():
    fpath = "data/summary.csv"

    df = pd.read_csv(fpath)

    # Rename the participant IDs to P1, P2, P3, and P4
    unique_participant_ids = df['participantId'].unique()
    mapping = {unique_participant_ids[i]: f'P{i+1}' for i in range(len(unique_participant_ids))}
    df['participantLabel'] = df['participantId'].map(mapping)

    # Specify the order of the conditions and the width of the bars
    condition_order = ['flat', 'engine', 'speakers']
    bar_width = 0.5

    # Create the boxplot
    plt.figure(figsize=(9, 6))
    sns.boxplot(x='condition', y='perceivedRealism', hue='participantLabel', data=df, palette='Set2', order=condition_order, width=bar_width)

    # Set the axis labels
    plt.ylabel('perceived realism')

    # Add a legend for the participant colors
    plt.legend(loc='lower right', borderaxespad=0.5)

    plt.savefig('figs/boxplot_perceived_realism.png', dpi=300)

    # Create a confusion matrix for each condition
    conditions = ['flat', 'engine', 'speakers']
    confusion_matrices = {}

    direction_order = ['f', 'fr', 'r', 'br', 'b', 'bl', 'l', 'fl']

    for condition in conditions:
        condition_data = df[df['condition'] == condition]
        if condition_data.empty:
            print(f"No data available for condition: {condition}")
            continue
        confusion_matrix = pd.crosstab(condition_data['playbackDirection'], condition_data['perceivedDirection'], rownames=['played'], colnames=['perceived'], normalize='index')
        confusion_matrix = confusion_matrix.reindex(index=direction_order, columns=direction_order, fill_value=0)
        confusion_matrices[condition] = confusion_matrix

    # Plot the heatmaps
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Remove the fourth subplot (bottom-right corner)
    axes[1, 1].set_axis_off()

    # Flatten the axes array for easier iteration
    axes_flat = axes.flatten()

    for i, condition in enumerate(conditions):
        if condition not in confusion_matrices:
            continue
        ax = axes_flat[i]
        sns.heatmap(confusion_matrices[condition], annot=True, fmt='.2f', cmap='coolwarm', cbar=False, ax=ax, linewidths=0.01)
        ax.set_title(condition, y=-0.2, x=0.5)

    plt.tight_layout()


    plt.savefig('figs/confusion_matrix_heatmaps.png', dpi=300)

    plt.figure(figsize=(9, 6))

    # Filter the dataframe to keep rows with perceivedSource == 's' and condition in ['Speakers', 'Engine', 'Flat']
    filtered_df = df[(df['perceivedSource'] == 's') & (df['condition'].isin(['flat', 'engine', 'speakers']))]

    # Create the count plot
    sns.countplot(x='condition', data=filtered_df, palette='coolwarm', order=condition_order)

    # Set plot title and labels
    plt.xlabel('condition')
    plt.ylabel('percieved as speakers (count)')

    plt.savefig('figs/count_plot_perceived_as_speakers.png', dpi=300)

    # plt.figure(figsize=(9, 6))
    # Create a histogram for each condition
    conditions = ['flat', 'engine', 'speakers']
    colors = ['steelblue', 'darkorange', 'forestgreen']
    fig, ax = plt.subplots(figsize=(8, 6))
    for i, condition in enumerate(conditions):
        condition_data = df[df['condition'] == condition]

        print(condition, np.mean(condition_data['perceivedRealism']))

        if condition_data.empty:
            print(f"No data available for condition: {condition}")
            continue
        sns.histplot(data=condition_data, x='perceivedRealism', bins=[1, 2, 3, 4, 5, 6], color=colors[i], alpha=0.5, label=condition)

    # Set plot title and labels
    plt.xlabel("perceived realism")
    plt.ylabel("count")
    plt.legend()

    plt.savefig('figs/histogram_perceived_realism.png', dpi=300)


    # Calculate the modified MRR and accuracy for each condition
    conditions = ['flat', 'engine', 'speakers']
    results = []
    for condition in conditions:
        modified_mrr = calculate_modified_mrr(df, condition)
        accuracy = calculate_accuracy(df, condition)
        results.append([condition, accuracy, modified_mrr])

    # Output the data as a LaTeX formatted table
    results_df = pd.DataFrame(results, columns=['Condition', 'Accuracy', 'Modified MRR'])
    print(results_df.to_latex(index=False))

    # Show the plot
    plt.show()

def circular_distance(choice, correct):
    # Function to calculate the circular distance between two directions
    directions = ['l', 'fl', 'f', 'fr', 'r', 'br', 'b', 'bl']
    index_choice = directions.index(choice)
    index_correct = directions.index(correct)
    distance = abs(index_choice - index_correct)
    circular_distance = min(distance, len(directions) - distance)
    return circular_distance


def calculate_accuracy(df, condition):
# Function to calculate the accuracy for a given condition
    df_condition = df[df['condition'] == condition]
    correct_answers = sum(df_condition['perceivedDirection'] == df_condition['playbackDirection'])
    total_answers = len(df_condition)
    return correct_answers / total_answers


def calculate_modified_mrr(df, condition):
    # Function to calculate the modified MRR for a given condition
    df_condition = df[df['condition'] == condition]
    reciprocal_ranks = []
    for _, row in df_condition.iterrows():
        distance = circular_distance(row['perceivedDirection'], row['playbackDirection'])
        rank = distance + 1
        reciprocal_rank = 1 / rank
        reciprocal_ranks.append(reciprocal_rank)
    return sum(reciprocal_ranks) / len(reciprocal_ranks)


if __name__ == "__main__":
    main()