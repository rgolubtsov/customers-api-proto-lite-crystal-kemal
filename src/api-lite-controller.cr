#
# src/api-lite-controller.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.2.3
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

    # Request filters ---------------------------------------------------------

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

    # REST API endpoints ------------------------------------------------------

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
        payload = ctx.request.body.not_nil!()

        customer : JSON::Any

        # Trying to parse and validate the request payload.
        begin
            customer = JSON.parse(payload)
        rescue
            ctx.response.status_code = HTTP::Status::BAD_REQUEST.code()

            {:error => ERR_REQ_MALFORMED}.to_json()
        else
            customer_name = customer["name"].as_s()

            _dbg(dbg, log, O_BRACKET + customer_name + C_BRACKET)

            # Creating a new customer (putting customer data to the database).
            cnx.exec(SQL_PUT_CUSTOMER, customer_name)

            customer_ = cnx.query_one(SQL_GET_ALL_CUSTOMERS + SQL_DESC_LIMIT_1,
                as: {Int64, String})

            cust = Customer.new(customer_[0], customer_[1])

            _dbg(dbg, log, "#{O_BRACKET}#{cust.id}" + # getId()
                              V_BAR     + cust.name + # getName()
                              C_BRACKET)

            ctx.response.headers.add(HDR_LOCATION_N, SLASH + REST_VERSION +
                                                     SLASH + REST_PREFIX  +
                                                  "#{SLASH}#{cust.id}")#getId()

            cust.to_json()
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

        payload = ctx.request.body.not_nil!()

        contact : JSON::Any

        # Trying to parse and validate the request payload.
        begin
            contact = JSON.parse(payload)
        rescue
            ctx.response.status_code = HTTP::Status::BAD_REQUEST.code()

            {:error => ERR_REQ_MALFORMED}.to_json()
        else
            contact_cust_id = contact["customer_id"].as_s()
            contact_contact = contact["contact"    ].as_s()

            _dbg(dbg, log, REST_CUST_ID + EQUALS + contact_cust_id)
            _dbg(dbg, log, O_BRACKET + contact_contact + C_BRACKET)

            # Parsing and validating a customer contact: phone or email.
            contact_type = _parse_contact(contact_contact)

            if (contact_type == SPACE)
                ctx.response.status_code = HTTP::Status::BAD_REQUEST.code()

                {:error => ERR_REQ_MALFORMED}.to_json()
            else
                sql_query = SQL_PUT_CONTACT[1]

                   if ((contact_type == PHONE) ||
                       (contact_type == PHONE.upcase()))

                    sql_query = SQL_PUT_CONTACT[0]
                elsif ((contact_type == EMAIL) ||
                       (contact_type == EMAIL.upcase()))

                    sql_query = SQL_PUT_CONTACT[1]
                end

                # Creating a new contact (putting a contact regarding
                # a given customer to the database).
                cnx.exec(sql_query, contact_contact, contact_cust_id)

                sql_query_ = SQL_GET_CONTACTS_BY_TYPE[2]

                   if ((contact_type == PHONE) ||
                       (contact_type == PHONE.upcase()))

                    sql_query_ = SQL_GET_CONTACTS_BY_TYPE[0] +
                                 SQL_ORDER_CONTACTS_BY_ID[0]
                elsif ((contact_type == EMAIL) ||
                       (contact_type == EMAIL.upcase()))

                    sql_query_ = SQL_GET_CONTACTS_BY_TYPE[1] +
                                 SQL_ORDER_CONTACTS_BY_ID[1]
                end

                begin
                    contact_ = cnx.query_one(sql_query_ + SQL_DESC_LIMIT_1,
                        contact_cust_id, as: String)
                rescue e: DB::NoResultsError
                    # Storing a special flag in the server context storage,
                    # indicating requesting for a non-existent customer.
                    ctx.set(REST_CUST_ID, true)

                    ctx.response.status_code = HTTP::Status::NOT_FOUND.code()
                else
                    cont = Contact.new(contact_)

                    _dbg(dbg, log, O_BRACKET + contact_type +
                                   V_BAR     + cont.contact + # getContact()
                                   C_BRACKET)

                    ctx.response.headers.add(HDR_LOCATION_N,
                                             SLASH + REST_VERSION    +
                                             SLASH + REST_PREFIX     +
                                             SLASH + contact_cust_id +
                                             SLASH + REST_CONTACTS   +
                                             SLASH + contact_type)

                    cont.to_json()
                end
            end
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

        customer_id = ctx.params.url[REST_CUST_ID]

        _dbg(dbg, log, REST_CUST_ID + EQUALS + customer_id)

        # Validating the request path variable.
        cust_id = customer_id.to_i64?()

        if (cust_id == nil)
            ctx.response.status_code = HTTP::Status::BAD_REQUEST.code()

            {:error => ERR_REQ_MALFORMED}.to_json()
        else
            # Retrieving profile details for a given customer
            # from the database.
            customer = cnx.query_one(SQL_GET_CUSTOMER_BY_ID, cust_id,
                as: {Int64, String}) rescue {0.to_i64(), EMPTY_STRING}

            if (customer[0] == 0)
                # Storing a special flag in the server context storage,
                # indicating requesting for a non-existent customer.
                ctx.set(REST_CUST_ID, true)

                ctx.response.status_code = HTTP::Status::NOT_FOUND.code()
            else
                cust = Customer.new(customer[0], customer[1])

                _dbg(dbg, log, "#{O_BRACKET}#{cust.id}" + # getId()
                                  V_BAR     + cust.name + # getName()
                                  C_BRACKET)

                cust.to_json()
            end
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

        customer_id = ctx.params.url[REST_CUST_ID]

        _dbg(dbg, log, REST_CUST_ID + EQUALS + customer_id)

        # Validating the request path variable.
        cust_id = customer_id.to_i64?()

        if (cust_id == nil)
            ctx.response.status_code = HTTP::Status::BAD_REQUEST.code()

            {:error => ERR_REQ_MALFORMED}.to_json()
        else
            conts = [] of Contact

            # Retrieving all contacts associated with a given customer
            # from the database.
            cnx.query(SQL_GET_ALL_CONTACTS,
                cust_id, # <== For retrieving phones.
                cust_id  # <== For retrieving emails.
            ) do |contacts|
                contacts.each() do
                    conts << Contact.new(contacts.read(String))
                end
            end

            if (conts.size() == 0)
                # Storing a special flag in the server context storage,
                # indicating there are no contacts belonging to a given
                # customer exist, or there is no customer with such ID.
                ctx.set(REST_CONTACTS, true)

                ctx.response.status_code = HTTP::Status::NOT_FOUND.code()
            else
                _dbg(dbg, log, O_BRACKET + conts[0].contact + # getContact()
                               C_BRACKET)

                conts.to_json()
            end
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

        customer_id  = ctx.params.url[REST_CUST_ID]
        contact_type = ctx.params.url[REST_CONT_TYPE]

        _dbg(dbg, log, REST_CUST_ID   + EQUALS + customer_id + SPACE + V_BAR +
               SPACE + REST_CONT_TYPE + EQUALS + contact_type)

        # Validating the request path variable {customer_id}.
        cust_id = customer_id.to_i64?()

        if (cust_id == nil)
            ctx.response.status_code = HTTP::Status::BAD_REQUEST.code()

            {:error => ERR_REQ_MALFORMED}.to_json()
        else
            sql_query = SQL_GET_CONTACTS_BY_TYPE[2]

               if ((contact_type == PHONE) || (contact_type == PHONE.upcase()))
                sql_query = SQL_GET_CONTACTS_BY_TYPE[0]
            elsif ((contact_type == EMAIL) || (contact_type == EMAIL.upcase()))
                sql_query = SQL_GET_CONTACTS_BY_TYPE[1]
            end

            conts = [] of Contact

            # Retrieving all contacts of a given type associated
            # with a given customer from the database.
            cnx.query(sql_query, cust_id) do |contacts|
                contacts.each() do
                    conts << Contact.new(contacts.read(String))
                end
            end

            if (conts.size() == 0)
                # Storing a special flag in the server context storage,
                # indicating there are no contacts of a given type belonging
                # to a given customer exist, or there is no customer
                # with such ID.
                ctx.set(REST_CONTACTS, true)

                ctx.response.status_code = HTTP::Status::NOT_FOUND.code()
            else
                _dbg(dbg, log, O_BRACKET + conts[0].contact + # getContact()
                               C_BRACKET)

                conts.to_json()
            end
        end
    end

    # Unused route method stubs - just to respond with HTTP 405 ---------------

    post    (SLASH + ANY) do end
    patch   (SLASH + ANY) do end
    delete  (SLASH + ANY) do end
    options (SLASH + ANY) do end

    # Conventional HTTP error responses ---------------------------------------

    error 404 do |ctx|
        # Retrieving special flags from the server context storage (if any),
        # placed there by PUT and GET endpoints.
        is_cust_id  = ctx.get?(REST_CUST_ID)
        is_contacts = ctx.get?(REST_CONTACTS)

           if ((is_cust_id  != nil) && is_cust_id)
            {:error => ERR_REQ_NOT_FOUND_2}.to_json()
        elsif ((is_contacts != nil) && is_contacts)
            {:error => ERR_REQ_NOT_FOUND_3}.to_json()
        else
            {:error => ERR_REQ_NOT_FOUND_1}.to_json()
        end
    end
end

# Helper function. Used to parse and validate a customer contact.
#                  Returns the type of contact: phone or email.
private def _parse_contact(contact)
    phone_regex = Regex.literal(PHONE_REGEX, i: true)
    email_regex = Regex.literal(EMAIL_REGEX, i: true)

       if (phone_regex.match(contact) != nil) PHONE
    elsif (email_regex.match(contact) != nil) EMAIL
    else SPACE end
end

# vim:set nu et ts=4 sw=4:
