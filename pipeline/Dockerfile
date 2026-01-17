# base image  we are building on
FROM python:3.13.11-slim
# copy uv binary from official uv image (multi-stage build pattern)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin
# (image to copy from) (/uv - what to copy) (/bin - where to copy to in our container)

# set up a working directory inside the container
WORKDIR /code
ENV PATH="/code/.venv/bin:$PATH"

# copying dependency file first (for better layer caching)
# copies all those 3 files into the directory ()./)
COPY pyproject.toml .python-version uv.lock ./
# install dependencies from uv.lock file(this was created when we created Venv) 
# makes sure dependencies installed in container are those also installed in Venv 
# (ensures reproducible builds)
RUN uv sync --locked


# copy the script to the container. 1st is source. 2nd is destination (what it should be in container)
COPY ingest_zone.py taxi_zone_lookup.csv .

# define what to do first when container runs
# we just run script here
# we break each part of command into tokens
ENTRYPOINT ["python", "ingest_zone.py"] 
# using single quote above gives error

