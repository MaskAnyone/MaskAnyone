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
    type character varying NOT NULL,
    status character varying NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    finished_at timestamp without time zone
);


ALTER TABLE public.jobs OWNER TO dev;

--
-- Name: result_videos; Type: TABLE; Schema: public; Owner: dev
--

CREATE TABLE public.result_videos (
    id uuid NOT NULL,
    video_id uuid NOT NULL,
    job_id uuid NOT NULL,
    video_info jsonb
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
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.jobs (id, video_id, type, status, data, created_at, started_at, finished_at) FROM stdin;
\.


--
-- Data for Name: result_videos; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.result_videos (id, video_id, job_id, video_info) FROM stdin;
\.


--
-- Data for Name: videos; Type: TABLE DATA; Schema: public; Owner: dev
--

COPY public.videos (id, name, status, video_info) FROM stdin;
96e9e676-51ac-4af5-9952-3ad371669ddc	ted_kid.mp4	valid	{"fps": 30, "codec": "avc1", "duration": 7.006966666666666, "frame_count": 210, "frame_width": 1920, "frame_height": 1080}
c466648e-7a51-4bf9-b876-0f7ee59ea0ad	sample.mp4	valid	{"fps": 30, "codec": "avc1", "duration": 17.266000000000002, "frame_count": 518, "frame_width": 1280, "frame_height": 720}
dcd7f0f2-7f77-403f-b0bc-14a8198793d8	test.mp4	valid	{"fps": 30, "codec": "avc1", "duration": 42.83316666666667, "frame_count": 1285, "frame_width": 640, "frame_height": 360}
\.


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: result_videos result_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.result_videos
    ADD CONSTRAINT result_videos_pkey PRIMARY KEY (id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: dev
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

