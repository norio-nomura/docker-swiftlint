# runtime image
ARG RUNTIME_IMAGE=swift:jammy
FROM ${RUNTIME_IMAGE}
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
ARG TARGETARCH
ADD swiftlint_linux_${TARGETARCH}.tar.gz /

# Print Installed SwiftLint Version
RUN ["swiftlint", "version"]
RUN echo "_ = 0" | exec swiftlint --use-stdin
CMD ["swiftlint", "lint"]
