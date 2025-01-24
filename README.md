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
- Infrastracture: Terraform
- Workflow orchestration: Kestra
- Data Storage: Google Cloud Platform
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
## [Creating GCP Project Infrastructure with Terraform](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/1_intro_to_data_engineering/1_README.md#creating-gcp-project-infrastructure-with-terraform)

The infrastructure we will need consists of a:

- Cloud Storage Bucket (google_storage-bucket) for our Data Lake
- BigQuery Dataset (google_bigquery_dataset)
### Local Setup for GCP

- Create a project
  - setup a new project and write down:
    - Project number
    - Project ID

- Create a service account for the project and: 
  - download authentication keys to your computer
- Set env var to point to your downloaded GCP auth-key:
- Go to the folder where the key was saved and on the command line run the command below:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="url/to/your/key.json"
```

### Terraform Installation 

When installing Terraform, either follow the instructions by downloading the binaries and adding them to path.
Or ideally download Terraform from the Synaptic Package Manager (if on Ubuntu) and there will be no need to add it to the path.

[Terraform Installation on Linux/Ubuntu Instructions](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/1_intro_to_data_engineering/1_README.md#creating-gcp-project-infrastructure-with-terraform)


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