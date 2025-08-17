#
# src/api-lite-controller.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.1.5
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

    before_all do |ctx|
        method = ctx.request.method()
        status = HTTP::Status::IM_A_TEAPOT # <== HTTP 418 I'm a teapot

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)
        _dbg(dbg, log, "#{O_BRACKET}#{cnx}#{C_BRACKET}")

        case (method)
        when "PUT"
            _dbg(dbg, log, O_BRACKET + "---PUT" + C_BRACKET)

            status = HTTP::Status::CREATED
        when "GET", "HEAD"
            _dbg(dbg, log, O_BRACKET + "---GET, HEAD" + C_BRACKET)

            status = HTTP::Status::OK
        when "POST", "PATCH", "DELETE", "OPTIONS"
            _dbg(dbg, log, O_BRACKET + "---POST, PATCH, DELETE, OPTIONS" +
                           C_BRACKET)

            status = HTTP::Status::METHOD_NOT_ALLOWED #< 405 Method Not Allowed

            ctx.response.headers.add(HDR_ALLOW_N, HDR_ALLOW_V)
        else
            # For any other method Kemal will automatically respond
            # with the HTTP 404 Not Found status code.
            _dbg(dbg, log, O_BRACKET + "---Any other HTTP method" + C_BRACKET)
        end

        ctx.response.status_code  = status.code()
        ctx.response.content_type = MIME_TYPE
    end

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
    end

    # The `GET /v1/customers` endpoint.
    #
    # Retrieves from the database and lists all customer profiles.
    #
    # Returns the `200 OK` HTTP status code and the response body
    # in JSON representation, containing a list of all customer profiles.
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX) do |ctx|
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
    end

    # Unused route method stubs - just to respond with HTTP 405 ---------------

    post    (SLASH + ANY) do end
    patch   (SLASH + ANY) do end
    delete  (SLASH + ANY) do end
    options (SLASH + ANY) do end

    # Conventional HTTP error responses ---------------------------------------

    error 404 do
        {:error => ERR_REQ_NOT_FOUND}.to_json()
    end

    # Off-topic ---------------------------------------------------------------

    get SLASH do
        ret = EMPTY_STRING; (1 .. 79).each() do ret += MINUS end#; ret += EOL

        ret.to_json()
    end
end

# vim:set nu et ts=4 sw=4:
