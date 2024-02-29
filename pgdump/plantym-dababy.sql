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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: article; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.article (
    id integer NOT NULL,
    "pageId" integer NOT NULL,
    title character(1) NOT NULL,
    "order" integer NOT NULL,
    category character(1) NOT NULL,
    verticles json NOT NULL,
    "lastModifiedAt" timestamp without time zone NOT NULL
);


--
-- Name: article_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.article_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: article_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.article_id_seq OWNED BY public.article.id;


--
-- Name: layout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layout (
    id integer NOT NULL,
    "articleId" integer NOT NULL,
    "order" integer NOT NULL,
    text character(1) NOT NULL,
    type character(1) NOT NULL,
    verticles json NOT NULL,
    "lastModifiedAt" timestamp without time zone NOT NULL
);


--
-- Name: layout_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.layout_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: layout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.layout_id_seq OWNED BY public.layout.id;


--
-- Name: newspaper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newspaper (
    id integer NOT NULL,
    "newspaperCompanyId" integer NOT NULL,
    "publishDate" timestamp without time zone NOT NULL,
    "uploadDate" timestamp without time zone NOT NULL,
    "uploadUser" integer NOT NULL,
    "lastInspectionUser" integer,
    "lastInspectionDate" timestamp without time zone,
    "isDeploy" boolean
);


--
-- Name: COLUMN newspaper.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper.id IS '신문 고유 아이디';


--
-- Name: COLUMN newspaper."newspaperCompanyId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."newspaperCompanyId" IS '신문사 고유 아이디';


--
-- Name: COLUMN newspaper."publishDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."publishDate" IS '신문 발행일';


--
-- Name: COLUMN newspaper."uploadDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."uploadDate" IS '신문 업로드일';


--
-- Name: COLUMN newspaper."uploadUser"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."uploadUser" IS '신문 파일 등록 유저';


--
-- Name: COLUMN newspaper."lastInspectionUser"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."lastInspectionUser" IS '최근 검수 유저';


--
-- Name: COLUMN newspaper."lastInspectionDate"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."lastInspectionDate" IS '최근 검수일';


--
-- Name: COLUMN newspaper."isDeploy"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper."isDeploy" IS '배포 여부';


--
-- Name: newspaper_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newspaper_company (
    id integer NOT NULL,
    name character(1) NOT NULL
);


--
-- Name: COLUMN newspaper_company.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper_company.id IS '신문사 고유 아이디';


--
-- Name: COLUMN newspaper_company.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.newspaper_company.name IS '신문사 이름';


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

ALTER SEQUENCE public.newspaper_id_seq OWNED BY public.newspaper.id;


--
-- Name: page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page (
    id integer NOT NULL,
    "newspaperId" integer NOT NULL,
    "pageNumber" integer NOT NULL,
    "isInspection" boolean NOT NULL,
    "isDeploy" boolean NOT NULL,
    "lastInspectionDate" timestamp without time zone NOT NULL,
    "lastInspectionUser" integer
);


--
-- Name: COLUMN page.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.page.id IS '페이지 고유 아이디';


--
-- Name: COLUMN page."newspaperId"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.page."newspaperId" IS '신문 고유 아이디';


--
-- Name: COLUMN page."pageNumber"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.page."pageNumber" IS '페이지 번호';


--
-- Name: COLUMN page."isInspection"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.page."isInspection" IS '검수 여부';


--
-- Name: COLUMN page."isDeploy"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.page."isDeploy" IS '배포 여부';


--
-- Name: page_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_id_seq OWNED BY public.page.id;


--
-- Name: article id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article ALTER COLUMN id SET DEFAULT nextval('public.article_id_seq'::regclass);


--
-- Name: layout id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout ALTER COLUMN id SET DEFAULT nextval('public.layout_id_seq'::regclass);


--
-- Name: newspaper id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper ALTER COLUMN id SET DEFAULT nextval('public.newspaper_id_seq'::regclass);


--
-- Name: newspaper_company id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company ALTER COLUMN id SET DEFAULT nextval('public.newspaper_company_id_seq'::regclass);


--
-- Name: page id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page ALTER COLUMN id SET DEFAULT nextval('public.page_id_seq'::regclass);


--
-- Name: article article_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article
    ADD CONSTRAINT article_pkey PRIMARY KEY (id);


--
-- Name: layout layout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout
    ADD CONSTRAINT layout_pkey PRIMARY KEY (id);


--
-- Name: newspaper_company newspaper_company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper_company
    ADD CONSTRAINT newspaper_company_pkey PRIMARY KEY (id);


--
-- Name: newspaper newspaper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper
    ADD CONSTRAINT newspaper_pkey PRIMARY KEY (id);


--
-- Name: page page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page
    ADD CONSTRAINT page_pkey PRIMARY KEY (id);


--
-- Name: article article_pageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.article
    ADD CONSTRAINT "article_pageId_fkey" FOREIGN KEY ("pageId") REFERENCES public.page(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: layout layout_articleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layout
    ADD CONSTRAINT "layout_articleId_fkey" FOREIGN KEY ("articleId") REFERENCES public.article(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: newspaper newspaper_newspaperCompanyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspaper
    ADD CONSTRAINT "newspaper_newspaperCompanyId_fkey" FOREIGN KEY ("newspaperCompanyId") REFERENCES public.newspaper_company(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: page page_newspaperId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page
    ADD CONSTRAINT "page_newspaperId_fkey" FOREIGN KEY ("newspaperId") REFERENCES public.newspaper(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

