// referenced with modifications from: https://docs.dagger.io/1205/container-images
package main

import (
    "dagger.io/dagger"
    "universe.dagger.io/docker"
)

// This action builds a docker image from a python app.
// Build steps are defined in an inline Dockerfile.
#PythonBuild: docker.#Dockerfile & {
    dockerfile: contents: """
        FROM python:3.9-alpine
        CMD python --version
        """
}

// Example usage in a plan
dagger.#Plan & {
    client: filesystem: "./": read: contents: dagger.#FS

    actions: build: #PythonBuild & {
        source: client.filesystem."./".read.contents
    }
}