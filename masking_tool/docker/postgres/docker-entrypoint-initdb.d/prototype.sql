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
-- Name: prototype; Type: DATABASE; Schema: -; Owner: dev
--

CREATE DATABASE prototype WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE prototype OWNER TO dev;

\connect prototype

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
-- Name: jobs; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.jobs (
    id uuid NOT NULL,
    video_id uuid NOT NULL,
    result_video_id uuid NOT NULL,
    type character varying NOT NULL,
    status character varying NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    progress integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.jobs OWNER TO dev;

--
-- Name: presets; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.presets (
    id uuid NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE public.presets OWNER TO dev;

--
-- Name: result_audio_files; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.result_audio_files (
    id uuid NOT NULL,
    result_video_id uuid NOT NULL,
    video_id uuid NOT NULL,
    job_id uuid NOT NULL,
    data bytea NOT NULL
);


ALTER TABLE public.result_audio_files OWNER TO dev;

--
-- Name: result_extra_files; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.result_extra_files (
    id uuid NOT NULL,
    result_video_id uuid NOT NULL,
    video_id uuid NOT NULL,
    job_id uuid NOT NULL,
    ending character varying NOT NULL,
    data bytea NOT NULL
);


ALTER TABLE public.result_extra_files OWNER TO dev;

--
-- Name: result_blendshapes; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.result_blendshapes (
    id uuid NOT NULL,
    result_video_id uuid NOT NULL,
    video_id uuid NOT NULL,
    job_id uuid NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE public.result_blendshapes OWNER TO dev;

--
-- Name: result_mp_kinematics; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.result_mp_kinematics (
    id uuid NOT NULL,
    result_video_id uuid NOT NULL,
    video_id uuid NOT NULL,
    job_id uuid NOT NULL,
    type character varying NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE public.result_mp_kinematics OWNER TO dev;

--
-- Name: result_videos; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.result_videos (
    id uuid NOT NULL,
    video_id uuid NOT NULL,
    job_id uuid NOT NULL,
    video_info jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name character varying DEFAULT 'Result'::character varying NOT NULL
);


ALTER TABLE public.result_videos OWNER TO dev;

--
-- Name: videos; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.videos (
    id uuid NOT NULL,
    name character varying NOT NULL,
    status character varying NOT NULL,
    video_info jsonb
);


ALTER TABLE public.videos OWNER TO dev;

--
-- Name: workers; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.workers (
    id uuid NOT NULL,
    job_id uuid,
    last_activity timestamp without time zone
);


ALTER TABLE public.workers OWNER TO dev;

--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: presets presets_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.presets
    ADD CONSTRAINT presets_pkey PRIMARY KEY (id);


--
-- Name: result_audio_files result_audio_files_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.result_audio_files
    ADD CONSTRAINT result_audio_files_pkey PRIMARY KEY (id);


--
-- Name: result_extra_files result_extra_files_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.result_extra_files
    ADD CONSTRAINT result_extra_files_pkey PRIMARY KEY (id);


--
-- Name: result_blendshapes result_blendshapes_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.result_blendshapes
    ADD CONSTRAINT result_blendshapes_pkey PRIMARY KEY (id);


--
-- Name: result_mp_kinematics result_mp_kinematics_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.result_mp_kinematics
    ADD CONSTRAINT result_mp_kinematics_pkey PRIMARY KEY (id);


--
-- Name: result_videos result_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.result_videos
    ADD CONSTRAINT result_videos_pkey PRIMARY KEY (id);


--
-- Name: jobs unique_result_video_id; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT unique_result_video_id UNIQUE (result_video_id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

