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
464dbf93-f387-4479-a63a-42afb60cec54	\N	auth-cookie	15357e80-1b48-4482-93a9-2311f5c506f8	afecbc2c-8a17-41d3-88f2-5c5fefc1a6ca	2	10	f	\N	\N
ab012b71-8e48-4546-bd98-956d8bb4433d	\N	auth-spnego	15357e80-1b48-4482-93a9-2311f5c506f8	afecbc2c-8a17-41d3-88f2-5c5fefc1a6ca	3	20	f	\N	\N
7900220f-a464-43a1-be9c-0539a0e69e1c	\N	identity-provider-redirector	15357e80-1b48-4482-93a9-2311f5c506f8	afecbc2c-8a17-41d3-88f2-5c5fefc1a6ca	2	25	f	\N	\N
be7ac69e-aa6a-4752-bd9c-2df905244d43	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	afecbc2c-8a17-41d3-88f2-5c5fefc1a6ca	2	30	t	53a53839-6031-4feb-9323-5bf2130686b5	\N
0b9fa58b-df73-43ed-9bae-1588822cf393	\N	auth-username-password-form	15357e80-1b48-4482-93a9-2311f5c506f8	53a53839-6031-4feb-9323-5bf2130686b5	0	10	f	\N	\N
3e3f8aca-9f63-499e-9969-693f1e8b23ce	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	53a53839-6031-4feb-9323-5bf2130686b5	1	20	t	58dd17fa-b2a7-40eb-9d8e-447bb67dca55	\N
8a328f1d-bf35-42aa-a367-44fa7469e8cd	\N	conditional-user-configured	15357e80-1b48-4482-93a9-2311f5c506f8	58dd17fa-b2a7-40eb-9d8e-447bb67dca55	0	10	f	\N	\N
910dfb64-fa14-4343-9490-3fe316459227	\N	auth-otp-form	15357e80-1b48-4482-93a9-2311f5c506f8	58dd17fa-b2a7-40eb-9d8e-447bb67dca55	0	20	f	\N	\N
a80532f8-9cab-4eb2-bc0e-dbd33d54ddb7	\N	direct-grant-validate-username	15357e80-1b48-4482-93a9-2311f5c506f8	5e0c8041-a87c-45b4-85fb-335355d171e7	0	10	f	\N	\N
aa2b28b9-6fbc-497e-ae51-cda5637492bd	\N	direct-grant-validate-password	15357e80-1b48-4482-93a9-2311f5c506f8	5e0c8041-a87c-45b4-85fb-335355d171e7	0	20	f	\N	\N
9c040fcc-8e6b-487c-81a7-e8db3959cc26	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	5e0c8041-a87c-45b4-85fb-335355d171e7	1	30	t	b9bd810d-ae6b-4e70-ad47-e083dc28b15a	\N
c003a191-0064-468f-adfa-63cd8ccb7c7e	\N	conditional-user-configured	15357e80-1b48-4482-93a9-2311f5c506f8	b9bd810d-ae6b-4e70-ad47-e083dc28b15a	0	10	f	\N	\N
2718f485-be5b-48d0-912c-f677cde0a4ef	\N	direct-grant-validate-otp	15357e80-1b48-4482-93a9-2311f5c506f8	b9bd810d-ae6b-4e70-ad47-e083dc28b15a	0	20	f	\N	\N
f24d9cf7-322a-4a2a-b0d1-f8553ce8ffce	\N	registration-page-form	15357e80-1b48-4482-93a9-2311f5c506f8	b6838112-f14f-4acf-b487-90bad8e7bda0	0	10	t	73b60e92-a37a-469c-b886-8c6513d85f5c	\N
56595a1e-191b-489a-a52f-69902d9c09b1	\N	registration-user-creation	15357e80-1b48-4482-93a9-2311f5c506f8	73b60e92-a37a-469c-b886-8c6513d85f5c	0	20	f	\N	\N
7725fbc1-9045-4f89-9d64-1b6a39fec8a2	\N	registration-password-action	15357e80-1b48-4482-93a9-2311f5c506f8	73b60e92-a37a-469c-b886-8c6513d85f5c	0	50	f	\N	\N
a9fb04ea-6563-4390-a891-19a18abaf74c	\N	registration-recaptcha-action	15357e80-1b48-4482-93a9-2311f5c506f8	73b60e92-a37a-469c-b886-8c6513d85f5c	3	60	f	\N	\N
eecf29c7-be27-4e93-b702-5113929a944b	\N	registration-terms-and-conditions	15357e80-1b48-4482-93a9-2311f5c506f8	73b60e92-a37a-469c-b886-8c6513d85f5c	3	70	f	\N	\N
6fcf71af-6a25-4b34-ab59-4e8cd0553b9f	\N	reset-credentials-choose-user	15357e80-1b48-4482-93a9-2311f5c506f8	b4d48465-e273-46dd-a6bd-7dbc18387bec	0	10	f	\N	\N
a78a14ef-1f43-48e1-ba06-6af83b97e210	\N	reset-credential-email	15357e80-1b48-4482-93a9-2311f5c506f8	b4d48465-e273-46dd-a6bd-7dbc18387bec	0	20	f	\N	\N
ab39d9aa-9caa-4019-8a15-7dca6c6bdc6a	\N	reset-password	15357e80-1b48-4482-93a9-2311f5c506f8	b4d48465-e273-46dd-a6bd-7dbc18387bec	0	30	f	\N	\N
3045aed0-28a1-44d7-ab8e-44213c274743	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	b4d48465-e273-46dd-a6bd-7dbc18387bec	1	40	t	3a6f9197-5d79-4d8c-a704-c607f1d02808	\N
02e411a2-a074-4a45-aec6-fff26240f254	\N	conditional-user-configured	15357e80-1b48-4482-93a9-2311f5c506f8	3a6f9197-5d79-4d8c-a704-c607f1d02808	0	10	f	\N	\N
0e8b6d41-f4fb-418c-9d26-65d90463281b	\N	reset-otp	15357e80-1b48-4482-93a9-2311f5c506f8	3a6f9197-5d79-4d8c-a704-c607f1d02808	0	20	f	\N	\N
3e8021eb-8934-4281-add7-6be9571224f5	\N	client-secret	15357e80-1b48-4482-93a9-2311f5c506f8	10d57c21-4598-4807-a807-d5fdc09f2820	2	10	f	\N	\N
2ea10227-3807-4b28-839d-7ed701234172	\N	client-jwt	15357e80-1b48-4482-93a9-2311f5c506f8	10d57c21-4598-4807-a807-d5fdc09f2820	2	20	f	\N	\N
6ae721c2-ebc9-4973-b1f5-75892cc6c412	\N	client-secret-jwt	15357e80-1b48-4482-93a9-2311f5c506f8	10d57c21-4598-4807-a807-d5fdc09f2820	2	30	f	\N	\N
6a90e5a6-327d-4c56-8621-d5450547e62c	\N	client-x509	15357e80-1b48-4482-93a9-2311f5c506f8	10d57c21-4598-4807-a807-d5fdc09f2820	2	40	f	\N	\N
db149ae7-8ed2-46f8-beaa-497abfa9dcf4	\N	idp-review-profile	15357e80-1b48-4482-93a9-2311f5c506f8	8f409014-e89a-4c02-8d61-9f4ec4ec1f34	0	10	f	\N	000839d9-6389-4b7b-80c8-74b1b65c50f2
5fc2bb39-639e-4277-bc3b-b0695217a8c5	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	8f409014-e89a-4c02-8d61-9f4ec4ec1f34	0	20	t	d1712f02-ffdd-4d52-b649-50af28652394	\N
3e2c11fb-2221-4ad4-be9e-c870ef46502b	\N	idp-create-user-if-unique	15357e80-1b48-4482-93a9-2311f5c506f8	d1712f02-ffdd-4d52-b649-50af28652394	2	10	f	\N	4fb2736c-7570-462f-8028-1cd9a710ab82
0b3320d4-d3a5-4027-8018-bbd4bdc1fc9c	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	d1712f02-ffdd-4d52-b649-50af28652394	2	20	t	16d63351-19d6-48fd-876a-406ee2d3321c	\N
91451bba-a550-4dc0-9929-9340245783af	\N	idp-confirm-link	15357e80-1b48-4482-93a9-2311f5c506f8	16d63351-19d6-48fd-876a-406ee2d3321c	0	10	f	\N	\N
f03195fc-37b0-4e23-ad37-9cff59edd28f	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	16d63351-19d6-48fd-876a-406ee2d3321c	0	20	t	993985aa-0b5c-44cf-8bc0-4bf90be32314	\N
fa98b61c-de70-4e3e-ba6b-744ed50a43fd	\N	idp-email-verification	15357e80-1b48-4482-93a9-2311f5c506f8	993985aa-0b5c-44cf-8bc0-4bf90be32314	2	10	f	\N	\N
e103b7ef-f7ce-4499-81b0-49d5e38801b0	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	993985aa-0b5c-44cf-8bc0-4bf90be32314	2	20	t	754d2b75-3557-4364-ac33-3796f4dbc509	\N
4633c840-6826-43d1-9a76-9d00972ab54a	\N	idp-username-password-form	15357e80-1b48-4482-93a9-2311f5c506f8	754d2b75-3557-4364-ac33-3796f4dbc509	0	10	f	\N	\N
2c3dd857-a310-4dec-9026-a64b3a17a17a	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	754d2b75-3557-4364-ac33-3796f4dbc509	1	20	t	701db2ba-5a47-4095-bed6-dec19f3f3e4b	\N
933897b0-3f9f-4638-972d-2decc57d7c0b	\N	conditional-user-configured	15357e80-1b48-4482-93a9-2311f5c506f8	701db2ba-5a47-4095-bed6-dec19f3f3e4b	0	10	f	\N	\N
c343226f-4b8c-4a0e-9316-65b8e543f61c	\N	auth-otp-form	15357e80-1b48-4482-93a9-2311f5c506f8	701db2ba-5a47-4095-bed6-dec19f3f3e4b	0	20	f	\N	\N
ab7ef006-c572-4735-8780-091d2613121d	\N	http-basic-authenticator	15357e80-1b48-4482-93a9-2311f5c506f8	14d78638-6893-4d16-bda4-7b86429fd37f	0	10	f	\N	\N
2591259c-9c93-4e4c-ac73-75941ab2b9a4	\N	docker-http-basic-authenticator	15357e80-1b48-4482-93a9-2311f5c506f8	4f92962b-c341-4399-8602-4a23dacc6f95	0	10	f	\N	\N
9fb6dee0-bfa6-4736-b1c3-58afcd25c929	\N	auth-cookie	d4451a80-7ae2-4c36-999e-8e6184a6ec05	ae434371-eb92-4bc0-8964-80e9ea2e06d2	2	10	f	\N	\N
dbb07f41-7007-4b7a-beac-b7705f4490e6	\N	auth-spnego	d4451a80-7ae2-4c36-999e-8e6184a6ec05	ae434371-eb92-4bc0-8964-80e9ea2e06d2	3	20	f	\N	\N
00e130d8-6244-426f-a604-534c238ec4b4	\N	identity-provider-redirector	d4451a80-7ae2-4c36-999e-8e6184a6ec05	ae434371-eb92-4bc0-8964-80e9ea2e06d2	2	25	f	\N	\N
64761542-438e-4e8a-a681-15c776d422f3	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	ae434371-eb92-4bc0-8964-80e9ea2e06d2	2	30	t	89d21395-2028-4aab-98ed-ac689a7b74a1	\N
52f0001e-bd63-4446-a1c3-512ec1b1c2f1	\N	auth-username-password-form	d4451a80-7ae2-4c36-999e-8e6184a6ec05	89d21395-2028-4aab-98ed-ac689a7b74a1	0	10	f	\N	\N
5ca98e4b-0236-4e14-83f5-4d6043cb57be	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	89d21395-2028-4aab-98ed-ac689a7b74a1	1	20	t	d75de237-5596-434e-bdbf-2d4a2c845709	\N
4a6c8032-6173-452e-bede-83b0b922e7e5	\N	conditional-user-configured	d4451a80-7ae2-4c36-999e-8e6184a6ec05	d75de237-5596-434e-bdbf-2d4a2c845709	0	10	f	\N	\N
8c81206b-2f3a-44ea-b879-cdada862f6bc	\N	auth-otp-form	d4451a80-7ae2-4c36-999e-8e6184a6ec05	d75de237-5596-434e-bdbf-2d4a2c845709	0	20	f	\N	\N
20efd985-110e-49fb-a150-98f79844db4f	\N	direct-grant-validate-username	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f803135f-0749-498a-90ef-919d2543add0	0	10	f	\N	\N
39c5a321-c4f6-40b4-bfb6-7b63c5629f81	\N	direct-grant-validate-password	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f803135f-0749-498a-90ef-919d2543add0	0	20	f	\N	\N
7c68e700-13a4-488a-aadb-b3d785e45e50	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f803135f-0749-498a-90ef-919d2543add0	1	30	t	05d1f0ef-8666-4064-b4d7-8e46fc0ba2c6	\N
12c3f408-5b6c-43d0-8e5e-87a9e38b5434	\N	conditional-user-configured	d4451a80-7ae2-4c36-999e-8e6184a6ec05	05d1f0ef-8666-4064-b4d7-8e46fc0ba2c6	0	10	f	\N	\N
33347118-1182-4a11-bee2-3a108a0ef20b	\N	direct-grant-validate-otp	d4451a80-7ae2-4c36-999e-8e6184a6ec05	05d1f0ef-8666-4064-b4d7-8e46fc0ba2c6	0	20	f	\N	\N
cbb20f05-7803-46c4-bdfc-84401323c87d	\N	registration-page-form	d4451a80-7ae2-4c36-999e-8e6184a6ec05	e461fa7b-a50d-48be-aa4c-a44546b0916f	0	10	t	52fc12c7-2399-4cae-8ef0-64ce5c74d28b	\N
58dd8a7c-ad51-43cf-9c7b-1b246756c5ab	\N	registration-user-creation	d4451a80-7ae2-4c36-999e-8e6184a6ec05	52fc12c7-2399-4cae-8ef0-64ce5c74d28b	0	20	f	\N	\N
f20268cd-fc4b-4ec2-9447-efc58909cf4e	\N	registration-password-action	d4451a80-7ae2-4c36-999e-8e6184a6ec05	52fc12c7-2399-4cae-8ef0-64ce5c74d28b	0	50	f	\N	\N
6cb7f4d3-d903-49c8-bb08-d44c61f6bc3e	\N	registration-recaptcha-action	d4451a80-7ae2-4c36-999e-8e6184a6ec05	52fc12c7-2399-4cae-8ef0-64ce5c74d28b	3	60	f	\N	\N
9310fa5d-0bfa-44e9-bd68-a674dd335239	\N	reset-credentials-choose-user	d4451a80-7ae2-4c36-999e-8e6184a6ec05	4d8560e2-c33f-428d-bddd-0243c217a04a	0	10	f	\N	\N
5119fe99-09d9-418b-b0cb-e3972b42d400	\N	reset-credential-email	d4451a80-7ae2-4c36-999e-8e6184a6ec05	4d8560e2-c33f-428d-bddd-0243c217a04a	0	20	f	\N	\N
58c5f811-20a3-4b1b-bf95-b3bfedfcf26e	\N	reset-password	d4451a80-7ae2-4c36-999e-8e6184a6ec05	4d8560e2-c33f-428d-bddd-0243c217a04a	0	30	f	\N	\N
840ef98c-8889-4456-871e-2db6111d5c86	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	4d8560e2-c33f-428d-bddd-0243c217a04a	1	40	t	fa418a71-aea4-4897-ba02-c64872c0dcbb	\N
bf2159f9-56b6-4cde-b214-8c4979dea88d	\N	conditional-user-configured	d4451a80-7ae2-4c36-999e-8e6184a6ec05	fa418a71-aea4-4897-ba02-c64872c0dcbb	0	10	f	\N	\N
1a53faec-319f-4ce3-960f-e2600e9a4b09	\N	reset-otp	d4451a80-7ae2-4c36-999e-8e6184a6ec05	fa418a71-aea4-4897-ba02-c64872c0dcbb	0	20	f	\N	\N
0ffca424-ff4f-416d-8bb4-eab066a61040	\N	client-secret	d4451a80-7ae2-4c36-999e-8e6184a6ec05	b5d173c0-ce8d-43b0-b717-0ec3100df5f8	2	10	f	\N	\N
de89d955-16f5-4ab5-95bc-83c6955e951c	\N	client-jwt	d4451a80-7ae2-4c36-999e-8e6184a6ec05	b5d173c0-ce8d-43b0-b717-0ec3100df5f8	2	20	f	\N	\N
b5b58f6b-ca47-46f7-999f-b6f349b815e2	\N	client-secret-jwt	d4451a80-7ae2-4c36-999e-8e6184a6ec05	b5d173c0-ce8d-43b0-b717-0ec3100df5f8	2	30	f	\N	\N
4246e059-118c-4a69-a734-b8831ad6b415	\N	client-x509	d4451a80-7ae2-4c36-999e-8e6184a6ec05	b5d173c0-ce8d-43b0-b717-0ec3100df5f8	2	40	f	\N	\N
1d75ca2d-0922-41c8-93e2-3ada97f30b5f	\N	idp-review-profile	d4451a80-7ae2-4c36-999e-8e6184a6ec05	25c1f356-5dd8-4785-b9c1-fa185cb69cff	0	10	f	\N	4aa351ee-db35-420b-bb55-0f5e4e5d927a
5a1407ad-f642-49a5-8057-39f961e8fc18	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	25c1f356-5dd8-4785-b9c1-fa185cb69cff	0	20	t	443f8d5d-1a1f-4f12-aa99-c44543bafc6a	\N
a57e3c4d-792f-4d3a-8809-2b0dcc647df4	\N	idp-create-user-if-unique	d4451a80-7ae2-4c36-999e-8e6184a6ec05	443f8d5d-1a1f-4f12-aa99-c44543bafc6a	2	10	f	\N	7a0c0434-995c-492b-9874-40f774b5dd6c
e24718fb-1d6a-4fed-bf65-0031b9123c7c	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	443f8d5d-1a1f-4f12-aa99-c44543bafc6a	2	20	t	b7fe88cf-480b-4087-9be7-c4d1dd3670b2	\N
d6d0cb5a-ed60-44df-8857-66c05f88b5f3	\N	idp-confirm-link	d4451a80-7ae2-4c36-999e-8e6184a6ec05	b7fe88cf-480b-4087-9be7-c4d1dd3670b2	0	10	f	\N	\N
a9891507-722d-4325-b371-2bd6e0c0d70a	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	b7fe88cf-480b-4087-9be7-c4d1dd3670b2	0	20	t	86072787-b21e-4daf-b674-6eaf0a3462b7	\N
0d927336-0326-4197-a1c5-15b001ce9fff	\N	idp-email-verification	d4451a80-7ae2-4c36-999e-8e6184a6ec05	86072787-b21e-4daf-b674-6eaf0a3462b7	2	10	f	\N	\N
e572fcc6-b58d-4ac7-97e0-b7b5f72b642f	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	86072787-b21e-4daf-b674-6eaf0a3462b7	2	20	t	8ba0244e-a91c-425c-abcd-9b392fc909f3	\N
da229e0a-6006-4f68-9593-f5d41d92b2df	\N	idp-username-password-form	d4451a80-7ae2-4c36-999e-8e6184a6ec05	8ba0244e-a91c-425c-abcd-9b392fc909f3	0	10	f	\N	\N
4378babe-fb73-4068-965f-7552a935c20e	\N	\N	d4451a80-7ae2-4c36-999e-8e6184a6ec05	8ba0244e-a91c-425c-abcd-9b392fc909f3	1	20	t	582d867a-cfcc-4b03-bab3-2376a235f698	\N
b8108422-f557-4fea-83f5-45bf5c6bb4fd	\N	conditional-user-configured	d4451a80-7ae2-4c36-999e-8e6184a6ec05	582d867a-cfcc-4b03-bab3-2376a235f698	0	10	f	\N	\N
50805321-be11-499f-9b7e-5d0107c3022a	\N	auth-otp-form	d4451a80-7ae2-4c36-999e-8e6184a6ec05	582d867a-cfcc-4b03-bab3-2376a235f698	0	20	f	\N	\N
eec29037-3446-43a0-a5ed-42dde6030f0a	\N	http-basic-authenticator	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7e9c5f9c-031d-4764-b13e-1557b54acc2c	0	10	f	\N	\N
91360e32-7d7a-4eb3-b458-feeadefd9ea4	\N	docker-http-basic-authenticator	d4451a80-7ae2-4c36-999e-8e6184a6ec05	34802205-42d1-421d-989b-72a624f4b624	0	10	f	\N	\N
\.


--
-- Data for Name: authentication_flow; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authentication_flow (id, alias, description, realm_id, provider_id, top_level, built_in) FROM stdin;
afecbc2c-8a17-41d3-88f2-5c5fefc1a6ca	browser	browser based authentication	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
53a53839-6031-4feb-9323-5bf2130686b5	forms	Username, password, otp and other auth forms.	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
58dd17fa-b2a7-40eb-9d8e-447bb67dca55	Browser - Conditional OTP	Flow to determine if the OTP is required for the authentication	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
5e0c8041-a87c-45b4-85fb-335355d171e7	direct grant	OpenID Connect Resource Owner Grant	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
b9bd810d-ae6b-4e70-ad47-e083dc28b15a	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
b6838112-f14f-4acf-b487-90bad8e7bda0	registration	registration flow	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
73b60e92-a37a-469c-b886-8c6513d85f5c	registration form	registration form	15357e80-1b48-4482-93a9-2311f5c506f8	form-flow	f	t
b4d48465-e273-46dd-a6bd-7dbc18387bec	reset credentials	Reset credentials for a user if they forgot their password or something	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
3a6f9197-5d79-4d8c-a704-c607f1d02808	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
10d57c21-4598-4807-a807-d5fdc09f2820	clients	Base authentication for clients	15357e80-1b48-4482-93a9-2311f5c506f8	client-flow	t	t
8f409014-e89a-4c02-8d61-9f4ec4ec1f34	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
d1712f02-ffdd-4d52-b649-50af28652394	User creation or linking	Flow for the existing/non-existing user alternatives	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
16d63351-19d6-48fd-876a-406ee2d3321c	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
993985aa-0b5c-44cf-8bc0-4bf90be32314	Account verification options	Method with which to verity the existing account	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
754d2b75-3557-4364-ac33-3796f4dbc509	Verify Existing Account by Re-authentication	Reauthentication of existing account	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
701db2ba-5a47-4095-bed6-dec19f3f3e4b	First broker login - Conditional OTP	Flow to determine if the OTP is required for the authentication	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	f	t
14d78638-6893-4d16-bda4-7b86429fd37f	saml ecp	SAML ECP Profile Authentication Flow	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
4f92962b-c341-4399-8602-4a23dacc6f95	docker auth	Used by Docker clients to authenticate against the IDP	15357e80-1b48-4482-93a9-2311f5c506f8	basic-flow	t	t
ae434371-eb92-4bc0-8964-80e9ea2e06d2	browser	browser based authentication	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
89d21395-2028-4aab-98ed-ac689a7b74a1	forms	Username, password, otp and other auth forms.	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
d75de237-5596-434e-bdbf-2d4a2c845709	Browser - Conditional OTP	Flow to determine if the OTP is required for the authentication	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
f803135f-0749-498a-90ef-919d2543add0	direct grant	OpenID Connect Resource Owner Grant	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
05d1f0ef-8666-4064-b4d7-8e46fc0ba2c6	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
e461fa7b-a50d-48be-aa4c-a44546b0916f	registration	registration flow	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
52fc12c7-2399-4cae-8ef0-64ce5c74d28b	registration form	registration form	d4451a80-7ae2-4c36-999e-8e6184a6ec05	form-flow	f	t
4d8560e2-c33f-428d-bddd-0243c217a04a	reset credentials	Reset credentials for a user if they forgot their password or something	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
fa418a71-aea4-4897-ba02-c64872c0dcbb	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
b5d173c0-ce8d-43b0-b717-0ec3100df5f8	clients	Base authentication for clients	d4451a80-7ae2-4c36-999e-8e6184a6ec05	client-flow	t	t
25c1f356-5dd8-4785-b9c1-fa185cb69cff	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
443f8d5d-1a1f-4f12-aa99-c44543bafc6a	User creation or linking	Flow for the existing/non-existing user alternatives	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
b7fe88cf-480b-4087-9be7-c4d1dd3670b2	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
86072787-b21e-4daf-b674-6eaf0a3462b7	Account verification options	Method with which to verity the existing account	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
8ba0244e-a91c-425c-abcd-9b392fc909f3	Verify Existing Account by Re-authentication	Reauthentication of existing account	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
582d867a-cfcc-4b03-bab3-2376a235f698	First broker login - Conditional OTP	Flow to determine if the OTP is required for the authentication	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	f	t
7e9c5f9c-031d-4764-b13e-1557b54acc2c	saml ecp	SAML ECP Profile Authentication Flow	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
34802205-42d1-421d-989b-72a624f4b624	docker auth	Used by Docker clients to authenticate against the IDP	d4451a80-7ae2-4c36-999e-8e6184a6ec05	basic-flow	t	t
\.


