--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.25
-- Dumped by pg_dump version 9.5.25

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: batch_delete_expired_rows(); Type: FUNCTION; Schema: public; Owner: macf
--

CREATE FUNCTION public.batch_delete_expired_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          EXECUTE FORMAT('WITH rows AS (SELECT ctid FROM %s WHERE %s < CURRENT_TIMESTAMP AT TIME ZONE ''UTC'' ORDER BY %s LIMIT 2 FOR UPDATE SKIP LOCKED) DELETE FROM %s WHERE ctid IN (TABLE rows)', TG_TABLE_NAME, TG_ARGV[0], TG_ARGV[0], TG_TABLE_NAME);
          RETURN NULL;
        END;
      $$;


ALTER FUNCTION public.batch_delete_expired_rows() OWNER TO macf;

--
-- Name: sync_tags(); Type: FUNCTION; Schema: public; Owner: macf
--

CREATE FUNCTION public.sync_tags() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          IF (TG_OP = 'TRUNCATE') THEN
            DELETE FROM tags WHERE entity_name = TG_TABLE_NAME;
            RETURN NULL;
          ELSIF (TG_OP = 'DELETE') THEN
            DELETE FROM tags WHERE entity_id = OLD.id;
            RETURN OLD;
          ELSE

          -- Triggered by INSERT/UPDATE
          -- Do an upsert on the tags table
          -- So we don't need to migrate pre 1.1 entities
          INSERT INTO tags VALUES (NEW.id, TG_TABLE_NAME, NEW.tags)
          ON CONFLICT (entity_id) DO UPDATE
                  SET tags=EXCLUDED.tags;
          END IF;
          RETURN NEW;
        END;
      $$;


