# import libraries
import sys              # helps with parameterization on CMD (esp. sys.argv)
import pandas as pd     # pandas

# inserted parameter from CMD here 
month = int(sys.argv[1])    # [0] - scriptname, [1] or e'thing after - parameter itself 

print(f"hello piper, it's the {month}th month")

# test with df
df = pd.DataFrame({"day": [1, 2], "no. of passesngers": [3, 4]})
df["month"]= month

print(df.head())

# saves data in parquet format using parameterized name
df.to_parquet(f"output_{month}.parquet")


