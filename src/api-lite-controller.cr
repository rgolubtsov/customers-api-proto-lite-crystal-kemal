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
    dbg = true # <== TODO: Get the debug logging enabler actually and properly.
    l   = Log.for(EMPTY_STRING)

    # The `GET /v1/customers` endpoint.
    #
    # Retrieves from the database and lists all customer profiles.
    #
    # Returns the `200 OK` HTTP status code and the response body
    # in JSON representation, containing a list of all customer profiles.
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX) do |ctx|
        method = ctx.request.method

        _dbg(dbg, l, O_BRACKET + method + C_BRACKET)

        # FIXME: Do handle the incoming request properly: e.g. return
        #        HTTP 405 Method Not Allowed where applicable, etc.
        if (method == "PUT")
            _dbg(dbg, l, O_BRACKET + "---PUT" + C_BRACKET)
        elsif ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, l, O_BRACKET + "---GET, HEAD" + C_BRACKET)
        else
            _dbg(dbg, l, O_BRACKET +
                "---POST, PATCH, DELETE, OPTIONS, TRACE, etc." + C_BRACKET)
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

        _dbg(dbg, l, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, l, O_BRACKET + "---GET, HEAD" + C_BRACKET)
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

        _dbg(dbg, l, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, l, O_BRACKET + "---GET, HEAD" + C_BRACKET)
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

        _dbg(dbg, l, O_BRACKET + method + C_BRACKET)

        if ((method == "GET") || (method == "HEAD"))
            _dbg(dbg, l, O_BRACKET + "---GET, HEAD" + C_BRACKET)
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
