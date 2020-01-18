FROM python:3.7-slim
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 5000

# Define environment variables
ENV MODEL_NAME textsummarize
ENV API_TYPE REST
ENV SERVICE_TYPE MODEL
ENV PERSISTENCE 0

# Add Model code
CP MyModel.py /

# Add Model weights
CP MyModel_weights.h5 /

CMD exec seldon-core-microservice $MODEL_NAME $API_TYPE --service-type $SERVICE_TYPE --persistence $PERSISTENCE