--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: keycloak; Type: DATABASE; Schema: -; Owner: dev
--

CREATE DATABASE keycloak WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE keycloak OWNER TO dev;

\connect keycloak

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_event_entity; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.admin_event_entity (
    id character varying(36) NOT NULL,
    admin_event_time bigint,
    realm_id character varying(255),
    operation_type character varying(255),
    auth_realm_id character varying(255),
    auth_client_id character varying(255),
    auth_user_id character varying(255),
    ip_address character varying(255),
    resource_path character varying(2550),
    representation text,
    error character varying(255),
    resource_type character varying(64)
);


ALTER TABLE public.admin_event_entity OWNER TO dev;

--
-- Name: associated_policy; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.associated_policy (
    policy_id character varying(36) NOT NULL,
    associated_policy_id character varying(36) NOT NULL
);


ALTER TABLE public.associated_policy OWNER TO dev;

--
-- Name: authentication_execution; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.authentication_execution (
    id character varying(36) NOT NULL,
    alias character varying(255),
    authenticator character varying(36),
    realm_id character varying(36),
    flow_id character varying(36),
    requirement integer,
    priority integer,
    authenticator_flow boolean DEFAULT false NOT NULL,
    auth_flow_id character varying(36),
    auth_config character varying(36)
);


ALTER TABLE public.authentication_execution OWNER TO dev;

--
-- Name: authentication_flow; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.authentication_flow (
    id character varying(36) NOT NULL,
    alias character varying(255),
    description character varying(255),
    realm_id character varying(36),
    provider_id character varying(36) DEFAULT 'basic-flow'::character varying NOT NULL,
    top_level boolean DEFAULT false NOT NULL,
    built_in boolean DEFAULT false NOT NULL
);


ALTER TABLE public.authentication_flow OWNER TO dev;

--
-- Name: authenticator_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.authenticator_config (
    id character varying(36) NOT NULL,
    alias character varying(255),
    realm_id character varying(36)
);


ALTER TABLE public.authenticator_config OWNER TO dev;

