# Webserver Log File Analysis Data Pipeline
This is a capstone project built as a part of the [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)'s assignment.

<!-- TODO:

- secure credentials
- upload to github private repo

- authomate heroku log files data upload

- document -->

<!-- 
DONE:
- add task to the kestra flow to remove the files stored in gsc to save costs -->

## Problem Statement
Server Log files help to provide insights into how search engine crawlers navigate a website.
Typically, these files include:

- Time the request was made
- URL requested
- User agent supplied when making the request
- Response Code
- Size of response
- IP address of client making the request
- Time taken to serve the request
- Referrer, the page that provided the link to make this request

Why looking at the contents of your site’s server logs? How this data pipeline can be used by SEO specialist? 
 
## Dataset Description

- Frequevency: updated daily.
- Format:

## Main Objective

1. Select a dataset.
2. Create a pipeline for processing this dataset and putting it to a data warehouse (BigQuery).
4. Transform the data in the data warehouse (BigQuery) by using dbt: prepare it for the dashboard.
5. Create a dashboard.

## Technologies
- Containerization: Docker
- Workflow orchestration: Kestra
- Terraform
- Google Cloud Platform
- Data Warehouse: BigQuery
- Batch processing/Transformations: dbt cloud
- Dashboard: Google Data Studio

## Prerequisites

Install Docker Engine and Docker Desktop on Ubuntu 24.04

```bash
# install Docker Engine (used when we want to handle only one container)
docker --version # Docker version 27.4.1, build b9d17ea

# to verify the installation run
sudo service docker start
sudo docker run hello-world

# This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

# install Docker Compose (used when we have multiple containers to handle)
docker compose version # Docker Compose version v2.32.1

# Install Postgres 
psql --version
psql (PostgreSQL) 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

# Install CLI for Postgres
pgcli -v # Version: 4.0.1
```

## Terraform and Google Cloud Platform

### Local Setup for GCP

- Create a project
  - setup a new project and write down:
    - Project number
    - Project ID

- Create a service account for the log-analysis-pipline project and: 
  - download authentication keys to your computer
- Set env var to point to your downloaded GCP auth-key:
- Go to the folder where the key was saved and on the command line run the command below:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="url/to/your/key.json"
```

When installing Terraform, either follow the instructions by downloading the binaries and adding them to path. Or ideally download Terraform from the Synaptic Package Manager (if on Ubuntu) and there will be no need to add it to the path.

<hr>

```bash
# build docker image
sudo docker compose build

# run docker compose in detached mode
sudo docker compose up -d
```


#### Log File Analysis Examples
- [Streaming process NASA web access logs on GCP](https://q15928.github.io/2019/06/10/nasa-log-analysis/)
- [Scalable Log Analytics with Apache Spark — A Comprehensive Case-Study](https://towardsdatascience.com/scalable-log-analytics-with-apache-spark-a-comprehensive-case-study-2be3eb3be977)
- [Web Log Mining](https://medium.com/@dilshadakhan24/web-log-mining-association-rules-function-model-nasa-web-access-logs-c72eddc26bb4)




<!-- 
# SECRET_POSTGRES_DB ={{ "server_logs_db" | base64encode }} 
# SECRET_POSTGRES_USER ={{ "server_logs_analyst" | base64encode }} 
# SECRET_POSTGRES_PASSWORD ={{ "Lkjh87Gugj65L!jo(+_7j)" | base64encode }} 


# SECRET_KESTRA_USERNAME ={{ "k.a.kumyk@gmail.com" | base64encode }} 
# SECRET_KESTRA_PASSWORD ={{ "KH98yHIg65gu&&$Hgk)" | base64encode }}


# volumes:
#   postgres-data:
#     driver: local
#   kestra-data:
#     driver: local

# services:
#   postgres:
#     image: postgres
#     volumes:
#       - postgres-data:/var/lib/postgresql/data
#     environment:
#       POSTGRES_DB: "{{ secret('POSTGRES_DB') }}"
#       POSTGRES_USER: "{{ secret('POSTGRES_USER') }}"
#       POSTGRES_PASSWORD: "{{ secret('POSTGRES_PASSWORD') }}"
#     healthcheck:
#       test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
#       interval: 30s
#       timeout: 10s
#       retries: 10
#     ports:
#       - "5433:5432"

#   kestra:
#     image: kestra/kestra:latest
#     pull_policy: always
#     user: "root"
#     command: server standalone
#     volumes:
#       - kestra-data:/app/storage
#       - /var/run/docker.sock:/var/run/docker.sock
#       - /tmp/kestra-wd:/tmp/kestra-wd
#     environment:
#       KESTRA_CONFIGURATION: |
#         datasources:
#           postgres:
#             url: jdbc:postgresql://postgres:5432/kestra
#             driverClassName: org.postgresql.Driver
#             username: "{{ secret('POSTGRES_USER') }}"
#             password: "{{ secret('POSTGRES_PASSWORD') }}"
#         kestra:
#           server:
#             basicAuth:
#               enabled: false
#               username: "{{ secret('KESTRA_USER') }}"
#               password: "{{ secret('KESTRA_PASSWORD') }}"
#           repository:
#             type: postgres
#           storage:
#             type: local
#             local:
#               basePath: "/app/storage"
#           queue:
#             type: postgres
#           tasks:
#             tmpDir:
#               path: /tmp/kestra-wd/tmp
#           url: http://localhost:8080/
#     ports:
#       - "8080:8080"
#       - "8081:8081"
#     depends_on:
#       postgres:
#         condition: service_started





  # - id: gcp_project_id
  #   type: io.kestra.plugin.core.kv.Set
  #   key: GCP_PROJECT_ID
  #   kvType: STRING
  #   value: log-analysis-pipeline-448011

  # - id: gcp_location
  #   type: io.kestra.plugin.core.kv.Set
  #   key: GCP_LOCATION
  #   kvType: STRING
  #   value: europe-west2

  # - id: gcp_bucket_name
  #   type: io.kestra.plugin.core.kv.Set
  #   key: GCP_BUCKET_NAME
  #   kvType: STRING
  #   value: access_server_logs_bucket

  # - id: gcp_dataset
  #   type: io.kestra.plugin.core.kv.Set
  #   key: GCP_DATASET
  #   kvType: STRING
  #   value: access_logs_data



# Project ID: log-analysis-pipeline-448011
# Project number: 588270431793




#   ### Export Logs Periodically with the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#install-the-heroku-cli)

#   ```bash
#     # install Heroku CLI
#     curl https://cli-assets.heroku.com/install.sh | sh
#     heroku --version

