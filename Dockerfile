#
# Dockerfile
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.2.3
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# === Stage 1: Install dependencies ===========================================
FROM       crystallang/crystal:latest-alpine
RUN        ["apk", "add", "sqlite-dev"]

# === Stage 2: Build the microservice =========================================
USER       daemon
WORKDIR    var/tmp
COPY       src       api-lite/src/
COPY       etc       api-lite/etc/
COPY       data/db   api-lite/data/db/
COPY       shard.yml api-lite/
COPY       Makefile  api-lite/
WORKDIR    api-lite
USER       root
RUN        ["chown", "-R", "daemon:daemon", "."]
USER       daemon
RUN        ["make", "clean"]
RUN        ["make", "all"  ]

# === Stage 3: Run the microservice ===========================================
ENTRYPOINT ["bin/api-lited"]

# vim:set nu ts=4 sw=4:
