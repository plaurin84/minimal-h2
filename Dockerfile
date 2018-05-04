FROM openjdk:8-jre-alpine
ARG version
LABEL h2_version=$version
LABEL maintainer="Patrick Laurin <plaurin@inocybe.ca>"
WORKDIR /opt
ADD http://repo2.maven.org/maven2/com/h2database/h2/$version/h2-$version.jar h2.jar
ADD run.sh h2-run/
RUN mkdir h2-data
RUN apk add --no-cache bash python
CMD ["sh", "h2-run/run.sh"]