--
-- Data for Name: authenticator_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authenticator_config (id, alias, realm_id) FROM stdin;
000839d9-6389-4b7b-80c8-74b1b65c50f2	review profile config	15357e80-1b48-4482-93a9-2311f5c506f8
4fb2736c-7570-462f-8028-1cd9a710ab82	create unique user config	15357e80-1b48-4482-93a9-2311f5c506f8
4aa351ee-db35-420b-bb55-0f5e4e5d927a	review profile config	d4451a80-7ae2-4c36-999e-8e6184a6ec05
7a0c0434-995c-492b-9874-40f774b5dd6c	create unique user config	d4451a80-7ae2-4c36-999e-8e6184a6ec05
\.


--
-- Data for Name: authenticator_config_entry; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.authenticator_config_entry (authenticator_id, value, name) FROM stdin;
000839d9-6389-4b7b-80c8-74b1b65c50f2	missing	update.profile.on.first.login
4fb2736c-7570-462f-8028-1cd9a710ab82	false	require.password.update.after.registration
4aa351ee-db35-420b-bb55-0f5e4e5d927a	missing	update.profile.on.first.login
7a0c0434-995c-492b-9874-40f774b5dd6c	false	require.password.update.after.registration
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
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	f	master-realm	0	f	\N	\N	t	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	\N	0	f	f	master Realm	f	client-secret	\N	\N	\N	t	f	f	f
175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	f	account	0	t	\N	/realms/master/account/	f	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
1027adf9-f5a4-4317-9aef-b634d978fb5f	t	f	account-console	0	t	\N	/realms/master/account/	f	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
50385586-9131-4a77-a928-d2fdfefc3173	t	f	broker	0	f	\N	\N	t	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
6311a773-e535-4fde-ac60-61694989a4bc	t	f	security-admin-console	0	t	\N	/admin/master/console/	f	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
27fc4a2e-e7af-47f2-9ad2-cf9612047884	t	f	admin-cli	0	t	\N	\N	f	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	f	maskanyone-realm	0	f	\N	\N	t	\N	f	15357e80-1b48-4482-93a9-2311f5c506f8	\N	0	f	f	maskanyone Realm	f	client-secret	\N	\N	\N	t	f	f	f
7f4d1776-be78-4103-bbea-fde19008a431	t	f	realm-management	0	f	\N	\N	t	\N	f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	0	f	f	${client_realm-management}	f	client-secret	\N	\N	\N	t	f	f	f
5edb3285-0625-4a5e-a93a-27c7b489020b	t	f	account	0	t	\N	/realms/maskanyone/account/	f	\N	f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
6c46bf16-f287-447b-9e2c-9d017241dd84	t	f	account-console	0	t	\N	/realms/maskanyone/account/	f	\N	f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	t	f	broker	0	f	\N	\N	t	\N	f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
eff849b3-27b3-4b4e-986b-bb5986524cd1	t	f	security-admin-console	0	t	\N	/admin/maskanyone/console/	f	\N	f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
d10a6489-bf54-41bf-89da-a00122a8628d	t	f	admin-cli	0	t	\N	\N	f	\N	f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	t	t	maskanyone-fe	0	t	\N		f		f	d4451a80-7ae2-4c36-999e-8e6184a6ec05	openid-connect	-1	t	f		f	client-secret	https://localhost		\N	t	f	t	f
\.


--
-- Data for Name: client_attributes; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_attributes (client_id, name, value) FROM stdin;
175549f9-bbf4-4afd-bde3-d1371c27ed9d	post.logout.redirect.uris	+
1027adf9-f5a4-4317-9aef-b634d978fb5f	post.logout.redirect.uris	+
1027adf9-f5a4-4317-9aef-b634d978fb5f	pkce.code.challenge.method	S256
6311a773-e535-4fde-ac60-61694989a4bc	post.logout.redirect.uris	+
6311a773-e535-4fde-ac60-61694989a4bc	pkce.code.challenge.method	S256
5edb3285-0625-4a5e-a93a-27c7b489020b	post.logout.redirect.uris	+
6c46bf16-f287-447b-9e2c-9d017241dd84	post.logout.redirect.uris	+
6c46bf16-f287-447b-9e2c-9d017241dd84	pkce.code.challenge.method	S256
eff849b3-27b3-4b4e-986b-bb5986524cd1	post.logout.redirect.uris	+
eff849b3-27b3-4b4e-986b-bb5986524cd1	pkce.code.challenge.method	S256
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	oauth2.device.authorization.grant.enabled	false
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	oidc.ciba.grant.enabled	false
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	backchannel.logout.session.required	true
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	backchannel.logout.revoke.offline.tokens	false
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	display.on.consent.screen	false
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
8dd342c0-eade-48a0-9ca2-18df93898a26	offline_access	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect built-in scope: offline_access	openid-connect
be034ad8-b58c-4d9f-8e05-e886f4af3335	role_list	15357e80-1b48-4482-93a9-2311f5c506f8	SAML role list	saml
1b34d161-ab56-479f-9a02-7e2d2d79a812	profile	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect built-in scope: profile	openid-connect
d7ff3aa5-e508-4fc4-9d06-05effb107ec0	email	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect built-in scope: email	openid-connect
9cb83105-0b9e-4143-beb9-68c719f48101	address	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect built-in scope: address	openid-connect
fc17d436-d1af-49b8-9911-1b45fb5efa2b	phone	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect built-in scope: phone	openid-connect
4dd418d7-c9d1-46c4-8434-52a0fcc6983e	roles	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect scope for add user roles to the access token	openid-connect
792e70bd-133f-4cff-98ca-2c473215f85d	web-origins	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect scope for add allowed web origins to the access token	openid-connect
382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	microprofile-jwt	15357e80-1b48-4482-93a9-2311f5c506f8	Microprofile - JWT built-in scope	openid-connect
2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	acr	15357e80-1b48-4482-93a9-2311f5c506f8	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
235681d5-862a-4654-8177-8d51967e4b86	offline_access	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect built-in scope: offline_access	openid-connect
afa87c90-033f-4c84-b2cc-b5aecf1f3667	role_list	d4451a80-7ae2-4c36-999e-8e6184a6ec05	SAML role list	saml
0fc988b4-555b-4552-ba5d-dcad9949464d	profile	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect built-in scope: profile	openid-connect
aa7575c3-c000-48fc-b49f-d1a636e9aad3	email	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect built-in scope: email	openid-connect
8862492b-3819-43fc-b18d-a7e0d4f98df2	address	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect built-in scope: address	openid-connect
fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	phone	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect built-in scope: phone	openid-connect
0c05d94c-3a14-41a8-aae5-1f9444261cb8	roles	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect scope for add user roles to the access token	openid-connect
71cba98e-b6bf-473e-b8a5-f1b6dcf47643	web-origins	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect scope for add allowed web origins to the access token	openid-connect
ab6dcd38-fda1-4657-8d67-49922f9ba5f9	microprofile-jwt	d4451a80-7ae2-4c36-999e-8e6184a6ec05	Microprofile - JWT built-in scope	openid-connect
98f06ba5-8194-4b69-8d5f-c2aef35f707a	acr	d4451a80-7ae2-4c36-999e-8e6184a6ec05	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
\.


--
-- Data for Name: client_scope_attributes; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope_attributes (scope_id, value, name) FROM stdin;
8dd342c0-eade-48a0-9ca2-18df93898a26	true	display.on.consent.screen
8dd342c0-eade-48a0-9ca2-18df93898a26	${offlineAccessScopeConsentText}	consent.screen.text
be034ad8-b58c-4d9f-8e05-e886f4af3335	true	display.on.consent.screen
be034ad8-b58c-4d9f-8e05-e886f4af3335	${samlRoleListScopeConsentText}	consent.screen.text
1b34d161-ab56-479f-9a02-7e2d2d79a812	true	display.on.consent.screen
1b34d161-ab56-479f-9a02-7e2d2d79a812	${profileScopeConsentText}	consent.screen.text
1b34d161-ab56-479f-9a02-7e2d2d79a812	true	include.in.token.scope
d7ff3aa5-e508-4fc4-9d06-05effb107ec0	true	display.on.consent.screen
d7ff3aa5-e508-4fc4-9d06-05effb107ec0	${emailScopeConsentText}	consent.screen.text
d7ff3aa5-e508-4fc4-9d06-05effb107ec0	true	include.in.token.scope
9cb83105-0b9e-4143-beb9-68c719f48101	true	display.on.consent.screen
9cb83105-0b9e-4143-beb9-68c719f48101	${addressScopeConsentText}	consent.screen.text
9cb83105-0b9e-4143-beb9-68c719f48101	true	include.in.token.scope
fc17d436-d1af-49b8-9911-1b45fb5efa2b	true	display.on.consent.screen
fc17d436-d1af-49b8-9911-1b45fb5efa2b	${phoneScopeConsentText}	consent.screen.text
fc17d436-d1af-49b8-9911-1b45fb5efa2b	true	include.in.token.scope
4dd418d7-c9d1-46c4-8434-52a0fcc6983e	true	display.on.consent.screen
4dd418d7-c9d1-46c4-8434-52a0fcc6983e	${rolesScopeConsentText}	consent.screen.text
4dd418d7-c9d1-46c4-8434-52a0fcc6983e	false	include.in.token.scope
792e70bd-133f-4cff-98ca-2c473215f85d	false	display.on.consent.screen
792e70bd-133f-4cff-98ca-2c473215f85d		consent.screen.text
792e70bd-133f-4cff-98ca-2c473215f85d	false	include.in.token.scope
382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	false	display.on.consent.screen
382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	true	include.in.token.scope
2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	false	display.on.consent.screen
2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	false	include.in.token.scope
235681d5-862a-4654-8177-8d51967e4b86	true	display.on.consent.screen
235681d5-862a-4654-8177-8d51967e4b86	${offlineAccessScopeConsentText}	consent.screen.text
afa87c90-033f-4c84-b2cc-b5aecf1f3667	true	display.on.consent.screen
afa87c90-033f-4c84-b2cc-b5aecf1f3667	${samlRoleListScopeConsentText}	consent.screen.text
0fc988b4-555b-4552-ba5d-dcad9949464d	true	display.on.consent.screen
0fc988b4-555b-4552-ba5d-dcad9949464d	${profileScopeConsentText}	consent.screen.text
0fc988b4-555b-4552-ba5d-dcad9949464d	true	include.in.token.scope
aa7575c3-c000-48fc-b49f-d1a636e9aad3	true	display.on.consent.screen
aa7575c3-c000-48fc-b49f-d1a636e9aad3	${emailScopeConsentText}	consent.screen.text
aa7575c3-c000-48fc-b49f-d1a636e9aad3	true	include.in.token.scope
8862492b-3819-43fc-b18d-a7e0d4f98df2	true	display.on.consent.screen
8862492b-3819-43fc-b18d-a7e0d4f98df2	${addressScopeConsentText}	consent.screen.text
8862492b-3819-43fc-b18d-a7e0d4f98df2	true	include.in.token.scope
fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	true	display.on.consent.screen
fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	${phoneScopeConsentText}	consent.screen.text
fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	true	include.in.token.scope
0c05d94c-3a14-41a8-aae5-1f9444261cb8	true	display.on.consent.screen
0c05d94c-3a14-41a8-aae5-1f9444261cb8	${rolesScopeConsentText}	consent.screen.text
0c05d94c-3a14-41a8-aae5-1f9444261cb8	false	include.in.token.scope
71cba98e-b6bf-473e-b8a5-f1b6dcf47643	false	display.on.consent.screen
71cba98e-b6bf-473e-b8a5-f1b6dcf47643		consent.screen.text
71cba98e-b6bf-473e-b8a5-f1b6dcf47643	false	include.in.token.scope
ab6dcd38-fda1-4657-8d67-49922f9ba5f9	false	display.on.consent.screen
ab6dcd38-fda1-4657-8d67-49922f9ba5f9	true	include.in.token.scope
98f06ba5-8194-4b69-8d5f-c2aef35f707a	false	display.on.consent.screen
98f06ba5-8194-4b69-8d5f-c2aef35f707a	false	include.in.token.scope
\.


--
-- Data for Name: client_scope_client; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope_client (client_id, scope_id, default_scope) FROM stdin;
175549f9-bbf4-4afd-bde3-d1371c27ed9d	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
175549f9-bbf4-4afd-bde3-d1371c27ed9d	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
175549f9-bbf4-4afd-bde3-d1371c27ed9d	792e70bd-133f-4cff-98ca-2c473215f85d	t
175549f9-bbf4-4afd-bde3-d1371c27ed9d	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
175549f9-bbf4-4afd-bde3-d1371c27ed9d	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
175549f9-bbf4-4afd-bde3-d1371c27ed9d	9cb83105-0b9e-4143-beb9-68c719f48101	f
175549f9-bbf4-4afd-bde3-d1371c27ed9d	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
175549f9-bbf4-4afd-bde3-d1371c27ed9d	8dd342c0-eade-48a0-9ca2-18df93898a26	f
175549f9-bbf4-4afd-bde3-d1371c27ed9d	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
1027adf9-f5a4-4317-9aef-b634d978fb5f	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
1027adf9-f5a4-4317-9aef-b634d978fb5f	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
1027adf9-f5a4-4317-9aef-b634d978fb5f	792e70bd-133f-4cff-98ca-2c473215f85d	t
1027adf9-f5a4-4317-9aef-b634d978fb5f	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
1027adf9-f5a4-4317-9aef-b634d978fb5f	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
1027adf9-f5a4-4317-9aef-b634d978fb5f	9cb83105-0b9e-4143-beb9-68c719f48101	f
1027adf9-f5a4-4317-9aef-b634d978fb5f	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
1027adf9-f5a4-4317-9aef-b634d978fb5f	8dd342c0-eade-48a0-9ca2-18df93898a26	f
1027adf9-f5a4-4317-9aef-b634d978fb5f	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
27fc4a2e-e7af-47f2-9ad2-cf9612047884	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
27fc4a2e-e7af-47f2-9ad2-cf9612047884	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
27fc4a2e-e7af-47f2-9ad2-cf9612047884	792e70bd-133f-4cff-98ca-2c473215f85d	t
27fc4a2e-e7af-47f2-9ad2-cf9612047884	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
27fc4a2e-e7af-47f2-9ad2-cf9612047884	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
27fc4a2e-e7af-47f2-9ad2-cf9612047884	9cb83105-0b9e-4143-beb9-68c719f48101	f
27fc4a2e-e7af-47f2-9ad2-cf9612047884	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
27fc4a2e-e7af-47f2-9ad2-cf9612047884	8dd342c0-eade-48a0-9ca2-18df93898a26	f
27fc4a2e-e7af-47f2-9ad2-cf9612047884	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
50385586-9131-4a77-a928-d2fdfefc3173	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
50385586-9131-4a77-a928-d2fdfefc3173	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
50385586-9131-4a77-a928-d2fdfefc3173	792e70bd-133f-4cff-98ca-2c473215f85d	t
50385586-9131-4a77-a928-d2fdfefc3173	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
50385586-9131-4a77-a928-d2fdfefc3173	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
50385586-9131-4a77-a928-d2fdfefc3173	9cb83105-0b9e-4143-beb9-68c719f48101	f
50385586-9131-4a77-a928-d2fdfefc3173	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
50385586-9131-4a77-a928-d2fdfefc3173	8dd342c0-eade-48a0-9ca2-18df93898a26	f
50385586-9131-4a77-a928-d2fdfefc3173	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	792e70bd-133f-4cff-98ca-2c473215f85d	t
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	9cb83105-0b9e-4143-beb9-68c719f48101	f
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	8dd342c0-eade-48a0-9ca2-18df93898a26	f
33fbb3ed-00f4-4f09-86d9-ed0e682c528c	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
6311a773-e535-4fde-ac60-61694989a4bc	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
6311a773-e535-4fde-ac60-61694989a4bc	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
6311a773-e535-4fde-ac60-61694989a4bc	792e70bd-133f-4cff-98ca-2c473215f85d	t
6311a773-e535-4fde-ac60-61694989a4bc	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
6311a773-e535-4fde-ac60-61694989a4bc	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
6311a773-e535-4fde-ac60-61694989a4bc	9cb83105-0b9e-4143-beb9-68c719f48101	f
6311a773-e535-4fde-ac60-61694989a4bc	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
6311a773-e535-4fde-ac60-61694989a4bc	8dd342c0-eade-48a0-9ca2-18df93898a26	f
6311a773-e535-4fde-ac60-61694989a4bc	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
5edb3285-0625-4a5e-a93a-27c7b489020b	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
5edb3285-0625-4a5e-a93a-27c7b489020b	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
5edb3285-0625-4a5e-a93a-27c7b489020b	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
5edb3285-0625-4a5e-a93a-27c7b489020b	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
5edb3285-0625-4a5e-a93a-27c7b489020b	0fc988b4-555b-4552-ba5d-dcad9949464d	t
5edb3285-0625-4a5e-a93a-27c7b489020b	235681d5-862a-4654-8177-8d51967e4b86	f
5edb3285-0625-4a5e-a93a-27c7b489020b	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
5edb3285-0625-4a5e-a93a-27c7b489020b	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
5edb3285-0625-4a5e-a93a-27c7b489020b	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
6c46bf16-f287-447b-9e2c-9d017241dd84	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
6c46bf16-f287-447b-9e2c-9d017241dd84	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
6c46bf16-f287-447b-9e2c-9d017241dd84	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
6c46bf16-f287-447b-9e2c-9d017241dd84	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
6c46bf16-f287-447b-9e2c-9d017241dd84	0fc988b4-555b-4552-ba5d-dcad9949464d	t
6c46bf16-f287-447b-9e2c-9d017241dd84	235681d5-862a-4654-8177-8d51967e4b86	f
6c46bf16-f287-447b-9e2c-9d017241dd84	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
6c46bf16-f287-447b-9e2c-9d017241dd84	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
6c46bf16-f287-447b-9e2c-9d017241dd84	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
d10a6489-bf54-41bf-89da-a00122a8628d	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
d10a6489-bf54-41bf-89da-a00122a8628d	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
d10a6489-bf54-41bf-89da-a00122a8628d	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
d10a6489-bf54-41bf-89da-a00122a8628d	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
d10a6489-bf54-41bf-89da-a00122a8628d	0fc988b4-555b-4552-ba5d-dcad9949464d	t
d10a6489-bf54-41bf-89da-a00122a8628d	235681d5-862a-4654-8177-8d51967e4b86	f
d10a6489-bf54-41bf-89da-a00122a8628d	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
d10a6489-bf54-41bf-89da-a00122a8628d	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
d10a6489-bf54-41bf-89da-a00122a8628d	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	0fc988b4-555b-4552-ba5d-dcad9949464d	t
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	235681d5-862a-4654-8177-8d51967e4b86	f
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
7f4d1776-be78-4103-bbea-fde19008a431	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
7f4d1776-be78-4103-bbea-fde19008a431	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
7f4d1776-be78-4103-bbea-fde19008a431	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
7f4d1776-be78-4103-bbea-fde19008a431	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
7f4d1776-be78-4103-bbea-fde19008a431	0fc988b4-555b-4552-ba5d-dcad9949464d	t
7f4d1776-be78-4103-bbea-fde19008a431	235681d5-862a-4654-8177-8d51967e4b86	f
7f4d1776-be78-4103-bbea-fde19008a431	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
7f4d1776-be78-4103-bbea-fde19008a431	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
7f4d1776-be78-4103-bbea-fde19008a431	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
eff849b3-27b3-4b4e-986b-bb5986524cd1	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
eff849b3-27b3-4b4e-986b-bb5986524cd1	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
eff849b3-27b3-4b4e-986b-bb5986524cd1	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
eff849b3-27b3-4b4e-986b-bb5986524cd1	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
eff849b3-27b3-4b4e-986b-bb5986524cd1	0fc988b4-555b-4552-ba5d-dcad9949464d	t
eff849b3-27b3-4b4e-986b-bb5986524cd1	235681d5-862a-4654-8177-8d51967e4b86	f
eff849b3-27b3-4b4e-986b-bb5986524cd1	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
eff849b3-27b3-4b4e-986b-bb5986524cd1	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
eff849b3-27b3-4b4e-986b-bb5986524cd1	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	0fc988b4-555b-4552-ba5d-dcad9949464d	t
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	235681d5-862a-4654-8177-8d51967e4b86	f
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
\.


--
-- Data for Name: client_scope_role_mapping; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.client_scope_role_mapping (scope_id, role_id) FROM stdin;
8dd342c0-eade-48a0-9ca2-18df93898a26	57c0c2e4-d68e-487f-8856-3acb43a2216b
235681d5-862a-4654-8177-8d51967e4b86	90818fa4-9863-4101-bc97-c1007c78cf0c
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
c24d3659-7d6c-41a2-ac7a-b89421ec11dd	Trusted Hosts	15357e80-1b48-4482-93a9-2311f5c506f8	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	anonymous
1d2b9fbf-4c34-40c5-a218-0bf1bacfeb0f	Consent Required	15357e80-1b48-4482-93a9-2311f5c506f8	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	anonymous
fa66fa4e-3869-4ce0-ba5c-a514ce3b5846	Full Scope Disabled	15357e80-1b48-4482-93a9-2311f5c506f8	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	anonymous
f2e94a36-060a-45c7-8af5-7571101e8929	Max Clients Limit	15357e80-1b48-4482-93a9-2311f5c506f8	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	anonymous
6eb2cab6-b121-40a0-9cf4-f58c895a3137	Allowed Protocol Mapper Types	15357e80-1b48-4482-93a9-2311f5c506f8	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	anonymous
b0643cf3-cee1-4bc7-9f2c-abff2fb36fba	Allowed Client Scopes	15357e80-1b48-4482-93a9-2311f5c506f8	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	anonymous
1d46e9b4-7780-44e3-aea5-60fe82b297a8	Allowed Protocol Mapper Types	15357e80-1b48-4482-93a9-2311f5c506f8	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	authenticated
36458614-7608-4692-a9bd-40aacf4314d9	Allowed Client Scopes	15357e80-1b48-4482-93a9-2311f5c506f8	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	authenticated
574dfc72-3c6c-4217-9c4c-a683540ae39c	rsa-generated	15357e80-1b48-4482-93a9-2311f5c506f8	rsa-generated	org.keycloak.keys.KeyProvider	15357e80-1b48-4482-93a9-2311f5c506f8	\N
ebbff150-553d-4ff1-8319-2170288298cb	rsa-enc-generated	15357e80-1b48-4482-93a9-2311f5c506f8	rsa-enc-generated	org.keycloak.keys.KeyProvider	15357e80-1b48-4482-93a9-2311f5c506f8	\N
c70309ce-8b1b-43d6-b0de-1e5ee5da0a55	hmac-generated	15357e80-1b48-4482-93a9-2311f5c506f8	hmac-generated	org.keycloak.keys.KeyProvider	15357e80-1b48-4482-93a9-2311f5c506f8	\N
936c00fd-9596-49e7-b6c7-e8b9623f8b43	aes-generated	15357e80-1b48-4482-93a9-2311f5c506f8	aes-generated	org.keycloak.keys.KeyProvider	15357e80-1b48-4482-93a9-2311f5c506f8	\N
00b35e1c-8b66-4de3-bdfb-c460c7c202bf	rsa-generated	d4451a80-7ae2-4c36-999e-8e6184a6ec05	rsa-generated	org.keycloak.keys.KeyProvider	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N
36d2ee92-3d7b-4295-a651-9d41402dd925	rsa-enc-generated	d4451a80-7ae2-4c36-999e-8e6184a6ec05	rsa-enc-generated	org.keycloak.keys.KeyProvider	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N
5f36c41a-5e14-4a68-b592-00fe1cec7406	hmac-generated	d4451a80-7ae2-4c36-999e-8e6184a6ec05	hmac-generated	org.keycloak.keys.KeyProvider	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N
f38f3754-1795-47af-8c49-69cb408ef1cd	aes-generated	d4451a80-7ae2-4c36-999e-8e6184a6ec05	aes-generated	org.keycloak.keys.KeyProvider	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N
89d80a1c-484b-402c-bef8-d043fd0c726f	Trusted Hosts	d4451a80-7ae2-4c36-999e-8e6184a6ec05	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	anonymous
131e113e-bfae-438f-bf7d-997767e7dca8	Consent Required	d4451a80-7ae2-4c36-999e-8e6184a6ec05	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	anonymous
f2b4ad3a-09cd-4271-b119-fb1497c1269d	Full Scope Disabled	d4451a80-7ae2-4c36-999e-8e6184a6ec05	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	anonymous
fa699e63-f929-4e0d-aba9-4c9681d0bd59	Max Clients Limit	d4451a80-7ae2-4c36-999e-8e6184a6ec05	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	anonymous
81060bba-2b4f-433a-bf9d-a1afdc8c4419	Allowed Protocol Mapper Types	d4451a80-7ae2-4c36-999e-8e6184a6ec05	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	anonymous
0c50819a-e8a2-4124-9206-7ee06479470e	Allowed Client Scopes	d4451a80-7ae2-4c36-999e-8e6184a6ec05	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	anonymous
f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	Allowed Protocol Mapper Types	d4451a80-7ae2-4c36-999e-8e6184a6ec05	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	authenticated
224679e0-4792-4d4f-a246-ef93e2b258c4	Allowed Client Scopes	d4451a80-7ae2-4c36-999e-8e6184a6ec05	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	authenticated
\.


