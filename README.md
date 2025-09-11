# Customers API Lite microservice prototype :small_blue_diamond: <img src="https://crystal-lang.org/reference/1.16/assets/crystal-circ.svg" style="border:0;width:32px" alt="Crystal" />

**A daemon written in Crystal, designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[Crystal](https://crystal-lang.org "The Crystal Programming Language")** port of the earlier developed **Customers API Lite microservice prototype**, written in V using **[veb](https://modules.vlang.io/veb.html "The V Web Server")** web server library/framework, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-vlang-veb)** almost as is, without any principal modifications or adjustment.

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
Fetching https://github.com/crystal-community/toml.cr.git
Fetching https://github.com/chris-huxtable/syslog.cr.git
Fetching https://github.com/kemalcr/kemal.git
Fetching https://github.com/crystal-lang/crystal-sqlite3.git
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
$ shards --production build --release && \
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
$ # Pull the Crystal image first, if not already there:
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
...
```

**Note:** This will suppress all the console output only; logging to a logfile and to the Unix syslog will remain unchanged.

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

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `debug.enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2025-09-08][20:30:10] [DEBUG] [Customers API Lite]
[2025-09-08][20:30:10] [DEBUG] [#<DB::Database:0x71814c610ed0>]
[2025-09-08][20:30:10] [INFO ] Server started on port 8765
[2025-09-08][20:30:10] [INFO ] [development] Kemal is ready to lead at http://0.0.0.0:8765
[2025-09-08][20:30:20] [DEBUG] [PUT]
[2025-09-08][20:30:20] [DEBUG] [Jamison Palmer]
[2025-09-08][20:30:20] [DEBUG] Executing query
[2025-09-08][20:30:20] [DEBUG] Executing query
[2025-09-08][20:30:20] [DEBUG] [3|Jamison Palmer]
[2025-09-08][20:30:20] [INFO ] 201 PUT /v1/customers 129.65ms
[2025-09-08][20:40:50] [DEBUG] [PUT]
[2025-09-08][20:40:50] [DEBUG] customer_id=3
[2025-09-08][20:40:50] [DEBUG] [jamison.palmer@example.com]
[2025-09-08][20:40:50] [DEBUG] Executing query
[2025-09-08][20:40:50] [DEBUG] Executing query
[2025-09-08][20:40:50] [DEBUG] [email|jamison.palmer@example.com]
[2025-09-08][20:40:50] [INFO ] 201 PUT /v1/customers/contacts 106.84ms
[2025-09-08][20:45:50] [DEBUG] [GET]
[2025-09-08][20:45:50] [DEBUG] customer_id=3
[2025-09-08][20:45:50] [DEBUG] Executing query
[2025-09-08][20:45:50] [DEBUG] [3|Jamison Palmer]
[2025-09-08][20:45:50] [INFO ] 200 GET /v1/customers/3 651.31µs
[2025-09-08][20:55:25] [DEBUG] [GET]
[2025-09-08][20:55:25] [DEBUG] customer_id=3 | contact_type=email
[2025-09-08][20:55:25] [DEBUG] Executing query
[2025-09-08][20:55:25] [DEBUG] [jamison.palmer@example.com]
[2025-09-08][20:55:25] [INFO ] 200 GET /v1/customers/3/contacts/email 718.68µs
[2025-09-08][21:20:20] [INFO ] Kemal is going to take a rest!
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Sep 08 20:30:10 <hostname> api-lited[<pid>]: [Customers API Lite]
Sep 08 20:30:10 <hostname> api-lited[<pid>]: [#<DB::Database:0x71814c610ed0>]
Sep 08 20:30:10 <hostname> api-lited[<pid>]: Server started on port 8765
Sep 08 20:30:20 <hostname> api-lited[<pid>]: [PUT]
Sep 08 20:30:20 <hostname> api-lited[<pid>]: [Jamison Palmer]
Sep 08 20:30:20 <hostname> api-lited[<pid>]: [3|Jamison Palmer]
Sep 08 20:40:50 <hostname> api-lited[<pid>]: [PUT]
Sep 08 20:40:50 <hostname> api-lited[<pid>]: customer_id=3
Sep 08 20:40:50 <hostname> api-lited[<pid>]: [jamison.palmer@example.com]
Sep 08 20:40:50 <hostname> api-lited[<pid>]: [email|jamison.palmer@example.com]
Sep 08 20:45:50 <hostname> api-lited[<pid>]: [GET]
Sep 08 20:45:50 <hostname> api-lited[<pid>]: customer_id=3
Sep 08 20:45:50 <hostname> api-lited[<pid>]: [3|Jamison Palmer]
Sep 08 20:55:25 <hostname> api-lited[<pid>]: [GET]
Sep 08 20:55:25 <hostname> api-lited[<pid>]: customer_id=3 | contact_type=email
Sep 08 20:55:25 <hostname> api-lited[<pid>]: [jamison.palmer@example.com]
Sep 08 21:20:20 <hostname> api-lited[<pid>]: Server stopped
```

**TBD** :cd:

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

---

**WIP** :dvd:
