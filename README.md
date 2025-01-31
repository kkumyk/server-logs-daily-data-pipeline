# Server Log Files Analysis | Data Pipeline
This is a capstone project built as a part of the [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)'s assignment.

## Problem Statement
Server Log files help to provide insights into how search engine crawlers navigate a website.
Typically, these files include:

- Time the request was made
- URL requested
- User agent supplied when making the request
- Response Code
- Size of response
- IP address of client making the request
- Referrer, the page that provided the link to make this request

Why looking at the contents of your site’s server logs? How this data pipeline can be used by SEO specialist? 
 
## Dataset Description
- Server logs data from a [site hosted on Heroku](https://kabardian-poems-collection-b906b8b63b33.herokuapp.com/), avaliable via [GitHub](https://github.com/kkumyk/heroku_access_log_files/releases/tag/v1.0.0).

- Frequevency of data extraction: daily.

## Main Objectives

Create an ELT data pipeline for processing server logs data inluding:

- <strong>Extract</strong> from Heroku server
- <strong>Load</strong> load the extracted data to Github Release
- <strong>Load</strong> the data into GCS and a data warehouse (BigQuery)
- <strong>Transform</strong> the data in the data warehouse (BigQuery) using dbt

Finally, the processed data will be presented in a Looker dashboard.
<hr>


## Technologies
- Infrastracture: <strong>Terraform</strong>
- Containerization: <strong>Docker</strong>
- Workflow orchestration: <strong>Kestra</strong>
- Data Storage: <strong>Google Cloud Platform</strong>
- Data Warehouse: <strong>BigQuery</strong>
- Transformations: <strong>dbt cloud</strong>
- Dashboard: <strong>Looker Studio</strong>

## Prerequisites

Install Docker Engine and Docker Desktop on Ubuntu 24.04

```bash
# install Docker Engine (used when we want to handle only one container)
docker --version # Docker version 27.4.1, build b9d17ea

# verify the installation run
sudo service docker start

# this command downloads a test image and runs it in a container
# when the container runs, it prints a confirmation message and exits
sudo docker run hello-world

# install Docker Compose (used when we have multiple containers to handle)
docker compose version # Docker Compose version v2.32.1

# install Postgres 
psql --version
psql (PostgreSQL) 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

# install CLI for Postgres
pgcli -v # Version: 4.0.1
```
## Create GCP Project Infrastructure with Terraform

The infrastructure we need consists of:

- a Cloud Storage Bucket (google_storage-bucket) for our Data Lake
- a BigQuery Dataset (google_bigquery_dataset)

See full indtallation instructions [here](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/1_intro_to_data_engineering/1_README.md#creating-gcp-project-infrastructure-with-terraform).

### Local Setup for GCP

- Create a project
  - setup a new project and write down:
    - Project number
    - Project ID

- Create a service account for the project and: 
  - download authentication keys to your computer
- Set env var to point to your downloaded GCP auth-key:
  - go to the folder where the key was saved and on the command line run the command below:
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS="url/to/your/key.json"
  ```
### Terraform Installation 

#### Ubuntu
When installing Terraform, either follow the instructions by downloading the binaries and adding them to path. Or ideally download Terraform from the Synaptic Package Manager and there will be no need to add it to the path.

[Terraform Installation on Linux/Ubuntu Instructions](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/1_intro_to_data_engineering/1_README.md#creating-gcp-project-infrastructure-with-terraform)


Add your project ID in <strong>variables.tf</strong>:
  ```tf
  variable "project" {
    description = "ADD-YOUR-PROJECT-ID_HERE"
  }
  ```
After following the commands below you should see "server_logs_bucket" in GCS and "server_logs_data" dataset in BigQuery.

```bash
# Refresh service-account's auth-token for this session:
gcloud auth application-default login

# Initialize configuration and import plugins for Google provider: cd to the folder with the Terraform config files and run the following command:
terraform init

# Create resources with Terraform plan; add your project ID when prompted:
terraform plan

# Create Infra with Apply; add your project ID when prompted and type "yes":
terraform apply
```

## Run Docker Compose Container

```bash
# change to the folder that includes your docker-compose.yaml file
cd kestra/

# build docker image
sudo docker compose build

# run docker compose in detached mode
sudo docker compose up -d

# wait untill the above command has finished running
# open http://localhost:8080/ in your brouser and add your flows via UI
# to run the 02_logs_2_gcs_2_bq.yaml flow don't press execute
# go to Triggers > "Backfill executions" > select the start date > "Execute backfills"
```

### Log File Analysis Examples
- [Streaming process NASA web access logs on GCP](https://q15928.github.io/2019/06/10/nasa-log-analysis/)
- [Scalable Log Analytics with Apache Spark — A Comprehensive Case-Study](https://towardsdatascience.com/scalable-log-analytics-with-apache-spark-a-comprehensive-case-study-2be3eb3be977)
- [Web Log Mining](https://medium.com/@dilshadakhan24/web-log-mining-association-rules-function-model-nasa-web-access-logs-c72eddc26bb4)