--
-- Data for Name: component_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.component_config (id, component_id, name, value) FROM stdin;
cfcf6211-6838-4d21-a9aa-5e9dffeb2722	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	saml-user-property-mapper
9f6fd91b-c192-4aae-8bdc-d95e26b3edca	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	oidc-full-name-mapper
3c12a16b-c614-4c11-aae3-0720e21808d3	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	saml-user-attribute-mapper
756dbf2c-a9e7-4b7f-8a2b-e689a4a81eda	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	oidc-address-mapper
6001c05d-471d-42af-8af9-5ffbf34da4d0	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	saml-role-list-mapper
5dcd80c4-3397-4bcc-9a50-8c2769655e4d	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
4db47367-0ec0-4743-8104-04ee55ce7bb2	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
04b74681-59ea-4b54-a645-7974e2505afc	1d46e9b4-7780-44e3-aea5-60fe82b297a8	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
ad8ffec3-5ef4-4e62-b54d-e49267fa57b4	b0643cf3-cee1-4bc7-9f2c-abff2fb36fba	allow-default-scopes	true
b3846956-1f39-47c4-ad98-5c34a5932aea	c24d3659-7d6c-41a2-ac7a-b89421ec11dd	host-sending-registration-request-must-match	true
135e8609-1ea6-4073-abc9-278f4aa2e410	c24d3659-7d6c-41a2-ac7a-b89421ec11dd	client-uris-must-match	true
52d01564-3d5a-49ed-b959-7ecb7cc02418	f2e94a36-060a-45c7-8af5-7571101e8929	max-clients	200
da47b2cf-2894-4cb3-ba26-0e2302d32df2	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
8807cff3-12c1-48fe-ae11-1dd37d38021c	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	oidc-address-mapper
49d4bea1-a337-4506-ae16-81f2c4634b7a	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
b22258ae-fe3c-4944-9f06-4fcf2b3a0ea0	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	saml-user-attribute-mapper
0f8b6d86-162d-4653-be6f-21ebe6ead604	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	saml-user-property-mapper
8a5a3fd7-6d12-4a94-a0c4-370c68792981	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
445b48ab-4ae4-4053-828b-296063505ed4	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	oidc-full-name-mapper
59637ab6-3b96-4eb9-9894-995e6ca0e35e	6eb2cab6-b121-40a0-9cf4-f58c895a3137	allowed-protocol-mapper-types	saml-role-list-mapper
eb0cf09d-149a-4bdb-aee0-f1ca275c70a8	36458614-7608-4692-a9bd-40aacf4314d9	allow-default-scopes	true
a430f776-8e70-4c2e-a13d-0a381ab46c72	574dfc72-3c6c-4217-9c4c-a683540ae39c	keyUse	SIG
7a77e550-dff7-447b-b5aa-58814384d680	574dfc72-3c6c-4217-9c4c-a683540ae39c	priority	100
276340f6-573b-43f0-bacb-7c07fb0df667	574dfc72-3c6c-4217-9c4c-a683540ae39c	certificate	MIICmzCCAYMCBgGNMt6YSDANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjQwMTIyMjAyOTI1WhcNMzQwMTIyMjAzMTA1WjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDKgy0WsJ2kpaozzOoR3gbpa/qWsx/1TkMNXirGFxAuJFTG6go5fTGK+1pYWulqp1XiCB9TKBHfahzPuXCnb7jYGKZi2iVg+EgV0YgSAHApxaXj0bs1dmOV7eR/VhAue+d4sZrIFp7cUmlcVaE1lOSWiJKB0CF+G+CBJdlJfwN6qgi4MCwU2Du4n5IdJ4F5TqYGOukDJBYFnyG+emwaY89oHEWUy6gXbvMAaaRyaaZ9ErAGSAsBu6bMNNjNSj7YKEL3hLGEFJACspc5Tj/gOKVuzUOEQGEy7SnCCWpjCvxZWHwpWs/qLYfyrKkufPQ06kKXuDAHpr1DbibwVkaFhoQTAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAFbK0otS+6SpALGWlzkIPZdtBZGqDXK+7c7xnSLqX8r32bDMnVbwAse40XQb0yoNdK9bfmb1J5wJNahyfYZhvL2LsC9lHH57OgRxbhnmro5OHIbVO9Nb8pGxqQWFxUFqOSenPUzuUPkTCvnhGIRTNLhB/NEJcFr8VxaDkH5vmQA7EDf1/w/msRAw/Do3gTM0KKidCclfdd/Iph0Ov6j1O6GbwG5DWzWte26z6hhfRsKOVciD/fOuAt+6coJggarS7pcCotgZYDLR63A/ysUgdg3WaKLKzY9QLCQhNFetpUIzUj6EuovSCtnVhBBe3J3FvPP6gswtQ4dOShA3uJqko6s=
fdf259ed-cf17-4c56-b80a-6ef79d84b675	574dfc72-3c6c-4217-9c4c-a683540ae39c	privateKey	MIIEowIBAAKCAQEAyoMtFrCdpKWqM8zqEd4G6Wv6lrMf9U5DDV4qxhcQLiRUxuoKOX0xivtaWFrpaqdV4ggfUygR32ocz7lwp2+42BimYtolYPhIFdGIEgBwKcWl49G7NXZjle3kf1YQLnvneLGayBae3FJpXFWhNZTkloiSgdAhfhvggSXZSX8DeqoIuDAsFNg7uJ+SHSeBeU6mBjrpAyQWBZ8hvnpsGmPPaBxFlMuoF27zAGmkcmmmfRKwBkgLAbumzDTYzUo+2ChC94SxhBSQArKXOU4/4Dilbs1DhEBhMu0pwglqYwr8WVh8KVrP6i2H8qypLnz0NOpCl7gwB6a9Q24m8FZGhYaEEwIDAQABAoIBACKk4TRF/5n4m07kSdDHrmAFUGeyeg+hlVf2mZOsw2BZZ8VlqV0fXTfc+x4tY0wTF16lLBKyQqh5QzeIDk0ekD0rrl8v2YAmyVIuN7x4pbeHr/Ly4LdrKustuM7N3tPM75LWs1dygzfGw25/2aXMdHSKJaIehHRJ+ZSucGch2usDWJuz0iPIw9D4aKWXJ6VdYyEoYQ0upbOwla4hCwrnv3Xxg9zey7c3OHY6hL6YMAxTLBjKcL3UGlXxR+AqydilgufBcnevXiOrU1tXMB7wn64OCcuIZ7by/Ty5NvEAEpCD/mF0JAT1CCAdHT2tJgxZfobEmD2YQ7IpexnVhmcQXyUCgYEA77Z9FXK/g86t6Y7QPyG1o0YpcIQajrmEmAJTXkpAFEBKDbg5iDWPZNXravvZGWl04oom+M1hITgmJ564UIdsIdTDwH+GsqXyZlok4/s2g6zgY+U/MQBB+fD0c3efI8lPSbauNRLfGP6XhnJm/s5GE2n/JBoMcCUiS0e5Odq8dMcCgYEA2EWhpaZPwboaLJSaEK2uEzCDOTA7zK5igFta/Dt2detel8EcEoY7TvmSg0grCmYqp3TJjH7i51nooes09pUoyEuPlNLfLfP3u7g6pRue9l6SJbI0BZf0TrSzYYZ2NgHt2DuznYtq3AbVwK4gIDm/08rLBybNELmSpd3exVgUUlUCgYEAlbzewckeDM3MITsOpoD+H3GybRB4LnOAehvpy9qB0KSgHZXYilc6rXhbSEbtxEv1sZUu5vgUFlYmr1UcOWF+kFuBs/t1Pp8engTtSmQgF3yj5oLLSGaqz+BOMtqkVAxqNNeiVpDlP425RUitQbnEWFg8AmcrIdpwY6n38EXMtv0CgYBe1dnWS6F5r+O+XMNaQO6uV32TXEU8sdNbubOiG2kMuFNYdEOdE+N59BJ9Iu5MtxRJLfsbcqCJFnHeXsdwwWOKwSeK+RUIj4y4cka1E/GW001+3i/VrBZjVPW79Dxt3lavlS5kDTiklxKwVSqdNvWZJ7nzvt35UYau2SXQn5j5qQKBgGnuN/cd5O9LeIegKxKeEM3LtFwBsdjkGyWIZ+izrvdQgmCvvdhlolh14L7Hokhks2UnMPZsFHh1xUnPIikhlB1q29qfz90BliRZZoVKDPjOeKxdbwwd2kd7/i3XCa+41eRXBiLich1h7F8sgyDza4axnC0GT9GRDTTUOyEsbWaD
57609f4e-ef3b-46be-9c78-e03c29a4266b	ebbff150-553d-4ff1-8319-2170288298cb	algorithm	RSA-OAEP
b1990748-e869-4bae-9d46-473ba3a9e221	ebbff150-553d-4ff1-8319-2170288298cb	certificate	MIICmzCCAYMCBgGNMt6ZJjANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjQwMTIyMjAyOTI1WhcNMzQwMTIyMjAzMTA1WjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCJM0r9zTrpvG43C2hok8X5enHjeoq/NjRwUzA4+rPF+ec6V+udsaotS8a82+sEmF50W2aCPakamQvMHtBDsMFDeaUc65gP2Ls4piEVJnPaKyQ6gl5IABkLDfhGMPDGwkFmHB1ClOIUmOcdg6bK7iqO53Q8ofMji7Z/vmkgmShCf9sgVrTQTku86iuLDGuOLyDb12XJwCijUUDnjS6V4Yi4uDjlIi8zljaHwkcOnmXc4cwkKaPEPp5y52tyfawK1dIIbiVZ8/Url+LtSUBjP6qfU4qwAYTvxk5D3bF/n/KTakHpxxt4bmsYLvI50VtHE2X36G3AxmMAcDq429jiMh9nAgMBAAEwDQYJKoZIhvcNAQELBQADggEBACbUftJrBFjJjO9cZj73LN6w1htY65Q4rGhWvZweHa5vD//FwJJnFO+iEe5FV+gHgxBN5VBXvDX/IlfZW4FiWSS4Ph80/vf6iFlthfaKgdlbs/sSvS6rMLfkZkdUd1aVz4d8TyxnZkWF+uOvvYrqE5bw/0yxSPgB5EkvxkgP0appoVWf2Wl0LwBu8xFA+csl9Om4hXIAcRUQKYywh0qBSLTSEoeviTX7lKwIRYkKHDmiLgdRHlhQgBTpjrNQUxi8sttwShwqg9iM0O4ZOqi/1f2H9ywHz3w2usa56KbFlg3mEnPGPFaDYVsxxQN68PoEVwPRaQ17eENBOgKlb8ZKA+c=
0569721b-1499-433d-89af-cff820bcffcc	ebbff150-553d-4ff1-8319-2170288298cb	privateKey	MIIEowIBAAKCAQEAiTNK/c066bxuNwtoaJPF+Xpx43qKvzY0cFMwOPqzxfnnOlfrnbGqLUvGvNvrBJhedFtmgj2pGpkLzB7QQ7DBQ3mlHOuYD9i7OKYhFSZz2iskOoJeSAAZCw34RjDwxsJBZhwdQpTiFJjnHYOmyu4qjud0PKHzI4u2f75pIJkoQn/bIFa00E5LvOoriwxrji8g29dlycAoo1FA540uleGIuLg45SIvM5Y2h8JHDp5l3OHMJCmjxD6ecudrcn2sCtXSCG4lWfP1K5fi7UlAYz+qn1OKsAGE78ZOQ92xf5/yk2pB6ccbeG5rGC7yOdFbRxNl9+htwMZjAHA6uNvY4jIfZwIDAQABAoIBAA6iJ+d2EkiHzoGUd+hfiogXZTpMAaxvTZyFYulQ5AfDpcP1SK4jGvGF2YafNivhTIHAlehiRz0NAdMdnjz6B0L5IIE7J5bZGO7r2S92UHj+jPiomwG28PTa4pYp9iRc57jKWtyVIJ/txwjA1/Ng/60KRr2I0HQEHMz3NCND8qVU8cEZlJ5PEfCwYKcl5xQSvrGv81Dbnj1BvmrQEcVufOHWyuBEAhGfoLzn/BDzVNcYwe/QOPUbNAzW+aLOVJGdqX29NXw/tNOyLJ43+uirxut2Q9BKPtAGhJztLduvXMwtWbUHBpHeSCJFcREd6vcfxvcmc022dMJ69AVQI6DefVECgYEAvZNbii3fCXT2zKOVLRK8YQUyIfdwmi82d6HyxCxpy4ESQKjcDTNZP807JLEQPOtTAHMkov9whExlDiq4yWHdFIT5CyKW0H8Xiv9Erru549gGarUFZQBrEH5H4uA8OE12LyO/IrWIBI4vAItd6+IYxXGVHRQKVIIxYmTr8AvudUMCgYEAuUX0lac1BJ2Quv5fNenD8+bPRbJEdLYsq6jV8cqoXS2NVRMTlG1QlLQzvjOuB78tobMjTJrBUJJdgOL7VMgX5zaYXOQvLXxEj+BfNUP0P6otunBmAA/53zrJ7jvf8A3EZLlCXV7iz7PEMscsKY0qKVErTi2os7SISz5SwlhY+Q0CgYEApIFIwCGKF8S9nVqeSpylh3Ngy4TS25j4pNuNtJntvEBmvGFLgtD6M5k+J1rXAmYagptoQWF0G/nG/4InE+muVO4GxpjfUlHW9jEJQq94YbTF7Lbk1X6FaayLaN64owrk8YcNh2sLexh+xPQrLlPmtv8XLEKFrEvF2uJEsutHo80CgYAs9TO/qN5tq0p2hclWzM32/ngngnWoGJjIYuTfkny+d5JHJaTnrIsUOpIfwmylhpetGEoliZwFUC8OWoYAcbmTKqVYTSrBj9kXTKvtwfqgBEyqZCHsO/Q3Xg2oGLFjkAOrKWVYQPEq04V1iO1He/DSK9clVmEMkm9MSuhMLqIQdQKBgENfDGpkAMGUykj1FggtUh56vTH9fuhZAVFFBXqQVWp2iJWEaqPzP0C7Kui20kZOxX4bPflRq1ItBw5oiwq3OVYjqjeNsnrvWRJG+XM3q1rauNFDxXyo389VZ9iNJra7MiSZPycwDN8b2obTswX9B9S9phfpClCcEAmfG/i82g8r
f8871cf9-5822-4f2f-b621-32ab37d9da5e	ebbff150-553d-4ff1-8319-2170288298cb	keyUse	ENC
fadb4760-ad08-4875-862a-bd46dfcef10a	ebbff150-553d-4ff1-8319-2170288298cb	priority	100
ee44faee-9402-493c-b110-3f5b3caafd1f	c70309ce-8b1b-43d6-b0de-1e5ee5da0a55	secret	wLXQscf3bxYAZ0u_N6DVzhMFVKjR6FSOqw1S7XVuyaA2JzzuBeq-6Xx5svuauclp3v_VsVDB0Jj2RIzg6PTyUQ
247b004d-48f1-4c55-83ec-054b712602ed	c70309ce-8b1b-43d6-b0de-1e5ee5da0a55	kid	f3fe3940-d438-4496-9040-5aff6367a7b1
5aa10062-6189-4d87-b7a7-b6ba79c34cca	c70309ce-8b1b-43d6-b0de-1e5ee5da0a55	priority	100
802f960c-1e68-4080-88c8-2c4d4a063351	c70309ce-8b1b-43d6-b0de-1e5ee5da0a55	algorithm	HS256
9749e288-a182-4901-8b4e-c9bd172e0cda	936c00fd-9596-49e7-b6c7-e8b9623f8b43	secret	VzTOdprF8GlqgkzNc25qHQ
0a56dd7d-9ed8-4714-a3dd-529e1d127f84	936c00fd-9596-49e7-b6c7-e8b9623f8b43	priority	100
09f23a22-b079-4630-a9d8-55bae4a8d5f9	936c00fd-9596-49e7-b6c7-e8b9623f8b43	kid	f18d773e-2010-4ee8-aaba-28fa2dbaf160
1fba2d6e-b32f-4ba9-8daa-ec37732ab88e	36d2ee92-3d7b-4295-a651-9d41402dd925	priority	100
8311d82a-2bc1-46cc-9e4c-b0d132e8ba0d	36d2ee92-3d7b-4295-a651-9d41402dd925	algorithm	RSA-OAEP
e1289e30-f1b3-4334-900f-2525f6cfcffa	36d2ee92-3d7b-4295-a651-9d41402dd925	certificate	MIICozCCAYsCBgGNN6oSbTANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDAptYXNrYW55b25lMB4XDTI0MDEyMzE4NTAwOVoXDTM0MDEyMzE4NTE0OVowFTETMBEGA1UEAwwKbWFza2FueW9uZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJi7v0VtpF7ToSCKs06XX2yrFEAap56BqAqkMHclFp/OVxIRRapfMp7i6z+Hd8yFWPqHPAH6GivM4jW/vycHoKDmOsu4MMR/zdVXfQ12Ztto5FEMwpc96BxKP3mEIwF0UnKNLdCPF3lrpPpkWOgqQ4JcoO0tdN5xXBxOJKPOw3eSekKAimM8uMWZfl3+bsuLcIjual9bMeb3uhgi7dDhyHHFZvhzwUpmXAtegVwgyuwinJg8bBB/sKW1ypUUDyms0ewYoTd+gbMbOJPBfKnyw6oZgiYTkVEG7k8aQUdfqzcVoy4aWByp84nQrpQZrTyY+5fl2Qk/gWz4Ny9hTpfhNCECAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAU7c4Pf3xzxAAsdVpUY2frgDWzbE71g8m0oCqTcVG1iMo9KpOpDn+5P9wQEVS02ZapRCY1auVGnwWjx7F0AEolOa9iTyZS6ns/FqM48Jfd5Y+DTlM9bNb98BWuogjUnC2Ex40ewTQnOcWpnTewLxdA+tYMzls2V4+a0tv+uOohAIiSeWtKoSLzx+wJDIDUgfse5fU703Nz99CKOtPPc2kxE1t9S9h9/iqpRkW0hPQ4/VD5hSjCnhVl9PmnnUTFYQvKZojVt3yoYsPmew5yWGhWD3Fo0zhFIVoIp7eS80d/QPlHM8+Mwiq0rPSyDluDZN3VnJhVRsv8E88WQCpRfpFcQ==
cf8f7921-1b70-424f-9408-6e4088292fc7	36d2ee92-3d7b-4295-a651-9d41402dd925	privateKey	MIIEoAIBAAKCAQEAmLu/RW2kXtOhIIqzTpdfbKsUQBqnnoGoCqQwdyUWn85XEhFFql8ynuLrP4d3zIVY+oc8AfoaK8ziNb+/JwegoOY6y7gwxH/N1Vd9DXZm22jkUQzClz3oHEo/eYQjAXRSco0t0I8XeWuk+mRY6CpDglyg7S103nFcHE4ko87Dd5J6QoCKYzy4xZl+Xf5uy4twiO5qX1sx5ve6GCLt0OHIccVm+HPBSmZcC16BXCDK7CKcmDxsEH+wpbXKlRQPKazR7BihN36Bsxs4k8F8qfLDqhmCJhORUQbuTxpBR1+rNxWjLhpYHKnzidCulBmtPJj7l+XZCT+BbPg3L2FOl+E0IQIDAQABAoH/K2v1DQAG4w63mFDWeVl/v51DvJXXYbDq3Vugi773l6dKCdDvRWibM6C/0OfqnzKqAU/BN66rEhjFlxJUffwlJplNze0nsDXFhwnAe7tVsrs3bfN6vxTSkHhrY1i1uwwfBIIurESCH/sChE1TGW4qkz1SYxuxRixkS4fL0uZNnAiP9DickdMwpknDr2ZSAti2Y7PLQgnvIHMbBnYZzi7hRDhxVgTrW6v3vUya3LfrqmZ1gbchMDc2tTsFLWVotdNSiiiQeKFgYmA1QNMJz1Ti7t8q7UtgP+TPErcFh91V+52oJ3j67nXpzkrIdEV6ns6OXObIEDk5GmQV9+URS3pBAoGBANcilDHcC+CR9+cSXJChnGxFfkxI4irCj1GuKVjHbtjKuVLJXQZYyi0eahoeByQBNot6dgjnDhQZrPL3pm1tJFdFXz9y9tf1U+KpN+vw8Iso0v48Wmxo0UoKD5CCkvlhP2BpPj6ZPA0HsXWPCdZn2bPNZ96EUkkQQb/B0Sf90ZthAoGBALW+v2DZMXhVH4fH7Cc+V0/vwpIU3NFb/vLHnCXZvCY9SDzf+LQe597HFURFNOgRQSUeew2ng8NJgplJFdU+ZrqojNQtJZoU026GEWNnW3GAQd++VCmy1GDJTL+DW9aI9Dd8oLXvW4pWwEU71GN3vXNhjyrlox3unPXjrwWCRRDBAoGAM6mQIPEQwRsMhyb3p5vHrpB5peQSu+YA+MJ0F2e9DL6SBnlop2+HDZKyNBdl65WG/bOoyLaDwPvxdl9WTgzZn0N/fgMjl/TH8jRkw3oWqbRiBr+Dj2kUaU1FM5THqq9ZwtNDKVEvBIoGaY6x9BT4SJ9ZBCyOfhEzWNM4YPwo68ECgYAffUQ1aIxMuBr1cKs3BXMlU3pXyyuTTqg2smUYncgerAGHIps5wh0UmVPS91a6Wrr5znUtoXeP732kR2h0ARLVhnyYCpZ4QuF7RdlfaroKSVmghZ6ZdvWbK2WTzROtcR83Oe2yeB1ZM7yugjZDYay+gAnJOe5wMjaZ1/AsOSz0QQKBgDS2tyVYZvAYVg+lQrRlOgHiU3A8AvMroc2jgbVAJpo2AjcFTshRgAukehYIFeIxNmiPIDaTUn+7Uv9pUGEhs0s22ibbjLtPvfZBlIWWcr8bVfVMk5Y1Zm0HhQaEKHEgAOX2NIxuIj+EN+B5gOgrxEDLDbj6kAetXUV176kNka32
e7b7e423-8c05-4ef2-8127-174fdcb74712	36d2ee92-3d7b-4295-a651-9d41402dd925	keyUse	ENC
3cfdef2d-bf40-444a-b49f-98820ea64bb4	5f36c41a-5e14-4a68-b592-00fe1cec7406	algorithm	HS256
393fe580-fbf8-4de7-9178-5fc38fb6a125	5f36c41a-5e14-4a68-b592-00fe1cec7406	priority	100
f7183a1f-5c8a-44ff-b04e-39033c389836	5f36c41a-5e14-4a68-b592-00fe1cec7406	secret	G-rndc4KCO_MohvfW4rvUd_LoL2-oMfxvXFg7WFAFweSokbbTwaVjKt3ICXjHV2gvyX-wL90STb5K7_ED_sSuw
2030c6c8-6be9-4a33-8081-44bca3b23671	5f36c41a-5e14-4a68-b592-00fe1cec7406	kid	cc5fbbcc-f326-441c-b811-c3e366c5ce23
5ce2334c-1170-45b1-a167-42933bbadab6	f38f3754-1795-47af-8c49-69cb408ef1cd	priority	100
5b58fc7f-1ce8-46ff-9380-12091d04e802	f38f3754-1795-47af-8c49-69cb408ef1cd	secret	98keixVP3guxqAvPxvjKww
7a64a02b-58f4-427d-b31a-cc77fa7fe527	f38f3754-1795-47af-8c49-69cb408ef1cd	kid	fbafae55-c07b-49ae-9c63-28ef7b649a68
ae12a06a-ae11-433d-bb06-b630efb55161	00b35e1c-8b66-4de3-bdfb-c460c7c202bf	privateKey	MIIEowIBAAKCAQEAsXeGEI7KQxGGA9fl8ISWvTu9K6ggPL886mU83kOxAqqSoSDnaG5CT3UbYqcgTmN4UNv5KMrdtqLvTOEWVo5ZBF48HHTUNDin20M6GNIQKPeQwTiY7H2vhjmcWabvchkjS8lKoMkheCZ5HJjsW+j+u6GgF0N/mloN2UgnejlTRUMMTpWA/Mr2TGbn8Yzxqtyiab/ywuAcWema5KfpqXdCCErcHqMjy0LXAJ70C2rXlgO8cC8nL49cRkNncpdXl3I9e9mNSBGwIP6WqVVBh6OmlOdIK94ALzJH3UeweAufqhw7jbGILj3YKr0o08lWuSTn9e28BpD0h8iIymY5h9LvlQIDAQABAoIBAD/w/bfnis7BeJTX7DxNuXYzGQSqzfq1OMCHe3fl0dhRFwXBMj95QqEYY6aW6tfzlP0lVM+y0FGmwSvlCcRkA4TEY0opee/a3fftb/hTb4kjMd+8gbTr0Bs/lKrkr+9fSU1cGGx4K3v7+LUqEDdJasa2BFV9d3NosQaxra+nCe6xEHDBJ9f/azIkG8SRzs0IoyrlB51yWnRzr2uikARfWp2tJoCDq+BEE3UrUijwNe+ppEyx1KhbHZJk7I4rkElRCL3wSrt2sxLrJ87z7vcLlAoS8SY5yFfCkqWA4Tnna3YuMzz0PPDubtU7hSaqoYF53nM3vo+PbHvz4cfJ0fovQT0CgYEA6gX9wKO5uSSjgwwNylkRvR1WeasPYns2HYwGv1J6EnvyrTUh1KWZjTrEHautnfM8AkUssEP/qj8twSyQW1d0n/iUE3fOPXqcVoLJLWa5hNhBy40xrx+4TLD9mxQ9ZFt5NjW81H6speYWKrYEGaK6L5iQmEj0iQexBYhMB9oDhfsCgYEAwiHknzFoBduQ5T3Q57xkYyQDtZVWoVwELydozeUpBJrSBJcx1juSi7VH1YlP7vjP29aIBx7otzRSGig7zNSig35WkMoOtYN1/Cxca5vXHWo4BJTA/vwJ4vlW7DzpAZSiErhlhQAjFPplKLMae71GLKC7D9JRg/9/PHH4yHvku68CgYAnnmIKNe2gSXKhIe5HvnKBWLEmIe6V1pQfxm/x/e2KqY85AZC7pllrjnJbL5BR+DbFj550LN7gnJeLZ5b8z75/wp6W+SZiRBqpjrSuSgDIW7Av3LR3mGAkI6ablX6bOd04bzqLovJpl51TF8Nz75ejrSl1joxPkozGif+NKLyF9wKBgQC6lbLT4ruVLbQ08NXxdNuTghDinNc3nWYUIC+V/RQQbfE/IkZvHrC6AJE7Ro+CIrg9FhOFrIqFUw86PsNDGnfcJDh1Tw8WHHTw2340mwMFLYsLtCFOsdWaxoVp5x0YPNANaBeC3l/ZkNRbatEgbwmcaRuBmGZqlM2ove4cWx+71wKBgHGWeL1kvjhqrNKIibmt4LCZ6KNETSsKqVSrEwRgIy6xh+8WdHT42nXPEanqYT38gFlR+k+m/LZmvGeeiHlPm7J9VLwnAOJNDnwSsJVyyQa9fQ+geHdNDO7ZzHZeLTklA0o8oUQ85BcTsg7OaC53j8Lz+lcy3hUunrgwE4TP91Yd
900d8764-0727-4c54-8103-35a8d18a2c41	00b35e1c-8b66-4de3-bdfb-c460c7c202bf	certificate	MIICozCCAYsCBgGNN6oR6jANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDAptYXNrYW55b25lMB4XDTI0MDEyMzE4NTAwOVoXDTM0MDEyMzE4NTE0OVowFTETMBEGA1UEAwwKbWFza2FueW9uZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALF3hhCOykMRhgPX5fCElr07vSuoIDy/POplPN5DsQKqkqEg52huQk91G2KnIE5jeFDb+SjK3bai70zhFlaOWQRePBx01DQ4p9tDOhjSECj3kME4mOx9r4Y5nFmm73IZI0vJSqDJIXgmeRyY7Fvo/ruhoBdDf5paDdlIJ3o5U0VDDE6VgPzK9kxm5/GM8arcomm/8sLgHFnpmuSn6al3QghK3B6jI8tC1wCe9Atq15YDvHAvJy+PXEZDZ3KXV5dyPXvZjUgRsCD+lqlVQYejppTnSCveAC8yR91HsHgLn6ocO42xiC492Cq9KNPJVrkk5/XtvAaQ9IfIiMpmOYfS75UCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAhvkuijo9cT9x0r0xsPN6BHDA6BS+xY9B2DkUCjCYv9U2pwbEDnSfp05qQtKfMaXYYPiv8vKU/mwPFRW1M8qr4echuvooLrAah/SCBYSq4Ho6iaS+hDlnEbLWkWJNpv7y/MXeZYfrmpCl3RB0c6rcRHsLBK6rvlq6h17Y8BPZZG6XlQUU0CCDYaecIt8QFEX6c9DWkzVjXrlZEV5ma6cBEh+6TC0qEepstGI+War9o1HrotwDiJTNydGI0mASTddeijv4yGZhsPW5c2THjMD0l6eraQgH0ospy6M+K7m8KkgBGW0W2u7QQlEyOPLsfxhcPCy4K3m0BtOW0sMvp0p3qA==
fac5aa14-77e2-4c52-9145-0404ddfe4bbe	00b35e1c-8b66-4de3-bdfb-c460c7c202bf	priority	100
6d11b2fe-35e2-4e96-9a1b-9fa7e4561957	00b35e1c-8b66-4de3-bdfb-c460c7c202bf	keyUse	SIG
5b6dd07c-0504-40e2-80a5-b54732568ba3	fa699e63-f929-4e0d-aba9-4c9681d0bd59	max-clients	200
5dbe9262-9f1a-434e-9dcc-d35f386c1ff8	0c50819a-e8a2-4124-9206-7ee06479470e	allow-default-scopes	true
8d026bb7-62ba-4190-b852-985fc8be2f89	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	saml-user-property-mapper
6e38feb4-073e-494b-91d3-2e334cea15d5	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
6f16ecfc-97ba-4e1b-ab11-c7dc7424f657	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	oidc-address-mapper
c3022189-929e-4e83-a5bd-028834811b7f	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
d02e8790-eeb9-49a3-954a-b5748be28e23	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	oidc-full-name-mapper
6e0b8c40-ef15-4a70-895a-a41cb5b56ebf	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	saml-user-attribute-mapper
3841a441-1a53-49f3-99b1-6e867f0cd185	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	saml-role-list-mapper
ceba698e-34e6-4187-88bc-334f06baa2c4	81060bba-2b4f-433a-bf9d-a1afdc8c4419	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
588d289a-77c2-42d8-a97b-e10f6f2a0a3b	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
6c160b41-40a9-4062-8eb9-e5ad7616036d	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
280cf6c6-faef-48b3-bb25-614192ace081	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	saml-user-property-mapper
495387d4-d8d7-45a4-861c-88ad3ff84a59	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	saml-user-attribute-mapper
c32b7c7a-72aa-4c82-b60e-bbb685ba03ea	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	oidc-full-name-mapper
137cb8e4-b6cb-4dde-a930-bbec78d48b19	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	saml-role-list-mapper
730f1548-229d-46c3-9820-f83529f0e286	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	oidc-address-mapper
bbe40cb9-1d54-408f-9fdb-fbc49720126e	f8ce4ba4-f659-4bf4-b03c-5715c1f3bbf8	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
7395c49a-b199-4ca2-a426-3eb725505cc2	89d80a1c-484b-402c-bef8-d043fd0c726f	client-uris-must-match	true
65e077fd-c526-427d-93cb-4bb1bd4a3de9	89d80a1c-484b-402c-bef8-d043fd0c726f	host-sending-registration-request-must-match	true
40fbe582-5825-406b-b9b2-70d4c4897094	224679e0-4792-4d4f-a246-ef93e2b258c4	allow-default-scopes	true
\.


