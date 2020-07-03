-module(emqx_psk_pgsql_sup).

-behaviour(supervisor).

-include("emqx_psk_pgsql.hrl").

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    %% PgSQL Connection Pool
    {ok, Opts} = application:get_env(?APP, server),
    PoolSpec = ecpool:pool_spec(?APP, ?APP, emqx_psk_pgsql_client, Opts),
    {ok, {{one_for_one, 10, 100}, [PoolSpec]}}.
