# GraalVM Native CLI Example

This project is a demonstration of a CLI built with GraalVM and Java. The application is compiled into a native binary
using GraalVM, with the entire build process containerized for consistency and ease of use. The result is a lightweight,
fast binary that can be deployed without the need for a JVM.

---

## Requirements

- Docker 27.2.0

---

## Run

```bash
docker run --rm --name ${PWD##*/} -it $(docker build --quiet .) \
  /bin/bash -c "head -c 10 /dev/random > ${PWD##*/}.txt; ${PWD##*/} ${PWD##*/}.txt; rm ${PWD##*/}.txt"
```