--
-- Data for Name: composite_role; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.composite_role (composite, child_role) FROM stdin;
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	d703598d-25f4-4c74-bee6-cd09d60c363b
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	5492ef4e-43e0-41fd-8203-bb96022ee96e
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	4910c258-54ed-429b-8f8a-5e68dd077d71
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	c77a6e8e-e784-4be3-91da-53877f570dd5
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	04c3016b-3943-4583-901e-d900b6c8a006
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	c74250bd-a82e-47b6-bf49-1e4152779848
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	c6d5fe21-ab9f-40eb-9124-94f2982ef694
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	95deb6d2-1000-448e-bf28-80bc991df8c1
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	8e137a80-73f1-4cc9-9ffe-30b1b993b76b
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	dbce6153-99d6-419c-8ad1-3d422d9b20f3
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	907bde45-0fd4-4aa6-95d4-eb0f032747de
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	053ea80d-129d-4dbc-81b0-a0b9b94cc04e
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	63a10ea9-8485-4dae-9910-a4513e4f45b8
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	c8dfc6d1-64b4-4460-8326-e107a205b7ea
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	d35de0ac-03de-4fb2-92fd-f966b6d7648c
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	9093c50f-cd23-4241-afae-3c14bf6c93cc
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	b2d04492-5049-4426-a37c-fc863ab5a957
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	55fb5940-cd8b-4fb6-bb29-9cca8c84df19
04c3016b-3943-4583-901e-d900b6c8a006	9093c50f-cd23-4241-afae-3c14bf6c93cc
a06d40f9-1f4c-4ec6-affc-4e64e2803ea9	fb64aa40-b26c-4a63-82f4-ff926bb81071
c77a6e8e-e784-4be3-91da-53877f570dd5	d35de0ac-03de-4fb2-92fd-f966b6d7648c
c77a6e8e-e784-4be3-91da-53877f570dd5	55fb5940-cd8b-4fb6-bb29-9cca8c84df19
a06d40f9-1f4c-4ec6-affc-4e64e2803ea9	9ff4acc5-0f84-4b89-9e1b-b7116c86c843
9ff4acc5-0f84-4b89-9e1b-b7116c86c843	9c4fa0b6-1e6a-4273-9b3e-6cfb03294299
9ba92f5b-24da-4319-861d-b57ad8f3b144	8ff7690d-1058-49d0-9c12-004de4f5f01b
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	079b9e97-f375-4c68-9906-aec8cead59f0
a06d40f9-1f4c-4ec6-affc-4e64e2803ea9	57c0c2e4-d68e-487f-8856-3acb43a2216b
a06d40f9-1f4c-4ec6-affc-4e64e2803ea9	5e2ed825-2c99-4f6e-b133-a3633d7f1806
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	54ba87cf-a7bd-49be-8083-a2bf6b023c68
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	72a999b0-44e1-4cba-91ae-969d339f3083
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	59074f6b-e7a6-49f6-8169-4ef6fd6b0ab6
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	588b1669-bbfb-497b-b852-2a9ed79d90c1
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	cf79e2a4-833e-459f-a9a3-2b695d36b9fe
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	c2fa8fc2-48ff-4523-9162-e7485a4804e5
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	213432b2-4ec7-40c4-887e-cf658c5c833f
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	396febca-1a30-4a8a-b6f3-ec37512b411b
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	5101e6bc-eb30-422a-a4cf-826b6b22d471
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	8a647b27-11a3-41ab-ad89-989dac04d134
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	7e5d707a-0beb-4e4f-b1a8-208e30d21b2c
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	4e4e3f0a-812d-41e5-a7aa-7c4d1a588e0d
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	8fe53906-ceeb-4819-b4d8-40f7d2e5dbb5
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	14bbc843-46b6-40a0-beda-fd2246be2404
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	947beb93-4b2f-47ae-b1ec-cd45e1baf44a
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	4dfb1e0c-8119-46db-bf1c-afc7e9c67ef5
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	da3e31cb-a541-400c-9195-122bc93fe061
588b1669-bbfb-497b-b852-2a9ed79d90c1	947beb93-4b2f-47ae-b1ec-cd45e1baf44a
59074f6b-e7a6-49f6-8169-4ef6fd6b0ab6	da3e31cb-a541-400c-9195-122bc93fe061
59074f6b-e7a6-49f6-8169-4ef6fd6b0ab6	14bbc843-46b6-40a0-beda-fd2246be2404
fe08970b-0770-4157-9ebc-e37c4868f4b5	2cc9e686-a942-4e1e-b101-29c5313f9a16
fe08970b-0770-4157-9ebc-e37c4868f4b5	86085310-8759-4109-a2d3-62f4a8e65eb2
fe08970b-0770-4157-9ebc-e37c4868f4b5	3e129908-cd48-42e9-940d-6ff7dc3215bf
fe08970b-0770-4157-9ebc-e37c4868f4b5	8d143ed9-65a1-439a-b7f5-d548e6f722ab
fe08970b-0770-4157-9ebc-e37c4868f4b5	be8619e2-3653-47da-9abf-5211f12cd992
fe08970b-0770-4157-9ebc-e37c4868f4b5	84d32185-ee4e-4f60-8462-6fd05d5bb5f4
fe08970b-0770-4157-9ebc-e37c4868f4b5	fec02ffb-11b2-4bd1-a973-de8490989910
fe08970b-0770-4157-9ebc-e37c4868f4b5	33a1b992-06e7-483b-917f-b8abf45d2d45
fe08970b-0770-4157-9ebc-e37c4868f4b5	70e22d50-8711-4a02-a479-91e5844f7f1c
fe08970b-0770-4157-9ebc-e37c4868f4b5	9ee3d272-9d55-4266-a271-8c3bb40cbc37
fe08970b-0770-4157-9ebc-e37c4868f4b5	f4ed715a-0d50-4252-aab9-a32aa71b4670
fe08970b-0770-4157-9ebc-e37c4868f4b5	06daf1be-dd52-4ac3-98c6-6a04e6c339c5
fe08970b-0770-4157-9ebc-e37c4868f4b5	9f8e1bb6-128c-43da-b9a7-e9083f1e9588
fe08970b-0770-4157-9ebc-e37c4868f4b5	63b3267f-cb4d-44b9-ac49-8e75e8592232
fe08970b-0770-4157-9ebc-e37c4868f4b5	99117ba4-388c-43e7-b5d5-64f300b7002d
fe08970b-0770-4157-9ebc-e37c4868f4b5	fa50f3ac-0c51-487b-9374-062694b68ee4
fe08970b-0770-4157-9ebc-e37c4868f4b5	bf95db4b-3416-4fd1-84cd-15d019621e88
166370f4-a467-404c-b411-06e4d5af8895	52711218-298b-4698-8c81-1b0a97cf95eb
3e129908-cd48-42e9-940d-6ff7dc3215bf	63b3267f-cb4d-44b9-ac49-8e75e8592232
3e129908-cd48-42e9-940d-6ff7dc3215bf	bf95db4b-3416-4fd1-84cd-15d019621e88
8d143ed9-65a1-439a-b7f5-d548e6f722ab	99117ba4-388c-43e7-b5d5-64f300b7002d
166370f4-a467-404c-b411-06e4d5af8895	dbd0c2a7-ab8e-4917-a2cc-d93d66b73401
dbd0c2a7-ab8e-4917-a2cc-d93d66b73401	73083079-1aff-47ee-b122-8bc0460f612f
fec05d01-eae2-4bc0-8d3f-78772fbc8744	faf5a6f2-dff0-4c3a-8932-39da260256ab
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	acae0528-9f38-41c0-bc3a-fa62f434cfd8
fe08970b-0770-4157-9ebc-e37c4868f4b5	a0bc5c17-df74-4b16-bbb4-c4673d7ee9f2
166370f4-a467-404c-b411-06e4d5af8895	90818fa4-9863-4101-bc97-c1007c78cf0c
166370f4-a467-404c-b411-06e4d5af8895	2aaf3931-2b6c-4057-ba51-dcc58c6665bf
\.


