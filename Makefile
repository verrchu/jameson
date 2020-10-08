IMAGE = ulidity/jameson
CONTAINER = jameson
NETWORK = ulidity

start:
	@ printf "CHECK VERSION: " && test -n "$(VERSION)" && printf "OK\n"

	@ docker run -d --network $(NETWORK) --name $(CONTAINER) $(IMAGE):$(VERSION)

build:
	@ printf "CHECK API_KEY: " && test -n "$(API_KEY)" && printf "OK\n"
	@ printf "CHECK VERSION: " && test -n "$(VERSION)" && printf "OK\n"

	@ docker build -t $(IMAGE):$(VERSION) --build-arg API_KEY=$(API_KEY) .

kill:
	@ docker rm -f $(CONTAINER)

publish:
	@ printf "CHECK VERSION: " && test -n "$(VERSION)" && printf "OK\n"

	@ docker push $(IMAGE):$(VERSION)

latest:
	@ printf "CHECK VERSION: " && test -n "$(VERSION)" && printf "OK\n"

	@ docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

bash:
	@ docker exec -it $(CONTAINER) /bin/bash

iex:
	@ docker exec -it $(CONTAINER) /app/_build/prod/rel/jameson/bin/jameson remote

register:
	@ printf "CHECK API_KEY: " && test -n "$(API_KEY)" && printf "OK\n"

	@ curl -X POST -H "Content-Type: application/json" \
		https://api.telegram.org/bot$(API_KEY)/setWebhook \
		-d '{"url": "https://ulidity.com/bot/jameson/notify"}'
