#!/bin/bash

terraform import google_project_service.gcp_services["cloudresourcemanager.googleapis.com"] quadsci-exercise-aaron/cloudresourcemanager.googleapis.com && \
terraform import google_project_service.gcp_services["compute.googleapis.com"] quadsci-exercise-aaron/compute.googleapis.com && \
terraform import google_project_service.gcp_services["container.googleapis.com"] quadsci-exercise-aaron/container.googleapis.com