CREATE TABLE IF NOT EXISTS "mqtt_dtls_psk"(
    id text PRIMARY KEY UNIQUE,
    psk bytea NOT NULL,
    created_at timestamptz DEFAULT now()
);