#
# src/api-lite-helper.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.1.5
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The helper module for the daemon --------------------------------------------

require "toml"

module Helper
    extend self

    # Helper constants.
    EXIT_FAILURE =   1 #    Failing exit status.
    EXIT_SUCCESS =   0 # Successful exit status.
    EMPTY_STRING =  ""
    SPACE        = " "
    SLASH        = "/"
    ANY          = "*"
    COLON        = ":"
    MINUS        = "-"
    O_BRACKET    = "["
    C_BRACKET    = "]"

    # Common notification messages.
    MSG_SERVER_STARTED = "Server started on port "
    MSG_SERVER_STOPPED = "Server stopped"

    # Common error messages.
    ERR_PORT_VALID_MUST_BE_POSITIVE_INT =
        "Valid server port must be a positive integer value, "   +
        "in the range 1024 .. 49151. The default value of 8080 " +
        "will be used instead."
    ERR_CANNOT_START_SERVER =
        "FATAL: Cannot start server "
    ERR_ADDR_ALREADY_IN_USE =
        "due to address requested already in use. Quitting..."
    ERR_SERV_UNKNOWN_REASON =
        "for an unknown reason. Quitting..."
    ERR_REQ_NOT_FOUND =
        "HTTP 404 Not Found: Bad HTTP method used or no such " +
        "REST URI path exists. Please check your inputs."

    # The path and filename of the daemon settings.
    SETTINGS = "./etc/settings.conf"

    # The minimum port number allowed.
    MIN_PORT = 1024

    # The maximum port number allowed.
    MAX_PORT = 49151

    # The default server port number.
    DEF_PORT = 8080

    # Daemon settings keys for the microservice daemon name.
    DAEMON_NAME_G = "daemon"
    DAEMON_NAME_S = "name"

    # Daemon settings keys for the server port number.
    SERVER_PORT_G = "server"
    SERVER_PORT_S = "port"

    # Daemon settings keys for the debug logging enabler.
    LOG_ENABLED_G  = "logger"
    LOG_ENABLED_S1 = "debug"
    LOG_ENABLED_S2 = "enabled"

    LOG_DIR = "./log/"
    LOGFILE = "customers-api-lite.log"
    LOGTIME = "[%F][%T]"
    LOGSRCS = "*"
    APPEND_ = "a+"

    SVRT_INFO = "INFO"
    SVRT_WARN = "WARN"

    # Daemon settings keys for the SQLite database path.
    DB_PATH_G  = "sqlite"
    DB_PATH_S1 = "database"
    DB_PATH_S2 = "path"

    # The SQLite database connection schema.
    DB_CONN_SCHEMA = "sqlite3://"

    # REST URI path-related constants.
    REST_VERSION   = "v1"
    REST_PREFIX    = "customers"
    REST_CUST_ID   = "customer_id"
    REST_CONTACTS  = "contacts"
    REST_CONT_TYPE = "contact_type"

    # HTTP response-related constants.
    MIME_TYPE   = "application/json"
    HDR_ALLOW_N = "Allow"
    HDR_ALLOW_V = "PUT, GET, HEAD"

    # Helper function. Used to get the daemon settings.
    def _get_settings()
        settings = TOML.parse(File.read(SETTINGS))
    end

    # Helper function. Retrieves the port number used to run
    #                  the Kemal web server, from daemon settings.
    def _get_server_port(settings, log)
        server_port = settings[SERVER_PORT_G][SERVER_PORT_S].as_i()

        if (server_port != 0)
            if ((server_port >= MIN_PORT) && (server_port <= MAX_PORT))
                return server_port
            else
                log.error{ERR_PORT_VALID_MUST_BE_POSITIVE_INT}; return DEF_PORT
            end
        else
            log.error{ERR_PORT_VALID_MUST_BE_POSITIVE_INT}; return DEF_PORT
        end
    end

    # Helper func. Used to set log format for both console and logfile output.
    def _set_log_format(entry, io)
        logtime = Time::Format.new(LOGTIME)

        entry_severity = entry.severity.label()

        if ((entry_severity == SVRT_INFO) || (entry_severity == SVRT_WARN))
             entry_severity += SPACE
        end

        io << logtime.format(entry.timestamp)            + SPACE +
                O_BRACKET << entry_severity << C_BRACKET + SPACE <<
                             entry.message
    end

    # Helper function. Used to log messages for debugging aims in a free form.
    def _dbg(dbg, log, message)
        if (dbg)
               log.debug{message}
            Syslog.debug(message)
        end
    end

    # Helper function. Makes final cleanups, closes streams, etc.
    def _cleanup(cnx)
        cnx.close()

        Syslog.info(MSG_SERVER_STOPPED)

        # Closing the system logger.
        # Calling <syslog.h> closelog();
        Syslog.close()
    end

    # Globals and their getters and setters -----------------------------------

    @@dbg                = false
    @@log                = Log.for(EMPTY_STRING)
    @@cnx : DB::Database = DB.open(DB_CONN_SCHEMA)

    def dbg() @@dbg end
    def dbg=(@@dbg) end

    def log() @@log end
    def log=(@@log) end

    def cnx() @@cnx end
    def cnx=(@@cnx) end
end

# vim:set nu et ts=4 sw=4:
