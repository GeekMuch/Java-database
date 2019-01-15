--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: t_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION t_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN 
  IF ((SELECT gpu_on_board FROM mainboard WHERE NEW.mainboard = mainboard.id) IS FALSE AND 
  (NEW.gfx IS NULL)) THEN   
    RAISE EXCEPTION 'NO grafics-card';
     END IF;
  IF ((SELECT socket FROM cpu WHERE NEW.cpu = cpu.id) != 
    (SELECT cpu_socket FROM mainboard WHERE NEW.mainboard = mainboard.id)) THEN
    RAISE EXCEPTION 'NO matching cpu socket';
  END IF; 
  IF ((SELECT ram_type FROM mainboard WHERE NEW.mainboard = mainboard.id) != 
    (SELECT ram_type FROM ram WHERE NEW.ram = ram.id)) THEN
    RAISE EXCEPTION 'NO matching RAM type';
  END IF; 
    IF ((SELECT formfactor_mb FROM mainboard WHERE NEW.mainboard = mainboard.id) != 
    (SELECT formfactor_case FROM cabine WHERE NEW.cabine = cabine.id)) THEN
    RAISE EXCEPTION 'NO matching formfactor';
  END IF; 
  RETURN NEW; 
END;
$$;


ALTER FUNCTION public.t_check() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cabine; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cabine (
    id integer NOT NULL,
    formfactor_case character varying NOT NULL
);


ALTER TABLE cabine OWNER TO postgres;

--
-- Name: cabine_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cabine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cabine_id_seq OWNER TO postgres;

--
-- Name: cabine_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cabine_id_seq OWNED BY cabine.id;


--
-- Name: component; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE component (
    id integer NOT NULL,
    name character varying NOT NULL,
    kind character varying NOT NULL,
    price numeric NOT NULL
);


ALTER TABLE component OWNER TO postgres;

--
-- Name: cabine_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW cabine_view AS
 SELECT cabine.id,
    component.name,
    component.kind,
    component.price,
    cabine.formfactor_case
   FROM (cabine
     JOIN component USING (id));


ALTER TABLE cabine_view OWNER TO postgres;

--
-- Name: component_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE component_id_seq OWNER TO postgres;

--
-- Name: component_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE component_id_seq OWNED BY component.id;


--
-- Name: computer_system; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE computer_system (
    cs_id integer NOT NULL,
    name character varying NOT NULL,
    kind character varying NOT NULL,
    cpu numeric NOT NULL,
    mainboard numeric NOT NULL,
    ram numeric NOT NULL,
    cabine numeric NOT NULL,
    gfx numeric
);


ALTER TABLE computer_system OWNER TO postgres;

--
-- Name: computer_system_cs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE computer_system_cs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE computer_system_cs_id_seq OWNER TO postgres;

--
-- Name: computer_system_cs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE computer_system_cs_id_seq OWNED BY computer_system.cs_id;


--
-- Name: stock; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stock (
    id integer NOT NULL,
    current_stock numeric NOT NULL,
    preferred_amount numeric NOT NULL,
    minimum_amount numeric NOT NULL
);


ALTER TABLE stock OWNER TO postgres;

--
-- Name: computer_system_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW computer_system_view AS
 SELECT computer_system.cs_id,
    computer_system.name,
    computer_system.kind,
    ( SELECT component.name
           FROM component
          WHERE ((component.id)::numeric = computer_system.cpu)) AS cpu,
    ( SELECT component.name
           FROM component
          WHERE ((component.id)::numeric = computer_system.mainboard)) AS mainboard,
    ( SELECT component.name
           FROM component
          WHERE ((component.id)::numeric = computer_system.ram)) AS ram,
    ( SELECT component.name
           FROM component
          WHERE ((component.id)::numeric = computer_system.cabine)) AS cabine,
    ( SELECT component.name
           FROM component
          WHERE ((component.id)::numeric = computer_system.gfx)) AS gpu,
    ( SELECT sum(component.price) AS sum
           FROM component
          WHERE ((((((component.id)::numeric = computer_system.cpu) OR ((component.id)::numeric = computer_system.ram)) OR ((component.id)::numeric = computer_system.mainboard)) OR ((component.id)::numeric = computer_system.cabine)) OR ((component.id)::numeric = computer_system.gfx))) AS price,
    ( SELECT min(stock.current_stock) AS min
           FROM stock
          WHERE ((((((stock.id)::numeric = computer_system.cpu) OR ((stock.id)::numeric = computer_system.mainboard)) OR ((stock.id)::numeric = computer_system.ram)) OR ((stock.id)::numeric = computer_system.cabine)) OR ((stock.id)::numeric = computer_system.gfx))) AS current_stock
   FROM computer_system;


ALTER TABLE computer_system_view OWNER TO postgres;

--
-- Name: cpu; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cpu (
    id integer NOT NULL,
    socket character varying NOT NULL,
    bus_speed_cpu integer NOT NULL
);


ALTER TABLE cpu OWNER TO postgres;

--
-- Name: cpu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cpu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cpu_id_seq OWNER TO postgres;

--
-- Name: cpu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE cpu_id_seq OWNED BY cpu.id;


--
-- Name: cpu_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW cpu_view AS
 SELECT cpu.id,
    component.name,
    component.kind,
    component.price,
    cpu.socket,
    cpu.bus_speed_cpu
   FROM (cpu
     JOIN component USING (id));


ALTER TABLE cpu_view OWNER TO postgres;

--
-- Name: graphics_card; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE graphics_card (
    id integer NOT NULL,
    bus_speed_gfx numeric NOT NULL
);


ALTER TABLE graphics_card OWNER TO postgres;

--
-- Name: gfx_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW gfx_view AS
 SELECT graphics_card.id,
    component.name,
    component.kind,
    component.price,
    graphics_card.bus_speed_gfx
   FROM (graphics_card
     JOIN component USING (id));


ALTER TABLE gfx_view OWNER TO postgres;

--
-- Name: graphics_card_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE graphics_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE graphics_card_id_seq OWNER TO postgres;

--
-- Name: graphics_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE graphics_card_id_seq OWNED BY graphics_card.id;


--
-- Name: mainboard; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mainboard (
    id integer NOT NULL,
    cpu_socket character varying NOT NULL,
    ram_type character varying NOT NULL,
    gpu_on_board boolean,
    formfactor_mb character varying NOT NULL
);


ALTER TABLE mainboard OWNER TO postgres;

--
-- Name: mainboard_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE mainboard_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mainboard_id_seq OWNER TO postgres;

--
-- Name: mainboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE mainboard_id_seq OWNED BY mainboard.id;


--
-- Name: mb_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW mb_view AS
 SELECT mainboard.id,
    component.name,
    component.kind,
    component.price,
    mainboard.cpu_socket,
    mainboard.ram_type,
    mainboard.gpu_on_board,
    mainboard.formfactor_mb
   FROM (mainboard
     JOIN component USING (id));


ALTER TABLE mb_view OWNER TO postgres;

--
-- Name: ram; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ram (
    id integer NOT NULL,
    ram_type character varying NOT NULL,
    bus_speed_ram integer NOT NULL
);


ALTER TABLE ram OWNER TO postgres;

--
-- Name: ram_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE ram_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ram_id_seq OWNER TO postgres;

--
-- Name: ram_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE ram_id_seq OWNED BY ram.id;


--
-- Name: ram_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW ram_view AS
 SELECT ram.id,
    component.name,
    component.kind,
    component.price,
    ram.ram_type,
    ram.bus_speed_ram
   FROM (ram
     JOIN component USING (id));


ALTER TABLE ram_view OWNER TO postgres;

--
-- Name: stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stock_id_seq OWNER TO postgres;

--
-- Name: stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stock_id_seq OWNED BY stock.id;


--
-- Name: stock_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW stock_view AS
 SELECT stock.id,
    component.name,
    component.kind,
    component.price,
    stock.current_stock,
    stock.preferred_amount,
    stock.minimum_amount
   FROM (stock
     JOIN component USING (id));


