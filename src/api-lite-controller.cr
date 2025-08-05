#
# src/api-lite-controller.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.1.1
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The controller module of the daemon -----------------------------------------

module Controller
    dbg = Helper.dbg()
    log = Helper.log()
    cnx = Helper.cnx()

    # The `PUT /v1/customers` endpoint.
    #
    # Creates a new customer (puts customer data to the database).
    #
    # The request body is defined exactly in the form
    # as `{"name":"{customer_name}"}`. It should be passed with the accompanied
    # request header `content-type` just like the following:
    #
    # ```
    # -H 'content-type: application/json' -d '{"name":"{customer_name}"}'
    # ```
    #
    # `{customer_name}` is a name assigned to a newly created customer.
    #
    # Returns the `201 Created` HTTP status code, the `Location` response
    # header (among others), and the response body in JSON representation,
    # containing profile details of a newly created customer.
    # May return client or server error depending on incoming request.
    put (SLASH + REST_VERSION + SLASH + REST_PREFIX) do |ctx|
        method = ctx.request.method

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        # FIXME: Do handle the incoming request properly: e.g. return
        #        HTTP 405 Method Not Allowed where applicable, etc.
        if (method == "PUT")
            _dbg(dbg, log, O_BRACKET + "---PUT" + C_BRACKET)
        elsif ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, log, O_BRACKET + "---GET, HEAD" + C_BRACKET)
        else
            _dbg(dbg, log, O_BRACKET +
                "---POST, PATCH, DELETE, OPTIONS, TRACE, etc." + C_BRACKET)
        end
    end

    # The `PUT /v1/customers/contacts` endpoint.
    #
    # Creates a new contact for a given customer (puts a contact
    # regarding a given customer to the database).
    #
    # The request body is defined exactly in the form
    # as `{"customer_id":"{customer_id}","contact":"{customer_contact}"}`.
    # It should be passed with the accompanied request header `content-type`
    # just like the following:
    #
    # ```
    # -H 'content-type: application/json' -d '{"customer_id":"{customer_id}","contact":"{customer_contact}"}'
    # ```
    #
    # `{customer_id}` is the customer ID used to associate a newly created
    # contact with this customer.
    #
    # Returns the `201 Created` HTTP status code, the `Location` response
    # header (among others), and the response body in JSON representation,
    # containing details of a newly created customer contact (phone or email).
    # May return client or server error depending on incoming request.
    put (SLASH + REST_VERSION + SLASH + REST_PREFIX +
         SLASH + REST_CONTACTS) do |ctx|

        method = ctx.request.method

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        if (method == "PUT")
            _dbg(dbg, log, O_BRACKET + "---PUT" + C_BRACKET)
        else
            # TODO: Return HTTP 405 Method Not Allowed and relevant JSON resp.
        end
    end

    # The `GET /v1/customers` endpoint.
    #
    # Retrieves from the database and lists all customer profiles.
    #
    # Returns the `200 OK` HTTP status code and the response body
    # in JSON representation, containing a list of all customer profiles.
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX) do |ctx|
        method = ctx.request.method

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, log, O_BRACKET + "---GET, HEAD" + C_BRACKET)
        else
            # TODO: Return HTTP 405 Method Not Allowed and relevant JSON resp.
        end
    end

    # The `GET /v1/customers/{customer_id}` endpoint.
    #
    # Retrieves profile details for a given customer from the database.
    #
    # Returns a specific HTTP status code with profile details for a given
    # customer (in the response body in JSON representation).
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX +
         SLASH + COLON + REST_CUST_ID) do |ctx|

        method = ctx.request.method

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, log, O_BRACKET + "---GET, HEAD" + C_BRACKET)
        else
            # TODO: Return HTTP 405 Method Not Allowed and relevant JSON resp.
        end
    end

    # The `GET /v1/customers/{customer_id}/contacts` endpoint.
    #
    # Retrieves from the database and lists all contacts
    # associated with a given customer.
    #
    # Returns the `200 OK` HTTP status code and the response body
    # in JSON representation, containing a list of all contacts
    # associated with a given customer.
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX +
         SLASH + COLON + REST_CUST_ID + SLASH + REST_CONTACTS) do |ctx|

        method = ctx.request.method

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, log, O_BRACKET + "---GET, HEAD" + C_BRACKET)
        else
            # TODO: Return HTTP 405 Method Not Allowed and relevant JSON resp.
        end
    end

    # The `GET /v1/customers/{customer_id}/contacts/{contact_type}` endpoint.
    #
    # Retrieves from the database and lists all contacts of a given type
    # associated with a given customer.
    #
    # Returns the `200 OK` HTTP status code and the response body
    # in JSON representation, containing a list of all contacts of a given type
    # associated with a given customer.
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX +
         SLASH + COLON + REST_CUST_ID + SLASH + REST_CONTACTS +
         SLASH + COLON + REST_CONT_TYPE) do |ctx|

        method = ctx.request.method

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, log, O_BRACKET + "---GET, HEAD" + C_BRACKET)
        else
            # TODO: Return HTTP 405 Method Not Allowed and relevant JSON resp.
        end
    end

    # Off-topic ---------------------------------------------------------------

    get SLASH do
        ret = EMPTY_STRING; (1 .. 79).each() do ret += MINUS end; ret += EOL
    end
end

# vim:set nu et ts=4 sw=4:
