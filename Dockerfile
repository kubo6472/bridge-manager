FROM dock.mau.dev/tulir/lottieconverter:alpine-3.18 AS lottie

FROM golang:1.21-alpine3.18 AS builder

COPY . /build/
RUN cd /build && ./build.sh

FROM alpine:3.18

COPY --from=lottie /cryptg-*.whl /tmp/
RUN apk add --no-cache bash curl jq git ffmpeg \
	# Python for python bridges
	python3 py3-pip py3-setuptools py3-wheel \
	# Common dependencies that need native extensions for Python bridges
	py3-magic py3-ruamel.yaml py3-aiohttp py3-pillow py3-olm py3-pycryptodome \
    && pip3 install /tmp/cryptg-*.whl && rm -f /tmp/cryptg-*.whl

VOLUME /data
COPY --from=builder /build/bbctl /usr/local/bin/bbctl
COPY --from=lottie /usr/lib/librlottie.so* /usr/lib/
COPY --from=lottie /usr/local/bin/lottieconverter /usr/local/bin/lottieconverter
COPY ./docker/run-bridge.sh /usr/local/bin/run-bridge.sh
ENV SYSTEM_SITE_PACKAGES=true

CMD /usr/local/bin/run-bridge.sh