#Base image
FROM python:3.9-slim
#Setting work directory within container
WORKDIR /app
#Copy requirements to be installed
COPY . /app
#Instal dependencies into install directory
RUN pip install -r requirements.txt
EXPOSE 8888
CMD ["python", "./app.py"]