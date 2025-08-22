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

require "./api-lite-model"; include Model

module Controller
    dbg = Helper.dbg()
    log = Helper.log()
    cnx = Helper.cnx()

    before_all do |ctx|
        method = ctx.request.method()
        status = HTTP::Status::IM_A_TEAPOT # <== HTTP 418 I'm a teapot

        _dbg(dbg, log, O_BRACKET + method + C_BRACKET)

        case (method)
        when HTTP_PUT
            status = HTTP::Status::CREATED
        when HTTP_GET, HTTP_HEAD
            status = HTTP::Status::OK
        when HTTP_POST, HTTP_PATCH, HTTP_DELETE, HTTP_OPTIONS
            status = HTTP::Status::METHOD_NOT_ALLOWED #< 405 Method Not Allowed

            ctx.response.headers.add(HDR_ALLOW_N, HDR_ALLOW_V)
        else
            # For any other method Kemal will automatically respond
            # with the HTTP 404 Not Found status code.
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
        custs = [] of Customer

        # Retrieving all customer profiles from the database.
        cnx.query(SQL_GET_ALL_CUSTOMERS) do |customers|
            customers.each() do
                custs << Customer.new(customers.read(Int64),
                                      customers.read(String))
            end
        end

        _dbg(dbg, log, "#{O_BRACKET}#{custs[0].id}" + # getId()
                          V_BAR     + custs[0].name + # getName()
                          C_BRACKET)

        custs.to_json()
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
