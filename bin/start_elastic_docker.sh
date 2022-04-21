sudo docker run -d -p 9200:9200 -p 9300:9300 elasticsearch
sleep 5
rails r "Card.import force: true"
