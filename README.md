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
  * **[Error handling](#error-handling)**

## Building

The microservice might be built and run successfully under **Arch Linux** (proven). &mdash; First install the necessary dependencies (`base-devel`, `crystal`, `shards`, `sqlite`, `docker`):

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
Using toml (0.8.1)
Using syslog (0.1.2)
Using db (0.13.1)
Using sqlite3 (0.21.0)
Using radix (0.4.1)
Using backtracer (1.2.4)
Using exception_page (0.5.0)
Using kemal (1.7.1)
```

---

**Build** the microservice using the **Shards utility**:

```
$ shards build && \
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

The microservice should expose **six REST API endpoints** to web clients... They are all intended to deal with customer entities and/or contact entities that belong to customer profiles. The following table displays their syntax:

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

**TBD** :cd:

2. **Create contact**

**TBD** :cd:

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
< Content-Length: 66
...
[{"id":1,"name":"Jammy Jellyfish"},{"id":2,"name":"Noble Numbat"}]
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/2
...
> GET /v1/customers/2 HTTP/1.1
...
< HTTP/1.1 200 OK
...
< X-Powered-By: Kemal
< Content-Type: application/json
...
< Content-Length: 30
...
{"id":2,"name":"Noble Numbat"}
```

5. **List contacts for a given customer**

**TBD** :cd:

6. **List contacts of a given type for a given customer**

**TBD** :cd:

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `debug.enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log/customers-api-lite.log` logfile:

```
$ tail -f log/customers-api-lite.log
[2025-08-22][22:20:30] [DEBUG] [Customers API Lite]
[2025-08-22][22:20:30] [DEBUG] [#<DB::Database:0x7676c74ebed0>]
[2025-08-22][22:20:30] [INFO ] Server started on port 8765
[2025-08-22][22:20:30] [INFO ] [development] Kemal is ready to lead at http://0.0.0.0:8765
[2025-08-22][22:50:30] [DEBUG] [GET]
[2025-08-22][22:50:30] [DEBUG] Executing query
[2025-08-22][22:50:30] [DEBUG] [1|Jammy Jellyfish]
[2025-08-22][22:50:30] [INFO ] 200 GET /v1/customers 847.02µs
[2025-08-22][22:55:20] [DEBUG] [GET]
[2025-08-22][22:55:20] [DEBUG] customer_id=2
[2025-08-22][22:55:20] [DEBUG] Executing query
[2025-08-22][22:55:20] [DEBUG] [2|Noble Numbat]
[2025-08-22][22:55:20] [INFO ] 200 GET /v1/customers/2 470.44µs
[2025-08-22][22:55:50] [INFO ] Kemal is going to take a rest!
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Aug 22 22:20:30 <hostname> api-lited[<pid>]: [Customers API Lite]
Aug 22 22:20:30 <hostname> api-lited[<pid>]: [#<DB::Database:0x7676c74ebed0>]
Aug 22 22:20:30 <hostname> api-lited[<pid>]: Server started on port 8765
Aug 22 22:50:30 <hostname> api-lited[<pid>]: [GET]
Aug 22 22:50:30 <hostname> api-lited[<pid>]: [1|Jammy Jellyfish]
Aug 22 22:55:20 <hostname> api-lited[<pid>]: [GET]
Aug 22 22:55:20 <hostname> api-lited[<pid>]: customer_id=2
Aug 22 22:55:20 <hostname> api-lited[<pid>]: [2|Noble Numbat]
Aug 22 22:55:50 <hostname> api-lited[<pid>]: Server stopped
```

**TBD** :cd:

### Error handling

When the URI path of an incoming request contains inappropriate input, the microservice will respond with the **HTTP 400 Bad Request** status code, including a specific response body in JSON representation which may describe a possible cause of underlying client error, like the following:

```
$ curl http://localhost:8765/v1/customers/=qwerty4838=-i-.--089asdf..nj524987
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
```

---

**WIP** :dvd:
