# About this Repo

This is a fork of the Git repo of the Docker [official image](https://docs.docker.com/docker-hub/official_repos/) for [jenkins](hhttps://hub.docker.com/_/jenkins/).

This images includes ruby and bundler.

# Jenkins version

2.19.4 LTS

# How to use this image

Refer to the [official site](https://github.com/jenkinsci/docker) on how to use this image. It's pretty the same.

To make it short:

```
docker run -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home mminks/docker-jenkins
```