ALTER FUNCTION public.sync_tags() OWNER TO macf;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acls; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.acls (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    consumer_id uuid,
    "group" text,
    cache_key text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.acls OWNER TO macf;

--
-- Name: acme_storage; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.acme_storage (
    id uuid NOT NULL,
    key text,
    value text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE public.acme_storage OWNER TO macf;

--
-- Name: basicauth_credentials; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.basicauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    consumer_id uuid,
    username text,
    password text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.basicauth_credentials OWNER TO macf;

--
-- Name: ca_certificates; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.ca_certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    cert text NOT NULL,
    tags text[],
    cert_digest text NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.ca_certificates OWNER TO macf;

--
-- Name: certificates; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.certificates (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    cert text,
    key text,
    tags text[],
    ws_id uuid,
    cert_alt text,
    key_alt text,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.certificates OWNER TO macf;

--
-- Name: cluster_events; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.cluster_events (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    at timestamp with time zone NOT NULL,
    nbf timestamp with time zone,
    expire_at timestamp with time zone NOT NULL,
    channel text,
    data text
);


ALTER TABLE public.cluster_events OWNER TO macf;

--
-- Name: clustering_data_planes; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.clustering_data_planes (
    id uuid NOT NULL,
    hostname text NOT NULL,
    ip text NOT NULL,
    last_seen timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    config_hash text NOT NULL,
    ttl timestamp with time zone,
    version text,
    sync_status text DEFAULT 'unknown'::text NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    labels jsonb,
    cert_details jsonb,
    rpc_capabilities text[]
);


ALTER TABLE public.clustering_data_planes OWNER TO macf;

--
-- Name: clustering_rpc_requests; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.clustering_rpc_requests (
    id bigint NOT NULL,
    node_id uuid NOT NULL,
    reply_to uuid NOT NULL,
    ttl timestamp with time zone NOT NULL,
    payload json NOT NULL
);


ALTER TABLE public.clustering_rpc_requests OWNER TO macf;

--
-- Name: clustering_rpc_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.clustering_rpc_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clustering_rpc_requests_id_seq OWNER TO macf;

--
-- Name: clustering_rpc_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.clustering_rpc_requests_id_seq OWNED BY public.clustering_rpc_requests.id;


--
-- Name: consumers; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.consumers (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    username text,
    custom_id text,
    tags text[],
    ws_id uuid,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.consumers OWNER TO macf;

--
-- Name: filter_chains; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.filter_chains (
    id uuid NOT NULL,
    name text,
    enabled boolean DEFAULT true,
    route_id uuid,
    service_id uuid,
    ws_id uuid,
    cache_key text,
    filters jsonb[],
    tags text[],
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.filter_chains OWNER TO macf;

--
-- Name: hmacauth_credentials; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.hmacauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    consumer_id uuid,
    username text,
    secret text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.hmacauth_credentials OWNER TO macf;

--
-- Name: jwt_secrets; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.jwt_secrets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    consumer_id uuid,
    key text,
    secret text,
    algorithm text,
    rsa_public_key text,
    tags text[],
    ws_id uuid
);


ALTER TABLE public.jwt_secrets OWNER TO macf;

--
-- Name: key_sets; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.key_sets (
    id uuid NOT NULL,
    name text,
    tags text[],
    ws_id uuid,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.key_sets OWNER TO macf;

--
-- Name: keyauth_credentials; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.keyauth_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    consumer_id uuid,
    key text,
    tags text[],
    ttl timestamp with time zone,
    ws_id uuid
);


ALTER TABLE public.keyauth_credentials OWNER TO macf;

--
-- Name: keys; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.keys (
    id uuid NOT NULL,
    set_id uuid,
    name text,
    cache_key text,
    ws_id uuid,
    kid text,
    jwk text,
    pem jsonb,
    tags text[],
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.keys OWNER TO macf;

--
-- Name: konga_api_health_checks; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_api_health_checks (
    id integer NOT NULL,
    api_id text,
    api json,
    health_check_endpoint text,
    notification_endpoint text,
    active boolean,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_api_health_checks OWNER TO macf;

--
-- Name: konga_api_health_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_api_health_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_api_health_checks_id_seq OWNER TO macf;

--
-- Name: konga_api_health_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_api_health_checks_id_seq OWNED BY public.konga_api_health_checks.id;


--
-- Name: konga_email_transports; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_email_transports (
    id integer NOT NULL,
    name text,
    description text,
    schema json,
    settings json,
    active boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_email_transports OWNER TO macf;

--
-- Name: konga_email_transports_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_email_transports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_email_transports_id_seq OWNER TO macf;

--
-- Name: konga_email_transports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_email_transports_id_seq OWNED BY public.konga_email_transports.id;


--
-- Name: konga_kong_nodes; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_kong_nodes (
    id integer NOT NULL,
    name text,
    type text,
    kong_admin_url text,
    netdata_url text,
    kong_api_key text,
    jwt_algorithm text,
    jwt_key text,
    jwt_secret text,
    username text,
    password text,
    kong_version text,
    health_checks boolean,
    health_check_details json,
    active boolean,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_kong_nodes OWNER TO macf;

--
-- Name: konga_kong_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_kong_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_kong_nodes_id_seq OWNER TO macf;

--
-- Name: konga_kong_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_kong_nodes_id_seq OWNED BY public.konga_kong_nodes.id;


--
-- Name: konga_kong_services; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_kong_services (
    id integer NOT NULL,
    service_id text,
    kong_node_id text,
    description text,
    tags json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_kong_services OWNER TO macf;

--
-- Name: konga_kong_services_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_kong_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_kong_services_id_seq OWNER TO macf;

--
-- Name: konga_kong_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_kong_services_id_seq OWNED BY public.konga_kong_services.id;


--
-- Name: konga_kong_snapshot_schedules; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_kong_snapshot_schedules (
    id integer NOT NULL,
    connection integer,
    active boolean,
    cron text,
    "lastRunAt" date,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_kong_snapshot_schedules OWNER TO macf;

--
-- Name: konga_kong_snapshot_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_kong_snapshot_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_kong_snapshot_schedules_id_seq OWNER TO macf;

--
-- Name: konga_kong_snapshot_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_kong_snapshot_schedules_id_seq OWNED BY public.konga_kong_snapshot_schedules.id;


--
-- Name: konga_kong_snapshots; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_kong_snapshots (
    id integer NOT NULL,
    name text,
    kong_node_name text,
    kong_node_url text,
    kong_version text,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_kong_snapshots OWNER TO macf;

--
-- Name: konga_kong_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_kong_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_kong_snapshots_id_seq OWNER TO macf;

--
-- Name: konga_kong_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_kong_snapshots_id_seq OWNED BY public.konga_kong_snapshots.id;


--
-- Name: konga_kong_upstream_alerts; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_kong_upstream_alerts (
    id integer NOT NULL,
    upstream_id text,
    connection integer,
    email boolean,
    slack boolean,
    cron text,
    active boolean,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_kong_upstream_alerts OWNER TO macf;

--
-- Name: konga_kong_upstream_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_kong_upstream_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_kong_upstream_alerts_id_seq OWNER TO macf;

--
-- Name: konga_kong_upstream_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_kong_upstream_alerts_id_seq OWNED BY public.konga_kong_upstream_alerts.id;


--
-- Name: konga_netdata_connections; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_netdata_connections (
    id integer NOT NULL,
    "apiId" text,
    url text,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_netdata_connections OWNER TO macf;

--
-- Name: konga_netdata_connections_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_netdata_connections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_netdata_connections_id_seq OWNER TO macf;

--
-- Name: konga_netdata_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_netdata_connections_id_seq OWNED BY public.konga_netdata_connections.id;


--
-- Name: konga_passports; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_passports (
    id integer NOT NULL,
    protocol text,
    password text,
    provider text,
    identifier text,
    tokens json,
    "user" integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.konga_passports OWNER TO macf;

--
-- Name: konga_passports_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_passports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_passports_id_seq OWNER TO macf;

--
-- Name: konga_passports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_passports_id_seq OWNED BY public.konga_passports.id;


--
-- Name: konga_settings; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_settings (
    id integer NOT NULL,
    data json,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_settings OWNER TO macf;

--
-- Name: konga_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_settings_id_seq OWNER TO macf;

--
-- Name: konga_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_settings_id_seq OWNED BY public.konga_settings.id;


--
-- Name: konga_users; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.konga_users (
    id integer NOT NULL,
    username text,
    email text,
    "firstName" text,
    "lastName" text,
    admin boolean,
    node_id text,
    active boolean,
    "activationToken" text,
    node integer,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "createdUserId" integer,
    "updatedUserId" integer
);


ALTER TABLE public.konga_users OWNER TO macf;

--
-- Name: konga_users_id_seq; Type: SEQUENCE; Schema: public; Owner: macf
--

CREATE SEQUENCE public.konga_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.konga_users_id_seq OWNER TO macf;

--
-- Name: konga_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: macf
--

ALTER SEQUENCE public.konga_users_id_seq OWNED BY public.konga_users.id;


--
-- Name: locks; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.locks (
    key text NOT NULL,
    owner text,
    ttl timestamp with time zone
);


ALTER TABLE public.locks OWNER TO macf;

--
-- Name: oauth2_authorization_codes; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.oauth2_authorization_codes (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    credential_id uuid,
    service_id uuid,
    code text,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone,
    challenge text,
    challenge_method text,
    ws_id uuid,
    plugin_id uuid
);


ALTER TABLE public.oauth2_authorization_codes OWNER TO macf;

--
-- Name: oauth2_credentials; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.oauth2_credentials (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    name text,
    consumer_id uuid,
    client_id text,
    client_secret text,
    redirect_uris text[],
    tags text[],
    client_type text,
    hash_secret boolean,
    ws_id uuid
);


ALTER TABLE public.oauth2_credentials OWNER TO macf;

--
-- Name: oauth2_tokens; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.oauth2_tokens (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    credential_id uuid,
    service_id uuid,
    access_token text,
    refresh_token text,
    token_type text,
    expires_in integer,
    authenticated_userid text,
    scope text,
    ttl timestamp with time zone,
    ws_id uuid
);


ALTER TABLE public.oauth2_tokens OWNER TO macf;

--
-- Name: parameters; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.parameters (
    key text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone
);


ALTER TABLE public.parameters OWNER TO macf;

--
-- Name: plugins; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.plugins (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    name text NOT NULL,
    consumer_id uuid,
    service_id uuid,
    route_id uuid,
    config jsonb NOT NULL,
    enabled boolean NOT NULL,
    cache_key text,
    protocols text[],
    tags text[],
    ws_id uuid,
    instance_name text,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.plugins OWNER TO macf;

--
-- Name: ratelimiting_metrics; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer,
    ttl timestamp with time zone
);


ALTER TABLE public.ratelimiting_metrics OWNER TO macf;

--
-- Name: response_ratelimiting_metrics; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.response_ratelimiting_metrics (
    identifier text NOT NULL,
    period text NOT NULL,
    period_date timestamp with time zone NOT NULL,
    service_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    route_id uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL,
    value integer
);


ALTER TABLE public.response_ratelimiting_metrics OWNER TO macf;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.routes (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name text,
    service_id uuid,
    protocols text[],
    methods text[],
    hosts text[],
    paths text[],
    snis text[],
    sources jsonb[],
    destinations jsonb[],
    regex_priority bigint,
    strip_path boolean,
    preserve_host boolean,
    tags text[],
    https_redirect_status_code integer,
    headers jsonb,
    path_handling text DEFAULT 'v0'::text,
    ws_id uuid,
    request_buffering boolean,
    response_buffering boolean,
    expression text,
    priority bigint
);


ALTER TABLE public.routes OWNER TO macf;

--
-- Name: schema_meta; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.schema_meta (
    key text NOT NULL,
    subsystem text NOT NULL,
    last_executed text,
    executed text[],
    pending text[]
);


ALTER TABLE public.schema_meta OWNER TO macf;

--
-- Name: services; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.services (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name text,
    retries bigint,
    protocol text,
    host text,
    port bigint,
    path text,
    connect_timeout bigint,
    write_timeout bigint,
    read_timeout bigint,
    tags text[],
    client_certificate_id uuid,
    tls_verify boolean,
    tls_verify_depth smallint,
    ca_certificates uuid[],
    ws_id uuid,
    enabled boolean DEFAULT true
);


ALTER TABLE public.services OWNER TO macf;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    session_id text,
    expires integer,
    data text,
    created_at timestamp with time zone,
    ttl timestamp with time zone
);


ALTER TABLE public.sessions OWNER TO macf;

--
-- Name: sm_vaults; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.sm_vaults (
    id uuid NOT NULL,
    ws_id uuid,
    prefix text,
    name text NOT NULL,
    description text,
    config jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    updated_at timestamp with time zone,
    tags text[]
);


ALTER TABLE public.sm_vaults OWNER TO macf;

--
-- Name: snis; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.snis (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    name text NOT NULL,
    certificate_id uuid,
    tags text[],
    ws_id uuid,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.snis OWNER TO macf;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.tags (
    entity_id uuid NOT NULL,
    entity_name text,
    tags text[]
);


ALTER TABLE public.tags OWNER TO macf;

--
-- Name: targets; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.targets (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(3) with time zone),
    upstream_id uuid,
    target text NOT NULL,
    weight integer NOT NULL,
    tags text[],
    ws_id uuid,
    cache_key text,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(3) with time zone)
);


ALTER TABLE public.targets OWNER TO macf;

--
-- Name: upstreams; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.upstreams (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(3) with time zone),
    name text,
    hash_on text,
    hash_fallback text,
    hash_on_header text,
    hash_fallback_header text,
    hash_on_cookie text,
    hash_on_cookie_path text,
    slots integer NOT NULL,
    healthchecks jsonb,
    tags text[],
    algorithm text,
    host_header text,
    client_certificate_id uuid,
    ws_id uuid,
    hash_on_query_arg text,
    hash_fallback_query_arg text,
    hash_on_uri_capture text,
    hash_fallback_uri_capture text,
    use_srv_name boolean DEFAULT false,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.upstreams OWNER TO macf;

--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: macf
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    name text,
    comment text,
    created_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone),
    meta jsonb,
    config jsonb,
    updated_at timestamp with time zone DEFAULT timezone('UTC'::text, ('now'::text)::timestamp(0) with time zone)
);


ALTER TABLE public.workspaces OWNER TO macf;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.clustering_rpc_requests ALTER COLUMN id SET DEFAULT nextval('public.clustering_rpc_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_api_health_checks ALTER COLUMN id SET DEFAULT nextval('public.konga_api_health_checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_email_transports ALTER COLUMN id SET DEFAULT nextval('public.konga_email_transports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_nodes ALTER COLUMN id SET DEFAULT nextval('public.konga_kong_nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_services ALTER COLUMN id SET DEFAULT nextval('public.konga_kong_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_snapshot_schedules ALTER COLUMN id SET DEFAULT nextval('public.konga_kong_snapshot_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_snapshots ALTER COLUMN id SET DEFAULT nextval('public.konga_kong_snapshots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_upstream_alerts ALTER COLUMN id SET DEFAULT nextval('public.konga_kong_upstream_alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_netdata_connections ALTER COLUMN id SET DEFAULT nextval('public.konga_netdata_connections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_passports ALTER COLUMN id SET DEFAULT nextval('public.konga_passports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_settings ALTER COLUMN id SET DEFAULT nextval('public.konga_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_users ALTER COLUMN id SET DEFAULT nextval('public.konga_users_id_seq'::regclass);


--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.acls (id, created_at, consumer_id, "group", cache_key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: acme_storage; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.acme_storage (id, key, value, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: basicauth_credentials; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.basicauth_credentials (id, created_at, consumer_id, username, password, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: ca_certificates; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.ca_certificates (id, created_at, cert, tags, cert_digest, updated_at) FROM stdin;
\.


--
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.certificates (id, created_at, cert, key, tags, ws_id, cert_alt, key_alt, updated_at) FROM stdin;
\.


--
-- Data for Name: cluster_events; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.cluster_events (id, node_id, at, nbf, expire_at, channel, data) FROM stdin;
\.


--
-- Data for Name: clustering_data_planes; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.clustering_data_planes (id, hostname, ip, last_seen, config_hash, ttl, version, sync_status, updated_at, labels, cert_details, rpc_capabilities) FROM stdin;
\.


--
-- Data for Name: clustering_rpc_requests; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.clustering_rpc_requests (id, node_id, reply_to, ttl, payload) FROM stdin;
\.


--
-- Name: clustering_rpc_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.clustering_rpc_requests_id_seq', 1, false);


--
-- Data for Name: consumers; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.consumers (id, created_at, username, custom_id, tags, ws_id, updated_at) FROM stdin;
\.


--
-- Data for Name: filter_chains; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.filter_chains (id, name, enabled, route_id, service_id, ws_id, cache_key, filters, tags, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: hmacauth_credentials; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.hmacauth_credentials (id, created_at, consumer_id, username, secret, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: jwt_secrets; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.jwt_secrets (id, created_at, consumer_id, key, secret, algorithm, rsa_public_key, tags, ws_id) FROM stdin;
\.


--
-- Data for Name: key_sets; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.key_sets (id, name, tags, ws_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: keyauth_credentials; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.keyauth_credentials (id, created_at, consumer_id, key, tags, ttl, ws_id) FROM stdin;
\.


--
-- Data for Name: keys; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.keys (id, set_id, name, cache_key, ws_id, kid, jwk, pem, tags, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: konga_api_health_checks; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_api_health_checks (id, api_id, api, health_check_endpoint, notification_endpoint, active, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Name: konga_api_health_checks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_api_health_checks_id_seq', 1, false);


--
-- Data for Name: konga_email_transports; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_email_transports (id, name, description, schema, settings, active, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
3	smtp	Send emails using the SMTP protocol	[{"name":"host","description":"The SMTP host","type":"text","required":true},{"name":"port","description":"The SMTP port","type":"text","required":true},{"name":"username","model":"auth.user","description":"The SMTP user username","type":"text","required":true},{"name":"password","model":"auth.pass","description":"The SMTP user password","type":"text","required":true},{"name":"secure","model":"secure","description":"Use secure connection","type":"boolean"}]	{"host":"","port":"","auth":{"user":"","pass":""},"secure":false}	t	2024-10-15 02:37:28+00	2024-10-17 13:04:39+00	\N	\N
1	sendmail	Pipe messages to the sendmail command	\N	{"sendmail":true}	f	2024-10-15 02:37:28+00	2024-10-17 13:04:39+00	\N	\N
2	mailgun	Send emails through Mailgun’s Web API	[{"name":"api_key","model":"auth.api_key","description":"The API key that you got from www.mailgun.com/cp","type":"text","required":true},{"name":"domain","model":"auth.domain","description":"One of your domain names listed at your https://mailgun.com/app/domains","type":"text","required":true}]	{"auth":{"api_key":"","domain":""}}	f	2024-10-15 02:37:28+00	2024-10-17 13:04:39+00	\N	\N
\.


--
-- Name: konga_email_transports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_email_transports_id_seq', 3, true);


--
-- Data for Name: konga_kong_nodes; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_kong_nodes (id, name, type, kong_admin_url, netdata_url, kong_api_key, jwt_algorithm, jwt_key, jwt_secret, username, password, kong_version, health_checks, health_check_details, active, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	admin	default	http://kong-admin.kong-development.svc.cluster.local:8001	\N		HS256	\N	\N			2.7.2	f	\N	f	2024-10-17 08:00:43+00	2024-10-17 13:48:22+00	1	1
\.


--
-- Name: konga_kong_nodes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_kong_nodes_id_seq', 1, true);


--
-- Data for Name: konga_kong_services; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_kong_services (id, service_id, kong_node_id, description, tags, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Name: konga_kong_services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_kong_services_id_seq', 1, false);


--
-- Data for Name: konga_kong_snapshot_schedules; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_kong_snapshot_schedules (id, connection, active, cron, "lastRunAt", "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Name: konga_kong_snapshot_schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_kong_snapshot_schedules_id_seq', 1, false);


--
-- Data for Name: konga_kong_snapshots; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_kong_snapshots (id, name, kong_node_name, kong_node_url, kong_version, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Name: konga_kong_snapshots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_kong_snapshots_id_seq', 1, false);


--
-- Data for Name: konga_kong_upstream_alerts; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_kong_upstream_alerts (id, upstream_id, connection, email, slack, cron, active, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Name: konga_kong_upstream_alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_kong_upstream_alerts_id_seq', 1, false);


--
-- Data for Name: konga_netdata_connections; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_netdata_connections (id, "apiId", url, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
\.


--
-- Name: konga_netdata_connections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_netdata_connections_id_seq', 1, false);


--
-- Data for Name: konga_passports; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_passports (id, protocol, password, provider, identifier, tokens, "user", "createdAt", "updatedAt") FROM stdin;
1	local	$2a$10$ElupaTjUcMRac0msayRONOfNFjDq8RDGlRqv0uSDpjIzQ6mCUHuCi	\N	\N	\N	1	2024-10-17 07:59:53+00	2024-10-17 07:59:53+00
\.


--
-- Name: konga_passports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_passports_id_seq', 1, true);


--
-- Data for Name: konga_settings; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_settings (id, data, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	{"signup_enable":false,"signup_require_activation":false,"info_polling_interval":5000,"email_default_sender_name":"KONGA","email_default_sender":"konga@konga.test","email_notifications":false,"default_transport":"sendmail","notify_when":{"node_down":{"title":"A node is down or unresponsive","description":"Health checks must be enabled for the nodes that need to be monitored.","active":false},"api_down":{"title":"An API is down or unresponsive","description":"Health checks must be enabled for the APIs that need to be monitored.","active":false}},"integrations":[{"id":"slack","name":"Slack","image":"slack_rgb.png","config":{"enabled":false,"fields":[{"id":"slack_webhook_url","name":"Slack Webhook URL","type":"text","required":true,"value":""}],"slack_webhook_url":""}}],"user_permissions":{"apis":{"create":false,"read":true,"update":false,"delete":false},"services":{"create":false,"read":true,"update":false,"delete":false},"routes":{"create":false,"read":true,"update":false,"delete":false},"consumers":{"create":false,"read":true,"update":false,"delete":false},"plugins":{"create":false,"read":true,"update":false,"delete":false},"upstreams":{"create":false,"read":true,"update":false,"delete":false},"certificates":{"create":false,"read":true,"update":false,"delete":false},"connections":{"create":false,"read":true,"update":false,"delete":false},"users":{"create":false,"read":true,"update":false,"delete":false}}}	2024-10-15 02:37:28+00	2024-10-17 13:04:39+00	\N	\N
\.


--
-- Name: konga_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_settings_id_seq', 1, true);


--
-- Data for Name: konga_users; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.konga_users (id, username, email, "firstName", "lastName", admin, node_id, active, "activationToken", node, "createdAt", "updatedAt", "createdUserId", "updatedUserId") FROM stdin;
1	macf	kontol@mcf.co.id	\N	\N	t		t	9b1541c5-7c1c-42a9-8eb2-47bca772d68d	1	2024-10-17 07:59:53+00	2024-10-17 13:48:22+00	\N	1
\.


--
-- Name: konga_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: macf
--

SELECT pg_catalog.setval('public.konga_users_id_seq', 1, true);


--
-- Data for Name: locks; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.locks (key, owner, ttl) FROM stdin;
\.


--
-- Data for Name: oauth2_authorization_codes; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.oauth2_authorization_codes (id, created_at, credential_id, service_id, code, authenticated_userid, scope, ttl, challenge, challenge_method, ws_id, plugin_id) FROM stdin;
\.


--
-- Data for Name: oauth2_credentials; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.oauth2_credentials (id, created_at, name, consumer_id, client_id, client_secret, redirect_uris, tags, client_type, hash_secret, ws_id) FROM stdin;
\.


--
-- Data for Name: oauth2_tokens; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.oauth2_tokens (id, created_at, credential_id, service_id, access_token, refresh_token, token_type, expires_in, authenticated_userid, scope, ttl, ws_id) FROM stdin;
\.


--
-- Data for Name: parameters; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.parameters (key, value, created_at) FROM stdin;
cluster_id	d757d71d-566a-4c58-9f5c-47be8ce99446	\N
\.



--
-- Data for Name: ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value, ttl) FROM stdin;
\.


--
-- Data for Name: response_ratelimiting_metrics; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.response_ratelimiting_metrics (identifier, period, period_date, service_id, route_id, value) FROM stdin;
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.routes (id, created_at, updated_at, name, service_id, protocols, methods, hosts, paths, snis, sources, destinations, regex_priority, strip_path, preserve_host, tags, https_redirect_status_code, headers, path_handling, ws_id, request_buffering, response_buffering, expression, priority) FROM stdin;
816f4c6c-65e4-47c7-b10e-72ae706b7667	2024-09-25 09:17:00+00	2024-09-26 02:20:44+00	\N	9dd96f96-ec79-45f4-a170-9ba78112c2c2	{http,https}	\N	\N	{/}	\N	\N	\N	0	t	f	\N	426	\N	v1	3f719519-4acb-432a-aea7-be4c49bc132e	t	t	\N	\N
6ca8d12d-bdb1-4eef-b82f-962fb64e694d	2024-09-26 06:10:44+00	2024-09-26 06:15:07+00	\N	6a2650c1-cfc1-43ff-967e-0bb5bf312c1e	{http,https}	\N	\N	{/acq-service}	\N	\N	\N	0	t	f	\N	426	\N	v1	3f719519-4acb-432a-aea7-be4c49bc132e	t	t	\N	\N
4566d314-2ce2-4453-bbdd-4a974f969af6	2024-09-26 06:16:32+00	2024-09-26 06:16:32+00	\N	e1bc9b67-ba37-4bba-9c37-ff2b33cf5090	{http,https}	\N	\N	{/dynamic-services}	\N	\N	\N	0	t	f	\N	426	\N	v1	3f719519-4acb-432a-aea7-be4c49bc132e	t	t	\N	\N
093441d4-104e-410d-952f-69a2ad1699ea	2024-09-27 07:50:40+00	2024-09-27 07:50:40+00	\N	5187f2dc-407a-4fe6-ba4a-0fc63e71c782	{http,https}	\N	\N	{/acq-applicant-service}	\N	\N	\N	0	t	f	\N	426	\N	v1	3f719519-4acb-432a-aea7-be4c49bc132e	t	t	\N	\N
ce5f5055-6ab4-4e0a-bc7e-e5df0ed6132c	2024-10-11 07:21:58+00	2024-10-11 09:55:26+00	\N	cc7870df-430d-4bce-b800-e116d0537362	{http,https}	\N	\N	{/login-service}	\N	\N	\N	0	t	f	\N	426	\N	v1	3f719519-4acb-432a-aea7-be4c49bc132e	t	t	\N	\N
\.


--
-- Data for Name: schema_meta; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.schema_meta (key, subsystem, last_executed, executed, pending) FROM stdin;
schema_meta	core	023_360_to_370	{000_base,003_100_to_110,004_110_to_120,005_120_to_130,006_130_to_140,007_140_to_150,008_150_to_200,009_200_to_210,010_210_to_211,011_212_to_213,012_213_to_220,013_220_to_230,014_230_to_270,015_270_to_280,016_280_to_300,017_300_to_310,018_310_to_320,019_320_to_330,020_330_to_340,021_340_to_350,022_350_to_360,023_360_to_370}	{}
schema_meta	basic-auth	003_200_to_210	{000_base_basic_auth,002_130_to_140,003_200_to_210}	{}
schema_meta	bot-detection	001_200_to_210	{001_200_to_210}	{}
schema_meta	acme	002_320_to_330	{000_base_acme,001_280_to_300,002_320_to_330}	{003_350_to_360}
schema_meta	hmac-auth	003_200_to_210	{000_base_hmac_auth,002_130_to_140,003_200_to_210}	{}
schema_meta	http-log	001_280_to_300	{001_280_to_300}	{}
schema_meta	ip-restriction	001_200_to_210	{001_200_to_210}	{}
schema_meta	ai-proxy	\N	\N	{001_360_to_370}
schema_meta	key-auth	004_320_to_330	{000_base_key_auth,002_130_to_140,003_200_to_210,004_320_to_330}	{}
schema_meta	jwt	003_200_to_210	{000_base_jwt,002_130_to_140,003_200_to_210}	{}
schema_meta	oauth2	007_320_to_330	{000_base_oauth2,003_130_to_140,004_200_to_210,005_210_to_211,006_320_to_330,007_320_to_330}	{}
schema_meta	opentelemetry	\N	\N	{001_331_to_332}
schema_meta	rate-limiting	005_320_to_330	{000_base_rate_limiting,003_10_to_112,004_200_to_210,005_320_to_330}	{006_350_to_360}
schema_meta	response-ratelimiting	000_base_response_rate_limiting	{000_base_response_rate_limiting}	{001_350_to_360}
schema_meta	acl	004_212_to_213	{000_base_acl,002_130_to_140,003_200_to_210,004_212_to_213}	{}
schema_meta	session	002_320_to_330	{000_base_session,001_add_ttl_index,002_320_to_330}	\N
schema_meta	post-function	001_280_to_300	{001_280_to_300}	{}
schema_meta	pre-function	001_280_to_300	{001_280_to_300}	{}
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.services (id, created_at, updated_at, name, retries, protocol, host, port, path, connect_timeout, write_timeout, read_timeout, tags, client_certificate_id, tls_verify, tls_verify_depth, ca_certificates, ws_id, enabled) FROM stdin;
6a2650c1-cfc1-43ff-967e-0bb5bf312c1e	2024-09-26 06:10:05+00	2024-09-26 06:10:05+00	acq-service	5	http	acq-services.development.svc.cluster.local	5086	/	60000	60000	60000	{}	\N	\N	\N	\N	3f719519-4acb-432a-aea7-be4c49bc132e	t
e1bc9b67-ba37-4bba-9c37-ff2b33cf5090	2024-09-26 06:16:15+00	2024-09-26 06:16:15+00	dynamic-services	5	http	dynamic-services.development.svc.cluster.local	5085	/	60000	60000	60000	{}	\N	\N	\N	\N	3f719519-4acb-432a-aea7-be4c49bc132e	t
5187f2dc-407a-4fe6-ba4a-0fc63e71c782	2024-09-27 07:50:18+00	2024-09-27 07:50:18+00	acq-applicant-service	5	http	acq-applicant-services.development.svc.cluster.local	5090	\N	60000	60000	60000	{}	\N	\N	\N	\N	3f719519-4acb-432a-aea7-be4c49bc132e	t
cc7870df-430d-4bce-b800-e116d0537362	2024-10-11 07:20:56+00	2024-10-11 07:20:56+00	login-services	5	http	login-services.piloting.svc.cluster.local	1000	/	60000	60000	60000	{}	\N	\N	\N	\N	3f719519-4acb-432a-aea7-be4c49bc132e	t
9dd96f96-ec79-45f4-a170-9ba78112c2c2	2024-09-25 09:08:36+00	2024-10-11 09:59:15+00	moofi	5	http	mobile2.macf.co.id	80	/	60000	60000	60000	{}	\N	\N	\N	\N	3f719519-4acb-432a-aea7-be4c49bc132e	t
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.sessions (id, session_id, expires, data, created_at, ttl) FROM stdin;
\.


--
-- Data for Name: sm_vaults; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.sm_vaults (id, ws_id, prefix, name, description, config, created_at, updated_at, tags) FROM stdin;
\.


--
-- Data for Name: snis; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.snis (id, created_at, name, certificate_id, tags, ws_id, updated_at) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.tags (entity_id, entity_name, tags) FROM stdin;
816f4c6c-65e4-47c7-b10e-72ae706b7667	routes	\N
6a2650c1-cfc1-43ff-967e-0bb5bf312c1e	services	{}
6ca8d12d-bdb1-4eef-b82f-962fb64e694d	routes	\N
e1bc9b67-ba37-4bba-9c37-ff2b33cf5090	services	{}
4566d314-2ce2-4453-bbdd-4a974f969af6	routes	\N
ec128b67-a716-4e2a-9ade-2b084482f53d	plugins	\N
5187f2dc-407a-4fe6-ba4a-0fc63e71c782	services	{}
093441d4-104e-410d-952f-69a2ad1699ea	routes	\N
cc7870df-430d-4bce-b800-e116d0537362	services	{}
ce5f5055-6ab4-4e0a-bc7e-e5df0ed6132c	routes	\N
9dd96f96-ec79-45f4-a170-9ba78112c2c2	services	{}
d088e1aa-481e-440c-b6b5-96971ee501ea	plugins	\N
\.


--
-- Data for Name: targets; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.targets (id, created_at, upstream_id, target, weight, tags, ws_id, cache_key, updated_at) FROM stdin;
\.


--
-- Data for Name: upstreams; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.upstreams (id, created_at, name, hash_on, hash_fallback, hash_on_header, hash_fallback_header, hash_on_cookie, hash_on_cookie_path, slots, healthchecks, tags, algorithm, host_header, client_certificate_id, ws_id, hash_on_query_arg, hash_fallback_query_arg, hash_on_uri_capture, hash_fallback_uri_capture, use_srv_name, updated_at) FROM stdin;
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: macf
--

COPY public.workspaces (id, name, comment, created_at, meta, config, updated_at) FROM stdin;
3f719519-4acb-432a-aea7-be4c49bc132e	default	\N	2024-09-25 08:56:13+00	\N	\N	2024-10-14 05:12:53+00
\.


--
-- Name: acls_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_cache_key_key UNIQUE (cache_key);


--
-- Name: acls_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: acls_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);


--
-- Name: acme_storage_key_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_key_key UNIQUE (key);


--
-- Name: acme_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acme_storage
    ADD CONSTRAINT acme_storage_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: basicauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: basicauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: ca_certificates_cert_digest_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_cert_digest_key UNIQUE (cert_digest);


--
-- Name: ca_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.ca_certificates
    ADD CONSTRAINT ca_certificates_pkey PRIMARY KEY (id);


--
-- Name: certificates_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: cluster_events_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.cluster_events
    ADD CONSTRAINT cluster_events_pkey PRIMARY KEY (id);


--
-- Name: clustering_data_planes_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.clustering_data_planes
    ADD CONSTRAINT clustering_data_planes_pkey PRIMARY KEY (id);


--
-- Name: clustering_rpc_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.clustering_rpc_requests
    ADD CONSTRAINT clustering_rpc_requests_pkey PRIMARY KEY (id);


--
-- Name: consumers_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: consumers_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_pkey PRIMARY KEY (id);


--
-- Name: consumers_ws_id_custom_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_custom_id_unique UNIQUE (ws_id, custom_id);


--
-- Name: consumers_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: filter_chains_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_cache_key_key UNIQUE (cache_key);


--
-- Name: filter_chains_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_name_key UNIQUE (name);


--
-- Name: filter_chains_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: hmacauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: hmacauth_credentials_ws_id_username_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_username_unique UNIQUE (ws_id, username);


--
-- Name: jwt_secrets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: jwt_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_pkey PRIMARY KEY (id);


--
-- Name: jwt_secrets_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: key_sets_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.key_sets
    ADD CONSTRAINT key_sets_name_key UNIQUE (name);


--
-- Name: key_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.key_sets
    ADD CONSTRAINT key_sets_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: keyauth_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_pkey PRIMARY KEY (id);


--
-- Name: keyauth_credentials_ws_id_key_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_key_unique UNIQUE (ws_id, key);


--
-- Name: keys_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_cache_key_key UNIQUE (cache_key);


--
-- Name: keys_kid_set_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_kid_set_id_key UNIQUE (kid, set_id);


--
-- Name: keys_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_name_key UNIQUE (name);


--
-- Name: keys_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_pkey PRIMARY KEY (id);


--
-- Name: konga_api_health_checks_api_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_api_health_checks
    ADD CONSTRAINT konga_api_health_checks_api_id_key UNIQUE (api_id);


--
-- Name: konga_api_health_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_api_health_checks
    ADD CONSTRAINT konga_api_health_checks_pkey PRIMARY KEY (id);


--
-- Name: konga_email_transports_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_email_transports
    ADD CONSTRAINT konga_email_transports_name_key UNIQUE (name);


--
-- Name: konga_email_transports_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_email_transports
    ADD CONSTRAINT konga_email_transports_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_nodes
    ADD CONSTRAINT konga_kong_nodes_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_services_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_services
    ADD CONSTRAINT konga_kong_services_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_services_service_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_services
    ADD CONSTRAINT konga_kong_services_service_id_key UNIQUE (service_id);


--
-- Name: konga_kong_snapshot_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_snapshot_schedules
    ADD CONSTRAINT konga_kong_snapshot_schedules_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_snapshots_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_snapshots
    ADD CONSTRAINT konga_kong_snapshots_name_key UNIQUE (name);


--
-- Name: konga_kong_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_snapshots
    ADD CONSTRAINT konga_kong_snapshots_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_upstream_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_upstream_alerts
    ADD CONSTRAINT konga_kong_upstream_alerts_pkey PRIMARY KEY (id);


--
-- Name: konga_kong_upstream_alerts_upstream_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_kong_upstream_alerts
    ADD CONSTRAINT konga_kong_upstream_alerts_upstream_id_key UNIQUE (upstream_id);


--
-- Name: konga_netdata_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_netdata_connections
    ADD CONSTRAINT konga_netdata_connections_pkey PRIMARY KEY (id);


--
-- Name: konga_passports_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_passports
    ADD CONSTRAINT konga_passports_pkey PRIMARY KEY (id);


--
-- Name: konga_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_settings
    ADD CONSTRAINT konga_settings_pkey PRIMARY KEY (id);


--
-- Name: konga_users_email_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_users
    ADD CONSTRAINT konga_users_email_key UNIQUE (email);


--
-- Name: konga_users_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_users
    ADD CONSTRAINT konga_users_pkey PRIMARY KEY (id);


--
-- Name: konga_users_username_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.konga_users
    ADD CONSTRAINT konga_users_username_key UNIQUE (username);


--
-- Name: locks_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.locks
    ADD CONSTRAINT locks_pkey PRIMARY KEY (key);


--
-- Name: oauth2_authorization_codes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth2_authorization_codes_ws_id_code_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_code_unique UNIQUE (ws_id, code);


--
-- Name: oauth2_credentials_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_pkey PRIMARY KEY (id);


--
-- Name: oauth2_credentials_ws_id_client_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_client_id_unique UNIQUE (ws_id, client_id);


--
-- Name: oauth2_tokens_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: oauth2_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth2_tokens_ws_id_access_token_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_access_token_unique UNIQUE (ws_id, access_token);


--
-- Name: oauth2_tokens_ws_id_refresh_token_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_refresh_token_unique UNIQUE (ws_id, refresh_token);


--
-- Name: parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (key);


--
-- Name: plugins_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_cache_key_key UNIQUE (cache_key);


--
-- Name: plugins_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: plugins_ws_id_instance_name_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_ws_id_instance_name_unique UNIQUE (ws_id, instance_name);


--
-- Name: ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.ratelimiting_metrics
    ADD CONSTRAINT ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: response_ratelimiting_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.response_ratelimiting_metrics
    ADD CONSTRAINT response_ratelimiting_metrics_pkey PRIMARY KEY (identifier, period, period_date, service_id, route_id);


--
-- Name: routes_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: routes_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: routes_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: schema_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.schema_meta
    ADD CONSTRAINT schema_meta_pkey PRIMARY KEY (key, subsystem);


--
-- Name: services_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: services_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: services_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_id_key UNIQUE (session_id);


--
-- Name: sm_vaults_id_ws_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_id_ws_id_key UNIQUE (id, ws_id);


--
-- Name: sm_vaults_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_pkey PRIMARY KEY (id);


--
-- Name: sm_vaults_prefix_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_prefix_key UNIQUE (prefix);


--
-- Name: sm_vaults_prefix_ws_id_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_prefix_ws_id_key UNIQUE (prefix, ws_id);


--
-- Name: snis_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: snis_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_name_key UNIQUE (name);


--
-- Name: snis_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (entity_id);


--
-- Name: targets_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_cache_key_key UNIQUE (cache_key);


--
-- Name: targets_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: targets_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: upstreams_id_ws_id_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_id_ws_id_unique UNIQUE (id, ws_id);


--
-- Name: upstreams_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_pkey PRIMARY KEY (id);


--
-- Name: upstreams_ws_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_name_unique UNIQUE (ws_id, name);


--
-- Name: workspaces_name_key; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_name_key UNIQUE (name);


--
-- Name: workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: acls_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX acls_consumer_id_idx ON public.acls USING btree (consumer_id);


--
-- Name: acls_group_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX acls_group_idx ON public.acls USING btree ("group");


--
-- Name: acls_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX acls_tags_idex_tags_idx ON public.acls USING gin (tags);


--
-- Name: acme_storage_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX acme_storage_ttl_idx ON public.acme_storage USING btree (ttl);


--
-- Name: basicauth_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX basicauth_consumer_id_idx ON public.basicauth_credentials USING btree (consumer_id);


--
-- Name: basicauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX basicauth_tags_idex_tags_idx ON public.basicauth_credentials USING gin (tags);


--
-- Name: certificates_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX certificates_tags_idx ON public.certificates USING gin (tags);


--
-- Name: cluster_events_at_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX cluster_events_at_idx ON public.cluster_events USING btree (at);


--
-- Name: cluster_events_channel_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX cluster_events_channel_idx ON public.cluster_events USING btree (channel);


--
-- Name: cluster_events_expire_at_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX cluster_events_expire_at_idx ON public.cluster_events USING btree (expire_at);


--
-- Name: clustering_data_planes_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX clustering_data_planes_ttl_idx ON public.clustering_data_planes USING btree (ttl);


--
-- Name: clustering_rpc_requests_node_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX clustering_rpc_requests_node_id_idx ON public.clustering_rpc_requests USING btree (node_id);


--
-- Name: consumers_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX consumers_tags_idx ON public.consumers USING gin (tags);


--
-- Name: consumers_username_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX consumers_username_idx ON public.consumers USING btree (lower(username));


--
-- Name: filter_chains_cache_key_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE UNIQUE INDEX filter_chains_cache_key_idx ON public.filter_chains USING btree (cache_key);


--
-- Name: filter_chains_name_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE UNIQUE INDEX filter_chains_name_idx ON public.filter_chains USING btree (name);


--
-- Name: filter_chains_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX filter_chains_tags_idx ON public.filter_chains USING gin (tags);


--
-- Name: hmacauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX hmacauth_credentials_consumer_id_idx ON public.hmacauth_credentials USING btree (consumer_id);


--
-- Name: hmacauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX hmacauth_tags_idex_tags_idx ON public.hmacauth_credentials USING gin (tags);


--
-- Name: jwt_secrets_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX jwt_secrets_consumer_id_idx ON public.jwt_secrets USING btree (consumer_id);


--
-- Name: jwt_secrets_secret_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX jwt_secrets_secret_idx ON public.jwt_secrets USING btree (secret);


--
-- Name: jwtsecrets_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX jwtsecrets_tags_idex_tags_idx ON public.jwt_secrets USING gin (tags);


--
-- Name: key_sets_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX key_sets_tags_idx ON public.key_sets USING gin (tags);


--
-- Name: keyauth_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX keyauth_credentials_consumer_id_idx ON public.keyauth_credentials USING btree (consumer_id);


--
-- Name: keyauth_credentials_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX keyauth_credentials_ttl_idx ON public.keyauth_credentials USING btree (ttl);


--
-- Name: keyauth_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX keyauth_tags_idex_tags_idx ON public.keyauth_credentials USING gin (tags);


--
-- Name: keys_fkey_key_sets; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX keys_fkey_key_sets ON public.keys USING btree (set_id);


--
-- Name: keys_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX keys_tags_idx ON public.keys USING gin (tags);


--
-- Name: locks_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX locks_ttl_idx ON public.locks USING btree (ttl);


--
-- Name: oauth2_authorization_codes_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_authorization_codes_authenticated_userid_idx ON public.oauth2_authorization_codes USING btree (authenticated_userid);


--
-- Name: oauth2_authorization_codes_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_authorization_codes_ttl_idx ON public.oauth2_authorization_codes USING btree (ttl);


--
-- Name: oauth2_authorization_credential_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_authorization_credential_id_idx ON public.oauth2_authorization_codes USING btree (credential_id);


--
-- Name: oauth2_authorization_service_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_authorization_service_id_idx ON public.oauth2_authorization_codes USING btree (service_id);


--
-- Name: oauth2_credentials_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_credentials_consumer_id_idx ON public.oauth2_credentials USING btree (consumer_id);


--
-- Name: oauth2_credentials_secret_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_credentials_secret_idx ON public.oauth2_credentials USING btree (client_secret);


--
-- Name: oauth2_credentials_tags_idex_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_credentials_tags_idex_tags_idx ON public.oauth2_credentials USING gin (tags);


--
-- Name: oauth2_tokens_authenticated_userid_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_tokens_authenticated_userid_idx ON public.oauth2_tokens USING btree (authenticated_userid);


--
-- Name: oauth2_tokens_credential_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_tokens_credential_id_idx ON public.oauth2_tokens USING btree (credential_id);


--
-- Name: oauth2_tokens_service_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_tokens_service_id_idx ON public.oauth2_tokens USING btree (service_id);


--
-- Name: oauth2_tokens_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX oauth2_tokens_ttl_idx ON public.oauth2_tokens USING btree (ttl);


--
-- Name: plugins_consumer_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX plugins_consumer_id_idx ON public.plugins USING btree (consumer_id);


--
-- Name: plugins_name_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX plugins_name_idx ON public.plugins USING btree (name);


--
-- Name: plugins_route_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX plugins_route_id_idx ON public.plugins USING btree (route_id);


--
-- Name: plugins_service_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX plugins_service_id_idx ON public.plugins USING btree (service_id);


--
-- Name: plugins_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX plugins_tags_idx ON public.plugins USING gin (tags);


--
-- Name: ratelimiting_metrics_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX ratelimiting_metrics_idx ON public.ratelimiting_metrics USING btree (service_id, route_id, period_date, period);


--
-- Name: ratelimiting_metrics_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX ratelimiting_metrics_ttl_idx ON public.ratelimiting_metrics USING btree (ttl);


--
-- Name: routes_service_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX routes_service_id_idx ON public.routes USING btree (service_id);


--
-- Name: routes_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX routes_tags_idx ON public.routes USING gin (tags);


--
-- Name: services_fkey_client_certificate; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX services_fkey_client_certificate ON public.services USING btree (client_certificate_id);


--
-- Name: services_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX services_tags_idx ON public.services USING gin (tags);


--
-- Name: session_sessions_expires_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX session_sessions_expires_idx ON public.sessions USING btree (expires);


--
-- Name: sessions_ttl_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX sessions_ttl_idx ON public.sessions USING btree (ttl);


--
-- Name: sm_vaults_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX sm_vaults_tags_idx ON public.sm_vaults USING gin (tags);


--
-- Name: snis_certificate_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX snis_certificate_id_idx ON public.snis USING btree (certificate_id);


--
-- Name: snis_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX snis_tags_idx ON public.snis USING gin (tags);


--
-- Name: tags_entity_name_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX tags_entity_name_idx ON public.tags USING btree (entity_name);


--
-- Name: tags_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX tags_tags_idx ON public.tags USING gin (tags);


--
-- Name: targets_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX targets_tags_idx ON public.targets USING gin (tags);


--
-- Name: targets_target_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX targets_target_idx ON public.targets USING btree (target);


--
-- Name: targets_upstream_id_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX targets_upstream_id_idx ON public.targets USING btree (upstream_id);


--
-- Name: upstreams_fkey_client_certificate; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX upstreams_fkey_client_certificate ON public.upstreams USING btree (client_certificate_id);


--
-- Name: upstreams_tags_idx; Type: INDEX; Schema: public; Owner: macf
--

CREATE INDEX upstreams_tags_idx ON public.upstreams USING gin (tags);


--
-- Name: acls_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER acls_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.acls FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: acme_storage_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER acme_storage_ttl_trigger AFTER INSERT ON public.acme_storage FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: basicauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER basicauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.basicauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: ca_certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER ca_certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.ca_certificates FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: certificates_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER certificates_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.certificates FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: cluster_events_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER cluster_events_ttl_trigger AFTER INSERT ON public.cluster_events FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('expire_at');


--
-- Name: clustering_data_planes_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER clustering_data_planes_ttl_trigger AFTER INSERT ON public.clustering_data_planes FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: consumers_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER consumers_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.consumers FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: filter_chains_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER filter_chains_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.filter_chains FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: hmacauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER hmacauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.hmacauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: jwtsecrets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER jwtsecrets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.jwt_secrets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: key_sets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER key_sets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.key_sets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: keyauth_credentials_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER keyauth_credentials_ttl_trigger AFTER INSERT ON public.keyauth_credentials FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: keyauth_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER keyauth_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.keyauth_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: keys_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER keys_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.keys FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: oauth2_authorization_codes_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER oauth2_authorization_codes_ttl_trigger AFTER INSERT ON public.oauth2_authorization_codes FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: oauth2_credentials_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER oauth2_credentials_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.oauth2_credentials FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: oauth2_tokens_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER oauth2_tokens_ttl_trigger AFTER INSERT ON public.oauth2_tokens FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: plugins_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER plugins_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.plugins FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: ratelimiting_metrics_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER ratelimiting_metrics_ttl_trigger AFTER INSERT ON public.ratelimiting_metrics FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: routes_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER routes_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.routes FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: services_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER services_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.services FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: sessions_ttl_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER sessions_ttl_trigger AFTER INSERT ON public.sessions FOR EACH STATEMENT EXECUTE PROCEDURE public.batch_delete_expired_rows('ttl');


--
-- Name: sm_vaults_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER sm_vaults_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.sm_vaults FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: snis_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER snis_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.snis FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: targets_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER targets_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.targets FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: upstreams_sync_tags_trigger; Type: TRIGGER; Schema: public; Owner: macf
--

CREATE TRIGGER upstreams_sync_tags_trigger AFTER INSERT OR DELETE OR UPDATE OF tags ON public.upstreams FOR EACH ROW EXECUTE PROCEDURE public.sync_tags();


--
-- Name: acls_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: acls_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.acls
    ADD CONSTRAINT acls_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: basicauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: basicauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.basicauth_credentials
    ADD CONSTRAINT basicauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: certificates_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: consumers_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.consumers
    ADD CONSTRAINT consumers_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: filter_chains_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- Name: filter_chains_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: filter_chains_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.filter_chains
    ADD CONSTRAINT filter_chains_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: hmacauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.hmacauth_credentials
    ADD CONSTRAINT hmacauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: jwt_secrets_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: jwt_secrets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.jwt_secrets
    ADD CONSTRAINT jwt_secrets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: key_sets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.key_sets
    ADD CONSTRAINT key_sets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: keyauth_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: keyauth_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keyauth_credentials
    ADD CONSTRAINT keyauth_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: keys_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.key_sets(id) ON DELETE CASCADE;


--
-- Name: keys_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.keys
    ADD CONSTRAINT keys_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_authorization_codes_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes_plugin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_plugin_id_fkey FOREIGN KEY (plugin_id) REFERENCES public.plugins(id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_authorization_codes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_authorization_codes
    ADD CONSTRAINT oauth2_authorization_codes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_credentials_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_credentials_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_credentials
    ADD CONSTRAINT oauth2_credentials_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: oauth2_tokens_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_credential_id_fkey FOREIGN KEY (credential_id, ws_id) REFERENCES public.oauth2_credentials(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: oauth2_tokens_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.oauth2_tokens
    ADD CONSTRAINT oauth2_tokens_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: plugins_consumer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_consumer_id_fkey FOREIGN KEY (consumer_id, ws_id) REFERENCES public.consumers(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_route_id_fkey FOREIGN KEY (route_id, ws_id) REFERENCES public.routes(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id) ON DELETE CASCADE;


--
-- Name: plugins_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: routes_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_service_id_fkey FOREIGN KEY (service_id, ws_id) REFERENCES public.services(id, ws_id);


--
-- Name: routes_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: services_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_client_certificate_id_fkey FOREIGN KEY (client_certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: services_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: sm_vaults_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.sm_vaults
    ADD CONSTRAINT sm_vaults_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: snis_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_certificate_id_fkey FOREIGN KEY (certificate_id, ws_id) REFERENCES public.certificates(id, ws_id);


--
-- Name: snis_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.snis
    ADD CONSTRAINT snis_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: targets_upstream_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_upstream_id_fkey FOREIGN KEY (upstream_id, ws_id) REFERENCES public.upstreams(id, ws_id) ON DELETE CASCADE;


--
-- Name: targets_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: upstreams_client_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_client_certificate_id_fkey FOREIGN KEY (client_certificate_id) REFERENCES public.certificates(id);


--
-- Name: upstreams_ws_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: macf
--

ALTER TABLE ONLY public.upstreams
    ADD CONSTRAINT upstreams_ws_id_fkey FOREIGN KEY (ws_id) REFERENCES public.workspaces(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: macf
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM macf;
GRANT ALL ON SCHEMA public TO macf;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

