# Server Log Files Analysis | Data Pipeline
This is a capstone project built as a part of the [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)'s assignment.

##  1. Problem Statement

<!-- For a case of building a data pipeline using daily data for a newly migrated website, provide suggestions with
what would be the most useful metrics to report on and how to group the data in the 4th dbt model. Provide the model example -->

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

## Data Flow Overview
1. <strong>Cron</strong>: Three Cron jobs are running daily:
   - Server logs are extracted via Heroku CLI.
   - <i>process_raw_txt_files.sh</i> bash script cleans the collected the data and splits it into CSV files. Each file contains data by day.
   - <i>upload_csv.sh</i> upload CSV files to a GitHub repository.
2. <strong>Kestra</strong>: CSV files now stored in the Github Release, will be orchestrated to GCP bucket and then ingested into <i>server_logs_data</i> Bigquery dataset.
 


##  2. Dataset Description
- Server logs data from a [site hosted on Heroku](https://kabardian-poems-collection-b906b8b63b33.herokuapp.com/), avaliable via [GitHub](https://github.com/kkumyk/heroku_log_files/releases/tag/daily-upload).

- Frequevency of data extraction: daily.

###  2.1. <a name='ExportLogsPeriodicallywiththeHerokuCLIhttps:devcenter.heroku.comarticlesheroku-cliinstall-the-heroku-cli'></a>Export Logs Periodically with the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#install-the-heroku-cli)

1. Setup a Cron Job to Extract Access Logs via Heroku CLI.

2. Use bash script to clean the data and extract the data into CSV files.

    ```bash
    # make the script executable:
    chmod +x process_raw_txt.sh

    #  confirm if the file is executable
    ls -l process_raw_txt.sh

    # run the script
    bash process_raw_txt.sh
    ```

3. Load CSV files into Github Release automatically.

  1. Create a repo: <i>heroku_log_files</i>
  2. Create an initial release in your target Github repository - <i>heroku_log_files</i>:
      - GitHub > Releases > Create a new release
      - Choose a tag: <i>daily-upload</i> > Create new tag
      - Release title: <i>Daily CSV Upload</i>
      - Publish release
  3. Generate a GitHub Personal Access Token (PAT) - needed to authenticate when uploading files via script.
  - GitHub > Settings > Developer Settings
  - Personal access tokens > Fine-grained tockens > Generate new token
  - Token name: Heroku Releases Automation
  - Set expiration date
  - Choose repositories you want this token to access:
    - Select "Only select repositories" and pick the relevant repository.
  - Set Permissions under <i>Permissions</i>:
      - Actions: Read and write if you're triggering workflows.
      - Contents: Read and write (to upload files/releases).
      - Metadata: Read-only (to read repo info).
  - Generate and copy the Token.


  4. Write a script <i>upload_csv.sh</i> using the GitHub CLI (gh) to automate uploading the CSV files: 
  
  ```bash
  #!/bin/bash

  # set variables
  REPO="your-github-repo"
  TAG="daily-upload" # release tag where files will be uploaded
  CSV_FOLDER="/your-local-folder-with-csvs/"  # path to your local CSV files

  # create release if it doesn't exist
  if ! gh release view "$TAG" --repo "$REPO" > /dev/null 2>&1; then
    gh release create "$TAG" --repo "$REPO" --title "Daily CSV Upload" --notes "Automated daily upload"
  fi

  # upload CSV files to the release
  for file in "$CSV_FOLDER"/*.csv; do
    echo "Uploading $file to release $TAG..."
    gh release upload "$TAG" "$file" --repo "$REPO" --clobber
  done

  echo "Upload complete!"
  ```
  - make the script executable:
  ```bash
  chmod +x upload_csv.sh
  ```

  - Install GitHub CLI if not installed:
  ```bash
  sudo apt update && sudo apt install gh -y # Ubuntu
  ```
  - Authenticate GitHub CLI:
  ```bash
  echo YOUR_TOKEN_HERE | gh auth login --with-token
  ```





##  3. Main Objectives

Create an ELT data pipeline for processing server logs data inluding:

- <strong>Extract</strong> from Heroku server
- <strong>Load</strong> load the extracted data to Github Release
- <strong>Load</strong> the data into GCS and a data warehouse (BigQuery)
- <strong>Transform</strong> the data in the data warehouse (BigQuery) using dbt

Finally, the processed data will be presented in a Looker dashboard.
<hr>


##  Technologies
- Infrastracture: <strong>Terraform</strong>
- Containerization: <strong>Docker</strong>
- Workflow orchestration: <strong>Kestra</strong>
- Data Storage: <strong>Google Cloud Platform</strong>
- Data Warehouse: <strong>BigQuery</strong>
- Transformations: <strong>dbt cloud</strong>
- BI tools: <strong>Looker Studio</strong>

##  5. Prerequisites

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
##  6. Create GCP Project Infrastructure with Terraform

The infrastructure we need consists of:

- a Cloud Storage Bucket (google_storage-bucket) for our Data Lake
- a BigQuery Dataset (google_bigquery_dataset)

See full indtallation instructions [here](https://github.com/kkumyk/data-engineering-zoomcamp/blob/main/1_intro_to_data_engineering/1_README.md#creating-gcp-project-infrastructure-with-terraform).

###  6.1. Local Setup for GCP

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
###  6.2. Terraform Installation 

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

##  7. Orchestration with Kestra
- docker-compose.yaml > <i>update "your-email-goes-here.com", row 45</i>
  - flows
    - 00_gcp_kv.yaml > <i>update rows 10, 28, 34</i>
    - 01_gcp_setup.yaml
    - 02_logs_2_gcs_2_bq.yaml



This section explains how to orchestrate the data ingestion into:
- <strong>GCP</strong> - the files from Github Release will be moved to a <i>server_logs_bucket</i> on Google Cloud Storage (GCS) and
- <strong>BigQuery</strong> - the data from CSV files will be ingested into a bigQuery dataset <i>daily_data</i>.


## Run Docker Compose Container
```bash
# change to the folder that includes your docker-compose.yaml file
cd kestra/

# build docker image
sudo docker compose build

# run docker compose in detached mode
sudo docker compose up -d
```

The above command will spin up two containers:
- kestra-postgres-1
- kestra-kestra-1

Wait untill the above command has finished running, open http://localhost:8080/ in your brouser and add your flows via UI: <i>Flows > Create </i>

Run <i>00_gcp_kv.yaml</i> and <i>01_gcp_setup.yaml</i>.

To run the <i>02_logs_2_gcs_2_bq.yaml</i> fike don't press <i>Execute</i> as it contains a trigger.

Go to Triggers > "Backfill executions" > Select the start date > "Execute backfills".

##  8. DBT

###  8.1. Prerequisites

Create 2 new empty datasets for your project in BigQuery:
- a development dataset, e.g.: <i>dbt_dev_env</i>
- a production dataset, e.g.: <i>dbt_prod_env</i>

<strong>Note:</strong> Make sure you select your region in accordance with the selected region of your entire project.

###  8.2. Setting Up dbt

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

###  8.3. Creating a dbt Cloud Project

To create a dbt Cloud project you will need:
- access to your data warehouse (BigQuery):
  - in your dbt project settings adjust Connections/BigQuery by uploading a service account JSON file via the Settings section; it will autopopulate the fields in that section.
- admin access to your repo, where you will have your dbt project

1. Connect dbt to BigQuery development dataset and to the Github repo by following [these instructions](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/04-analytics-engineering/dbt_cloud_setup.md).
2. In the IDE windows, press the green <i>Initilize</i> button to create the project files.
3. Inside dbt_project.yml, change the project name both in:
  - the name field and
  - right below the <i>models:</i> block. You may comment or delete the example block at the end.

###  8.4. Developing <i>log_files_analysis</i> dbt Project

#### Project Setup and Structure
<hr>

1. After setting up dbt Cloud account, in the Settings of your project rename the default name to "log_files_analysis".
2. Inside <i>dbt_project.yml</i>, change the project name both in:
    - the <i>name</i> field and
    - right below the <i>models</i> block. You may comment or delete the example block at the end.
      ```sql
      name: 'log_files_analysis' 

      models:
        log_files_analysis:
      ```
3. Under the <i>models</i> folder create two sub-folders:
    - <i>core</i>
    - <i>staging</i>

4. The <i>staging</i> folder contains <strong>schema.yml</strong>, which defines:
    - the data sources the models are going to use; here, the partitioned table <i>daily_data</i> from the <i>server_logs_data</i> BigQuery dataset will be used by the <i>stg_daily_data.sql</i> model
    - the schema for the <i>stg_daily_data</i> table that will be created under BigQuery's development dataset based on the <i>stg_daily_data.sql</i> dbt model using the <i>daily_data</i> table.

#### Models
<hr>

##### 1. stg_daily_data.sql (staging)

<i>stg_daily_data.sql</i> - this model referencing <i>bot_vs_human.sql</i> macro which separates requests by defining them either as a <i>bot</i> or as a <i>human</i> based on the data found in the <i>user_agent</i> column. E.g.: 
    
    Mozilla/5.0(compatible;YandexBot/3.0;+http://yandex.com/bots)

  The result of running <i>stg_daily_data.sql</i> model is a <i>stg_daily_data</i> view created under the <i>dbt_dev_env</i> with a column referencing bot vs human flag.

```bash
dbt build --select stg_daily_data.sql
```
<hr>

##### 2. page_categories.sql (core) - based on a provided seed data 

This module is using a <i>categories_by_page.csv</i> file - supplied wihtin <i>seeds</i> folder - listing all existing pages on the site. The file has two columns:
  - page url
  - page type: category vs regular page

The <i>page_categories.sql</i> model uses the seed file and extends it by a <i>cleaned_page_url</i> which contains the same data as in page_url trimmed the trailing slash at the end and the pagination. This version of the page urls will be used in the final dashboard.

```bash
dbt build --select page_categories.sql
```
<!-- TODO: -->
<!-- 
- run dbt seed by typing <code>dbt seed</code> in the dbt command line
- after refreshing the tab with the BigQuery you will see a new categories_by_page table that will contain the data from the seed file
After adding the CSV file to the seeds folder, run <code>dbt seed</code> command. -->
<!-- - as we are using the seed file as it is we don't need to create a model for it; simply running <code>dbt seed</code> will create a table in the BigQuery -->

<hr>

##### 3. daily_data_by_page.sql

This model is using previously created models:
- stg_daily_data.sql (staging)
- page_categories.sql (core)

To build your project run:
```bash
dbt build --select daily_data_by_page.sql
```
<hr>

##### 4. aggregated_data.sql

This model contains the following aggregated calculations:

  ```bash
  dbt build --select aggregated_data.sql
  ```



<hr>

Before going into production, make sure everything is submitted to gitgub.

The resulting Looker dashboard will contain the folloving information in its tables/graphs:

</hr>
<!-- 
#2d706c - green -->


##  9. Log File Analysis Examples
- [Streaming process NASA web access logs on GCP](https://q15928.github.io/2019/06/10/nasa-log-analysis/)
- [Scalable Log Analytics with Apache Spark — A Comprehensive Case-Study](https://towardsdatascience.com/scalable-log-analytics-with-apache-spark-a-comprehensive-case-study-2be3eb3be977)
- [Web Log Mining](https://medium.com/@dilshadakhan24/web-log-mining-association-rules-function-model-nasa-web-access-logs-c72eddc26bb4)




<!-- 
          ```yml
          version: 2

          sources:
              - name: staging
                database: gcp_project_id # replace with yours
                schema: log_files_data_all # same as your BigQuery dataset

                tables:
                    - name: daily_data # the partitioned table from your BigQuery dataset that consolidates all daily data
          ``` -->





<!-- - create categories_by_page.csv file in dbt cloud under the seeds folder
- use cat and then copy what’s on my terminal and paste the values into the all_pages.csv file
  ```bash
  cd to_the_folder_with_the_all_pages.csv
  cat categories_by_page.csv
  ``` -->
<!-- - add categories.sql to the models/core folder -->