# runtime image
ARG RUNTIME_IMAGE=swift:focal
FROM ${RUNTIME_IMAGE}
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
ADD swiftlint_linux.tar.gz /

# Print Installed SwiftLint Version
RUN swiftlint version
RUN echo "_ = 0" | swiftlint --use-stdin
CMD ["swiftlint", "lint"]
