# Docker Image packaging for [Mule](https://www.mulesoft.com/platform/mule) EE runtime engine with license

##### Note: A valid Mule EE license file (license.lic) is required. Do not attempt to start the container without providing a license file. Before building the image, Put your license file (license.lic) in the resources folder (see Step 2).

## Getting started
###### Step 1: Obtain Docker image files
* Clone this GitHub repository:  
`$ git clone https://github.com/rajprins/mule-docker.git`
* From the location where you cloned the GitHub repo files, navigate to folder `mule4/EE-license/`

###### Step 2: Provide a license file
* A valid Mule Enterprise Edition license file is required. Do not attempt to start the container without providing a license file
* Put your license file (mule4-ee-license.lic) in the resources folder

###### Step 3: Build a Docker base image
* Navigate to the folder that contains the cloned Docker file
* Build and tag the Docker base image from current location:  
`$ docker build --tag="mule4-ee" .`

###### Step 4: Run the Docker image
* Run the image (with port 8081 mapped and locally mounted data volume) using this command:  
`$ docker run -t -i --name="mule4-ee" -p 8081:8081 -v ~/mule/apps:/opt/mule/apps -v ~/mule/logs:/opt/mule/logs mule4-ee`
* Or, if you wish to run the same configuration in detached mode:  
`$ docker run -d --name="mule4-ee" -p 8081:8081 -v ~/mule/apps:/opt/mule/apps -v ~/mule/logs:/opt/mule/logs mule4-ee`


#### Relevant Mule folders and mappings
For deploying applications and accessing log files, these mount points are mapped to local folders:

| Location          | Description                            | Local folder mapping |
|------------------ |----------------------------------------|----------------------|
|/opt/mule/apps     | Mule applications deployment directory | ~/mule/apps          |
|/opt/mule/domains  | Mule Domains deployment directory      | ~/mule/domains       |
|/opt/mule/logs     | Logs directory                         | ~/mule/logs          |


#### Exposed ports
| Port | Description                                                    |
|----- |----------------------------------------------------------------|
| 8081 | Default port for HTTP inbound endpoints                        |
| 7777 | MMC Agent default port                                         |
| 5005 | Remote debugger default port                                   |
| 9997 | Mule Agent default port                                        |
| 1098 | JMX default port                                               |


## Deploying applications
The simplest way of deploying Mule applications is to copy a deployable archive (.jar file, created with Anypoint Studio or Maven) to the mapped ~/mule/apps folder.

Alternatively, you can install the Mule Agent and register your Mule runtime with the Anypoint Runtime Manager. Details can be found [here](https://docs.mulesoft.com/runtime-manager/managing-servers#add-a-server). Now you can use the Anypoint Runtime Manager to deploy and monitor Mule applications.


## Connecting to a running container
To connect to a running container, you can open a Bash shell
* First, retrieve the container's ID:  
`$ docker ps`
* Check the CONTAINER_ID column of the output
* Open a Bash shell on the container:  
`$ docker exec -t -i <CONTAINER_ID> /bin/bash`


## Running multiple containers
If you wish to run multiple Docker containers, for example to set up a load balanced runtime environment, make sure the provide a unique name, mount points and HTTP port mapping for each instance. Note that it is highly recommended to run the containers in detached mode.  
Example:

```
$ docker run -d --name="mule01" -p 8081:8081 -v ~/mule/mule01/apps:/opt/mule/apps -v ~/mule/mule01/logs:/opt/mule/logs mule4-ee

$ docker run -d --name="mule02" -p 9081:8081 -v ~/mule/mule02/apps:/opt/mule/apps -v ~/mule/mule02/logs:/opt/mule/logs mule4-ee
```

## Setting up a cluster
It is possible to easily set up a cluster with 2 nodes using Docker Compose:
* From the location where you cloned the GitHub repo files, navigate to folder `mule3/EE-license/cluster`
* To launch the cluster and see logs in console, run  
`$ docker-compose up`
* Or, to launch the cluster in detached mode, run  
`$ docker-compose up -d`


This will launch two containers, both with a Mule EE runtime, configured to run in a multicast-enabled cluster.
* Service `mule01`:
  * bind `mule01:8081` to `localhost:8081`
  * mount `/opt/mule/apps` volume to `~/mule/cluster/mule01/apps`
  * mount `/opt/mule/logs` volume to `~/mule/cluster/mule01/logs`
* Service `mule02`:
  * bind `mule02:8081` to `localhost:9081`
  * mount `/opt/mule/apps` volume to `~/mule/cluster/mule02/apps`
  * mount `/opt/mule/logs` volume to `~/mule/cluster/mule02/logs`

Edit `docker-compose.yml` to fit your preferred configuration
