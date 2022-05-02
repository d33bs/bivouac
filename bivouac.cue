// referenced with modifications from: https://docs.dagger.io/1205/container-images
package main

import (
    "dagger.io/dagger"
    "universe.dagger.io/docker"
    "universe.dagger.io/docker/cli"
)

// Build referenced Dockerfile by filepath
#BuildImage: {

    filepath: string

    output: docker.#Dockerfile.output

    docker.#Dockerfile & {
        dockerfile: path: filepath
    }
}

dagger.#Plan & {
    client: { 
        filesystem: { 
            "./": read: contents: dagger.#FS
            "./src": read: contents: dagger.#FS
        }
        network: {
            "unix:///var/run/docker.sock": connect: dagger.#Socket
        } 
    }

    actions: {

        // Build image
        build: #BuildImage & {
            filepath: "./jupyter-dev.Dockerfile"
            source: client.filesystem."./".read.contents
        }

        // Attempt to run local container from build
        run: docker.#Run & {
                input: build.output
                ports: {
                    "web": {
                        frontend: dagger.#Socket & {
                            _id : "8888"
                        }
                        backend: {
                            protocol: "tcp"
                            address: "8888"
                        }
                    }
                }
                mounts: {
                    "src": {
                        dest: "./src"
                        contents: client.filesystem."./src".read.contents
                    }
                }
             
        }

        // Load image to local docker instance
        load: cli.#Load & {
            image: build.output
            host:  client.network."unix:///var/run/docker.sock".connect
            tag:   "jupyter-dev"
        }
    }
} 