FROM python:3.7.4
LABEL maintainer="Sudheer Kondla, skondla@me.com"
#RUN apt-get -y install python3-pip
RUN mkdir /app
WORKDIR /app
COPY . /app
RUN groupadd -r migrate &&\
    useradd -r -g migrate -d /home/migrate -s /sbin/nologin -c "Docker image user" migrate
#RUN pip3 install --upgrade setuptools pip
RUN apt-get update
RUN apt-get install -y libzmq3-dev python3-pip
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt
#RUN cp lib/rdsAdmin.py /usr/lib/python3.7
#RUN cp lib/rdsAdmin.py /usr/local/lib/python3.7
RUN cp lib/* /usr/local/lib/python3.7
#RUN apt-get install -y apt-utils && apt-get install -y curl
RUN apt-get -y install curl
RUN chown -R migrate:migrate /app
USER migrate
ENTRYPOINT [ "python" ]
CMD [ "copyPlayedAssets2Target.py" ]
