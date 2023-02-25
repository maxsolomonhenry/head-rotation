from glob import glob
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def main():

    df = load_data("data", do_process=True)
    print(df.head(10))
    

def process(df):
    df['outputs'] = df['outputs'].apply(make_int_list)
    df['whichCondition'] = df['outputs'].apply(get_condition)
    df['trueDirection'] = df['outputs'].apply(get_true_direction)
    return df

def get_true_direction(x):
    y = ""
    for element in x:
        element = ((element - 1) % 4) + 1
        
        if element == 1:
            y += "l"
        if element == 2:
            y += "r"
        if element == 3:
            y += "f"
        if element == 4:
            y += "b"

    # Reverse to be consistent with user input (`rf`` -> `fr``)
    return y[::-1]

def get_condition(x):
    if x[0] <= 4:
        return "engine"
    if x[0] <= 8:
        return "speakers"
    if x[0] <= 12:
        return "flat"
    
    return "unknown"

def load_data(data_dir, do_process=True):
    fpattern = os.path.join(data_dir, "*.csv")

    df = pd.DataFrame([])
    for fpath in glob(fpattern):
        df = pd.concat([df, pd.read_csv(fpath)])

    
    if do_process:
        df = process(df)

    return df

def make_int_list(the_string):
    return [int(x) for x in the_string[1:-1].split("  ")]

if __name__ == "__main__":
    main()