--
-- Name: authenticator_config_entry; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.authenticator_config_entry (
    authenticator_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.authenticator_config_entry OWNER TO dev;

--
-- Name: broker_link; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.broker_link (
    identity_provider character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL,
    broker_user_id character varying(255),
    broker_username character varying(255),
    token text,
    user_id character varying(255) NOT NULL
);


ALTER TABLE public.broker_link OWNER TO dev;

--
-- Name: client; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client (
    id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    full_scope_allowed boolean DEFAULT false NOT NULL,
    client_id character varying(255),
    not_before integer,
    public_client boolean DEFAULT false NOT NULL,
    secret character varying(255),
    base_url character varying(255),
    bearer_only boolean DEFAULT false NOT NULL,
    management_url character varying(255),
    surrogate_auth_required boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    protocol character varying(255),
    node_rereg_timeout integer DEFAULT 0,
    frontchannel_logout boolean DEFAULT false NOT NULL,
    consent_required boolean DEFAULT false NOT NULL,
    name character varying(255),
    service_accounts_enabled boolean DEFAULT false NOT NULL,
    client_authenticator_type character varying(255),
    root_url character varying(255),
    description character varying(255),
    registration_token character varying(255),
    standard_flow_enabled boolean DEFAULT true NOT NULL,
    implicit_flow_enabled boolean DEFAULT false NOT NULL,
    direct_access_grants_enabled boolean DEFAULT false NOT NULL,
    always_display_in_console boolean DEFAULT false NOT NULL
);


ALTER TABLE public.client OWNER TO dev;

--
-- Name: client_attributes; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_attributes (
    client_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.client_attributes OWNER TO dev;

--
-- Name: client_auth_flow_bindings; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_auth_flow_bindings (
    client_id character varying(36) NOT NULL,
    flow_id character varying(36),
    binding_name character varying(255) NOT NULL
);


ALTER TABLE public.client_auth_flow_bindings OWNER TO dev;

--
-- Name: client_initial_access; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_initial_access (
    id character varying(36) NOT NULL,
    realm_id character varying(36) NOT NULL,
    "timestamp" integer,
    expiration integer,
    count integer,
    remaining_count integer
);


ALTER TABLE public.client_initial_access OWNER TO dev;

--
-- Name: client_node_registrations; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_node_registrations (
    client_id character varying(36) NOT NULL,
    value integer,
    name character varying(255) NOT NULL
);


ALTER TABLE public.client_node_registrations OWNER TO dev;

--
-- Name: client_scope; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_scope (
    id character varying(36) NOT NULL,
    name character varying(255),
    realm_id character varying(36),
    description character varying(255),
    protocol character varying(255)
);


ALTER TABLE public.client_scope OWNER TO dev;

--
-- Name: client_scope_attributes; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_scope_attributes (
    scope_id character varying(36) NOT NULL,
    value character varying(2048),
    name character varying(255) NOT NULL
);


ALTER TABLE public.client_scope_attributes OWNER TO dev;

--
-- Name: client_scope_client; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_scope_client (
    client_id character varying(255) NOT NULL,
    scope_id character varying(255) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


ALTER TABLE public.client_scope_client OWNER TO dev;

--
-- Name: client_scope_role_mapping; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_scope_role_mapping (
    scope_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


ALTER TABLE public.client_scope_role_mapping OWNER TO dev;

--
-- Name: client_session; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_session (
    id character varying(36) NOT NULL,
    client_id character varying(36),
    redirect_uri character varying(255),
    state character varying(255),
    "timestamp" integer,
    session_id character varying(36),
    auth_method character varying(255),
    realm_id character varying(255),
    auth_user_id character varying(36),
    current_action character varying(36)
);


ALTER TABLE public.client_session OWNER TO dev;

--
-- Name: client_session_auth_status; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_session_auth_status (
    authenticator character varying(36) NOT NULL,
    status integer,
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_auth_status OWNER TO dev;

--
-- Name: client_session_note; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_session_note (
    name character varying(255) NOT NULL,
    value character varying(255),
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_note OWNER TO dev;

--
-- Name: client_session_prot_mapper; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_session_prot_mapper (
    protocol_mapper_id character varying(36) NOT NULL,
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_prot_mapper OWNER TO dev;

--
-- Name: client_session_role; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_session_role (
    role_id character varying(255) NOT NULL,
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_role OWNER TO dev;

--
-- Name: client_user_session_note; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.client_user_session_note (
    name character varying(255) NOT NULL,
    value character varying(2048),
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_user_session_note OWNER TO dev;

--
-- Name: component; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.component (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_id character varying(36),
    provider_id character varying(36),
    provider_type character varying(255),
    realm_id character varying(36),
    sub_type character varying(255)
);


ALTER TABLE public.component OWNER TO dev;

--
-- Name: component_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.component_config (
    id character varying(36) NOT NULL,
    component_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.component_config OWNER TO dev;

--
-- Name: composite_role; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.composite_role (
    composite character varying(36) NOT NULL,
    child_role character varying(36) NOT NULL
);


ALTER TABLE public.composite_role OWNER TO dev;

--
-- Name: credential; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    user_id character varying(36),
    created_date bigint,
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer
);


ALTER TABLE public.credential OWNER TO dev;

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO dev;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO dev;

--
-- Name: default_client_scope; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.default_client_scope (
    realm_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


ALTER TABLE public.default_client_scope OWNER TO dev;

--
-- Name: event_entity; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.event_entity (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    details_json character varying(2550),
    error character varying(255),
    ip_address character varying(255),
    realm_id character varying(255),
    session_id character varying(255),
    event_time bigint,
    type character varying(255),
    user_id character varying(255),
    details_json_long_value text
);


ALTER TABLE public.event_entity OWNER TO dev;

--
-- Name: fed_user_attribute; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_attribute (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    value character varying(2024)
);


ALTER TABLE public.fed_user_attribute OWNER TO dev;

--
-- Name: fed_user_consent; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


ALTER TABLE public.fed_user_consent OWNER TO dev;

--
-- Name: fed_user_consent_cl_scope; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_consent_cl_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.fed_user_consent_cl_scope OWNER TO dev;

--
-- Name: fed_user_credential; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    created_date bigint,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer
);


ALTER TABLE public.fed_user_credential OWNER TO dev;

--
-- Name: fed_user_group_membership; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_group_membership OWNER TO dev;

--
-- Name: fed_user_required_action; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_required_action (
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_required_action OWNER TO dev;

--
-- Name: fed_user_role_mapping; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.fed_user_role_mapping (
    role_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_role_mapping OWNER TO dev;

--
-- Name: federated_identity; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.federated_identity (
    identity_provider character varying(255) NOT NULL,
    realm_id character varying(36),
    federated_user_id character varying(255),
    federated_username character varying(255),
    token text,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.federated_identity OWNER TO dev;

--
-- Name: federated_user; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.federated_user (
    id character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.federated_user OWNER TO dev;

--
-- Name: group_attribute; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.group_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.group_attribute OWNER TO dev;

--
-- Name: group_role_mapping; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.group_role_mapping (
    role_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.group_role_mapping OWNER TO dev;

--
-- Name: identity_provider; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.identity_provider (
    internal_id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    provider_alias character varying(255),
    provider_id character varying(255),
    store_token boolean DEFAULT false NOT NULL,
    authenticate_by_default boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    add_token_role boolean DEFAULT true NOT NULL,
    trust_email boolean DEFAULT false NOT NULL,
    first_broker_login_flow_id character varying(36),
    post_broker_login_flow_id character varying(36),
    provider_display_name character varying(255),
    link_only boolean DEFAULT false NOT NULL
);


ALTER TABLE public.identity_provider OWNER TO dev;

--
-- Name: identity_provider_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.identity_provider_config (
    identity_provider_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.identity_provider_config OWNER TO dev;

--
-- Name: identity_provider_mapper; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.identity_provider_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    idp_alias character varying(255) NOT NULL,
    idp_mapper_name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.identity_provider_mapper OWNER TO dev;

--
-- Name: idp_mapper_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.idp_mapper_config (
    idp_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.idp_mapper_config OWNER TO dev;

--
-- Name: keycloak_group; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.keycloak_group (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_group character varying(36) NOT NULL,
    realm_id character varying(36)
);


ALTER TABLE public.keycloak_group OWNER TO dev;

--
-- Name: keycloak_role; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.keycloak_role (
    id character varying(36) NOT NULL,
    client_realm_constraint character varying(255),
    client_role boolean DEFAULT false NOT NULL,
    description character varying(255),
    name character varying(255),
    realm_id character varying(255),
    client character varying(36),
    realm character varying(36)
);


ALTER TABLE public.keycloak_role OWNER TO dev;

--
-- Name: migration_model; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.migration_model (
    id character varying(36) NOT NULL,
    version character varying(36),
    update_time bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.migration_model OWNER TO dev;

--
-- Name: offline_client_session; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.offline_client_session (
    user_session_id character varying(36) NOT NULL,
    client_id character varying(255) NOT NULL,
    offline_flag character varying(4) NOT NULL,
    "timestamp" integer,
    data text,
    client_storage_provider character varying(36) DEFAULT 'local'::character varying NOT NULL,
    external_client_id character varying(255) DEFAULT 'local'::character varying NOT NULL
);


ALTER TABLE public.offline_client_session OWNER TO dev;

--
-- Name: offline_user_session; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.offline_user_session (
    user_session_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    created_on integer NOT NULL,
    offline_flag character varying(4) NOT NULL,
    data text,
    last_session_refresh integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.offline_user_session OWNER TO dev;

--
-- Name: policy_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.policy_config (
    policy_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.policy_config OWNER TO dev;

--
-- Name: protocol_mapper; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.protocol_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    protocol character varying(255) NOT NULL,
    protocol_mapper_name character varying(255) NOT NULL,
    client_id character varying(36),
    client_scope_id character varying(36)
);


ALTER TABLE public.protocol_mapper OWNER TO dev;

--
-- Name: protocol_mapper_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.protocol_mapper_config (
    protocol_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.protocol_mapper_config OWNER TO dev;

--
-- Name: realm; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm (
    id character varying(36) NOT NULL,
    access_code_lifespan integer,
    user_action_lifespan integer,
    access_token_lifespan integer,
    account_theme character varying(255),
    admin_theme character varying(255),
    email_theme character varying(255),
    enabled boolean DEFAULT false NOT NULL,
    events_enabled boolean DEFAULT false NOT NULL,
    events_expiration bigint,
    login_theme character varying(255),
    name character varying(255),
    not_before integer,
    password_policy character varying(2550),
    registration_allowed boolean DEFAULT false NOT NULL,
    remember_me boolean DEFAULT false NOT NULL,
    reset_password_allowed boolean DEFAULT false NOT NULL,
    social boolean DEFAULT false NOT NULL,
    ssl_required character varying(255),
    sso_idle_timeout integer,
    sso_max_lifespan integer,
    update_profile_on_soc_login boolean DEFAULT false NOT NULL,
    verify_email boolean DEFAULT false NOT NULL,
    master_admin_client character varying(36),
    login_lifespan integer,
    internationalization_enabled boolean DEFAULT false NOT NULL,
    default_locale character varying(255),
    reg_email_as_username boolean DEFAULT false NOT NULL,
    admin_events_enabled boolean DEFAULT false NOT NULL,
    admin_events_details_enabled boolean DEFAULT false NOT NULL,
    edit_username_allowed boolean DEFAULT false NOT NULL,
    otp_policy_counter integer DEFAULT 0,
    otp_policy_window integer DEFAULT 1,
    otp_policy_period integer DEFAULT 30,
    otp_policy_digits integer DEFAULT 6,
    otp_policy_alg character varying(36) DEFAULT 'HmacSHA1'::character varying,
    otp_policy_type character varying(36) DEFAULT 'totp'::character varying,
    browser_flow character varying(36),
    registration_flow character varying(36),
    direct_grant_flow character varying(36),
    reset_credentials_flow character varying(36),
    client_auth_flow character varying(36),
    offline_session_idle_timeout integer DEFAULT 0,
    revoke_refresh_token boolean DEFAULT false NOT NULL,
    access_token_life_implicit integer DEFAULT 0,
    login_with_email_allowed boolean DEFAULT true NOT NULL,
    duplicate_emails_allowed boolean DEFAULT false NOT NULL,
    docker_auth_flow character varying(36),
    refresh_token_max_reuse integer DEFAULT 0,
    allow_user_managed_access boolean DEFAULT false NOT NULL,
    sso_max_lifespan_remember_me integer DEFAULT 0 NOT NULL,
    sso_idle_timeout_remember_me integer DEFAULT 0 NOT NULL,
    default_role character varying(255)
);


ALTER TABLE public.realm OWNER TO dev;

--
-- Name: realm_attribute; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_attribute (
    name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    value text
);


ALTER TABLE public.realm_attribute OWNER TO dev;

--
-- Name: realm_default_groups; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_default_groups (
    realm_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.realm_default_groups OWNER TO dev;

--
-- Name: realm_enabled_event_types; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_enabled_event_types (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_enabled_event_types OWNER TO dev;

--
-- Name: realm_events_listeners; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_events_listeners (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_events_listeners OWNER TO dev;

--
-- Name: realm_localizations; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_localizations (
    realm_id character varying(255) NOT NULL,
    locale character varying(255) NOT NULL,
    texts text NOT NULL
);


ALTER TABLE public.realm_localizations OWNER TO dev;

--
-- Name: realm_required_credential; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_required_credential (
    type character varying(255) NOT NULL,
    form_label character varying(255),
    input boolean DEFAULT false NOT NULL,
    secret boolean DEFAULT false NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.realm_required_credential OWNER TO dev;

--
-- Name: realm_smtp_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_smtp_config (
    realm_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.realm_smtp_config OWNER TO dev;

--
-- Name: realm_supported_locales; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.realm_supported_locales (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_supported_locales OWNER TO dev;

--
-- Name: redirect_uris; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.redirect_uris (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.redirect_uris OWNER TO dev;

--
-- Name: required_action_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.required_action_config (
    required_action_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.required_action_config OWNER TO dev;

--
-- Name: required_action_provider; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.required_action_provider (
    id character varying(36) NOT NULL,
    alias character varying(255),
    name character varying(255),
    realm_id character varying(36),
    enabled boolean DEFAULT false NOT NULL,
    default_action boolean DEFAULT false NOT NULL,
    provider_id character varying(255),
    priority integer
);


ALTER TABLE public.required_action_provider OWNER TO dev;

--
-- Name: resource_attribute; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    resource_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_attribute OWNER TO dev;

--
-- Name: resource_policy; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_policy (
    resource_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_policy OWNER TO dev;

--
-- Name: resource_scope; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_scope (
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_scope OWNER TO dev;

--
-- Name: resource_server; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_server (
    id character varying(36) NOT NULL,
    allow_rs_remote_mgmt boolean DEFAULT false NOT NULL,
    policy_enforce_mode smallint NOT NULL,
    decision_strategy smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.resource_server OWNER TO dev;

--
-- Name: resource_server_perm_ticket; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_server_perm_ticket (
    id character varying(36) NOT NULL,
    owner character varying(255) NOT NULL,
    requester character varying(255) NOT NULL,
    created_timestamp bigint NOT NULL,
    granted_timestamp bigint,
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36),
    resource_server_id character varying(36) NOT NULL,
    policy_id character varying(36)
);


ALTER TABLE public.resource_server_perm_ticket OWNER TO dev;

--
-- Name: resource_server_policy; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_server_policy (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    type character varying(255) NOT NULL,
    decision_strategy smallint,
    logic smallint,
    resource_server_id character varying(36) NOT NULL,
    owner character varying(255)
);


ALTER TABLE public.resource_server_policy OWNER TO dev;

--
-- Name: resource_server_resource; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_server_resource (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255),
    icon_uri character varying(255),
    owner character varying(255) NOT NULL,
    resource_server_id character varying(36) NOT NULL,
    owner_managed_access boolean DEFAULT false NOT NULL,
    display_name character varying(255)
);


ALTER TABLE public.resource_server_resource OWNER TO dev;

--
-- Name: resource_server_scope; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_server_scope (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon_uri character varying(255),
    resource_server_id character varying(36) NOT NULL,
    display_name character varying(255)
);


ALTER TABLE public.resource_server_scope OWNER TO dev;

--
-- Name: resource_uris; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.resource_uris (
    resource_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.resource_uris OWNER TO dev;

--
-- Name: role_attribute; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.role_attribute (
    id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255)
);


ALTER TABLE public.role_attribute OWNER TO dev;

--
-- Name: scope_mapping; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.scope_mapping (
    client_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


ALTER TABLE public.scope_mapping OWNER TO dev;

--
-- Name: scope_policy; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.scope_policy (
    scope_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


ALTER TABLE public.scope_policy OWNER TO dev;

--
-- Name: user_attribute; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_attribute (
    name character varying(255) NOT NULL,
    value character varying(255),
    user_id character varying(36) NOT NULL,
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL
);


ALTER TABLE public.user_attribute OWNER TO dev;

--
-- Name: user_consent; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(36) NOT NULL,
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


ALTER TABLE public.user_consent OWNER TO dev;

--
-- Name: user_consent_client_scope; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_consent_client_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.user_consent_client_scope OWNER TO dev;

--
-- Name: user_entity; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_entity (
    id character varying(36) NOT NULL,
    email character varying(255),
    email_constraint character varying(255),
    email_verified boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    federation_link character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    realm_id character varying(255),
    username character varying(255),
    created_timestamp bigint,
    service_account_client_link character varying(255),
    not_before integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_entity OWNER TO dev;

--
-- Name: user_federation_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_federation_config (
    user_federation_provider_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.user_federation_config OWNER TO dev;

--
-- Name: user_federation_mapper; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_federation_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    federation_provider_id character varying(36) NOT NULL,
    federation_mapper_type character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.user_federation_mapper OWNER TO dev;

--
-- Name: user_federation_mapper_config; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_federation_mapper_config (
    user_federation_mapper_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.user_federation_mapper_config OWNER TO dev;

--
-- Name: user_federation_provider; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_federation_provider (
    id character varying(36) NOT NULL,
    changed_sync_period integer,
    display_name character varying(255),
    full_sync_period integer,
    last_sync integer,
    priority integer,
    provider_name character varying(255),
    realm_id character varying(36)
);


ALTER TABLE public.user_federation_provider OWNER TO dev;

--
-- Name: user_group_membership; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.user_group_membership OWNER TO dev;

--
-- Name: user_required_action; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_required_action (
    user_id character varying(36) NOT NULL,
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL
);


ALTER TABLE public.user_required_action OWNER TO dev;

--
-- Name: user_role_mapping; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_role_mapping (
    role_id character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.user_role_mapping OWNER TO dev;

--
-- Name: user_session; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_session (
    id character varying(36) NOT NULL,
    auth_method character varying(255),
    ip_address character varying(255),
    last_session_refresh integer,
    login_username character varying(255),
    realm_id character varying(255),
    remember_me boolean DEFAULT false NOT NULL,
    started integer,
    user_id character varying(255),
    user_session_state integer,
    broker_session_id character varying(255),
    broker_user_id character varying(255)
);


ALTER TABLE public.user_session OWNER TO dev;

--
-- Name: user_session_note; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.user_session_note (
    user_session character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(2048)
);


ALTER TABLE public.user_session_note OWNER TO dev;

--
-- Name: username_login_failure; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.username_login_failure (
    realm_id character varying(36) NOT NULL,
    username character varying(255) NOT NULL,
    failed_login_not_before integer,
    last_failure bigint,
    last_ip_failure character varying(255),
    num_failures integer
);


ALTER TABLE public.username_login_failure OWNER TO dev;

--
-- Name: web_origins; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.web_origins (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.web_origins OWNER TO dev;

--
-- Data for Name: admin_event_entity; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.admin_event_entity (id, admin_event_time, realm_id, operation_type, auth_realm_id, auth_client_id, auth_user_id, ip_address, resource_path, representation, error, resource_type) FROM stdin;
\.


--
-- Data for Name: associated_policy; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.associated_policy (policy_id, associated_policy_id) FROM stdin;
\.


--
-- Data for Name: authentication_execution; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authentication_execution (id, alias, authenticator, realm_id, flow_id, requirement, priority, authenticator_flow, auth_flow_id, auth_config) FROM stdin;
7c7c79f8-5da0-4dbd-8b4f-37c91730b572	\N	auth-cookie	def58135-f6f9-494c-b177-21c2d610717d	0f63d3ca-1a92-43cf-8b6f-1ea93c9a47f0	2	10	f	\N	\N
bd4330e0-3e0c-460d-b1ed-d934a1cc42ba	\N	auth-spnego	def58135-f6f9-494c-b177-21c2d610717d	0f63d3ca-1a92-43cf-8b6f-1ea93c9a47f0	3	20	f	\N	\N
d74dd6b7-1dda-4469-a229-495cf0a85790	\N	identity-provider-redirector	def58135-f6f9-494c-b177-21c2d610717d	0f63d3ca-1a92-43cf-8b6f-1ea93c9a47f0	2	25	f	\N	\N
17435b27-412b-47c6-bab8-18214eab3f15	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	0f63d3ca-1a92-43cf-8b6f-1ea93c9a47f0	2	30	t	fdbbd1d7-49a6-4411-9e8e-d31a5923fe87	\N
9d9eb338-01f7-4cf1-a9dc-efcc60fd84ef	\N	auth-username-password-form	def58135-f6f9-494c-b177-21c2d610717d	fdbbd1d7-49a6-4411-9e8e-d31a5923fe87	0	10	f	\N	\N
9bd6fc05-87bf-4628-8160-8495bd630f50	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	fdbbd1d7-49a6-4411-9e8e-d31a5923fe87	1	20	t	c05a3ddf-0623-4715-b1fb-7afefebca3ed	\N
5f88c5a9-9c40-469f-b699-226c1355da7b	\N	conditional-user-configured	def58135-f6f9-494c-b177-21c2d610717d	c05a3ddf-0623-4715-b1fb-7afefebca3ed	0	10	f	\N	\N
96a4b476-9091-4eb6-a3b4-54abc53c233d	\N	auth-otp-form	def58135-f6f9-494c-b177-21c2d610717d	c05a3ddf-0623-4715-b1fb-7afefebca3ed	0	20	f	\N	\N
d31752ea-e3a6-472c-8529-9574ba707a49	\N	direct-grant-validate-username	def58135-f6f9-494c-b177-21c2d610717d	80521110-e051-4613-882a-3e1f30d23174	0	10	f	\N	\N
99a6d8dd-5494-4ad2-a155-882cd67101f4	\N	direct-grant-validate-password	def58135-f6f9-494c-b177-21c2d610717d	80521110-e051-4613-882a-3e1f30d23174	0	20	f	\N	\N
ffbe4cd7-384c-49c9-a86e-be6e877c3950	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	80521110-e051-4613-882a-3e1f30d23174	1	30	t	8dce14d1-38c4-4bb5-b395-f65952102262	\N
c2cd13cd-d00c-429f-891b-7d60e6430b96	\N	conditional-user-configured	def58135-f6f9-494c-b177-21c2d610717d	8dce14d1-38c4-4bb5-b395-f65952102262	0	10	f	\N	\N
2055c048-e9dd-4986-9d42-01b3950ddbea	\N	direct-grant-validate-otp	def58135-f6f9-494c-b177-21c2d610717d	8dce14d1-38c4-4bb5-b395-f65952102262	0	20	f	\N	\N
878dc966-0930-4213-a25e-a3d459cb53b7	\N	registration-page-form	def58135-f6f9-494c-b177-21c2d610717d	55688f4b-42df-4969-9957-15c6099759e6	0	10	t	10a759be-259b-477d-8f74-a9fd06eb9fcd	\N
7b56b4f3-2a65-4f6e-9b52-84f8fad511f6	\N	registration-user-creation	def58135-f6f9-494c-b177-21c2d610717d	10a759be-259b-477d-8f74-a9fd06eb9fcd	0	20	f	\N	\N
195f7f18-5c97-427f-9e26-7239bcd1bd6c	\N	registration-password-action	def58135-f6f9-494c-b177-21c2d610717d	10a759be-259b-477d-8f74-a9fd06eb9fcd	0	50	f	\N	\N
20301a11-c5f7-4869-8bd2-89a70af5084f	\N	registration-recaptcha-action	def58135-f6f9-494c-b177-21c2d610717d	10a759be-259b-477d-8f74-a9fd06eb9fcd	3	60	f	\N	\N
15d5e100-a389-4e6c-9e94-f695d57f3c92	\N	registration-terms-and-conditions	def58135-f6f9-494c-b177-21c2d610717d	10a759be-259b-477d-8f74-a9fd06eb9fcd	3	70	f	\N	\N
35f7ff06-97e2-444a-b9e5-2f2bf08626ba	\N	reset-credentials-choose-user	def58135-f6f9-494c-b177-21c2d610717d	7b06330b-14b8-4d35-bf40-3dc344f89b99	0	10	f	\N	\N
dedd4102-5fb0-4854-9d04-fd41feb01988	\N	reset-credential-email	def58135-f6f9-494c-b177-21c2d610717d	7b06330b-14b8-4d35-bf40-3dc344f89b99	0	20	f	\N	\N
5dc29a99-9ffc-45a3-a1c4-8db413c51dc4	\N	reset-password	def58135-f6f9-494c-b177-21c2d610717d	7b06330b-14b8-4d35-bf40-3dc344f89b99	0	30	f	\N	\N
8a503346-6dca-45c7-b625-83440b8e6d5d	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	7b06330b-14b8-4d35-bf40-3dc344f89b99	1	40	t	8e74f452-a243-44a3-8fea-e4ee2a16fe47	\N
526216dd-5b53-442d-9fa2-2e7adc6c3990	\N	conditional-user-configured	def58135-f6f9-494c-b177-21c2d610717d	8e74f452-a243-44a3-8fea-e4ee2a16fe47	0	10	f	\N	\N
ff386dfd-0c55-457f-83b5-b4cb3ad29034	\N	reset-otp	def58135-f6f9-494c-b177-21c2d610717d	8e74f452-a243-44a3-8fea-e4ee2a16fe47	0	20	f	\N	\N
204c59de-7dbe-415b-88d9-672a05687283	\N	client-secret	def58135-f6f9-494c-b177-21c2d610717d	11c7742e-dad9-45e2-bea9-8686ebaf815f	2	10	f	\N	\N
3bc3853f-6a1b-4b91-b4f1-4e9a37a44e36	\N	client-jwt	def58135-f6f9-494c-b177-21c2d610717d	11c7742e-dad9-45e2-bea9-8686ebaf815f	2	20	f	\N	\N
e4d65099-18bf-4111-97d7-44d390fc96f8	\N	client-secret-jwt	def58135-f6f9-494c-b177-21c2d610717d	11c7742e-dad9-45e2-bea9-8686ebaf815f	2	30	f	\N	\N
02e7079f-41a2-483e-be38-90a9780b68f4	\N	client-x509	def58135-f6f9-494c-b177-21c2d610717d	11c7742e-dad9-45e2-bea9-8686ebaf815f	2	40	f	\N	\N
23134d8c-c03f-49de-aa23-1e4a5072bceb	\N	idp-review-profile	def58135-f6f9-494c-b177-21c2d610717d	6a21de26-ef53-4747-bc85-631ffa1e9a89	0	10	f	\N	5927d697-c6f7-4945-8415-0cc34e0f03a3
28d93bc8-b3bb-4d02-935a-361cb3bac811	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	6a21de26-ef53-4747-bc85-631ffa1e9a89	0	20	t	b1e98ee9-bfd0-41af-9d10-c1f872fe317a	\N
020e2dd5-2bfd-4f10-bc67-19fb15157e8d	\N	idp-create-user-if-unique	def58135-f6f9-494c-b177-21c2d610717d	b1e98ee9-bfd0-41af-9d10-c1f872fe317a	2	10	f	\N	e0c4e293-d3c0-46f4-bb32-1d716ba98d86
198cc8c2-2eca-46b5-9acb-b0fa02e5e8ce	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	b1e98ee9-bfd0-41af-9d10-c1f872fe317a	2	20	t	3a612536-774d-4a25-b630-406f02ff8241	\N
aead64d9-5036-41da-bd95-607668efb75a	\N	idp-confirm-link	def58135-f6f9-494c-b177-21c2d610717d	3a612536-774d-4a25-b630-406f02ff8241	0	10	f	\N	\N
9e1da03b-25e4-4e71-92ac-b567d05cccec	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	3a612536-774d-4a25-b630-406f02ff8241	0	20	t	d805ae00-f125-492f-90ef-5d93ae02045d	\N
3aaa306c-5259-4a70-a1aa-d83c6b36d000	\N	idp-email-verification	def58135-f6f9-494c-b177-21c2d610717d	d805ae00-f125-492f-90ef-5d93ae02045d	2	10	f	\N	\N
ff4fc2f5-ac3c-423c-8543-5e7f7d9d553a	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	d805ae00-f125-492f-90ef-5d93ae02045d	2	20	t	ec91b84a-e61a-4484-941b-54a874a4129b	\N
ec38992c-2176-4468-8544-ac76da49b60e	\N	idp-username-password-form	def58135-f6f9-494c-b177-21c2d610717d	ec91b84a-e61a-4484-941b-54a874a4129b	0	10	f	\N	\N
1b9fe580-e4e7-4453-b96a-3471f7830093	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	ec91b84a-e61a-4484-941b-54a874a4129b	1	20	t	7370c63d-7d34-431d-a106-487a80cf648d	\N
7ca6ca64-5554-4f31-ac6c-593d94fb9d0a	\N	conditional-user-configured	def58135-f6f9-494c-b177-21c2d610717d	7370c63d-7d34-431d-a106-487a80cf648d	0	10	f	\N	\N
8b358303-bb14-4ceb-b85e-faf7451194ed	\N	auth-otp-form	def58135-f6f9-494c-b177-21c2d610717d	7370c63d-7d34-431d-a106-487a80cf648d	0	20	f	\N	\N
f7c2b204-ec9d-4ee3-b472-00ad2f4b347e	\N	http-basic-authenticator	def58135-f6f9-494c-b177-21c2d610717d	9f851236-d90f-4e54-9c35-f3ff9be80d26	0	10	f	\N	\N
14a31a47-b5fb-427d-9d63-3f107a307c24	\N	docker-http-basic-authenticator	def58135-f6f9-494c-b177-21c2d610717d	dbc20a4b-c64f-4776-a2a2-676c8d94e6ad	0	10	f	\N	\N
80d38ee5-ac7f-4467-ab87-9e355cc969cc	\N	auth-cookie	26848019-e2da-4775-a3ad-60ce8c6173f2	94aa729f-ad78-4dc9-b511-3a4a1efa5ec9	2	10	f	\N	\N
e1a409a2-0cc8-429b-813d-2d9eb260e865	\N	auth-spnego	26848019-e2da-4775-a3ad-60ce8c6173f2	94aa729f-ad78-4dc9-b511-3a4a1efa5ec9	3	20	f	\N	\N
c3ecb3eb-7e32-460e-bc5c-9849957b4567	\N	identity-provider-redirector	26848019-e2da-4775-a3ad-60ce8c6173f2	94aa729f-ad78-4dc9-b511-3a4a1efa5ec9	2	25	f	\N	\N
313754d9-271e-4b26-9d23-7edbbb2b0604	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	94aa729f-ad78-4dc9-b511-3a4a1efa5ec9	2	30	t	cbd422d0-2a3e-4644-b598-7b63d0631523	\N
e1892831-d5ee-4bdf-9924-e4175cf0e4cb	\N	auth-username-password-form	26848019-e2da-4775-a3ad-60ce8c6173f2	cbd422d0-2a3e-4644-b598-7b63d0631523	0	10	f	\N	\N
e2ffb668-1573-4c78-ad66-fc812a6d28d6	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	cbd422d0-2a3e-4644-b598-7b63d0631523	1	20	t	a2bd731f-3d60-423b-bee1-196c02249d19	\N
2783ac11-6952-4338-819c-f12a61d8ab3b	\N	conditional-user-configured	26848019-e2da-4775-a3ad-60ce8c6173f2	a2bd731f-3d60-423b-bee1-196c02249d19	0	10	f	\N	\N
4e99cde6-7ce1-4c14-9cbf-27cd9161a813	\N	auth-otp-form	26848019-e2da-4775-a3ad-60ce8c6173f2	a2bd731f-3d60-423b-bee1-196c02249d19	0	20	f	\N	\N
a1f3706e-4a7e-4cf8-bfbd-d707a1dd89b1	\N	direct-grant-validate-username	26848019-e2da-4775-a3ad-60ce8c6173f2	a98e6219-9416-4395-bcef-62cfd524197b	0	10	f	\N	\N
ebe4b34b-3e0b-4590-bf0d-0e7e6fa8a0d6	\N	direct-grant-validate-password	26848019-e2da-4775-a3ad-60ce8c6173f2	a98e6219-9416-4395-bcef-62cfd524197b	0	20	f	\N	\N
cd28a13d-6521-47e6-986b-377911b37aa2	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	a98e6219-9416-4395-bcef-62cfd524197b	1	30	t	d75cae0a-def5-473f-b88e-cde6f2e35c87	\N
d4ca3ad1-929a-4e5e-ba9f-b5bfcc3038f2	\N	conditional-user-configured	26848019-e2da-4775-a3ad-60ce8c6173f2	d75cae0a-def5-473f-b88e-cde6f2e35c87	0	10	f	\N	\N
ac1fafa8-1ceb-4877-86d1-8629c22d1507	\N	direct-grant-validate-otp	26848019-e2da-4775-a3ad-60ce8c6173f2	d75cae0a-def5-473f-b88e-cde6f2e35c87	0	20	f	\N	\N
95ba8f36-8331-4341-9c6b-aff090da6bda	\N	registration-page-form	26848019-e2da-4775-a3ad-60ce8c6173f2	4503b87d-2e6b-4e75-9754-e971da575a2d	0	10	t	7f4a2a9d-7484-4df1-a667-6714285e30fd	\N
49cb0b5e-d123-46ba-97a2-9ead7813c4b6	\N	registration-user-creation	26848019-e2da-4775-a3ad-60ce8c6173f2	7f4a2a9d-7484-4df1-a667-6714285e30fd	0	20	f	\N	\N
ba63a342-1291-4f4c-b40a-62ebefcd989b	\N	registration-password-action	26848019-e2da-4775-a3ad-60ce8c6173f2	7f4a2a9d-7484-4df1-a667-6714285e30fd	0	50	f	\N	\N
737aff47-deea-4b40-b839-ac3d03eae238	\N	registration-recaptcha-action	26848019-e2da-4775-a3ad-60ce8c6173f2	7f4a2a9d-7484-4df1-a667-6714285e30fd	3	60	f	\N	\N
6bdf7fbe-03da-4126-8919-0622bb70c33a	\N	reset-credentials-choose-user	26848019-e2da-4775-a3ad-60ce8c6173f2	ed5e2d9c-d256-4827-84d0-4a6a7ec3c501	0	10	f	\N	\N
b4797c68-e64b-4687-a5c8-38fbaee4d24a	\N	reset-credential-email	26848019-e2da-4775-a3ad-60ce8c6173f2	ed5e2d9c-d256-4827-84d0-4a6a7ec3c501	0	20	f	\N	\N
bc000290-17c6-472b-83b4-e9aff4c9e11d	\N	reset-password	26848019-e2da-4775-a3ad-60ce8c6173f2	ed5e2d9c-d256-4827-84d0-4a6a7ec3c501	0	30	f	\N	\N
1d715e12-2c09-4d68-aa19-d4e9aa95c024	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	ed5e2d9c-d256-4827-84d0-4a6a7ec3c501	1	40	t	5afe1965-8b3c-4e69-8df3-4ae6392e4c1c	\N
9f303e9c-27b5-40f9-a2d4-60305ada81e1	\N	conditional-user-configured	26848019-e2da-4775-a3ad-60ce8c6173f2	5afe1965-8b3c-4e69-8df3-4ae6392e4c1c	0	10	f	\N	\N
606f7bab-c5c3-4225-a714-6341e7ff9ab5	\N	reset-otp	26848019-e2da-4775-a3ad-60ce8c6173f2	5afe1965-8b3c-4e69-8df3-4ae6392e4c1c	0	20	f	\N	\N
69c1d58f-c447-4ac9-93ca-35d6e08fbfd3	\N	client-secret	26848019-e2da-4775-a3ad-60ce8c6173f2	a74f4001-7bc6-468f-bd31-111576eb68c7	2	10	f	\N	\N
f73606f2-f6f0-4c10-955f-4d031055bfb9	\N	client-jwt	26848019-e2da-4775-a3ad-60ce8c6173f2	a74f4001-7bc6-468f-bd31-111576eb68c7	2	20	f	\N	\N
80afce1a-e4ee-49a1-b9de-910deccc05fa	\N	client-secret-jwt	26848019-e2da-4775-a3ad-60ce8c6173f2	a74f4001-7bc6-468f-bd31-111576eb68c7	2	30	f	\N	\N
473a6351-464c-4b50-9f81-eae8544fdf52	\N	client-x509	26848019-e2da-4775-a3ad-60ce8c6173f2	a74f4001-7bc6-468f-bd31-111576eb68c7	2	40	f	\N	\N
3ee85594-aea3-4054-accf-e2fff21507dd	\N	idp-review-profile	26848019-e2da-4775-a3ad-60ce8c6173f2	2b607b78-93b0-4635-b26c-a5263f91285f	0	10	f	\N	7d379fef-6448-47a0-af89-61112ac8ac2e
10002493-9c21-482f-b487-349a7270646a	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	2b607b78-93b0-4635-b26c-a5263f91285f	0	20	t	1d2219dd-46cd-4d96-bbe1-7e35b5cd3965	\N
e7ef04ca-b9fd-4f54-a7a6-997b3f47803d	\N	idp-create-user-if-unique	26848019-e2da-4775-a3ad-60ce8c6173f2	1d2219dd-46cd-4d96-bbe1-7e35b5cd3965	2	10	f	\N	33a46e9f-a3cd-4254-b00d-d53c2b9d16b1
a09dd56f-2efd-4307-a36c-c200fd2c9440	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	1d2219dd-46cd-4d96-bbe1-7e35b5cd3965	2	20	t	87632881-9e0f-4b13-9d9c-d85d0220d675	\N
e3081dc8-0d18-4f23-89ef-bbed379b3b10	\N	idp-confirm-link	26848019-e2da-4775-a3ad-60ce8c6173f2	87632881-9e0f-4b13-9d9c-d85d0220d675	0	10	f	\N	\N
0760a578-4bc1-4c91-b4a2-99798b0b9df6	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	87632881-9e0f-4b13-9d9c-d85d0220d675	0	20	t	e2652052-51a0-4c7a-aff3-8c864cb89222	\N
2addda0a-ea80-4b2f-aead-796ca9ed1040	\N	idp-email-verification	26848019-e2da-4775-a3ad-60ce8c6173f2	e2652052-51a0-4c7a-aff3-8c864cb89222	2	10	f	\N	\N
388f0b5e-da79-4265-afa7-3c847ecf9927	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	e2652052-51a0-4c7a-aff3-8c864cb89222	2	20	t	ce3ed5d1-7988-4102-b94b-b0b6f243449c	\N
59c7b777-a85a-4e1b-ac8c-07b40be469c9	\N	idp-username-password-form	26848019-e2da-4775-a3ad-60ce8c6173f2	ce3ed5d1-7988-4102-b94b-b0b6f243449c	0	10	f	\N	\N
1ace4571-de32-42d7-9076-c3f69f737279	\N	\N	26848019-e2da-4775-a3ad-60ce8c6173f2	ce3ed5d1-7988-4102-b94b-b0b6f243449c	1	20	t	be047640-9100-4a3e-92f1-24dc0717359c	\N
52e60983-3f72-404e-9a24-1c3edb78d296	\N	conditional-user-configured	26848019-e2da-4775-a3ad-60ce8c6173f2	be047640-9100-4a3e-92f1-24dc0717359c	0	10	f	\N	\N
17084115-55f9-4489-9b32-0cad31b875cb	\N	auth-otp-form	26848019-e2da-4775-a3ad-60ce8c6173f2	be047640-9100-4a3e-92f1-24dc0717359c	0	20	f	\N	\N
9fb58457-d7a3-4b27-bfa5-6ee81b806f4f	\N	http-basic-authenticator	26848019-e2da-4775-a3ad-60ce8c6173f2	add1256f-2f02-4607-8ad0-7d71d96120a2	0	10	f	\N	\N
310782f0-7c92-4028-a0a9-50f4d102b945	\N	docker-http-basic-authenticator	26848019-e2da-4775-a3ad-60ce8c6173f2	bd929695-e425-423c-a0e5-c513b40f5c5f	0	10	f	\N	\N
\.


--
-- Data for Name: authentication_flow; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authentication_flow (id, alias, description, realm_id, provider_id, top_level, built_in) FROM stdin;
0f63d3ca-1a92-43cf-8b6f-1ea93c9a47f0	browser	browser based authentication	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
fdbbd1d7-49a6-4411-9e8e-d31a5923fe87	forms	Username, password, otp and other auth forms.	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
c05a3ddf-0623-4715-b1fb-7afefebca3ed	Browser - Conditional OTP	Flow to determine if the OTP is required for the authentication	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
80521110-e051-4613-882a-3e1f30d23174	direct grant	OpenID Connect Resource Owner Grant	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
8dce14d1-38c4-4bb5-b395-f65952102262	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
55688f4b-42df-4969-9957-15c6099759e6	registration	registration flow	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
10a759be-259b-477d-8f74-a9fd06eb9fcd	registration form	registration form	def58135-f6f9-494c-b177-21c2d610717d	form-flow	f	t
7b06330b-14b8-4d35-bf40-3dc344f89b99	reset credentials	Reset credentials for a user if they forgot their password or something	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
8e74f452-a243-44a3-8fea-e4ee2a16fe47	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
11c7742e-dad9-45e2-bea9-8686ebaf815f	clients	Base authentication for clients	def58135-f6f9-494c-b177-21c2d610717d	client-flow	t	t
6a21de26-ef53-4747-bc85-631ffa1e9a89	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
b1e98ee9-bfd0-41af-9d10-c1f872fe317a	User creation or linking	Flow for the existing/non-existing user alternatives	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
3a612536-774d-4a25-b630-406f02ff8241	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
d805ae00-f125-492f-90ef-5d93ae02045d	Account verification options	Method with which to verity the existing account	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
ec91b84a-e61a-4484-941b-54a874a4129b	Verify Existing Account by Re-authentication	Reauthentication of existing account	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
7370c63d-7d34-431d-a106-487a80cf648d	First broker login - Conditional OTP	Flow to determine if the OTP is required for the authentication	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	f	t
9f851236-d90f-4e54-9c35-f3ff9be80d26	saml ecp	SAML ECP Profile Authentication Flow	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
dbc20a4b-c64f-4776-a2a2-676c8d94e6ad	docker auth	Used by Docker clients to authenticate against the IDP	def58135-f6f9-494c-b177-21c2d610717d	basic-flow	t	t
94aa729f-ad78-4dc9-b511-3a4a1efa5ec9	browser	browser based authentication	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
cbd422d0-2a3e-4644-b598-7b63d0631523	forms	Username, password, otp and other auth forms.	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
a2bd731f-3d60-423b-bee1-196c02249d19	Browser - Conditional OTP	Flow to determine if the OTP is required for the authentication	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
a98e6219-9416-4395-bcef-62cfd524197b	direct grant	OpenID Connect Resource Owner Grant	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
d75cae0a-def5-473f-b88e-cde6f2e35c87	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
4503b87d-2e6b-4e75-9754-e971da575a2d	registration	registration flow	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
7f4a2a9d-7484-4df1-a667-6714285e30fd	registration form	registration form	26848019-e2da-4775-a3ad-60ce8c6173f2	form-flow	f	t
ed5e2d9c-d256-4827-84d0-4a6a7ec3c501	reset credentials	Reset credentials for a user if they forgot their password or something	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
5afe1965-8b3c-4e69-8df3-4ae6392e4c1c	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
a74f4001-7bc6-468f-bd31-111576eb68c7	clients	Base authentication for clients	26848019-e2da-4775-a3ad-60ce8c6173f2	client-flow	t	t
2b607b78-93b0-4635-b26c-a5263f91285f	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
1d2219dd-46cd-4d96-bbe1-7e35b5cd3965	User creation or linking	Flow for the existing/non-existing user alternatives	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
87632881-9e0f-4b13-9d9c-d85d0220d675	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
e2652052-51a0-4c7a-aff3-8c864cb89222	Account verification options	Method with which to verity the existing account	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
ce3ed5d1-7988-4102-b94b-b0b6f243449c	Verify Existing Account by Re-authentication	Reauthentication of existing account	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
be047640-9100-4a3e-92f1-24dc0717359c	First broker login - Conditional OTP	Flow to determine if the OTP is required for the authentication	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	f	t
add1256f-2f02-4607-8ad0-7d71d96120a2	saml ecp	SAML ECP Profile Authentication Flow	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
bd929695-e425-423c-a0e5-c513b40f5c5f	docker auth	Used by Docker clients to authenticate against the IDP	26848019-e2da-4775-a3ad-60ce8c6173f2	basic-flow	t	t
\.


--
-- Data for Name: authenticator_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authenticator_config (id, alias, realm_id) FROM stdin;
5927d697-c6f7-4945-8415-0cc34e0f03a3	review profile config	def58135-f6f9-494c-b177-21c2d610717d
e0c4e293-d3c0-46f4-bb32-1d716ba98d86	create unique user config	def58135-f6f9-494c-b177-21c2d610717d
7d379fef-6448-47a0-af89-61112ac8ac2e	review profile config	26848019-e2da-4775-a3ad-60ce8c6173f2
33a46e9f-a3cd-4254-b00d-d53c2b9d16b1	create unique user config	26848019-e2da-4775-a3ad-60ce8c6173f2
\.


--
-- Data for Name: authenticator_config_entry; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authenticator_config_entry (authenticator_id, value, name) FROM stdin;
5927d697-c6f7-4945-8415-0cc34e0f03a3	missing	update.profile.on.first.login
e0c4e293-d3c0-46f4-bb32-1d716ba98d86	false	require.password.update.after.registration
33a46e9f-a3cd-4254-b00d-d53c2b9d16b1	false	require.password.update.after.registration
7d379fef-6448-47a0-af89-61112ac8ac2e	missing	update.profile.on.first.login
\.


--
-- Data for Name: broker_link; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.broker_link (identity_provider, storage_provider_id, realm_id, broker_user_id, broker_username, token, user_id) FROM stdin;
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client (id, enabled, full_scope_allowed, client_id, not_before, public_client, secret, base_url, bearer_only, management_url, surrogate_auth_required, realm_id, protocol, node_rereg_timeout, frontchannel_logout, consent_required, name, service_accounts_enabled, client_authenticator_type, root_url, description, registration_token, standard_flow_enabled, implicit_flow_enabled, direct_access_grants_enabled, always_display_in_console) FROM stdin;
7026036f-3ce5-4357-831a-544680b316b4	t	f	master-realm	0	f	\N	\N	t	\N	f	def58135-f6f9-494c-b177-21c2d610717d	\N	0	f	f	master Realm	f	client-secret	\N	\N	\N	t	f	f	f
6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	f	account	0	t	\N	/realms/master/account/	f	\N	f	def58135-f6f9-494c-b177-21c2d610717d	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	t	f	account-console	0	t	\N	/realms/master/account/	f	\N	f	def58135-f6f9-494c-b177-21c2d610717d	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
39b31477-f075-4686-8d71-7dcb4d9487cb	t	f	broker	0	f	\N	\N	t	\N	f	def58135-f6f9-494c-b177-21c2d610717d	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	t	f	security-admin-console	0	t	\N	/admin/master/console/	f	\N	f	def58135-f6f9-494c-b177-21c2d610717d	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
b21a1f25-def9-453e-8c42-b86029954c13	t	f	admin-cli	0	t	\N	\N	f	\N	f	def58135-f6f9-494c-b177-21c2d610717d	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
bf4b0124-6dbe-4947-92a3-c28ae427642f	t	f	maskanyone-realm	0	f	\N	\N	t	\N	f	def58135-f6f9-494c-b177-21c2d610717d	\N	0	f	f	maskanyone Realm	f	client-secret	\N	\N	\N	t	f	f	f
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	f	realm-management	0	f	\N	\N	t	\N	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	0	f	f	${client_realm-management}	f	client-secret	\N	\N	\N	t	f	f	f
a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	f	account	0	t	\N	/realms/maskanyone/account/	f	\N	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
8e1e8954-7bec-4a60-8567-613e39ee594c	t	f	account-console	0	t	\N	/realms/maskanyone/account/	f	\N	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	t	f	broker	0	f	\N	\N	t	\N	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
fbfe3dc5-e674-4324-8dc4-d00e64be6796	t	f	security-admin-console	0	t	\N	/admin/maskanyone/console/	f	\N	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	t	f	admin-cli	0	t	\N	\N	f	\N	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	t	t	maskanyone-fe	0	t	\N		f	https://localhost	f	26848019-e2da-4775-a3ad-60ce8c6173f2	openid-connect	-1	t	f		f	client-secret	https://localhost		\N	t	t	t	f
\.


--
-- Data for Name: client_attributes; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_attributes (client_id, name, value) FROM stdin;
6a0cd2a0-1010-4a5e-bdfa-d20537224997	post.logout.redirect.uris	+
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	post.logout.redirect.uris	+
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	pkce.code.challenge.method	S256
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	post.logout.redirect.uris	+
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	pkce.code.challenge.method	S256
a56c5ce1-4e7c-4380-ab53-c3658986fa56	post.logout.redirect.uris	+
8e1e8954-7bec-4a60-8567-613e39ee594c	post.logout.redirect.uris	+
8e1e8954-7bec-4a60-8567-613e39ee594c	pkce.code.challenge.method	S256
fbfe3dc5-e674-4324-8dc4-d00e64be6796	post.logout.redirect.uris	+
fbfe3dc5-e674-4324-8dc4-d00e64be6796	pkce.code.challenge.method	S256
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	oauth2.device.authorization.grant.enabled	false
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	oidc.ciba.grant.enabled	false
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	backchannel.logout.session.required	true
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	backchannel.logout.revoke.offline.tokens	false
\.


--
-- Data for Name: client_auth_flow_bindings; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_auth_flow_bindings (client_id, flow_id, binding_name) FROM stdin;
\.


--
-- Data for Name: client_initial_access; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_initial_access (id, realm_id, "timestamp", expiration, count, remaining_count) FROM stdin;
\.


--
-- Data for Name: client_node_registrations; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_node_registrations (client_id, value, name) FROM stdin;
\.


--
-- Data for Name: client_scope; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope (id, name, realm_id, description, protocol) FROM stdin;
4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	offline_access	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect built-in scope: offline_access	openid-connect
a14f4177-310c-420a-b28f-428df0698136	role_list	def58135-f6f9-494c-b177-21c2d610717d	SAML role list	saml
e60a80ce-084b-4571-8cc4-09b5292aa042	profile	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect built-in scope: profile	openid-connect
9b11e43e-d445-4546-bcf0-bc8d2802face	email	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect built-in scope: email	openid-connect
9cb609e3-fde4-48e2-9961-2a521366eb55	address	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect built-in scope: address	openid-connect
beb03732-4117-43c6-b498-c02128563608	phone	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect built-in scope: phone	openid-connect
56f38420-c513-45f4-8d5b-785eb9298404	roles	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect scope for add user roles to the access token	openid-connect
b28e9102-1992-4af1-933b-fd0c20a8e266	web-origins	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect scope for add allowed web origins to the access token	openid-connect
32fd8b43-bdd1-4ced-983f-d8590a944cbb	microprofile-jwt	def58135-f6f9-494c-b177-21c2d610717d	Microprofile - JWT built-in scope	openid-connect
f057fa69-8f7b-4b9b-bede-69cd3faf35c6	acr	def58135-f6f9-494c-b177-21c2d610717d	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
a773fb0f-9993-49e7-9214-7e7f98c6ad79	offline_access	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect built-in scope: offline_access	openid-connect
cbaacbbe-c0c5-4657-907d-00fb309df49d	role_list	26848019-e2da-4775-a3ad-60ce8c6173f2	SAML role list	saml
8baab608-b71e-4b15-b96c-d2fc480555aa	profile	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect built-in scope: profile	openid-connect
fe7ad17f-93c9-4206-a35b-03e852c5c1d8	email	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect built-in scope: email	openid-connect
b7e33886-aa02-44c2-8165-aaf52c05634d	address	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect built-in scope: address	openid-connect
ab0d9d68-dcb7-44b7-96cb-75b359b1d529	phone	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect built-in scope: phone	openid-connect
322a9d9e-56e1-4785-8a61-96eab81465d6	roles	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect scope for add user roles to the access token	openid-connect
1a83699a-cf4d-45db-8be0-c841c3c253a6	web-origins	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect scope for add allowed web origins to the access token	openid-connect
3fe2462d-dd6a-48c6-b590-40a4e8408397	microprofile-jwt	26848019-e2da-4775-a3ad-60ce8c6173f2	Microprofile - JWT built-in scope	openid-connect
d99f24ab-b058-41c0-89c8-347252789592	acr	26848019-e2da-4775-a3ad-60ce8c6173f2	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
\.


--
-- Data for Name: client_scope_attributes; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope_attributes (scope_id, value, name) FROM stdin;
4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	true	display.on.consent.screen
4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	${offlineAccessScopeConsentText}	consent.screen.text
a14f4177-310c-420a-b28f-428df0698136	true	display.on.consent.screen
a14f4177-310c-420a-b28f-428df0698136	${samlRoleListScopeConsentText}	consent.screen.text
e60a80ce-084b-4571-8cc4-09b5292aa042	true	display.on.consent.screen
e60a80ce-084b-4571-8cc4-09b5292aa042	${profileScopeConsentText}	consent.screen.text
e60a80ce-084b-4571-8cc4-09b5292aa042	true	include.in.token.scope
9b11e43e-d445-4546-bcf0-bc8d2802face	true	display.on.consent.screen
9b11e43e-d445-4546-bcf0-bc8d2802face	${emailScopeConsentText}	consent.screen.text
9b11e43e-d445-4546-bcf0-bc8d2802face	true	include.in.token.scope
9cb609e3-fde4-48e2-9961-2a521366eb55	true	display.on.consent.screen
9cb609e3-fde4-48e2-9961-2a521366eb55	${addressScopeConsentText}	consent.screen.text
9cb609e3-fde4-48e2-9961-2a521366eb55	true	include.in.token.scope
beb03732-4117-43c6-b498-c02128563608	true	display.on.consent.screen
beb03732-4117-43c6-b498-c02128563608	${phoneScopeConsentText}	consent.screen.text
beb03732-4117-43c6-b498-c02128563608	true	include.in.token.scope
56f38420-c513-45f4-8d5b-785eb9298404	true	display.on.consent.screen
56f38420-c513-45f4-8d5b-785eb9298404	${rolesScopeConsentText}	consent.screen.text
56f38420-c513-45f4-8d5b-785eb9298404	false	include.in.token.scope
b28e9102-1992-4af1-933b-fd0c20a8e266	false	display.on.consent.screen
b28e9102-1992-4af1-933b-fd0c20a8e266		consent.screen.text
b28e9102-1992-4af1-933b-fd0c20a8e266	false	include.in.token.scope
32fd8b43-bdd1-4ced-983f-d8590a944cbb	false	display.on.consent.screen
32fd8b43-bdd1-4ced-983f-d8590a944cbb	true	include.in.token.scope
f057fa69-8f7b-4b9b-bede-69cd3faf35c6	false	display.on.consent.screen
f057fa69-8f7b-4b9b-bede-69cd3faf35c6	false	include.in.token.scope
a773fb0f-9993-49e7-9214-7e7f98c6ad79	true	display.on.consent.screen
a773fb0f-9993-49e7-9214-7e7f98c6ad79	${offlineAccessScopeConsentText}	consent.screen.text
cbaacbbe-c0c5-4657-907d-00fb309df49d	true	display.on.consent.screen
cbaacbbe-c0c5-4657-907d-00fb309df49d	${samlRoleListScopeConsentText}	consent.screen.text
8baab608-b71e-4b15-b96c-d2fc480555aa	true	display.on.consent.screen
8baab608-b71e-4b15-b96c-d2fc480555aa	${profileScopeConsentText}	consent.screen.text
8baab608-b71e-4b15-b96c-d2fc480555aa	true	include.in.token.scope
fe7ad17f-93c9-4206-a35b-03e852c5c1d8	true	display.on.consent.screen
fe7ad17f-93c9-4206-a35b-03e852c5c1d8	${emailScopeConsentText}	consent.screen.text
fe7ad17f-93c9-4206-a35b-03e852c5c1d8	true	include.in.token.scope
b7e33886-aa02-44c2-8165-aaf52c05634d	true	display.on.consent.screen
b7e33886-aa02-44c2-8165-aaf52c05634d	${addressScopeConsentText}	consent.screen.text
b7e33886-aa02-44c2-8165-aaf52c05634d	true	include.in.token.scope
ab0d9d68-dcb7-44b7-96cb-75b359b1d529	true	display.on.consent.screen
ab0d9d68-dcb7-44b7-96cb-75b359b1d529	${phoneScopeConsentText}	consent.screen.text
ab0d9d68-dcb7-44b7-96cb-75b359b1d529	true	include.in.token.scope
322a9d9e-56e1-4785-8a61-96eab81465d6	true	display.on.consent.screen
322a9d9e-56e1-4785-8a61-96eab81465d6	${rolesScopeConsentText}	consent.screen.text
322a9d9e-56e1-4785-8a61-96eab81465d6	false	include.in.token.scope
1a83699a-cf4d-45db-8be0-c841c3c253a6	false	display.on.consent.screen
1a83699a-cf4d-45db-8be0-c841c3c253a6		consent.screen.text
1a83699a-cf4d-45db-8be0-c841c3c253a6	false	include.in.token.scope
3fe2462d-dd6a-48c6-b590-40a4e8408397	false	display.on.consent.screen
3fe2462d-dd6a-48c6-b590-40a4e8408397	true	include.in.token.scope
d99f24ab-b058-41c0-89c8-347252789592	false	display.on.consent.screen
d99f24ab-b058-41c0-89c8-347252789592	false	include.in.token.scope
\.


--
-- Data for Name: client_scope_client; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope_client (client_id, scope_id, default_scope) FROM stdin;
6a0cd2a0-1010-4a5e-bdfa-d20537224997	b28e9102-1992-4af1-933b-fd0c20a8e266	t
6a0cd2a0-1010-4a5e-bdfa-d20537224997	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
6a0cd2a0-1010-4a5e-bdfa-d20537224997	9b11e43e-d445-4546-bcf0-bc8d2802face	t
6a0cd2a0-1010-4a5e-bdfa-d20537224997	56f38420-c513-45f4-8d5b-785eb9298404	t
6a0cd2a0-1010-4a5e-bdfa-d20537224997	e60a80ce-084b-4571-8cc4-09b5292aa042	t
6a0cd2a0-1010-4a5e-bdfa-d20537224997	9cb609e3-fde4-48e2-9961-2a521366eb55	f
6a0cd2a0-1010-4a5e-bdfa-d20537224997	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
6a0cd2a0-1010-4a5e-bdfa-d20537224997	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
6a0cd2a0-1010-4a5e-bdfa-d20537224997	beb03732-4117-43c6-b498-c02128563608	f
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	b28e9102-1992-4af1-933b-fd0c20a8e266	t
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	9b11e43e-d445-4546-bcf0-bc8d2802face	t
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	56f38420-c513-45f4-8d5b-785eb9298404	t
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	e60a80ce-084b-4571-8cc4-09b5292aa042	t
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	9cb609e3-fde4-48e2-9961-2a521366eb55	f
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	beb03732-4117-43c6-b498-c02128563608	f
b21a1f25-def9-453e-8c42-b86029954c13	b28e9102-1992-4af1-933b-fd0c20a8e266	t
b21a1f25-def9-453e-8c42-b86029954c13	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
b21a1f25-def9-453e-8c42-b86029954c13	9b11e43e-d445-4546-bcf0-bc8d2802face	t
b21a1f25-def9-453e-8c42-b86029954c13	56f38420-c513-45f4-8d5b-785eb9298404	t
b21a1f25-def9-453e-8c42-b86029954c13	e60a80ce-084b-4571-8cc4-09b5292aa042	t
b21a1f25-def9-453e-8c42-b86029954c13	9cb609e3-fde4-48e2-9961-2a521366eb55	f
b21a1f25-def9-453e-8c42-b86029954c13	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
b21a1f25-def9-453e-8c42-b86029954c13	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
b21a1f25-def9-453e-8c42-b86029954c13	beb03732-4117-43c6-b498-c02128563608	f
39b31477-f075-4686-8d71-7dcb4d9487cb	b28e9102-1992-4af1-933b-fd0c20a8e266	t
39b31477-f075-4686-8d71-7dcb4d9487cb	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
39b31477-f075-4686-8d71-7dcb4d9487cb	9b11e43e-d445-4546-bcf0-bc8d2802face	t
39b31477-f075-4686-8d71-7dcb4d9487cb	56f38420-c513-45f4-8d5b-785eb9298404	t
39b31477-f075-4686-8d71-7dcb4d9487cb	e60a80ce-084b-4571-8cc4-09b5292aa042	t
39b31477-f075-4686-8d71-7dcb4d9487cb	9cb609e3-fde4-48e2-9961-2a521366eb55	f
39b31477-f075-4686-8d71-7dcb4d9487cb	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
39b31477-f075-4686-8d71-7dcb4d9487cb	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
39b31477-f075-4686-8d71-7dcb4d9487cb	beb03732-4117-43c6-b498-c02128563608	f
7026036f-3ce5-4357-831a-544680b316b4	b28e9102-1992-4af1-933b-fd0c20a8e266	t
7026036f-3ce5-4357-831a-544680b316b4	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
7026036f-3ce5-4357-831a-544680b316b4	9b11e43e-d445-4546-bcf0-bc8d2802face	t
7026036f-3ce5-4357-831a-544680b316b4	56f38420-c513-45f4-8d5b-785eb9298404	t
7026036f-3ce5-4357-831a-544680b316b4	e60a80ce-084b-4571-8cc4-09b5292aa042	t
7026036f-3ce5-4357-831a-544680b316b4	9cb609e3-fde4-48e2-9961-2a521366eb55	f
7026036f-3ce5-4357-831a-544680b316b4	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
7026036f-3ce5-4357-831a-544680b316b4	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
7026036f-3ce5-4357-831a-544680b316b4	beb03732-4117-43c6-b498-c02128563608	f
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	b28e9102-1992-4af1-933b-fd0c20a8e266	t
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	9b11e43e-d445-4546-bcf0-bc8d2802face	t
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	56f38420-c513-45f4-8d5b-785eb9298404	t
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	e60a80ce-084b-4571-8cc4-09b5292aa042	t
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	9cb609e3-fde4-48e2-9961-2a521366eb55	f
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	beb03732-4117-43c6-b498-c02128563608	f
a56c5ce1-4e7c-4380-ab53-c3658986fa56	322a9d9e-56e1-4785-8a61-96eab81465d6	t
a56c5ce1-4e7c-4380-ab53-c3658986fa56	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
a56c5ce1-4e7c-4380-ab53-c3658986fa56	d99f24ab-b058-41c0-89c8-347252789592	t
a56c5ce1-4e7c-4380-ab53-c3658986fa56	8baab608-b71e-4b15-b96c-d2fc480555aa	t
a56c5ce1-4e7c-4380-ab53-c3658986fa56	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
a56c5ce1-4e7c-4380-ab53-c3658986fa56	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
a56c5ce1-4e7c-4380-ab53-c3658986fa56	b7e33886-aa02-44c2-8165-aaf52c05634d	f
a56c5ce1-4e7c-4380-ab53-c3658986fa56	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
a56c5ce1-4e7c-4380-ab53-c3658986fa56	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
8e1e8954-7bec-4a60-8567-613e39ee594c	322a9d9e-56e1-4785-8a61-96eab81465d6	t
8e1e8954-7bec-4a60-8567-613e39ee594c	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
8e1e8954-7bec-4a60-8567-613e39ee594c	d99f24ab-b058-41c0-89c8-347252789592	t
8e1e8954-7bec-4a60-8567-613e39ee594c	8baab608-b71e-4b15-b96c-d2fc480555aa	t
8e1e8954-7bec-4a60-8567-613e39ee594c	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
8e1e8954-7bec-4a60-8567-613e39ee594c	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
8e1e8954-7bec-4a60-8567-613e39ee594c	b7e33886-aa02-44c2-8165-aaf52c05634d	f
8e1e8954-7bec-4a60-8567-613e39ee594c	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
8e1e8954-7bec-4a60-8567-613e39ee594c	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	322a9d9e-56e1-4785-8a61-96eab81465d6	t
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	d99f24ab-b058-41c0-89c8-347252789592	t
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	8baab608-b71e-4b15-b96c-d2fc480555aa	t
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	b7e33886-aa02-44c2-8165-aaf52c05634d	f
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
1c76358e-df7f-46b0-ad5e-10b51bd18bc9	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	322a9d9e-56e1-4785-8a61-96eab81465d6	t
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	d99f24ab-b058-41c0-89c8-347252789592	t
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	8baab608-b71e-4b15-b96c-d2fc480555aa	t
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	b7e33886-aa02-44c2-8165-aaf52c05634d	f
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	322a9d9e-56e1-4785-8a61-96eab81465d6	t
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	d99f24ab-b058-41c0-89c8-347252789592	t
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	8baab608-b71e-4b15-b96c-d2fc480555aa	t
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	b7e33886-aa02-44c2-8165-aaf52c05634d	f
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
b85b80bf-3a5e-40d7-916c-eae2c0d2704d	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
fbfe3dc5-e674-4324-8dc4-d00e64be6796	322a9d9e-56e1-4785-8a61-96eab81465d6	t
fbfe3dc5-e674-4324-8dc4-d00e64be6796	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
fbfe3dc5-e674-4324-8dc4-d00e64be6796	d99f24ab-b058-41c0-89c8-347252789592	t
fbfe3dc5-e674-4324-8dc4-d00e64be6796	8baab608-b71e-4b15-b96c-d2fc480555aa	t
fbfe3dc5-e674-4324-8dc4-d00e64be6796	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
fbfe3dc5-e674-4324-8dc4-d00e64be6796	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
fbfe3dc5-e674-4324-8dc4-d00e64be6796	b7e33886-aa02-44c2-8165-aaf52c05634d	f
fbfe3dc5-e674-4324-8dc4-d00e64be6796	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
fbfe3dc5-e674-4324-8dc4-d00e64be6796	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	322a9d9e-56e1-4785-8a61-96eab81465d6	t
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	d99f24ab-b058-41c0-89c8-347252789592	t
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	8baab608-b71e-4b15-b96c-d2fc480555aa	t
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	b7e33886-aa02-44c2-8165-aaf52c05634d	f
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
\.


--
-- Data for Name: client_scope_role_mapping; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope_role_mapping (scope_id, role_id) FROM stdin;
4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	ad4dfb7c-bb2a-4bcb-b60d-461f1ecc1d64
a773fb0f-9993-49e7-9214-7e7f98c6ad79	c4d5cdda-04b9-4597-a8a1-1732007044e7
\.


--
-- Data for Name: client_session; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_session (id, client_id, redirect_uri, state, "timestamp", session_id, auth_method, realm_id, auth_user_id, current_action) FROM stdin;
\.


--
-- Data for Name: client_session_auth_status; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_session_auth_status (authenticator, status, client_session) FROM stdin;
\.


--
-- Data for Name: client_session_note; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_session_note (name, value, client_session) FROM stdin;
\.


--
-- Data for Name: client_session_prot_mapper; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_session_prot_mapper (protocol_mapper_id, client_session) FROM stdin;
\.


--
-- Data for Name: client_session_role; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_session_role (role_id, client_session) FROM stdin;
\.


--
-- Data for Name: client_user_session_note; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_user_session_note (name, value, client_session) FROM stdin;
\.


--
-- Data for Name: component; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.component (id, name, parent_id, provider_id, provider_type, realm_id, sub_type) FROM stdin;
40178be8-2764-48f5-b3e4-09da48002fb1	Trusted Hosts	def58135-f6f9-494c-b177-21c2d610717d	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	anonymous
a601cc9c-e5c7-4efd-a667-f64183388226	Consent Required	def58135-f6f9-494c-b177-21c2d610717d	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	anonymous
51b7e21b-b893-4f4f-b21e-66d783da8622	Full Scope Disabled	def58135-f6f9-494c-b177-21c2d610717d	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	anonymous
4fc5fbbf-fcde-49fc-93bd-b0503761cbd0	Max Clients Limit	def58135-f6f9-494c-b177-21c2d610717d	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	anonymous
0fb9d275-584d-4742-a21c-e8d7137489bb	Allowed Protocol Mapper Types	def58135-f6f9-494c-b177-21c2d610717d	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	anonymous
d4677823-3091-4b01-b8c9-c6891543e1b4	Allowed Client Scopes	def58135-f6f9-494c-b177-21c2d610717d	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	anonymous
821b5599-c786-4dff-b727-d25f199816b7	Allowed Protocol Mapper Types	def58135-f6f9-494c-b177-21c2d610717d	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	authenticated
35e5a46f-879d-4617-bf04-3dbc8356c11d	Allowed Client Scopes	def58135-f6f9-494c-b177-21c2d610717d	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	def58135-f6f9-494c-b177-21c2d610717d	authenticated
f7c8a59d-b629-49e9-ac2a-6ecd4f7b37c3	rsa-generated	def58135-f6f9-494c-b177-21c2d610717d	rsa-generated	org.keycloak.keys.KeyProvider	def58135-f6f9-494c-b177-21c2d610717d	\N
492a9e89-ebfd-4c8c-8f8a-26bd2059da4e	rsa-enc-generated	def58135-f6f9-494c-b177-21c2d610717d	rsa-enc-generated	org.keycloak.keys.KeyProvider	def58135-f6f9-494c-b177-21c2d610717d	\N
ff0839ac-d570-4909-9742-4344cf50e895	hmac-generated	def58135-f6f9-494c-b177-21c2d610717d	hmac-generated	org.keycloak.keys.KeyProvider	def58135-f6f9-494c-b177-21c2d610717d	\N
da1b660d-3dd1-4cec-aaa4-54c4760cc13f	aes-generated	def58135-f6f9-494c-b177-21c2d610717d	aes-generated	org.keycloak.keys.KeyProvider	def58135-f6f9-494c-b177-21c2d610717d	\N
3baf88d6-d10f-4b40-87fb-f957ee70584e	rsa-generated	26848019-e2da-4775-a3ad-60ce8c6173f2	rsa-generated	org.keycloak.keys.KeyProvider	26848019-e2da-4775-a3ad-60ce8c6173f2	\N
7960579d-38e6-4e6b-81f5-7828036e8a0c	rsa-enc-generated	26848019-e2da-4775-a3ad-60ce8c6173f2	rsa-enc-generated	org.keycloak.keys.KeyProvider	26848019-e2da-4775-a3ad-60ce8c6173f2	\N
308c19a7-6181-4e2d-94a9-099914a6f5f1	hmac-generated	26848019-e2da-4775-a3ad-60ce8c6173f2	hmac-generated	org.keycloak.keys.KeyProvider	26848019-e2da-4775-a3ad-60ce8c6173f2	\N
7c12dec4-b483-48cc-b525-00830ee14b89	aes-generated	26848019-e2da-4775-a3ad-60ce8c6173f2	aes-generated	org.keycloak.keys.KeyProvider	26848019-e2da-4775-a3ad-60ce8c6173f2	\N
62d4b2c4-277e-401b-b51d-96dc3f11f0d8	Trusted Hosts	26848019-e2da-4775-a3ad-60ce8c6173f2	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	anonymous
499937f0-65be-4dad-b313-4025091ace40	Consent Required	26848019-e2da-4775-a3ad-60ce8c6173f2	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	anonymous
57ff3831-7a91-4e5a-81bc-e9af402e1aa8	Full Scope Disabled	26848019-e2da-4775-a3ad-60ce8c6173f2	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	anonymous
973fa527-e891-4735-aafe-85646ed66818	Max Clients Limit	26848019-e2da-4775-a3ad-60ce8c6173f2	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	anonymous
74002348-061e-4d07-b56b-34376972c994	Allowed Protocol Mapper Types	26848019-e2da-4775-a3ad-60ce8c6173f2	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	anonymous
bc57826c-46d3-4b88-aee8-a588ee723fa6	Allowed Client Scopes	26848019-e2da-4775-a3ad-60ce8c6173f2	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	anonymous
d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	Allowed Protocol Mapper Types	26848019-e2da-4775-a3ad-60ce8c6173f2	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	authenticated
39d23c3e-f9c0-40a4-b09e-9fdb305f42f5	Allowed Client Scopes	26848019-e2da-4775-a3ad-60ce8c6173f2	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	authenticated
\.


--
-- Data for Name: component_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.component_config (id, component_id, name, value) FROM stdin;
7096134a-3f51-4569-ad49-84b96acd2ff3	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	saml-user-attribute-mapper
6c65347a-2d86-4244-88b0-b336193ec62e	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
67e1803e-f43f-429d-8f7a-ffce87208ae0	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	saml-user-property-mapper
0362706b-d06e-4a6d-8a06-efb4aaae2471	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
39a811b0-5e09-40fd-8a27-9666935656d8	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
2da40dfe-f6a1-4d04-a441-9f340918ab0e	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	oidc-full-name-mapper
1240cabc-faf2-45b3-b178-bf0efebe75fc	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	oidc-address-mapper
236facd9-6400-4341-958e-b47bad1eb618	821b5599-c786-4dff-b727-d25f199816b7	allowed-protocol-mapper-types	saml-role-list-mapper
fe57bb41-f776-4fb8-adc8-a5a8a7206eb9	40178be8-2764-48f5-b3e4-09da48002fb1	client-uris-must-match	true
dbd0a211-f651-4699-b350-2822263358d4	40178be8-2764-48f5-b3e4-09da48002fb1	host-sending-registration-request-must-match	true
5803e585-4cb8-4b72-ae3b-98e15fbd13ee	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	saml-user-attribute-mapper
315f2a2f-72cf-4822-a30e-6ea6237bfa4d	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	oidc-full-name-mapper
15103ffb-696d-4d7d-8283-1549415a563a	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
21dbf5ee-ea39-4450-bee4-9f37249504b8	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	saml-role-list-mapper
885035f0-224e-466e-b108-ebaa8c0dc29c	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	oidc-address-mapper
8a0c5c6d-c13f-4903-8189-075cda249d39	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
e9ca9d63-fabb-4245-95f3-ea50ae499d19	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	saml-user-property-mapper
a56959da-1931-4a8c-a553-a70d7e87bcfa	0fb9d275-584d-4742-a21c-e8d7137489bb	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
39ac7244-e425-499f-8efa-a1672111b5a0	d4677823-3091-4b01-b8c9-c6891543e1b4	allow-default-scopes	true
9a319af1-ba78-44bb-9522-4b3521b2d7d4	4fc5fbbf-fcde-49fc-93bd-b0503761cbd0	max-clients	200
16c85d57-bb0c-45ac-b84f-edaf5cd311ab	35e5a46f-879d-4617-bf04-3dbc8356c11d	allow-default-scopes	true
511f599f-60f4-4f8a-bf52-459bd15ddc1b	ff0839ac-d570-4909-9742-4344cf50e895	kid	f02b7ce2-1d4d-4147-bbc4-6a21eb8d345c
be238da6-521a-4727-a304-1aaeaa809e14	ff0839ac-d570-4909-9742-4344cf50e895	algorithm	HS256
b9283551-c2e2-4137-8008-0e918231764d	ff0839ac-d570-4909-9742-4344cf50e895	priority	100
c48bfdc6-2f64-45a3-9207-5171d0fcc9cf	ff0839ac-d570-4909-9742-4344cf50e895	secret	0Skvfyn0Ag_ZtQWdfygqun2uCXmuhkVgAtTxG8fdFwnRyw3wj7IfaAGKtDa9uM5OCYPHw_iV9Wh1Yfi7xt4A8w
acf8de2c-14fc-4c8e-8150-bb096091ba5f	492a9e89-ebfd-4c8c-8f8a-26bd2059da4e	keyUse	ENC
1cfcc5e0-e186-4a9f-9b46-6cb07c755202	492a9e89-ebfd-4c8c-8f8a-26bd2059da4e	priority	100
57f0876c-30d8-4140-88c0-681be53368dd	492a9e89-ebfd-4c8c-8f8a-26bd2059da4e	algorithm	RSA-OAEP
01c31952-4b55-4326-ba01-c855da2ec124	492a9e89-ebfd-4c8c-8f8a-26bd2059da4e	privateKey	MIIEpQIBAAKCAQEAlzBldzJFOupQx0Ria3wK9CWB214NuLWxfLCJObuOhMUNT5YAFMJTzWaGWVH7FVjoso1s4qVqwKdhd1DJKZZQKzQxY601Uih+y0b3/LpmH7MzRCr//t9aeGlUuquiR8YYuITpO9/alKyH6H3C3nQnA+9TTKPwekR6gA1dsYdurXIRqbHeaQSgzP3fcRcrWwiKvZ0EahO97kTM+scatX9npL5x/p+lAgqT2nnpnyJB6NEuJcV2onpiLtItntXf28v/ovhtQX4YO/1yBKdKkIzI1nMMNfGIn354yFgm+8uUJ/MPQF3OOnPN8LbNaQE1/SpPQAQg9P2Nc0NAnBS0N8X7xQIDAQABAoIBACNMNog9aZnfblQTlGnVSEZnglmZrBjxfJpoqeUbc6LuUZUA54xxMTkNhHTSlc0OWKelKqSAq7uGaJQ/fXOy5w0rLpO/suj3UOD7NPcheqnQf/ncky9pbJkbuF8rpqPcrVVZHI3wzbqzzDg8slQW6Kv7wmYsiT62gaYnWLZTsQSXtwdn4jnEHbZ+qUp1gCOuHYtYeLdAehYQJHTkw/UvsXBpyODOubU//fiJVSV+mvNgfv08lycnNwyzFN70rS6OcfdsZbGaReyfrz5MoMqmqMiX3GxjKxGlayvwcH9bl/lyHT8EHIcvOL8cvoVRr1m844HO3O/3/YJ9q28cYVBRUfkCgYEAxpEHQMZZW5dKNNEhfHc7WtBIEhaZFTF1w4LjiZvE0BVVYrtnjzZyMeCkad63HSfFKD1aUhwmKkKXJRSJ7XK/9rpjhg4ZtqwdnRjTTflL9gnU+yn29YDt4tOhJWiDy4Tryzx4hkRgtv9KFXzSQT4h0k7oJw+a8cV6wagT7UA4WXkCgYEAwutGsvCrGnfSS+uGhxqs9HkwDaHBzYy5PofeIbNk5IfDwS5AzldFuhPpsMbm3ytXWWWasL/C1EkjBMqz4P0/+fhBw4i0gJEQiuxslypwPrUISvDjsx3jK3wucFGBG49p6wP8YLbbD+kOF8dfD0ITigKB+mAtPXhMg8aAXuMhba0CgYEAjArK7780VGl+F4QLNuosfV76BW/UpWLNqIcOjQXEJ/Fz1/9OCW4f2deSfWxq/vAGl9u1cMWTkSiHysoSgNn2Uz+fY3NcZT48YIiatpqFHVBP2pf9Kaa1n80cEPMGSKpFVoAejKt6/nVMPZ1b+FGmrtmh17Kk17EsY5pz+1bYpxkCgYEAnztYvCGDhdHQyBiWA5S1Kdo+eURlcCe/xOd1fY5xo4eNUSkZ4/bDjWlrBPDX9gQQDYXFQxLEdGty4h09qVT5iJlYEAaDfmwDWZoec7dFjtSQ+7eiK9cEl6eQwEy07fDQlB7jc5atimfXDXHfpDVUhO/bgtBC5O57g0ML53gg/NkCgYEAxiCGnAQumfbBJF8b+OX3n030OS+W4mHznf3OPArx0eoEkR/gWFqf6+og+0NSL46k4O+XGvutgN2bNdNSEQ7cXUXBgTjEpPtAnEzM6+NSghjfPzvdhGwgf9YxvBlfrxpLY2/j6aZ5eaEUd5pB0gtF3yIXlJPG2w3JXJZY4ULIoAs=
1ea83321-cf19-4a70-92ca-24a5d48131b0	492a9e89-ebfd-4c8c-8f8a-26bd2059da4e	certificate	MIICmzCCAYMCBgGNmqRANjANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjQwMjEyMDAwNjEyWhcNMzQwMjEyMDAwNzUyWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCXMGV3MkU66lDHRGJrfAr0JYHbXg24tbF8sIk5u46ExQ1PlgAUwlPNZoZZUfsVWOiyjWzipWrAp2F3UMkpllArNDFjrTVSKH7LRvf8umYfszNEKv/+31p4aVS6q6JHxhi4hOk739qUrIfofcLedCcD71NMo/B6RHqADV2xh26tchGpsd5pBKDM/d9xFytbCIq9nQRqE73uRMz6xxq1f2ekvnH+n6UCCpPaeemfIkHo0S4lxXaiemIu0i2e1d/by/+i+G1Bfhg7/XIEp0qQjMjWcww18YiffnjIWCb7y5Qn8w9AXc46c83wts1pATX9Kk9ABCD0/Y1zQ0CcFLQ3xfvFAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAFe6LTcwMrrvVNHlMbAAdDReDTGnNYVWLNho6W5IiqEKSjs071/ZV2YvS2fIu3ABHdN8jTsuo2X/5rpSEMzTF1sOe5gk9/LQfkjMbH9TV1b5vXeuXC0NuD8FEfTfjIBJuobZM+cIyl2ZSHCk7iZtNg0v7IsfLZ8+8Lj2cPG6IVopiDlNPhW9VQFFNr0Xocpixo1+Pcb7GX/TCC99ApA4SVy62osGNMrS59Z3BLD1R5SXiZ/xXVY9YK6Hffiab/2Ukla1IZEsI0Ki8x7XVj70tU3sWH8ivlzaERSS3LqH3xnN8+WwChdlNXb7SbTgoJqdXMUG4smccjwABypbJihiqeE=
ad4dbb15-b262-4e52-84a7-e16efd510b42	da1b660d-3dd1-4cec-aaa4-54c4760cc13f	priority	100
b22554ae-4510-4339-a31f-e8cdd1a15f1e	da1b660d-3dd1-4cec-aaa4-54c4760cc13f	kid	18178916-0a2d-4206-8a1b-da590d4e7a72
71205739-08d1-4bd2-9d96-8b4d67c72b57	da1b660d-3dd1-4cec-aaa4-54c4760cc13f	secret	4WBsDiiJa3tN_S-XI1qXSQ
c19a30a8-2c11-40e1-8030-cb76796ea53d	f7c8a59d-b629-49e9-ac2a-6ecd4f7b37c3	privateKey	MIIEowIBAAKCAQEAspnoOfcNby5uhejs07PmAjkMTOozXy9KuqweuAU2BOdQ28/ezB2PBgIT8hAWx2wVKt+WUArcrcSIyhU1vvCdd63Cgal7fuhPnfuWwPT9KkoLx0qRrwbkoxuBqZXmE36NE0/11KdlFfvhVchR8CnxlYtnllXN3Z9x3E0akmP2PbVshZwPLlCvzTKGGDcyLErNM7qKOlLbiIBnMfE+eiMaHMmpEa68OrTIdVZbMLenU1qKeExotKrnMDZxvFGxoOxtu9R61+LkZHnth/Pc/k8ig1N7O1gHCoEuVpFHJfO1HXjV1E94+koPiUOHAXzNt5JBakubQPopNpsKnxd+09UqqwIDAQABAoIBAD5txdrdHHkMhd2Q+ZdWfsOwJTiNdL+EzF5L48D3MVatdHohQwOeIWw8NbSbIxs6EHwYA3afFVw4IohguZSwjppSxnaEQ4KsuYfDdYKlIAk0MMHMsve3NRw+dShOGUofJjjl7kwS5ya0EKPnjZyhTKy1OdQ20erx3N7gpLUe8+fFeT28XiGi84FvFEhouHBmWMNxH15aNzE1Gtn02m99ylJ3RiWCD51LaGB7dp9+dcJadLghxvg9E2AGjfG9VnOjxLZuk6quaAXdWs1YHUIEyhkpMDQXMFeBSLJnvsi3JzzkAtsM/rqFEQVQaN53atmsbBjG6KgS+QzgJ+2RQ8fFseECgYEA3hYhCI5nGey2IfIPtgFhaIHEJWUY1pbRV1Auy84CSBsw/0T9q8VgRAy+eMbRkefv3TPZX01sJbBUML7xkdEOMUGIu4jHBMSQv3jnJ88GDvT/UxIoVk7YONB/vJJnaY3MvTxrTDKbWw06jqp+9kPZFmmM+HK24OvOV/epcdjoG80CgYEAzd/W+fO2v4iTZI6bsmvrezRJxg/9ej6npB6OO7tHd05UTy7OmUs7sJLtLtz9lQfSTZRNJAW1QuUyyEATo7ZdLo0fbPThSR1qIi7YBXzc2uYKBzPJgAYoWnYEHiwiT4oA8MaPcpAfOK6evLjLDA1pcnc2U/cfjdkRZMQ0JgA6mFcCgYBy9Xl7+FqeLM3KnIZNbEGD20gxIzfMPJ14WOUgUi8ULB8cxBWbSLwf/YjK8/+fSzP6iNBIaMdGaxPpd62MEW8LSCUDDjYW3bkfo/HjxWIZc/CGi6udoYqDPkogzpgBJ4mHmzLfaoLIivx4xQCbcVt6IoD6Skcn/mf9WRG5ANKFMQKBgE7d2yrxtCZ3mY9CGl8lfJY8F67qXT5BVlNG6VH0kpIfzahv0/FhosIn5vi26+X1kxjpIQwVq7SuvN99vIhQyi2VHl7NCKjLvebOby7bAHhS+7B6pEyJD1hoMXeljJdP1MBoMHfAwlUif+joGdDKKoURKhzMZKggactiZl/QYqINAoGBANRreoQO7uLSNaTK0K2kD7TbD9eyz/FCGrIDf+tuTlN6JaH1tv9Cmk3NWoMg/Oih/rJPyV+3e27zrXe/gq31XqakNH0OhFw1Id0k0Cd1esZkD7H2/sl5tPXq8pCsJhsDwN+yxUf+0T7gwSiPDhFnQg6geMeT+oxyAhfpxtMROWpN
745aba11-dbe0-40c1-90bd-57de21faa9b6	f7c8a59d-b629-49e9-ac2a-6ecd4f7b37c3	priority	100
153be63f-286e-4c06-b709-241f5159b2f3	f7c8a59d-b629-49e9-ac2a-6ecd4f7b37c3	certificate	MIICmzCCAYMCBgGNmqQ+vjANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjQwMjEyMDAwNjExWhcNMzQwMjEyMDAwNzUxWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCymeg59w1vLm6F6OzTs+YCOQxM6jNfL0q6rB64BTYE51Dbz97MHY8GAhPyEBbHbBUq35ZQCtytxIjKFTW+8J13rcKBqXt+6E+d+5bA9P0qSgvHSpGvBuSjG4GpleYTfo0TT/XUp2UV++FVyFHwKfGVi2eWVc3dn3HcTRqSY/Y9tWyFnA8uUK/NMoYYNzIsSs0zuoo6UtuIgGcx8T56IxocyakRrrw6tMh1Vlswt6dTWop4TGi0qucwNnG8UbGg7G271HrX4uRkee2H89z+TyKDU3s7WAcKgS5WkUcl87UdeNXUT3j6Sg+JQ4cBfM23kkFqS5tA+ik2mwqfF37T1SqrAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAFmiIXEjHw31RLICF2jaBTVkNl9qqzgAOIeyfE/T6i2t97S+/sN4cl4EWd2KM+jzKZffFFPYQGE0W3Cp7rrwxHx2Ps3yeYOXm4fVt9s5iBWabT6RFDSROhlotwTtU2bbxQ1S6L7LmpH1uEi05s0tCW6cVsEiOxmteWvwLw7crDzMMp1GcIVtvIq0y2BL3rM9psdBP6f4h4IsdQiarNKOgvEXDL8cvUKP9MAUXQjWHWCBrKLxJSIj7ls4CwXyY44m+ei8zwyPf/17eHlv+uMmJNcIhShbGKuYBygfeDPNCxA+cPRO9vKRtbLcQxih2MmWegdTIwC0gXnZk28nPd2/lVw=
9f8f0ec4-cf6f-48c9-a709-d5916af09e12	f7c8a59d-b629-49e9-ac2a-6ecd4f7b37c3	keyUse	SIG
5eb65c9a-3059-40a0-999d-9c7972ff87d5	3baf88d6-d10f-4b40-87fb-f957ee70584e	priority	100
0c241117-05bb-4475-9a6a-638578580f52	3baf88d6-d10f-4b40-87fb-f957ee70584e	keyUse	SIG
0b06e879-6e2a-4c9c-b1bc-df64450ac94a	3baf88d6-d10f-4b40-87fb-f957ee70584e	privateKey	MIIEogIBAAKCAQEA6AMl42mLITdC2UZQP72XI0YGPEMuD6hKlsNIthtnsDKqltDrHd4bsYn/QBdmbFsEyK9761pdOAnW+3Bc8GhlKO10l59HwjgSWeedZwhUa4uVQvVnwIvNU8IcNWMSJ/8cLfpUzJULR0OSx5msBN+2qBXUUiq6bdUve54ChDwMaxsU2yUOwTcm8A9J5eGxsxowi9CGUMsxeggFIm4XBAc3kIwvUziggIuO9pe/S+Z/Jt90pqGhjMQ8nsLOyfX2d14GNTbBeptrvYoubHSBXh5IzHubxvx3Z+55daJUyCrcuz8xp85A9JAxC04X9/4/OyAjxSmVcn/PsCG4Cm7kAIxFJwIDAQABAoIBAAGK+uANR5H93CVMdNE4o14igblnGp0iv22llrGrGKJPCZgz+9HvND/THf0i1BzktVqr1FB9AYb8wcOl8P7eots6pMnJzzMerlatqN3HTf2Xc4KZITBEMnGJJkb9yX55xiB+gBcoqwy1gglB41v2ldX2ygXKkS+jzA83RfZOGZIZstIQ/3jS8hvAFI4QA1n0f+yx2M8dm4iPBBPynPr/Tw2EwelIkncRxLvyN/V2vj9KjR17J9Mgyy5XIs4n+OuKBVP01mgRmJZN8EUDj5tYc70t8wWBkpMAu4VjNiDHvJ4MKjz86csQsKQplgfYaTh1UScyjWn0GsAdS+wWcWqRkZECgYEA+YRfXg9dHDuNy/3VmquFdaayPS6o9suJjfw1TtA4ActL1o8E9QKiJjxGhe9WPddV5SfHGwYKEODXlxiWHm/AklD+QbQw0HiAaJ8fQ4eWApHz6jbjp67TPGAFQr+K8ZMs97+x7Mz9T9Bi3Rw/Sy2QMvtORtx93oIDrLMKrUXZkt8CgYEA7gpYSqCbQ9OG4B/lY8ohXFBmaXZEMXZMwBxzvIKyHzSWaBVtaqypkVJpMLPhT/mwXcFhjNIsHc67hL8Msz3ltgna2xVeF+Pg58K4oVXS7Wcuq/lo5EE8cmXLYQaYq721QAlLuaXs0d8vvOcYnPQgddv2YfL+utar9vi1zq9FHrkCgYBCKamoJWbJL7l/2AUmCElRUyx8ML05A+urrK7uASR4xVGMyUvFNDeO7/i7VyWFLG5oX03aipVsuFIyjKBx3awwoC1rer5e6TUTiO4fV/qdH9qPxpJDSoZUwhljA6tyN1Z7M2eYpRqeaWFtxCm8Y46TFjRBcgImWE9lIey42YbB/QKBgBsLhdiEwt9D6zEPrqpVztCEOf6Fd13/SN0S3ntuhfpRqT0OIi5ai7F9IYJtDY5emhEs5X5wap7AXEHKyxCaWb0DBaCanuQr+eObFgsOizZ54K2dWrOETe/ZbPALJdFtbmhmJfpjxbJanzvhLcS3X/DEGwwp5ZMozMT0oQNomnvRAoGATg7ik6HjMuI3yzEhK9v+oip1aNNo8Q7lE4PjlpkQKBRB7Dl8lj9xg0Q4Hsvt0TjLaUvbcZl53UHAv+bsTMO6McROvaS5KLbqKgiwt5XeGvhKn1Z6HL7RRc7FK6zGRQMYxAeGHHXpKrKPuY5PSECBrmgz+8IPMA025Mt9lWcQjAQ=
3b3794d6-01d9-47d5-acc8-24c567037f7f	3baf88d6-d10f-4b40-87fb-f957ee70584e	certificate	MIICozCCAYsCBgGNmqTksTANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDAptYXNrYW55b25lMB4XDTI0MDIxMjAwMDY1NFoXDTM0MDIxMjAwMDgzNFowFTETMBEGA1UEAwwKbWFza2FueW9uZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOgDJeNpiyE3QtlGUD+9lyNGBjxDLg+oSpbDSLYbZ7AyqpbQ6x3eG7GJ/0AXZmxbBMive+taXTgJ1vtwXPBoZSjtdJefR8I4ElnnnWcIVGuLlUL1Z8CLzVPCHDVjEif/HC36VMyVC0dDkseZrATftqgV1FIqum3VL3ueAoQ8DGsbFNslDsE3JvAPSeXhsbMaMIvQhlDLMXoIBSJuFwQHN5CML1M4oICLjvaXv0vmfybfdKahoYzEPJ7Czsn19ndeBjU2wXqba72KLmx0gV4eSMx7m8b8d2fueXWiVMgq3Ls/MafOQPSQMQtOF/f+PzsgI8UplXJ/z7AhuApu5ACMRScCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAv1P3UmcvlnoqLHqjw3t82MP6Ety/+6aNpRI22K8FSAGjlC8C5hqDPsguOwmGtWHSM/TE751xdEdMB3wJ9OFYGf1wV0cjN5AgkaaR9FxPFZVBiRdQS9SZ/vaxkZvE9hlnX7XnQ2XD099HUnmQSshHYTSCnahLFoFHulHfQgZ2BcppNc0eBR5vxE4OT8QBega/oLXU1we1lUGc0iqEh/IIhZsEgps0OX3KKMgfT1AxXDwGQdp1bCvyIETsnL4iRHGDp8eCjtEt5JRqkeF4KdlqmiTBzcYN0k2xI32v5Xlzv/xg+cOGTEsDIEapOnOHMWIXFX6PDBLTSya8IZ+rOa5D3A==
e34c512e-aec8-4c9c-958c-3187981d3cf6	7960579d-38e6-4e6b-81f5-7828036e8a0c	priority	100
1b59c964-59f2-4292-81b0-91080db8b433	7960579d-38e6-4e6b-81f5-7828036e8a0c	algorithm	RSA-OAEP
7e74260b-4e84-4421-8e23-d178c778d5f9	7960579d-38e6-4e6b-81f5-7828036e8a0c	certificate	MIICozCCAYsCBgGNmqTk4jANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDAptYXNrYW55b25lMB4XDTI0MDIxMjAwMDY1NFoXDTM0MDIxMjAwMDgzNFowFTETMBEGA1UEAwwKbWFza2FueW9uZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMouGHERsu6OG9kbkIA6suaW7INaNwPEsDJP+bzVRk1yjMQxxuN2m/4XDB/4HwesACxQcetHqgiQAFBiIUEANBUw7JglfKo4DMQp0wRdc8k1IXXlhj2hiJDcS5qxTkHnaR8spnjSsWJbsULu5SFwBS4Oc6gf2Q9INU3DPiTtUkqyvA1r6AWmhZqKIs6gx1KQFxUFgwRbeUYVEBfdWDAifeUnThasIEo0g30XgOLGh9fNSpN9Tv9Hwex6fZERpVKo98na8yp618A+mrhwYoiF0E+HpIfjZ5xpd3C2sO9YlGnO1tOG2CbbTESTqrlP/5+18uY6TDu5YwICRsnus4t9/kECAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAGRZLKQi8BY1pX5fgyxeimIS7Dc6T/lilrY1aeFfv2EncIJxldWwg3pf4D+Z1Ikr9pfQzHhdBdTBIhkAuZfb4r3YU2vQb94h1lEEi/Rw500RMjabJAo1Ky1fPTZx7Wn/sNMQ6N5yaNQqXUo0D5Mt9XI4nEgtqgh1iiim9PA2AQKMHtAwuUIjjpTk0M1rVCMHbBa+HrQds5ow6x8SA8ZmvKKNRgonIJOFlouYYNa74gfn5XTphXWbPmhbfVb6Npx+PUEyoqIzDPx3js965xVpKnkpkhKLmSdp8Dzzk2/Xibjk7cwyA+po2Q08EgPhgf6qh6cjuHi6H5T/3ZBcu/2oADg==
8d921ba0-cc26-4cbe-b5ec-2c7a407ebb4e	7960579d-38e6-4e6b-81f5-7828036e8a0c	keyUse	ENC
a9e00501-3705-477c-baa6-bce92d10a34a	7960579d-38e6-4e6b-81f5-7828036e8a0c	privateKey	MIIEpAIBAAKCAQEAyi4YcRGy7o4b2RuQgDqy5pbsg1o3A8SwMk/5vNVGTXKMxDHG43ab/hcMH/gfB6wALFBx60eqCJAAUGIhQQA0FTDsmCV8qjgMxCnTBF1zyTUhdeWGPaGIkNxLmrFOQedpHyymeNKxYluxQu7lIXAFLg5zqB/ZD0g1TcM+JO1SSrK8DWvoBaaFmooizqDHUpAXFQWDBFt5RhUQF91YMCJ95SdOFqwgSjSDfReA4saH181Kk31O/0fB7Hp9kRGlUqj3ydrzKnrXwD6auHBiiIXQT4ekh+NnnGl3cLaw71iUac7W04bYJttMRJOquU//n7Xy5jpMO7ljAgJGye6zi33+QQIDAQABAoIBAADVO8iLeB8/eqHkWS4OD9qfWI4Z+wwK7WbnqXG7tzRuemH8ioM5Y98iHSysiwQvEzkbg7yiaPLsFPQ/0z8/TvefYfomfWL+JB9SxMnJ0MZNb7vanDj4x2VBYxZaEKZ425gDSRRKWey7z/kkntEKcxsDeDqDFxPXClEtsr3YNHSWUgvycikVj6O3l6BVe8AxPhgn6d20r2Zjl3jZvGSiUyUulqM9U4gzMORwZTJt170LxAZl7lOhEHfvL1foJTpsfTSUrK1C/ru1NsQ2rbz+7APGJRxPl/qQ4hI6Iz8tXMJayrgavgFo8MUaxTSSnnfVprkQYo/HbSkEQ80qfvQ2kzkCgYEA6cdfW+DUzBESjsJ6y2++nnjgVTxK0GIMxR98rJ5I9pKTyrzgQ14/5a1V/hRDKVJQzBnOxl8drliBSYr0P1uu5rzURL/sD4p6y5GMbUAr3Lp81LvXGSn7GFvlLI+0Nn1RnKIVSVpwbPVnAAbF3ZgDutG9A3AW/xfQZrS7NyxraT8CgYEA3WXRqQijhwV0aICqpPa8VwwE68WlazDXHu+lp20jsYI8dFfvKTkEpb9dWjPtZykJs2qNnAFz8H9xWs+bX7x1rW3Z38fJknJ/F8EEPaaKTAxbg4NSMdnpBsyPpUKevQHGKixD8UL8t3G+Y0LTGgPKV6OOtLqUOca11yQW7XoROH8CgYEAq+vXEPZzB++2Og6Dx4BSKrCyKXzBeCXjRkQ1p6xv9AUvcvUb5+80BnBGwSedjJHgoXiJPBFO/pxP2Am8PavrH/zWDgkmTPeF/pb3MpDysMzkaH4LXZIl+m/6RZ8Y5Mmcbxgzl1JPQ5HlQXu5n5DfjVAZNKIGB2s385AN7jFYfHkCgYEApp0Bc1v09J++QwbRZOPqSPfanDRZkJloyvc+iwkvW17PcB7c9QDb5oBlGIULnB7eFg+SEl1liw/dlqG2JA4H4URSOn53y6YuzwmKz3qNiT2jgQ1KxglfvKYlVBEWtNao8wPs/ZuT49nNlZWsmF9R3zJPKuNeuTw5jHa0anL6krECgYBdwxBGtGLKC96r0xc+5XimBizDKPsJbnwuA+qq9ldFEgAozDzzwg6bUdS9nArhJ/yfHVRkG2UJ30BLII7qQ/EbcUTA1DX5SaTnfr0oBbJBU2o9v/cUJ7AwCQfNVxuZigdV5CdrjUEV6xyrXd4/96D9rzrBkMn0M+eRxM7dK+bquA==
35c9f0c9-5f3d-4bc0-86e6-aaeb0b9bbf58	7c12dec4-b483-48cc-b525-00830ee14b89	priority	100
16d45740-b1b5-41df-82dc-2b66036f7fb8	7c12dec4-b483-48cc-b525-00830ee14b89	kid	0aef80af-27d7-4a35-8f0f-8d524a672659
c97e86c4-e115-46a9-b6a6-cbcb405d72f4	7c12dec4-b483-48cc-b525-00830ee14b89	secret	bEXRZOPO13nLXun3aEQpCw
567ebc4a-4120-4bd7-b464-c4218997a7c2	308c19a7-6181-4e2d-94a9-099914a6f5f1	priority	100
7ad640fe-dca1-4fb2-bf9a-3aac5ef289a7	308c19a7-6181-4e2d-94a9-099914a6f5f1	kid	56f13b06-68fb-4a35-9afd-331dfea1031f
22eab2eb-b782-4888-a8be-d867b02c5907	308c19a7-6181-4e2d-94a9-099914a6f5f1	secret	EO2Mv9XQVFHa5U1DbNr4dFlJT2AzgDOK5e1EBdxpTFSPJaiRf5AMALbxEXWxff9i_3cjEnYyEPpnzSZWlep2qw
9790b734-5ee6-4318-b8cd-9f442980f15c	308c19a7-6181-4e2d-94a9-099914a6f5f1	algorithm	HS256
3871b137-33fb-4589-860a-e657c4865292	62d4b2c4-277e-401b-b51d-96dc3f11f0d8	client-uris-must-match	true
36db9870-74b7-4dfd-86b4-1242cd0d6f7c	62d4b2c4-277e-401b-b51d-96dc3f11f0d8	host-sending-registration-request-must-match	true
626ce2c6-d233-4f32-a4f4-3e646becb7a9	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	saml-user-property-mapper
0fdd01aa-f527-4df4-a10f-4618e8029198	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	saml-user-attribute-mapper
8e11760d-74fe-4655-870a-fa3db5202e16	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	oidc-full-name-mapper
80fe98aa-d02a-47c5-b2ad-f869f6496483	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
6ba9ec20-571c-4d16-8abf-9f461cedc849	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	saml-role-list-mapper
b72446e1-635a-452a-b751-14c3ab5b5797	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
d2053eee-8720-4a8c-a1ba-c11aa867227a	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
4c319e40-baf5-4c02-8ea4-60c0ee8b168c	74002348-061e-4d07-b56b-34376972c994	allowed-protocol-mapper-types	oidc-address-mapper
06a0840f-c050-45c0-b974-795404debf52	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	saml-user-attribute-mapper
00c88524-56b3-43c0-89e2-38cf1a5c7cbe	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
6ff7b331-bbeb-4174-821f-f07ac1c10189	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	saml-role-list-mapper
0a0bba3c-93d0-4495-9a62-2b615d3a2b0f	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	saml-user-property-mapper
627f7bb7-b9a9-4d0a-b5db-15a7d4136a0e	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
95f00518-d665-4b03-90f6-cc4794870c24	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	oidc-full-name-mapper
f96ca142-05d3-45ea-8997-93b10362a025	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	oidc-address-mapper
1f3f1b78-4b82-4b59-87e1-be93c4f22e55	d53cb0a9-e298-4fe7-983b-ebfe9a0dc978	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
5f88e9ac-f749-4e03-9903-e9fae2527706	973fa527-e891-4735-aafe-85646ed66818	max-clients	200
4f3b938f-24e2-4e53-9ce3-b14c0e6c317b	bc57826c-46d3-4b88-aee8-a588ee723fa6	allow-default-scopes	true
adb5ccc6-8e8f-49d2-98db-8c9d1458bdc3	39d23c3e-f9c0-40a4-b09e-9fdb305f42f5	allow-default-scopes	true
\.


--
-- Data for Name: composite_role; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.composite_role (composite, child_role) FROM stdin;
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	e33dc421-3182-47a3-9cbe-15e5cf2f149c
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	428ebcbf-687b-46c7-a7cc-9d736fd75238
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	9ebae38d-57bb-4be9-b394-f893fd407b5c
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	de070575-4361-40db-98a6-37860fc1aeb8
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	e6f7c314-bd97-467a-a749-9d7b27e417c9
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	137613d8-2178-4dc7-a769-9c2e21449487
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	d1ca75ba-b7c2-4690-a89e-f0bd39e28d58
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	4242e742-7fbd-41da-97bc-a7431cc320c6
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	f894574c-dd32-458d-b96c-99cec4b045c7
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	f48f8f81-d7a7-44bf-8418-bf7261cbce49
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	3c7694ab-745d-4e8f-8ad1-277920794dfe
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	f3488a7f-8df9-4a56-a93f-87fe9275c341
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	3a747c69-56af-461b-9cb3-658d7eb8991a
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	5b8502a1-f8c9-429b-89bf-45c3186f0b42
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	c90b782c-9351-4b86-8ce9-4212e9cc1911
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	3eee5771-8205-4e6e-b346-d9c554201831
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	420c4417-2571-4203-857f-f73e2d144827
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	60ddf613-d4ca-4b51-a32e-b478645d1ac6
473daa87-403d-43d2-a630-f2bed71ec503	5191e000-d6d5-41a4-8771-9156016fccde
de070575-4361-40db-98a6-37860fc1aeb8	c90b782c-9351-4b86-8ce9-4212e9cc1911
de070575-4361-40db-98a6-37860fc1aeb8	60ddf613-d4ca-4b51-a32e-b478645d1ac6
e6f7c314-bd97-467a-a749-9d7b27e417c9	3eee5771-8205-4e6e-b346-d9c554201831
473daa87-403d-43d2-a630-f2bed71ec503	c0a795a3-9e5e-4f86-be82-03a5cc344d98
c0a795a3-9e5e-4f86-be82-03a5cc344d98	5fc9e81f-1e93-4a6c-944d-a407a37ed781
9c8ea9e6-d8da-40a7-b449-05456fa5389c	1d551609-99f6-4c92-ae68-a23d6b918b73
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	e8bb0c02-7d75-4d8d-b76f-cbbe828b42ab
473daa87-403d-43d2-a630-f2bed71ec503	ad4dfb7c-bb2a-4bcb-b60d-461f1ecc1d64
473daa87-403d-43d2-a630-f2bed71ec503	512295cb-cd34-4aed-8c21-4991ea085301
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	60f6a924-36be-42f0-8354-5eca6466b15d
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	47a67318-5e33-47d4-be51-07ef9afea16f
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	1c56f3d3-a3f1-4d6a-a65a-e09d453a62c1
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	5a4f2979-5e2d-4344-a5e2-780bf31b0764
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	0c73944f-fbab-4fa3-888e-70ff3ea4de56
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	1f4c5eae-fa50-498f-9178-c19a11ca9647
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	5bc7f09b-dcdf-45dd-988c-8dcb7193e349
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	66f8a6f9-3a6c-49b3-a721-480d710377c5
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	2959b426-1990-4ebf-a4eb-2368f8e4418d
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	ed55f9f5-4ea7-471e-981a-f552d92efcc3
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	9f70bfe2-719a-4526-9d75-4de322b8c14e
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	29b70a3e-4253-4cb3-a265-7248c2515cee
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	d911c5b5-5112-4bd4-b202-e67af7afdd09
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	0b2b0fc3-e662-493d-b82a-c542cc0dee92
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	840720f3-47e0-4590-9256-dfd3241aea63
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	429ebaa9-4519-4d8c-8e17-dc8823e4e4c9
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	0010befa-9e09-47d1-9d75-75a873d23a57
1c56f3d3-a3f1-4d6a-a65a-e09d453a62c1	0010befa-9e09-47d1-9d75-75a873d23a57
1c56f3d3-a3f1-4d6a-a65a-e09d453a62c1	0b2b0fc3-e662-493d-b82a-c542cc0dee92
5a4f2979-5e2d-4344-a5e2-780bf31b0764	840720f3-47e0-4590-9256-dfd3241aea63
a941d83e-8bc2-4c12-808c-d32e83a1e222	beb5c60e-c132-4f7e-adc6-c5e48a8ee11d
a941d83e-8bc2-4c12-808c-d32e83a1e222	e0fd44da-29b7-4087-b6e5-33bd3a4a7c24
a941d83e-8bc2-4c12-808c-d32e83a1e222	ce0fe192-4fa1-4712-bf83-ebf4d611f9ee
a941d83e-8bc2-4c12-808c-d32e83a1e222	e134f723-8940-4730-96e4-3089b1bba380
a941d83e-8bc2-4c12-808c-d32e83a1e222	8fbe606a-bded-45d1-b685-dbb1c532eebe
a941d83e-8bc2-4c12-808c-d32e83a1e222	0d15c5a7-bce8-4f91-bf68-7ebc792565a7
a941d83e-8bc2-4c12-808c-d32e83a1e222	6a0ca684-33d1-49bb-9a18-c6d3378000a1
a941d83e-8bc2-4c12-808c-d32e83a1e222	ba6e8b36-7847-4182-a571-ab4ddc6044ff
a941d83e-8bc2-4c12-808c-d32e83a1e222	c453fe8f-9c6a-49da-848a-6d726d0753e9
a941d83e-8bc2-4c12-808c-d32e83a1e222	8984a950-6e21-4578-b9db-5845099b142e
a941d83e-8bc2-4c12-808c-d32e83a1e222	bf95a241-6885-4e05-a883-4bd6272e221b
a941d83e-8bc2-4c12-808c-d32e83a1e222	67b43d87-d43c-49c2-b486-dee77d5d4e40
a941d83e-8bc2-4c12-808c-d32e83a1e222	fa72d8dd-a6fd-4cb8-b61f-38c79ef56f97
a941d83e-8bc2-4c12-808c-d32e83a1e222	eb7821e6-aae1-4b87-a109-311b9c267052
a941d83e-8bc2-4c12-808c-d32e83a1e222	2e687305-714b-42f9-823d-7d107381ca7a
a941d83e-8bc2-4c12-808c-d32e83a1e222	7f090d09-9c08-483a-a045-dfb4583b45d4
a941d83e-8bc2-4c12-808c-d32e83a1e222	5ff35e6b-5772-4c1e-9fd0-0ce7d98e1285
16d47a9d-16a5-4aab-bf57-945c2e783eba	c6a1f777-41bb-41c0-bcf5-15757d27342e
ce0fe192-4fa1-4712-bf83-ebf4d611f9ee	eb7821e6-aae1-4b87-a109-311b9c267052
ce0fe192-4fa1-4712-bf83-ebf4d611f9ee	5ff35e6b-5772-4c1e-9fd0-0ce7d98e1285
e134f723-8940-4730-96e4-3089b1bba380	2e687305-714b-42f9-823d-7d107381ca7a
16d47a9d-16a5-4aab-bf57-945c2e783eba	89fa0898-18c7-4db3-bd95-aebe022a2c37
89fa0898-18c7-4db3-bd95-aebe022a2c37	087a5da2-f68c-4224-a9db-19b7cdfef1a3
bd18407f-8b83-4232-806f-240d05b51127	fa3e3883-eced-4746-9c6b-e0195f4d98fc
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	7d73286d-9cac-471c-a322-28ea87660fde
a941d83e-8bc2-4c12-808c-d32e83a1e222	e0fdc6c4-d8b8-44b6-a094-9985563e8941
16d47a9d-16a5-4aab-bf57-945c2e783eba	c4d5cdda-04b9-4597-a8a1-1732007044e7
16d47a9d-16a5-4aab-bf57-945c2e783eba	d898abd2-0442-48a0-9013-6988bef64f2e
\.


--
-- Data for Name: credential; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.credential (id, salt, type, user_id, created_date, user_label, secret_data, credential_data, priority) FROM stdin;
5af79b6d-35bb-4900-800a-61cb7885969f	\N	password	bf5e8280-f52c-42e3-a5e3-39484efc69c7	1707696472617	\N	{"value":"gHniLWvKQgdfBbhJPRjqGlA0BNGAy3Sf0FueRIP1qlY=","salt":"g9wUU+EYP/MjtyD7VA7Ynw==","additionalParameters":{}}	{"hashIterations":27500,"algorithm":"pbkdf2-sha256","additionalParameters":{}}	10
b139c998-ce7d-462a-b0f1-039f0c4283ec	\N	password	20a691bf-a2bd-44bc-9049-0d7955b176e0	1707696685075	My password	{"value":"FbltSq66NRjdUXRFx5wRem4j7HBD8hH0ah6++zQDlFQ=","salt":"UlfjC8/j/U8BIrgHGN2lcQ==","additionalParameters":{}}	{"hashIterations":27500,"algorithm":"pbkdf2-sha256","additionalParameters":{}}	10
0d706877-5714-4e09-845e-0157bbe0415f	\N	password	3b8fe421-f59a-498e-92ad-a5a15567c4d5	1707696696737	My password	{"value":"SL5rOTsz0zrxU70axuoyxs8PjiRgdPSZgV/IKSXIuw4=","salt":"2sCD9brdG9DPNQpc6Us8uQ==","additionalParameters":{}}	{"hashIterations":27500,"algorithm":"pbkdf2-sha256","additionalParameters":{}}	10
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/jpa-changelog-1.0.0.Final.xml	2024-02-12 00:07:47.273297	1	EXECUTED	9:6f1016664e21e16d26517a4418f5e3df	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.23.2	\N	\N	7696466462
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/db2-jpa-changelog-1.0.0.Final.xml	2024-02-12 00:07:47.312318	2	MARK_RAN	9:828775b1596a07d1200ba1d49e5e3941	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.23.2	\N	\N	7696466462
1.1.0.Beta1	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Beta1.xml	2024-02-12 00:07:47.363339	3	EXECUTED	9:5f090e44a7d595883c1fb61f4b41fd38	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=CLIENT_ATTRIBUTES; createTable tableName=CLIENT_SESSION_NOTE; createTable tableName=APP_NODE_REGISTRATIONS; addColumn table...		\N	4.23.2	\N	\N	7696466462
1.1.0.Final	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Final.xml	2024-02-12 00:07:47.36975	4	EXECUTED	9:c07e577387a3d2c04d1adc9aaad8730e	renameColumn newColumnName=EVENT_TIME, oldColumnName=TIME, tableName=EVENT_ENTITY		\N	4.23.2	\N	\N	7696466462
1.2.0.Beta1	psilva@redhat.com	META-INF/jpa-changelog-1.2.0.Beta1.xml	2024-02-12 00:07:47.557824	5	EXECUTED	9:b68ce996c655922dbcd2fe6b6ae72686	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.23.2	\N	\N	7696466462
1.2.0.Beta1	psilva@redhat.com	META-INF/db2-jpa-changelog-1.2.0.Beta1.xml	2024-02-12 00:07:47.573114	6	MARK_RAN	9:543b5c9989f024fe35c6f6c5a97de88e	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.23.2	\N	\N	7696466462
1.2.0.RC1	bburke@redhat.com	META-INF/jpa-changelog-1.2.0.CR1.xml	2024-02-12 00:07:47.697222	7	EXECUTED	9:765afebbe21cf5bbca048e632df38336	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.23.2	\N	\N	7696466462
1.2.0.RC1	bburke@redhat.com	META-INF/db2-jpa-changelog-1.2.0.CR1.xml	2024-02-12 00:07:47.716162	8	MARK_RAN	9:db4a145ba11a6fdaefb397f6dbf829a1	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.23.2	\N	\N	7696466462
1.2.0.Final	keycloak	META-INF/jpa-changelog-1.2.0.Final.xml	2024-02-12 00:07:47.725253	9	EXECUTED	9:9d05c7be10cdb873f8bcb41bc3a8ab23	update tableName=CLIENT; update tableName=CLIENT; update tableName=CLIENT		\N	4.23.2	\N	\N	7696466462
1.3.0	bburke@redhat.com	META-INF/jpa-changelog-1.3.0.xml	2024-02-12 00:07:47.877715	10	EXECUTED	9:18593702353128d53111f9b1ff0b82b8	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=ADMI...		\N	4.23.2	\N	\N	7696466462
1.4.0	bburke@redhat.com	META-INF/jpa-changelog-1.4.0.xml	2024-02-12 00:07:47.942335	11	EXECUTED	9:6122efe5f090e41a85c0f1c9e52cbb62	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.23.2	\N	\N	7696466462
1.4.0	bburke@redhat.com	META-INF/db2-jpa-changelog-1.4.0.xml	2024-02-12 00:07:47.951759	12	MARK_RAN	9:e1ff28bf7568451453f844c5d54bb0b5	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.23.2	\N	\N	7696466462
1.5.0	bburke@redhat.com	META-INF/jpa-changelog-1.5.0.xml	2024-02-12 00:07:47.973368	13	EXECUTED	9:7af32cd8957fbc069f796b61217483fd	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.23.2	\N	\N	7696466462
1.6.1_from15	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-02-12 00:07:48.002731	14	EXECUTED	9:6005e15e84714cd83226bf7879f54190	addColumn tableName=REALM; addColumn tableName=KEYCLOAK_ROLE; addColumn tableName=CLIENT; createTable tableName=OFFLINE_USER_SESSION; createTable tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_US_SES_PK2, tableName=...		\N	4.23.2	\N	\N	7696466462
1.6.1_from16-pre	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-02-12 00:07:48.006159	15	MARK_RAN	9:bf656f5a2b055d07f314431cae76f06c	delete tableName=OFFLINE_CLIENT_SESSION; delete tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	7696466462
1.6.1_from16	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-02-12 00:07:48.010535	16	MARK_RAN	9:f8dadc9284440469dcf71e25ca6ab99b	dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_US_SES_PK, tableName=OFFLINE_USER_SESSION; dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_CL_SES_PK, tableName=OFFLINE_CLIENT_SESSION; addColumn tableName=OFFLINE_USER_SESSION; update tableName=OF...		\N	4.23.2	\N	\N	7696466462
1.6.1	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-02-12 00:07:48.014194	17	EXECUTED	9:d41d8cd98f00b204e9800998ecf8427e	empty		\N	4.23.2	\N	\N	7696466462
1.7.0	bburke@redhat.com	META-INF/jpa-changelog-1.7.0.xml	2024-02-12 00:07:48.098618	18	EXECUTED	9:3368ff0be4c2855ee2dd9ca813b38d8e	createTable tableName=KEYCLOAK_GROUP; createTable tableName=GROUP_ROLE_MAPPING; createTable tableName=GROUP_ATTRIBUTE; createTable tableName=USER_GROUP_MEMBERSHIP; createTable tableName=REALM_DEFAULT_GROUPS; addColumn tableName=IDENTITY_PROVIDER; ...		\N	4.23.2	\N	\N	7696466462
1.8.0	mposolda@redhat.com	META-INF/jpa-changelog-1.8.0.xml	2024-02-12 00:07:48.156771	19	EXECUTED	9:8ac2fb5dd030b24c0570a763ed75ed20	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.23.2	\N	\N	7696466462
1.8.0-2	keycloak	META-INF/jpa-changelog-1.8.0.xml	2024-02-12 00:07:48.164986	20	EXECUTED	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.23.2	\N	\N	7696466462
1.8.0	mposolda@redhat.com	META-INF/db2-jpa-changelog-1.8.0.xml	2024-02-12 00:07:48.174373	21	MARK_RAN	9:831e82914316dc8a57dc09d755f23c51	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.23.2	\N	\N	7696466462
1.8.0-2	keycloak	META-INF/db2-jpa-changelog-1.8.0.xml	2024-02-12 00:07:48.179908	22	MARK_RAN	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.23.2	\N	\N	7696466462
1.9.0	mposolda@redhat.com	META-INF/jpa-changelog-1.9.0.xml	2024-02-12 00:07:48.220454	23	EXECUTED	9:bc3d0f9e823a69dc21e23e94c7a94bb1	update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=REALM; update tableName=REALM; customChange; dr...		\N	4.23.2	\N	\N	7696466462
1.9.1	keycloak	META-INF/jpa-changelog-1.9.1.xml	2024-02-12 00:07:48.228275	24	EXECUTED	9:c9999da42f543575ab790e76439a2679	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=PUBLIC_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.23.2	\N	\N	7696466462
1.9.1	keycloak	META-INF/db2-jpa-changelog-1.9.1.xml	2024-02-12 00:07:48.231558	25	MARK_RAN	9:0d6c65c6f58732d81569e77b10ba301d	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.23.2	\N	\N	7696466462
1.9.2	keycloak	META-INF/jpa-changelog-1.9.2.xml	2024-02-12 00:07:48.284741	26	EXECUTED	9:fc576660fc016ae53d2d4778d84d86d0	createIndex indexName=IDX_USER_EMAIL, tableName=USER_ENTITY; createIndex indexName=IDX_USER_ROLE_MAPPING, tableName=USER_ROLE_MAPPING; createIndex indexName=IDX_USER_GROUP_MAPPING, tableName=USER_GROUP_MEMBERSHIP; createIndex indexName=IDX_USER_CO...		\N	4.23.2	\N	\N	7696466462
authz-2.0.0	psilva@redhat.com	META-INF/jpa-changelog-authz-2.0.0.xml	2024-02-12 00:07:48.43809	27	EXECUTED	9:43ed6b0da89ff77206289e87eaa9c024	createTable tableName=RESOURCE_SERVER; addPrimaryKey constraintName=CONSTRAINT_FARS, tableName=RESOURCE_SERVER; addUniqueConstraint constraintName=UK_AU8TT6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER; createTable tableName=RESOURCE_SERVER_RESOU...		\N	4.23.2	\N	\N	7696466462
authz-2.5.1	psilva@redhat.com	META-INF/jpa-changelog-authz-2.5.1.xml	2024-02-12 00:07:48.449897	28	EXECUTED	9:44bae577f551b3738740281eceb4ea70	update tableName=RESOURCE_SERVER_POLICY		\N	4.23.2	\N	\N	7696466462
2.1.0-KEYCLOAK-5461	bburke@redhat.com	META-INF/jpa-changelog-2.1.0.xml	2024-02-12 00:07:48.583414	29	EXECUTED	9:bd88e1f833df0420b01e114533aee5e8	createTable tableName=BROKER_LINK; createTable tableName=FED_USER_ATTRIBUTE; createTable tableName=FED_USER_CONSENT; createTable tableName=FED_USER_CONSENT_ROLE; createTable tableName=FED_USER_CONSENT_PROT_MAPPER; createTable tableName=FED_USER_CR...		\N	4.23.2	\N	\N	7696466462
2.2.0	bburke@redhat.com	META-INF/jpa-changelog-2.2.0.xml	2024-02-12 00:07:48.611759	30	EXECUTED	9:a7022af5267f019d020edfe316ef4371	addColumn tableName=ADMIN_EVENT_ENTITY; createTable tableName=CREDENTIAL_ATTRIBUTE; createTable tableName=FED_CREDENTIAL_ATTRIBUTE; modifyDataType columnName=VALUE, tableName=CREDENTIAL; addForeignKeyConstraint baseTableName=FED_CREDENTIAL_ATTRIBU...		\N	4.23.2	\N	\N	7696466462
2.3.0	bburke@redhat.com	META-INF/jpa-changelog-2.3.0.xml	2024-02-12 00:07:48.635542	31	EXECUTED	9:fc155c394040654d6a79227e56f5e25a	createTable tableName=FEDERATED_USER; addPrimaryKey constraintName=CONSTR_FEDERATED_USER, tableName=FEDERATED_USER; dropDefaultValue columnName=TOTP, tableName=USER_ENTITY; dropColumn columnName=TOTP, tableName=USER_ENTITY; addColumn tableName=IDE...		\N	4.23.2	\N	\N	7696466462
2.4.0	bburke@redhat.com	META-INF/jpa-changelog-2.4.0.xml	2024-02-12 00:07:48.641372	32	EXECUTED	9:eac4ffb2a14795e5dc7b426063e54d88	customChange		\N	4.23.2	\N	\N	7696466462
2.5.0	bburke@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-02-12 00:07:48.649837	33	EXECUTED	9:54937c05672568c4c64fc9524c1e9462	customChange; modifyDataType columnName=USER_ID, tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	7696466462
2.5.0-unicode-oracle	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-02-12 00:07:48.654101	34	MARK_RAN	9:3a32bace77c84d7678d035a7f5a8084e	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.23.2	\N	\N	7696466462
2.5.0-unicode-other-dbs	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-02-12 00:07:48.692694	35	EXECUTED	9:33d72168746f81f98ae3a1e8e0ca3554	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.23.2	\N	\N	7696466462
2.5.0-duplicate-email-support	slawomir@dabek.name	META-INF/jpa-changelog-2.5.0.xml	2024-02-12 00:07:48.699793	36	EXECUTED	9:61b6d3d7a4c0e0024b0c839da283da0c	addColumn tableName=REALM		\N	4.23.2	\N	\N	7696466462
2.5.0-unique-group-names	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-02-12 00:07:48.71041	37	EXECUTED	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	7696466462
2.5.1	bburke@redhat.com	META-INF/jpa-changelog-2.5.1.xml	2024-02-12 00:07:48.716475	38	EXECUTED	9:a2b870802540cb3faa72098db5388af3	addColumn tableName=FED_USER_CONSENT		\N	4.23.2	\N	\N	7696466462
3.0.0	bburke@redhat.com	META-INF/jpa-changelog-3.0.0.xml	2024-02-12 00:07:48.723321	39	EXECUTED	9:132a67499ba24bcc54fb5cbdcfe7e4c0	addColumn tableName=IDENTITY_PROVIDER		\N	4.23.2	\N	\N	7696466462
3.2.0-fix	keycloak	META-INF/jpa-changelog-3.2.0.xml	2024-02-12 00:07:48.726555	40	MARK_RAN	9:938f894c032f5430f2b0fafb1a243462	addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS		\N	4.23.2	\N	\N	7696466462
3.2.0-fix-with-keycloak-5416	keycloak	META-INF/jpa-changelog-3.2.0.xml	2024-02-12 00:07:48.732587	41	MARK_RAN	9:845c332ff1874dc5d35974b0babf3006	dropIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS; addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS; createIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS		\N	4.23.2	\N	\N	7696466462
3.2.0-fix-offline-sessions	hmlnarik	META-INF/jpa-changelog-3.2.0.xml	2024-02-12 00:07:48.748864	42	EXECUTED	9:fc86359c079781adc577c5a217e4d04c	customChange		\N	4.23.2	\N	\N	7696466462
3.2.0-fixed	keycloak	META-INF/jpa-changelog-3.2.0.xml	2024-02-12 00:07:49.137768	43	EXECUTED	9:59a64800e3c0d09b825f8a3b444fa8f4	addColumn tableName=REALM; dropPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_PK2, tableName=OFFLINE_CLIENT_SESSION; dropColumn columnName=CLIENT_SESSION_ID, tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_P...		\N	4.23.2	\N	\N	7696466462
3.3.0	keycloak	META-INF/jpa-changelog-3.3.0.xml	2024-02-12 00:07:49.153916	44	EXECUTED	9:d48d6da5c6ccf667807f633fe489ce88	addColumn tableName=USER_ENTITY		\N	4.23.2	\N	\N	7696466462
authz-3.4.0.CR1-resource-server-pk-change-part1	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-02-12 00:07:49.170489	45	EXECUTED	9:dde36f7973e80d71fceee683bc5d2951	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_RESOURCE; addColumn tableName=RESOURCE_SERVER_SCOPE		\N	4.23.2	\N	\N	7696466462
authz-3.4.0.CR1-resource-server-pk-change-part2-KEYCLOAK-6095	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-02-12 00:07:49.186195	46	EXECUTED	9:b855e9b0a406b34fa323235a0cf4f640	customChange		\N	4.23.2	\N	\N	7696466462
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-02-12 00:07:49.192111	47	MARK_RAN	9:51abbacd7b416c50c4421a8cabf7927e	dropIndex indexName=IDX_RES_SERV_POL_RES_SERV, tableName=RESOURCE_SERVER_POLICY; dropIndex indexName=IDX_RES_SRV_RES_RES_SRV, tableName=RESOURCE_SERVER_RESOURCE; dropIndex indexName=IDX_RES_SRV_SCOPE_RES_SRV, tableName=RESOURCE_SERVER_SCOPE		\N	4.23.2	\N	\N	7696466462
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed-nodropindex	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-02-12 00:07:49.327304	48	EXECUTED	9:bdc99e567b3398bac83263d375aad143	addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_POLICY; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_RESOURCE; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, ...		\N	4.23.2	\N	\N	7696466462
authn-3.4.0.CR1-refresh-token-max-reuse	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-02-12 00:07:49.346741	49	EXECUTED	9:d198654156881c46bfba39abd7769e69	addColumn tableName=REALM		\N	4.23.2	\N	\N	7696466462
3.4.0	keycloak	META-INF/jpa-changelog-3.4.0.xml	2024-02-12 00:07:49.449238	50	EXECUTED	9:cfdd8736332ccdd72c5256ccb42335db	addPrimaryKey constraintName=CONSTRAINT_REALM_DEFAULT_ROLES, tableName=REALM_DEFAULT_ROLES; addPrimaryKey constraintName=CONSTRAINT_COMPOSITE_ROLE, tableName=COMPOSITE_ROLE; addPrimaryKey constraintName=CONSTR_REALM_DEFAULT_GROUPS, tableName=REALM...		\N	4.23.2	\N	\N	7696466462
3.4.0-KEYCLOAK-5230	hmlnarik@redhat.com	META-INF/jpa-changelog-3.4.0.xml	2024-02-12 00:07:49.548809	51	EXECUTED	9:7c84de3d9bd84d7f077607c1a4dcb714	createIndex indexName=IDX_FU_ATTRIBUTE, tableName=FED_USER_ATTRIBUTE; createIndex indexName=IDX_FU_CONSENT, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CONSENT_RU, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CREDENTIAL, t...		\N	4.23.2	\N	\N	7696466462
3.4.1	psilva@redhat.com	META-INF/jpa-changelog-3.4.1.xml	2024-02-12 00:07:49.562285	52	EXECUTED	9:5a6bb36cbefb6a9d6928452c0852af2d	modifyDataType columnName=VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	7696466462
3.4.2	keycloak	META-INF/jpa-changelog-3.4.2.xml	2024-02-12 00:07:49.573293	53	EXECUTED	9:8f23e334dbc59f82e0a328373ca6ced0	update tableName=REALM		\N	4.23.2	\N	\N	7696466462
3.4.2-KEYCLOAK-5172	mkanis@redhat.com	META-INF/jpa-changelog-3.4.2.xml	2024-02-12 00:07:49.582887	54	EXECUTED	9:9156214268f09d970cdf0e1564d866af	update tableName=CLIENT		\N	4.23.2	\N	\N	7696466462
4.0.0-KEYCLOAK-6335	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-02-12 00:07:49.606235	55	EXECUTED	9:db806613b1ed154826c02610b7dbdf74	createTable tableName=CLIENT_AUTH_FLOW_BINDINGS; addPrimaryKey constraintName=C_CLI_FLOW_BIND, tableName=CLIENT_AUTH_FLOW_BINDINGS		\N	4.23.2	\N	\N	7696466462
4.0.0-CLEANUP-UNUSED-TABLE	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-02-12 00:07:49.637017	56	EXECUTED	9:229a041fb72d5beac76bb94a5fa709de	dropTable tableName=CLIENT_IDENTITY_PROV_MAPPING		\N	4.23.2	\N	\N	7696466462
4.0.0-KEYCLOAK-6228	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-02-12 00:07:49.719851	57	EXECUTED	9:079899dade9c1e683f26b2aa9ca6ff04	dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; dropNotNullConstraint columnName=CLIENT_ID, tableName=USER_CONSENT; addColumn tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHO...		\N	4.23.2	\N	\N	7696466462
4.0.0-KEYCLOAK-5579-fixed	mposolda@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-02-12 00:07:49.942772	58	EXECUTED	9:139b79bcbbfe903bb1c2d2a4dbf001d9	dropForeignKeyConstraint baseTableName=CLIENT_TEMPLATE_ATTRIBUTES, constraintName=FK_CL_TEMPL_ATTR_TEMPL; renameTable newTableName=CLIENT_SCOPE_ATTRIBUTES, oldTableName=CLIENT_TEMPLATE_ATTRIBUTES; renameColumn newColumnName=SCOPE_ID, oldColumnName...		\N	4.23.2	\N	\N	7696466462
authz-4.0.0.CR1	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.CR1.xml	2024-02-12 00:07:50.057451	59	EXECUTED	9:b55738ad889860c625ba2bf483495a04	createTable tableName=RESOURCE_SERVER_PERM_TICKET; addPrimaryKey constraintName=CONSTRAINT_FAPMT, tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRHO213XCX4WNKOG82SSPMT...		\N	4.23.2	\N	\N	7696466462
authz-4.0.0.Beta3	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.Beta3.xml	2024-02-12 00:07:50.082701	60	EXECUTED	9:e0057eac39aa8fc8e09ac6cfa4ae15fe	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRPO2128CX4WNKOG82SSRFY, referencedTableName=RESOURCE_SERVER_POLICY		\N	4.23.2	\N	\N	7696466462
authz-4.2.0.Final	mhajas@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2024-02-12 00:07:50.114771	61	EXECUTED	9:42a33806f3a0443fe0e7feeec821326c	createTable tableName=RESOURCE_URIS; addForeignKeyConstraint baseTableName=RESOURCE_URIS, constraintName=FK_RESOURCE_SERVER_URIS, referencedTableName=RESOURCE_SERVER_RESOURCE; customChange; dropColumn columnName=URI, tableName=RESOURCE_SERVER_RESO...		\N	4.23.2	\N	\N	7696466462
authz-4.2.0.Final-KEYCLOAK-9944	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2024-02-12 00:07:50.1316	62	EXECUTED	9:9968206fca46eecc1f51db9c024bfe56	addPrimaryKey constraintName=CONSTRAINT_RESOUR_URIS_PK, tableName=RESOURCE_URIS		\N	4.23.2	\N	\N	7696466462
4.2.0-KEYCLOAK-6313	wadahiro@gmail.com	META-INF/jpa-changelog-4.2.0.xml	2024-02-12 00:07:50.139514	63	EXECUTED	9:92143a6daea0a3f3b8f598c97ce55c3d	addColumn tableName=REQUIRED_ACTION_PROVIDER		\N	4.23.2	\N	\N	7696466462
4.3.0-KEYCLOAK-7984	wadahiro@gmail.com	META-INF/jpa-changelog-4.3.0.xml	2024-02-12 00:07:50.145379	64	EXECUTED	9:82bab26a27195d889fb0429003b18f40	update tableName=REQUIRED_ACTION_PROVIDER		\N	4.23.2	\N	\N	7696466462
4.6.0-KEYCLOAK-7950	psilva@redhat.com	META-INF/jpa-changelog-4.6.0.xml	2024-02-12 00:07:50.150113	65	EXECUTED	9:e590c88ddc0b38b0ae4249bbfcb5abc3	update tableName=RESOURCE_SERVER_RESOURCE		\N	4.23.2	\N	\N	7696466462
4.6.0-KEYCLOAK-8377	keycloak	META-INF/jpa-changelog-4.6.0.xml	2024-02-12 00:07:50.172593	66	EXECUTED	9:5c1f475536118dbdc38d5d7977950cc0	createTable tableName=ROLE_ATTRIBUTE; addPrimaryKey constraintName=CONSTRAINT_ROLE_ATTRIBUTE_PK, tableName=ROLE_ATTRIBUTE; addForeignKeyConstraint baseTableName=ROLE_ATTRIBUTE, constraintName=FK_ROLE_ATTRIBUTE_ID, referencedTableName=KEYCLOAK_ROLE...		\N	4.23.2	\N	\N	7696466462
4.6.0-KEYCLOAK-8555	gideonray@gmail.com	META-INF/jpa-changelog-4.6.0.xml	2024-02-12 00:07:50.181108	67	EXECUTED	9:e7c9f5f9c4d67ccbbcc215440c718a17	createIndex indexName=IDX_COMPONENT_PROVIDER_TYPE, tableName=COMPONENT		\N	4.23.2	\N	\N	7696466462
4.7.0-KEYCLOAK-1267	sguilhen@redhat.com	META-INF/jpa-changelog-4.7.0.xml	2024-02-12 00:07:50.18815	68	EXECUTED	9:88e0bfdda924690d6f4e430c53447dd5	addColumn tableName=REALM		\N	4.23.2	\N	\N	7696466462
4.7.0-KEYCLOAK-7275	keycloak	META-INF/jpa-changelog-4.7.0.xml	2024-02-12 00:07:50.201688	69	EXECUTED	9:f53177f137e1c46b6a88c59ec1cb5218	renameColumn newColumnName=CREATED_ON, oldColumnName=LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION; addNotNullConstraint columnName=CREATED_ON, tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_USER_SESSION; customChange; createIn...		\N	4.23.2	\N	\N	7696466462
4.8.0-KEYCLOAK-8835	sguilhen@redhat.com	META-INF/jpa-changelog-4.8.0.xml	2024-02-12 00:07:50.208918	70	EXECUTED	9:a74d33da4dc42a37ec27121580d1459f	addNotNullConstraint columnName=SSO_MAX_LIFESPAN_REMEMBER_ME, tableName=REALM; addNotNullConstraint columnName=SSO_IDLE_TIMEOUT_REMEMBER_ME, tableName=REALM		\N	4.23.2	\N	\N	7696466462
authz-7.0.0-KEYCLOAK-10443	psilva@redhat.com	META-INF/jpa-changelog-authz-7.0.0.xml	2024-02-12 00:07:50.216122	71	EXECUTED	9:fd4ade7b90c3b67fae0bfcfcb42dfb5f	addColumn tableName=RESOURCE_SERVER		\N	4.23.2	\N	\N	7696466462
8.0.0-adding-credential-columns	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-02-12 00:07:50.223911	72	EXECUTED	9:aa072ad090bbba210d8f18781b8cebf4	addColumn tableName=CREDENTIAL; addColumn tableName=FED_USER_CREDENTIAL		\N	4.23.2	\N	\N	7696466462
8.0.0-updating-credential-data-not-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-02-12 00:07:50.230321	73	EXECUTED	9:1ae6be29bab7c2aa376f6983b932be37	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.23.2	\N	\N	7696466462
8.0.0-updating-credential-data-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-02-12 00:07:50.23446	74	MARK_RAN	9:14706f286953fc9a25286dbd8fb30d97	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.23.2	\N	\N	7696466462
8.0.0-credential-cleanup-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-02-12 00:07:50.257861	75	EXECUTED	9:2b9cc12779be32c5b40e2e67711a218b	dropDefaultValue columnName=COUNTER, tableName=CREDENTIAL; dropDefaultValue columnName=DIGITS, tableName=CREDENTIAL; dropDefaultValue columnName=PERIOD, tableName=CREDENTIAL; dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; dropColumn ...		\N	4.23.2	\N	\N	7696466462
8.0.0-resource-tag-support	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-02-12 00:07:50.268633	76	EXECUTED	9:91fa186ce7a5af127a2d7a91ee083cc5	addColumn tableName=MIGRATION_MODEL; createIndex indexName=IDX_UPDATE_TIME, tableName=MIGRATION_MODEL		\N	4.23.2	\N	\N	7696466462
9.0.0-always-display-client	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-02-12 00:07:50.274563	77	EXECUTED	9:6335e5c94e83a2639ccd68dd24e2e5ad	addColumn tableName=CLIENT		\N	4.23.2	\N	\N	7696466462
9.0.0-drop-constraints-for-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-02-12 00:07:50.277797	78	MARK_RAN	9:6bdb5658951e028bfe16fa0a8228b530	dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5PMT, tableName=RESOURCE_SERVER_PERM_TICKET; dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER_RESOURCE; dropPrimaryKey constraintName=CONSTRAINT_O...		\N	4.23.2	\N	\N	7696466462
9.0.0-increase-column-size-federated-fk	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-02-12 00:07:50.305356	79	EXECUTED	9:d5bc15a64117ccad481ce8792d4c608f	modifyDataType columnName=CLIENT_ID, tableName=FED_USER_CONSENT; modifyDataType columnName=CLIENT_REALM_CONSTRAINT, tableName=KEYCLOAK_ROLE; modifyDataType columnName=OWNER, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=CLIENT_ID, ta...		\N	4.23.2	\N	\N	7696466462
9.0.0-recreate-constraints-after-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-02-12 00:07:50.310714	80	MARK_RAN	9:077cba51999515f4d3e7ad5619ab592c	addNotNullConstraint columnName=CLIENT_ID, tableName=OFFLINE_CLIENT_SESSION; addNotNullConstraint columnName=OWNER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNullConstraint columnName=REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNull...		\N	4.23.2	\N	\N	7696466462
9.0.1-add-index-to-client.client_id	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-02-12 00:07:50.321715	81	EXECUTED	9:be969f08a163bf47c6b9e9ead8ac2afb	createIndex indexName=IDX_CLIENT_ID, tableName=CLIENT		\N	4.23.2	\N	\N	7696466462
9.0.1-KEYCLOAK-12579-drop-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-02-12 00:07:50.325899	82	MARK_RAN	9:6d3bb4408ba5a72f39bd8a0b301ec6e3	dropUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	7696466462
9.0.1-KEYCLOAK-12579-add-not-null-constraint	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-02-12 00:07:50.341365	83	EXECUTED	9:966bda61e46bebf3cc39518fbed52fa7	addNotNullConstraint columnName=PARENT_GROUP, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	7696466462
9.0.1-KEYCLOAK-12579-recreate-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-02-12 00:07:50.347533	84	MARK_RAN	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	7696466462
9.0.1-add-index-to-events	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-02-12 00:07:50.365237	85	EXECUTED	9:7d93d602352a30c0c317e6a609b56599	createIndex indexName=IDX_EVENT_TIME, tableName=EVENT_ENTITY		\N	4.23.2	\N	\N	7696466462
map-remove-ri	keycloak	META-INF/jpa-changelog-11.0.0.xml	2024-02-12 00:07:50.389292	86	EXECUTED	9:71c5969e6cdd8d7b6f47cebc86d37627	dropForeignKeyConstraint baseTableName=REALM, constraintName=FK_TRAF444KK6QRKMS7N56AIWQ5Y; dropForeignKeyConstraint baseTableName=KEYCLOAK_ROLE, constraintName=FK_KJHO5LE2C0RAL09FL8CM9WFW9		\N	4.23.2	\N	\N	7696466462
map-remove-ri	keycloak	META-INF/jpa-changelog-12.0.0.xml	2024-02-12 00:07:50.430024	87	EXECUTED	9:a9ba7d47f065f041b7da856a81762021	dropForeignKeyConstraint baseTableName=REALM_DEFAULT_GROUPS, constraintName=FK_DEF_GROUPS_GROUP; dropForeignKeyConstraint baseTableName=REALM_DEFAULT_ROLES, constraintName=FK_H4WPD7W4HSOOLNI3H0SW7BTJE; dropForeignKeyConstraint baseTableName=CLIENT...		\N	4.23.2	\N	\N	7696466462
12.1.0-add-realm-localization-table	keycloak	META-INF/jpa-changelog-12.0.0.xml	2024-02-12 00:07:50.448568	88	EXECUTED	9:fffabce2bc01e1a8f5110d5278500065	createTable tableName=REALM_LOCALIZATIONS; addPrimaryKey tableName=REALM_LOCALIZATIONS		\N	4.23.2	\N	\N	7696466462
default-roles	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.468332	89	EXECUTED	9:fa8a5b5445e3857f4b010bafb5009957	addColumn tableName=REALM; customChange		\N	4.23.2	\N	\N	7696466462
default-roles-cleanup	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.499318	90	EXECUTED	9:67ac3241df9a8582d591c5ed87125f39	dropTable tableName=REALM_DEFAULT_ROLES; dropTable tableName=CLIENT_DEFAULT_ROLES		\N	4.23.2	\N	\N	7696466462
13.0.0-KEYCLOAK-16844	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.512377	91	EXECUTED	9:ad1194d66c937e3ffc82386c050ba089	createIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	7696466462
map-remove-ri-13.0.0	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.537012	92	EXECUTED	9:d9be619d94af5a2f5d07b9f003543b91	dropForeignKeyConstraint baseTableName=DEFAULT_CLIENT_SCOPE, constraintName=FK_R_DEF_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SCOPE_CLIENT, constraintName=FK_C_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SC...		\N	4.23.2	\N	\N	7696466462
13.0.0-KEYCLOAK-17992-drop-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.54143	93	MARK_RAN	9:544d201116a0fcc5a5da0925fbbc3bde	dropPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CLSCOPE_CL, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CL_CLSCOPE, tableName=CLIENT_SCOPE_CLIENT		\N	4.23.2	\N	\N	7696466462
13.0.0-increase-column-size-federated	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.563135	94	EXECUTED	9:43c0c1055b6761b4b3e89de76d612ccf	modifyDataType columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; modifyDataType columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT		\N	4.23.2	\N	\N	7696466462
13.0.0-KEYCLOAK-17992-recreate-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.567151	95	MARK_RAN	9:8bd711fd0330f4fe980494ca43ab1139	addNotNullConstraint columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; addNotNullConstraint columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT; addPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; createIndex indexName=...		\N	4.23.2	\N	\N	7696466462
json-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-02-12 00:07:50.577186	96	EXECUTED	9:e07d2bc0970c348bb06fb63b1f82ddbf	addColumn tableName=REALM_ATTRIBUTE; update tableName=REALM_ATTRIBUTE; dropColumn columnName=VALUE, tableName=REALM_ATTRIBUTE; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=REALM_ATTRIBUTE		\N	4.23.2	\N	\N	7696466462
14.0.0-KEYCLOAK-11019	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.597156	97	EXECUTED	9:24fb8611e97f29989bea412aa38d12b7	createIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USER, tableName=OFFLINE_USER_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	7696466462
14.0.0-KEYCLOAK-18286	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.600165	98	MARK_RAN	9:259f89014ce2506ee84740cbf7163aa7	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	7696466462
14.0.0-KEYCLOAK-18286-revert	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.610066	99	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	7696466462
14.0.0-KEYCLOAK-18286-supported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.62135	100	EXECUTED	9:60ca84a0f8c94ec8c3504a5a3bc88ee8	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	7696466462
14.0.0-KEYCLOAK-18286-unsupported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.624217	101	MARK_RAN	9:d3d977031d431db16e2c181ce49d73e9	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	7696466462
KEYCLOAK-17267-add-index-to-user-attributes	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.634928	102	EXECUTED	9:0b305d8d1277f3a89a0a53a659ad274c	createIndex indexName=IDX_USER_ATTRIBUTE_NAME, tableName=USER_ATTRIBUTE		\N	4.23.2	\N	\N	7696466462
KEYCLOAK-18146-add-saml-art-binding-identifier	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-02-12 00:07:50.640395	103	EXECUTED	9:2c374ad2cdfe20e2905a84c8fac48460	customChange		\N	4.23.2	\N	\N	7696466462
15.0.0-KEYCLOAK-18467	keycloak	META-INF/jpa-changelog-15.0.0.xml	2024-02-12 00:07:50.649237	104	EXECUTED	9:47a760639ac597360a8219f5b768b4de	addColumn tableName=REALM_LOCALIZATIONS; update tableName=REALM_LOCALIZATIONS; dropColumn columnName=TEXTS, tableName=REALM_LOCALIZATIONS; renameColumn newColumnName=TEXTS, oldColumnName=TEXTS_NEW, tableName=REALM_LOCALIZATIONS; addNotNullConstrai...		\N	4.23.2	\N	\N	7696466462
17.0.0-9562	keycloak	META-INF/jpa-changelog-17.0.0.xml	2024-02-12 00:07:50.659379	105	EXECUTED	9:a6272f0576727dd8cad2522335f5d99e	createIndex indexName=IDX_USER_SERVICE_ACCOUNT, tableName=USER_ENTITY		\N	4.23.2	\N	\N	7696466462
18.0.0-10625-IDX_ADMIN_EVENT_TIME	keycloak	META-INF/jpa-changelog-18.0.0.xml	2024-02-12 00:07:50.669005	106	EXECUTED	9:015479dbd691d9cc8669282f4828c41d	createIndex indexName=IDX_ADMIN_EVENT_TIME, tableName=ADMIN_EVENT_ENTITY		\N	4.23.2	\N	\N	7696466462
19.0.0-10135	keycloak	META-INF/jpa-changelog-19.0.0.xml	2024-02-12 00:07:50.675038	107	EXECUTED	9:9518e495fdd22f78ad6425cc30630221	customChange		\N	4.23.2	\N	\N	7696466462
20.0.0-12964-supported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2024-02-12 00:07:50.685836	108	EXECUTED	9:e5f243877199fd96bcc842f27a1656ac	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.23.2	\N	\N	7696466462
20.0.0-12964-unsupported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2024-02-12 00:07:50.688655	109	MARK_RAN	9:1a6fcaa85e20bdeae0a9ce49b41946a5	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.23.2	\N	\N	7696466462
client-attributes-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-20.0.0.xml	2024-02-12 00:07:50.698484	110	EXECUTED	9:3f332e13e90739ed0c35b0b25b7822ca	addColumn tableName=CLIENT_ATTRIBUTES; update tableName=CLIENT_ATTRIBUTES; dropColumn columnName=VALUE, tableName=CLIENT_ATTRIBUTES; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	7696466462
21.0.2-17277	keycloak	META-INF/jpa-changelog-21.0.2.xml	2024-02-12 00:07:50.704909	111	EXECUTED	9:7ee1f7a3fb8f5588f171fb9a6ab623c0	customChange		\N	4.23.2	\N	\N	7696466462
21.1.0-19404	keycloak	META-INF/jpa-changelog-21.1.0.xml	2024-02-12 00:07:50.750073	112	EXECUTED	9:3d7e830b52f33676b9d64f7f2b2ea634	modifyDataType columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=LOGIC, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=POLICY_ENFORCE_MODE, tableName=RESOURCE_SERVER		\N	4.23.2	\N	\N	7696466462
21.1.0-19404-2	keycloak	META-INF/jpa-changelog-21.1.0.xml	2024-02-12 00:07:50.754191	113	MARK_RAN	9:627d032e3ef2c06c0e1f73d2ae25c26c	addColumn tableName=RESOURCE_SERVER_POLICY; update tableName=RESOURCE_SERVER_POLICY; dropColumn columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; renameColumn newColumnName=DECISION_STRATEGY, oldColumnName=DECISION_STRATEGY_NEW, tabl...		\N	4.23.2	\N	\N	7696466462
22.0.0-17484-updated	keycloak	META-INF/jpa-changelog-22.0.0.xml	2024-02-12 00:07:50.760922	114	EXECUTED	9:90af0bfd30cafc17b9f4d6eccd92b8b3	customChange		\N	4.23.2	\N	\N	7696466462
22.0.5-24031	keycloak	META-INF/jpa-changelog-22.0.0.xml	2024-02-12 00:07:50.764232	115	MARK_RAN	9:a60d2d7b315ec2d3eba9e2f145f9df28	customChange		\N	4.23.2	\N	\N	7696466462
23.0.0-12062	keycloak	META-INF/jpa-changelog-23.0.0.xml	2024-02-12 00:07:50.772311	116	EXECUTED	9:2168fbe728fec46ae9baf15bf80927b8	addColumn tableName=COMPONENT_CONFIG; update tableName=COMPONENT_CONFIG; dropColumn columnName=VALUE, tableName=COMPONENT_CONFIG; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=COMPONENT_CONFIG		\N	4.23.2	\N	\N	7696466462
23.0.0-17258	keycloak	META-INF/jpa-changelog-23.0.0.xml	2024-02-12 00:07:50.778576	117	EXECUTED	9:36506d679a83bbfda85a27ea1864dca8	addColumn tableName=EVENT_ENTITY		\N	4.23.2	\N	\N	7696466462
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
1000	f	\N	\N
1001	f	\N	\N
\.


--
-- Data for Name: default_client_scope; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.default_client_scope (realm_id, scope_id, default_scope) FROM stdin;
def58135-f6f9-494c-b177-21c2d610717d	4d258cbc-d0c8-4d75-8fe5-ff1dc444cbfa	f
def58135-f6f9-494c-b177-21c2d610717d	a14f4177-310c-420a-b28f-428df0698136	t
def58135-f6f9-494c-b177-21c2d610717d	e60a80ce-084b-4571-8cc4-09b5292aa042	t
def58135-f6f9-494c-b177-21c2d610717d	9b11e43e-d445-4546-bcf0-bc8d2802face	t
def58135-f6f9-494c-b177-21c2d610717d	9cb609e3-fde4-48e2-9961-2a521366eb55	f
def58135-f6f9-494c-b177-21c2d610717d	beb03732-4117-43c6-b498-c02128563608	f
def58135-f6f9-494c-b177-21c2d610717d	56f38420-c513-45f4-8d5b-785eb9298404	t
def58135-f6f9-494c-b177-21c2d610717d	b28e9102-1992-4af1-933b-fd0c20a8e266	t
def58135-f6f9-494c-b177-21c2d610717d	32fd8b43-bdd1-4ced-983f-d8590a944cbb	f
def58135-f6f9-494c-b177-21c2d610717d	f057fa69-8f7b-4b9b-bede-69cd3faf35c6	t
26848019-e2da-4775-a3ad-60ce8c6173f2	a773fb0f-9993-49e7-9214-7e7f98c6ad79	f
26848019-e2da-4775-a3ad-60ce8c6173f2	cbaacbbe-c0c5-4657-907d-00fb309df49d	t
26848019-e2da-4775-a3ad-60ce8c6173f2	8baab608-b71e-4b15-b96c-d2fc480555aa	t
26848019-e2da-4775-a3ad-60ce8c6173f2	fe7ad17f-93c9-4206-a35b-03e852c5c1d8	t
26848019-e2da-4775-a3ad-60ce8c6173f2	b7e33886-aa02-44c2-8165-aaf52c05634d	f
26848019-e2da-4775-a3ad-60ce8c6173f2	ab0d9d68-dcb7-44b7-96cb-75b359b1d529	f
26848019-e2da-4775-a3ad-60ce8c6173f2	322a9d9e-56e1-4785-8a61-96eab81465d6	t
26848019-e2da-4775-a3ad-60ce8c6173f2	1a83699a-cf4d-45db-8be0-c841c3c253a6	t
26848019-e2da-4775-a3ad-60ce8c6173f2	3fe2462d-dd6a-48c6-b590-40a4e8408397	f
26848019-e2da-4775-a3ad-60ce8c6173f2	d99f24ab-b058-41c0-89c8-347252789592	t
\.


--
-- Data for Name: event_entity; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.event_entity (id, client_id, details_json, error, ip_address, realm_id, session_id, event_time, type, user_id, details_json_long_value) FROM stdin;
\.


--
-- Data for Name: fed_user_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_attribute (id, name, user_id, realm_id, storage_provider_id, value) FROM stdin;
\.


--
-- Data for Name: fed_user_consent; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_consent (id, client_id, user_id, realm_id, storage_provider_id, created_date, last_updated_date, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: fed_user_consent_cl_scope; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_consent_cl_scope (user_consent_id, scope_id) FROM stdin;
\.


--
-- Data for Name: fed_user_credential; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_credential (id, salt, type, created_date, user_id, realm_id, storage_provider_id, user_label, secret_data, credential_data, priority) FROM stdin;
\.


--
-- Data for Name: fed_user_group_membership; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_group_membership (group_id, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: fed_user_required_action; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_required_action (required_action, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: fed_user_role_mapping; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.fed_user_role_mapping (role_id, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: federated_identity; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.federated_identity (identity_provider, realm_id, federated_user_id, federated_username, token, user_id) FROM stdin;
\.


--
-- Data for Name: federated_user; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.federated_user (id, storage_provider_id, realm_id) FROM stdin;
\.


--
-- Data for Name: group_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.group_attribute (id, name, value, group_id) FROM stdin;
\.


--
-- Data for Name: group_role_mapping; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.group_role_mapping (role_id, group_id) FROM stdin;
\.


--
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.identity_provider (internal_id, enabled, provider_alias, provider_id, store_token, authenticate_by_default, realm_id, add_token_role, trust_email, first_broker_login_flow_id, post_broker_login_flow_id, provider_display_name, link_only) FROM stdin;
\.


--
-- Data for Name: identity_provider_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.identity_provider_config (identity_provider_id, value, name) FROM stdin;
\.


--
-- Data for Name: identity_provider_mapper; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.identity_provider_mapper (id, name, idp_alias, idp_mapper_name, realm_id) FROM stdin;
\.


--
-- Data for Name: idp_mapper_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.idp_mapper_config (idp_mapper_id, value, name) FROM stdin;
\.


--
-- Data for Name: keycloak_group; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.keycloak_group (id, name, parent_group, realm_id) FROM stdin;
\.


--
-- Data for Name: keycloak_role; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.keycloak_role (id, client_realm_constraint, client_role, description, name, realm_id, client, realm) FROM stdin;
473daa87-403d-43d2-a630-f2bed71ec503	def58135-f6f9-494c-b177-21c2d610717d	f	${role_default-roles}	default-roles-master	def58135-f6f9-494c-b177-21c2d610717d	\N	\N
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	def58135-f6f9-494c-b177-21c2d610717d	f	${role_admin}	admin	def58135-f6f9-494c-b177-21c2d610717d	\N	\N
e33dc421-3182-47a3-9cbe-15e5cf2f149c	def58135-f6f9-494c-b177-21c2d610717d	f	${role_create-realm}	create-realm	def58135-f6f9-494c-b177-21c2d610717d	\N	\N
428ebcbf-687b-46c7-a7cc-9d736fd75238	7026036f-3ce5-4357-831a-544680b316b4	t	${role_create-client}	create-client	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
9ebae38d-57bb-4be9-b394-f893fd407b5c	7026036f-3ce5-4357-831a-544680b316b4	t	${role_view-realm}	view-realm	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
de070575-4361-40db-98a6-37860fc1aeb8	7026036f-3ce5-4357-831a-544680b316b4	t	${role_view-users}	view-users	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
e6f7c314-bd97-467a-a749-9d7b27e417c9	7026036f-3ce5-4357-831a-544680b316b4	t	${role_view-clients}	view-clients	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
137613d8-2178-4dc7-a769-9c2e21449487	7026036f-3ce5-4357-831a-544680b316b4	t	${role_view-events}	view-events	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
d1ca75ba-b7c2-4690-a89e-f0bd39e28d58	7026036f-3ce5-4357-831a-544680b316b4	t	${role_view-identity-providers}	view-identity-providers	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
4242e742-7fbd-41da-97bc-a7431cc320c6	7026036f-3ce5-4357-831a-544680b316b4	t	${role_view-authorization}	view-authorization	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
f894574c-dd32-458d-b96c-99cec4b045c7	7026036f-3ce5-4357-831a-544680b316b4	t	${role_manage-realm}	manage-realm	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
f48f8f81-d7a7-44bf-8418-bf7261cbce49	7026036f-3ce5-4357-831a-544680b316b4	t	${role_manage-users}	manage-users	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
3c7694ab-745d-4e8f-8ad1-277920794dfe	7026036f-3ce5-4357-831a-544680b316b4	t	${role_manage-clients}	manage-clients	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
f3488a7f-8df9-4a56-a93f-87fe9275c341	7026036f-3ce5-4357-831a-544680b316b4	t	${role_manage-events}	manage-events	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
3a747c69-56af-461b-9cb3-658d7eb8991a	7026036f-3ce5-4357-831a-544680b316b4	t	${role_manage-identity-providers}	manage-identity-providers	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
5b8502a1-f8c9-429b-89bf-45c3186f0b42	7026036f-3ce5-4357-831a-544680b316b4	t	${role_manage-authorization}	manage-authorization	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
c90b782c-9351-4b86-8ce9-4212e9cc1911	7026036f-3ce5-4357-831a-544680b316b4	t	${role_query-users}	query-users	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
3eee5771-8205-4e6e-b346-d9c554201831	7026036f-3ce5-4357-831a-544680b316b4	t	${role_query-clients}	query-clients	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
420c4417-2571-4203-857f-f73e2d144827	7026036f-3ce5-4357-831a-544680b316b4	t	${role_query-realms}	query-realms	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
60ddf613-d4ca-4b51-a32e-b478645d1ac6	7026036f-3ce5-4357-831a-544680b316b4	t	${role_query-groups}	query-groups	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
5191e000-d6d5-41a4-8771-9156016fccde	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_view-profile}	view-profile	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
c0a795a3-9e5e-4f86-be82-03a5cc344d98	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_manage-account}	manage-account	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
5fc9e81f-1e93-4a6c-944d-a407a37ed781	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_manage-account-links}	manage-account-links	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
1e61ba13-dd0f-4ffc-8332-38a63fd3fac7	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_view-applications}	view-applications	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
1d551609-99f6-4c92-ae68-a23d6b918b73	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_view-consent}	view-consent	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
9c8ea9e6-d8da-40a7-b449-05456fa5389c	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_manage-consent}	manage-consent	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
6019cd62-8aff-481f-9edc-85081c0b45b8	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_view-groups}	view-groups	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
fa665ffc-a8c7-4cd5-bb54-922aa5ecb4e1	6a0cd2a0-1010-4a5e-bdfa-d20537224997	t	${role_delete-account}	delete-account	def58135-f6f9-494c-b177-21c2d610717d	6a0cd2a0-1010-4a5e-bdfa-d20537224997	\N
a9f453df-9c04-43af-9d84-88bf38182463	39b31477-f075-4686-8d71-7dcb4d9487cb	t	${role_read-token}	read-token	def58135-f6f9-494c-b177-21c2d610717d	39b31477-f075-4686-8d71-7dcb4d9487cb	\N
e8bb0c02-7d75-4d8d-b76f-cbbe828b42ab	7026036f-3ce5-4357-831a-544680b316b4	t	${role_impersonation}	impersonation	def58135-f6f9-494c-b177-21c2d610717d	7026036f-3ce5-4357-831a-544680b316b4	\N
ad4dfb7c-bb2a-4bcb-b60d-461f1ecc1d64	def58135-f6f9-494c-b177-21c2d610717d	f	${role_offline-access}	offline_access	def58135-f6f9-494c-b177-21c2d610717d	\N	\N
512295cb-cd34-4aed-8c21-4991ea085301	def58135-f6f9-494c-b177-21c2d610717d	f	${role_uma_authorization}	uma_authorization	def58135-f6f9-494c-b177-21c2d610717d	\N	\N
16d47a9d-16a5-4aab-bf57-945c2e783eba	26848019-e2da-4775-a3ad-60ce8c6173f2	f	${role_default-roles}	default-roles-maskanyone	26848019-e2da-4775-a3ad-60ce8c6173f2	\N	\N
60f6a924-36be-42f0-8354-5eca6466b15d	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_create-client}	create-client	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
47a67318-5e33-47d4-be51-07ef9afea16f	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_view-realm}	view-realm	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
1c56f3d3-a3f1-4d6a-a65a-e09d453a62c1	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_view-users}	view-users	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
5a4f2979-5e2d-4344-a5e2-780bf31b0764	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_view-clients}	view-clients	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
0c73944f-fbab-4fa3-888e-70ff3ea4de56	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_view-events}	view-events	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
1f4c5eae-fa50-498f-9178-c19a11ca9647	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_view-identity-providers}	view-identity-providers	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
5bc7f09b-dcdf-45dd-988c-8dcb7193e349	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_view-authorization}	view-authorization	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
66f8a6f9-3a6c-49b3-a721-480d710377c5	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_manage-realm}	manage-realm	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
2959b426-1990-4ebf-a4eb-2368f8e4418d	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_manage-users}	manage-users	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
ed55f9f5-4ea7-471e-981a-f552d92efcc3	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_manage-clients}	manage-clients	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
9f70bfe2-719a-4526-9d75-4de322b8c14e	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_manage-events}	manage-events	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
29b70a3e-4253-4cb3-a265-7248c2515cee	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_manage-identity-providers}	manage-identity-providers	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
d911c5b5-5112-4bd4-b202-e67af7afdd09	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_manage-authorization}	manage-authorization	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
0b2b0fc3-e662-493d-b82a-c542cc0dee92	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_query-users}	query-users	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
840720f3-47e0-4590-9256-dfd3241aea63	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_query-clients}	query-clients	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
429ebaa9-4519-4d8c-8e17-dc8823e4e4c9	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_query-realms}	query-realms	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
0010befa-9e09-47d1-9d75-75a873d23a57	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_query-groups}	query-groups	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
a941d83e-8bc2-4c12-808c-d32e83a1e222	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_realm-admin}	realm-admin	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
beb5c60e-c132-4f7e-adc6-c5e48a8ee11d	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_create-client}	create-client	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
e0fd44da-29b7-4087-b6e5-33bd3a4a7c24	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_view-realm}	view-realm	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
ce0fe192-4fa1-4712-bf83-ebf4d611f9ee	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_view-users}	view-users	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
e134f723-8940-4730-96e4-3089b1bba380	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_view-clients}	view-clients	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
8fbe606a-bded-45d1-b685-dbb1c532eebe	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_view-events}	view-events	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
0d15c5a7-bce8-4f91-bf68-7ebc792565a7	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_view-identity-providers}	view-identity-providers	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
6a0ca684-33d1-49bb-9a18-c6d3378000a1	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_view-authorization}	view-authorization	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
ba6e8b36-7847-4182-a571-ab4ddc6044ff	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_manage-realm}	manage-realm	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
c453fe8f-9c6a-49da-848a-6d726d0753e9	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_manage-users}	manage-users	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
8984a950-6e21-4578-b9db-5845099b142e	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_manage-clients}	manage-clients	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
bf95a241-6885-4e05-a883-4bd6272e221b	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_manage-events}	manage-events	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
67b43d87-d43c-49c2-b486-dee77d5d4e40	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_manage-identity-providers}	manage-identity-providers	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
fa72d8dd-a6fd-4cb8-b61f-38c79ef56f97	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_manage-authorization}	manage-authorization	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
eb7821e6-aae1-4b87-a109-311b9c267052	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_query-users}	query-users	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
2e687305-714b-42f9-823d-7d107381ca7a	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_query-clients}	query-clients	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
7f090d09-9c08-483a-a045-dfb4583b45d4	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_query-realms}	query-realms	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
5ff35e6b-5772-4c1e-9fd0-0ce7d98e1285	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_query-groups}	query-groups	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
c6a1f777-41bb-41c0-bcf5-15757d27342e	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_view-profile}	view-profile	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
89fa0898-18c7-4db3-bd95-aebe022a2c37	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_manage-account}	manage-account	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
087a5da2-f68c-4224-a9db-19b7cdfef1a3	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_manage-account-links}	manage-account-links	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
6d2e1606-348f-47d2-b1f4-0cc0652ea0fd	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_view-applications}	view-applications	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
fa3e3883-eced-4746-9c6b-e0195f4d98fc	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_view-consent}	view-consent	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
bd18407f-8b83-4232-806f-240d05b51127	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_manage-consent}	manage-consent	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
04473526-f292-4dfe-ba03-81bf5a364705	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_view-groups}	view-groups	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
5c8c013f-6fa2-4981-ab36-51d78b474594	a56c5ce1-4e7c-4380-ab53-c3658986fa56	t	${role_delete-account}	delete-account	26848019-e2da-4775-a3ad-60ce8c6173f2	a56c5ce1-4e7c-4380-ab53-c3658986fa56	\N
7d73286d-9cac-471c-a322-28ea87660fde	bf4b0124-6dbe-4947-92a3-c28ae427642f	t	${role_impersonation}	impersonation	def58135-f6f9-494c-b177-21c2d610717d	bf4b0124-6dbe-4947-92a3-c28ae427642f	\N
e0fdc6c4-d8b8-44b6-a094-9985563e8941	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	t	${role_impersonation}	impersonation	26848019-e2da-4775-a3ad-60ce8c6173f2	b85b80bf-3a5e-40d7-916c-eae2c0d2704d	\N
aaa5bb95-70da-4220-84ed-09cbe16dcce2	67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	t	${role_read-token}	read-token	26848019-e2da-4775-a3ad-60ce8c6173f2	67f7d82a-e5bf-4c5d-8c49-a36f0b03de9d	\N
c4d5cdda-04b9-4597-a8a1-1732007044e7	26848019-e2da-4775-a3ad-60ce8c6173f2	f	${role_offline-access}	offline_access	26848019-e2da-4775-a3ad-60ce8c6173f2	\N	\N
d898abd2-0442-48a0-9013-6988bef64f2e	26848019-e2da-4775-a3ad-60ce8c6173f2	f	${role_uma_authorization}	uma_authorization	26848019-e2da-4775-a3ad-60ce8c6173f2	\N	\N
\.


