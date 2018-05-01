FROM openjdk:8-jre-alpine as builder
RUN apk add --no-cache curl unzip
RUN curl http://www.h2database.com/h2-2017-06-10.zip -o h2.zip
RUN unzip h2.zip

FROM openjdk:8-jre-alpine
WORKDIR /opt
RUN mkdir h2-data h2-run
COPY --from=builder h2 h2
ADD run.sh h2-run
RUN chmod +x h2-run/run.sh
CMD ["sh", "h2-run/run.sh"]
