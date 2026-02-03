FROM python:3.6-slim-buster

# Install system dependencies for mysqlclient, pyodbc, and curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-mysql-client \
    default-libmysqlclient-dev \
    unixodbc \
    unixodbc-dev \
    curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

EXPOSE 3637

CMD ["python", "views.py"]
