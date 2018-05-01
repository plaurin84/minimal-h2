# minimal-h2

Minimalistic and versatile ways to run h2 database server in a docker container.  
Based on openjdk:8-jre-alpine, automated build on docker hub.  
Assuming you understand how h2 and docker works!

Defaults:
* h2 version 1.4.196 (2017-06-10)
* h2 database server installed in /opt/h2
* Run script (run.sh) installed in /opt/h2-run
* Data stored in /opt/h2-data
* WORKDIR is /opt

## Build from source

Example how to configure and run your h2 database using shared tcp connection and custom password.  
Modify run.sh accordingly:  

* **h2 database server** - Provide additional tcp arguments in run.sh:  
```
java -jar /opt/h2/bin/h2-1.4.196.jar -baseDir /opt/h2-data -tcp -tcpAllowOthers &
```

* **Init Stage** - Customise your database in run.sh (here, we change the default users's password):
```
java -cp /opt/h2/bin/h2-1.4.196.jar org.h2.tools.Shell -url "jdbc:h2:tcp://localhost/test" -user sa -password sa -sql "ALTER USER sa SET PASSWORD 'notdumbpassword';"
```

* **Shell Runtime** - This keeps the container alive and provides graceful shutdown. Don't touch this.

Build and run your docker container:
```
docker build -t h2 .
docker run -p 9092:9092 h2
```

## Kubernetes

You can use this docker image in kubernetes. Simply provide a custom run.sh through a configmap or secret, as you need. -- Never use a plain configmap if you provide any kind of sensitive data or password.

Example with shared tcp connection, custom password and additional shell applications:

* kubernetes configmap
```
apiVersion: v1
kind: ConfigMap
metadata:
    name: h2-config
data:
    run.sh: |
      #!/bin/sh
      H2="/opt/h2/bin/h2-1.4.196.jar"

      #--------------------#
      # h2 database server #
      #--------------------#
      java -jar $H2 -baseDir /opt/h2-data -tcp -tcpAllowOthers &

      #------------#
      # Init stage #
      #------------#
      java -cp $H2 org.h2.tools.Shell -url "jdbc:h2:tcp://localhost/test" -user sa -sql "ALTER USER sa SET PASSWORD 'dumbpass';"
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
      env: test
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
      env: test
    type: LoadBalancer
```
