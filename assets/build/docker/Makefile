# Makefile to generate documentation using jinja2 templates
# Constructs dependency makefiles to include for each document
# Creates local markdown files to include top level templates
# Makefile jinja2.mk from parent directory needs two variables set
# target_dir is the target directory for the generated markdown files
# template_dir is the template directory with the source templates

current_repo_top := $(shell git rev-parse --show-toplevel)
target_dir:= $(current_repo_top)/devkit/docker
template_dir := $(current_repo_top)/assets/templates/docker

include ../jinja2.mk
