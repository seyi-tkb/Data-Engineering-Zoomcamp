import pandas as pd
from sqlalchemy import create_engine

table = "green_taxi"
url = "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet"

def ingest_green():
    
    df = pd.read_parquet(url, engine="pyarrow")

    engine = create_engine('postgresql://root:root@postgres:5432/ny_taxi')

    df.to_sql(name=table,
          con=engine,
          if_exists="replace")
    print(f'{table} table created.')


if __name__ == "__main__":
    ingest_green()