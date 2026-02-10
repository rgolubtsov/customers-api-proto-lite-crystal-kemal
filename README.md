# Customers API Lite microservice prototype :small_blue_diamond: <img src="https://crystal-lang.org/reference/1.16/assets/crystal-circ.svg" style="border:0;width:32px" alt="Crystal" />

**A daemon written in Crystal, designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[Crystal](https://crystal-lang.org "The Crystal Programming Language")** port of the earlier developed **Customers API Lite microservice prototype**, written in V using **[veb](https://modules.vlang.io/veb.html "The V Web Server")** web server library/framework, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-vlang-veb/blob/main/README.md)** almost as is, without any principal modifications or adjustment.

This repo is dedicated to develop a microservice that implements a prototype of REST API service for ordinary Customers operations like adding/retrieving a Customer to/from the database, also doing the same ops with Contacts (phone or email) which belong to a Customer account.

The data scheme chosen is very simplified and consisted of only three SQL database tables, but that's quite sufficient because the service operates on only two entities: a **Customer** and a **Contact** (phone or email). And a set of these operations is limited to the following ones:

* Create a new customer (put customer data to the database).
* Create a new contact for a given customer (put a contact regarding a given customer to the database).
* Retrieve from the database and list all customer profiles.
* Retrieve profile details for a given customer from the database.
* Retrieve from the database and list all contacts associated with a given customer.
* Retrieve from the database and list all contacts of a given type associated with a given customer.

As it is clearly seen, there are no *mutating*, usually expected operations like *update* or *delete* an entity and that's made intentionally.

The microservice incorporates the **[SQLite](https://sqlite.org "A small, fast, self-contained, high-reliability, full-featured, SQL database engine")** database as its persistent store. It is located in the `data/db/` directory as an XZ-compressed database file with minimal initial data &mdash; actually having two Customers and by six Contacts for each Customer. The database file is automatically decompressed during build process of the microservice and ready to use as is even when containerized with Docker.

Generally speaking, this project might be explored as a PoC (proof of concept) on how to amalgamate Crystal REST API service backed by SQLite database, running standalone as a conventional daemon in host or VM environment, or in a containerized form as usually widely adopted nowadays.

Surely, one may consider this project to be suitable for a wide variety of applied areas and may use this prototype as: (1) a template for building similar microservices, (2) for evolving it to make something more universal, or (3) to simply explore it and take out some snippets and techniques from it for *educational purposes*, etc.

---

## Table of Contents

* **[Building](#building)**
  * **[Creating a Docker image](#creating-a-docker-image)**
* **[Running](#running)**
  * **[Running a Docker image](#running-a-docker-image)**
  * **[Exploring a Docker image payload](#exploring-a-docker-image-payload)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**
  * **[Error handling](#error-handling)**

## Building

The microservice might be built and run successfully under **Ubuntu Server (Ubuntu 24.04.3 LTS x86-64)** and **Arch Linux** (both proven). &mdash; First install the necessary dependencies (`build-essential`, `crystal`, `shards`, `libsqlite3-dev`, `docker.io`):

* In Ubuntu Server:

```
$ sudo apt-get update && \
  sudo apt-get install build-essential libsqlite3-dev docker.io -y
...
```

> Since Crystal package is somehow outdated in the stock Ubuntu package repository, it is preferred to be installed from the official Crystal website by using their specifically tailored convenient installation script:

```
$ curl -sfSL https://crystal-lang.org/install.sh | sudo bash -s -- --version=1.16
...
```

* In Arch Linux:

```
$ sudo pacman -Syu base-devel crystal shards sqlite docker
...
```

Then pull and install all the necessary third-party libraries (so-called **shards**):

```
$ shards
Resolving dependencies
Fetching https://github.com/crystal-lang/crystal-sqlite3.git
Fetching https://github.com/kemalcr/kemal.git
Fetching https://github.com/crystal-community/toml.cr.git
Fetching https://github.com/chris-huxtable/syslog.cr.git
Fetching https://github.com/crystal-lang/crystal-db.git
Fetching https://github.com/luislavena/radix.git
Fetching https://github.com/crystal-loot/exception_page.git
Fetching https://github.com/sija/backtracer.cr.git
Installing toml (0.8.1)
Installing syslog (0.1.2)
Installing db (0.13.1)
Installing sqlite3 (0.21.0)
Installing radix (0.4.1)
Installing backtracer (1.2.4)
Installing exception_page (0.5.0)
Installing kemal (1.7.1)
```

---

**Build** the microservice using the **Shards utility**:

```
$ shards --production build --release --no-debug && \
  if [ -f data/db/customers-api-lite.db.xz ]; then \
     unxz data/db/customers-api-lite.db.xz; \
  fi
Dependencies are satisfied
Building: api-lited
```

Or **build** the microservice using **GNU Make** (optional, but for convenience &mdash; it covers the same **Shards utility** build workflow under the hood):

```
$ make clean
...
$ make all  # <== Building the daemon.
...
```

### Creating a Docker image

**Build** a Docker image for the microservice:

```
$ # Pull the Crystal image first (based on Alpine Linux), if not already there:
$ sudo docker pull crystallang/crystal:latest-alpine
...
$ # Then build the microservice image:
$ sudo docker build -tcustomersapi/api-lite-cry .
...
```

## Running

**Run** the microservice using its executable directly, built previously by the Shards utility or GNU Make's `all` target:

```
$ ./bin/api-lited; echo $?
...
```

To run the microservice as a *true* daemon, i.e. in the background, redirecting all the console output to `/dev/null`, the following form of invocation of its executable can be used:

```
$ ./bin/api-lited > /dev/null 2>&1 &
[1] <pid>
```

**Note:** This will suppress all the console output only; logging to a logfile and to the Unix syslog will remain unchanged.

The daemonized microservice then can be stopped gracefully at any time by issuing the following command:

```
$ kill -SIGTERM <pid>
$
[1]+  Done                    ./bin/api-lited > /dev/null 2>&1
```

### Running a Docker image

**Run** a Docker image of the microservice, deleting all stopped containers prior to that (if any):

```
$ sudo docker rm `sudo docker ps -aq`; \
  export PORT=8765 && sudo docker run -dp${PORT}:${PORT} --name api-lite-cry customersapi/api-lite-cry; echo $?
...
```

### Exploring a Docker image payload

The following is not necessary but might be considered somewhat interesting &mdash; to look up into the running container, and check out that the microservice's daemon executable, config, logfile, and accompanied SQLite database are at their expected places and in effect:

```
$ sudo docker ps -a
CONTAINER ID   IMAGE                       COMMAND           CREATED              STATUS              PORTS                                       NAMES
<container_id> customersapi/api-lite-cry   "bin/api-lited"   About a minute ago   Up About a minute   0.0.0.0:8765->8765/tcp, :::8765->8765/tcp   api-lite-cry
$
$ sudo docker exec -it api-lite-cry sh; echo $?
/var/tmp/api-lite $
/var/tmp/api-lite $ uname -a
Linux <container_id> 6.8.0-79-generic #79-Ubuntu SMP PREEMPT_DYNAMIC Tue Aug 12 14:42:46 UTC 2025 x86_64 Linux
/var/tmp/api-lite $
/var/tmp/api-lite $ crystal --version
Crystal 1.17.1 [19be240d1] (2025-07-22)

LLVM: 18.1.8
Default target: x86_64-unknown-linux-musl
/var/tmp/api-lite $
/var/tmp/api-lite $ shards --version
Shards 0.19.1 [182792a] (2025-01-23)
/var/tmp/api-lite $
/var/tmp/api-lite $ ls -al
total 64
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 11:00 .
drwxrwxrwt    1 root     root          4096 Sep 16 10:50 ..
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:51 .crystal
drwxr-xr-x    3 daemon   daemon        4096 Sep 16 10:50 .shards
-rw-rw-r--    1 daemon   daemon        1254 Sep 13 21:40 Makefile
drwxr-xr-x    2 daemon   daemon        4096 Sep 16 10:53 bin
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:50 data
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:50 etc
drwxr-xr-x   10 daemon   daemon        4096 Sep 16 10:50 lib
drwxr-xr-x    2 daemon   daemon        4096 Sep 16 11:00 log
-rw-r--r--    1 daemon   daemon         706 Sep 16 10:50 shard.lock
-rw-rw-r--    1 daemon   daemon        1436 Sep 13 21:40 shard.yml
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:50 src
/var/tmp/api-lite $
/var/tmp/api-lite $ ls -al bin/ data/db/ etc/ log/ src/
bin/:
total 4480
drwxr-xr-x    2 daemon   daemon        4096 Sep 16 10:53 .
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 11:00 ..
-rwxr-xr-x    1 daemon   daemon     4574056 Sep 16 10:53 api-lited

data/db/:
total 40
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:53 .
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:50 ..
-rw-rw-r--    1 daemon   daemon       24576 Sep 16 10:50 customers-api-lite.db

etc/:
total 16
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:50 .
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 11:00 ..
-rw-rw-r--    1 daemon   daemon         797 Sep 15 20:00 settings.conf

log/:
total 16
drwxr-xr-x    2 daemon   daemon        4096 Sep 16 11:00 .
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 11:00 ..
-rw-r--r--    1 daemon   daemon         265 Sep 16 11:00 customers-api-lite.log

src/:
total 52
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 10:50 .
drwxr-xr-x    1 daemon   daemon        4096 Sep 16 11:00 ..
-rw-rw-r--    1 daemon   daemon       16448 Sep 13 21:40 api-lite-controller.cr
-rw-rw-r--    1 daemon   daemon        3411 Sep 13 21:40 api-lite-core.cr
-rw-rw-r--    1 daemon   daemon        6130 Sep 13 21:40 api-lite-helper.cr
-rw-rw-r--    1 daemon   daemon        4933 Sep 13 21:40 api-lite-model.cr
/var/tmp/api-lite $
/var/tmp/api-lite $ ldd bin/api-lited
        /lib/ld-musl-x86_64.so.1 (0x7e06e7e8a000)
        libz.so.1 => /lib/libz.so.1 (0x7e06e7c8f000)
        libssl.so.3 => /lib/libssl.so.3 (0x7e06e7bcb000)
        libcrypto.so.3 => /lib/libcrypto.so.3 (0x7e06e7783000)
        libsqlite3.so.0 => /usr/lib/libsqlite3.so.0 (0x7e06e7620000)
        libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0x7e06e7575000)
        libgc.so.1 => /usr/lib/libgc.so.1 (0x7e06e750d000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x7e06e74e9000)
        libc.musl-x86_64.so.1 => /lib/ld-musl-x86_64.so.1 (0x7e06e7e8a000)
/var/tmp/api-lite $
/var/tmp/api-lite $ netstat -plunt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:8765            0.0.0.0:*               LISTEN      1/api-lited
/var/tmp/api-lite $
/var/tmp/api-lite $ ps aux
PID   USER     TIME  COMMAND
    1 daemon    0:00 bin/api-lited
    7 daemon    0:00 sh
   21 daemon    0:00 ps aux
/var/tmp/api-lite $
/var/tmp/api-lite $ exit # Or simply <Ctrl-D>.
0
```

To stop a running container of the microservice gracefully at any time, simply issue the following command:

```
$ sudo docker stop api-lite-cry; echo $?
api-lite-cry
0
```

## Consuming

The microservice exposes **six REST API endpoints** to web clients. They are all intended to deal with customer entities and/or contact entities that belong to customer profiles. The following table displays their syntax:

No. | Endpoint name                                      | Request method and REST URI                                   | Request body
--: | -------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------
1   | Create customer                                    | **PUT** `/v1/customers`                                       | `{"name":"{customer_name}"}`
2   | Create contact                                     | **PUT** `/v1/customers/contacts`                              | `{"customer_id":"{customer_id}","contact":"{customer_contact}"}`
3   | List customers                                     | **GET** `/v1/customers`                                       | &ndash;
4   | Retrieve customer                                  | **GET** `/v1/customers/{customer_id}`                         | &ndash;
5   | List contacts for a given customer                 | **GET** `/v1/customers/{customer_id}/contacts`                | &ndash;
6   | List contacts of a given type for a given customer | **GET** `/v1/customers/{customer_id}/contacts/{contact_type}` | &ndash;

* The `{customer_name}` placeholder is a string &mdash; it usually means the full name given to a newly created customer.
* The `{customer_id}` placeholder is a decimal positive integer number, greater than `0`.
* The `{customer_contact}` placeholder is a string &mdash; it denotes a newly created customer contact (phone or email).
* The `{contact_type}` placeholder is a string and can take one of two possible values, case-insensitive: `phone` or `email`.

The following command-line snippets display the exact usage for these endpoints (the **cURL** utility is used as an example to access them)^:

1. **Create customer**

```
$ curl -vXPUT http://localhost:8765/v1/customers \
       -H 'content-type: application/json' \
       -d '{"name":"Jamison Palmer"}'
...
> PUT /v1/customers HTTP/1.1
...
> content-type: application/json
> Content-Length: 25
...
< HTTP/1.1 201 Created
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Location: /v1/customers/3
< Content-Length: 32
...
{"id":3,"name":"Jamison Palmer"}
```

2. **Create contact**

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"+12197654320"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 44
...
< HTTP/1.1 201 Created
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Location: /v1/customers/3/contacts/phone
< Content-Length: 26
...
{"contact":"+12197654320"}
```

Or create **email** contact:

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"jamison.palmer@example.com"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 58
...
< HTTP/1.1 201 Created
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Location: /v1/customers/3/contacts/email
< Content-Length: 40
...
{"contact":"jamison.palmer@example.com"}
```

3. **List customers**

```
$ curl -v http://localhost:8765/v1/customers
...
> GET /v1/customers HTTP/1.1
...
< HTTP/1.1 200 OK
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Content-Length: 136
...
[{"id":1,"name":"Jammy Jellyfish"},{"id":2,"name":"Noble Numbat"},{"id":3,"name":"Jamison Palmer"},{"id":4,"name":"Sarah Kitteringham"}]
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/3
...
> GET /v1/customers/3 HTTP/1.1
...
< HTTP/1.1 200 OK
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Content-Length: 32
...
{"id":3,"name":"Jamison Palmer"}
```

5. **List contacts for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts
...
> GET /v1/customers/3/contacts HTTP/1.1
...
< HTTP/1.1 200 OK
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Content-Length: 186
...
[{"contact":"+12197654320"},{"contact":"+12197654321"},{"contact":"+12197654322"},{"contact":"jamison.palmer@example.com"},{"contact":"jp@example.com"},{"contact":"jpalmer@example.com"}]
```

6. **List contacts of a given type for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/phone
...
> GET /v1/customers/3/contacts/phone HTTP/1.1
...
< HTTP/1.1 200 OK
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Content-Length: 82
...
[{"contact":"+12197654320"},{"contact":"+12197654321"},{"contact":"+12197654322"}]
```

Or list **email** contacts:

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/email
...
> GET /v1/customers/3/contacts/email HTTP/1.1
...
< HTTP/1.1 200 OK
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Content-Length: 105
...
[{"contact":"jamison.palmer@example.com"},{"contact":"jpalmer@example.com"},{"contact":"jp@example.com"}]
```

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `debug.enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Ubuntu Server or Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2025-09-15][22:15:10] [DEBUG] [Customers API Lite]
[2025-09-15][22:15:10] [DEBUG] [#<DB::Database:0x75812eb2fed0>]
[2025-09-15][22:15:10] [INFO ] Server started on port 8765
[2025-09-15][22:15:10] [INFO ] [production] Kemal is ready to lead at http://0.0.0.0:8765
[2025-09-15][22:20:10] [DEBUG] [PUT]
[2025-09-15][22:20:10] [DEBUG] [Saturday Sunday]
[2025-09-15][22:20:10] [DEBUG] Executing query
[2025-09-15][22:20:10] [DEBUG] Executing query
[2025-09-15][22:20:10] [DEBUG] [5|Saturday Sunday]
[2025-09-15][22:20:10] [INFO ] 201 PUT /v1/customers 204.62ms
[2025-09-15][22:25:10] [DEBUG] [PUT]
[2025-09-15][22:25:10] [DEBUG] customer_id=5
[2025-09-15][22:25:10] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-15][22:25:10] [DEBUG] Executing query
[2025-09-15][22:25:10] [DEBUG] Executing query
[2025-09-15][22:25:10] [DEBUG] [email|Saturday.Sunday@example.com]
[2025-09-15][22:25:10] [INFO ] 201 PUT /v1/customers/contacts 148.83ms
[2025-09-15][22:30:20] [DEBUG] [GET]
[2025-09-15][22:30:20] [DEBUG] customer_id=5
[2025-09-15][22:30:20] [DEBUG] Executing query
[2025-09-15][22:30:20] [DEBUG] [5|Saturday Sunday]
[2025-09-15][22:30:20] [INFO ] 200 GET /v1/customers/5 465.34µs
[2025-09-15][22:35:30] [DEBUG] [GET]
[2025-09-15][22:35:30] [DEBUG] customer_id=5 | contact_type=email
[2025-09-15][22:35:30] [DEBUG] Executing query
[2025-09-15][22:35:30] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-15][22:35:30] [INFO ] 200 GET /v1/customers/5/contacts/email 951.57µs
[2025-09-15][22:40:40] [INFO ] Kemal is going to take a rest!
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Sep 15 22:15:10 <hostname> api-lited[<pid>]: [Customers API Lite]
Sep 15 22:15:10 <hostname> api-lited[<pid>]: [#<DB::Database:0x75812eb2fed0>]
Sep 15 22:15:10 <hostname> api-lited[<pid>]: Server started on port 8765
Sep 15 22:20:10 <hostname> api-lited[<pid>]: [PUT]
Sep 15 22:20:10 <hostname> api-lited[<pid>]: [Saturday Sunday]
Sep 15 22:20:10 <hostname> api-lited[<pid>]: [5|Saturday Sunday]
Sep 15 22:25:10 <hostname> api-lited[<pid>]: [PUT]
Sep 15 22:25:10 <hostname> api-lited[<pid>]: customer_id=5
Sep 15 22:25:10 <hostname> api-lited[<pid>]: [Saturday.Sunday@example.com]
Sep 15 22:25:10 <hostname> api-lited[<pid>]: [email|Saturday.Sunday@example.com]
Sep 15 22:30:20 <hostname> api-lited[<pid>]: [GET]
Sep 15 22:30:20 <hostname> api-lited[<pid>]: customer_id=5
Sep 15 22:30:20 <hostname> api-lited[<pid>]: [5|Saturday Sunday]
Sep 15 22:35:30 <hostname> api-lited[<pid>]: [GET]
Sep 15 22:35:30 <hostname> api-lited[<pid>]: customer_id=5 | contact_type=email
Sep 15 22:35:30 <hostname> api-lited[<pid>]: [Saturday.Sunday@example.com]
Sep 15 22:40:40 <hostname> api-lited[<pid>]: Server stopped
```

Inside the running container logs might be queried also by `tail`ing the `log/customers-api-lite.log` logfile:

```
/var/tmp/api-lite $ tail -f log/customers-api-lite.log
[2025-09-16][11:00:30] [DEBUG] [Customers API Lite]
[2025-09-16][11:00:30] [DEBUG] [#<DB::Database:0x77853f2b8ed0>]
[2025-09-16][11:00:30] [INFO ] Server started on port 8765
[2025-09-16][11:00:30] [INFO ] [production] Kemal is ready to lead at http://0.0.0.0:8765
[2025-09-16][20:05:30] [DEBUG] [PUT]
[2025-09-16][20:05:30] [DEBUG] [Saturday Sunday]
[2025-09-16][20:05:30] [DEBUG] Executing query
[2025-09-16][20:05:30] [DEBUG] Executing query
[2025-09-16][20:05:30] [DEBUG] [5|Saturday Sunday]
[2025-09-16][20:05:30] [INFO ] 201 PUT /v1/customers 71.62ms
[2025-09-16][20:10:30] [DEBUG] [PUT]
[2025-09-16][20:10:30] [DEBUG] customer_id=5
[2025-09-16][20:10:30] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-16][20:10:30] [DEBUG] Executing query
[2025-09-16][20:10:30] [DEBUG] Executing query
[2025-09-16][20:10:30] [DEBUG] [email|Saturday.Sunday@example.com]
[2025-09-16][20:10:30] [INFO ] 201 PUT /v1/customers/contacts 81.54ms
[2025-09-16][20:15:40] [DEBUG] [GET]
[2025-09-16][20:15:40] [DEBUG] customer_id=5
[2025-09-16][20:15:40] [DEBUG] Executing query
[2025-09-16][20:15:40] [DEBUG] [5|Saturday Sunday]
[2025-09-16][20:15:40] [INFO ] 200 GET /v1/customers/5 608.12µs
[2025-09-16][20:20:50] [DEBUG] [GET]
[2025-09-16][20:20:50] [DEBUG] customer_id=5 | contact_type=email
[2025-09-16][20:20:50] [DEBUG] Executing query
[2025-09-16][20:20:50] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-16][20:20:50] [INFO ] 200 GET /v1/customers/5/contacts/email 425.1µs
```

And of course, Docker itself gives the possibility to read log messages by using the corresponding command for that:

```
$ sudo docker logs -f api-lite-cry
[2025-09-16][11:00:30] [DEBUG] [Customers API Lite]
[2025-09-16][11:00:30] [DEBUG] [#<DB::Database:0x77853f2b8ed0>]
[2025-09-16][11:00:30] [INFO ] Server started on port 8765
[2025-09-16][11:00:30] [INFO ] [production] Kemal is ready to lead at http://0.0.0.0:8765
[2025-09-16][20:05:30] [DEBUG] [PUT]
[2025-09-16][20:05:30] [DEBUG] [Saturday Sunday]
[2025-09-16][20:05:30] [DEBUG] Executing query
[2025-09-16][20:05:30] [DEBUG] Executing query
[2025-09-16][20:05:30] [DEBUG] [5|Saturday Sunday]
[2025-09-16][20:05:30] [INFO ] 201 PUT /v1/customers 71.62ms
[2025-09-16][20:10:30] [DEBUG] [PUT]
[2025-09-16][20:10:30] [DEBUG] customer_id=5
[2025-09-16][20:10:30] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-16][20:10:30] [DEBUG] Executing query
[2025-09-16][20:10:30] [DEBUG] Executing query
[2025-09-16][20:10:30] [DEBUG] [email|Saturday.Sunday@example.com]
[2025-09-16][20:10:30] [INFO ] 201 PUT /v1/customers/contacts 81.54ms
[2025-09-16][20:15:40] [DEBUG] [GET]
[2025-09-16][20:15:40] [DEBUG] customer_id=5
[2025-09-16][20:15:40] [DEBUG] Executing query
[2025-09-16][20:15:40] [DEBUG] [5|Saturday Sunday]
[2025-09-16][20:15:40] [INFO ] 200 GET /v1/customers/5 608.12µs
[2025-09-16][20:20:50] [DEBUG] [GET]
[2025-09-16][20:20:50] [DEBUG] customer_id=5 | contact_type=email
[2025-09-16][20:20:50] [DEBUG] Executing query
[2025-09-16][20:20:50] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-16][20:20:50] [INFO ] 200 GET /v1/customers/5/contacts/email 425.1µs
[2025-09-16][20:25:00] [INFO ] Kemal is going to take a rest!
```

### Error handling

When the URI path or request body passed in an incoming request contains inappropriate input, the microservice will respond with the **HTTP 400 Bad Request** status code, including a specific response body in JSON representation which may describe a possible cause of underlying client error, like the following:

```
$ curl http://localhost:8765/v1/customers/=qwerty4838=-i-.--089asdf..nj524987
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl http://localhost:8765/v1/customers/3..,,7/contacts
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl http://localhost:8765/v1/customers/--089asdf../contacts/email
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl -XPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"12197654320--089asdf../nj524987"}'
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
```