ALTER TABLE stock_view OWNER TO postgres;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cabine ALTER COLUMN id SET DEFAULT nextval('cabine_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY component ALTER COLUMN id SET DEFAULT nextval('component_id_seq'::regclass);


--
-- Name: cs_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY computer_system ALTER COLUMN cs_id SET DEFAULT nextval('computer_system_cs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cpu ALTER COLUMN id SET DEFAULT nextval('cpu_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY graphics_card ALTER COLUMN id SET DEFAULT nextval('graphics_card_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mainboard ALTER COLUMN id SET DEFAULT nextval('mainboard_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ram ALTER COLUMN id SET DEFAULT nextval('ram_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stock ALTER COLUMN id SET DEFAULT nextval('stock_id_seq'::regclass);


--
-- Data for Name: cabine; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cabine (id, formfactor_case) FROM stdin;
21	ATX
22	ATX
23	mini-ITX
24	ATX
25	EATX
26	ATX
\.


--
-- Name: cabine_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('cabine_id_seq', 1, false);


--
-- Data for Name: component; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY component (id, name, kind, price) FROM stdin;
1	Intel - Core i5 6600K	cpu	2899
2	Intel - Pentium G3250	cpu	699
3	AMD - Pentium G3250	cpu	1599
4	AMD - Athlon X4 840	cpu	699
5	Intel - Core i3-6100	cpu	1399
6	Intel - Core i7-5960X Extreme	cpu	11299
7	Intel - Core i5-6400	cpu	1999
8	ASUS - Z170-P	mainboard	1399
9	Gigabyte - GA-Z170-Gaming K3	mainboard	1299
10	ASUS - H81I-PLUS	mainboard	799
11	ASUS - M5A97 R2.0	mainboard	999
12	MSI - A68HM GRENADE	mainboard	599
13	ASUS - B150M-A	mainboard	899
14	MSI - X99A GAMING 9 ACK	mainboard	4699
15	ASUS - B150M Pro Gaming	mainboard	1199
16	Kingston - Value 2133MHz	ram	399
17	Kingston - HyperX Fury 2133MHz	ram	499
18	Kingston - HyperX Fury 1866MHz	ram	499
19	Kingston - HyperX Fury 2100MHz	ram	1599
20	Crucial - 2133MHz	ram	399
21	Corsair - Carbide 330R Blackout Edition	case	999
22	Corsair - Carbide 200R	case	699
23	Cooler Master - Elite 120	case	599
24	In Win - 703	case	799
25	Corsair - Graphite 760T	case	1799
26	Corsair - Carbide SPEC-03	case	799
27	ASUS - GeForce GTX 970	gfx	3399
28	Gainward - GeForce GTX 960	gfx	2099
29	XFX - Radeon R9 380	gfx	1799
30	XFX - Radeon R7 360	gfx	1199
31	MSI - GeForce GTX TITAN X	gfx	10899
32	ASUS - TURBO GeForce GTX960	gfx	2299
\.


--
-- Name: component_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('component_id_seq', 32, true);


--
-- Data for Name: computer_system; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY computer_system (cs_id, name, kind, cpu, mainboard, ram, cabine, gfx) FROM stdin;
1	Super awesome computer	computer system	1	8	16	21	27
2	Super noob computer	computer system	6	14	19	25	31
3	Super bitcoin farm computer	computer system	2	10	18	23	28
4	Super duper noober computer	computer system	7	9	20	24	\N
5	Super assjack computer	computer system	5	15	17	26	30
6	Super magnificant computer	computer system	5	8	16	21	29
7	Super moppet computer	computer system	4	12	18	22	30
8	Super cracker-hacker-firecracker computer	computer system	3	11	18	21	29
\.


--
-- Name: computer_system_cs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('computer_system_cs_id_seq', 8, true);


--
-- Data for Name: cpu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cpu (id, socket, bus_speed_cpu) FROM stdin;
1	LGA1151	3500
2	LGA1150	3200
3	AM3+	3500
4	FM2+	3100
5	LGA1151	3700
6	LGA2011-v3	3000
7	LGA1151	2700
\.


--
-- Name: cpu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('cpu_id_seq', 1, false);


--
-- Data for Name: graphics_card; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY graphics_card (id, bus_speed_gfx) FROM stdin;
27	3500
28	3200
29	3500
30	3100
31	4000
32	2133
\.


--
-- Name: graphics_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('graphics_card_id_seq', 1, false);


--
-- Data for Name: mainboard; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY mainboard (id, cpu_socket, ram_type, gpu_on_board, formfactor_mb) FROM stdin;
8	LGA1151	DDR4	t	ATX
9	LGA1151	DDR4	t	ATX
10	LGA1150	DDR3	t	mini-ITX
11	AM3+	DDR3	t	ATX
12	FM2+	DDR3	t	ATX
13	LGA1151	DDR4	t	ATX
14	LGA2011-v3	DDR4	t	EATX
15	LGA1151	DDR4	f	ATX
\.


--
-- Name: mainboard_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('mainboard_id_seq', 1, false);


--
-- Data for Name: ram; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ram (id, ram_type, bus_speed_ram) FROM stdin;
16	DDR4	8192
17	DDR4	8192
18	DDR3	8192
19	DDR4	32768
20	DDR4	8192
\.


--
-- Name: ram_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('ram_id_seq', 1, false);


--
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY stock (id, current_stock, preferred_amount, minimum_amount) FROM stdin;
1	100	150	50
2	100	150	50
3	100	150	50
4	100	150	50
5	100	150	50
6	100	150	50
7	100	150	50
8	100	150	50
9	100	150	50
10	100	150	50
11	100	150	50
12	100	150	50
13	100	150	50
14	100	150	50
15	100	150	50
16	100	150	50
17	100	150	50
18	100	150	50
19	100	150	50
20	100	150	50
21	100	150	50
22	100	150	50
23	100	150	50
24	100	150	50
25	100	150	50
26	100	150	50
27	100	150	50
28	100	150	50
29	100	150	50
30	100	150	50
31	100	150	50
32	100	150	50
\.


--
-- Name: stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('stock_id_seq', 32, true);


--
-- Name: component_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_pkey PRIMARY KEY (id);


--
-- Name: computer_system_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY computer_system
    ADD CONSTRAINT computer_system_pkey PRIMARY KEY (cs_id);


--
-- Name: stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id);


--
-- Name: cabine_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE cabine_insert_rule AS
    ON INSERT TO cabine_view DO INSTEAD ( INSERT INTO component (id, name, kind, price)
  VALUES (DEFAULT, new.name, 'case'::character varying, (round((new.price * 1.3), (-2)) - (1)::numeric));
 INSERT INTO cabine (id, formfactor_case)
  VALUES (( SELECT component.id
           FROM component
          WHERE ((component.name)::text = (new.name)::text)), new.formfactor_case);
);


--
-- Name: cpu_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE cpu_insert_rule AS
    ON INSERT TO cpu_view DO INSTEAD ( INSERT INTO component (id, name, kind, price)
  VALUES (DEFAULT, new.name, 'cpu'::character varying, (round((new.price * 1.3), (-2)) - (1)::numeric));
 INSERT INTO cpu (id, socket, bus_speed_cpu)
  VALUES (( SELECT component.id
           FROM component
          WHERE ((component.name)::text = (new.name)::text)), new.socket, new.bus_speed_cpu);
);


--
-- Name: gfx_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE gfx_insert_rule AS
    ON INSERT TO gfx_view DO INSTEAD ( INSERT INTO component (id, name, kind, price)
  VALUES (DEFAULT, new.name, 'gfx'::character varying, (round((new.price * 1.3), (-2)) - (1)::numeric));
 INSERT INTO graphics_card (id, bus_speed_gfx)
  VALUES (( SELECT component.id
           FROM component
          WHERE ((component.name)::text = (new.name)::text)), new.bus_speed_gfx);
);


--
-- Name: mb_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE mb_insert_rule AS
    ON INSERT TO mb_view DO INSTEAD ( INSERT INTO component (id, name, kind, price)
  VALUES (DEFAULT, new.name, 'mainboard'::character varying, (round((new.price * 1.3), (-2)) - (1)::numeric));
 INSERT INTO mainboard (id, cpu_socket, ram_type, gpu_on_board, formfactor_mb)
  VALUES (( SELECT component.id
           FROM component
          WHERE ((component.name)::text = (new.name)::text)), new.cpu_socket, new.ram_type, new.gpu_on_board, new.formfactor_mb);
);


--
-- Name: ram_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE ram_insert_rule AS
    ON INSERT TO ram_view DO INSTEAD ( INSERT INTO component (id, name, kind, price)
  VALUES (DEFAULT, new.name, 'ram'::character varying, (round((new.price * 1.3), (-2)) - (1)::numeric));
 INSERT INTO ram (id, ram_type, bus_speed_ram)
  VALUES (( SELECT component.id
           FROM component
          WHERE ((component.name)::text = (new.name)::text)), new.ram_type, new.bus_speed_ram);
);


--
-- Name: stock_insert_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE stock_insert_rule AS
    ON INSERT TO stock_view DO INSTEAD  INSERT INTO stock (id, current_stock, preferred_amount, minimum_amount)
  VALUES (DEFAULT, new.current_stock, new.preferred_amount, new.minimum_amount);


--
-- Name: t_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER t_check AFTER INSERT OR UPDATE ON computer_system FOR EACH ROW EXECUTE PROCEDURE t_check();


--
-- Name: cs_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY computer_system
    ADD CONSTRAINT cs_id_fkey FOREIGN KEY (cs_id) REFERENCES component(id);


--
-- Name: stock_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stock
    ADD CONSTRAINT stock_id_fkey FOREIGN KEY (id) REFERENCES component(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

