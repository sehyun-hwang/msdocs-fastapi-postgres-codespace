--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.6 (Debian 15.6-0+deb12u1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pg_similarity; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_similarity WITH SCHEMA public;


--
-- Name: EXTENSION pg_similarity; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_similarity IS 'support similarity queries';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: myrowtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.myrowtype AS (
	index integer,
	jsonpath text
);


--
-- Name: find_index(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_index(hash_param character varying, title character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$ DECLARE
	max_score numeric := 0;
	score numeric := 0;
	idx numeric := 0;
	obj RECORD;
BEGIN
	FOR obj IN (SELECT index, xpath('//HeadLine/text()', xml) as title FROM groundtruth a WHERE a.hash=hash_param) LOOP
		score := jarowinkler(obj.title::text, title);
		IF score > max_score THEN
			max_score := score;
			idx := obj.index;
		END IF;
	END LOOP;
	RETURN idx;
END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: article_ai; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_ai (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    hash character(32) NOT NULL,
    title character varying,
    article jsonb,
    article_index integer,
    image character varying,
    images text[] DEFAULT '{}'::character varying[],
    hull double precision[] DEFAULT '{}'::double precision[],
    reg_dt timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    category character varying,
    layouts jsonb,
    update_cnt bigint DEFAULT 0
);


--
-- Name: article_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article_revision (
    id integer NOT NULL,
    article_id uuid NOT NULL,
    article jsonb,
    layouts jsonb
);


--
-- Name: article_revision_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_revision_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_revision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_revision_id_seq OWNED BY public.article_revision.id;


--
-- Name: cognito_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cognito_user (
    id integer NOT NULL,
    user_name character varying,
    plantym_user_id character varying
);


--
-- Name: const; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.const (
    name text NOT NULL,
    json jsonb,
    string character varying
);


--
-- Name: groundtruth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groundtruth (
    hash character(32) NOT NULL,
    pdf_path_legacy character varying NOT NULL,
    index integer NOT NULL,
    xml xml NOT NULL
);


--
-- Name: newspaper_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newspaper_company (
    id integer NOT NULL,
    author character varying,
    display_status boolean DEFAULT false
);


--
-- Name: COLUMN newspaper_company.author; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper_company.author IS 'Newspaper Company';


--
-- Name: newspaper_company_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newspaper_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newspaper_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newspaper_company_id_seq OWNED BY public.newspaper_company.id;


--
-- Name: newspaper_upload; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newspaper_upload (
    date date NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    author character varying NOT NULL,
    mime character varying NOT NULL,
    hash character varying NOT NULL,
    bucket character varying NOT NULL,
    key character varying NOT NULL,
    name character varying NOT NULL,
    page integer,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: pdf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pdf (
    hash character(32) NOT NULL,
    path character varying,
    page integer DEFAULT 1 NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    page_image character varying,
    page_image_file_name character varying,
    thum_image character varying,
    thum_file_name character varying,
    origin_pdf character varying,
    origin_file_name character varying,
    stepfunction_arn character varying,
    upload_id uuid NOT NULL
);


--
-- Name: COLUMN pdf.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.hash IS 'PDF 바이너리 MD5 해시값';


--
-- Name: COLUMN pdf.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.path IS 'AWS S3 PDF Key값';


--
-- Name: COLUMN pdf.page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.page IS 'Page 정보';


--
-- Name: COLUMN pdf."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf."timestamp" IS 'Insert 타임스템프';


--
-- Name: COLUMN pdf.page_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.page_image IS '페이지 이미지 경로';


--
-- Name: COLUMN pdf.page_image_file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.page_image_file_name IS '페이지 이미지 파일이름';


--
-- Name: COLUMN pdf.thum_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.thum_image IS '썸네일 이미지 경로';


--
-- Name: COLUMN pdf.thum_file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.thum_file_name IS '썸네일 이미지 파일이름';


--
-- Name: COLUMN pdf.origin_pdf; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.origin_pdf IS 'PDF 낱장 원본 경로';


--
-- Name: COLUMN pdf.origin_file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.origin_file_name IS 'PDF 낱장 원본 파일이름';


--
-- Name: COLUMN pdf.stepfunction_arn; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.stepfunction_arn IS 'AI 검수 수행한 Stepfunction ARN';


--
-- Name: result_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.result_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task (
    arn character varying NOT NULL,
    layouts_spaced_pdf jsonb,
    layouts_naver jsonb DEFAULT jsonb_build_array(),
    layouts_spaced_naver jsonb DEFAULT jsonb_build_array(),
    hash character(32) NOT NULL,
    reg_dt timestamp with time zone DEFAULT now() NOT NULL,
    first_title character varying,
    layouts_pdf jsonb,
    layouts_pdf_paragraph_connection jsonb,
    layouts_naver_paragraph_connection jsonb,
    layouts_pdf_category jsonb,
    layouts_naver_category jsonb,
    CONSTRAINT task_hash_check CHECK ((length(hash) = 32)),
    CONSTRAINT task_layouts_populated_check CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text)),
    CONSTRAINT task_layouts_populated_check1 CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text)),
    CONSTRAINT task_layouts_populated_check2 CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text)),
    CONSTRAINT task_layouts_populated_check3 CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text)),
    CONSTRAINT task_layouts_populated_check4 CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text)),
    CONSTRAINT task_layouts_populated_check5 CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text)),
    CONSTRAINT task_layouts_populated_check6 CHECK ((jsonb_typeof(layouts_spaced_pdf) = 'array'::text))
);


