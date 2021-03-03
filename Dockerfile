# Copyright (C) 2016-2019 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:alpine as builder

ENV CGO_ENABLED=0
ENV GO111MODULE=on

RUN apk update \
    && apk add --no-cache git ca-certificates tzdata \
    && update-ca-certificates

RUN adduser -D -g '' appuser

ADD . ${GOPATH}/src/app/
WORKDIR ${GOPATH}/src/app

RUN go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/speedtest_exporter

# --------------------------------------------------------------------------------

FROM gcr.io/distroless/base

LABEL summary="Speedtest Prometheus exporter" \
      description="A Prometheus exporter for speedtest" \
      name="nlamirault/speedtest_exporter" \
      url="https://github.com/nlamirault/speedtest_exporter" \
      maintainer="Nicolas Lamirault <nicolas.lamirault@gmail.com>"

COPY --from=builder /go/bin/speedtest_exporter /usr/bin/speedtest_exporter

COPY --from=builder /etc/passwd /etc/passwd

EXPOSE 9112

ENTRYPOINT [ "/usr/bin/speedtest_exporter" ]
