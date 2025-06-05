#sample python program that takes some open fame data and plot it using json epoch
#Jimmy & Erik 2024-2025 ; - executes from jupiterlab
#pysample.ipynb


import subprocess, json, pandas as pd
import matplotlib.ticker as ticker
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import os


famebase = '$REFERTID/data/fornavn.db'
famesoek = 'OLE,ERIK?,BR?R'
famedato = 'date 2000 to *'

api = "getfame -s"
apipath = "$REFERTID/system/myfame/api/"

# Hente Fame kommando with apipath and api concatenation
command = f"ssh sl-fame-1.ssb.no '{apipath}{api} {famebase} \"{famesoek}\" \"{famedato}\"'"

subprocess.run(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


# Retrieve the value of the $HOME environment variable
home_dir = os.getenv("HOME")

# Construct the full path using the $HOME variable and the api variable
file_path = os.path.join(home_dir, ".GetFAME", "getfameseries.json")


# Open the sample JSON file using the full path
with open(file_path) as f:


    data = json.load(f)

# Initialize an empty DataFrame to store all data
df_all = pd.DataFrame()

# Iterate over each series in the JSON data
for series in data[0]["Series"]:
    # Get the series name
    series_name = series["Name"]

    # Normalize the JSON data for the current series
    df = pd.json_normalize(series["Observations"])

    # Add a column for the series name
    df['Series'] = series_name

    # Append to the main DataFrame
    df_all = pd.concat([df_all, df], ignore_index=True)

# Convert Date to datetime
df_all['Date'] = pd.to_datetime(df_all['Date'])

# Extract epoch times and values
df_all['Epoch'] = df_all['Epo'].apply(lambda x: x[0])
df_all['Epoch'] = pd.to_datetime(df_all['Epoch'], unit='ms')
df_all['Value'] = df_all['Epo'].apply(lambda x: x[1])

# Plotting
fig, ax = plt.subplots(figsize=(8, 4))

# Plot each series separately we use epoch in upper leagues
for series_name in df_all['Series'].unique():
    df_series = df_all[df_all['Series'] == series_name]
    ax.plot(df_series['Epoch'], df_series['Value'], label=series_name)


# Use AutoDateLocator and AutoDateFormatter
locator = mdates.AutoDateLocator()
formatter = mdates.ConciseDateFormatter(locator)

ax.xaxis.set_major_locator(locator)
ax.xaxis.set_major_formatter(formatter)

# Auto-format the x-axis dates
fig.autofmt_xdate()

# Adding labels and title
plt.xlabel('Time')
plt.ylabel('Values')
plt.title(f"DemoChart: {famesoek} in {famedato}")
plt.grid(True)
plt.legend()

plt.show()
