#!/usr/bin/env bash

cd terraform
terraform destroy -force
rm plan.out
