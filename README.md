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
* **[Running](#running)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**

## Building

The microservice might be built and run successfully under **Arch Linux** (proven).

**Build** the microservice using the **Shards utility**:

```
$ # First pull and install all the necessary dependencies, if not already there:
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
Using toml (0.8.1)
Using syslog (0.1.2)
Using db (0.13.1)
Using sqlite3 (0.21.0)
Using radix (0.4.1)
Using backtracer (1.2.4)
Using exception_page (0.5.0)
Using kemal (1.7.1)
$
$ # Then build the microservice itself:
$ shards build && \
  if [ -f data/db/customers-api-lite.db.xz ]; then \
      unxz data/db/customers-api-lite.db.xz; \
  fi
Dependencies are satisfied
Building: api-lited
```

:cd:

## Running

**Run** the microservice using its executable directly, built previously by the Shards utility:

```
$ ./bin/api-lited; echo $?
...
```

:cd:

## Consuming

The microservice should expose **six REST API endpoints** to web clients...

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `debug.enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2025-07-23][23:35:10] [DEBUG] [Customers API Lite]
[2025-07-23][23:35:10] [INFO ] Server started on port 8765
[2025-07-23][23:35:10] [INFO ] [development] Kemal is ready to lead at http://0.0.0.0:8765
[2025-07-23][23:35:15] [INFO ] 404 GET /v1/customers 251.58µs
[2025-07-23][23:35:30] [INFO ] Kemal is going to take a rest!
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Jul 23 23:35:10 <hostname> api-lited[<pid>]: [Customers API Lite]
Jul 23 23:35:10 <hostname> api-lited[<pid>]: Server started on port 8765
Jul 23 23:35:30 <hostname> api-lited[<pid>]: Server stopped
```

:cd:

---

:dvd:
