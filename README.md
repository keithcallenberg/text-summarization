# text-summarization

Takes in a text passage and sends the summarized text in response, based on:
https://github.com/dongjun-Lee/text-summarization-tensorflow

* Seldon-based REST API endpoint with the following signature: POST /predict

* Kubernetes deployment using YAML with an autoscaling policy is also provided, but hasn't yet been tested.

### Build and run using docker-compose
```bash
docker-compose build && docker-compose up
```

### Build and run using docker
```bash
docker build -t keithcallenberg/text-summarization . && docker run -p 5000:5000 keithcallenberg/text-summarization
```

### Test with curl
```bash
curl -v 0.0.0.0:5000/predict -d '{"data":{"names":["text"],"ndarray":["australian foreign minister alexander downer called wednesday for the reform of the un security council and expressed support for brazil , india , japan and an african country to join the council ."]}}' -H "Content-Type: application/json"
```
