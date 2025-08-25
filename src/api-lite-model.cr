#
# src/api-lite-model.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.1.7
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The model module of the daemon ----------------------------------------------

module Model
    # The SQL query for retrieving all customer profiles.
    #
    # Used by the `GET /v1/customers` REST endpoint.
    SQL_GET_ALL_CUSTOMERS  =
        "select id ,"      + # as 'Customer ID'
        "       name"      + # as 'Customer Name'
        " from"            +
        "       customers" +
        " order by"        +
        "       id"

    # The SQL query for retrieving profile details for a given customer.
    #
    # Used by the `GET /v1/customers/{customer_id}` REST endpoint.
    SQL_GET_CUSTOMER_BY_ID =
        "select id ,"      + # as 'Customer ID'
        "       name"      + # as 'Customer Name'
        " from"            +
        "       customers" +
        " where"           +
        "      (id = ?)"

    # The SQL query for retrieving all contacts for a given customer.
    #
    # Used by the `GET /v1/customers/{customer_id}/contacts` REST endpoint.
    SQL_GET_ALL_CONTACTS =
        "select phones.contact"                    + # as 'Phone(s)'
        " from"                                    +
        "       contact_phones phones,"            +
        "       customers      cust"               +
        " where"                                   +
        "      (cust.id = phones.customer_id) and" +
        "      (cust.id =                  ?)"     +
        " union "                                  +
        "select emails.contact"                    + # as 'Email(s)'
        " from"                                    +
        "       contact_emails emails,"            +
        "       customers      cust"               +
        " where"                                   +
        "      (cust.id = emails.customer_id) and" +
        "      (cust.id =                  ?)"

    # The struct defining the Customer entity.
    struct Customer
        include JSON::Serializable

        property(id   : Int64 )
        property(name : String)

        def initialize(@id, @name)
        end
    end

    # The struct defining the Contact entity.
    struct Contact
        include JSON::Serializable

        property(contact     : String)

        @[JSON::Field(ignore_serialize: true)]
        property(customer_id : String)

        def initialize(@contact, @customer_id = EMPTY_STRING)
        end
    end
end

# vim:set nu et ts=4 sw=4:
