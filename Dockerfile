ARG APPLICATION=graalvm-native-cli-example

FROM container-registry.oracle.com/graalvm/native-image:21.0.4 AS graalvm-native-image-builder
ARG \
    # https://maven.apache.org/docs/history.html
    MAVEN_VERSION="3.9.9" \
    # https://gradle.org/releases/
    GRADLE_VERSION="8.10"
ENV \
    M2_HOME="/opt/apache-maven-${MAVEN_VERSION}" \
    GRADLE_HOME="/opt/gradle-${GRADLE_VERSION}" \
    PATH=\
"${PATH}"\
":/opt/apache-maven-${MAVEN_VERSION}/bin"\
":/opt/gradle-${GRADLE_VERSION}/bin"

# Required Dependencies
RUN microdnf update -y; \
    microdnf install tar gzip unzip findutils -y; \
    microdnf clean all;

# Maven
RUN mkdir -p ${M2_HOME}; \
    curl --silent --fail --output ${M2_HOME}/../apache-maven-${MAVEN_VERSION}-bin.tar.gz https://dlcdn.apache.org/maven/maven-${MAVEN_VERSION%%.*}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz; \
    curl --silent --fail --output ${M2_HOME}/../apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512 https://dlcdn.apache.org/maven/maven-${MAVEN_VERSION%%.*}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512; \
    cd ${M2_HOME}/..; \
    echo "$(cat apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512) apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha512sum --quiet --strict --check -; \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512; \
    cd --; \
    tar --extract --file ${M2_HOME}/../apache-maven-${MAVEN_VERSION}-bin.tar.gz --directory ${M2_HOME} --strip-components 1 --no-same-owner; \
    rm ${M2_HOME}/../apache-maven-${MAVEN_VERSION}-bin.tar.gz; \
    if [ ! $(command -v mvn) ]; then echo "Error when trying to install Maven"; exit 1; else mvn --version; fi;

# Gradle
RUN mkdir -p ${GRADLE_HOME}; \
    curl --silent --fail --output ${GRADLE_HOME}/../gradle-${GRADLE_VERSION}-bin.zip --location --remote-name --url https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip; \
    curl --silent --fail --output ${GRADLE_HOME}/../gradle-${GRADLE_VERSION}-bin.zip.sha256 --location --remote-name --url https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256; \
    cd ${GRADLE_HOME}/..; \
    echo "$(cat gradle-${GRADLE_VERSION}-bin.zip.sha256) gradle-${GRADLE_VERSION}-bin.zip" | sha256sum --quiet --strict --check -; \
    rm gradle-${GRADLE_VERSION}-bin.zip.sha256; \
    cd --; \
    unzip -qq ${GRADLE_HOME}/../gradle-${GRADLE_VERSION}-bin.zip -d ${GRADLE_HOME}/..; \
    rm ${GRADLE_HOME}/../gradle-${GRADLE_VERSION}-bin.zip; \
    if [ ! $(command -v gradle) ]; then echo "Error when trying to install Gradle"; exit 1; else gradle --version; fi

FROM graalvm-native-image-builder AS graalvm-native-image-application-builder
COPY . /app
RUN mvn clean install --file /app/pom.xml

FROM docker.io/almalinux:9.4-minimal-20240723
ARG APPLICATION
COPY --from=graalvm-native-image-application-builder /app/target/${APPLICATION} /usr/local/bin/${APPLICATION}