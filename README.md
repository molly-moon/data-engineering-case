# Data Engineering Case: ETL Workflow
The goal of this project is to provide a solution for Business Inteligence team who needs to perform a market study on publicly available data of their competitors. The project features extraction, transformation and loading of Amazon Customer Reviews dataset and Netflix Prize dataset with Pyspark to a data warehouse (Amazon Redshift). The execution of task was demonstrated by using AWS Step Functions coded with AWS CloudFormation. Below I provide a shortcut to create exactly the same architecture on AWS environment.

Finally, a set of [SQL queries](https://github.com/molly-moon/data-engineering-case/blob/master/sql/business_queries.sql) was executed in order to respond to some business-related questions. [Here](https://raw.githubusercontent.com/molly-moon/data-engineering-case/master/emails.txt) you will find a business-oriented summary of the task, and also a slightly more technical one in a form of an email to stakeholders. 

## Data Transformation
Both datasets present user ratings of movies and series. 
- Netflix Prize data is a dataset publicly [available on Kaggle](https://www.kaggle.com/netflix-inc/netflix-prize-data),
- Amazon Customer Reviews is a dataset publicly [available on Amazon S3](https://s3.amazonaws.com/amazon-reviews-pds/readme.html). Only a small part refering to movies, videos, and series was used in this project.

In order to be able to compare the same movie/series titles described differently by both companies, a set of transformations was made, among other things: 
- removal of text in parenthesis,
- standardization of information about the movie/series, if present in the title,
- removal of special signs, double/trailing spaces,
- removal of irrelevant columns for this problem.

[Here](https://github.com/molly-moon/data-engineering-case/blob/master/data-transformation.py) you will find the script to perform complete transformation. [The final dataset](https://github.com/molly-moon/data-engineering-case/tree/master/final_data.parquet) contains the following columns: company, title, year, rating. It was saved to a columnar data format Parquet and loaded to Amazon Redshift. The diagram below ilustrates all data operations performed on each particular set of data. 

<p align=center>
  <img src="https://github.com/molly-moon/data-engineering-case/blob/master/images/logical-diagram.png" height=600/>
  </p>
<p align=center>

## State Machine Demo: Orchestrated ETL Workflow
The state machine built with AWS Step Functions consists of 5 steps, each performed by AWS Glue. First 2 steps execute data transformation, subsequent 2 create tables and load data to s3 and the last one executes queries within Redshift to answer some business related questions. 

- Step 1: 
    - Amazon Customer Reviews dataset processing and unload to S3,
    - Netflix Prize dataset processing and unload to S3,
- Step 2: Datasets join, further transformations and unload to S3,
- Step 3: Creation of schema and tables in Glue and Redshift,
- Step 4: Data insertion to Redshift,
- Step 5: Data querying within Redshift and unload of results to S3. 

<p align=center>
  <img src="https://github.com/molly-moon/data-engineering-case/blob/master/images/state-machine.png" height=400/>
  </p>
<p align=center>

## Launch CloudFormation Stack and Run State Machine 

In order to launch the app you need to create resources with Amazon Web Services. Below template defines all necessary infrastructure, permissions and operations to execute the whole data engineering task. It creates the following resources:
- A standard configured VPC (2 private and 2 public subnets, Internet Gateway, NAT Gateway, Route Tables),
- Amazon Lambda function (necessary only for the initial setup),
- an S3 bucket,
- Amazon Redshift cluster,
- a JDBC connection with Redshift for Glue,
- Secret Manager for Redshift secrets (password, username),
- 4 different AWS Glue jobs,
- a state machine with Step Functions,
- permissions: IAM roles, IAM policies, NACLs, security groups.

1. To launch the stack via the console, click on the button below (if necessary, change the default deployment region). Leave default stack parameters.

[<img src='https://github.com/molly-moon/app-object-detection/blob/master/images/cloudformation-launch-stack.png?raw=true'>](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=etl-queries&templateURL=https://ala-artifacts.s3.us-east-2.amazonaws.com/template.yml) 

Stack creation time: ~3 min

2. Retrieve password from Secrets Manager secret (default name: ```reviewssecret```)

3. Edit the AWS Glue connection and insert retrieved password into an empty ```Password``` field (default name: ```GlueRedshiftConnection```)

4. Run State Machine (default name: ```GlueJobStateMachine-{stack-name}```) with default input.

  State Machine execution time: ~15 min

5. Consult query results in S3 (default name: ```{stack-name}-databucket-{random-number}/insights/```)