--
-- Data for Name: migration_model; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.migration_model (id, version, update_time) FROM stdin;
cbmp0	23.0.6	1707696470
\.


--
-- Data for Name: offline_client_session; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.offline_client_session (user_session_id, client_id, offline_flag, "timestamp", data, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: offline_user_session; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.offline_user_session (user_session_id, user_id, realm_id, created_on, offline_flag, data, last_session_refresh) FROM stdin;
\.


--
-- Data for Name: policy_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.policy_config (policy_id, name, value) FROM stdin;
\.


--
-- Data for Name: protocol_mapper; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.protocol_mapper (id, name, protocol, protocol_mapper_name, client_id, client_scope_id) FROM stdin;
0f49345b-66ff-47cd-829a-15291b37e417	audience resolve	openid-connect	oidc-audience-resolve-mapper	a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	\N
20997c21-ee6c-4245-8f70-ca6540079f95	locale	openid-connect	oidc-usermodel-attribute-mapper	baa7050d-d58f-4ce0-8d94-8fd75a2096a0	\N
4d224713-6331-4327-9520-8dde38d1f778	role list	saml	saml-role-list-mapper	\N	a14f4177-310c-420a-b28f-428df0698136
ab7a7520-e32c-45e7-990d-95ffdcc92b31	full name	openid-connect	oidc-full-name-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
b02a75cf-a429-4bc7-8939-00f3ca8901c6	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
65524193-abeb-479e-a1fe-4c46abcd1975	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
514afdec-11a4-46ca-b44a-4508c4caae32	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
cab040f7-6085-47ee-80bd-0ad3beb48b49	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
07831dc7-7977-4ff6-86c9-08155842f16a	username	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
bec56e67-2a2c-491c-bf12-b696e721adbe	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
4454162c-9871-47b6-b567-d65d2b877df4	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	website	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
a50f6a76-224a-459b-b793-4b76994d972a	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
a175a9fd-2545-4f86-8a56-bf0c1307d770	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
ae91d074-5b39-467a-ab17-0719caadf9eb	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	e60a80ce-084b-4571-8cc4-09b5292aa042
380d03f8-013a-4764-b808-d3d39b293383	email	openid-connect	oidc-usermodel-attribute-mapper	\N	9b11e43e-d445-4546-bcf0-bc8d2802face
aca61d1a-0133-44de-9b56-61a12d9f925e	email verified	openid-connect	oidc-usermodel-property-mapper	\N	9b11e43e-d445-4546-bcf0-bc8d2802face
13284fa7-b346-4f25-81e1-0168db3c5568	address	openid-connect	oidc-address-mapper	\N	9cb609e3-fde4-48e2-9961-2a521366eb55
aec47577-df86-4fa8-af49-21a6b7c9e5b3	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	beb03732-4117-43c6-b498-c02128563608
f77e6c76-9297-4355-af97-c7155f3dfe1a	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	beb03732-4117-43c6-b498-c02128563608
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	56f38420-c513-45f4-8d5b-785eb9298404
6099a445-ba2c-4477-ac57-66396a971cc6	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	56f38420-c513-45f4-8d5b-785eb9298404
6115efa2-8ac3-4732-ab51-2e15b5c09306	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	56f38420-c513-45f4-8d5b-785eb9298404
a511ac78-a2bc-4bc0-8d85-08d9c06f3f90	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	b28e9102-1992-4af1-933b-fd0c20a8e266
2b1a1ba9-e179-4707-90e6-b2561e09acae	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	32fd8b43-bdd1-4ced-983f-d8590a944cbb
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	32fd8b43-bdd1-4ced-983f-d8590a944cbb
be71c879-11ac-4345-84da-48c723e60569	acr loa level	openid-connect	oidc-acr-mapper	\N	f057fa69-8f7b-4b9b-bede-69cd3faf35c6
fa8928f1-dd64-4c47-b9dc-02134d3fbe67	audience resolve	openid-connect	oidc-audience-resolve-mapper	8e1e8954-7bec-4a60-8567-613e39ee594c	\N
ba581428-f3c5-4af5-b7c1-5486ba3a4314	role list	saml	saml-role-list-mapper	\N	cbaacbbe-c0c5-4657-907d-00fb309df49d
2d495d2b-1bbf-4bf0-80f8-a8e50b6f9e64	full name	openid-connect	oidc-full-name-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
675225b9-ad21-4a51-af27-887deb8e9f35	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
46d2fe5f-8611-4fe9-b5a8-08399431e856	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
061bedbd-7676-42f9-9cb5-8e63f60c202c	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
f841408c-d3a1-434d-8d56-3edac8930fdd	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	username	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
3ef9afd9-09c2-4779-a56b-33ffd8714d36	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
9cb84501-b078-40a7-a64f-2d159aec0bfb	website	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
346a8f91-8195-40d9-8e14-255e2f501c1c	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
0664c366-6965-4c8f-a135-523bf9c1147f	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
899ce4b9-4654-43db-b8de-c9155681d61f	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
46e175d1-4d16-4a4e-a833-90da0272efac	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
c6a7e90f-5e60-43ae-b687-170101e4b3b5	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	8baab608-b71e-4b15-b96c-d2fc480555aa
8bda2814-2bac-44b7-b95e-863f5dd39055	email	openid-connect	oidc-usermodel-attribute-mapper	\N	fe7ad17f-93c9-4206-a35b-03e852c5c1d8
f5deb462-fbc7-4a5d-85df-29d3f891e683	email verified	openid-connect	oidc-usermodel-property-mapper	\N	fe7ad17f-93c9-4206-a35b-03e852c5c1d8
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	address	openid-connect	oidc-address-mapper	\N	b7e33886-aa02-44c2-8165-aaf52c05634d
878b8d5a-1c75-4eac-a848-eaa03fb957ab	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	ab0d9d68-dcb7-44b7-96cb-75b359b1d529
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	ab0d9d68-dcb7-44b7-96cb-75b359b1d529
35416da6-94ef-41fd-8831-b58a693d4356	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	322a9d9e-56e1-4785-8a61-96eab81465d6
04d991ba-fb6c-4ff2-af93-0e991f87dd76	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	322a9d9e-56e1-4785-8a61-96eab81465d6
62e3dccb-ce62-45b7-b0b2-69e35d77326b	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	322a9d9e-56e1-4785-8a61-96eab81465d6
37e33701-4d52-4b8e-b69c-e72959baa3d0	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	1a83699a-cf4d-45db-8be0-c841c3c253a6
5e5f93fd-a72d-4038-8258-593d1d02f9aa	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	3fe2462d-dd6a-48c6-b590-40a4e8408397
b96e8ba0-cf1a-428b-a015-ab487d902001	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	3fe2462d-dd6a-48c6-b590-40a4e8408397
67319cbe-116e-48d2-827d-b5971d8fa4cf	acr loa level	openid-connect	oidc-acr-mapper	\N	d99f24ab-b058-41c0-89c8-347252789592
d4986728-720c-414a-85de-1c7abeb9b4a6	locale	openid-connect	oidc-usermodel-attribute-mapper	fbfe3dc5-e674-4324-8dc4-d00e64be6796	\N
\.


--
-- Data for Name: protocol_mapper_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.protocol_mapper_config (protocol_mapper_id, value, name) FROM stdin;
20997c21-ee6c-4245-8f70-ca6540079f95	true	introspection.token.claim
20997c21-ee6c-4245-8f70-ca6540079f95	true	userinfo.token.claim
20997c21-ee6c-4245-8f70-ca6540079f95	locale	user.attribute
20997c21-ee6c-4245-8f70-ca6540079f95	true	id.token.claim
20997c21-ee6c-4245-8f70-ca6540079f95	true	access.token.claim
20997c21-ee6c-4245-8f70-ca6540079f95	locale	claim.name
20997c21-ee6c-4245-8f70-ca6540079f95	String	jsonType.label
4d224713-6331-4327-9520-8dde38d1f778	false	single
4d224713-6331-4327-9520-8dde38d1f778	Basic	attribute.nameformat
4d224713-6331-4327-9520-8dde38d1f778	Role	attribute.name
07831dc7-7977-4ff6-86c9-08155842f16a	true	introspection.token.claim
07831dc7-7977-4ff6-86c9-08155842f16a	true	userinfo.token.claim
07831dc7-7977-4ff6-86c9-08155842f16a	username	user.attribute
07831dc7-7977-4ff6-86c9-08155842f16a	true	id.token.claim
07831dc7-7977-4ff6-86c9-08155842f16a	true	access.token.claim
07831dc7-7977-4ff6-86c9-08155842f16a	preferred_username	claim.name
07831dc7-7977-4ff6-86c9-08155842f16a	String	jsonType.label
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	true	introspection.token.claim
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	true	userinfo.token.claim
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	website	user.attribute
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	true	id.token.claim
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	true	access.token.claim
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	website	claim.name
09d54750-5aac-4c67-a2b0-8f06c1a9e4fd	String	jsonType.label
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	true	introspection.token.claim
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	true	userinfo.token.claim
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	birthdate	user.attribute
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	true	id.token.claim
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	true	access.token.claim
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	birthdate	claim.name
0c3b9fc2-6bf0-42e0-ac95-7a2cf8597aaf	String	jsonType.label
4454162c-9871-47b6-b567-d65d2b877df4	true	introspection.token.claim
4454162c-9871-47b6-b567-d65d2b877df4	true	userinfo.token.claim
4454162c-9871-47b6-b567-d65d2b877df4	picture	user.attribute
4454162c-9871-47b6-b567-d65d2b877df4	true	id.token.claim
4454162c-9871-47b6-b567-d65d2b877df4	true	access.token.claim
4454162c-9871-47b6-b567-d65d2b877df4	picture	claim.name
4454162c-9871-47b6-b567-d65d2b877df4	String	jsonType.label
514afdec-11a4-46ca-b44a-4508c4caae32	true	introspection.token.claim
514afdec-11a4-46ca-b44a-4508c4caae32	true	userinfo.token.claim
514afdec-11a4-46ca-b44a-4508c4caae32	middleName	user.attribute
514afdec-11a4-46ca-b44a-4508c4caae32	true	id.token.claim
514afdec-11a4-46ca-b44a-4508c4caae32	true	access.token.claim
514afdec-11a4-46ca-b44a-4508c4caae32	middle_name	claim.name
514afdec-11a4-46ca-b44a-4508c4caae32	String	jsonType.label
65524193-abeb-479e-a1fe-4c46abcd1975	true	introspection.token.claim
65524193-abeb-479e-a1fe-4c46abcd1975	true	userinfo.token.claim
65524193-abeb-479e-a1fe-4c46abcd1975	firstName	user.attribute
65524193-abeb-479e-a1fe-4c46abcd1975	true	id.token.claim
65524193-abeb-479e-a1fe-4c46abcd1975	true	access.token.claim
65524193-abeb-479e-a1fe-4c46abcd1975	given_name	claim.name
65524193-abeb-479e-a1fe-4c46abcd1975	String	jsonType.label
a175a9fd-2545-4f86-8a56-bf0c1307d770	true	introspection.token.claim
a175a9fd-2545-4f86-8a56-bf0c1307d770	true	userinfo.token.claim
a175a9fd-2545-4f86-8a56-bf0c1307d770	locale	user.attribute
a175a9fd-2545-4f86-8a56-bf0c1307d770	true	id.token.claim
a175a9fd-2545-4f86-8a56-bf0c1307d770	true	access.token.claim
a175a9fd-2545-4f86-8a56-bf0c1307d770	locale	claim.name
a175a9fd-2545-4f86-8a56-bf0c1307d770	String	jsonType.label
a50f6a76-224a-459b-b793-4b76994d972a	true	introspection.token.claim
a50f6a76-224a-459b-b793-4b76994d972a	true	userinfo.token.claim
a50f6a76-224a-459b-b793-4b76994d972a	gender	user.attribute
a50f6a76-224a-459b-b793-4b76994d972a	true	id.token.claim
a50f6a76-224a-459b-b793-4b76994d972a	true	access.token.claim
a50f6a76-224a-459b-b793-4b76994d972a	gender	claim.name
a50f6a76-224a-459b-b793-4b76994d972a	String	jsonType.label
ab7a7520-e32c-45e7-990d-95ffdcc92b31	true	introspection.token.claim
ab7a7520-e32c-45e7-990d-95ffdcc92b31	true	userinfo.token.claim
ab7a7520-e32c-45e7-990d-95ffdcc92b31	true	id.token.claim
ab7a7520-e32c-45e7-990d-95ffdcc92b31	true	access.token.claim
ae91d074-5b39-467a-ab17-0719caadf9eb	true	introspection.token.claim
ae91d074-5b39-467a-ab17-0719caadf9eb	true	userinfo.token.claim
ae91d074-5b39-467a-ab17-0719caadf9eb	updatedAt	user.attribute
ae91d074-5b39-467a-ab17-0719caadf9eb	true	id.token.claim
ae91d074-5b39-467a-ab17-0719caadf9eb	true	access.token.claim
ae91d074-5b39-467a-ab17-0719caadf9eb	updated_at	claim.name
ae91d074-5b39-467a-ab17-0719caadf9eb	long	jsonType.label
b02a75cf-a429-4bc7-8939-00f3ca8901c6	true	introspection.token.claim
b02a75cf-a429-4bc7-8939-00f3ca8901c6	true	userinfo.token.claim
b02a75cf-a429-4bc7-8939-00f3ca8901c6	lastName	user.attribute
b02a75cf-a429-4bc7-8939-00f3ca8901c6	true	id.token.claim
b02a75cf-a429-4bc7-8939-00f3ca8901c6	true	access.token.claim
b02a75cf-a429-4bc7-8939-00f3ca8901c6	family_name	claim.name
b02a75cf-a429-4bc7-8939-00f3ca8901c6	String	jsonType.label
bec56e67-2a2c-491c-bf12-b696e721adbe	true	introspection.token.claim
bec56e67-2a2c-491c-bf12-b696e721adbe	true	userinfo.token.claim
bec56e67-2a2c-491c-bf12-b696e721adbe	profile	user.attribute
bec56e67-2a2c-491c-bf12-b696e721adbe	true	id.token.claim
bec56e67-2a2c-491c-bf12-b696e721adbe	true	access.token.claim
bec56e67-2a2c-491c-bf12-b696e721adbe	profile	claim.name
bec56e67-2a2c-491c-bf12-b696e721adbe	String	jsonType.label
cab040f7-6085-47ee-80bd-0ad3beb48b49	true	introspection.token.claim
cab040f7-6085-47ee-80bd-0ad3beb48b49	true	userinfo.token.claim
cab040f7-6085-47ee-80bd-0ad3beb48b49	nickname	user.attribute
cab040f7-6085-47ee-80bd-0ad3beb48b49	true	id.token.claim
cab040f7-6085-47ee-80bd-0ad3beb48b49	true	access.token.claim
cab040f7-6085-47ee-80bd-0ad3beb48b49	nickname	claim.name
cab040f7-6085-47ee-80bd-0ad3beb48b49	String	jsonType.label
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	true	introspection.token.claim
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	true	userinfo.token.claim
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	zoneinfo	user.attribute
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	true	id.token.claim
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	true	access.token.claim
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	zoneinfo	claim.name
dd3535fe-3be6-48cc-bd10-8146bb4dbc9c	String	jsonType.label
380d03f8-013a-4764-b808-d3d39b293383	true	introspection.token.claim
380d03f8-013a-4764-b808-d3d39b293383	true	userinfo.token.claim
380d03f8-013a-4764-b808-d3d39b293383	email	user.attribute
380d03f8-013a-4764-b808-d3d39b293383	true	id.token.claim
380d03f8-013a-4764-b808-d3d39b293383	true	access.token.claim
380d03f8-013a-4764-b808-d3d39b293383	email	claim.name
380d03f8-013a-4764-b808-d3d39b293383	String	jsonType.label
aca61d1a-0133-44de-9b56-61a12d9f925e	true	introspection.token.claim
aca61d1a-0133-44de-9b56-61a12d9f925e	true	userinfo.token.claim
aca61d1a-0133-44de-9b56-61a12d9f925e	emailVerified	user.attribute
aca61d1a-0133-44de-9b56-61a12d9f925e	true	id.token.claim
aca61d1a-0133-44de-9b56-61a12d9f925e	true	access.token.claim
aca61d1a-0133-44de-9b56-61a12d9f925e	email_verified	claim.name
aca61d1a-0133-44de-9b56-61a12d9f925e	boolean	jsonType.label
13284fa7-b346-4f25-81e1-0168db3c5568	formatted	user.attribute.formatted
13284fa7-b346-4f25-81e1-0168db3c5568	country	user.attribute.country
13284fa7-b346-4f25-81e1-0168db3c5568	true	introspection.token.claim
13284fa7-b346-4f25-81e1-0168db3c5568	postal_code	user.attribute.postal_code
13284fa7-b346-4f25-81e1-0168db3c5568	true	userinfo.token.claim
13284fa7-b346-4f25-81e1-0168db3c5568	street	user.attribute.street
13284fa7-b346-4f25-81e1-0168db3c5568	true	id.token.claim
13284fa7-b346-4f25-81e1-0168db3c5568	region	user.attribute.region
13284fa7-b346-4f25-81e1-0168db3c5568	true	access.token.claim
13284fa7-b346-4f25-81e1-0168db3c5568	locality	user.attribute.locality
aec47577-df86-4fa8-af49-21a6b7c9e5b3	true	introspection.token.claim
aec47577-df86-4fa8-af49-21a6b7c9e5b3	true	userinfo.token.claim
aec47577-df86-4fa8-af49-21a6b7c9e5b3	phoneNumber	user.attribute
aec47577-df86-4fa8-af49-21a6b7c9e5b3	true	id.token.claim
aec47577-df86-4fa8-af49-21a6b7c9e5b3	true	access.token.claim
aec47577-df86-4fa8-af49-21a6b7c9e5b3	phone_number	claim.name
aec47577-df86-4fa8-af49-21a6b7c9e5b3	String	jsonType.label
f77e6c76-9297-4355-af97-c7155f3dfe1a	true	introspection.token.claim
f77e6c76-9297-4355-af97-c7155f3dfe1a	true	userinfo.token.claim
f77e6c76-9297-4355-af97-c7155f3dfe1a	phoneNumberVerified	user.attribute
f77e6c76-9297-4355-af97-c7155f3dfe1a	true	id.token.claim
f77e6c76-9297-4355-af97-c7155f3dfe1a	true	access.token.claim
f77e6c76-9297-4355-af97-c7155f3dfe1a	phone_number_verified	claim.name
f77e6c76-9297-4355-af97-c7155f3dfe1a	boolean	jsonType.label
6099a445-ba2c-4477-ac57-66396a971cc6	true	introspection.token.claim
6099a445-ba2c-4477-ac57-66396a971cc6	true	multivalued
6099a445-ba2c-4477-ac57-66396a971cc6	foo	user.attribute
6099a445-ba2c-4477-ac57-66396a971cc6	true	access.token.claim
6099a445-ba2c-4477-ac57-66396a971cc6	resource_access.${client_id}.roles	claim.name
6099a445-ba2c-4477-ac57-66396a971cc6	String	jsonType.label
6115efa2-8ac3-4732-ab51-2e15b5c09306	true	introspection.token.claim
6115efa2-8ac3-4732-ab51-2e15b5c09306	true	access.token.claim
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	true	introspection.token.claim
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	true	multivalued
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	foo	user.attribute
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	true	access.token.claim
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	realm_access.roles	claim.name
c8cc89e4-5e25-413e-a1d9-fccf0a56b716	String	jsonType.label
a511ac78-a2bc-4bc0-8d85-08d9c06f3f90	true	introspection.token.claim
a511ac78-a2bc-4bc0-8d85-08d9c06f3f90	true	access.token.claim
2b1a1ba9-e179-4707-90e6-b2561e09acae	true	introspection.token.claim
2b1a1ba9-e179-4707-90e6-b2561e09acae	true	userinfo.token.claim
2b1a1ba9-e179-4707-90e6-b2561e09acae	username	user.attribute
2b1a1ba9-e179-4707-90e6-b2561e09acae	true	id.token.claim
2b1a1ba9-e179-4707-90e6-b2561e09acae	true	access.token.claim
2b1a1ba9-e179-4707-90e6-b2561e09acae	upn	claim.name
2b1a1ba9-e179-4707-90e6-b2561e09acae	String	jsonType.label
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	true	introspection.token.claim
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	true	multivalued
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	foo	user.attribute
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	true	id.token.claim
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	true	access.token.claim
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	groups	claim.name
80d7a86d-970d-4992-9bb6-ff8f60ec22ca	String	jsonType.label
be71c879-11ac-4345-84da-48c723e60569	true	introspection.token.claim
be71c879-11ac-4345-84da-48c723e60569	true	id.token.claim
be71c879-11ac-4345-84da-48c723e60569	true	access.token.claim
ba581428-f3c5-4af5-b7c1-5486ba3a4314	false	single
ba581428-f3c5-4af5-b7c1-5486ba3a4314	Basic	attribute.nameformat
ba581428-f3c5-4af5-b7c1-5486ba3a4314	Role	attribute.name
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	true	introspection.token.claim
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	true	userinfo.token.claim
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	picture	user.attribute
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	true	id.token.claim
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	true	access.token.claim
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	picture	claim.name
04d704b4-9d07-4e7a-ac4b-d6d5abdb1796	String	jsonType.label
061bedbd-7676-42f9-9cb5-8e63f60c202c	true	introspection.token.claim
061bedbd-7676-42f9-9cb5-8e63f60c202c	true	userinfo.token.claim
061bedbd-7676-42f9-9cb5-8e63f60c202c	middleName	user.attribute
061bedbd-7676-42f9-9cb5-8e63f60c202c	true	id.token.claim
061bedbd-7676-42f9-9cb5-8e63f60c202c	true	access.token.claim
061bedbd-7676-42f9-9cb5-8e63f60c202c	middle_name	claim.name
061bedbd-7676-42f9-9cb5-8e63f60c202c	String	jsonType.label
0664c366-6965-4c8f-a135-523bf9c1147f	true	introspection.token.claim
0664c366-6965-4c8f-a135-523bf9c1147f	true	userinfo.token.claim
0664c366-6965-4c8f-a135-523bf9c1147f	birthdate	user.attribute
0664c366-6965-4c8f-a135-523bf9c1147f	true	id.token.claim
0664c366-6965-4c8f-a135-523bf9c1147f	true	access.token.claim
0664c366-6965-4c8f-a135-523bf9c1147f	birthdate	claim.name
0664c366-6965-4c8f-a135-523bf9c1147f	String	jsonType.label
2d495d2b-1bbf-4bf0-80f8-a8e50b6f9e64	true	introspection.token.claim
2d495d2b-1bbf-4bf0-80f8-a8e50b6f9e64	true	userinfo.token.claim
2d495d2b-1bbf-4bf0-80f8-a8e50b6f9e64	true	id.token.claim
2d495d2b-1bbf-4bf0-80f8-a8e50b6f9e64	true	access.token.claim
346a8f91-8195-40d9-8e14-255e2f501c1c	true	introspection.token.claim
346a8f91-8195-40d9-8e14-255e2f501c1c	true	userinfo.token.claim
346a8f91-8195-40d9-8e14-255e2f501c1c	gender	user.attribute
346a8f91-8195-40d9-8e14-255e2f501c1c	true	id.token.claim
346a8f91-8195-40d9-8e14-255e2f501c1c	true	access.token.claim
346a8f91-8195-40d9-8e14-255e2f501c1c	gender	claim.name
346a8f91-8195-40d9-8e14-255e2f501c1c	String	jsonType.label
3ef9afd9-09c2-4779-a56b-33ffd8714d36	true	introspection.token.claim
3ef9afd9-09c2-4779-a56b-33ffd8714d36	true	userinfo.token.claim
3ef9afd9-09c2-4779-a56b-33ffd8714d36	profile	user.attribute
3ef9afd9-09c2-4779-a56b-33ffd8714d36	true	id.token.claim
3ef9afd9-09c2-4779-a56b-33ffd8714d36	true	access.token.claim
3ef9afd9-09c2-4779-a56b-33ffd8714d36	profile	claim.name
3ef9afd9-09c2-4779-a56b-33ffd8714d36	String	jsonType.label
46d2fe5f-8611-4fe9-b5a8-08399431e856	true	introspection.token.claim
46d2fe5f-8611-4fe9-b5a8-08399431e856	true	userinfo.token.claim
46d2fe5f-8611-4fe9-b5a8-08399431e856	firstName	user.attribute
46d2fe5f-8611-4fe9-b5a8-08399431e856	true	id.token.claim
46d2fe5f-8611-4fe9-b5a8-08399431e856	true	access.token.claim
46d2fe5f-8611-4fe9-b5a8-08399431e856	given_name	claim.name
46d2fe5f-8611-4fe9-b5a8-08399431e856	String	jsonType.label
46e175d1-4d16-4a4e-a833-90da0272efac	true	introspection.token.claim
46e175d1-4d16-4a4e-a833-90da0272efac	true	userinfo.token.claim
46e175d1-4d16-4a4e-a833-90da0272efac	locale	user.attribute
46e175d1-4d16-4a4e-a833-90da0272efac	true	id.token.claim
46e175d1-4d16-4a4e-a833-90da0272efac	true	access.token.claim
46e175d1-4d16-4a4e-a833-90da0272efac	locale	claim.name
46e175d1-4d16-4a4e-a833-90da0272efac	String	jsonType.label
675225b9-ad21-4a51-af27-887deb8e9f35	true	introspection.token.claim
675225b9-ad21-4a51-af27-887deb8e9f35	true	userinfo.token.claim
675225b9-ad21-4a51-af27-887deb8e9f35	lastName	user.attribute
675225b9-ad21-4a51-af27-887deb8e9f35	true	id.token.claim
675225b9-ad21-4a51-af27-887deb8e9f35	true	access.token.claim
675225b9-ad21-4a51-af27-887deb8e9f35	family_name	claim.name
675225b9-ad21-4a51-af27-887deb8e9f35	String	jsonType.label
899ce4b9-4654-43db-b8de-c9155681d61f	true	introspection.token.claim
899ce4b9-4654-43db-b8de-c9155681d61f	true	userinfo.token.claim
899ce4b9-4654-43db-b8de-c9155681d61f	zoneinfo	user.attribute
899ce4b9-4654-43db-b8de-c9155681d61f	true	id.token.claim
899ce4b9-4654-43db-b8de-c9155681d61f	true	access.token.claim
899ce4b9-4654-43db-b8de-c9155681d61f	zoneinfo	claim.name
899ce4b9-4654-43db-b8de-c9155681d61f	String	jsonType.label
9cb84501-b078-40a7-a64f-2d159aec0bfb	true	introspection.token.claim
9cb84501-b078-40a7-a64f-2d159aec0bfb	true	userinfo.token.claim
9cb84501-b078-40a7-a64f-2d159aec0bfb	website	user.attribute
9cb84501-b078-40a7-a64f-2d159aec0bfb	true	id.token.claim
9cb84501-b078-40a7-a64f-2d159aec0bfb	true	access.token.claim
9cb84501-b078-40a7-a64f-2d159aec0bfb	website	claim.name
9cb84501-b078-40a7-a64f-2d159aec0bfb	String	jsonType.label
c6a7e90f-5e60-43ae-b687-170101e4b3b5	true	introspection.token.claim
c6a7e90f-5e60-43ae-b687-170101e4b3b5	true	userinfo.token.claim
c6a7e90f-5e60-43ae-b687-170101e4b3b5	updatedAt	user.attribute
c6a7e90f-5e60-43ae-b687-170101e4b3b5	true	id.token.claim
c6a7e90f-5e60-43ae-b687-170101e4b3b5	true	access.token.claim
c6a7e90f-5e60-43ae-b687-170101e4b3b5	updated_at	claim.name
c6a7e90f-5e60-43ae-b687-170101e4b3b5	long	jsonType.label
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	true	introspection.token.claim
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	true	userinfo.token.claim
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	username	user.attribute
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	true	id.token.claim
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	true	access.token.claim
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	preferred_username	claim.name
e6d96dfa-b13d-4bb7-8bf5-7a4de855d878	String	jsonType.label
f841408c-d3a1-434d-8d56-3edac8930fdd	true	introspection.token.claim
f841408c-d3a1-434d-8d56-3edac8930fdd	true	userinfo.token.claim
f841408c-d3a1-434d-8d56-3edac8930fdd	nickname	user.attribute
f841408c-d3a1-434d-8d56-3edac8930fdd	true	id.token.claim
f841408c-d3a1-434d-8d56-3edac8930fdd	true	access.token.claim
f841408c-d3a1-434d-8d56-3edac8930fdd	nickname	claim.name
f841408c-d3a1-434d-8d56-3edac8930fdd	String	jsonType.label
8bda2814-2bac-44b7-b95e-863f5dd39055	true	introspection.token.claim
8bda2814-2bac-44b7-b95e-863f5dd39055	true	userinfo.token.claim
8bda2814-2bac-44b7-b95e-863f5dd39055	email	user.attribute
8bda2814-2bac-44b7-b95e-863f5dd39055	true	id.token.claim
8bda2814-2bac-44b7-b95e-863f5dd39055	true	access.token.claim
8bda2814-2bac-44b7-b95e-863f5dd39055	email	claim.name
8bda2814-2bac-44b7-b95e-863f5dd39055	String	jsonType.label
f5deb462-fbc7-4a5d-85df-29d3f891e683	true	introspection.token.claim
f5deb462-fbc7-4a5d-85df-29d3f891e683	true	userinfo.token.claim
f5deb462-fbc7-4a5d-85df-29d3f891e683	emailVerified	user.attribute
f5deb462-fbc7-4a5d-85df-29d3f891e683	true	id.token.claim
f5deb462-fbc7-4a5d-85df-29d3f891e683	true	access.token.claim
f5deb462-fbc7-4a5d-85df-29d3f891e683	email_verified	claim.name
f5deb462-fbc7-4a5d-85df-29d3f891e683	boolean	jsonType.label
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	formatted	user.attribute.formatted
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	country	user.attribute.country
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	true	introspection.token.claim
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	postal_code	user.attribute.postal_code
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	true	userinfo.token.claim
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	street	user.attribute.street
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	true	id.token.claim
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	region	user.attribute.region
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	true	access.token.claim
fe9f0075-74e4-4bce-b358-8b681bbaa1a9	locality	user.attribute.locality
878b8d5a-1c75-4eac-a848-eaa03fb957ab	true	introspection.token.claim
878b8d5a-1c75-4eac-a848-eaa03fb957ab	true	userinfo.token.claim
878b8d5a-1c75-4eac-a848-eaa03fb957ab	phoneNumber	user.attribute
878b8d5a-1c75-4eac-a848-eaa03fb957ab	true	id.token.claim
878b8d5a-1c75-4eac-a848-eaa03fb957ab	true	access.token.claim
878b8d5a-1c75-4eac-a848-eaa03fb957ab	phone_number	claim.name
878b8d5a-1c75-4eac-a848-eaa03fb957ab	String	jsonType.label
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	true	introspection.token.claim
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	true	userinfo.token.claim
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	phoneNumberVerified	user.attribute
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	true	id.token.claim
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	true	access.token.claim
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	phone_number_verified	claim.name
eaf270e1-80cf-43b0-aa5d-aa4415a642a5	boolean	jsonType.label
04d991ba-fb6c-4ff2-af93-0e991f87dd76	true	introspection.token.claim
04d991ba-fb6c-4ff2-af93-0e991f87dd76	true	multivalued
04d991ba-fb6c-4ff2-af93-0e991f87dd76	foo	user.attribute
04d991ba-fb6c-4ff2-af93-0e991f87dd76	true	access.token.claim
04d991ba-fb6c-4ff2-af93-0e991f87dd76	resource_access.${client_id}.roles	claim.name
04d991ba-fb6c-4ff2-af93-0e991f87dd76	String	jsonType.label
35416da6-94ef-41fd-8831-b58a693d4356	true	introspection.token.claim
35416da6-94ef-41fd-8831-b58a693d4356	true	multivalued
35416da6-94ef-41fd-8831-b58a693d4356	foo	user.attribute
35416da6-94ef-41fd-8831-b58a693d4356	true	access.token.claim
35416da6-94ef-41fd-8831-b58a693d4356	realm_access.roles	claim.name
35416da6-94ef-41fd-8831-b58a693d4356	String	jsonType.label
62e3dccb-ce62-45b7-b0b2-69e35d77326b	true	introspection.token.claim
62e3dccb-ce62-45b7-b0b2-69e35d77326b	true	access.token.claim
37e33701-4d52-4b8e-b69c-e72959baa3d0	true	introspection.token.claim
37e33701-4d52-4b8e-b69c-e72959baa3d0	true	access.token.claim
5e5f93fd-a72d-4038-8258-593d1d02f9aa	true	introspection.token.claim
5e5f93fd-a72d-4038-8258-593d1d02f9aa	true	userinfo.token.claim
5e5f93fd-a72d-4038-8258-593d1d02f9aa	username	user.attribute
5e5f93fd-a72d-4038-8258-593d1d02f9aa	true	id.token.claim
5e5f93fd-a72d-4038-8258-593d1d02f9aa	true	access.token.claim
5e5f93fd-a72d-4038-8258-593d1d02f9aa	upn	claim.name
5e5f93fd-a72d-4038-8258-593d1d02f9aa	String	jsonType.label
b96e8ba0-cf1a-428b-a015-ab487d902001	true	introspection.token.claim
b96e8ba0-cf1a-428b-a015-ab487d902001	true	multivalued
b96e8ba0-cf1a-428b-a015-ab487d902001	foo	user.attribute
b96e8ba0-cf1a-428b-a015-ab487d902001	true	id.token.claim
b96e8ba0-cf1a-428b-a015-ab487d902001	true	access.token.claim
b96e8ba0-cf1a-428b-a015-ab487d902001	groups	claim.name
b96e8ba0-cf1a-428b-a015-ab487d902001	String	jsonType.label
67319cbe-116e-48d2-827d-b5971d8fa4cf	true	introspection.token.claim
67319cbe-116e-48d2-827d-b5971d8fa4cf	true	id.token.claim
67319cbe-116e-48d2-827d-b5971d8fa4cf	true	access.token.claim
d4986728-720c-414a-85de-1c7abeb9b4a6	true	introspection.token.claim
d4986728-720c-414a-85de-1c7abeb9b4a6	true	userinfo.token.claim
d4986728-720c-414a-85de-1c7abeb9b4a6	locale	user.attribute
d4986728-720c-414a-85de-1c7abeb9b4a6	true	id.token.claim
d4986728-720c-414a-85de-1c7abeb9b4a6	true	access.token.claim
d4986728-720c-414a-85de-1c7abeb9b4a6	locale	claim.name
d4986728-720c-414a-85de-1c7abeb9b4a6	String	jsonType.label
\.


--
-- Data for Name: realm; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm (id, access_code_lifespan, user_action_lifespan, access_token_lifespan, account_theme, admin_theme, email_theme, enabled, events_enabled, events_expiration, login_theme, name, not_before, password_policy, registration_allowed, remember_me, reset_password_allowed, social, ssl_required, sso_idle_timeout, sso_max_lifespan, update_profile_on_soc_login, verify_email, master_admin_client, login_lifespan, internationalization_enabled, default_locale, reg_email_as_username, admin_events_enabled, admin_events_details_enabled, edit_username_allowed, otp_policy_counter, otp_policy_window, otp_policy_period, otp_policy_digits, otp_policy_alg, otp_policy_type, browser_flow, registration_flow, direct_grant_flow, reset_credentials_flow, client_auth_flow, offline_session_idle_timeout, revoke_refresh_token, access_token_life_implicit, login_with_email_allowed, duplicate_emails_allowed, docker_auth_flow, refresh_token_max_reuse, allow_user_managed_access, sso_max_lifespan_remember_me, sso_idle_timeout_remember_me, default_role) FROM stdin;
26848019-e2da-4775-a3ad-60ce8c6173f2	60	300	3600	\N	\N	\N	t	f	0	\N	maskanyone	0	\N	f	t	f	f	EXTERNAL	10800	86400	f	f	bf4b0124-6dbe-4947-92a3-c28ae427642f	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	94aa729f-ad78-4dc9-b511-3a4a1efa5ec9	4503b87d-2e6b-4e75-9754-e971da575a2d	a98e6219-9416-4395-bcef-62cfd524197b	ed5e2d9c-d256-4827-84d0-4a6a7ec3c501	a74f4001-7bc6-468f-bd31-111576eb68c7	2592000	f	3600	t	f	bd929695-e425-423c-a0e5-c513b40f5c5f	0	f	7776000	2592000	16d47a9d-16a5-4aab-bf57-945c2e783eba
def58135-f6f9-494c-b177-21c2d610717d	60	300	60	\N	\N	\N	t	f	0	\N	master	0	\N	f	f	f	f	EXTERNAL	1800	36000	f	f	7026036f-3ce5-4357-831a-544680b316b4	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	0f63d3ca-1a92-43cf-8b6f-1ea93c9a47f0	55688f4b-42df-4969-9957-15c6099759e6	80521110-e051-4613-882a-3e1f30d23174	7b06330b-14b8-4d35-bf40-3dc344f89b99	11c7742e-dad9-45e2-bea9-8686ebaf815f	2592000	f	900	t	f	dbc20a4b-c64f-4776-a2a2-676c8d94e6ad	0	f	0	0	473daa87-403d-43d2-a630-f2bed71ec503
\.


--
-- Data for Name: realm_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_attribute (name, realm_id, value) FROM stdin;
_browser_header.contentSecurityPolicyReportOnly	def58135-f6f9-494c-b177-21c2d610717d	
_browser_header.xContentTypeOptions	def58135-f6f9-494c-b177-21c2d610717d	nosniff
_browser_header.referrerPolicy	def58135-f6f9-494c-b177-21c2d610717d	no-referrer
_browser_header.xRobotsTag	def58135-f6f9-494c-b177-21c2d610717d	none
_browser_header.xFrameOptions	def58135-f6f9-494c-b177-21c2d610717d	SAMEORIGIN
_browser_header.contentSecurityPolicy	def58135-f6f9-494c-b177-21c2d610717d	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.xXSSProtection	def58135-f6f9-494c-b177-21c2d610717d	1; mode=block
_browser_header.strictTransportSecurity	def58135-f6f9-494c-b177-21c2d610717d	max-age=31536000; includeSubDomains
bruteForceProtected	def58135-f6f9-494c-b177-21c2d610717d	false
permanentLockout	def58135-f6f9-494c-b177-21c2d610717d	false
maxFailureWaitSeconds	def58135-f6f9-494c-b177-21c2d610717d	900
minimumQuickLoginWaitSeconds	def58135-f6f9-494c-b177-21c2d610717d	60
waitIncrementSeconds	def58135-f6f9-494c-b177-21c2d610717d	60
quickLoginCheckMilliSeconds	def58135-f6f9-494c-b177-21c2d610717d	1000
maxDeltaTimeSeconds	def58135-f6f9-494c-b177-21c2d610717d	43200
failureFactor	def58135-f6f9-494c-b177-21c2d610717d	30
realmReusableOtpCode	def58135-f6f9-494c-b177-21c2d610717d	false
displayName	def58135-f6f9-494c-b177-21c2d610717d	Keycloak
displayNameHtml	def58135-f6f9-494c-b177-21c2d610717d	<div class="kc-logo-text"><span>Keycloak</span></div>
defaultSignatureAlgorithm	def58135-f6f9-494c-b177-21c2d610717d	RS256
offlineSessionMaxLifespanEnabled	def58135-f6f9-494c-b177-21c2d610717d	false
offlineSessionMaxLifespan	def58135-f6f9-494c-b177-21c2d610717d	5184000
shortVerificationUri	26848019-e2da-4775-a3ad-60ce8c6173f2	
actionTokenGeneratedByUserLifespan.verify-email	26848019-e2da-4775-a3ad-60ce8c6173f2	
actionTokenGeneratedByUserLifespan.idp-verify-account-via-email	26848019-e2da-4775-a3ad-60ce8c6173f2	
actionTokenGeneratedByUserLifespan.reset-credentials	26848019-e2da-4775-a3ad-60ce8c6173f2	
actionTokenGeneratedByUserLifespan.execute-actions	26848019-e2da-4775-a3ad-60ce8c6173f2	
bruteForceProtected	26848019-e2da-4775-a3ad-60ce8c6173f2	false
permanentLockout	26848019-e2da-4775-a3ad-60ce8c6173f2	false
maxFailureWaitSeconds	26848019-e2da-4775-a3ad-60ce8c6173f2	900
minimumQuickLoginWaitSeconds	26848019-e2da-4775-a3ad-60ce8c6173f2	60
waitIncrementSeconds	26848019-e2da-4775-a3ad-60ce8c6173f2	60
quickLoginCheckMilliSeconds	26848019-e2da-4775-a3ad-60ce8c6173f2	1000
maxDeltaTimeSeconds	26848019-e2da-4775-a3ad-60ce8c6173f2	43200
failureFactor	26848019-e2da-4775-a3ad-60ce8c6173f2	30
actionTokenGeneratedByAdminLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	43200
actionTokenGeneratedByUserLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	300
defaultSignatureAlgorithm	26848019-e2da-4775-a3ad-60ce8c6173f2	RS256
realmReusableOtpCode	26848019-e2da-4775-a3ad-60ce8c6173f2	false
offlineSessionMaxLifespanEnabled	26848019-e2da-4775-a3ad-60ce8c6173f2	false
offlineSessionMaxLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	5184000
webAuthnPolicyRpEntityName	26848019-e2da-4775-a3ad-60ce8c6173f2	keycloak
webAuthnPolicySignatureAlgorithms	26848019-e2da-4775-a3ad-60ce8c6173f2	ES256
webAuthnPolicyRpId	26848019-e2da-4775-a3ad-60ce8c6173f2	
oauth2DeviceCodeLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	600
oauth2DevicePollingInterval	26848019-e2da-4775-a3ad-60ce8c6173f2	5
webAuthnPolicyAttestationConveyancePreference	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyAuthenticatorAttachment	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyRequireResidentKey	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyUserVerificationRequirement	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyCreateTimeout	26848019-e2da-4775-a3ad-60ce8c6173f2	0
webAuthnPolicyAvoidSameAuthenticatorRegister	26848019-e2da-4775-a3ad-60ce8c6173f2	false
webAuthnPolicyRpEntityNamePasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	keycloak
webAuthnPolicySignatureAlgorithmsPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	ES256
webAuthnPolicyRpIdPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	
webAuthnPolicyAttestationConveyancePreferencePasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyAuthenticatorAttachmentPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyRequireResidentKeyPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyUserVerificationRequirementPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	not specified
webAuthnPolicyCreateTimeoutPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	0
webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless	26848019-e2da-4775-a3ad-60ce8c6173f2	false
client-policies.profiles	26848019-e2da-4775-a3ad-60ce8c6173f2	{"profiles":[]}
client-policies.policies	26848019-e2da-4775-a3ad-60ce8c6173f2	{"policies":[]}
_browser_header.contentSecurityPolicyReportOnly	26848019-e2da-4775-a3ad-60ce8c6173f2	
cibaBackchannelTokenDeliveryMode	26848019-e2da-4775-a3ad-60ce8c6173f2	poll
cibaExpiresIn	26848019-e2da-4775-a3ad-60ce8c6173f2	120
cibaInterval	26848019-e2da-4775-a3ad-60ce8c6173f2	5
cibaAuthRequestedUserHint	26848019-e2da-4775-a3ad-60ce8c6173f2	login_hint
parRequestUriLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	60
_browser_header.xContentTypeOptions	26848019-e2da-4775-a3ad-60ce8c6173f2	nosniff
_browser_header.referrerPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	no-referrer
_browser_header.xRobotsTag	26848019-e2da-4775-a3ad-60ce8c6173f2	none
_browser_header.xFrameOptions	26848019-e2da-4775-a3ad-60ce8c6173f2	SAMEORIGIN
_browser_header.contentSecurityPolicy	26848019-e2da-4775-a3ad-60ce8c6173f2	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.xXSSProtection	26848019-e2da-4775-a3ad-60ce8c6173f2	1; mode=block
_browser_header.strictTransportSecurity	26848019-e2da-4775-a3ad-60ce8c6173f2	max-age=31536000; includeSubDomains
clientSessionIdleTimeout	26848019-e2da-4775-a3ad-60ce8c6173f2	0
clientSessionMaxLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	0
clientOfflineSessionIdleTimeout	26848019-e2da-4775-a3ad-60ce8c6173f2	0
clientOfflineSessionMaxLifespan	26848019-e2da-4775-a3ad-60ce8c6173f2	0
\.


--
-- Data for Name: realm_default_groups; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_default_groups (realm_id, group_id) FROM stdin;
\.


--
-- Data for Name: realm_enabled_event_types; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_enabled_event_types (realm_id, value) FROM stdin;
\.


--
-- Data for Name: realm_events_listeners; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_events_listeners (realm_id, value) FROM stdin;
def58135-f6f9-494c-b177-21c2d610717d	jboss-logging
26848019-e2da-4775-a3ad-60ce8c6173f2	jboss-logging
\.


--
-- Data for Name: realm_localizations; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_localizations (realm_id, locale, texts) FROM stdin;
\.


--
-- Data for Name: realm_required_credential; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_required_credential (type, form_label, input, secret, realm_id) FROM stdin;
password	password	t	t	def58135-f6f9-494c-b177-21c2d610717d
password	password	t	t	26848019-e2da-4775-a3ad-60ce8c6173f2
\.


--
-- Data for Name: realm_smtp_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_smtp_config (realm_id, value, name) FROM stdin;
\.


--
-- Data for Name: realm_supported_locales; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_supported_locales (realm_id, value) FROM stdin;
\.


--
-- Data for Name: redirect_uris; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.redirect_uris (client_id, value) FROM stdin;
6a0cd2a0-1010-4a5e-bdfa-d20537224997	/realms/master/account/*
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	/realms/master/account/*
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	/admin/master/console/*
a56c5ce1-4e7c-4380-ab53-c3658986fa56	/realms/maskanyone/account/*
8e1e8954-7bec-4a60-8567-613e39ee594c	/realms/maskanyone/account/*
fbfe3dc5-e674-4324-8dc4-d00e64be6796	/admin/maskanyone/console/*
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	https://localhost/*
\.


--
-- Data for Name: required_action_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.required_action_config (required_action_id, value, name) FROM stdin;
\.


--
-- Data for Name: required_action_provider; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.required_action_provider (id, alias, name, realm_id, enabled, default_action, provider_id, priority) FROM stdin;
986fa53e-e824-4614-9c06-40e652401813	VERIFY_EMAIL	Verify Email	def58135-f6f9-494c-b177-21c2d610717d	t	f	VERIFY_EMAIL	50
4cbbe831-d109-47c3-86c5-e08d5071dcb1	UPDATE_PROFILE	Update Profile	def58135-f6f9-494c-b177-21c2d610717d	t	f	UPDATE_PROFILE	40
b574bc17-68c5-42b2-938d-1dbc6a2b3a3d	CONFIGURE_TOTP	Configure OTP	def58135-f6f9-494c-b177-21c2d610717d	t	f	CONFIGURE_TOTP	10
5a86ec79-051e-459b-a3c6-f25c1975f851	UPDATE_PASSWORD	Update Password	def58135-f6f9-494c-b177-21c2d610717d	t	f	UPDATE_PASSWORD	30
9bf27c19-1ca3-4617-b014-9febdc1c373a	TERMS_AND_CONDITIONS	Terms and Conditions	def58135-f6f9-494c-b177-21c2d610717d	f	f	TERMS_AND_CONDITIONS	20
080a3dc5-ecbe-42bc-a918-84b29eaf343b	delete_account	Delete Account	def58135-f6f9-494c-b177-21c2d610717d	f	f	delete_account	60
710bd638-faf6-4f18-86fa-d51450346eec	update_user_locale	Update User Locale	def58135-f6f9-494c-b177-21c2d610717d	t	f	update_user_locale	1000
d079f3c0-420f-4167-8ae5-1bdd13ffcdd9	webauthn-register	Webauthn Register	def58135-f6f9-494c-b177-21c2d610717d	t	f	webauthn-register	70
6f8ae19c-81e1-458f-804b-4884992dd77d	webauthn-register-passwordless	Webauthn Register Passwordless	def58135-f6f9-494c-b177-21c2d610717d	t	f	webauthn-register-passwordless	80
ff252d74-ff3d-4565-82d0-c8ee146a0394	VERIFY_EMAIL	Verify Email	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	VERIFY_EMAIL	50
dc9e3b41-81db-4406-9006-507a7545ddb1	UPDATE_PROFILE	Update Profile	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	UPDATE_PROFILE	40
16b8c2dd-2413-4e11-9976-0655f13a0095	CONFIGURE_TOTP	Configure OTP	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	CONFIGURE_TOTP	10
6a2fb02a-94f4-408a-912f-fc447771111f	UPDATE_PASSWORD	Update Password	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	UPDATE_PASSWORD	30
fd7601b2-6c2b-4137-827b-616650a5ca81	TERMS_AND_CONDITIONS	Terms and Conditions	26848019-e2da-4775-a3ad-60ce8c6173f2	f	f	TERMS_AND_CONDITIONS	20
ba640f37-bbbd-417f-b0d5-a4a293a74c8e	delete_account	Delete Account	26848019-e2da-4775-a3ad-60ce8c6173f2	f	f	delete_account	60
4ee2b6c4-b520-4d38-867c-e9d03ca10653	update_user_locale	Update User Locale	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	update_user_locale	1000
e28ea739-6e1c-4721-bb6f-2b05ba28754d	webauthn-register	Webauthn Register	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	webauthn-register	70
c970265a-2581-45ed-a66a-f6227cb0f6a3	webauthn-register-passwordless	Webauthn Register Passwordless	26848019-e2da-4775-a3ad-60ce8c6173f2	t	f	webauthn-register-passwordless	80
\.


--
-- Data for Name: resource_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_attribute (id, name, value, resource_id) FROM stdin;
\.


--
-- Data for Name: resource_policy; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_policy (resource_id, policy_id) FROM stdin;
\.


--
-- Data for Name: resource_scope; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_scope (resource_id, scope_id) FROM stdin;
\.


--
-- Data for Name: resource_server; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_server (id, allow_rs_remote_mgmt, policy_enforce_mode, decision_strategy) FROM stdin;
\.


--
-- Data for Name: resource_server_perm_ticket; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_server_perm_ticket (id, owner, requester, created_timestamp, granted_timestamp, resource_id, scope_id, resource_server_id, policy_id) FROM stdin;
\.


--
-- Data for Name: resource_server_policy; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_server_policy (id, name, description, type, decision_strategy, logic, resource_server_id, owner) FROM stdin;
\.


--
-- Data for Name: resource_server_resource; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_server_resource (id, name, type, icon_uri, owner, resource_server_id, owner_managed_access, display_name) FROM stdin;
\.


--
-- Data for Name: resource_server_scope; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_server_scope (id, name, icon_uri, resource_server_id, display_name) FROM stdin;
\.


--
-- Data for Name: resource_uris; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.resource_uris (resource_id, value) FROM stdin;
\.


--
-- Data for Name: role_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.role_attribute (id, role_id, name, value) FROM stdin;
\.


--
-- Data for Name: scope_mapping; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.scope_mapping (client_id, role_id) FROM stdin;
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	c0a795a3-9e5e-4f86-be82-03a5cc344d98
a8fe78fb-e4f0-4e78-b5bf-71ef027bd4c7	6019cd62-8aff-481f-9edc-85081c0b45b8
8e1e8954-7bec-4a60-8567-613e39ee594c	04473526-f292-4dfe-ba03-81bf5a364705
8e1e8954-7bec-4a60-8567-613e39ee594c	89fa0898-18c7-4db3-bd95-aebe022a2c37
\.


--
-- Data for Name: scope_policy; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.scope_policy (scope_id, policy_id) FROM stdin;
\.


--
-- Data for Name: user_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_attribute (name, value, user_id, id) FROM stdin;
\.


--
-- Data for Name: user_consent; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_consent (id, client_id, user_id, created_date, last_updated_date, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: user_consent_client_scope; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_consent_client_scope (user_consent_id, scope_id) FROM stdin;
\.


--
-- Data for Name: user_entity; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_entity (id, email, email_constraint, email_verified, enabled, federation_link, first_name, last_name, realm_id, username, created_timestamp, service_account_client_link, not_before) FROM stdin;
bf5e8280-f52c-42e3-a5e3-39484efc69c7	\N	ec6138b6-b01f-4f48-a840-5003db22bf37	f	t	\N	\N	\N	def58135-f6f9-494c-b177-21c2d610717d	dev	1707696472515	\N	0
3b8fe421-f59a-498e-92ad-a5a15567c4d5	test.user@hpi.de	test.user@hpi.de	f	t	\N	Test	User	26848019-e2da-4775-a3ad-60ce8c6173f2	test	1707696659054	\N	0
20a691bf-a2bd-44bc-9049-0d7955b176e0	test2.user@hpi.de	test2.user@hpi.de	f	t	\N	Test2	User	26848019-e2da-4775-a3ad-60ce8c6173f2	test2	1707696674914	\N	0
\.


--
-- Data for Name: user_federation_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_federation_config (user_federation_provider_id, value, name) FROM stdin;
\.


--
-- Data for Name: user_federation_mapper; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_federation_mapper (id, name, federation_provider_id, federation_mapper_type, realm_id) FROM stdin;
\.


--
-- Data for Name: user_federation_mapper_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_federation_mapper_config (user_federation_mapper_id, value, name) FROM stdin;
\.


--
-- Data for Name: user_federation_provider; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_federation_provider (id, changed_sync_period, display_name, full_sync_period, last_sync, priority, provider_name, realm_id) FROM stdin;
\.


--
-- Data for Name: user_group_membership; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_group_membership (group_id, user_id) FROM stdin;
\.


--
-- Data for Name: user_required_action; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_required_action (user_id, required_action) FROM stdin;
\.


--
-- Data for Name: user_role_mapping; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_role_mapping (role_id, user_id) FROM stdin;
473daa87-403d-43d2-a630-f2bed71ec503	bf5e8280-f52c-42e3-a5e3-39484efc69c7
6a614cf1-6c5f-44ac-bed4-6fb30d0712d9	bf5e8280-f52c-42e3-a5e3-39484efc69c7
60f6a924-36be-42f0-8354-5eca6466b15d	bf5e8280-f52c-42e3-a5e3-39484efc69c7
47a67318-5e33-47d4-be51-07ef9afea16f	bf5e8280-f52c-42e3-a5e3-39484efc69c7
1c56f3d3-a3f1-4d6a-a65a-e09d453a62c1	bf5e8280-f52c-42e3-a5e3-39484efc69c7
5a4f2979-5e2d-4344-a5e2-780bf31b0764	bf5e8280-f52c-42e3-a5e3-39484efc69c7
0c73944f-fbab-4fa3-888e-70ff3ea4de56	bf5e8280-f52c-42e3-a5e3-39484efc69c7
1f4c5eae-fa50-498f-9178-c19a11ca9647	bf5e8280-f52c-42e3-a5e3-39484efc69c7
5bc7f09b-dcdf-45dd-988c-8dcb7193e349	bf5e8280-f52c-42e3-a5e3-39484efc69c7
66f8a6f9-3a6c-49b3-a721-480d710377c5	bf5e8280-f52c-42e3-a5e3-39484efc69c7
2959b426-1990-4ebf-a4eb-2368f8e4418d	bf5e8280-f52c-42e3-a5e3-39484efc69c7
ed55f9f5-4ea7-471e-981a-f552d92efcc3	bf5e8280-f52c-42e3-a5e3-39484efc69c7
9f70bfe2-719a-4526-9d75-4de322b8c14e	bf5e8280-f52c-42e3-a5e3-39484efc69c7
29b70a3e-4253-4cb3-a265-7248c2515cee	bf5e8280-f52c-42e3-a5e3-39484efc69c7
d911c5b5-5112-4bd4-b202-e67af7afdd09	bf5e8280-f52c-42e3-a5e3-39484efc69c7
0b2b0fc3-e662-493d-b82a-c542cc0dee92	bf5e8280-f52c-42e3-a5e3-39484efc69c7
840720f3-47e0-4590-9256-dfd3241aea63	bf5e8280-f52c-42e3-a5e3-39484efc69c7
429ebaa9-4519-4d8c-8e17-dc8823e4e4c9	bf5e8280-f52c-42e3-a5e3-39484efc69c7
0010befa-9e09-47d1-9d75-75a873d23a57	bf5e8280-f52c-42e3-a5e3-39484efc69c7
16d47a9d-16a5-4aab-bf57-945c2e783eba	3b8fe421-f59a-498e-92ad-a5a15567c4d5
16d47a9d-16a5-4aab-bf57-945c2e783eba	20a691bf-a2bd-44bc-9049-0d7955b176e0
\.


--
-- Data for Name: user_session; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_session (id, auth_method, ip_address, last_session_refresh, login_username, realm_id, remember_me, started, user_id, user_session_state, broker_session_id, broker_user_id) FROM stdin;
\.


--
-- Data for Name: user_session_note; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.user_session_note (user_session, name, value) FROM stdin;
\.


--
-- Data for Name: username_login_failure; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.username_login_failure (realm_id, username, failed_login_not_before, last_failure, last_ip_failure, num_failures) FROM stdin;
\.


--
-- Data for Name: web_origins; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.web_origins (client_id, value) FROM stdin;
baa7050d-d58f-4ce0-8d94-8fd75a2096a0	+
fbfe3dc5-e674-4324-8dc4-d00e64be6796	+
3d24de0f-3ce8-419c-9ddb-fe45a7c0ee26	+
\.


--
-- Name: username_login_failure CONSTRAINT_17-2; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.username_login_failure
    ADD CONSTRAINT "CONSTRAINT_17-2" PRIMARY KEY (realm_id, username);


--
-- Name: keycloak_role UK_J3RWUVD56ONTGSUHOGM184WW2-2; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT "UK_J3RWUVD56ONTGSUHOGM184WW2-2" UNIQUE (name, client_realm_constraint);


--
-- Name: client_auth_flow_bindings c_cli_flow_bind; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_auth_flow_bindings
    ADD CONSTRAINT c_cli_flow_bind PRIMARY KEY (client_id, binding_name);


--
-- Name: client_scope_client c_cli_scope_bind; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope_client
    ADD CONSTRAINT c_cli_scope_bind PRIMARY KEY (client_id, scope_id);


--
-- Name: client_initial_access cnstr_client_init_acc_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_initial_access
    ADD CONSTRAINT cnstr_client_init_acc_pk PRIMARY KEY (id);


--
-- Name: realm_default_groups con_group_id_def_groups; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT con_group_id_def_groups UNIQUE (group_id);


--
-- Name: broker_link constr_broker_link_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.broker_link
    ADD CONSTRAINT constr_broker_link_pk PRIMARY KEY (identity_provider, user_id);


--
-- Name: client_user_session_note constr_cl_usr_ses_note; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_user_session_note
    ADD CONSTRAINT constr_cl_usr_ses_note PRIMARY KEY (client_session, name);


--
-- Name: component_config constr_component_config_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.component_config
    ADD CONSTRAINT constr_component_config_pk PRIMARY KEY (id);


--
-- Name: component constr_component_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT constr_component_pk PRIMARY KEY (id);


--
-- Name: fed_user_required_action constr_fed_required_action; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_required_action
    ADD CONSTRAINT constr_fed_required_action PRIMARY KEY (required_action, user_id);


--
-- Name: fed_user_attribute constr_fed_user_attr_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_attribute
    ADD CONSTRAINT constr_fed_user_attr_pk PRIMARY KEY (id);


--
-- Name: fed_user_consent constr_fed_user_consent_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_consent
    ADD CONSTRAINT constr_fed_user_consent_pk PRIMARY KEY (id);


--
-- Name: fed_user_credential constr_fed_user_cred_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_credential
    ADD CONSTRAINT constr_fed_user_cred_pk PRIMARY KEY (id);


--
-- Name: fed_user_group_membership constr_fed_user_group; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_group_membership
    ADD CONSTRAINT constr_fed_user_group PRIMARY KEY (group_id, user_id);


--
-- Name: fed_user_role_mapping constr_fed_user_role; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_role_mapping
    ADD CONSTRAINT constr_fed_user_role PRIMARY KEY (role_id, user_id);


--
-- Name: federated_user constr_federated_user; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.federated_user
    ADD CONSTRAINT constr_federated_user PRIMARY KEY (id);


--
-- Name: realm_default_groups constr_realm_default_groups; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT constr_realm_default_groups PRIMARY KEY (realm_id, group_id);


--
-- Name: realm_enabled_event_types constr_realm_enabl_event_types; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_enabled_event_types
    ADD CONSTRAINT constr_realm_enabl_event_types PRIMARY KEY (realm_id, value);


--
-- Name: realm_events_listeners constr_realm_events_listeners; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_events_listeners
    ADD CONSTRAINT constr_realm_events_listeners PRIMARY KEY (realm_id, value);


--
-- Name: realm_supported_locales constr_realm_supported_locales; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_supported_locales
    ADD CONSTRAINT constr_realm_supported_locales PRIMARY KEY (realm_id, value);


--
-- Name: identity_provider constraint_2b; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT constraint_2b PRIMARY KEY (internal_id);


--
-- Name: client_attributes constraint_3c; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_attributes
    ADD CONSTRAINT constraint_3c PRIMARY KEY (client_id, name);


--
-- Name: event_entity constraint_4; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.event_entity
    ADD CONSTRAINT constraint_4 PRIMARY KEY (id);


--
-- Name: federated_identity constraint_40; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.federated_identity
    ADD CONSTRAINT constraint_40 PRIMARY KEY (identity_provider, user_id);


--
-- Name: realm constraint_4a; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm
    ADD CONSTRAINT constraint_4a PRIMARY KEY (id);


--
-- Name: client_session_role constraint_5; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_role
    ADD CONSTRAINT constraint_5 PRIMARY KEY (client_session, role_id);


--
-- Name: user_session constraint_57; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_session
    ADD CONSTRAINT constraint_57 PRIMARY KEY (id);


--
-- Name: user_federation_provider constraint_5c; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_provider
    ADD CONSTRAINT constraint_5c PRIMARY KEY (id);


--
-- Name: client_session_note constraint_5e; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_note
    ADD CONSTRAINT constraint_5e PRIMARY KEY (client_session, name);


--
-- Name: client constraint_7; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT constraint_7 PRIMARY KEY (id);


--
-- Name: client_session constraint_8; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session
    ADD CONSTRAINT constraint_8 PRIMARY KEY (id);


--
-- Name: scope_mapping constraint_81; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.scope_mapping
    ADD CONSTRAINT constraint_81 PRIMARY KEY (client_id, role_id);


--
-- Name: client_node_registrations constraint_84; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_node_registrations
    ADD CONSTRAINT constraint_84 PRIMARY KEY (client_id, name);


--
-- Name: realm_attribute constraint_9; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_attribute
    ADD CONSTRAINT constraint_9 PRIMARY KEY (name, realm_id);


--
-- Name: realm_required_credential constraint_92; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_required_credential
    ADD CONSTRAINT constraint_92 PRIMARY KEY (realm_id, type);


--
-- Name: keycloak_role constraint_a; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT constraint_a PRIMARY KEY (id);


--
-- Name: admin_event_entity constraint_admin_event_entity; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.admin_event_entity
    ADD CONSTRAINT constraint_admin_event_entity PRIMARY KEY (id);


--
-- Name: authenticator_config_entry constraint_auth_cfg_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authenticator_config_entry
    ADD CONSTRAINT constraint_auth_cfg_pk PRIMARY KEY (authenticator_id, name);


--
-- Name: authentication_execution constraint_auth_exec_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT constraint_auth_exec_pk PRIMARY KEY (id);


--
-- Name: authentication_flow constraint_auth_flow_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authentication_flow
    ADD CONSTRAINT constraint_auth_flow_pk PRIMARY KEY (id);


--
-- Name: authenticator_config constraint_auth_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authenticator_config
    ADD CONSTRAINT constraint_auth_pk PRIMARY KEY (id);


--
-- Name: client_session_auth_status constraint_auth_status_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_auth_status
    ADD CONSTRAINT constraint_auth_status_pk PRIMARY KEY (client_session, authenticator);


--
-- Name: user_role_mapping constraint_c; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_role_mapping
    ADD CONSTRAINT constraint_c PRIMARY KEY (role_id, user_id);


--
-- Name: composite_role constraint_composite_role; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT constraint_composite_role PRIMARY KEY (composite, child_role);


--
-- Name: client_session_prot_mapper constraint_cs_pmp_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_prot_mapper
    ADD CONSTRAINT constraint_cs_pmp_pk PRIMARY KEY (client_session, protocol_mapper_id);


--
-- Name: identity_provider_config constraint_d; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider_config
    ADD CONSTRAINT constraint_d PRIMARY KEY (identity_provider_id, name);


--
-- Name: policy_config constraint_dpc; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.policy_config
    ADD CONSTRAINT constraint_dpc PRIMARY KEY (policy_id, name);


--
-- Name: realm_smtp_config constraint_e; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_smtp_config
    ADD CONSTRAINT constraint_e PRIMARY KEY (realm_id, name);


--
-- Name: credential constraint_f; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.credential
    ADD CONSTRAINT constraint_f PRIMARY KEY (id);


--
-- Name: user_federation_config constraint_f9; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_config
    ADD CONSTRAINT constraint_f9 PRIMARY KEY (user_federation_provider_id, name);


--
-- Name: resource_server_perm_ticket constraint_fapmt; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT constraint_fapmt PRIMARY KEY (id);


--
-- Name: resource_server_resource constraint_farsr; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT constraint_farsr PRIMARY KEY (id);


--
-- Name: resource_server_policy constraint_farsrp; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT constraint_farsrp PRIMARY KEY (id);


--
-- Name: associated_policy constraint_farsrpap; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT constraint_farsrpap PRIMARY KEY (policy_id, associated_policy_id);


--
-- Name: resource_policy constraint_farsrpp; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT constraint_farsrpp PRIMARY KEY (resource_id, policy_id);


--
-- Name: resource_server_scope constraint_farsrs; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT constraint_farsrs PRIMARY KEY (id);


--
-- Name: resource_scope constraint_farsrsp; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT constraint_farsrsp PRIMARY KEY (resource_id, scope_id);


--
-- Name: scope_policy constraint_farsrsps; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT constraint_farsrsps PRIMARY KEY (scope_id, policy_id);


--
-- Name: user_entity constraint_fb; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT constraint_fb PRIMARY KEY (id);


--
-- Name: user_federation_mapper_config constraint_fedmapper_cfg_pm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_mapper_config
    ADD CONSTRAINT constraint_fedmapper_cfg_pm PRIMARY KEY (user_federation_mapper_id, name);


--
-- Name: user_federation_mapper constraint_fedmapperpm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT constraint_fedmapperpm PRIMARY KEY (id);


--
-- Name: fed_user_consent_cl_scope constraint_fgrntcsnt_clsc_pm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.fed_user_consent_cl_scope
    ADD CONSTRAINT constraint_fgrntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- Name: user_consent_client_scope constraint_grntcsnt_clsc_pm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_consent_client_scope
    ADD CONSTRAINT constraint_grntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- Name: user_consent constraint_grntcsnt_pm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT constraint_grntcsnt_pm PRIMARY KEY (id);


--
-- Name: keycloak_group constraint_group; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.keycloak_group
    ADD CONSTRAINT constraint_group PRIMARY KEY (id);


--
-- Name: group_attribute constraint_group_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.group_attribute
    ADD CONSTRAINT constraint_group_attribute_pk PRIMARY KEY (id);


--
-- Name: group_role_mapping constraint_group_role; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.group_role_mapping
    ADD CONSTRAINT constraint_group_role PRIMARY KEY (role_id, group_id);


--
-- Name: identity_provider_mapper constraint_idpm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider_mapper
    ADD CONSTRAINT constraint_idpm PRIMARY KEY (id);


--
-- Name: idp_mapper_config constraint_idpmconfig; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.idp_mapper_config
    ADD CONSTRAINT constraint_idpmconfig PRIMARY KEY (idp_mapper_id, name);


--
-- Name: migration_model constraint_migmod; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.migration_model
    ADD CONSTRAINT constraint_migmod PRIMARY KEY (id);


--
-- Name: offline_client_session constraint_offl_cl_ses_pk3; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.offline_client_session
    ADD CONSTRAINT constraint_offl_cl_ses_pk3 PRIMARY KEY (user_session_id, client_id, client_storage_provider, external_client_id, offline_flag);


--
-- Name: offline_user_session constraint_offl_us_ses_pk2; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.offline_user_session
    ADD CONSTRAINT constraint_offl_us_ses_pk2 PRIMARY KEY (user_session_id, offline_flag);


--
-- Name: protocol_mapper constraint_pcm; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT constraint_pcm PRIMARY KEY (id);


--
-- Name: protocol_mapper_config constraint_pmconfig; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.protocol_mapper_config
    ADD CONSTRAINT constraint_pmconfig PRIMARY KEY (protocol_mapper_id, name);


--
-- Name: redirect_uris constraint_redirect_uris; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.redirect_uris
    ADD CONSTRAINT constraint_redirect_uris PRIMARY KEY (client_id, value);


--
-- Name: required_action_config constraint_req_act_cfg_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.required_action_config
    ADD CONSTRAINT constraint_req_act_cfg_pk PRIMARY KEY (required_action_id, name);


--
-- Name: required_action_provider constraint_req_act_prv_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.required_action_provider
    ADD CONSTRAINT constraint_req_act_prv_pk PRIMARY KEY (id);


--
-- Name: user_required_action constraint_required_action; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_required_action
    ADD CONSTRAINT constraint_required_action PRIMARY KEY (required_action, user_id);


--
-- Name: resource_uris constraint_resour_uris_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_uris
    ADD CONSTRAINT constraint_resour_uris_pk PRIMARY KEY (resource_id, value);


--
-- Name: role_attribute constraint_role_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.role_attribute
    ADD CONSTRAINT constraint_role_attribute_pk PRIMARY KEY (id);


--
-- Name: user_attribute constraint_user_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_attribute
    ADD CONSTRAINT constraint_user_attribute_pk PRIMARY KEY (id);


--
-- Name: user_group_membership constraint_user_group; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_group_membership
    ADD CONSTRAINT constraint_user_group PRIMARY KEY (group_id, user_id);


--
-- Name: user_session_note constraint_usn_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_session_note
    ADD CONSTRAINT constraint_usn_pk PRIMARY KEY (user_session, name);


--
-- Name: web_origins constraint_web_origins; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.web_origins
    ADD CONSTRAINT constraint_web_origins PRIMARY KEY (client_id, value);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: client_scope_attributes pk_cl_tmpl_attr; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope_attributes
    ADD CONSTRAINT pk_cl_tmpl_attr PRIMARY KEY (scope_id, name);


--
-- Name: client_scope pk_cli_template; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope
    ADD CONSTRAINT pk_cli_template PRIMARY KEY (id);


--
-- Name: resource_server pk_resource_server; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server
    ADD CONSTRAINT pk_resource_server PRIMARY KEY (id);


--
-- Name: client_scope_role_mapping pk_template_scope; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope_role_mapping
    ADD CONSTRAINT pk_template_scope PRIMARY KEY (scope_id, role_id);


--
-- Name: default_client_scope r_def_cli_scope_bind; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.default_client_scope
    ADD CONSTRAINT r_def_cli_scope_bind PRIMARY KEY (realm_id, scope_id);


--
-- Name: realm_localizations realm_localizations_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_localizations
    ADD CONSTRAINT realm_localizations_pkey PRIMARY KEY (realm_id, locale);


--
-- Name: resource_attribute res_attr_pk; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_attribute
    ADD CONSTRAINT res_attr_pk PRIMARY KEY (id);


--
-- Name: keycloak_group sibling_names; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.keycloak_group
    ADD CONSTRAINT sibling_names UNIQUE (realm_id, parent_group, name);


--
-- Name: identity_provider uk_2daelwnibji49avxsrtuf6xj33; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT uk_2daelwnibji49avxsrtuf6xj33 UNIQUE (provider_alias, realm_id);


--
-- Name: client uk_b71cjlbenv945rb6gcon438at; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_b71cjlbenv945rb6gcon438at UNIQUE (realm_id, client_id);


--
-- Name: client_scope uk_cli_scope; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope
    ADD CONSTRAINT uk_cli_scope UNIQUE (realm_id, name);


--
-- Name: user_entity uk_dykn684sl8up1crfei6eckhd7; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT uk_dykn684sl8up1crfei6eckhd7 UNIQUE (realm_id, email_constraint);


--
-- Name: resource_server_resource uk_frsr6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5ha6 UNIQUE (name, owner, resource_server_id);


--
-- Name: resource_server_perm_ticket uk_frsr6t700s9v50bu18ws5pmt; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5pmt UNIQUE (owner, requester, resource_server_id, resource_id, scope_id);


--
-- Name: resource_server_policy uk_frsrpt700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT uk_frsrpt700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- Name: resource_server_scope uk_frsrst700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT uk_frsrst700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- Name: user_consent uk_jkuwuvd56ontgsuhogm8uewrt; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT uk_jkuwuvd56ontgsuhogm8uewrt UNIQUE (client_id, client_storage_provider, external_client_id, user_id);


--
-- Name: realm uk_orvsdmla56612eaefiq6wl5oi; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm
    ADD CONSTRAINT uk_orvsdmla56612eaefiq6wl5oi UNIQUE (name);


--
-- Name: user_entity uk_ru8tt6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT uk_ru8tt6t700s9v50bu18ws5ha6 UNIQUE (realm_id, username);


--
-- Name: idx_admin_event_time; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_admin_event_time ON public.admin_event_entity USING btree (realm_id, admin_event_time);


--
-- Name: idx_assoc_pol_assoc_pol_id; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_assoc_pol_assoc_pol_id ON public.associated_policy USING btree (associated_policy_id);


--
-- Name: idx_auth_config_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_auth_config_realm ON public.authenticator_config USING btree (realm_id);


--
-- Name: idx_auth_exec_flow; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_auth_exec_flow ON public.authentication_execution USING btree (flow_id);


--
-- Name: idx_auth_exec_realm_flow; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_auth_exec_realm_flow ON public.authentication_execution USING btree (realm_id, flow_id);


--
-- Name: idx_auth_flow_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_auth_flow_realm ON public.authentication_flow USING btree (realm_id);


--
-- Name: idx_cl_clscope; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_cl_clscope ON public.client_scope_client USING btree (scope_id);


--
-- Name: idx_client_id; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_client_id ON public.client USING btree (client_id);


--
-- Name: idx_client_init_acc_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_client_init_acc_realm ON public.client_initial_access USING btree (realm_id);


--
-- Name: idx_client_session_session; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_client_session_session ON public.client_session USING btree (session_id);


--
-- Name: idx_clscope_attrs; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_clscope_attrs ON public.client_scope_attributes USING btree (scope_id);


--
-- Name: idx_clscope_cl; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_clscope_cl ON public.client_scope_client USING btree (client_id);


--
-- Name: idx_clscope_protmap; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_clscope_protmap ON public.protocol_mapper USING btree (client_scope_id);


--
-- Name: idx_clscope_role; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_clscope_role ON public.client_scope_role_mapping USING btree (scope_id);


--
-- Name: idx_compo_config_compo; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_compo_config_compo ON public.component_config USING btree (component_id);


--
-- Name: idx_component_provider_type; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_component_provider_type ON public.component USING btree (provider_type);


--
-- Name: idx_component_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_component_realm ON public.component USING btree (realm_id);


--
-- Name: idx_composite; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_composite ON public.composite_role USING btree (composite);


--
-- Name: idx_composite_child; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_composite_child ON public.composite_role USING btree (child_role);


--
-- Name: idx_defcls_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_defcls_realm ON public.default_client_scope USING btree (realm_id);


--
-- Name: idx_defcls_scope; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_defcls_scope ON public.default_client_scope USING btree (scope_id);


--
-- Name: idx_event_time; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_event_time ON public.event_entity USING btree (realm_id, event_time);


--
-- Name: idx_fedidentity_feduser; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fedidentity_feduser ON public.federated_identity USING btree (federated_user_id);


--
-- Name: idx_fedidentity_user; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fedidentity_user ON public.federated_identity USING btree (user_id);


--
-- Name: idx_fu_attribute; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_attribute ON public.fed_user_attribute USING btree (user_id, realm_id, name);


--
-- Name: idx_fu_cnsnt_ext; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_cnsnt_ext ON public.fed_user_consent USING btree (user_id, client_storage_provider, external_client_id);


--
-- Name: idx_fu_consent; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_consent ON public.fed_user_consent USING btree (user_id, client_id);


--
-- Name: idx_fu_consent_ru; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_consent_ru ON public.fed_user_consent USING btree (realm_id, user_id);


--
-- Name: idx_fu_credential; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_credential ON public.fed_user_credential USING btree (user_id, type);


--
-- Name: idx_fu_credential_ru; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_credential_ru ON public.fed_user_credential USING btree (realm_id, user_id);


--
-- Name: idx_fu_group_membership; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_group_membership ON public.fed_user_group_membership USING btree (user_id, group_id);


--
-- Name: idx_fu_group_membership_ru; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_group_membership_ru ON public.fed_user_group_membership USING btree (realm_id, user_id);


--
-- Name: idx_fu_required_action; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_required_action ON public.fed_user_required_action USING btree (user_id, required_action);


--
-- Name: idx_fu_required_action_ru; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_required_action_ru ON public.fed_user_required_action USING btree (realm_id, user_id);


--
-- Name: idx_fu_role_mapping; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_role_mapping ON public.fed_user_role_mapping USING btree (user_id, role_id);


--
-- Name: idx_fu_role_mapping_ru; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_fu_role_mapping_ru ON public.fed_user_role_mapping USING btree (realm_id, user_id);


--
-- Name: idx_group_att_by_name_value; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_group_att_by_name_value ON public.group_attribute USING btree (name, ((value)::character varying(250)));


--
-- Name: idx_group_attr_group; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_group_attr_group ON public.group_attribute USING btree (group_id);


--
-- Name: idx_group_role_mapp_group; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_group_role_mapp_group ON public.group_role_mapping USING btree (group_id);


--
-- Name: idx_id_prov_mapp_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_id_prov_mapp_realm ON public.identity_provider_mapper USING btree (realm_id);


--
-- Name: idx_ident_prov_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_ident_prov_realm ON public.identity_provider USING btree (realm_id);


--
-- Name: idx_keycloak_role_client; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_keycloak_role_client ON public.keycloak_role USING btree (client);


--
-- Name: idx_keycloak_role_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_keycloak_role_realm ON public.keycloak_role USING btree (realm);


--
-- Name: idx_offline_css_preload; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_offline_css_preload ON public.offline_client_session USING btree (client_id, offline_flag);


--
-- Name: idx_offline_uss_by_user; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_offline_uss_by_user ON public.offline_user_session USING btree (user_id, realm_id, offline_flag);


--
-- Name: idx_offline_uss_by_usersess; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_offline_uss_by_usersess ON public.offline_user_session USING btree (realm_id, offline_flag, user_session_id);


--
-- Name: idx_offline_uss_createdon; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_offline_uss_createdon ON public.offline_user_session USING btree (created_on);


--
-- Name: idx_offline_uss_preload; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_offline_uss_preload ON public.offline_user_session USING btree (offline_flag, created_on, user_session_id);


--
-- Name: idx_protocol_mapper_client; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_protocol_mapper_client ON public.protocol_mapper USING btree (client_id);


--
-- Name: idx_realm_attr_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_attr_realm ON public.realm_attribute USING btree (realm_id);


--
-- Name: idx_realm_clscope; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_clscope ON public.client_scope USING btree (realm_id);


--
-- Name: idx_realm_def_grp_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_def_grp_realm ON public.realm_default_groups USING btree (realm_id);


--
-- Name: idx_realm_evt_list_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_evt_list_realm ON public.realm_events_listeners USING btree (realm_id);


--
-- Name: idx_realm_evt_types_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_evt_types_realm ON public.realm_enabled_event_types USING btree (realm_id);


--
-- Name: idx_realm_master_adm_cli; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_master_adm_cli ON public.realm USING btree (master_admin_client);


--
-- Name: idx_realm_supp_local_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_realm_supp_local_realm ON public.realm_supported_locales USING btree (realm_id);


--
-- Name: idx_redir_uri_client; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_redir_uri_client ON public.redirect_uris USING btree (client_id);


--
-- Name: idx_req_act_prov_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_req_act_prov_realm ON public.required_action_provider USING btree (realm_id);


--
-- Name: idx_res_policy_policy; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_res_policy_policy ON public.resource_policy USING btree (policy_id);


--
-- Name: idx_res_scope_scope; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_res_scope_scope ON public.resource_scope USING btree (scope_id);


--
-- Name: idx_res_serv_pol_res_serv; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_res_serv_pol_res_serv ON public.resource_server_policy USING btree (resource_server_id);


--
-- Name: idx_res_srv_res_res_srv; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_res_srv_res_res_srv ON public.resource_server_resource USING btree (resource_server_id);


--
-- Name: idx_res_srv_scope_res_srv; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_res_srv_scope_res_srv ON public.resource_server_scope USING btree (resource_server_id);


--
-- Name: idx_role_attribute; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_role_attribute ON public.role_attribute USING btree (role_id);


--
-- Name: idx_role_clscope; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_role_clscope ON public.client_scope_role_mapping USING btree (role_id);


--
-- Name: idx_scope_mapping_role; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_scope_mapping_role ON public.scope_mapping USING btree (role_id);


--
-- Name: idx_scope_policy_policy; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_scope_policy_policy ON public.scope_policy USING btree (policy_id);


--
-- Name: idx_update_time; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_update_time ON public.migration_model USING btree (update_time);


--
-- Name: idx_us_sess_id_on_cl_sess; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_us_sess_id_on_cl_sess ON public.offline_client_session USING btree (user_session_id);


--
-- Name: idx_usconsent_clscope; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_usconsent_clscope ON public.user_consent_client_scope USING btree (user_consent_id);


--
-- Name: idx_user_attribute; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_attribute ON public.user_attribute USING btree (user_id);


--
-- Name: idx_user_attribute_name; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_attribute_name ON public.user_attribute USING btree (name, value);


--
-- Name: idx_user_consent; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_consent ON public.user_consent USING btree (user_id);


--
-- Name: idx_user_credential; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_credential ON public.credential USING btree (user_id);


--
-- Name: idx_user_email; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_email ON public.user_entity USING btree (email);


--
-- Name: idx_user_group_mapping; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_group_mapping ON public.user_group_membership USING btree (user_id);


--
-- Name: idx_user_reqactions; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_reqactions ON public.user_required_action USING btree (user_id);


--
-- Name: idx_user_role_mapping; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_role_mapping ON public.user_role_mapping USING btree (user_id);


--
-- Name: idx_user_service_account; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_user_service_account ON public.user_entity USING btree (realm_id, service_account_client_link);


--
-- Name: idx_usr_fed_map_fed_prv; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_usr_fed_map_fed_prv ON public.user_federation_mapper USING btree (federation_provider_id);


--
-- Name: idx_usr_fed_map_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_usr_fed_map_realm ON public.user_federation_mapper USING btree (realm_id);


--
-- Name: idx_usr_fed_prv_realm; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_usr_fed_prv_realm ON public.user_federation_provider USING btree (realm_id);


--
-- Name: idx_web_orig_client; Type: INDEX; Schema: public; Owner: dev
--

CREATE INDEX idx_web_orig_client ON public.web_origins USING btree (client_id);


--
-- Name: client_session_auth_status auth_status_constraint; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_auth_status
    ADD CONSTRAINT auth_status_constraint FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: identity_provider fk2b4ebc52ae5c3b34; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT fk2b4ebc52ae5c3b34 FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_attributes fk3c47c64beacca966; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_attributes
    ADD CONSTRAINT fk3c47c64beacca966 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: federated_identity fk404288b92ef007a6; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.federated_identity
    ADD CONSTRAINT fk404288b92ef007a6 FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: client_node_registrations fk4129723ba992f594; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_node_registrations
    ADD CONSTRAINT fk4129723ba992f594 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: client_session_note fk5edfb00ff51c2736; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_note
    ADD CONSTRAINT fk5edfb00ff51c2736 FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: user_session_note fk5edfb00ff51d3472; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_session_note
    ADD CONSTRAINT fk5edfb00ff51d3472 FOREIGN KEY (user_session) REFERENCES public.user_session(id);


--
-- Name: client_session_role fk_11b7sgqw18i532811v7o2dv76; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_role
    ADD CONSTRAINT fk_11b7sgqw18i532811v7o2dv76 FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: redirect_uris fk_1burs8pb4ouj97h5wuppahv9f; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.redirect_uris
    ADD CONSTRAINT fk_1burs8pb4ouj97h5wuppahv9f FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: user_federation_provider fk_1fj32f6ptolw2qy60cd8n01e8; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_provider
    ADD CONSTRAINT fk_1fj32f6ptolw2qy60cd8n01e8 FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_session_prot_mapper fk_33a8sgqw18i532811v7o2dk89; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session_prot_mapper
    ADD CONSTRAINT fk_33a8sgqw18i532811v7o2dk89 FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: realm_required_credential fk_5hg65lybevavkqfki3kponh9v; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_required_credential
    ADD CONSTRAINT fk_5hg65lybevavkqfki3kponh9v FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: resource_attribute fk_5hrm2vlf9ql5fu022kqepovbr; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu022kqepovbr FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: user_attribute fk_5hrm2vlf9ql5fu043kqepovbr; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu043kqepovbr FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: user_required_action fk_6qj3w1jw9cvafhe19bwsiuvmd; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_required_action
    ADD CONSTRAINT fk_6qj3w1jw9cvafhe19bwsiuvmd FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: keycloak_role fk_6vyqfe4cn4wlq8r6kt5vdsj5c; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT fk_6vyqfe4cn4wlq8r6kt5vdsj5c FOREIGN KEY (realm) REFERENCES public.realm(id);


--
-- Name: realm_smtp_config fk_70ej8xdxgxd0b9hh6180irr0o; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_smtp_config
    ADD CONSTRAINT fk_70ej8xdxgxd0b9hh6180irr0o FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_attribute fk_8shxd6l3e9atqukacxgpffptw; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_attribute
    ADD CONSTRAINT fk_8shxd6l3e9atqukacxgpffptw FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: composite_role fk_a63wvekftu8jo1pnj81e7mce2; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT fk_a63wvekftu8jo1pnj81e7mce2 FOREIGN KEY (composite) REFERENCES public.keycloak_role(id);


--
-- Name: authentication_execution fk_auth_exec_flow; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT fk_auth_exec_flow FOREIGN KEY (flow_id) REFERENCES public.authentication_flow(id);


--
-- Name: authentication_execution fk_auth_exec_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT fk_auth_exec_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: authentication_flow fk_auth_flow_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authentication_flow
    ADD CONSTRAINT fk_auth_flow_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: authenticator_config fk_auth_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.authenticator_config
    ADD CONSTRAINT fk_auth_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_session fk_b4ao2vcvat6ukau74wbwtfqo1; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_session
    ADD CONSTRAINT fk_b4ao2vcvat6ukau74wbwtfqo1 FOREIGN KEY (session_id) REFERENCES public.user_session(id);


--
-- Name: user_role_mapping fk_c4fqv34p1mbylloxang7b1q3l; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_role_mapping
    ADD CONSTRAINT fk_c4fqv34p1mbylloxang7b1q3l FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: client_scope_attributes fk_cl_scope_attr_scope; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope_attributes
    ADD CONSTRAINT fk_cl_scope_attr_scope FOREIGN KEY (scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_scope_role_mapping fk_cl_scope_rm_scope; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_scope_role_mapping
    ADD CONSTRAINT fk_cl_scope_rm_scope FOREIGN KEY (scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_user_session_note fk_cl_usr_ses_note; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_user_session_note
    ADD CONSTRAINT fk_cl_usr_ses_note FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: protocol_mapper fk_cli_scope_mapper; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT fk_cli_scope_mapper FOREIGN KEY (client_scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_initial_access fk_client_init_acc_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.client_initial_access
    ADD CONSTRAINT fk_client_init_acc_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: component_config fk_component_config; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.component_config
    ADD CONSTRAINT fk_component_config FOREIGN KEY (component_id) REFERENCES public.component(id);


--
-- Name: component fk_component_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT fk_component_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_default_groups fk_def_groups_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT fk_def_groups_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_federation_mapper_config fk_fedmapper_cfg; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_mapper_config
    ADD CONSTRAINT fk_fedmapper_cfg FOREIGN KEY (user_federation_mapper_id) REFERENCES public.user_federation_mapper(id);


--
-- Name: user_federation_mapper fk_fedmapperpm_fedprv; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_fedprv FOREIGN KEY (federation_provider_id) REFERENCES public.user_federation_provider(id);


--
-- Name: user_federation_mapper fk_fedmapperpm_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: associated_policy fk_frsr5s213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT fk_frsr5s213xcx4wnkog82ssrfy FOREIGN KEY (associated_policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: scope_policy fk_frsrasp13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT fk_frsrasp13xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog82sspmt; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82sspmt FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_server_resource fk_frsrho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog83sspmt; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog83sspmt FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog84sspmt; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog84sspmt FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: associated_policy fk_frsrpas14xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT fk_frsrpas14xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: scope_policy fk_frsrpass3xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT fk_frsrpass3xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: resource_server_perm_ticket fk_frsrpo2128cx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrpo2128cx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_server_policy fk_frsrpo213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT fk_frsrpo213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_scope fk_frsrpos13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT fk_frsrpos13xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_policy fk_frsrpos53xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT fk_frsrpos53xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_policy fk_frsrpp213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT fk_frsrpp213xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_scope fk_frsrps213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT fk_frsrps213xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: resource_server_scope fk_frsrso213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT fk_frsrso213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: composite_role fk_gr7thllb9lu8q4vqa4524jjy8; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT fk_gr7thllb9lu8q4vqa4524jjy8 FOREIGN KEY (child_role) REFERENCES public.keycloak_role(id);


--
-- Name: user_consent_client_scope fk_grntcsnt_clsc_usc; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_consent_client_scope
    ADD CONSTRAINT fk_grntcsnt_clsc_usc FOREIGN KEY (user_consent_id) REFERENCES public.user_consent(id);


--
-- Name: user_consent fk_grntcsnt_user; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT fk_grntcsnt_user FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: group_attribute fk_group_attribute_group; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.group_attribute
    ADD CONSTRAINT fk_group_attribute_group FOREIGN KEY (group_id) REFERENCES public.keycloak_group(id);


--
-- Name: group_role_mapping fk_group_role_group; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.group_role_mapping
    ADD CONSTRAINT fk_group_role_group FOREIGN KEY (group_id) REFERENCES public.keycloak_group(id);


--
-- Name: realm_enabled_event_types fk_h846o4h0w8epx5nwedrf5y69j; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_enabled_event_types
    ADD CONSTRAINT fk_h846o4h0w8epx5nwedrf5y69j FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_events_listeners fk_h846o4h0w8epx5nxev9f5y69j; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_events_listeners
    ADD CONSTRAINT fk_h846o4h0w8epx5nxev9f5y69j FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: identity_provider_mapper fk_idpm_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider_mapper
    ADD CONSTRAINT fk_idpm_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: idp_mapper_config fk_idpmconfig; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.idp_mapper_config
    ADD CONSTRAINT fk_idpmconfig FOREIGN KEY (idp_mapper_id) REFERENCES public.identity_provider_mapper(id);


--
-- Name: web_origins fk_lojpho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.web_origins
    ADD CONSTRAINT fk_lojpho213xcx4wnkog82ssrfy FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: scope_mapping fk_ouse064plmlr732lxjcn1q5f1; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.scope_mapping
    ADD CONSTRAINT fk_ouse064plmlr732lxjcn1q5f1 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: protocol_mapper fk_pcm_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT fk_pcm_realm FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: credential fk_pfyr0glasqyl0dei3kl69r6v0; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.credential
    ADD CONSTRAINT fk_pfyr0glasqyl0dei3kl69r6v0 FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: protocol_mapper_config fk_pmconfig; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.protocol_mapper_config
    ADD CONSTRAINT fk_pmconfig FOREIGN KEY (protocol_mapper_id) REFERENCES public.protocol_mapper(id);


--
-- Name: default_client_scope fk_r_def_cli_scope_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.default_client_scope
    ADD CONSTRAINT fk_r_def_cli_scope_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: required_action_provider fk_req_act_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.required_action_provider
    ADD CONSTRAINT fk_req_act_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: resource_uris fk_resource_server_uris; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.resource_uris
    ADD CONSTRAINT fk_resource_server_uris FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: role_attribute fk_role_attribute_id; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.role_attribute
    ADD CONSTRAINT fk_role_attribute_id FOREIGN KEY (role_id) REFERENCES public.keycloak_role(id);


--
-- Name: realm_supported_locales fk_supported_locales_realm; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.realm_supported_locales
    ADD CONSTRAINT fk_supported_locales_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_federation_config fk_t13hpu1j94r2ebpekr39x5eu5; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_federation_config
    ADD CONSTRAINT fk_t13hpu1j94r2ebpekr39x5eu5 FOREIGN KEY (user_federation_provider_id) REFERENCES public.user_federation_provider(id);


--
-- Name: user_group_membership fk_user_group_user; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.user_group_membership
    ADD CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: policy_config fkdc34197cf864c4e43; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.policy_config
    ADD CONSTRAINT fkdc34197cf864c4e43 FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: identity_provider_config fkdc4897cf864c4e43; Type: FK CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.identity_provider_config
    ADD CONSTRAINT fkdc4897cf864c4e43 FOREIGN KEY (identity_provider_id) REFERENCES public.identity_provider(internal_id);


--
-- PostgreSQL database dump complete
--

