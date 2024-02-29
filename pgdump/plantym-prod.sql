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
-- Name: confirm_article; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.confirm_article (
    id integer NOT NULL,
    hash character(32) NOT NULL,
    article jsonb,
    inspect_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    uuid uuid,
    meta jsonb,
    confirm_pdf_id integer,
    article_type character varying,
    info jsonb,
    coordinate jsonb,
    user_id integer
);


--
-- Name: COLUMN confirm_article.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_article.hash IS 'PDF Hash 값';


--
-- Name: COLUMN confirm_article.article; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_article.article IS '수정한 기사 데이터';


--
-- Name: COLUMN confirm_article.inspect_timestamp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_article.inspect_timestamp IS '검수 시각';


--
-- Name: COLUMN confirm_article.uuid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_article.uuid IS '같은 시간에 검수한 기사';


--
-- Name: COLUMN confirm_article.meta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_article.meta IS 'Plantym에서 요구하는 메타데이터';


--
-- Name: COLUMN confirm_article.coordinate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_article.coordinate IS '실제 기사 너비값';


--
-- Name: confirm_article_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.confirm_article_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: confirm_article_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.confirm_article_id_seq OWNED BY public.confirm_article.id;


--
-- Name: confirm_pdf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.confirm_pdf (
    id integer NOT NULL,
    hash character varying,
    article_count integer,
    ad_count integer,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    uuid uuid,
    user_id integer
);


--
-- Name: COLUMN confirm_pdf.hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_pdf.hash IS 'PDF Hash 값';


--
-- Name: COLUMN confirm_pdf.article_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_pdf.article_count IS '기사 수';


--
-- Name: COLUMN confirm_pdf.ad_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_pdf.ad_count IS '광고 수';


--
-- Name: COLUMN confirm_pdf."timestamp"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.confirm_pdf."timestamp" IS 'insert timestamp';


--
-- Name: confirm_pdf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.confirm_pdf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: confirm_pdf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.confirm_pdf_id_seq OWNED BY public.confirm_pdf.id;


--
-- Name: daily_newspaper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_newspaper (
    publish_date date NOT NULL,
    deploy_status boolean DEFAULT false,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL,
    author integer DEFAULT 1 NOT NULL
);


--
-- Name: COLUMN daily_newspaper.publish_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.publish_date IS '권호일자';


--
-- Name: COLUMN daily_newspaper.author; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.daily_newspaper.author IS '신문사 ID';


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
-- Name: layoutparser_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layoutparser_log (
    hash character(32) NOT NULL,
    layout jsonb NOT NULL,
    reg_dt timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    digest character(64)
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
    stepfunction_arn character varying
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
-- Name: cognito_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cognito_user ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: confirm_article id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_article ALTER COLUMN id SET DEFAULT nextval('public.confirm_article_id_seq'::regclass);


--
-- Name: confirm_pdf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_pdf ALTER COLUMN id SET DEFAULT nextval('public.confirm_pdf_id_seq'::regclass);


--
-- Name: daily_newspaper id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper ALTER COLUMN id SET DEFAULT nextval('public.newspaper_id_seq'::regclass);


--
-- Name: newspaper_company id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company ALTER COLUMN id SET DEFAULT nextval('public.newspaper_company_id_seq'::regclass);


--
-- Name: confirm_article confirm_article_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_article
    ADD CONSTRAINT confirm_article_pkey PRIMARY KEY (id);


--
-- Name: confirm_pdf confirm_pdf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_pdf
    ADD CONSTRAINT confirm_pdf_pkey PRIMARY KEY (id);


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
    ADD CONSTRAINT unique_author UNIQUE (author);


--
-- Name: daily_newspaper unique_author_date; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper
    ADD CONSTRAINT unique_author_date UNIQUE (author, publish_date);


--
-- Name: cognito_user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cognito_user
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: daily_newspaper_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX daily_newspaper_timestamp_idx ON public.daily_newspaper USING btree ("timestamp");


--
-- Name: hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hash ON public.layoutparser_log USING btree (hash);


--
-- Name: hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hash_index ON public.result USING btree (hash);


--
-- Name: pdf_daily_newspaper_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pdf_daily_newspaper_id_idx ON public.pdf USING btree (daily_newspaper_id);


--
-- Name: pdf_page_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pdf_page_idx ON public.pdf USING btree (page);


--
-- Name: reg_dt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reg_dt ON public.layoutparser_log USING btree (reg_dt);


--
-- Name: unique_plantym_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_plantym_user_id ON public.cognito_user USING btree (plantym_user_id);


--
-- Name: pdf update_ab_changetimestamp; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ab_changetimestamp BEFORE UPDATE ON public.pdf FOR EACH ROW EXECUTE FUNCTION public.update_changetimestamp_column();


--
-- Name: confirm_article confirm_article_confrim_pdf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_article
    ADD CONSTRAINT confirm_article_confrim_pdf_id_fkey FOREIGN KEY (confirm_pdf_id) REFERENCES public.confirm_pdf(id);


--
-- Name: confirm_article confirm_article_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_article
    ADD CONSTRAINT confirm_article_hash_fkey FOREIGN KEY (hash) REFERENCES public.pdf(hash) ON DELETE CASCADE;


--
-- Name: confirm_article confirm_article_user_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_article
    ADD CONSTRAINT confirm_article_user_id_fkey1 FOREIGN KEY (user_id) REFERENCES public.cognito_user(id);


--
-- Name: confirm_pdf confirm_pdf_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_pdf
    ADD CONSTRAINT confirm_pdf_hash_fkey FOREIGN KEY (hash) REFERENCES public.pdf(hash) ON DELETE CASCADE;


--
-- Name: confirm_pdf confirm_pdf_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.confirm_pdf
    ADD CONSTRAINT confirm_pdf_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.cognito_user(id);


--
-- Name: daily_newspaper daily_newspaper_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_newspaper
    ADD CONSTRAINT daily_newspaper_author_fkey FOREIGN KEY (author) REFERENCES public.newspaper_company(id) ON DELETE CASCADE;


--
-- Name: layoutparser_log layoutparser_log_hash_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layoutparser_log
    ADD CONSTRAINT layoutparser_log_hash_fkey FOREIGN KEY (hash) REFERENCES public.pdf(hash) ON UPDATE CASCADE ON DELETE CASCADE;


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

