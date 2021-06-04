# Note This may need to be run before you run any other commands
# docker buildx create --use

# Login to AWS ECR to access images
aws ecr get-login-password --region us-west-2 | \
    docker login --username AWS --password-stdin 657285219065.dkr.ecr.us-west-2.amazonaws.com

docker buildx build . \
    --platform linux/arm64,linux/amd64 \
    --tag "657285219065.dkr.ecr.us-west-2.amazonaws.com/kwhadocker/data-env:$(git rev-parse --abbrev-ref HEAD)" \
    --push
