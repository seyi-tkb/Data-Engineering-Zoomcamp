#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd


# In[3]:


# confirm environment pandas is using/imported from.
# our venv
pd.__file__


# In[20]:


# readability
prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'
url = f'{prefix}/yellow_tripdata_2021-01.csv.gz'

# Read a sample of the data
df = pd.read_csv(url)


# In[ ]:


# Check data types
df.dtypes


# ###### To prevent type issue, clean data type on load as opposed to after.

# In[23]:


# clean data type on load
dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

# Parse dates
parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]


# In[29]:


# Read a sample of the data
df = pd.read_csv(url,
                 dtype=dtype,
                 parse_dates=parse_dates
                )


# In[30]:


# Check data types
df.dtypes


# In[28]:


# Check data shape
df.shape


# In[39]:


# install connector to database
get_ipython().system('uv add sqlalchemy')


# In[40]:


# we install binary version as that is faster
get_ipython().system('uv add psycopg2-binary')


# In[46]:


# install tqdm to help monitor progress
get_ipython().system('uv add tqdm')


# In[41]:


# import our downloaded database connector
from sqlalchemy import create_engine

# create connection
engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')


# ###### Now we can use `df.sql` to insert into database

# In[42]:


# how does this get the schema
print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))


# In[44]:


# just create table with schema or column_names
# it actually adds it to our dockerized database/postgres
df.head(0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')


# ###### (MONITORED) INGESTION

# In[51]:


# create iterators instead of dataframes
df_iter = pd.read_csv(url,
                      dtype=dtype,
                      parse_dates=parse_dates,
                      iterator= True,
                      chunksize= 100000
                )


# In[52]:


# helps monitor progress
from tqdm.auto import tqdm


# In[53]:


# actual ingestion script
# load and monitor in batches
for chunk_df in tqdm(df_iter):
    chunk_df.to_sql(name='yellow_taxi_data', 
                    con=engine, 
                    if_exists='append')

    print("Inserted chunk:", len(chunk_df))

# what if i wanted to make it such that it doesn't ingest data it has loaded before in case of retries
# basically one of ACID


# In[ ]:




