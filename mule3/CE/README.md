# Docker Image packaging for [Mule](https://www.mulesoft.com/platform/mule) CE runtime engine

##### Note: This image uses the Community Edtion of the Mule runtime.

### Usage
Basic example of starting a container:
```
$ docker run -ti rprins/mule3-ce
```

Example of starting the container using HTTP port 8081 mapping and locally mounted data volume:  
```
$ docker run -ti --name="mule3-ce" -p 8081:8081 -v ~/mule/apps:/opt/mule/apps -v ~/mule/logs:/opt/mule/logs rprins/mule3-ce
```

Or, if you wish to start the container in detached mode, use the following command:   
```
$ docker run -d --name="mule3-ce" -p 8081:8081 -v ~/mule/apps:/opt/mule/apps -v ~/mule/logs:/opt/mule/logs rprins/mule3-ce
```


#### Relevant Mule folders and mappings
| Location          | Description                            | Local folder mapping |
|------------------ |----------------------------------------|----------------------|
|/opt/mule/apps     | Mule Application deployment directory  | ~/mule/apps          |
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
The simplest way of deploying Mule applications is copying a deployable archive (.zip file, created with Anypoint Studio or Maven) to the mapped ~/mule/apps folder.


## Connecting to a running container
To connect to a running container, you can open a Bash shell
* First, retrieve the container's ID:  
`$ docker ps`
* Check the CONTAINER_ID column of the output
* Open a Bash shell on the container:  
`$ docker exec -t -i <CONTAINER_ID> /bin/bash`


## Running multiple instances
If you wish to run multiple Docker containers, for example to set up a load balanced runtime environment, make sure the provide a unique name, mount points and HTTP port mapping for each instance.  
It is recommended to run the containers in detached mode (using the -d option).  
Example:

```
$ docker run -d --name="mule01" -p 8081:8081 -v ~/mule/mule01/apps:/opt/mule/apps -v ~/mule/mule01/logs:/opt/mule/logs rprins/mule3-ce
$ docker run -d --name="mule02" -p 8082:8081 -v ~/mule/mule02/apps:/opt/mule/apps -v ~/mule/mule02/logs:/opt/mule/logs rprins/mule3-ce
```
