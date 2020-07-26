#!/usr/bin/bash -eu

REGION=us-east-1

$(aws ecr get-login --region $REGION --no-include-email)
