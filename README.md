# minimal-h2

Minimalistic way to run h2 database server in a docker container.  
Based on openjdk:8-jre-alpine.
Assuming you understand how h2 and docker works!

Dockerfile defaults:
* h2 installed in /opt/h2.jar
* Run script installed in /opt/h2-run/run.sh
* Data stored in /opt/h2-data/*
* WORKDIR is /opt
* bash and python pre-installed, making the image ansible-ready

## Build container from source

Here's an example to understand how to configure and run your h2 database.  
Here, we setup shared tcp connection and custom password.  
#### Step1 - Modify run.sh

* Section **h2 database server:** Provide additional tcp arguments in run.sh:  
```
java -jar h2.jar -baseDir /opt/h2-data -tcp -tcpAllowOthers &
```

* Section **Init Stage:** Customise your database in run.sh (here, we change the default users's password):
```
java -cp h2.jar org.h2.tools.Shell -url "jdbc:h2:tcp://localhost/test" -user sa -sql "ALTER USER sa SET PASSWORD 'notdumbpassword';"
```

* Section **Shell Runtime:** This keeps the container alive and provides graceful shutdown. Don't touch this.

#### Step 2 - Build your docker image
Set your specific h2 version as a build arg.
```
docker build -t h2 --build-arg version=<version> .
docker run -p 9092:9092 h2
```
Example using 1.4.196
```
docker build -t h2 --build-arg version=1.4.196 .
docker run -p 9092:9092 h2
```

## Run in Kubernetes

You can use this docker image in kubernetes, as I publish images for specific versions in the public docker hub.  
See: https://hub.docker.com/r/plaurin/minimal-h2  
Simply provide a custom run.sh through a configmap or secret, to override the default one.  
-- Always use a kubernetes secret, instead of a configmap if you provide any kind of sensitive data or password.

Here's an example with h2 version 1.4.196, shared tcp connection, custom password and some additional shell tools:

* kubernetes configmap
```
apiVersion: v1
kind: ConfigMap
metadata:
    name: h2-config
data:
    run.sh: |
      #!/bin/sh

      #--------------------#
      # h2 database server #
      #--------------------#
      java -jar h2.jar -baseDir /opt/h2-data -tcp -tcpAllowOthers &

      #------------#
      # Init stage #
      #------------#
      java -cp h2.jar org.h2.tools.Shell -url "jdbc:h2:tcp://localhost/test" -user sa -sql "ALTER USER sa SET PASSWORD 'dumbpass';"
      apk add --no-cache bash curl unzip

      #---------------#
      # Shell Runtime #
      #---------------#
      trap 'pkill java; exit 0' SIGTERM
      while true; do :; done
```

* kubernetes pod
```
apiVersion: v1
kind: Pod
metadata:
    name: h2
    labels:
      env: demo
spec:
    containers:
      - name: h2
        image: plaurin/minimal-h2:1.4.196
        ports:
          - name: h2-tcp
            containerPort: 9092
        volumeMounts:
          - name: h2-config
            mountPath: /opt/h2-run
    volumes:
      - name: h2-config
        configMap:
          name: h2-config
```
* kubernetes service (to expose h2's tcp port)
```
apiVersion: v1
kind: Service
metadata:
    name: h2-tcp
spec:
    ports:
      - name: h2-tcp
        port: 9092
        targetPort: h2-tcp
    selector:
      env: demo
    type: LoadBalancer
```
