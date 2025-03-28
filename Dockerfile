
FROM mwalbeck/python-poetry:2-3.12
# https://hub.docker.com/r/mwalbeck/python-poetry
# Alternative: FROM python:3.10.16-slim-bookworm

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Poetry (not needed if python-poetry image is used)
# RUN pip install poetry

# Install dependencies
RUN poetry install

# Expose the Hug API port
EXPOSE 3003

# Run the Hug API server
CMD ["poetry", "run", "python", "/app/reverse_proxy/main.py"]
# CMD ["tail", "-f", "/dev/null"]  # for debugging