FROM docker-registry.na.intgdc.com/gdc:R24_6
RUN yum install -y openssl-devel python-pip libffi-devel libjpeg-turbo-devel gcc
RUN pip install tox