--
-- Data for Name: credential; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.credential (id, salt, type, user_id, created_date, user_label, secret_data, credential_data, priority) FROM stdin;
f3feb718-bacc-433b-9f2e-2ac9adc45539	\N	password	6feec7e0-d77f-48e3-801b-07c92666edb2	1705955466112	\N	{"value":"hzWSks01dOyi6JS8ek8DRp2LjZY0nZwaQGE0dHVIy3Q=","salt":"rCyWxfvC13bSeDnEhVdAog==","additionalParameters":{}}	{"hashIterations":27500,"algorithm":"pbkdf2-sha256","additionalParameters":{}}	10
9cfce5b5-624d-4df3-979d-815a65682182	\N	password	51ebd241-a1c5-481f-b1e3-35bf714277ea	1706037485208	My password	{"value":"YDBfLPPeza32Ft3jRxSK2h4HWXldsiop2c1eFsos7/I=","salt":"WIjwcD24FDG+RAS4BkatCg==","additionalParameters":{}}	{"hashIterations":27500,"algorithm":"pbkdf2-sha256","additionalParameters":{}}	10
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/jpa-changelog-1.0.0.Final.xml	2024-01-22 20:31:00.085367	1	EXECUTED	9:6f1016664e21e16d26517a4418f5e3df	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.23.2	\N	\N	5955459096
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/db2-jpa-changelog-1.0.0.Final.xml	2024-01-22 20:31:00.131077	2	MARK_RAN	9:828775b1596a07d1200ba1d49e5e3941	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.23.2	\N	\N	5955459096
1.1.0.Beta1	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Beta1.xml	2024-01-22 20:31:00.196242	3	EXECUTED	9:5f090e44a7d595883c1fb61f4b41fd38	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=CLIENT_ATTRIBUTES; createTable tableName=CLIENT_SESSION_NOTE; createTable tableName=APP_NODE_REGISTRATIONS; addColumn table...		\N	4.23.2	\N	\N	5955459096
1.1.0.Final	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Final.xml	2024-01-22 20:31:00.213082	4	EXECUTED	9:c07e577387a3d2c04d1adc9aaad8730e	renameColumn newColumnName=EVENT_TIME, oldColumnName=TIME, tableName=EVENT_ENTITY		\N	4.23.2	\N	\N	5955459096
1.2.0.Beta1	psilva@redhat.com	META-INF/jpa-changelog-1.2.0.Beta1.xml	2024-01-22 20:31:00.453927	5	EXECUTED	9:b68ce996c655922dbcd2fe6b6ae72686	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.23.2	\N	\N	5955459096
1.2.0.Beta1	psilva@redhat.com	META-INF/db2-jpa-changelog-1.2.0.Beta1.xml	2024-01-22 20:31:00.471916	6	MARK_RAN	9:543b5c9989f024fe35c6f6c5a97de88e	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.23.2	\N	\N	5955459096
1.2.0.RC1	bburke@redhat.com	META-INF/jpa-changelog-1.2.0.CR1.xml	2024-01-22 20:31:00.6282	7	EXECUTED	9:765afebbe21cf5bbca048e632df38336	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.23.2	\N	\N	5955459096
1.2.0.RC1	bburke@redhat.com	META-INF/db2-jpa-changelog-1.2.0.CR1.xml	2024-01-22 20:31:00.671846	8	MARK_RAN	9:db4a145ba11a6fdaefb397f6dbf829a1	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.23.2	\N	\N	5955459096
1.2.0.Final	keycloak	META-INF/jpa-changelog-1.2.0.Final.xml	2024-01-22 20:31:00.682061	9	EXECUTED	9:9d05c7be10cdb873f8bcb41bc3a8ab23	update tableName=CLIENT; update tableName=CLIENT; update tableName=CLIENT		\N	4.23.2	\N	\N	5955459096
1.3.0	bburke@redhat.com	META-INF/jpa-changelog-1.3.0.xml	2024-01-22 20:31:00.858103	10	EXECUTED	9:18593702353128d53111f9b1ff0b82b8	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=ADMI...		\N	4.23.2	\N	\N	5955459096
1.4.0	bburke@redhat.com	META-INF/jpa-changelog-1.4.0.xml	2024-01-22 20:31:00.931953	11	EXECUTED	9:6122efe5f090e41a85c0f1c9e52cbb62	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.23.2	\N	\N	5955459096
1.4.0	bburke@redhat.com	META-INF/db2-jpa-changelog-1.4.0.xml	2024-01-22 20:31:00.942175	12	MARK_RAN	9:e1ff28bf7568451453f844c5d54bb0b5	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.23.2	\N	\N	5955459096
1.5.0	bburke@redhat.com	META-INF/jpa-changelog-1.5.0.xml	2024-01-22 20:31:00.970749	13	EXECUTED	9:7af32cd8957fbc069f796b61217483fd	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.23.2	\N	\N	5955459096
1.6.1_from15	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-01-22 20:31:01.004048	14	EXECUTED	9:6005e15e84714cd83226bf7879f54190	addColumn tableName=REALM; addColumn tableName=KEYCLOAK_ROLE; addColumn tableName=CLIENT; createTable tableName=OFFLINE_USER_SESSION; createTable tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_US_SES_PK2, tableName=...		\N	4.23.2	\N	\N	5955459096
1.6.1_from16-pre	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-01-22 20:31:01.00698	15	MARK_RAN	9:bf656f5a2b055d07f314431cae76f06c	delete tableName=OFFLINE_CLIENT_SESSION; delete tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	5955459096
1.6.1_from16	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-01-22 20:31:01.011738	16	MARK_RAN	9:f8dadc9284440469dcf71e25ca6ab99b	dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_US_SES_PK, tableName=OFFLINE_USER_SESSION; dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_CL_SES_PK, tableName=OFFLINE_CLIENT_SESSION; addColumn tableName=OFFLINE_USER_SESSION; update tableName=OF...		\N	4.23.2	\N	\N	5955459096
1.6.1	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2024-01-22 20:31:01.015985	17	EXECUTED	9:d41d8cd98f00b204e9800998ecf8427e	empty		\N	4.23.2	\N	\N	5955459096
1.7.0	bburke@redhat.com	META-INF/jpa-changelog-1.7.0.xml	2024-01-22 20:31:01.107012	18	EXECUTED	9:3368ff0be4c2855ee2dd9ca813b38d8e	createTable tableName=KEYCLOAK_GROUP; createTable tableName=GROUP_ROLE_MAPPING; createTable tableName=GROUP_ATTRIBUTE; createTable tableName=USER_GROUP_MEMBERSHIP; createTable tableName=REALM_DEFAULT_GROUPS; addColumn tableName=IDENTITY_PROVIDER; ...		\N	4.23.2	\N	\N	5955459096
1.8.0	mposolda@redhat.com	META-INF/jpa-changelog-1.8.0.xml	2024-01-22 20:31:01.173781	19	EXECUTED	9:8ac2fb5dd030b24c0570a763ed75ed20	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.23.2	\N	\N	5955459096
1.8.0-2	keycloak	META-INF/jpa-changelog-1.8.0.xml	2024-01-22 20:31:01.182025	20	EXECUTED	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.23.2	\N	\N	5955459096
1.8.0	mposolda@redhat.com	META-INF/db2-jpa-changelog-1.8.0.xml	2024-01-22 20:31:01.192682	21	MARK_RAN	9:831e82914316dc8a57dc09d755f23c51	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.23.2	\N	\N	5955459096
1.8.0-2	keycloak	META-INF/db2-jpa-changelog-1.8.0.xml	2024-01-22 20:31:01.197213	22	MARK_RAN	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.23.2	\N	\N	5955459096
1.9.0	mposolda@redhat.com	META-INF/jpa-changelog-1.9.0.xml	2024-01-22 20:31:01.231397	23	EXECUTED	9:bc3d0f9e823a69dc21e23e94c7a94bb1	update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=REALM; update tableName=REALM; customChange; dr...		\N	4.23.2	\N	\N	5955459096
1.9.1	keycloak	META-INF/jpa-changelog-1.9.1.xml	2024-01-22 20:31:01.240862	24	EXECUTED	9:c9999da42f543575ab790e76439a2679	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=PUBLIC_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.23.2	\N	\N	5955459096
1.9.1	keycloak	META-INF/db2-jpa-changelog-1.9.1.xml	2024-01-22 20:31:01.244151	25	MARK_RAN	9:0d6c65c6f58732d81569e77b10ba301d	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.23.2	\N	\N	5955459096
1.9.2	keycloak	META-INF/jpa-changelog-1.9.2.xml	2024-01-22 20:31:01.299781	26	EXECUTED	9:fc576660fc016ae53d2d4778d84d86d0	createIndex indexName=IDX_USER_EMAIL, tableName=USER_ENTITY; createIndex indexName=IDX_USER_ROLE_MAPPING, tableName=USER_ROLE_MAPPING; createIndex indexName=IDX_USER_GROUP_MAPPING, tableName=USER_GROUP_MEMBERSHIP; createIndex indexName=IDX_USER_CO...		\N	4.23.2	\N	\N	5955459096
authz-2.0.0	psilva@redhat.com	META-INF/jpa-changelog-authz-2.0.0.xml	2024-01-22 20:31:01.455266	27	EXECUTED	9:43ed6b0da89ff77206289e87eaa9c024	createTable tableName=RESOURCE_SERVER; addPrimaryKey constraintName=CONSTRAINT_FARS, tableName=RESOURCE_SERVER; addUniqueConstraint constraintName=UK_AU8TT6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER; createTable tableName=RESOURCE_SERVER_RESOU...		\N	4.23.2	\N	\N	5955459096
authz-2.5.1	psilva@redhat.com	META-INF/jpa-changelog-authz-2.5.1.xml	2024-01-22 20:31:01.465645	28	EXECUTED	9:44bae577f551b3738740281eceb4ea70	update tableName=RESOURCE_SERVER_POLICY		\N	4.23.2	\N	\N	5955459096
2.1.0-KEYCLOAK-5461	bburke@redhat.com	META-INF/jpa-changelog-2.1.0.xml	2024-01-22 20:31:01.608897	29	EXECUTED	9:bd88e1f833df0420b01e114533aee5e8	createTable tableName=BROKER_LINK; createTable tableName=FED_USER_ATTRIBUTE; createTable tableName=FED_USER_CONSENT; createTable tableName=FED_USER_CONSENT_ROLE; createTable tableName=FED_USER_CONSENT_PROT_MAPPER; createTable tableName=FED_USER_CR...		\N	4.23.2	\N	\N	5955459096
2.2.0	bburke@redhat.com	META-INF/jpa-changelog-2.2.0.xml	2024-01-22 20:31:01.64099	30	EXECUTED	9:a7022af5267f019d020edfe316ef4371	addColumn tableName=ADMIN_EVENT_ENTITY; createTable tableName=CREDENTIAL_ATTRIBUTE; createTable tableName=FED_CREDENTIAL_ATTRIBUTE; modifyDataType columnName=VALUE, tableName=CREDENTIAL; addForeignKeyConstraint baseTableName=FED_CREDENTIAL_ATTRIBU...		\N	4.23.2	\N	\N	5955459096
2.3.0	bburke@redhat.com	META-INF/jpa-changelog-2.3.0.xml	2024-01-22 20:31:01.669674	31	EXECUTED	9:fc155c394040654d6a79227e56f5e25a	createTable tableName=FEDERATED_USER; addPrimaryKey constraintName=CONSTR_FEDERATED_USER, tableName=FEDERATED_USER; dropDefaultValue columnName=TOTP, tableName=USER_ENTITY; dropColumn columnName=TOTP, tableName=USER_ENTITY; addColumn tableName=IDE...		\N	4.23.2	\N	\N	5955459096
2.4.0	bburke@redhat.com	META-INF/jpa-changelog-2.4.0.xml	2024-01-22 20:31:01.676579	32	EXECUTED	9:eac4ffb2a14795e5dc7b426063e54d88	customChange		\N	4.23.2	\N	\N	5955459096
2.5.0	bburke@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-01-22 20:31:01.685246	33	EXECUTED	9:54937c05672568c4c64fc9524c1e9462	customChange; modifyDataType columnName=USER_ID, tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	5955459096
2.5.0-unicode-oracle	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-01-22 20:31:01.69005	34	MARK_RAN	9:3a32bace77c84d7678d035a7f5a8084e	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.23.2	\N	\N	5955459096
2.5.0-unicode-other-dbs	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-01-22 20:31:01.736097	35	EXECUTED	9:33d72168746f81f98ae3a1e8e0ca3554	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.23.2	\N	\N	5955459096
2.5.0-duplicate-email-support	slawomir@dabek.name	META-INF/jpa-changelog-2.5.0.xml	2024-01-22 20:31:01.744448	36	EXECUTED	9:61b6d3d7a4c0e0024b0c839da283da0c	addColumn tableName=REALM		\N	4.23.2	\N	\N	5955459096
2.5.0-unique-group-names	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2024-01-22 20:31:01.756778	37	EXECUTED	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	5955459096
2.5.1	bburke@redhat.com	META-INF/jpa-changelog-2.5.1.xml	2024-01-22 20:31:01.763908	38	EXECUTED	9:a2b870802540cb3faa72098db5388af3	addColumn tableName=FED_USER_CONSENT		\N	4.23.2	\N	\N	5955459096
3.0.0	bburke@redhat.com	META-INF/jpa-changelog-3.0.0.xml	2024-01-22 20:31:01.771214	39	EXECUTED	9:132a67499ba24bcc54fb5cbdcfe7e4c0	addColumn tableName=IDENTITY_PROVIDER		\N	4.23.2	\N	\N	5955459096
3.2.0-fix	keycloak	META-INF/jpa-changelog-3.2.0.xml	2024-01-22 20:31:01.774771	40	MARK_RAN	9:938f894c032f5430f2b0fafb1a243462	addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS		\N	4.23.2	\N	\N	5955459096
3.2.0-fix-with-keycloak-5416	keycloak	META-INF/jpa-changelog-3.2.0.xml	2024-01-22 20:31:01.779373	41	MARK_RAN	9:845c332ff1874dc5d35974b0babf3006	dropIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS; addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS; createIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS		\N	4.23.2	\N	\N	5955459096
3.2.0-fix-offline-sessions	hmlnarik	META-INF/jpa-changelog-3.2.0.xml	2024-01-22 20:31:01.786023	42	EXECUTED	9:fc86359c079781adc577c5a217e4d04c	customChange		\N	4.23.2	\N	\N	5955459096
3.2.0-fixed	keycloak	META-INF/jpa-changelog-3.2.0.xml	2024-01-22 20:31:02.1153	43	EXECUTED	9:59a64800e3c0d09b825f8a3b444fa8f4	addColumn tableName=REALM; dropPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_PK2, tableName=OFFLINE_CLIENT_SESSION; dropColumn columnName=CLIENT_SESSION_ID, tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_P...		\N	4.23.2	\N	\N	5955459096
3.3.0	keycloak	META-INF/jpa-changelog-3.3.0.xml	2024-01-22 20:31:02.126557	44	EXECUTED	9:d48d6da5c6ccf667807f633fe489ce88	addColumn tableName=USER_ENTITY		\N	4.23.2	\N	\N	5955459096
authz-3.4.0.CR1-resource-server-pk-change-part1	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-01-22 20:31:02.135588	45	EXECUTED	9:dde36f7973e80d71fceee683bc5d2951	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_RESOURCE; addColumn tableName=RESOURCE_SERVER_SCOPE		\N	4.23.2	\N	\N	5955459096
authz-3.4.0.CR1-resource-server-pk-change-part2-KEYCLOAK-6095	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-01-22 20:31:02.142832	46	EXECUTED	9:b855e9b0a406b34fa323235a0cf4f640	customChange		\N	4.23.2	\N	\N	5955459096
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-01-22 20:31:02.146295	47	MARK_RAN	9:51abbacd7b416c50c4421a8cabf7927e	dropIndex indexName=IDX_RES_SERV_POL_RES_SERV, tableName=RESOURCE_SERVER_POLICY; dropIndex indexName=IDX_RES_SRV_RES_RES_SRV, tableName=RESOURCE_SERVER_RESOURCE; dropIndex indexName=IDX_RES_SRV_SCOPE_RES_SRV, tableName=RESOURCE_SERVER_SCOPE		\N	4.23.2	\N	\N	5955459096
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed-nodropindex	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-01-22 20:31:02.233079	48	EXECUTED	9:bdc99e567b3398bac83263d375aad143	addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_POLICY; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_RESOURCE; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, ...		\N	4.23.2	\N	\N	5955459096
authn-3.4.0.CR1-refresh-token-max-reuse	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2024-01-22 20:31:02.250994	49	EXECUTED	9:d198654156881c46bfba39abd7769e69	addColumn tableName=REALM		\N	4.23.2	\N	\N	5955459096
3.4.0	keycloak	META-INF/jpa-changelog-3.4.0.xml	2024-01-22 20:31:02.374977	50	EXECUTED	9:cfdd8736332ccdd72c5256ccb42335db	addPrimaryKey constraintName=CONSTRAINT_REALM_DEFAULT_ROLES, tableName=REALM_DEFAULT_ROLES; addPrimaryKey constraintName=CONSTRAINT_COMPOSITE_ROLE, tableName=COMPOSITE_ROLE; addPrimaryKey constraintName=CONSTR_REALM_DEFAULT_GROUPS, tableName=REALM...		\N	4.23.2	\N	\N	5955459096
3.4.0-KEYCLOAK-5230	hmlnarik@redhat.com	META-INF/jpa-changelog-3.4.0.xml	2024-01-22 20:31:02.461103	51	EXECUTED	9:7c84de3d9bd84d7f077607c1a4dcb714	createIndex indexName=IDX_FU_ATTRIBUTE, tableName=FED_USER_ATTRIBUTE; createIndex indexName=IDX_FU_CONSENT, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CONSENT_RU, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CREDENTIAL, t...		\N	4.23.2	\N	\N	5955459096
3.4.1	psilva@redhat.com	META-INF/jpa-changelog-3.4.1.xml	2024-01-22 20:31:02.473858	52	EXECUTED	9:5a6bb36cbefb6a9d6928452c0852af2d	modifyDataType columnName=VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	5955459096
3.4.2	keycloak	META-INF/jpa-changelog-3.4.2.xml	2024-01-22 20:31:02.485137	53	EXECUTED	9:8f23e334dbc59f82e0a328373ca6ced0	update tableName=REALM		\N	4.23.2	\N	\N	5955459096
3.4.2-KEYCLOAK-5172	mkanis@redhat.com	META-INF/jpa-changelog-3.4.2.xml	2024-01-22 20:31:02.495361	54	EXECUTED	9:9156214268f09d970cdf0e1564d866af	update tableName=CLIENT		\N	4.23.2	\N	\N	5955459096
4.0.0-KEYCLOAK-6335	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-01-22 20:31:02.518957	55	EXECUTED	9:db806613b1ed154826c02610b7dbdf74	createTable tableName=CLIENT_AUTH_FLOW_BINDINGS; addPrimaryKey constraintName=C_CLI_FLOW_BIND, tableName=CLIENT_AUTH_FLOW_BINDINGS		\N	4.23.2	\N	\N	5955459096
4.0.0-CLEANUP-UNUSED-TABLE	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-01-22 20:31:02.549818	56	EXECUTED	9:229a041fb72d5beac76bb94a5fa709de	dropTable tableName=CLIENT_IDENTITY_PROV_MAPPING		\N	4.23.2	\N	\N	5955459096
4.0.0-KEYCLOAK-6228	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-01-22 20:31:02.616975	57	EXECUTED	9:079899dade9c1e683f26b2aa9ca6ff04	dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; dropNotNullConstraint columnName=CLIENT_ID, tableName=USER_CONSENT; addColumn tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHO...		\N	4.23.2	\N	\N	5955459096
4.0.0-KEYCLOAK-5579-fixed	mposolda@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2024-01-22 20:31:02.833704	58	EXECUTED	9:139b79bcbbfe903bb1c2d2a4dbf001d9	dropForeignKeyConstraint baseTableName=CLIENT_TEMPLATE_ATTRIBUTES, constraintName=FK_CL_TEMPL_ATTR_TEMPL; renameTable newTableName=CLIENT_SCOPE_ATTRIBUTES, oldTableName=CLIENT_TEMPLATE_ATTRIBUTES; renameColumn newColumnName=SCOPE_ID, oldColumnName...		\N	4.23.2	\N	\N	5955459096
authz-4.0.0.CR1	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.CR1.xml	2024-01-22 20:31:02.908414	59	EXECUTED	9:b55738ad889860c625ba2bf483495a04	createTable tableName=RESOURCE_SERVER_PERM_TICKET; addPrimaryKey constraintName=CONSTRAINT_FAPMT, tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRHO213XCX4WNKOG82SSPMT...		\N	4.23.2	\N	\N	5955459096
authz-4.0.0.Beta3	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.Beta3.xml	2024-01-22 20:31:02.922209	60	EXECUTED	9:e0057eac39aa8fc8e09ac6cfa4ae15fe	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRPO2128CX4WNKOG82SSRFY, referencedTableName=RESOURCE_SERVER_POLICY		\N	4.23.2	\N	\N	5955459096
authz-4.2.0.Final	mhajas@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2024-01-22 20:31:02.939585	61	EXECUTED	9:42a33806f3a0443fe0e7feeec821326c	createTable tableName=RESOURCE_URIS; addForeignKeyConstraint baseTableName=RESOURCE_URIS, constraintName=FK_RESOURCE_SERVER_URIS, referencedTableName=RESOURCE_SERVER_RESOURCE; customChange; dropColumn columnName=URI, tableName=RESOURCE_SERVER_RESO...		\N	4.23.2	\N	\N	5955459096
authz-4.2.0.Final-KEYCLOAK-9944	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2024-01-22 20:31:02.952577	62	EXECUTED	9:9968206fca46eecc1f51db9c024bfe56	addPrimaryKey constraintName=CONSTRAINT_RESOUR_URIS_PK, tableName=RESOURCE_URIS		\N	4.23.2	\N	\N	5955459096
4.2.0-KEYCLOAK-6313	wadahiro@gmail.com	META-INF/jpa-changelog-4.2.0.xml	2024-01-22 20:31:02.959896	63	EXECUTED	9:92143a6daea0a3f3b8f598c97ce55c3d	addColumn tableName=REQUIRED_ACTION_PROVIDER		\N	4.23.2	\N	\N	5955459096
4.3.0-KEYCLOAK-7984	wadahiro@gmail.com	META-INF/jpa-changelog-4.3.0.xml	2024-01-22 20:31:02.967348	64	EXECUTED	9:82bab26a27195d889fb0429003b18f40	update tableName=REQUIRED_ACTION_PROVIDER		\N	4.23.2	\N	\N	5955459096
4.6.0-KEYCLOAK-7950	psilva@redhat.com	META-INF/jpa-changelog-4.6.0.xml	2024-01-22 20:31:02.973503	65	EXECUTED	9:e590c88ddc0b38b0ae4249bbfcb5abc3	update tableName=RESOURCE_SERVER_RESOURCE		\N	4.23.2	\N	\N	5955459096
4.6.0-KEYCLOAK-8377	keycloak	META-INF/jpa-changelog-4.6.0.xml	2024-01-22 20:31:03.002053	66	EXECUTED	9:5c1f475536118dbdc38d5d7977950cc0	createTable tableName=ROLE_ATTRIBUTE; addPrimaryKey constraintName=CONSTRAINT_ROLE_ATTRIBUTE_PK, tableName=ROLE_ATTRIBUTE; addForeignKeyConstraint baseTableName=ROLE_ATTRIBUTE, constraintName=FK_ROLE_ATTRIBUTE_ID, referencedTableName=KEYCLOAK_ROLE...		\N	4.23.2	\N	\N	5955459096
4.6.0-KEYCLOAK-8555	gideonray@gmail.com	META-INF/jpa-changelog-4.6.0.xml	2024-01-22 20:31:03.013853	67	EXECUTED	9:e7c9f5f9c4d67ccbbcc215440c718a17	createIndex indexName=IDX_COMPONENT_PROVIDER_TYPE, tableName=COMPONENT		\N	4.23.2	\N	\N	5955459096
4.7.0-KEYCLOAK-1267	sguilhen@redhat.com	META-INF/jpa-changelog-4.7.0.xml	2024-01-22 20:31:03.024709	68	EXECUTED	9:88e0bfdda924690d6f4e430c53447dd5	addColumn tableName=REALM		\N	4.23.2	\N	\N	5955459096
4.7.0-KEYCLOAK-7275	keycloak	META-INF/jpa-changelog-4.7.0.xml	2024-01-22 20:31:03.064917	69	EXECUTED	9:f53177f137e1c46b6a88c59ec1cb5218	renameColumn newColumnName=CREATED_ON, oldColumnName=LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION; addNotNullConstraint columnName=CREATED_ON, tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_USER_SESSION; customChange; createIn...		\N	4.23.2	\N	\N	5955459096
4.8.0-KEYCLOAK-8835	sguilhen@redhat.com	META-INF/jpa-changelog-4.8.0.xml	2024-01-22 20:31:03.083866	70	EXECUTED	9:a74d33da4dc42a37ec27121580d1459f	addNotNullConstraint columnName=SSO_MAX_LIFESPAN_REMEMBER_ME, tableName=REALM; addNotNullConstraint columnName=SSO_IDLE_TIMEOUT_REMEMBER_ME, tableName=REALM		\N	4.23.2	\N	\N	5955459096
authz-7.0.0-KEYCLOAK-10443	psilva@redhat.com	META-INF/jpa-changelog-authz-7.0.0.xml	2024-01-22 20:31:03.099071	71	EXECUTED	9:fd4ade7b90c3b67fae0bfcfcb42dfb5f	addColumn tableName=RESOURCE_SERVER		\N	4.23.2	\N	\N	5955459096
8.0.0-adding-credential-columns	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-01-22 20:31:03.125789	72	EXECUTED	9:aa072ad090bbba210d8f18781b8cebf4	addColumn tableName=CREDENTIAL; addColumn tableName=FED_USER_CREDENTIAL		\N	4.23.2	\N	\N	5955459096
8.0.0-updating-credential-data-not-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-01-22 20:31:03.152454	73	EXECUTED	9:1ae6be29bab7c2aa376f6983b932be37	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.23.2	\N	\N	5955459096
8.0.0-updating-credential-data-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-01-22 20:31:03.163377	74	MARK_RAN	9:14706f286953fc9a25286dbd8fb30d97	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.23.2	\N	\N	5955459096
8.0.0-credential-cleanup-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-01-22 20:31:03.222142	75	EXECUTED	9:2b9cc12779be32c5b40e2e67711a218b	dropDefaultValue columnName=COUNTER, tableName=CREDENTIAL; dropDefaultValue columnName=DIGITS, tableName=CREDENTIAL; dropDefaultValue columnName=PERIOD, tableName=CREDENTIAL; dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; dropColumn ...		\N	4.23.2	\N	\N	5955459096
8.0.0-resource-tag-support	keycloak	META-INF/jpa-changelog-8.0.0.xml	2024-01-22 20:31:03.23481	76	EXECUTED	9:91fa186ce7a5af127a2d7a91ee083cc5	addColumn tableName=MIGRATION_MODEL; createIndex indexName=IDX_UPDATE_TIME, tableName=MIGRATION_MODEL		\N	4.23.2	\N	\N	5955459096
9.0.0-always-display-client	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-01-22 20:31:03.242515	77	EXECUTED	9:6335e5c94e83a2639ccd68dd24e2e5ad	addColumn tableName=CLIENT		\N	4.23.2	\N	\N	5955459096
9.0.0-drop-constraints-for-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-01-22 20:31:03.245633	78	MARK_RAN	9:6bdb5658951e028bfe16fa0a8228b530	dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5PMT, tableName=RESOURCE_SERVER_PERM_TICKET; dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER_RESOURCE; dropPrimaryKey constraintName=CONSTRAINT_O...		\N	4.23.2	\N	\N	5955459096
9.0.0-increase-column-size-federated-fk	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-01-22 20:31:03.277131	79	EXECUTED	9:d5bc15a64117ccad481ce8792d4c608f	modifyDataType columnName=CLIENT_ID, tableName=FED_USER_CONSENT; modifyDataType columnName=CLIENT_REALM_CONSTRAINT, tableName=KEYCLOAK_ROLE; modifyDataType columnName=OWNER, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=CLIENT_ID, ta...		\N	4.23.2	\N	\N	5955459096
9.0.0-recreate-constraints-after-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2024-01-22 20:31:03.282504	80	MARK_RAN	9:077cba51999515f4d3e7ad5619ab592c	addNotNullConstraint columnName=CLIENT_ID, tableName=OFFLINE_CLIENT_SESSION; addNotNullConstraint columnName=OWNER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNullConstraint columnName=REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNull...		\N	4.23.2	\N	\N	5955459096
9.0.1-add-index-to-client.client_id	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-01-22 20:31:03.294593	81	EXECUTED	9:be969f08a163bf47c6b9e9ead8ac2afb	createIndex indexName=IDX_CLIENT_ID, tableName=CLIENT		\N	4.23.2	\N	\N	5955459096
9.0.1-KEYCLOAK-12579-drop-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-01-22 20:31:03.297725	82	MARK_RAN	9:6d3bb4408ba5a72f39bd8a0b301ec6e3	dropUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	5955459096
9.0.1-KEYCLOAK-12579-add-not-null-constraint	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-01-22 20:31:03.305343	83	EXECUTED	9:966bda61e46bebf3cc39518fbed52fa7	addNotNullConstraint columnName=PARENT_GROUP, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	5955459096
9.0.1-KEYCLOAK-12579-recreate-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-01-22 20:31:03.3089	84	MARK_RAN	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.23.2	\N	\N	5955459096
9.0.1-add-index-to-events	keycloak	META-INF/jpa-changelog-9.0.1.xml	2024-01-22 20:31:03.320224	85	EXECUTED	9:7d93d602352a30c0c317e6a609b56599	createIndex indexName=IDX_EVENT_TIME, tableName=EVENT_ENTITY		\N	4.23.2	\N	\N	5955459096
map-remove-ri	keycloak	META-INF/jpa-changelog-11.0.0.xml	2024-01-22 20:31:03.333089	86	EXECUTED	9:71c5969e6cdd8d7b6f47cebc86d37627	dropForeignKeyConstraint baseTableName=REALM, constraintName=FK_TRAF444KK6QRKMS7N56AIWQ5Y; dropForeignKeyConstraint baseTableName=KEYCLOAK_ROLE, constraintName=FK_KJHO5LE2C0RAL09FL8CM9WFW9		\N	4.23.2	\N	\N	5955459096
map-remove-ri	keycloak	META-INF/jpa-changelog-12.0.0.xml	2024-01-22 20:31:03.355316	87	EXECUTED	9:a9ba7d47f065f041b7da856a81762021	dropForeignKeyConstraint baseTableName=REALM_DEFAULT_GROUPS, constraintName=FK_DEF_GROUPS_GROUP; dropForeignKeyConstraint baseTableName=REALM_DEFAULT_ROLES, constraintName=FK_H4WPD7W4HSOOLNI3H0SW7BTJE; dropForeignKeyConstraint baseTableName=CLIENT...		\N	4.23.2	\N	\N	5955459096
12.1.0-add-realm-localization-table	keycloak	META-INF/jpa-changelog-12.0.0.xml	2024-01-22 20:31:03.374398	88	EXECUTED	9:fffabce2bc01e1a8f5110d5278500065	createTable tableName=REALM_LOCALIZATIONS; addPrimaryKey tableName=REALM_LOCALIZATIONS		\N	4.23.2	\N	\N	5955459096
default-roles	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.385101	89	EXECUTED	9:fa8a5b5445e3857f4b010bafb5009957	addColumn tableName=REALM; customChange		\N	4.23.2	\N	\N	5955459096
default-roles-cleanup	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.423334	90	EXECUTED	9:67ac3241df9a8582d591c5ed87125f39	dropTable tableName=REALM_DEFAULT_ROLES; dropTable tableName=CLIENT_DEFAULT_ROLES		\N	4.23.2	\N	\N	5955459096
13.0.0-KEYCLOAK-16844	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.436038	91	EXECUTED	9:ad1194d66c937e3ffc82386c050ba089	createIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	5955459096
map-remove-ri-13.0.0	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.476146	92	EXECUTED	9:d9be619d94af5a2f5d07b9f003543b91	dropForeignKeyConstraint baseTableName=DEFAULT_CLIENT_SCOPE, constraintName=FK_R_DEF_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SCOPE_CLIENT, constraintName=FK_C_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SC...		\N	4.23.2	\N	\N	5955459096
13.0.0-KEYCLOAK-17992-drop-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.481869	93	MARK_RAN	9:544d201116a0fcc5a5da0925fbbc3bde	dropPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CLSCOPE_CL, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CL_CLSCOPE, tableName=CLIENT_SCOPE_CLIENT		\N	4.23.2	\N	\N	5955459096
13.0.0-increase-column-size-federated	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.509767	94	EXECUTED	9:43c0c1055b6761b4b3e89de76d612ccf	modifyDataType columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; modifyDataType columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT		\N	4.23.2	\N	\N	5955459096
13.0.0-KEYCLOAK-17992-recreate-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.519591	95	MARK_RAN	9:8bd711fd0330f4fe980494ca43ab1139	addNotNullConstraint columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; addNotNullConstraint columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT; addPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; createIndex indexName=...		\N	4.23.2	\N	\N	5955459096
json-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-13.0.0.xml	2024-01-22 20:31:03.546138	96	EXECUTED	9:e07d2bc0970c348bb06fb63b1f82ddbf	addColumn tableName=REALM_ATTRIBUTE; update tableName=REALM_ATTRIBUTE; dropColumn columnName=VALUE, tableName=REALM_ATTRIBUTE; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=REALM_ATTRIBUTE		\N	4.23.2	\N	\N	5955459096
14.0.0-KEYCLOAK-11019	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.575706	97	EXECUTED	9:24fb8611e97f29989bea412aa38d12b7	createIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USER, tableName=OFFLINE_USER_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION		\N	4.23.2	\N	\N	5955459096
14.0.0-KEYCLOAK-18286	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.579195	98	MARK_RAN	9:259f89014ce2506ee84740cbf7163aa7	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	5955459096
14.0.0-KEYCLOAK-18286-revert	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.591172	99	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	5955459096
14.0.0-KEYCLOAK-18286-supported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.602367	100	EXECUTED	9:60ca84a0f8c94ec8c3504a5a3bc88ee8	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	5955459096
14.0.0-KEYCLOAK-18286-unsupported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.606022	101	MARK_RAN	9:d3d977031d431db16e2c181ce49d73e9	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	5955459096
KEYCLOAK-17267-add-index-to-user-attributes	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.618189	102	EXECUTED	9:0b305d8d1277f3a89a0a53a659ad274c	createIndex indexName=IDX_USER_ATTRIBUTE_NAME, tableName=USER_ATTRIBUTE		\N	4.23.2	\N	\N	5955459096
KEYCLOAK-18146-add-saml-art-binding-identifier	keycloak	META-INF/jpa-changelog-14.0.0.xml	2024-01-22 20:31:03.630783	103	EXECUTED	9:2c374ad2cdfe20e2905a84c8fac48460	customChange		\N	4.23.2	\N	\N	5955459096
15.0.0-KEYCLOAK-18467	keycloak	META-INF/jpa-changelog-15.0.0.xml	2024-01-22 20:31:03.650519	104	EXECUTED	9:47a760639ac597360a8219f5b768b4de	addColumn tableName=REALM_LOCALIZATIONS; update tableName=REALM_LOCALIZATIONS; dropColumn columnName=TEXTS, tableName=REALM_LOCALIZATIONS; renameColumn newColumnName=TEXTS, oldColumnName=TEXTS_NEW, tableName=REALM_LOCALIZATIONS; addNotNullConstrai...		\N	4.23.2	\N	\N	5955459096
17.0.0-9562	keycloak	META-INF/jpa-changelog-17.0.0.xml	2024-01-22 20:31:03.667984	105	EXECUTED	9:a6272f0576727dd8cad2522335f5d99e	createIndex indexName=IDX_USER_SERVICE_ACCOUNT, tableName=USER_ENTITY		\N	4.23.2	\N	\N	5955459096
18.0.0-10625-IDX_ADMIN_EVENT_TIME	keycloak	META-INF/jpa-changelog-18.0.0.xml	2024-01-22 20:31:03.68323	106	EXECUTED	9:015479dbd691d9cc8669282f4828c41d	createIndex indexName=IDX_ADMIN_EVENT_TIME, tableName=ADMIN_EVENT_ENTITY		\N	4.23.2	\N	\N	5955459096
19.0.0-10135	keycloak	META-INF/jpa-changelog-19.0.0.xml	2024-01-22 20:31:03.696943	107	EXECUTED	9:9518e495fdd22f78ad6425cc30630221	customChange		\N	4.23.2	\N	\N	5955459096
20.0.0-12964-supported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2024-01-22 20:31:03.712247	108	EXECUTED	9:e5f243877199fd96bcc842f27a1656ac	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.23.2	\N	\N	5955459096
20.0.0-12964-unsupported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2024-01-22 20:31:03.717924	109	MARK_RAN	9:1a6fcaa85e20bdeae0a9ce49b41946a5	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.23.2	\N	\N	5955459096
client-attributes-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-20.0.0.xml	2024-01-22 20:31:03.739236	110	EXECUTED	9:3f332e13e90739ed0c35b0b25b7822ca	addColumn tableName=CLIENT_ATTRIBUTES; update tableName=CLIENT_ATTRIBUTES; dropColumn columnName=VALUE, tableName=CLIENT_ATTRIBUTES; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=CLIENT_ATTRIBUTES		\N	4.23.2	\N	\N	5955459096
21.0.2-17277	keycloak	META-INF/jpa-changelog-21.0.2.xml	2024-01-22 20:31:03.751267	111	EXECUTED	9:7ee1f7a3fb8f5588f171fb9a6ab623c0	customChange		\N	4.23.2	\N	\N	5955459096
21.1.0-19404	keycloak	META-INF/jpa-changelog-21.1.0.xml	2024-01-22 20:31:03.829448	112	EXECUTED	9:3d7e830b52f33676b9d64f7f2b2ea634	modifyDataType columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=LOGIC, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=POLICY_ENFORCE_MODE, tableName=RESOURCE_SERVER		\N	4.23.2	\N	\N	5955459096
21.1.0-19404-2	keycloak	META-INF/jpa-changelog-21.1.0.xml	2024-01-22 20:31:03.838219	113	MARK_RAN	9:627d032e3ef2c06c0e1f73d2ae25c26c	addColumn tableName=RESOURCE_SERVER_POLICY; update tableName=RESOURCE_SERVER_POLICY; dropColumn columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; renameColumn newColumnName=DECISION_STRATEGY, oldColumnName=DECISION_STRATEGY_NEW, tabl...		\N	4.23.2	\N	\N	5955459096
22.0.0-17484-updated	keycloak	META-INF/jpa-changelog-22.0.0.xml	2024-01-22 20:31:03.852145	114	EXECUTED	9:90af0bfd30cafc17b9f4d6eccd92b8b3	customChange		\N	4.23.2	\N	\N	5955459096
22.0.5-24031	keycloak	META-INF/jpa-changelog-22.0.0.xml	2024-01-22 20:31:03.856131	115	MARK_RAN	9:a60d2d7b315ec2d3eba9e2f145f9df28	customChange		\N	4.23.2	\N	\N	5955459096
23.0.0-12062	keycloak	META-INF/jpa-changelog-23.0.0.xml	2024-01-22 20:31:03.869229	116	EXECUTED	9:2168fbe728fec46ae9baf15bf80927b8	addColumn tableName=COMPONENT_CONFIG; update tableName=COMPONENT_CONFIG; dropColumn columnName=VALUE, tableName=COMPONENT_CONFIG; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=COMPONENT_CONFIG		\N	4.23.2	\N	\N	5955459096
23.0.0-17258	keycloak	META-INF/jpa-changelog-23.0.0.xml	2024-01-22 20:31:03.876134	117	EXECUTED	9:36506d679a83bbfda85a27ea1864dca8	addColumn tableName=EVENT_ENTITY		\N	4.23.2	\N	\N	5955459096
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
15357e80-1b48-4482-93a9-2311f5c506f8	8dd342c0-eade-48a0-9ca2-18df93898a26	f
15357e80-1b48-4482-93a9-2311f5c506f8	be034ad8-b58c-4d9f-8e05-e886f4af3335	t
15357e80-1b48-4482-93a9-2311f5c506f8	1b34d161-ab56-479f-9a02-7e2d2d79a812	t
15357e80-1b48-4482-93a9-2311f5c506f8	d7ff3aa5-e508-4fc4-9d06-05effb107ec0	t
15357e80-1b48-4482-93a9-2311f5c506f8	9cb83105-0b9e-4143-beb9-68c719f48101	f
15357e80-1b48-4482-93a9-2311f5c506f8	fc17d436-d1af-49b8-9911-1b45fb5efa2b	f
15357e80-1b48-4482-93a9-2311f5c506f8	4dd418d7-c9d1-46c4-8434-52a0fcc6983e	t
15357e80-1b48-4482-93a9-2311f5c506f8	792e70bd-133f-4cff-98ca-2c473215f85d	t
15357e80-1b48-4482-93a9-2311f5c506f8	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4	f
15357e80-1b48-4482-93a9-2311f5c506f8	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1	t
d4451a80-7ae2-4c36-999e-8e6184a6ec05	235681d5-862a-4654-8177-8d51967e4b86	f
d4451a80-7ae2-4c36-999e-8e6184a6ec05	afa87c90-033f-4c84-b2cc-b5aecf1f3667	t
d4451a80-7ae2-4c36-999e-8e6184a6ec05	0fc988b4-555b-4552-ba5d-dcad9949464d	t
d4451a80-7ae2-4c36-999e-8e6184a6ec05	aa7575c3-c000-48fc-b49f-d1a636e9aad3	t
d4451a80-7ae2-4c36-999e-8e6184a6ec05	8862492b-3819-43fc-b18d-a7e0d4f98df2	f
d4451a80-7ae2-4c36-999e-8e6184a6ec05	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc	f
d4451a80-7ae2-4c36-999e-8e6184a6ec05	0c05d94c-3a14-41a8-aae5-1f9444261cb8	t
d4451a80-7ae2-4c36-999e-8e6184a6ec05	71cba98e-b6bf-473e-b8a5-f1b6dcf47643	t
d4451a80-7ae2-4c36-999e-8e6184a6ec05	ab6dcd38-fda1-4657-8d67-49922f9ba5f9	f
d4451a80-7ae2-4c36-999e-8e6184a6ec05	98f06ba5-8194-4b69-8d5f-c2aef35f707a	t
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
a06d40f9-1f4c-4ec6-affc-4e64e2803ea9	15357e80-1b48-4482-93a9-2311f5c506f8	f	${role_default-roles}	default-roles-master	15357e80-1b48-4482-93a9-2311f5c506f8	\N	\N
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	15357e80-1b48-4482-93a9-2311f5c506f8	f	${role_admin}	admin	15357e80-1b48-4482-93a9-2311f5c506f8	\N	\N
d703598d-25f4-4c74-bee6-cd09d60c363b	15357e80-1b48-4482-93a9-2311f5c506f8	f	${role_create-realm}	create-realm	15357e80-1b48-4482-93a9-2311f5c506f8	\N	\N
5492ef4e-43e0-41fd-8203-bb96022ee96e	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_create-client}	create-client	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
4910c258-54ed-429b-8f8a-5e68dd077d71	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_view-realm}	view-realm	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
c77a6e8e-e784-4be3-91da-53877f570dd5	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_view-users}	view-users	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
04c3016b-3943-4583-901e-d900b6c8a006	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_view-clients}	view-clients	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
c74250bd-a82e-47b6-bf49-1e4152779848	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_view-events}	view-events	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
c6d5fe21-ab9f-40eb-9124-94f2982ef694	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_view-identity-providers}	view-identity-providers	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
95deb6d2-1000-448e-bf28-80bc991df8c1	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_view-authorization}	view-authorization	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
8e137a80-73f1-4cc9-9ffe-30b1b993b76b	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_manage-realm}	manage-realm	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
dbce6153-99d6-419c-8ad1-3d422d9b20f3	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_manage-users}	manage-users	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
907bde45-0fd4-4aa6-95d4-eb0f032747de	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_manage-clients}	manage-clients	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
053ea80d-129d-4dbc-81b0-a0b9b94cc04e	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_manage-events}	manage-events	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
63a10ea9-8485-4dae-9910-a4513e4f45b8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_manage-identity-providers}	manage-identity-providers	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
c8dfc6d1-64b4-4460-8326-e107a205b7ea	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_manage-authorization}	manage-authorization	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
d35de0ac-03de-4fb2-92fd-f966b6d7648c	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_query-users}	query-users	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
9093c50f-cd23-4241-afae-3c14bf6c93cc	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_query-clients}	query-clients	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
b2d04492-5049-4426-a37c-fc863ab5a957	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_query-realms}	query-realms	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
55fb5940-cd8b-4fb6-bb29-9cca8c84df19	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_query-groups}	query-groups	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
fb64aa40-b26c-4a63-82f4-ff926bb81071	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_view-profile}	view-profile	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
9ff4acc5-0f84-4b89-9e1b-b7116c86c843	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_manage-account}	manage-account	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
9c4fa0b6-1e6a-4273-9b3e-6cfb03294299	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_manage-account-links}	manage-account-links	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
7910f9b5-3b33-47aa-a687-e7c894f308c4	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_view-applications}	view-applications	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
8ff7690d-1058-49d0-9c12-004de4f5f01b	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_view-consent}	view-consent	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
9ba92f5b-24da-4319-861d-b57ad8f3b144	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_manage-consent}	manage-consent	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
911cba8e-de45-4af2-a733-a277a67d3159	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_view-groups}	view-groups	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
cd420efb-b350-4bfa-bf10-bea837d1c80d	175549f9-bbf4-4afd-bde3-d1371c27ed9d	t	${role_delete-account}	delete-account	15357e80-1b48-4482-93a9-2311f5c506f8	175549f9-bbf4-4afd-bde3-d1371c27ed9d	\N
bcbb97ec-e259-4f51-8cda-ceee1148f196	50385586-9131-4a77-a928-d2fdfefc3173	t	${role_read-token}	read-token	15357e80-1b48-4482-93a9-2311f5c506f8	50385586-9131-4a77-a928-d2fdfefc3173	\N
079b9e97-f375-4c68-9906-aec8cead59f0	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	t	${role_impersonation}	impersonation	15357e80-1b48-4482-93a9-2311f5c506f8	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	\N
57c0c2e4-d68e-487f-8856-3acb43a2216b	15357e80-1b48-4482-93a9-2311f5c506f8	f	${role_offline-access}	offline_access	15357e80-1b48-4482-93a9-2311f5c506f8	\N	\N
5e2ed825-2c99-4f6e-b133-a3633d7f1806	15357e80-1b48-4482-93a9-2311f5c506f8	f	${role_uma_authorization}	uma_authorization	15357e80-1b48-4482-93a9-2311f5c506f8	\N	\N
166370f4-a467-404c-b411-06e4d5af8895	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f	${role_default-roles}	default-roles-maskanyone	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N	\N
54ba87cf-a7bd-49be-8083-a2bf6b023c68	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_create-client}	create-client	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
72a999b0-44e1-4cba-91ae-969d339f3083	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_view-realm}	view-realm	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
59074f6b-e7a6-49f6-8169-4ef6fd6b0ab6	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_view-users}	view-users	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
588b1669-bbfb-497b-b852-2a9ed79d90c1	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_view-clients}	view-clients	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
cf79e2a4-833e-459f-a9a3-2b695d36b9fe	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_view-events}	view-events	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
c2fa8fc2-48ff-4523-9162-e7485a4804e5	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_view-identity-providers}	view-identity-providers	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
213432b2-4ec7-40c4-887e-cf658c5c833f	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_view-authorization}	view-authorization	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
396febca-1a30-4a8a-b6f3-ec37512b411b	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_manage-realm}	manage-realm	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
5101e6bc-eb30-422a-a4cf-826b6b22d471	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_manage-users}	manage-users	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
8a647b27-11a3-41ab-ad89-989dac04d134	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_manage-clients}	manage-clients	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
7e5d707a-0beb-4e4f-b1a8-208e30d21b2c	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_manage-events}	manage-events	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
4e4e3f0a-812d-41e5-a7aa-7c4d1a588e0d	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_manage-identity-providers}	manage-identity-providers	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
8fe53906-ceeb-4819-b4d8-40f7d2e5dbb5	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_manage-authorization}	manage-authorization	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
14bbc843-46b6-40a0-beda-fd2246be2404	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_query-users}	query-users	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
947beb93-4b2f-47ae-b1ec-cd45e1baf44a	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_query-clients}	query-clients	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
4dfb1e0c-8119-46db-bf1c-afc7e9c67ef5	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_query-realms}	query-realms	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
da3e31cb-a541-400c-9195-122bc93fe061	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_query-groups}	query-groups	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
fe08970b-0770-4157-9ebc-e37c4868f4b5	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_realm-admin}	realm-admin	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
2cc9e686-a942-4e1e-b101-29c5313f9a16	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_create-client}	create-client	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
86085310-8759-4109-a2d3-62f4a8e65eb2	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_view-realm}	view-realm	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
3e129908-cd48-42e9-940d-6ff7dc3215bf	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_view-users}	view-users	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
8d143ed9-65a1-439a-b7f5-d548e6f722ab	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_view-clients}	view-clients	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
be8619e2-3653-47da-9abf-5211f12cd992	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_view-events}	view-events	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
84d32185-ee4e-4f60-8462-6fd05d5bb5f4	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_view-identity-providers}	view-identity-providers	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
fec02ffb-11b2-4bd1-a973-de8490989910	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_view-authorization}	view-authorization	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
33a1b992-06e7-483b-917f-b8abf45d2d45	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_manage-realm}	manage-realm	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
70e22d50-8711-4a02-a479-91e5844f7f1c	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_manage-users}	manage-users	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
9ee3d272-9d55-4266-a271-8c3bb40cbc37	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_manage-clients}	manage-clients	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
f4ed715a-0d50-4252-aab9-a32aa71b4670	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_manage-events}	manage-events	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
06daf1be-dd52-4ac3-98c6-6a04e6c339c5	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_manage-identity-providers}	manage-identity-providers	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
9f8e1bb6-128c-43da-b9a7-e9083f1e9588	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_manage-authorization}	manage-authorization	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
63b3267f-cb4d-44b9-ac49-8e75e8592232	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_query-users}	query-users	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
99117ba4-388c-43e7-b5d5-64f300b7002d	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_query-clients}	query-clients	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
fa50f3ac-0c51-487b-9374-062694b68ee4	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_query-realms}	query-realms	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
bf95db4b-3416-4fd1-84cd-15d019621e88	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_query-groups}	query-groups	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
52711218-298b-4698-8c81-1b0a97cf95eb	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_view-profile}	view-profile	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
dbd0c2a7-ab8e-4917-a2cc-d93d66b73401	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_manage-account}	manage-account	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
73083079-1aff-47ee-b122-8bc0460f612f	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_manage-account-links}	manage-account-links	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
0bd03de8-6133-4ea0-9280-aa3592f5b7f9	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_view-applications}	view-applications	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
faf5a6f2-dff0-4c3a-8932-39da260256ab	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_view-consent}	view-consent	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
fec05d01-eae2-4bc0-8d3f-78772fbc8744	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_manage-consent}	manage-consent	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
67a08dca-1227-4fc0-858a-d022ab5a0163	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_view-groups}	view-groups	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
7cfcb5b1-c7d2-4e77-ba92-6ce0ababea29	5edb3285-0625-4a5e-a93a-27c7b489020b	t	${role_delete-account}	delete-account	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5edb3285-0625-4a5e-a93a-27c7b489020b	\N
acae0528-9f38-41c0-bc3a-fa62f434cfd8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	t	${role_impersonation}	impersonation	15357e80-1b48-4482-93a9-2311f5c506f8	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	\N
a0bc5c17-df74-4b16-bbb4-c4673d7ee9f2	7f4d1776-be78-4103-bbea-fde19008a431	t	${role_impersonation}	impersonation	d4451a80-7ae2-4c36-999e-8e6184a6ec05	7f4d1776-be78-4103-bbea-fde19008a431	\N
73288e26-feee-4604-9b9c-0d6e74fc7835	e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	t	${role_read-token}	read-token	d4451a80-7ae2-4c36-999e-8e6184a6ec05	e2d2e868-ded7-48dd-bc3a-2aceb34c1da6	\N
90818fa4-9863-4101-bc97-c1007c78cf0c	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f	${role_offline-access}	offline_access	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N	\N
2aaf3931-2b6c-4057-ba51-dcc58c6665bf	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f	${role_uma_authorization}	uma_authorization	d4451a80-7ae2-4c36-999e-8e6184a6ec05	\N	\N
\.


