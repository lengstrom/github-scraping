import pandas as pd

df = pd.read_json('out_995458.json')
filtered = df[df['fork'] == False]
names = filtered['name'].str.split('/').str.get(0).drop_duplicates()
