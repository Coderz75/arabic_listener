import pandas as pd
import sqlite3
import os.path

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(BASE_DIR, "hanswehr.sqlite")

# Read sqlite query results into a pandas DataFrame
con = sqlite3.connect(db_path)
df = pd.read_sql_query("SELECT * FROM 'DICTIONARY'", con)

# Verify that result of SQL query is stored in the dataframe
print(df.head())

con.close()
# Data to be written
dictionary = {
}

df = df.fillna(0)

df = df.reset_index()  # make sure indexes pair with number of rows

for index, row in df.iterrows():
    quran = row["quran_occurrence"]

    dictionary[str(int(row['id']))] = \
    {
        "word": str(row["word"]),
        "definition": str(row["definition"]),
        "is_root": row["is_root"],
        "parent": row["parent_id"],
        "quran": quran,
    }
    if(index == 0):
        print(row['word'],row["definition"])

import json


 
# Serializing json
json_object = json.dumps(dictionary, indent=4)
 
# Writing to sample.json
with open(os.path.join(BASE_DIR, "new_data.json"), "w") as outfile:
    outfile.write(json_object)
    
print(dictionary["4"]["word"] == "اب")