--
-- Data for Name: migration_model; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.migration_model (id, version, update_time) FROM stdin;
psjgx	23.0.4	1705955464
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
e1b4caff-f15f-4897-af38-65f50055d413	audience resolve	openid-connect	oidc-audience-resolve-mapper	1027adf9-f5a4-4317-9aef-b634d978fb5f	\N
aaca18f4-cfce-4427-bf52-c122b498d39f	locale	openid-connect	oidc-usermodel-attribute-mapper	6311a773-e535-4fde-ac60-61694989a4bc	\N
b24e8e21-46ce-4fad-bdb4-085220a38091	role list	saml	saml-role-list-mapper	\N	be034ad8-b58c-4d9f-8e05-e886f4af3335
1e0252f6-7bed-411f-bf3d-1583445513cf	full name	openid-connect	oidc-full-name-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
2433372c-ca2c-42ae-908c-aa2aed873d1a	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
64e6cf3e-7619-4856-8b55-123596731994	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
96846ff8-2ad1-49ca-9b4e-c521dba06565	username	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
7cb76195-6a5f-45eb-8aaa-708d7d154db2	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
491f2f52-39f6-4c0a-a67f-1b890a919fb8	website	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
0f3cbf0c-ad50-407c-a11a-19d96e199daf	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
9c7e7ff5-f624-4b7c-a12b-b0873023a947	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
7ebccc6a-fea7-42cd-a120-b425285d0144	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
651fa716-fd4e-479c-bdf2-fac14c30679e	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	1b34d161-ab56-479f-9a02-7e2d2d79a812
c181c600-bfaf-47f4-a19c-6777d7d446be	email	openid-connect	oidc-usermodel-attribute-mapper	\N	d7ff3aa5-e508-4fc4-9d06-05effb107ec0
83e98a45-0eb0-4660-afe9-a43deeb9eb99	email verified	openid-connect	oidc-usermodel-property-mapper	\N	d7ff3aa5-e508-4fc4-9d06-05effb107ec0
333109b4-69d9-43eb-a5c3-d1ada59de347	address	openid-connect	oidc-address-mapper	\N	9cb83105-0b9e-4143-beb9-68c719f48101
6144fdc1-0782-45b1-b883-0a373a31080d	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	fc17d436-d1af-49b8-9911-1b45fb5efa2b
e43a9bc1-ff34-415b-b419-633fd152edf0	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	fc17d436-d1af-49b8-9911-1b45fb5efa2b
49bcb4ad-1efe-455f-847b-7c420352ee4c	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	4dd418d7-c9d1-46c4-8434-52a0fcc6983e
0e1005db-e90b-4b30-a42d-8552e44abd4a	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	4dd418d7-c9d1-46c4-8434-52a0fcc6983e
712aa1cf-66dc-4c6a-9784-755a0d6f59fa	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	4dd418d7-c9d1-46c4-8434-52a0fcc6983e
e76c3240-b86b-4b11-a1e2-f2dfcd77bdea	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	792e70bd-133f-4cff-98ca-2c473215f85d
3aca48aa-6872-4338-8a66-6e9e945e89a2	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4
fa27cc39-5de5-41e2-867e-9d9053e21da8	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	382fcf5f-c990-4a4e-b0b8-2a9c68ecf6f4
e00f610d-5423-421d-b429-9e3a722f5420	acr loa level	openid-connect	oidc-acr-mapper	\N	2b9714f5-a2ec-4c10-9804-eb609a5c3dc1
269d09a5-466a-4973-88f5-966f456680e7	audience resolve	openid-connect	oidc-audience-resolve-mapper	6c46bf16-f287-447b-9e2c-9d017241dd84	\N
efec6347-5c63-4860-b36d-2355a3a89f9e	role list	saml	saml-role-list-mapper	\N	afa87c90-033f-4c84-b2cc-b5aecf1f3667
5e832b5e-8766-4c11-a380-2451c65efd3e	full name	openid-connect	oidc-full-name-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
76d2301b-eb71-4b0e-9d83-456294e67640	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
9718fe56-dfbe-44ad-8e95-2cdde454816e	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
308a33b4-bec8-4830-a043-ee87168f7c6c	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
24d3d333-fd8b-441b-9e61-6505849c2d7e	username	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	website	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
495aba16-aa17-4bdc-baec-1f5779ef88b5	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
fed8a610-2561-4b2b-b4a0-04a29141ee7d	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	0fc988b4-555b-4552-ba5d-dcad9949464d
199e58ce-d760-456e-87be-4dd9d5858691	email	openid-connect	oidc-usermodel-attribute-mapper	\N	aa7575c3-c000-48fc-b49f-d1a636e9aad3
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	email verified	openid-connect	oidc-usermodel-property-mapper	\N	aa7575c3-c000-48fc-b49f-d1a636e9aad3
b143f1ec-8794-4125-8df9-82f624c2bd14	address	openid-connect	oidc-address-mapper	\N	8862492b-3819-43fc-b18d-a7e0d4f98df2
467edd70-1ef0-482f-be35-f57cf0afc82d	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc
becb4c6b-f711-413d-8e77-6e0b873dc466	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	fe1dc0b9-b5cd-4192-965a-7c09c428e0dc
3cee67d0-80af-45fd-8892-52d9e86d7fc9	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	0c05d94c-3a14-41a8-aae5-1f9444261cb8
ae3b8eef-e31c-4db9-920b-67216dafc13d	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	0c05d94c-3a14-41a8-aae5-1f9444261cb8
6e97f25d-7747-4fa4-bdec-c0fc0050e56b	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	0c05d94c-3a14-41a8-aae5-1f9444261cb8
c18c44c1-a09a-49a4-903a-547488c0f0ac	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	71cba98e-b6bf-473e-b8a5-f1b6dcf47643
509241cc-da2f-4a84-b397-2f7eb692cd58	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	ab6dcd38-fda1-4657-8d67-49922f9ba5f9
28a90bec-dd46-4edd-9d86-18dc5d830c98	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	ab6dcd38-fda1-4657-8d67-49922f9ba5f9
bc887854-ce1b-4a2f-b215-7f84b6c09b18	acr loa level	openid-connect	oidc-acr-mapper	\N	98f06ba5-8194-4b69-8d5f-c2aef35f707a
2ecf849a-199c-4627-9447-e6e7b9527ff4	locale	openid-connect	oidc-usermodel-attribute-mapper	eff849b3-27b3-4b4e-986b-bb5986524cd1	\N
\.


