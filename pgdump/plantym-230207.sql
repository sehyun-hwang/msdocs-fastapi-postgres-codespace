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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


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


--
-- Name: update_changetimestamp_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_changetimestamp_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.timestamp = now(); 
   RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cognito_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cognito_user (
    id integer NOT NULL,
    user_name character varying,
    plantym_user_id character varying
);


--
-- Name: COLUMN cognito_user.plantym_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.cognito_user.plantym_user_id IS 'Plantym user id';


--
-- Name: daily_newspaper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_newspaper (
    publish_date date NOT NULL,
    is_complete_inspection boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL,
    newspaper_company_id integer DEFAULT 1 NOT NULL,
    inspection_page integer DEFAULT 0,
    total_page integer,
    last_modified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: COLUMN daily_newspaper.publish_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.publish_date IS '발행일';


--
-- Name: COLUMN daily_newspaper.is_complete_inspection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.is_complete_inspection IS '검수 완료 여부';


--
-- Name: COLUMN daily_newspaper.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.created_at IS '업로드일';


--
-- Name: COLUMN daily_newspaper.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.id IS '신문지 아이디';


--
-- Name: COLUMN daily_newspaper.newspaper_company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.newspaper_company_id IS '신문사 아이디';


--
-- Name: COLUMN daily_newspaper.inspection_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.inspection_page IS '검수된 페이지 수';


--
-- Name: COLUMN daily_newspaper.total_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.total_page IS '총 페이지 수';


--
-- Name: COLUMN daily_newspaper.last_modified_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.last_modified_at IS '최종 수정일';


--
-- Name: deploy; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deploy (
    id integer NOT NULL,
    page_info jsonb,
    articles jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    "isSuccess" boolean DEFAULT false
);


--
-- Name: deploy_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deploy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deploy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deploy_id_seq OWNED BY public.deploy.id;


--
-- Name: newspaper_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newspaper_company (
    id integer NOT NULL,
    name character varying
);


--
-- Name: COLUMN newspaper_company.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper_company.name IS 'Newspaper Company';


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
-- Name: newspaper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newspaper_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newspaper_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newspaper_id_seq OWNED BY public.daily_newspaper.id;


--
-- Name: pdf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pdf (
    hash character(32) NOT NULL,
    path character varying NOT NULL,
    page integer NOT NULL,
    has_next boolean DEFAULT false NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    parent character(32),
    publish_date date DEFAULT CURRENT_DATE NOT NULL,
    publish_company integer DEFAULT 1 NOT NULL,
    request_id character varying,
    daily_newspaper_id integer,
    page_image character varying,
    page_image_file_name character varying,
    thum_image character varying,
    thum_file_name character varying,
    origin_pdf character varying,
    origin_file_name character varying,
    stepfunction_arn character varying,
    is_inspect boolean DEFAULT false NOT NULL,
    inspected_at timestamp without time zone
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
-- Name: COLUMN pdf.has_next; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.has_next IS '다음페이지 유무';


--
-- Name: COLUMN pdf."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf."timestamp" IS 'Insert 타임스템프';


--
-- Name: COLUMN pdf.parent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.parent IS '자르기전 통권 PDF의 바이너리 MD5 해시값';


--
-- Name: COLUMN pdf.publish_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.publish_date IS '신문 발행일';


--
-- Name: COLUMN pdf.publish_company; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.publish_company IS '신문사 id';


--
-- Name: COLUMN pdf.request_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.request_id IS 'AWS Lambda PDF Split Request ID';


--
-- Name: COLUMN pdf.daily_newspaper_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pdf.daily_newspaper_id IS '신문사-신문발행일 기준 테이블 ID';


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
-- Name: result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.result (
    hash character(32) NOT NULL,
    title character varying,
    article jsonb,
    article_index integer,
    image text[] DEFAULT '{}'::text[],
    hull double precision[] DEFAULT '{}'::double precision[],
    reg_dt timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    category character varying
);


--
-- Name: COLUMN result.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.result.hash IS 'PDF 바이너리 MD5 해시값';


--
-- Name: COLUMN result.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.result.title IS '기사 제목';


--
-- Name: COLUMN result.article; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.result.article IS '기사 Object';


--
-- Name: COLUMN result.article_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.result.article_index IS '기사 갯수';


--
-- Name: COLUMN result.reg_dt; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.result.reg_dt IS 'insert 일자';


--
-- Name: COLUMN result.category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.result.category IS '카테고리 분류';


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
-- Name: user_inspection_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_inspection_data (
    hash character(32) NOT NULL,
    title character varying,
    article jsonb,
    article_index integer,
    image text[],
    hull double precision[],
    created_at timestamp without time zone NOT NULL,
    category character varying,
    last_modified_at timestamp without time zone,
    inspection_user_id integer
);


--
-- Name: cognito_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cognito_user ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: daily_newspaper id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper ALTER COLUMN id SET DEFAULT nextval('public.newspaper_id_seq'::regclass);


--
-- Name: deploy id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploy ALTER COLUMN id SET DEFAULT nextval('public.deploy_id_seq'::regclass);


--
-- Name: newspaper_company id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company ALTER COLUMN id SET DEFAULT nextval('public.newspaper_company_id_seq'::regclass);


--
-- Name: deploy deploy_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deploy
    ADD CONSTRAINT deploy_pkey PRIMARY KEY (id);


--
-- Name: newspaper_company newspaper_company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company
    ADD CONSTRAINT newspaper_company_pkey PRIMARY KEY (id);


--
-- Name: daily_newspaper newspaper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper
    ADD CONSTRAINT newspaper_pkey PRIMARY KEY (id);


--
-- Name: pdf pdf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf
    ADD CONSTRAINT pdf_pkey PRIMARY KEY (hash);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (id);


--
-- Name: newspaper_company unique_author; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company
    ADD CONSTRAINT unique_author UNIQUE (name);


--
-- Name: daily_newspaper unique_author_date; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper
    ADD CONSTRAINT unique_author_date UNIQUE (newspaper_company_id, publish_date);


--
-- Name: cognito_user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cognito_user
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: daily_newspaper_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_newspaper_created_at_idx ON public.daily_newspaper USING btree (created_at);


--
-- Name: hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hash_index ON public.result USING btree (hash);


--
-- Name: pdf_page_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pdf_page_idx ON public.pdf USING btree (page);


--
-- Name: unique_plantym_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_plantym_user_id ON public.cognito_user USING btree (plantym_user_id);


--
-- Name: pdf update_ab_changetimestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ab_changetimestamp BEFORE UPDATE ON public.pdf FOR EACH ROW EXECUTE FUNCTION public.update_changetimestamp_column();


--
-- Name: daily_newspaper daily_newspaper_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper
    ADD CONSTRAINT daily_newspaper_author_fkey FOREIGN KEY (newspaper_company_id) REFERENCES public.newspaper_company(id) ON DELETE CASCADE;


--
-- Name: pdf pdf_daily_newspaper_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pdf
    ADD CONSTRAINT pdf_daily_newspaper_id_fkey FOREIGN KEY (daily_newspaper_id) REFERENCES public.daily_newspaper(id) ON DELETE CASCADE;


--
-- Name: result result_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_hash_fkey FOREIGN KEY (hash) REFERENCES public.pdf(hash) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

