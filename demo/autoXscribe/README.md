# Auto trascribe demo

## Dependencies
* Authentication using Google's service account
 
Authenticate using Google service account and short-lived OAuth tokens. Namely,
it is assumed that the user has access to a Google service account key file 
(json format), which must be stored safely in the server. 
Newly-generated access_token is only temporary.

See https://cloud.google.com/speech/docs/common/auth.
For an example, see https://cloud.google.com/speech/docs/getting-started.

* Authentication using Microsoft's subscription key

See the following links:

https://www.microsoft.com/cognitive-services/en-us/subscriptions

https://www.microsoft.com/cognitive-services/en-us/Speech-api/documentation/API-Reference-REST/BingVoiceRecognition

* RabbitMQ
```bash
sudo apt-get install rabbitmq-server
```
* Node packages
```bash
npm install amqplib
npm install node-uuid
```
