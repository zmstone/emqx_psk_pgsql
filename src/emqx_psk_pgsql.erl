-module(emqx_psk_pgsql).

-export([psk_lookup/2]).

psk_lookup(ClientPSKID, UserState) ->
    case emqx_psk_pgsql_client:lookup_query(ClientPSKID) of
        {ok, _Cols, [{PSK} | _]} ->
            {stop, PSK};
        _NotFound ->
            {ok, UserState}
    end.