#     heroku login

#     # If you prefer to stay in the CLI to enter your credentials, run:
#     # heroku login -i


#     # Run the log-fetching command manually to ensure it works and that the logs are saved correctly:
#     heroku logs --app kabardian-poems-collection --num=1500 > /home/karina/Documents/programming/data-engineering-project/postgres_docker/logs/$(date +%Y-%m-%d).txt

#     # Adjust the Cron Command
#     # For the date command, you need to escape the % characters for cron to interpret it correctly:
#     0 0 * * * heroku logs --app kabardian-poems-collection --num=1500 > /home/karina/Documents/programming/data-engineering-project/postgres_docker/logs/$(date +\%Y-\%m-\%d).txt && shutdown +5
#   ```

<!-- ## Accessing Web Server Log Files Using the Heroku CLI

# ## Automating the Script with Cron
# - Make the Script Executable:
#     Use the chmod command to change the file permissions and make the script executable:
#     ```bash
#     chmod +x fetch_heroku_logs.py
#     ```
# - To check that the script has become executable, use the ls -l command to list the file permissions:
#     ```bash
#     ls -l fetch_heroku_logs.py
#     ```
# - Edit the Crontab: Open your crontab file to add a new scheduled task:
#     ```sql
#     crontab -e
#     ```
# - Verify the Cron Job: To ensure the cron job was added, run:
#   ```bash
#   crontab -l
#   ``` -->


# <!-- Post:
# Small is beautiful.

# Docker and Docker Compose will be run via terminal and Docker Desktop will not be used in this pipeline. The reason for this mainly because after upgrading to Ubuntu 24.04, Docker Desktop is not supported nativelly and required several installation adjustments. Not being a big fan of UIs, the choise to switch to the CLI was not difficult to make. 
# The most important part now is to find the input files to use for this project.
# Can I use my tiny log txt files? The alternative is the massive six days access log. Should I create dummy files with python code? First extract the last 1000 rows from your blog. Is it a bad idea to test the whole pipeline on tiny 1000 rows files first?

# I need to start on a final data engineering project. I have a problem which is to find input files to use. I have a blog that generates tiny txt web server log files - 1000 lines max in a month. I also found a massive access log file of 3gb which only covers 5 days. What are the best ways of solve this: extract monthly data from a blog that generates small amount of access logs or to split the massige file into the 5 days? Or should I generate dummy access file monthly logs for a year to test the pipeline and expand the input generated by a blog? Any other suggestions of finding solid web access logs for the last 12 months? Or should I find a way to increase the visits to my blog to expand the size of server logs?

# --> -->