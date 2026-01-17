#!/usr/bin/env python
# coding: utf-8

# import needed libraries
import pandas as pd
from sqlalchemy import create_engine    # database connector
from tqdm.auto import tqdm              # helps monitor progress
import click                            # for cli parameters

# confirm environment pandas is using/imported from.
# our venv
# pd.__file__

# specify data type to ensure clean data type on load
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
parse_dates = ["tpep_pickup_datetime",
               "tpep_dropoff_datetime"
               ]


# install connector to database
# get_ipython().system('uv add sqlalchemy')

# we install binary version as that is faster
# get_ipython().system('uv add psycopg2-binary')

# install tqdm to help monitor progress
# get_ipython().system('uv add tqdm')


# how does this get the schema
# print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))


# ###### (MONITORED) INGESTION

# parameterizing with click
@click.command()
@click.option('--pg_user', default='root', help='PostgreSQL user')
@click.option('--pg_pass', default='root', help='PostgreSQL password')
@click.option('--pg_host', default='localhost', help='PostgreSQL host')
@click.option('--pg_port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg_db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--target_table', default='yellow_taxi_data', help='Target table name')
@click.option('--year', default=2021, help='Year of the data')
@click.option('--month', default=1, help='Month of the data')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table, year, month):
    
    # readability
    prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'
    url = f'{prefix}/yellow_tripdata_{year}-{month:02d}.csv.gz' # pads month with 0, width - 2 characters

    # create iterators instead of dataframes
    df_iter = pd.read_csv(url,
                        dtype=dtype,
                        parse_dates=parse_dates,
                        iterator= True,
                        chunksize= 100000
                    )

    # create connection
    engine = create_engine(f"postgresql://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}")

    # actual ingestion script
    first = True
    for chunk_df in tqdm(df_iter):
        
        # just create table with schema or column_names
            # it actually adds it to our dockerized database/postgres
        if first:
            chunk_df.head(0).to_sql(name=target_table, 
                              con=engine, 
                              if_exists='replace'
                              )
            print(f"Created table: {target_table}")
            first = False
        
        # load and monitor in batches
        chunk_df.to_sql(name=target_table, 
                        con=engine, 
                        if_exists='append'
                        )

        print("Inserted chunk:", len(chunk_df))


if __name__ == '__main__':
    run()

