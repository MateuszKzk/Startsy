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

--
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO postgres;

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
-- Name: conversation_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversation_participants (
    conversation_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.conversation_participants OWNER TO postgres;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.conversations_id_seq OWNER TO postgres;

--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    conversation_id integer,
    sender_id integer,
    content text NOT NULL,
    sent_at timestamp without time zone DEFAULT now(),
    read_at timestamp without time zone
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    color character varying(7) DEFAULT '#ffffff'::character varying,
    contacts text
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
-- Name: user_connections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_connections (
    id integer NOT NULL,
    user_id integer NOT NULL,
    connection_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_connections OWNER TO postgres;

--
-- Name: user_connections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_connections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_connections_id_seq OWNER TO postgres;

--
-- Name: user_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_connections_id_seq OWNED BY public.user_connections.id;


--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_settings (
    user_id integer NOT NULL,
    dark_mode boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_settings OWNER TO postgres;

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
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


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
-- Name: user_connections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections ALTER COLUMN id SET DEFAULT nextval('public.user_connections_id_seq'::regclass);


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
-- Data for Name: conversation_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversation_participants (conversation_id, user_id) FROM stdin;
6	2
6	8
7	2
7	4
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (id, created_at, updated_at) FROM stdin;
1	2025-05-29 14:01:17.998606	2025-05-29 14:01:17.998606
2	2025-05-29 14:07:50.39314	2025-05-29 14:07:50.39314
3	2025-05-29 14:08:10.053288	2025-05-29 14:08:10.053288
4	2025-05-29 14:14:30.174688	2025-05-29 14:14:30.174688
5	2025-05-29 14:15:17.402139	2025-05-29 14:15:17.402139
7	2025-05-29 14:59:12.545985	2025-05-29 14:59:12.545985
6	2025-05-29 14:58:39.435316	2025-05-29 23:07:12.643537
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, conversation_id, sender_id, content, sent_at, read_at) FROM stdin;
1	6	2	hey	2025-05-29 14:59:25.853581	2025-05-29 15:01:38.971488
2	6	8	zo wassup\n	2025-05-29 15:01:43.383582	2025-05-29 15:02:15.858508
3	6	2	servas bruda\n	2025-05-29 22:00:35.306152	2025-05-29 22:01:01.054172
4	6	8	yo was geeeeht\n	2025-05-29 22:01:07.78855	2025-05-29 23:15:20.227696
5	6	8	hey\n]	2025-05-29 22:07:39.665498	2025-05-29 23:15:20.227696
6	6	8	wassup\n	2025-05-29 22:07:43.132008	2025-05-29 23:15:20.227696
7	6	8	myg\n	2025-05-29 22:07:43.945513	2025-05-29 23:15:20.227696
8	6	8	my g\n	2025-05-29 22:07:45.698422	2025-05-29 23:15:20.227696
9	6	8	yo wassup	2025-05-29 23:00:13.176377	2025-05-29 23:15:20.227696
10	6	8	hey	2025-05-29 23:00:45.228703	2025-05-29 23:15:20.227696
11	6	8	123	2025-05-29 23:03:13.994105	2025-05-29 23:15:20.227696
12	6	8	123	2025-05-29 23:03:35.168286	2025-05-29 23:15:20.227696
13	6	8	123	2025-05-29 23:06:28.373349	2025-05-29 23:15:20.227696
14	6	8	123	2025-05-29 23:07:12.643537	2025-05-29 23:15:20.227696
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
106	2	2025-04-15 01:17:41.99953
92	2	2025-04-15 01:17:44.741909
94	2	2025-04-15 01:17:46.948456
111	2	2025-04-15 01:17:48.925109
111	7	2025-04-15 16:14:42.545205
92	7	2025-04-15 16:14:50.185715
110	2	2025-05-08 17:24:25.38302
\.


--
-- Data for Name: startups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.startups (id, founder_id, name, description, required_skills, created_at, color, contacts) FROM stdin;
91	2	ByteCraft	AI-powered development tools for modern teams	1,3,5,7	2024-01-15 09:30:00	#e3f2fd	[{"type":"email","value":"contact@bytecraft.io"},{"type":"linkedin","value":"bytecraft"}]
92	2	NeuroSync	Brain-computer interface technology	2,4,6,8	2024-02-20 14:15:00	#fce4ec	[{"type":"email","value":"info@neurosync.ai"},{"type":"twitter","value":"neurosync_ai"}]
93	2	QuantumLeap	Quantum computing solutions for businesses	9,10,11,12	2024-03-05 11:00:00	#e8f5e9	[{"type":"email","value":"hello@quantumleap.tech"}]
94	2	GreenHarvest	Sustainable agriculture technology	13,14,15	2023-11-10 08:45:00	#c8e6c9	[{"type":"email","value":"contact@greenharvest.com"}]
95	2	MediScan	AI-powered medical diagnostics	16,17,18	2023-12-05 13:20:00	#ffebee	[{"type":"email","value":"support@mediscan.ai"},{"type":"phone","value":"+1234567890"}]
96	2	EduFuture	Personalized learning platforms	19,20,21	2024-01-22 10:10:00	#bbdefb	[{"type":"email","value":"info@edufuture.org"}]
97	2	Finova	Next-gen financial analytics	22,23,24	2024-02-18 16:30:00	#fff9c4	[{"type":"email","value":"hello@finova.io"},{"type":"linkedin","value":"finova-io"}]
98	2	SafeRoute	AI-driven navigation safety	25,26,1	2024-03-12 09:15:00	#ffccbc	[{"type":"email","value":"contact@saferoute.app"}]
99	2	CleanAir	Urban air purification systems	2,3,4	2023-10-30 14:50:00	#d1c4e9	[{"type":"email","value":"info@cleanair.tech"}]
100	2	FoodPrint	Sustainable food tracking	5,6,7	2023-11-28 11:25:00	#b2dfdb	[{"type":"email","value":"support@foodprint.app"}]
101	2	CodeHive	Collaborative coding environment	8,9,10	2024-01-08 15:40:00	#f8bbd0	[{"type":"email","value":"team@codehive.dev"},{"type":"discord","value":"codehive"}]
102	2	DataForge	Big data processing tools	11,12,13	2024-02-14 10:05:00	#c5cae9	[{"type":"email","value":"info@dataforge.io"}]
103	2	HealthTrack	Wearable health monitors	14,15,16	2024-03-08 13:55:00	#d7ccc8	[{"type":"email","value":"contact@healthtrack.tech"}]
104	2	EcoCharge	Renewable energy charging	17,18,19	2023-12-20 08:20:00	#f5f5f5	[{"type":"email","value":"hello@ecocharge.green"}]
105	2	VRGenius	Virtual reality education	20,21,22	2024-01-30 14:10:00	#e1bee7	[{"type":"email","value":"support@vrgenius.com"}]
106	2	AgriTech	Farm automation solutions	1,2,3	2024-03-25 09:45:00	#b3e5fc	[{"type":"email","value":"contact@agritech.farm"}]
107	2	LegalBot	AI legal assistant	4,5,6	2024-04-01 11:30:00	#ffcdd2	[{"type":"email","value":"info@legalbot.ai"}]
108	2	MindMeld	Collaborative brainstorming tools	7,8,9	2024-04-05 16:20:00	#dcedc8	[{"type":"email","value":"hello@mindmeld.team"}]
109	2	TradeWind	Global trade analytics	10,11,12	2024-04-10 13:15:00	#f0f4c3	[{"type":"email","value":"support@tradewind.io"}]
110	2	UrbanGrow	Vertical farming systems	13,14,15	2024-04-15 10:00:00	#ffcc80	[{"type":"email","value":"contact@urbangrow.tech"}]
111	2	TechFert	Smart Fertilizer Technology	28,80,59,55	2024-01-15 09:30:00	#e3f2fd	[{"type":"email","value":"contact@bytecraft.io"},{"type":"linkedin","value":"bytecraft"}]
\.


--
-- Data for Name: user_connections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_connections (id, user_id, connection_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_settings (user_id, dark_mode, created_at, updated_at) FROM stdin;
1	t	2025-04-10 17:36:11.87293+02	2025-04-10 17:36:11.87293+02
4	f	2025-04-10 18:06:49.265601+02	2025-04-10 18:06:49.265601+02
5	f	2025-04-10 21:37:11.066184+02	2025-04-10 21:37:11.066184+02
6	f	2025-04-10 22:34:31.881925+02	2025-04-10 22:34:31.881925+02
8	t	2025-05-27 19:47:39.143684+02	2025-05-29 23:15:07.934479+02
2	t	2025-04-10 21:44:09.663104+02	2025-05-29 23:26:02.313833+02
7	t	2025-04-15 16:14:12.716948+02	2025-05-27 19:47:45.044077+02
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password_hash, role, full_name, created_at) FROM stdin;
1	MatiK	$2b$10$0mp2UTNEX9lQcjlBfjaBUuXtnHcsOnsXSxnSPvwUDU4ifhgF8gWOS	Gründer	Mateusz Kuzniak	2025-04-08 18:55:49.142591
2	kevde	$2b$10$HAZBj0trHp5bIAhZATpr6.a0/tNjB2oxtu/STofqDUjqUTHBgY7CO	Mitstreiter	Kevin Deimel	2025-04-08 20:37:38.002001
3	1234	$2b$10$DImC49CKBf4srlnHrKh/aemz8D/5OzkbwS.6qf7/I59nFQGaMvdIi	Mitstreiter	matik	2025-04-10 17:59:28.162402
4	test1	$2b$10$g85DEYKm85xuHUBc6lyaYewDdO47aOfWCXoShX2bpUdPmaHovIRba	Mitstreiter	876867876	2025-04-10 18:06:49.26456
5	34	$2b$10$znlYl0ifPOLE9QqWIVH/YekFQER7ARQxDm9Ue7V.rzyWSpUXNrU6i	Mitstreiter	534	2025-04-10 21:37:11.064211
6	test123	$2b$10$W9JaZ8XlYQUs7U3ppbkMcux3V.QFp983BxuSjU.sPxD2u48D2RLk2	Mitstreiter	test test	2025-04-10 22:34:31.880959
7	matik	$2b$10$aCPDfyOCtKzNT.3JGgixJO2Ce/WxGBcRiFsNoKqsUzAZQ2byZxFi2	Mitstreiter	Mateusz Kuzniak	2025-04-15 16:14:12.714641
8	matik1	$2b$10$lDxq/3sqkoxU6kXw9bYPU.RhSktePEWf7nRxwTGcyKXHUlgpGkDRK	Mitstreiter	dupa dupa	2025-05-27 19:47:39.139108
\.


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.applications_id_seq', 1, false);


--
-- Name: conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conversations_id_seq', 7, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 14, true);


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

SELECT pg_catalog.setval('public.startups_id_seq', 124, true);


--
-- Name: user_connections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_connections_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: conversation_participants conversation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_pkey PRIMARY KEY (conversation_id, user_id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


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
-- Name: user_connections user_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_pkey PRIMARY KEY (id);


--
-- Name: user_connections user_connections_user_id_connection_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_user_id_connection_id_key UNIQUE (user_id, connection_id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (user_id);


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
-- Name: idx_messages_conversation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_conversation ON public.messages USING btree (conversation_id);


--
-- Name: idx_messages_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_sender ON public.messages USING btree (sender_id);


--
-- Name: idx_startup_members_startup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_startup_members_startup ON public.startup_members USING btree (startup_id);


--
-- Name: idx_startup_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_startup_members_user ON public.startup_members USING btree (user_id);


--
-- Name: idx_user_connections_connection; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_connections_connection ON public.user_connections USING btree (connection_id);


--
-- Name: idx_user_connections_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_connections_user ON public.user_connections USING btree (user_id);


--
-- Name: user_settings update_user_settings_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_settings_timestamp BEFORE UPDATE ON public.user_settings FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


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
-- Name: conversation_participants conversation_participants_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: conversation_participants conversation_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE SET NULL;


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
-- Name: user_connections user_connections_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_connection_id_fkey FOREIGN KEY (connection_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_connections user_connections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_settings user_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