--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_id_seq OWNED BY public.cognito_user.id;


--
-- Name: article_revision id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_revision ALTER COLUMN id SET DEFAULT nextval('public.article_revision_id_seq'::regclass);


--
-- Name: cognito_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cognito_user ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: newspaper_company id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company ALTER COLUMN id SET DEFAULT nextval('public.newspaper_company_id_seq'::regclass);


--
-- Name: article_revision article_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_revision
    ADD CONSTRAINT article_revision_pkey PRIMARY KEY (id);


--
-- Name: article_ai article_test_hash_article_index_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_ai
    ADD CONSTRAINT article_test_hash_article_index_key UNIQUE (hash, article_index);


--
-- Name: article_ai article_test_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_ai
    ADD CONSTRAINT article_test_pkey PRIMARY KEY (id);


--
-- Name: newspaper_company newspaper_company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company
    ADD CONSTRAINT newspaper_company_pkey PRIMARY KEY (id);


--
-- Name: pdf pdf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf
    ADD CONSTRAINT pdf_pkey PRIMARY KEY (hash);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (arn);


--
-- Name: newspaper_company unique_author; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company
    ADD CONSTRAINT unique_author UNIQUE (author);


--
-- Name: cognito_user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cognito_user
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: json_test_payload_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX json_test_payload_name_idx ON public.const USING btree (name);


--
-- Name: task_expr_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_expr_idx ON public.task USING btree (((layouts_pdf ->> 'article_id'::text)));


--
-- Name: task_reg_dt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_reg_dt_idx ON public.task USING btree (reg_dt);


--
-- Name: unique_plantym_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_plantym_user_id ON public.cognito_user USING btree (plantym_user_id);


--
-- Name: upload_author__date__page_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX upload_author__date__page_idx ON public.newspaper_upload USING btree (author, date, page);


--
-- Name: upload_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX upload_id_idx ON public.newspaper_upload USING btree (id);


--
-- Name: article_revision article_revision_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article_revision
    ADD CONSTRAINT article_revision_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.article_ai(id);


--
-- Name: pdf pdf_upload_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf
    ADD CONSTRAINT pdf_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES public.newspaper_upload(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: newspaper_upload upload_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_upload
    ADD CONSTRAINT upload_author_fkey FOREIGN KEY (author) REFERENCES public.newspaper_company(author);


--
-- PostgreSQL database dump complete
--

