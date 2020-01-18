FROM python:3.7-slim

RUN mkdir -p /app
WORKDIR /app

COPY requirements.txt /app
RUN pip install -r requirements.txt
EXPOSE 5000

# Define environment variables
ENV MODEL_NAME test
ENV API_TYPE REST
ENV SERVICE_TYPE MODEL
ENV PERSISTENCE 0

# Add Model code
COPY text-summarization-tensorflow-master/*.py /app/

# Add pre-trained model weights
#RUN wget https://drive.google.com/open?id=1V8pS1eoiv51wfiVp2rOB7IvJ5PeQs2n-
#RUN wget https://drive.google.com/uc?export=download&confirm=l5j4&id=1V8pS1eoiv51wfiVp2rOB7IvJ5PeQs2n-
#RUN unzip pre_trained.zip
COPY pre_trained/*.pickle /app/

# Add sample data
COPY text-summarization-tensorflow-master/sample_data/ /app/

CMD exec seldon-core-microservice $MODEL_NAME $API_TYPE --service-type $SERVICE_TYPE --persistence $PERSISTENCE