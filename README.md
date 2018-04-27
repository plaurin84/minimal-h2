# minimal-h2

Minimalistic h2 database server in a container  
Based on openjdk:8-jre-alpine  
Automated build on docker hub

Defaults:
* Server installed in /opt/h2
* Data stored in /opt/h2-data

## Docker

Run your h2 server and args using docker's native arguments.

Examples:

* Using default h2 behaviour (Embedded mode):
```
docker run h2
```

* Using h2 in Server mode with shared tcp connections only:
```
docker run -p 9092:9092 h2 -tcp -tcpAllowOthers
```

* Using tcp connection, web client and external volume for h2 data persistence:
```
docker run -p 8082:8082 -p 9092:9092 -v <localdir>:/opt/h2-data h2 -web -webAllowOthers -tcp -tcpAllowOthers
```

## Kubernetes

You can use this docker image as a quick drop-in in kubernetes. Simply provide the relevant args, ports and volumes as you need.

Example:

* Using tcp connection, web client and external volume for h2 data persistence:
```
[...]
spec:
  containers:
    - name: minimal-h2
      image: plaurin/minimal-h2
      args:
        - web
        - webAllowOthers
        - -tcp
        - -tcpAllowOthers
      ports:
        - name: h2-web
          containerPort: 8082
        - name: h2-tcp
          containerPort: 9092
      volumeMounts:
        - name: h2-data
          mountPath: /opt/h2-data
    volumes:
[...]
```
