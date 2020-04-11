#!/bin/bash
docker rm data_develop

if [ "$1" == "--start-jupyter" ]; then
    docker-compose -f local-docker-compose.yml run -d --service-ports \
	-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
        -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" \
	--name data_develop data_env && \
        docker exec -d data_develop jupyter notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root --NotebookApp.token='kwh' && \
	docker exec -it data_develop bash
elif [ "$1" == "" ]; then
    docker-compose -f local-docker-compose.yml run -d --service-ports \
	-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
	-e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" \
	--name data_develop data_env && \
	docker exec -it data_develop bash
else
    echo "Invalid arg. Please indicate --start-jupyter if you want to start Jupyter."\
        "Don't add an argument if you want to exec into bash on docker startup."
fi

