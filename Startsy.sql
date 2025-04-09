--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applications (
    id integer NOT NULL,
    user_id integer,
    startup_id integer,
    message text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'Pending'::character varying,
    CONSTRAINT applications_status_check CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Accepted'::character varying, 'Rejected'::character varying])::text[])))
);


ALTER TABLE public.applications OWNER TO postgres;

--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.applications_id_seq OWNER TO postgres;

--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    sender_id integer,
    receiver_id integer,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_read boolean DEFAULT false
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    message text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_read boolean DEFAULT false
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    category character varying(50)
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skills_id_seq OWNER TO postgres;

--
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;


--
-- Name: startup_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.startup_members (
    startup_id integer NOT NULL,
    user_id integer NOT NULL,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.startup_members OWNER TO postgres;

--
-- Name: startups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.startups (
    id integer NOT NULL,
    founder_id integer,
    name character varying(100) NOT NULL,
    description text NOT NULL,
    required_skills text NOT NULL,
    contact_info character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    color character varying(7) DEFAULT '#ffffff'::character varying
);


ALTER TABLE public.startups OWNER TO postgres;

--
-- Name: startups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.startups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.startups_id_seq OWNER TO postgres;

--
-- Name: startups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.startups_id_seq OWNED BY public.startups.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash text NOT NULL,
    role character varying(20) NOT NULL,
    full_name character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    darkmode boolean DEFAULT false,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['Gründer'::character varying, 'Mitstreiter'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: skills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);


--
-- Name: startups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startups ALTER COLUMN id SET DEFAULT nextval('public.startups_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applications (id, user_id, startup_id, message, created_at, status) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, sender_id, receiver_id, content, created_at, is_read) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, message, created_at, is_read) FROM stdin;
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (id, name, category) FROM stdin;
1	HTML	Web Development
2	CSS	Web Development
3	JavaScript	Web Development
4	TypeScript	Web Development
5	React	Web Development
6	Vue.js	Web Development
7	Angular	Web Development
8	Svelte	Web Development
9	Node.js	Web Development
10	Express.js	Web Development
11	Django	Web Development
12	Flask	Web Development
13	Ruby on Rails	Web Development
14	Laravel	Web Development
15	PHP	Web Development
16	ASP.NET	Web Development
17	GraphQL	Web Development
18	REST APIs	Web Development
19	WebSockets	Web Development
20	Webpack	Web Development
21	Vite	Web Development
22	Bootstrap	Web Development
23	Tailwind CSS	Web Development
24	SASS/SCSS	Web Development
25	jQuery	Web Development
26	Python	Backend
27	Java	Backend
28	C#	Backend
29	Go (Golang)	Backend
30	Rust	Backend
31	Kotlin	Backend
32	SQL	Database
33	PostgreSQL	Database
34	MySQL	Database
35	MongoDB	Database
36	Redis	Database
37	Firebase	Database
38	Supabase	Database
39	Prisma	Database
40	Docker	DevOps
41	Kubernetes	DevOps
42	AWS	DevOps
43	Azure	DevOps
44	Google Cloud	DevOps
45	CI/CD	DevOps
46	NGINX	DevOps
47	Apache	DevOps
48	Microservices	Backend
49	Serverless	Backend
50	Spring Boot	Backend
51	Swift	Mobile
52	Kotlin (Android)	Mobile
53	Flutter	Mobile
54	React Native	Mobile
55	Ionic	Mobile
56	Xamarin	Mobile
57	Android SDK	Mobile
58	iOS Development	Mobile
59	Python (Data Science)	Data Science
60	R	Data Science
61	TensorFlow	AI/ML
62	PyTorch	AI/ML
63	Pandas	Data Science
64	NumPy	Data Science
65	Scikit-learn	AI/ML
66	OpenCV	AI/ML
67	NLP	AI/ML
68	Data Visualization	Data Science
69	Big Data	Data Science
70	Hadoop	Data Science
71	Spark	Data Science
72	Tableau	Data Science
73	Power BI	Data Science
74	Linux	Systems
75	Bash/Shell	Systems
76	Git	Version Control
77	Blockchain	Emerging Tech
78	Solidity	Emerging Tech
79	Cybersecurity	Security
80	Ethical Hacking	Security
81	Quantum Computing	Emerging Tech
82	IoT	Embedded Systems
83	Arduino	Embedded Systems
84	Raspberry Pi	Embedded Systems
85	Unity	Game Dev
86	Unreal Engine	Game Dev
87	C++	Game Dev
88	C# (Game Dev)	Game Dev
89	OpenGL	Game Dev
90	DirectX	Game Dev
91	Godot	Game Dev
92	Game Design	Game Dev
93	Blender	Game Dev
94	3D Modeling	Game Dev
\.


--
-- Data for Name: startup_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startup_members (startup_id, user_id, joined_at) FROM stdin;
51	2	2025-04-09 21:42:35.31358
\.


--
-- Data for Name: startups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startups (id, founder_id, name, description, required_skills, contact_info, created_at, color) FROM stdin;
51	2			{}		2025-04-09 21:42:35.312787	#e1bee7
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password_hash, role, full_name, created_at, darkmode) FROM stdin;
1	MatiK	$2b$10$0mp2UTNEX9lQcjlBfjaBUuXtnHcsOnsXSxnSPvwUDU4ifhgF8gWOS	Gründer	Mateusz Kuzniak	2025-04-08 18:55:49.142591	f
2	kevde	$2b$10$HAZBj0trHp5bIAhZATpr6.a0/tNjB2oxtu/STofqDUjqUTHBgY7CO	Mitstreiter	Kevin Deimel	2025-04-08 20:37:38.002001	f
\.


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.applications_id_seq', 1, false);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skills_id_seq', 94, true);


--
-- Name: startups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.startups_id_seq', 51, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: startup_members startup_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_members
    ADD CONSTRAINT startup_members_pkey PRIMARY KEY (startup_id, user_id);


--
-- Name: startups startups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startups
    ADD CONSTRAINT startups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_startup_members_startup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_startup_members_startup ON public.startup_members USING btree (startup_id);


--
-- Name: idx_startup_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_startup_members_user ON public.startup_members USING btree (user_id);


--
-- Name: applications applications_startup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_startup_id_fkey FOREIGN KEY (startup_id) REFERENCES public.startups(id) ON DELETE CASCADE;


--
-- Name: applications applications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: startup_members startup_members_startup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_members
    ADD CONSTRAINT startup_members_startup_id_fkey FOREIGN KEY (startup_id) REFERENCES public.startups(id) ON DELETE CASCADE;


--
-- Name: startup_members startup_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startup_members
    ADD CONSTRAINT startup_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: startups startups_founder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.startups
    ADD CONSTRAINT startups_founder_id_fkey FOREIGN KEY (founder_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

