# About this Repo

This is a fork of the Git repo of the Docker [official image](https://docs.docker.com/docker-hub/official_repos/) for [jenkins](hhttps://hub.docker.com/_/jenkins/).

# Additional packages

This images includes:

* Ruby
* Bundler
* AWS CLI
* Terraform
* Docker (client) and Docker Compose

# Jenkins version

2.138.2 LTS

# How to use this image

Refer to the [official site](https://github.com/jenkinsci/docker) on how to use this image. It's pretty the same.

To make it short:

```
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home mminks/docker-jenkins
```
