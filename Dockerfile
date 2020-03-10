#GENERATE CODE FROM SAMPLE JSON USING DSLTOOL
FROM flaviostutz/ruller-dsl-feature-flag as BUILD

#geolite database
#Signup on https://dev.maxmind.com/geoip/geoip2/geolite2/
#Check https://www.maxmind.com/en/end-user-license-agreement
#Download manually the database "GeoLite2 City"
#Add to your workspace and uncomment the line below
# ADD /GeoLite2-City.tar.gz /opt/
# RUN cd /opt && \
#     tar -xvf GeoLite2-City.tar.gz && \
#     mv */GeoLite2-City.mmdb /opt/Geolite2-City.mmdb

#city state csv for Brazil
RUN curl https://raw.githubusercontent.com/chandez/Estados-Cidades-IBGE/master/Municipios.sql --output /opt/Municipios.sql
RUN awk -F ',' '{print "BR," $4 "," $5}' /opt/Municipios.sql | sed -e "s/''/#/g"  | sed -e "s/'//g" | sed -e "s/)//g" | sed -e "s/;//g" | sed -e s/", "/,/g | sed -e "s/#/'/g" > /opt/city-state.csv

#add json rules and generate code for them
ADD /domains.json /opt/
ADD /menu.json /opt/
RUN ruller-dsl-feature-flag \
    --log-level=info \
    --source=/opt/domains.json,/opt/menu.json \
    --target=/opt/rules.go \
    --condition-debug=true

#just for build cache optimization
ADD /sample/main.dep $GOPATH/src/sample/main.go
RUN go get -v sample

#now build generated code
RUN cat -n /opt/rules.go
RUN cp /opt/rules.go $GOPATH/src/sample/
ADD /sample/main.go  $GOPATH/src/sample/
RUN go get -v sample



#RUNTIME CONTAINER
# FROM scratch
FROM golang:1.10
COPY --from=BUILD /go/bin/* /bin/
# COPY --from=BUILD /opt/Geolite2-City.mmdb /opt/
COPY --from=BUILD /opt/city-state.csv /opt/
ENV LOG_LEVEL=info
ADD /customer-group1.txt /opt/customer-group1.txt
ADD /startup.sh /
CMD [ "sh", "-C", "/startup.sh" ]

