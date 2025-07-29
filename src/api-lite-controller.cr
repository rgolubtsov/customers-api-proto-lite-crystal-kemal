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
    # The `GET /v1/customers` endpoint.
    #
    # Retrieves from the database and lists all customer profiles.
    #
    # Returns the `200 OK` HTTP status code and the response body
    # in JSON representation, containing a list of all customer profiles.
    # May return client or server error depending on incoming request.
    get (SLASH + REST_VERSION + SLASH + REST_PREFIX) do |env|
        method = env.request.method

        # TODO: Get the debug logging enabler and the main logger,
        #       and make use of tracepoints.
        puts(O_BRACKET + method + C_BRACKET)

        # FIXME: Do handle the incoming request properly: e.g. return
        #        HTTP 405 Method Not Allowed where applicable, etc.
        if (method == "PUT")
            puts("---PUT")
        elsif ((method == "GET") || (method == "HEAD"))
            puts("---GET, HEAD")
        else
            puts("---POST, PATCH, DELETE, OPTIONS, TRACE, etc.")
        end
    end

    # Off-topic ---------------------------------------------------------------

    get SLASH do
        ret = EMPTY_STRING; (1 .. 79).each() do ret += MINUS end; ret += EOL
    end
end

# vim:set nu et ts=4 sw=4:
