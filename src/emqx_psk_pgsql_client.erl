-module(emqx_psk_pgsql_client).

-behaviour(ecpool_worker).

-include("emqx_psk_pgsql.hrl").

-export([connect/1]).

-export([lookup_query/1]).

-define(LOOKUP_QUERY, "lookup_query").
-define(LOG(Level, Msg), logger:log(Level, Msg)).
-define(LOG(Level, Fmt, Args), logger:log(Level, Fmt, Args)).

%%--------------------------------------------------------------------
%% PostgreSQL Connect/Query
%%--------------------------------------------------------------------

connect(Opts) ->
    Host     = proplists:get_value(host, Opts),
    Username = proplists:get_value(username, Opts),
    Password = proplists:get_value(password, Opts),
    case epgsql:connect(Host, Username, Password, conn_opts(Opts)) of
        {ok, C} ->
            conn_post(C),
            {ok, C};
        {error, Reason = econnrefused} ->
            ?LOG(error, "[Postgres] Can't connect to Postgres server: Connection refused."),
            {error, Reason};
        {error, Reason = invalid_authorization_specification} ->
            ?LOG(error, "[Postgres] Can't connect to Postgres server: Invalid authorization specification."),
            {error, Reason};
        {error, Reason = invalid_password} ->
            ?LOG(error, "[Postgres] Can't connect to Postgres server: Invalid password."),
            {error, Reason};
        {error, Reason} ->
            ?LOG(error, "[Postgres] Can't connect to Postgres server: ~p", [Reason]),
            {error, Reason}
    end.

conn_post(Connection) ->
    % Parse prepared queries post connection
    LookupQuery = application:get_env(?APP, lookup_query, undefined),
    {ok, _} = epgsql:parse(Connection, ?LOOKUP_QUERY, LookupQuery, []).

conn_opts(Opts) ->
    conn_opts(Opts, []).
conn_opts([], Acc) ->
    Acc;
conn_opts([Opt = {database, _}|Opts], Acc) ->
    conn_opts(Opts, [Opt|Acc]);
conn_opts([Opt = {ssl, _}|Opts], Acc) ->
    conn_opts(Opts, [Opt|Acc]);
conn_opts([Opt = {port, _}|Opts], Acc) ->
    conn_opts(Opts, [Opt|Acc]);
conn_opts([Opt = {timeout, _}|Opts], Acc) ->
    conn_opts(Opts, [Opt|Acc]);
conn_opts([Opt = {ssl_opts, _}|Opts], Acc) ->
    conn_opts(Opts, [Opt|Acc]);
conn_opts([_Opt|Opts], Acc) ->
    conn_opts(Opts, Acc).

lookup_query(ClientPSKID) ->
    ecpool:with_client(?APP, fun(C) -> epgsql:prepared_query(C, ?LOOKUP_QUERY, [ClientPSKID]) end).