--
-- Data for Name: protocol_mapper_config; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.protocol_mapper_config (protocol_mapper_id, value, name) FROM stdin;
aaca18f4-cfce-4427-bf52-c122b498d39f	true	introspection.token.claim
aaca18f4-cfce-4427-bf52-c122b498d39f	true	userinfo.token.claim
aaca18f4-cfce-4427-bf52-c122b498d39f	locale	user.attribute
aaca18f4-cfce-4427-bf52-c122b498d39f	true	id.token.claim
aaca18f4-cfce-4427-bf52-c122b498d39f	true	access.token.claim
aaca18f4-cfce-4427-bf52-c122b498d39f	locale	claim.name
aaca18f4-cfce-4427-bf52-c122b498d39f	String	jsonType.label
b24e8e21-46ce-4fad-bdb4-085220a38091	false	single
b24e8e21-46ce-4fad-bdb4-085220a38091	Basic	attribute.nameformat
b24e8e21-46ce-4fad-bdb4-085220a38091	Role	attribute.name
0f3cbf0c-ad50-407c-a11a-19d96e199daf	true	introspection.token.claim
0f3cbf0c-ad50-407c-a11a-19d96e199daf	true	userinfo.token.claim
0f3cbf0c-ad50-407c-a11a-19d96e199daf	gender	user.attribute
0f3cbf0c-ad50-407c-a11a-19d96e199daf	true	id.token.claim
0f3cbf0c-ad50-407c-a11a-19d96e199daf	true	access.token.claim
0f3cbf0c-ad50-407c-a11a-19d96e199daf	gender	claim.name
0f3cbf0c-ad50-407c-a11a-19d96e199daf	String	jsonType.label
1e0252f6-7bed-411f-bf3d-1583445513cf	true	introspection.token.claim
1e0252f6-7bed-411f-bf3d-1583445513cf	true	userinfo.token.claim
1e0252f6-7bed-411f-bf3d-1583445513cf	true	id.token.claim
1e0252f6-7bed-411f-bf3d-1583445513cf	true	access.token.claim
2433372c-ca2c-42ae-908c-aa2aed873d1a	true	introspection.token.claim
2433372c-ca2c-42ae-908c-aa2aed873d1a	true	userinfo.token.claim
2433372c-ca2c-42ae-908c-aa2aed873d1a	lastName	user.attribute
2433372c-ca2c-42ae-908c-aa2aed873d1a	true	id.token.claim
2433372c-ca2c-42ae-908c-aa2aed873d1a	true	access.token.claim
2433372c-ca2c-42ae-908c-aa2aed873d1a	family_name	claim.name
2433372c-ca2c-42ae-908c-aa2aed873d1a	String	jsonType.label
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	true	introspection.token.claim
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	true	userinfo.token.claim
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	firstName	user.attribute
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	true	id.token.claim
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	true	access.token.claim
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	given_name	claim.name
2c33b1b1-aea8-4c87-8f7f-f44b87a95c86	String	jsonType.label
491f2f52-39f6-4c0a-a67f-1b890a919fb8	true	introspection.token.claim
491f2f52-39f6-4c0a-a67f-1b890a919fb8	true	userinfo.token.claim
491f2f52-39f6-4c0a-a67f-1b890a919fb8	website	user.attribute
491f2f52-39f6-4c0a-a67f-1b890a919fb8	true	id.token.claim
491f2f52-39f6-4c0a-a67f-1b890a919fb8	true	access.token.claim
491f2f52-39f6-4c0a-a67f-1b890a919fb8	website	claim.name
491f2f52-39f6-4c0a-a67f-1b890a919fb8	String	jsonType.label
64e6cf3e-7619-4856-8b55-123596731994	true	introspection.token.claim
64e6cf3e-7619-4856-8b55-123596731994	true	userinfo.token.claim
64e6cf3e-7619-4856-8b55-123596731994	nickname	user.attribute
64e6cf3e-7619-4856-8b55-123596731994	true	id.token.claim
64e6cf3e-7619-4856-8b55-123596731994	true	access.token.claim
64e6cf3e-7619-4856-8b55-123596731994	nickname	claim.name
64e6cf3e-7619-4856-8b55-123596731994	String	jsonType.label
651fa716-fd4e-479c-bdf2-fac14c30679e	true	introspection.token.claim
651fa716-fd4e-479c-bdf2-fac14c30679e	true	userinfo.token.claim
651fa716-fd4e-479c-bdf2-fac14c30679e	locale	user.attribute
651fa716-fd4e-479c-bdf2-fac14c30679e	true	id.token.claim
651fa716-fd4e-479c-bdf2-fac14c30679e	true	access.token.claim
651fa716-fd4e-479c-bdf2-fac14c30679e	locale	claim.name
651fa716-fd4e-479c-bdf2-fac14c30679e	String	jsonType.label
7cb76195-6a5f-45eb-8aaa-708d7d154db2	true	introspection.token.claim
7cb76195-6a5f-45eb-8aaa-708d7d154db2	true	userinfo.token.claim
7cb76195-6a5f-45eb-8aaa-708d7d154db2	picture	user.attribute
7cb76195-6a5f-45eb-8aaa-708d7d154db2	true	id.token.claim
7cb76195-6a5f-45eb-8aaa-708d7d154db2	true	access.token.claim
7cb76195-6a5f-45eb-8aaa-708d7d154db2	picture	claim.name
7cb76195-6a5f-45eb-8aaa-708d7d154db2	String	jsonType.label
7ebccc6a-fea7-42cd-a120-b425285d0144	true	introspection.token.claim
7ebccc6a-fea7-42cd-a120-b425285d0144	true	userinfo.token.claim
7ebccc6a-fea7-42cd-a120-b425285d0144	zoneinfo	user.attribute
7ebccc6a-fea7-42cd-a120-b425285d0144	true	id.token.claim
7ebccc6a-fea7-42cd-a120-b425285d0144	true	access.token.claim
7ebccc6a-fea7-42cd-a120-b425285d0144	zoneinfo	claim.name
7ebccc6a-fea7-42cd-a120-b425285d0144	String	jsonType.label
96846ff8-2ad1-49ca-9b4e-c521dba06565	true	introspection.token.claim
96846ff8-2ad1-49ca-9b4e-c521dba06565	true	userinfo.token.claim
96846ff8-2ad1-49ca-9b4e-c521dba06565	username	user.attribute
96846ff8-2ad1-49ca-9b4e-c521dba06565	true	id.token.claim
96846ff8-2ad1-49ca-9b4e-c521dba06565	true	access.token.claim
96846ff8-2ad1-49ca-9b4e-c521dba06565	preferred_username	claim.name
96846ff8-2ad1-49ca-9b4e-c521dba06565	String	jsonType.label
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	true	introspection.token.claim
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	true	userinfo.token.claim
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	middleName	user.attribute
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	true	id.token.claim
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	true	access.token.claim
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	middle_name	claim.name
9bf79809-f135-4b7b-ba8c-13ff75f7e26a	String	jsonType.label
9c7e7ff5-f624-4b7c-a12b-b0873023a947	true	introspection.token.claim
9c7e7ff5-f624-4b7c-a12b-b0873023a947	true	userinfo.token.claim
9c7e7ff5-f624-4b7c-a12b-b0873023a947	birthdate	user.attribute
9c7e7ff5-f624-4b7c-a12b-b0873023a947	true	id.token.claim
9c7e7ff5-f624-4b7c-a12b-b0873023a947	true	access.token.claim
9c7e7ff5-f624-4b7c-a12b-b0873023a947	birthdate	claim.name
9c7e7ff5-f624-4b7c-a12b-b0873023a947	String	jsonType.label
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	true	introspection.token.claim
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	true	userinfo.token.claim
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	updatedAt	user.attribute
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	true	id.token.claim
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	true	access.token.claim
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	updated_at	claim.name
a1c3756f-8859-4a58-b4f5-12ddfe4dc78e	long	jsonType.label
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	true	introspection.token.claim
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	true	userinfo.token.claim
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	profile	user.attribute
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	true	id.token.claim
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	true	access.token.claim
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	profile	claim.name
ffd0f8dc-94de-40e1-bb7a-83e5d2f7bcab	String	jsonType.label
83e98a45-0eb0-4660-afe9-a43deeb9eb99	true	introspection.token.claim
83e98a45-0eb0-4660-afe9-a43deeb9eb99	true	userinfo.token.claim
83e98a45-0eb0-4660-afe9-a43deeb9eb99	emailVerified	user.attribute
83e98a45-0eb0-4660-afe9-a43deeb9eb99	true	id.token.claim
83e98a45-0eb0-4660-afe9-a43deeb9eb99	true	access.token.claim
83e98a45-0eb0-4660-afe9-a43deeb9eb99	email_verified	claim.name
83e98a45-0eb0-4660-afe9-a43deeb9eb99	boolean	jsonType.label
c181c600-bfaf-47f4-a19c-6777d7d446be	true	introspection.token.claim
c181c600-bfaf-47f4-a19c-6777d7d446be	true	userinfo.token.claim
c181c600-bfaf-47f4-a19c-6777d7d446be	email	user.attribute
c181c600-bfaf-47f4-a19c-6777d7d446be	true	id.token.claim
c181c600-bfaf-47f4-a19c-6777d7d446be	true	access.token.claim
c181c600-bfaf-47f4-a19c-6777d7d446be	email	claim.name
c181c600-bfaf-47f4-a19c-6777d7d446be	String	jsonType.label
333109b4-69d9-43eb-a5c3-d1ada59de347	formatted	user.attribute.formatted
333109b4-69d9-43eb-a5c3-d1ada59de347	country	user.attribute.country
333109b4-69d9-43eb-a5c3-d1ada59de347	true	introspection.token.claim
333109b4-69d9-43eb-a5c3-d1ada59de347	postal_code	user.attribute.postal_code
333109b4-69d9-43eb-a5c3-d1ada59de347	true	userinfo.token.claim
333109b4-69d9-43eb-a5c3-d1ada59de347	street	user.attribute.street
333109b4-69d9-43eb-a5c3-d1ada59de347	true	id.token.claim
333109b4-69d9-43eb-a5c3-d1ada59de347	region	user.attribute.region
333109b4-69d9-43eb-a5c3-d1ada59de347	true	access.token.claim
333109b4-69d9-43eb-a5c3-d1ada59de347	locality	user.attribute.locality
6144fdc1-0782-45b1-b883-0a373a31080d	true	introspection.token.claim
6144fdc1-0782-45b1-b883-0a373a31080d	true	userinfo.token.claim
6144fdc1-0782-45b1-b883-0a373a31080d	phoneNumber	user.attribute
6144fdc1-0782-45b1-b883-0a373a31080d	true	id.token.claim
6144fdc1-0782-45b1-b883-0a373a31080d	true	access.token.claim
6144fdc1-0782-45b1-b883-0a373a31080d	phone_number	claim.name
6144fdc1-0782-45b1-b883-0a373a31080d	String	jsonType.label
e43a9bc1-ff34-415b-b419-633fd152edf0	true	introspection.token.claim
e43a9bc1-ff34-415b-b419-633fd152edf0	true	userinfo.token.claim
e43a9bc1-ff34-415b-b419-633fd152edf0	phoneNumberVerified	user.attribute
e43a9bc1-ff34-415b-b419-633fd152edf0	true	id.token.claim
e43a9bc1-ff34-415b-b419-633fd152edf0	true	access.token.claim
e43a9bc1-ff34-415b-b419-633fd152edf0	phone_number_verified	claim.name
e43a9bc1-ff34-415b-b419-633fd152edf0	boolean	jsonType.label
0e1005db-e90b-4b30-a42d-8552e44abd4a	true	introspection.token.claim
0e1005db-e90b-4b30-a42d-8552e44abd4a	true	multivalued
0e1005db-e90b-4b30-a42d-8552e44abd4a	foo	user.attribute
0e1005db-e90b-4b30-a42d-8552e44abd4a	true	access.token.claim
0e1005db-e90b-4b30-a42d-8552e44abd4a	resource_access.${client_id}.roles	claim.name
0e1005db-e90b-4b30-a42d-8552e44abd4a	String	jsonType.label
49bcb4ad-1efe-455f-847b-7c420352ee4c	true	introspection.token.claim
49bcb4ad-1efe-455f-847b-7c420352ee4c	true	multivalued
49bcb4ad-1efe-455f-847b-7c420352ee4c	foo	user.attribute
49bcb4ad-1efe-455f-847b-7c420352ee4c	true	access.token.claim
49bcb4ad-1efe-455f-847b-7c420352ee4c	realm_access.roles	claim.name
49bcb4ad-1efe-455f-847b-7c420352ee4c	String	jsonType.label
712aa1cf-66dc-4c6a-9784-755a0d6f59fa	true	introspection.token.claim
712aa1cf-66dc-4c6a-9784-755a0d6f59fa	true	access.token.claim
e76c3240-b86b-4b11-a1e2-f2dfcd77bdea	true	introspection.token.claim
e76c3240-b86b-4b11-a1e2-f2dfcd77bdea	true	access.token.claim
3aca48aa-6872-4338-8a66-6e9e945e89a2	true	introspection.token.claim
3aca48aa-6872-4338-8a66-6e9e945e89a2	true	userinfo.token.claim
3aca48aa-6872-4338-8a66-6e9e945e89a2	username	user.attribute
3aca48aa-6872-4338-8a66-6e9e945e89a2	true	id.token.claim
3aca48aa-6872-4338-8a66-6e9e945e89a2	true	access.token.claim
3aca48aa-6872-4338-8a66-6e9e945e89a2	upn	claim.name
3aca48aa-6872-4338-8a66-6e9e945e89a2	String	jsonType.label
fa27cc39-5de5-41e2-867e-9d9053e21da8	true	introspection.token.claim
fa27cc39-5de5-41e2-867e-9d9053e21da8	true	multivalued
fa27cc39-5de5-41e2-867e-9d9053e21da8	foo	user.attribute
fa27cc39-5de5-41e2-867e-9d9053e21da8	true	id.token.claim
fa27cc39-5de5-41e2-867e-9d9053e21da8	true	access.token.claim
fa27cc39-5de5-41e2-867e-9d9053e21da8	groups	claim.name
fa27cc39-5de5-41e2-867e-9d9053e21da8	String	jsonType.label
e00f610d-5423-421d-b429-9e3a722f5420	true	introspection.token.claim
e00f610d-5423-421d-b429-9e3a722f5420	true	id.token.claim
e00f610d-5423-421d-b429-9e3a722f5420	true	access.token.claim
efec6347-5c63-4860-b36d-2355a3a89f9e	false	single
efec6347-5c63-4860-b36d-2355a3a89f9e	Basic	attribute.nameformat
efec6347-5c63-4860-b36d-2355a3a89f9e	Role	attribute.name
24d3d333-fd8b-441b-9e61-6505849c2d7e	true	introspection.token.claim
24d3d333-fd8b-441b-9e61-6505849c2d7e	true	userinfo.token.claim
24d3d333-fd8b-441b-9e61-6505849c2d7e	username	user.attribute
24d3d333-fd8b-441b-9e61-6505849c2d7e	true	id.token.claim
24d3d333-fd8b-441b-9e61-6505849c2d7e	true	access.token.claim
24d3d333-fd8b-441b-9e61-6505849c2d7e	preferred_username	claim.name
24d3d333-fd8b-441b-9e61-6505849c2d7e	String	jsonType.label
308a33b4-bec8-4830-a043-ee87168f7c6c	true	introspection.token.claim
308a33b4-bec8-4830-a043-ee87168f7c6c	true	userinfo.token.claim
308a33b4-bec8-4830-a043-ee87168f7c6c	nickname	user.attribute
308a33b4-bec8-4830-a043-ee87168f7c6c	true	id.token.claim
308a33b4-bec8-4830-a043-ee87168f7c6c	true	access.token.claim
308a33b4-bec8-4830-a043-ee87168f7c6c	nickname	claim.name
308a33b4-bec8-4830-a043-ee87168f7c6c	String	jsonType.label
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	true	introspection.token.claim
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	true	userinfo.token.claim
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	birthdate	user.attribute
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	true	id.token.claim
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	true	access.token.claim
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	birthdate	claim.name
454fcf5d-c01c-4b19-bcd0-fc0962a98b61	String	jsonType.label
495aba16-aa17-4bdc-baec-1f5779ef88b5	true	introspection.token.claim
495aba16-aa17-4bdc-baec-1f5779ef88b5	true	userinfo.token.claim
495aba16-aa17-4bdc-baec-1f5779ef88b5	gender	user.attribute
495aba16-aa17-4bdc-baec-1f5779ef88b5	true	id.token.claim
495aba16-aa17-4bdc-baec-1f5779ef88b5	true	access.token.claim
495aba16-aa17-4bdc-baec-1f5779ef88b5	gender	claim.name
495aba16-aa17-4bdc-baec-1f5779ef88b5	String	jsonType.label
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	true	introspection.token.claim
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	true	userinfo.token.claim
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	profile	user.attribute
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	true	id.token.claim
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	true	access.token.claim
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	profile	claim.name
5b1b9136-9bdf-4f92-b216-b27b3f6ff2eb	String	jsonType.label
5e832b5e-8766-4c11-a380-2451c65efd3e	true	introspection.token.claim
5e832b5e-8766-4c11-a380-2451c65efd3e	true	userinfo.token.claim
5e832b5e-8766-4c11-a380-2451c65efd3e	true	id.token.claim
5e832b5e-8766-4c11-a380-2451c65efd3e	true	access.token.claim
76d2301b-eb71-4b0e-9d83-456294e67640	true	introspection.token.claim
76d2301b-eb71-4b0e-9d83-456294e67640	true	userinfo.token.claim
76d2301b-eb71-4b0e-9d83-456294e67640	firstName	user.attribute
76d2301b-eb71-4b0e-9d83-456294e67640	true	id.token.claim
76d2301b-eb71-4b0e-9d83-456294e67640	true	access.token.claim
76d2301b-eb71-4b0e-9d83-456294e67640	given_name	claim.name
76d2301b-eb71-4b0e-9d83-456294e67640	String	jsonType.label
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	true	introspection.token.claim
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	true	userinfo.token.claim
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	picture	user.attribute
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	true	id.token.claim
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	true	access.token.claim
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	picture	claim.name
85cd7a6d-b6aa-4fe4-bbf7-c77eedf36962	String	jsonType.label
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	true	introspection.token.claim
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	true	userinfo.token.claim
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	website	user.attribute
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	true	id.token.claim
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	true	access.token.claim
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	website	claim.name
89cf8d15-f38c-4229-a4ec-f8ff4bf8ced8	String	jsonType.label
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	true	introspection.token.claim
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	true	userinfo.token.claim
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	locale	user.attribute
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	true	id.token.claim
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	true	access.token.claim
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	locale	claim.name
8b0542d2-ba39-416a-a5d5-ae21e734c5a2	String	jsonType.label
9718fe56-dfbe-44ad-8e95-2cdde454816e	true	introspection.token.claim
9718fe56-dfbe-44ad-8e95-2cdde454816e	true	userinfo.token.claim
9718fe56-dfbe-44ad-8e95-2cdde454816e	middleName	user.attribute
9718fe56-dfbe-44ad-8e95-2cdde454816e	true	id.token.claim
9718fe56-dfbe-44ad-8e95-2cdde454816e	true	access.token.claim
9718fe56-dfbe-44ad-8e95-2cdde454816e	middle_name	claim.name
9718fe56-dfbe-44ad-8e95-2cdde454816e	String	jsonType.label
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	true	introspection.token.claim
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	true	userinfo.token.claim
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	updatedAt	user.attribute
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	true	id.token.claim
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	true	access.token.claim
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	updated_at	claim.name
bbdccce4-9cec-46c3-aa71-7aab5f0061d7	long	jsonType.label
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	true	introspection.token.claim
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	true	userinfo.token.claim
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	lastName	user.attribute
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	true	id.token.claim
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	true	access.token.claim
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	family_name	claim.name
ceee5b75-2865-4dcc-bffc-018dd0a1f5c7	String	jsonType.label
fed8a610-2561-4b2b-b4a0-04a29141ee7d	true	introspection.token.claim
fed8a610-2561-4b2b-b4a0-04a29141ee7d	true	userinfo.token.claim
fed8a610-2561-4b2b-b4a0-04a29141ee7d	zoneinfo	user.attribute
fed8a610-2561-4b2b-b4a0-04a29141ee7d	true	id.token.claim
fed8a610-2561-4b2b-b4a0-04a29141ee7d	true	access.token.claim
fed8a610-2561-4b2b-b4a0-04a29141ee7d	zoneinfo	claim.name
fed8a610-2561-4b2b-b4a0-04a29141ee7d	String	jsonType.label
199e58ce-d760-456e-87be-4dd9d5858691	true	introspection.token.claim
199e58ce-d760-456e-87be-4dd9d5858691	true	userinfo.token.claim
199e58ce-d760-456e-87be-4dd9d5858691	email	user.attribute
199e58ce-d760-456e-87be-4dd9d5858691	true	id.token.claim
199e58ce-d760-456e-87be-4dd9d5858691	true	access.token.claim
199e58ce-d760-456e-87be-4dd9d5858691	email	claim.name
199e58ce-d760-456e-87be-4dd9d5858691	String	jsonType.label
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	true	introspection.token.claim
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	true	userinfo.token.claim
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	emailVerified	user.attribute
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	true	id.token.claim
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	true	access.token.claim
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	email_verified	claim.name
848a058f-c9ad-4c9f-99fc-93ab8d0c413f	boolean	jsonType.label
b143f1ec-8794-4125-8df9-82f624c2bd14	formatted	user.attribute.formatted
b143f1ec-8794-4125-8df9-82f624c2bd14	country	user.attribute.country
b143f1ec-8794-4125-8df9-82f624c2bd14	true	introspection.token.claim
b143f1ec-8794-4125-8df9-82f624c2bd14	postal_code	user.attribute.postal_code
b143f1ec-8794-4125-8df9-82f624c2bd14	true	userinfo.token.claim
b143f1ec-8794-4125-8df9-82f624c2bd14	street	user.attribute.street
b143f1ec-8794-4125-8df9-82f624c2bd14	true	id.token.claim
b143f1ec-8794-4125-8df9-82f624c2bd14	region	user.attribute.region
b143f1ec-8794-4125-8df9-82f624c2bd14	true	access.token.claim
b143f1ec-8794-4125-8df9-82f624c2bd14	locality	user.attribute.locality
467edd70-1ef0-482f-be35-f57cf0afc82d	true	introspection.token.claim
467edd70-1ef0-482f-be35-f57cf0afc82d	true	userinfo.token.claim
467edd70-1ef0-482f-be35-f57cf0afc82d	phoneNumber	user.attribute
467edd70-1ef0-482f-be35-f57cf0afc82d	true	id.token.claim
467edd70-1ef0-482f-be35-f57cf0afc82d	true	access.token.claim
467edd70-1ef0-482f-be35-f57cf0afc82d	phone_number	claim.name
467edd70-1ef0-482f-be35-f57cf0afc82d	String	jsonType.label
becb4c6b-f711-413d-8e77-6e0b873dc466	true	introspection.token.claim
becb4c6b-f711-413d-8e77-6e0b873dc466	true	userinfo.token.claim
becb4c6b-f711-413d-8e77-6e0b873dc466	phoneNumberVerified	user.attribute
becb4c6b-f711-413d-8e77-6e0b873dc466	true	id.token.claim
becb4c6b-f711-413d-8e77-6e0b873dc466	true	access.token.claim
becb4c6b-f711-413d-8e77-6e0b873dc466	phone_number_verified	claim.name
becb4c6b-f711-413d-8e77-6e0b873dc466	boolean	jsonType.label
3cee67d0-80af-45fd-8892-52d9e86d7fc9	true	introspection.token.claim
3cee67d0-80af-45fd-8892-52d9e86d7fc9	true	multivalued
3cee67d0-80af-45fd-8892-52d9e86d7fc9	foo	user.attribute
3cee67d0-80af-45fd-8892-52d9e86d7fc9	true	access.token.claim
3cee67d0-80af-45fd-8892-52d9e86d7fc9	realm_access.roles	claim.name
3cee67d0-80af-45fd-8892-52d9e86d7fc9	String	jsonType.label
6e97f25d-7747-4fa4-bdec-c0fc0050e56b	true	introspection.token.claim
6e97f25d-7747-4fa4-bdec-c0fc0050e56b	true	access.token.claim
ae3b8eef-e31c-4db9-920b-67216dafc13d	true	introspection.token.claim
ae3b8eef-e31c-4db9-920b-67216dafc13d	true	multivalued
ae3b8eef-e31c-4db9-920b-67216dafc13d	foo	user.attribute
ae3b8eef-e31c-4db9-920b-67216dafc13d	true	access.token.claim
ae3b8eef-e31c-4db9-920b-67216dafc13d	resource_access.${client_id}.roles	claim.name
ae3b8eef-e31c-4db9-920b-67216dafc13d	String	jsonType.label
c18c44c1-a09a-49a4-903a-547488c0f0ac	true	introspection.token.claim
c18c44c1-a09a-49a4-903a-547488c0f0ac	true	access.token.claim
28a90bec-dd46-4edd-9d86-18dc5d830c98	true	introspection.token.claim
28a90bec-dd46-4edd-9d86-18dc5d830c98	true	multivalued
28a90bec-dd46-4edd-9d86-18dc5d830c98	foo	user.attribute
28a90bec-dd46-4edd-9d86-18dc5d830c98	true	id.token.claim
28a90bec-dd46-4edd-9d86-18dc5d830c98	true	access.token.claim
28a90bec-dd46-4edd-9d86-18dc5d830c98	groups	claim.name
28a90bec-dd46-4edd-9d86-18dc5d830c98	String	jsonType.label
509241cc-da2f-4a84-b397-2f7eb692cd58	true	introspection.token.claim
509241cc-da2f-4a84-b397-2f7eb692cd58	true	userinfo.token.claim
509241cc-da2f-4a84-b397-2f7eb692cd58	username	user.attribute
509241cc-da2f-4a84-b397-2f7eb692cd58	true	id.token.claim
509241cc-da2f-4a84-b397-2f7eb692cd58	true	access.token.claim
509241cc-da2f-4a84-b397-2f7eb692cd58	upn	claim.name
509241cc-da2f-4a84-b397-2f7eb692cd58	String	jsonType.label
bc887854-ce1b-4a2f-b215-7f84b6c09b18	true	introspection.token.claim
bc887854-ce1b-4a2f-b215-7f84b6c09b18	true	id.token.claim
bc887854-ce1b-4a2f-b215-7f84b6c09b18	true	access.token.claim
2ecf849a-199c-4627-9447-e6e7b9527ff4	true	introspection.token.claim
2ecf849a-199c-4627-9447-e6e7b9527ff4	true	userinfo.token.claim
2ecf849a-199c-4627-9447-e6e7b9527ff4	locale	user.attribute
2ecf849a-199c-4627-9447-e6e7b9527ff4	true	id.token.claim
2ecf849a-199c-4627-9447-e6e7b9527ff4	true	access.token.claim
2ecf849a-199c-4627-9447-e6e7b9527ff4	locale	claim.name
2ecf849a-199c-4627-9447-e6e7b9527ff4	String	jsonType.label
\.


