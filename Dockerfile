#GENERATE CODE FROM SAMPLE JSON USING DSLTOOL
FROM flaviostutz/ruller-dsl-feature-flag:1.2.1 as BUILD
RUN apk add curl

ARG MAXMIND_LICENSE_KEY

#geolite database
#Signup on https://dev.maxmind.com/geoip/geoip2/geolite2/
#Check https://www.maxmind.com/en/end-user-license-agreement
# download db if license is not empty
ADD /download-geolite2-city.sh /
RUN /download-geolite2-city.sh $MAXMIND_LICENSE_KEY

# download city state csv for Brazil
RUN curl https://raw.githubusercontent.com/chandez/Estados-Cidades-IBGE/master/Municipios.sql --output Municipios.sql
RUN awk -F ',' '{print "BR," $4 "," $5}' Municipios.sql | sed -e "s/''/#/g"  | sed -e "s/'//g" | sed -e "s/)//g" | sed -e "s/;//g" | sed -e s/", "/,/g | sed -e "s/#/'/g" > /opt/city-state.csv


#build cache warmup
WORKDIR /app
ADD /go.mod /app/
ADD /go.sum /app/
RUN go mod download


#add json rules
ADD /rules/ /app/


RUN echo "Generate Golang code from DSL JSONs"
#this executable needs /app/templates to be present
RUN ruller-dsl-feature-flag \
    --log-level=info \
    --source=/app/domains.json,/app/menu.json,/app/screens.json \
    --target=/app/rules.go \
    --condition-debug=true


#build generated code
RUN echo "Generated code at /app/rules.go"
RUN cat -n /app/rules.go
ADD /main.go /app/
RUN go build -o /bin/ruller-sample-feature-flag



#RUNTIME CONTAINER
FROM golang:1.14.3-alpine3.11
ENV LOG_LEVEL=info

COPY --from=BUILD /bin/ruller-sample-feature-flag /bin/
COPY --from=BUILD /opt/ /opt/
# /opt/Geolite2-City.mmdb
# /opt/city-state.csv

RUN echo "Copy group text definition to where json rules expects"
ADD /rules/customer-group1.txt /rules/
ADD /rules/specialCustomers.txt /rules/

ADD /startup.sh /

CMD [ "/startup.sh" ]

