FROM python:3.7-slim

RUN mkdir -p /app
WORKDIR /app

COPY requirements.txt /app
RUN pip install -r requirements.txt
EXPOSE 5000

# get NLTK dependencies
RUN python -c "import nltk; nltk.download('punkt')"

# Add Model code
COPY Summarize.py /app/

RUN apt-get update && apt-get install -y git zip wget
RUN git clone https://github.com/dongjun-Lee/text-summarization-tensorflow.git
COPY text-summarization-tensorflow/*.py /app/

# Add pre-trained model weights (gymnastics to download from google drive)
RUN wget --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://drive.google.com/uc?export=download&id=1V8pS1eoiv51wfiVp2rOB7IvJ5PeQs2n-' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1V8pS1eoiv51wfiVp2rOB7IvJ5PeQs2n-" -O pre_trained.zip && rm -rf /tmp/cookies.txt
RUN unzip pre_trained.zip
COPY pre_trained/ /app/
RUN rm pre_trained.zip

# Add sample data
RUN cd text-summarization-tensorflow && unzip sample_data.zip
COPY text-summarization-tensorflow/sample_data/ /app/

# Define environment variables
ENV MODEL_NAME Summarize
ENV API_TYPE REST
ENV SERVICE_TYPE MODEL
ENV PERSISTENCE 0

CMD exec seldon-core-microservice $MODEL_NAME $API_TYPE --service-type $SERVICE_TYPE --persistence $PERSISTENCE