--
-- Data for Name: realm; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm (id, access_code_lifespan, user_action_lifespan, access_token_lifespan, account_theme, admin_theme, email_theme, enabled, events_enabled, events_expiration, login_theme, name, not_before, password_policy, registration_allowed, remember_me, reset_password_allowed, social, ssl_required, sso_idle_timeout, sso_max_lifespan, update_profile_on_soc_login, verify_email, master_admin_client, login_lifespan, internationalization_enabled, default_locale, reg_email_as_username, admin_events_enabled, admin_events_details_enabled, edit_username_allowed, otp_policy_counter, otp_policy_window, otp_policy_period, otp_policy_digits, otp_policy_alg, otp_policy_type, browser_flow, registration_flow, direct_grant_flow, reset_credentials_flow, client_auth_flow, offline_session_idle_timeout, revoke_refresh_token, access_token_life_implicit, login_with_email_allowed, duplicate_emails_allowed, docker_auth_flow, refresh_token_max_reuse, allow_user_managed_access, sso_max_lifespan_remember_me, sso_idle_timeout_remember_me, default_role) FROM stdin;
d4451a80-7ae2-4c36-999e-8e6184a6ec05	60	300	300	\N	\N	\N	t	f	0	\N	maskanyone	0	\N	f	t	f	f	EXTERNAL	1800	36000	f	f	789a5c1e-148f-46d7-92c3-cb4f51c2ce05	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	ae434371-eb92-4bc0-8964-80e9ea2e06d2	e461fa7b-a50d-48be-aa4c-a44546b0916f	f803135f-0749-498a-90ef-919d2543add0	4d8560e2-c33f-428d-bddd-0243c217a04a	b5d173c0-ce8d-43b0-b717-0ec3100df5f8	2592000	f	900	t	f	34802205-42d1-421d-989b-72a624f4b624	0	f	0	0	166370f4-a467-404c-b411-06e4d5af8895
15357e80-1b48-4482-93a9-2311f5c506f8	60	300	60	\N	\N	\N	t	f	0	\N	master	0	\N	f	f	f	f	EXTERNAL	1800	36000	f	f	33fbb3ed-00f4-4f09-86d9-ed0e682c528c	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	afecbc2c-8a17-41d3-88f2-5c5fefc1a6ca	b6838112-f14f-4acf-b487-90bad8e7bda0	5e0c8041-a87c-45b4-85fb-335355d171e7	b4d48465-e273-46dd-a6bd-7dbc18387bec	10d57c21-4598-4807-a807-d5fdc09f2820	2592000	f	900	t	f	4f92962b-c341-4399-8602-4a23dacc6f95	0	f	0	0	a06d40f9-1f4c-4ec6-affc-4e64e2803ea9
\.


--
-- Data for Name: realm_attribute; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.realm_attribute (name, realm_id, value) FROM stdin;
_browser_header.contentSecurityPolicyReportOnly	15357e80-1b48-4482-93a9-2311f5c506f8	
_browser_header.xContentTypeOptions	15357e80-1b48-4482-93a9-2311f5c506f8	nosniff
_browser_header.referrerPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	no-referrer
_browser_header.xRobotsTag	15357e80-1b48-4482-93a9-2311f5c506f8	none
_browser_header.xFrameOptions	15357e80-1b48-4482-93a9-2311f5c506f8	SAMEORIGIN
_browser_header.contentSecurityPolicy	15357e80-1b48-4482-93a9-2311f5c506f8	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.xXSSProtection	15357e80-1b48-4482-93a9-2311f5c506f8	1; mode=block
_browser_header.strictTransportSecurity	15357e80-1b48-4482-93a9-2311f5c506f8	max-age=31536000; includeSubDomains
bruteForceProtected	15357e80-1b48-4482-93a9-2311f5c506f8	false
permanentLockout	15357e80-1b48-4482-93a9-2311f5c506f8	false
maxFailureWaitSeconds	15357e80-1b48-4482-93a9-2311f5c506f8	900
minimumQuickLoginWaitSeconds	15357e80-1b48-4482-93a9-2311f5c506f8	60
waitIncrementSeconds	15357e80-1b48-4482-93a9-2311f5c506f8	60
quickLoginCheckMilliSeconds	15357e80-1b48-4482-93a9-2311f5c506f8	1000
maxDeltaTimeSeconds	15357e80-1b48-4482-93a9-2311f5c506f8	43200
failureFactor	15357e80-1b48-4482-93a9-2311f5c506f8	30
realmReusableOtpCode	15357e80-1b48-4482-93a9-2311f5c506f8	false
displayName	15357e80-1b48-4482-93a9-2311f5c506f8	Keycloak
displayNameHtml	15357e80-1b48-4482-93a9-2311f5c506f8	<div class="kc-logo-text"><span>Keycloak</span></div>
defaultSignatureAlgorithm	15357e80-1b48-4482-93a9-2311f5c506f8	RS256
offlineSessionMaxLifespanEnabled	15357e80-1b48-4482-93a9-2311f5c506f8	false
offlineSessionMaxLifespan	15357e80-1b48-4482-93a9-2311f5c506f8	5184000
bruteForceProtected	d4451a80-7ae2-4c36-999e-8e6184a6ec05	false
permanentLockout	d4451a80-7ae2-4c36-999e-8e6184a6ec05	false
maxFailureWaitSeconds	d4451a80-7ae2-4c36-999e-8e6184a6ec05	900
minimumQuickLoginWaitSeconds	d4451a80-7ae2-4c36-999e-8e6184a6ec05	60
waitIncrementSeconds	d4451a80-7ae2-4c36-999e-8e6184a6ec05	60
quickLoginCheckMilliSeconds	d4451a80-7ae2-4c36-999e-8e6184a6ec05	1000
maxDeltaTimeSeconds	d4451a80-7ae2-4c36-999e-8e6184a6ec05	43200
failureFactor	d4451a80-7ae2-4c36-999e-8e6184a6ec05	30
actionTokenGeneratedByAdminLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	43200
actionTokenGeneratedByUserLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	300
defaultSignatureAlgorithm	d4451a80-7ae2-4c36-999e-8e6184a6ec05	RS256
offlineSessionMaxLifespanEnabled	d4451a80-7ae2-4c36-999e-8e6184a6ec05	false
offlineSessionMaxLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5184000
webAuthnPolicyRpEntityName	d4451a80-7ae2-4c36-999e-8e6184a6ec05	keycloak
webAuthnPolicySignatureAlgorithms	d4451a80-7ae2-4c36-999e-8e6184a6ec05	ES256
webAuthnPolicyRpId	d4451a80-7ae2-4c36-999e-8e6184a6ec05	
realmReusableOtpCode	d4451a80-7ae2-4c36-999e-8e6184a6ec05	false
webAuthnPolicyAttestationConveyancePreference	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyAuthenticatorAttachment	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyRequireResidentKey	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyUserVerificationRequirement	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyCreateTimeout	d4451a80-7ae2-4c36-999e-8e6184a6ec05	0
oauth2DeviceCodeLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	600
oauth2DevicePollingInterval	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5
webAuthnPolicyAvoidSameAuthenticatorRegister	d4451a80-7ae2-4c36-999e-8e6184a6ec05	false
webAuthnPolicyRpEntityNamePasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	keycloak
webAuthnPolicySignatureAlgorithmsPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	ES256
webAuthnPolicyRpIdPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	
webAuthnPolicyAttestationConveyancePreferencePasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyAuthenticatorAttachmentPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyRequireResidentKeyPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyUserVerificationRequirementPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	not specified
webAuthnPolicyCreateTimeoutPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	0
webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	false
client-policies.profiles	d4451a80-7ae2-4c36-999e-8e6184a6ec05	{"profiles":[]}
client-policies.policies	d4451a80-7ae2-4c36-999e-8e6184a6ec05	{"policies":[]}
_browser_header.contentSecurityPolicyReportOnly	d4451a80-7ae2-4c36-999e-8e6184a6ec05	
_browser_header.xContentTypeOptions	d4451a80-7ae2-4c36-999e-8e6184a6ec05	nosniff
_browser_header.referrerPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	no-referrer
_browser_header.xRobotsTag	d4451a80-7ae2-4c36-999e-8e6184a6ec05	none
_browser_header.xFrameOptions	d4451a80-7ae2-4c36-999e-8e6184a6ec05	SAMEORIGIN
_browser_header.contentSecurityPolicy	d4451a80-7ae2-4c36-999e-8e6184a6ec05	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
cibaBackchannelTokenDeliveryMode	d4451a80-7ae2-4c36-999e-8e6184a6ec05	poll
cibaExpiresIn	d4451a80-7ae2-4c36-999e-8e6184a6ec05	120
cibaInterval	d4451a80-7ae2-4c36-999e-8e6184a6ec05	5
cibaAuthRequestedUserHint	d4451a80-7ae2-4c36-999e-8e6184a6ec05	login_hint
parRequestUriLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	60
_browser_header.xXSSProtection	d4451a80-7ae2-4c36-999e-8e6184a6ec05	1; mode=block
_browser_header.strictTransportSecurity	d4451a80-7ae2-4c36-999e-8e6184a6ec05	max-age=31536000; includeSubDomains
clientSessionIdleTimeout	d4451a80-7ae2-4c36-999e-8e6184a6ec05	0
clientSessionMaxLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	0
clientOfflineSessionIdleTimeout	d4451a80-7ae2-4c36-999e-8e6184a6ec05	0
clientOfflineSessionMaxLifespan	d4451a80-7ae2-4c36-999e-8e6184a6ec05	0
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
15357e80-1b48-4482-93a9-2311f5c506f8	jboss-logging
d4451a80-7ae2-4c36-999e-8e6184a6ec05	jboss-logging
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
password	password	t	t	15357e80-1b48-4482-93a9-2311f5c506f8
password	password	t	t	d4451a80-7ae2-4c36-999e-8e6184a6ec05
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
175549f9-bbf4-4afd-bde3-d1371c27ed9d	/realms/master/account/*
1027adf9-f5a4-4317-9aef-b634d978fb5f	/realms/master/account/*
6311a773-e535-4fde-ac60-61694989a4bc	/admin/master/console/*
5edb3285-0625-4a5e-a93a-27c7b489020b	/realms/maskanyone/account/*
6c46bf16-f287-447b-9e2c-9d017241dd84	/realms/maskanyone/account/*
eff849b3-27b3-4b4e-986b-bb5986524cd1	/admin/maskanyone/console/*
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	https://localhost/*
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
29dba7d4-941d-402f-855e-f2a50807b830	VERIFY_EMAIL	Verify Email	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	VERIFY_EMAIL	50
d1badf16-3845-4070-8287-ec670dc2017f	UPDATE_PROFILE	Update Profile	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	UPDATE_PROFILE	40
87b7852d-af61-4f07-8160-120d020569d1	CONFIGURE_TOTP	Configure OTP	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	CONFIGURE_TOTP	10
24ce2c52-5d8d-4a33-b1d1-46d46f3a1c55	UPDATE_PASSWORD	Update Password	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	UPDATE_PASSWORD	30
af1a1238-18f5-4764-85be-be1881461a8b	TERMS_AND_CONDITIONS	Terms and Conditions	15357e80-1b48-4482-93a9-2311f5c506f8	f	f	TERMS_AND_CONDITIONS	20
ed703f7e-106e-4620-8141-45bdd6bc3f8a	delete_account	Delete Account	15357e80-1b48-4482-93a9-2311f5c506f8	f	f	delete_account	60
1898b0d8-ee75-43c5-a6d2-ec9973a0b87e	update_user_locale	Update User Locale	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	update_user_locale	1000
494fab29-4b75-4d22-8fdf-e80eaf93dc03	webauthn-register	Webauthn Register	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	webauthn-register	70
bd41b7fe-3f89-4afd-9c83-c2e5722b04a0	webauthn-register-passwordless	Webauthn Register Passwordless	15357e80-1b48-4482-93a9-2311f5c506f8	t	f	webauthn-register-passwordless	80
07614696-2e94-47c9-a178-56a0857d381d	VERIFY_EMAIL	Verify Email	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	VERIFY_EMAIL	50
df5f7a0b-7af0-4dd7-a460-3fc893472251	UPDATE_PROFILE	Update Profile	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	UPDATE_PROFILE	40
a16eefbc-1ab9-4557-b02d-8964b7c25dc6	CONFIGURE_TOTP	Configure OTP	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	CONFIGURE_TOTP	10
e944c380-1f3b-403d-a116-8bc2f9745d03	UPDATE_PASSWORD	Update Password	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	UPDATE_PASSWORD	30
8f6310c6-a1a0-4c13-9a68-a18dc5492960	TERMS_AND_CONDITIONS	Terms and Conditions	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f	f	TERMS_AND_CONDITIONS	20
4ed48221-13be-4ad2-8236-bd228758189b	delete_account	Delete Account	d4451a80-7ae2-4c36-999e-8e6184a6ec05	f	f	delete_account	60
4827072d-34fa-4a58-9ddc-1b186817d515	update_user_locale	Update User Locale	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	update_user_locale	1000
beb0ca4d-f75e-45d1-94de-eb25adf65be9	webauthn-register	Webauthn Register	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	webauthn-register	70
34efbf99-6c83-47d1-a80e-03d1e7f43c7c	webauthn-register-passwordless	Webauthn Register Passwordless	d4451a80-7ae2-4c36-999e-8e6184a6ec05	t	f	webauthn-register-passwordless	80
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
1027adf9-f5a4-4317-9aef-b634d978fb5f	911cba8e-de45-4af2-a733-a277a67d3159
1027adf9-f5a4-4317-9aef-b634d978fb5f	9ff4acc5-0f84-4b89-9e1b-b7116c86c843
6c46bf16-f287-447b-9e2c-9d017241dd84	67a08dca-1227-4fc0-858a-d022ab5a0163
6c46bf16-f287-447b-9e2c-9d017241dd84	dbd0c2a7-ab8e-4917-a2cc-d93d66b73401
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
6feec7e0-d77f-48e3-801b-07c92666edb2	\N	bb0317ce-f07d-4a13-b60c-255f9a1ef1a5	f	t	\N	\N	\N	15357e80-1b48-4482-93a9-2311f5c506f8	dev	1705955466000	\N	0
51ebd241-a1c5-481f-b1e3-35bf714277ea	test.user@hpi.de	test.user@hpi.de	f	t	\N	Test	User	d4451a80-7ae2-4c36-999e-8e6184a6ec05	test	1706037471848	\N	0
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
a06d40f9-1f4c-4ec6-affc-4e64e2803ea9	6feec7e0-d77f-48e3-801b-07c92666edb2
cc85e419-a2db-47d5-b2e4-a8c7b39cf255	6feec7e0-d77f-48e3-801b-07c92666edb2
54ba87cf-a7bd-49be-8083-a2bf6b023c68	6feec7e0-d77f-48e3-801b-07c92666edb2
72a999b0-44e1-4cba-91ae-969d339f3083	6feec7e0-d77f-48e3-801b-07c92666edb2
59074f6b-e7a6-49f6-8169-4ef6fd6b0ab6	6feec7e0-d77f-48e3-801b-07c92666edb2
588b1669-bbfb-497b-b852-2a9ed79d90c1	6feec7e0-d77f-48e3-801b-07c92666edb2
cf79e2a4-833e-459f-a9a3-2b695d36b9fe	6feec7e0-d77f-48e3-801b-07c92666edb2
c2fa8fc2-48ff-4523-9162-e7485a4804e5	6feec7e0-d77f-48e3-801b-07c92666edb2
213432b2-4ec7-40c4-887e-cf658c5c833f	6feec7e0-d77f-48e3-801b-07c92666edb2
396febca-1a30-4a8a-b6f3-ec37512b411b	6feec7e0-d77f-48e3-801b-07c92666edb2
5101e6bc-eb30-422a-a4cf-826b6b22d471	6feec7e0-d77f-48e3-801b-07c92666edb2
8a647b27-11a3-41ab-ad89-989dac04d134	6feec7e0-d77f-48e3-801b-07c92666edb2
7e5d707a-0beb-4e4f-b1a8-208e30d21b2c	6feec7e0-d77f-48e3-801b-07c92666edb2
4e4e3f0a-812d-41e5-a7aa-7c4d1a588e0d	6feec7e0-d77f-48e3-801b-07c92666edb2
8fe53906-ceeb-4819-b4d8-40f7d2e5dbb5	6feec7e0-d77f-48e3-801b-07c92666edb2
14bbc843-46b6-40a0-beda-fd2246be2404	6feec7e0-d77f-48e3-801b-07c92666edb2
947beb93-4b2f-47ae-b1ec-cd45e1baf44a	6feec7e0-d77f-48e3-801b-07c92666edb2
4dfb1e0c-8119-46db-bf1c-afc7e9c67ef5	6feec7e0-d77f-48e3-801b-07c92666edb2
da3e31cb-a541-400c-9195-122bc93fe061	6feec7e0-d77f-48e3-801b-07c92666edb2
166370f4-a467-404c-b411-06e4d5af8895	51ebd241-a1c5-481f-b1e3-35bf714277ea
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
6311a773-e535-4fde-ac60-61694989a4bc	+
eff849b3-27b3-4b4e-986b-bb5986524cd1	+
30cbf199-a4e0-4bff-ae7a-895a2f93d8e2	+
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

