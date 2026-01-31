# 1. run on terminal 
    # i'm assuming you've gone past docker compose and you didn't delete your files
    # also need to be in pipeline directory (cd pipeline)
# docker compose up

# -------------------------------------
# 2. save this dockerfile "dockerfile.cj" in pipeline
# CJ's zone dockerfile
FROM python:3.13.11-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin

WORKDIR /code
ENV PATH="/code/.venv/bin:$PATH"

COPY pyproject.toml .python-version uv.lock ./

RUN uv sync --locked

# replace this part with script name and csv file name on your end
COPY ingest_zone.py taxi_zone_lookup.csv .

ENTRYPOINT ["python", "ingest_zone.py"] 

# -------------------------------------
# 3. run on terminal
# docker build -t ingest_zone:v001 -f Dockerfile.cj .
  
# -------------------------------------
# 4. run on terminal
    # since this container is not with docker compose, you need to specify network
# docker run -it --entrypoint=bash --network pipeline_default --rm ingest_green:v001

# 5. run on terminal (to execute ingest_zone script)
# uv run python ingest_zone.py
