-module(emqx_psk_pgsql_app).

-behaviour(application).

-emqx_plugin(?MODULE).

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqx_psk_pgsql_sup:start_link(),
    ok = emqx:hook('tls_handshake.psk_lookup', fun emqx_psk_pgsql:psk_lookup/2, []),
    {ok, Sup}.

stop(_State) ->
    ok = emqx:unhook('tls_handshake.psk_lookup', fun emqx_psk_pgsql:psk_lookup/2).