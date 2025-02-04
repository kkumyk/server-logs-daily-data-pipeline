<!-- vscode-markdown-toc -->
* 1. [Problem Statement](#ProblemStatement)
* 2. [Dataset Description](#DatasetDescription)
* 3. [Main Objectives](#MainObjectives)
* 4. [Technologies](#Technologies)
* 5. [Prerequisites](#Prerequisites)
* 6. [Create GCP Project Infrastructure with Terraform](#CreateGCPProjectInfrastructurewithTerraform)
	* 6.1. [Local Setup for GCP](#LocalSetupforGCP)
	* 6.2. [Terraform Installation](#TerraformInstallation)
		* 6.2.1. [Ubuntu](#Ubuntu)
* 7. [Run Docker Compose Container](#RunDockerComposeContainer)
* 8. [Log File Analysis Examples](#LogFileAnalysisExamples)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->
# Server Log Files Analysis | Data Pipeline
This is a capstone project built as a part of the [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)'s assignment.

##  1. <a name='ProblemStatement'></a>Problem Statement
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
 
##  2. <a name='DatasetDescription'></a>Dataset Description
- Server logs data from a [site hosted on Heroku](https://kabardian-poems-collection-b906b8b63b33.herokuapp.com/), avaliable via [GitHub](https://github.com/kkumyk/heroku_access_log_files/releases/tag/v1.0.0).

- Frequevency of data extraction: daily.

##  3. <a name='MainObjectives'></a>Main Objectives

Create an ELT data pipeline for processing server logs data inluding:

- <strong>Extract</strong> from Heroku server
- <strong>Load</strong> load the extracted data to Github Release
- <strong>Load</strong> the data into GCS and a data warehouse (BigQuery)
- <strong>Transform</strong> the data in the data warehouse (BigQuery) using dbt

Finally, the processed data will be presented in a Looker dashboard.
<hr>


##  4. <a name='Technologies'></a>Technologies
- Infrastracture: <strong>Terraform</strong>
- Containerization: <strong>Docker</strong>
- Workflow orchestration: <strong>Kestra</strong>
- Data Storage: <strong>Google Cloud Platform</strong>
- Data Warehouse: <strong>BigQuery</strong>
- Transformations: <strong>dbt cloud</strong>
- BI tools: <strong>Looker Studio</strong>

##  5. <a name='Prerequisites'></a>Prerequisites

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
##  6. <a name='CreateGCPProjectInfrastructurewithTerraform'></a>Create GCP Project Infrastructure with Terraform

The infrastructure we need consists of:

- a Cloud Storage Bucket (google_storage-bucket) for our Data Lake
- a BigQuery Dataset (google_bigquery_dataset)

See full indtallation instructions [here](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/1_intro_to_data_engineering/1_README.md#creating-gcp-project-infrastructure-with-terraform).

###  6.1. <a name='LocalSetupforGCP'></a>Local Setup for GCP

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
###  6.2. <a name='TerraformInstallation'></a>Terraform Installation 

####  6.2.1. <a name='Ubuntu'></a>Ubuntu
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

##  7. <a name='RunDockerComposeContainer'></a>Run Docker Compose Container

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

## DBT

### Prerequisites

Create 2 new empty datasets for your project in BigQuery:
- a development dataset, e.g.: <i>dbt_dev_env</i>
- a production dataset, e.g.: <i>dbt_prod_env</i>

<strong>Note:</strong> Make sure you select your region in accordance with the selected region of your entire project.

### Setting Up dbt

1. [Create a dbt user account](https://www.getdbt.com/signup) or [log in](https://cloud.getdbt.com/login) into the existing one.
2. Set up a GitHub repo for your project.
3. Connect dbt to BigQuery development dataset and to the Github repo by following ["How to setup dbt cloud with bigquery" instructions](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/4_analytics_engineering/4_README.md#setting-up-dbt).
<strong>Note:</strong> The steps for the current service account creation have slightly changed. E.g.: before you can actually create a new service account you will be first asked if you would like to re-use an existing one if such is already there. In this case, press "Continue" to land on a form to set up a new service account by proving your "Service account details".
  - add service account name, e.g.: <i>dbt-service-account</i>
  - press "create and continue"
  - in the "Grant this service account access to project" select "BigQuery Admin"
  - press "Done"
  - select newly created service account and navigate to its "KEYS" section
  - select "create new key" and the key type JSON; this will create and download the key file to your pc

### Creating a dbt Cloud Project

To create a dbt Cloud project you will need:
- access to your data warehouse (BigQuery):
  - in your dbt project settings adjust Connections/BigQuery by uploading a service account JSON file via the Settings section; it will autopopulate the fields in that section.
- admin access to your repo, where you will have your dbt project

1. Connect dbt to BigQuery development dataset and to the Github repo by following [these instructions](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/04-analytics-engineering/dbt_cloud_setup.md).
2. In the IDE windows, press the green Initilize button to create the project files.
3. Inside dbt_project.yml, change the project name both in:
  - the name field and
  - right below the <i>models:</i> block. You may comment or delete the example block at the end.

### Developing <i>log_files_analysis</i> Project
1. After setting up dbt Cloud account, in the Settings of your project rename the default name to "log_files_analysis".
2. Inside dbt_project.yml, change the project name both in:
    - the name field and
    - right below the <i>models:</i> block. You may comment or delete the example block at the end.
      ```sql
      name: 'log_files_analysis' 

      models:
        log_files_analysis:
      ```
3. Under the model folder create two folders:
    - code
    - staging

4. In the staging folder create two files:
  - <strong>schema.yml</strong>, here define:
    - the database the data will be coming from
    - the schema
    - the source table
    ```yml
    version: 2

    sources:
        - name: staging
          database:  your-BigQuery-dataset-name # your BigQuery data base name
          schema: log_files_data_all # same as your BigQuery dataset

          tables:
              - name: daily_data # the partitioned table from your BigQuery dataset that consolidates all daily data
    ```
  - <strong>stg_daily_data.sql</strong> will contain:

5. Build your project.

```bash
dbt build --select stg_daily_data.sql
```


For a case of builting a data pipeline using daily data for a newly migrated website, provide suggestions with
what would be the most useful metrics to report on and how to group the data in the 4th dbt model. Provide the model example


Update model #1 stg_daily_data.sql by referencing a macto in it:
- create a reusable macro to classify requests as bot and human based on user_agent;
  - e.g.: Mozilla/5.0(compatible;YandexBot/3.0;+http://yandex.com/bots)
- reference this macro in your model
- the result of running this model is an updated daily view data with a column referencing the bots vs human flag

Create a seed based model #2:
- add a seed file, e.g.: a CSV with all existing pages on the site with columns:
  - page url
  - page type: category vs regular page
- create seed based dbt model (all_pages.sql) in the Core folder that will produce a table instead of a view

Create model #3:
- this model will reference the previously created models and join all data into a single table
- create a model #3 in the Core folder that will reference:
  - the staging model #1 - daily data with extra column that splits bots and humans
  - the seed based model #2 - all avaliable pages on the site with the page categorisation
  - LEFT JOIN tables on the page url

Create model #4:
- this model contains the following calculations:

PROVIDE SUGGESTIONS FOR THIS SECTION


The Looker dashboard will contain the folloving information in its tables/graphs:
- 
PROVIDE SUGGESTIONS FOR THIS SECTION




##  8. <a name='LogFileAnalysisExamples'></a>Log File Analysis Examples
- [Streaming process NASA web access logs on GCP](https://q15928.github.io/2019/06/10/nasa-log-analysis/)
- [Scalable Log Analytics with Apache Spark — A Comprehensive Case-Study](https://towardsdatascience.com/scalable-log-analytics-with-apache-spark-a-comprehensive-case-study-2be3eb3be977)
- [Web Log Mining](https://medium.com/@dilshadakhan24/web-log-mining-association-rules-function-model-nasa-web-access-logs-c72eddc26bb4)