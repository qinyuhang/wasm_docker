FROM alpine/git as builder
RUN git clone https://github.com/emscripten-core/emsdk.git

FROM python:3.8-alpine as stage_builder
ENV EMSCRIPTEN_VERSION=latest
WORKDIR /root
COPY --from=builder /git/emsdk /emsdk
RUN cd /emsdk && rm -rf .git
RUN cd /emsdk && ./emsdk install ${EMSCRIPTEN_VERSION} && ./emsdk activate ${EMSCRIPTEN_VERSION}

FROM python:3.8-slim
ENV EMSCRIPTEN_VERSION=latest
ENV EMSDK=/emsdk \
    EM_CONFIG=/emsdk/.emscripten \
    EMSDK_NODE=/emsdk/node/14.15.5_64bit/bin/node \
    PATH="/emsdk:/emsdk/upstream/emscripten:/emsdk/upstream/bin:/emsdk/node/14.15.5_64bit/bin:${PATH}"
WORKDIR /app
COPY --from=stage_builder /emsdk /emsdk
ENTRYPOINT ["emcc"]
CMD ["--help"]
