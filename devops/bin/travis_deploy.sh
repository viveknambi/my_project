#!/bin/bash -eux

if ! command -v aws >/dev/null 2>&1; then
  pip install --user awscli
  export PATH=$PATH:$HOME/.local/bin # put aws in the path
fi

export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

eval $(aws ecr get-login --region us-east-1 --no-include-email)

REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"

docker tag 3tier_api:latest ${REGISTRY}/three_tier_api
docker push ${REGISTRY}/three_tier_api

docker tag 3tier_web:latest ${REGISTRY}/three_tier_web
docker push ${REGISTRY}/three_tier_web

aws ecs update-service --cluster threetier-production --service api-production --force-new-deployment
aws ecs update-service --cluster threetier-production --service web-production --force-new-deployment
