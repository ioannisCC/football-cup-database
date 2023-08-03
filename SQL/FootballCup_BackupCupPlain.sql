--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.2

-- Started on 2023-06-29 12:41:35

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

DROP DATABASE "FootballCup";
--
-- TOC entry 3436 (class 1262 OID 16531)
-- Name: FootballCup; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "FootballCup" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE "FootballCup" OWNER TO postgres;

\connect "FootballCup"

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
-- TOC entry 229 (class 1255 OID 18879)
-- Name: check_match_schedule(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_match_schedule() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    previous_match_date DATE;
BEGIN
    -- Check if the home team has a match within 10 days before or after the current match
    SELECT date INTO previous_match_date
    FROM match_and_schedule
    WHERE (home_club = NEW.home_club OR visiting_club = NEW.home_club)
    AND date >= NEW.date - INTERVAL '10 days'
    AND date <= NEW.date + INTERVAL '10 days'
    AND id_ms != NEW.id_ms;
    
    IF previous_match_date IS NOT NULL THEN
        RAISE EXCEPTION 'A team has a match within 10 days before or after this match.';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_match_schedule() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 18877)
-- Name: check_player_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_player_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  player_count INTEGER;
BEGIN
  -- Get the count of rows for the current club name
  SELECT COUNT(*) INTO player_count
  FROM player
  WHERE name_cl = NEW.name_cl;

  -- Raise an exception if the row count exceeds the limit
  IF player_count >= 11 THEN
    RAISE EXCEPTION 'Maximum row limit reached for club: %', NEW.name_cl;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_player_count() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 18923)
-- Name: clubs_log_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.clubs_log_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO drop_category_club (name_cl, stadium, story, wins_home, wins_away, losses_home, losses_away, draws_home, draws_away)
    VALUES (OLD.name_cl, OLD.stadium, OLD.story, OLD.wins_home, OLD.wins_away, OLD.losses_home, OLD.losses_away, OLD.draws_home, OLD.draws_away);
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.clubs_log_function() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 214 (class 1259 OID 18750)
-- Name: club; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.club (
    name_cl character varying(30) NOT NULL,
    stadium character varying(50) NOT NULL,
    story character varying(1000) NOT NULL,
    wins_home integer NOT NULL,
    wins_away integer NOT NULL,
    losses_home integer NOT NULL,
    losses_away integer NOT NULL,
    draws_home integer NOT NULL,
    draws_away integer NOT NULL
);


ALTER TABLE public.club OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 18762)
-- Name: player; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player (
    id_p integer NOT NULL,
    name character varying(20) NOT NULL,
    surname character varying(20) NOT NULL,
    name_cl character varying(30) NOT NULL,
    "position" character varying(20) NOT NULL,
    cards_y integer NOT NULL,
    cards_r integer NOT NULL,
    goals integer NOT NULL,
    is_active boolean NOT NULL,
    CONSTRAINT name_charset CHECK ((((name)::text ~ '^[Α-Ωα-ωάέήίϊΐόύϋΰώ\-]+$'::text) AND ((surname)::text ~ '^[Α-Ωα-ωάέήίϊΐόύϋΰώ\-]+$'::text)))
);


ALTER TABLE public.player OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 18789)
-- Name: coach; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coach (
    is_coach boolean NOT NULL,
    name_cl_coach character varying(30) NOT NULL
)
INHERITS (public.player);


ALTER TABLE public.coach OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18911)
-- Name: drop_category_club; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drop_category_club (
    name_cl character varying(30) NOT NULL,
    stadium character varying(50) NOT NULL,
    story character varying(1000) NOT NULL,
    wins_home integer NOT NULL,
    wins_away integer NOT NULL,
    losses_home integer NOT NULL,
    losses_away integer NOT NULL,
    draws_home integer NOT NULL,
    draws_away integer NOT NULL,
    deleted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.drop_category_club OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 18835)
-- Name: match_and_corners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_and_corners (
    id_ms integer NOT NULL,
    corner boolean NOT NULL,
    "time" interval NOT NULL
);


ALTER TABLE public.match_and_corners OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 18845)
-- Name: match_and_player_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_and_player_cards (
    id_ms integer NOT NULL,
    cards_y boolean DEFAULT false NOT NULL,
    cards_r boolean DEFAULT false NOT NULL,
    id_player integer NOT NULL,
    "time" interval NOT NULL
);


ALTER TABLE public.match_and_player_cards OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 18820)
-- Name: match_and_player_goals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_and_player_goals (
    id_ms integer NOT NULL,
    penalty boolean NOT NULL,
    goals_s boolean NOT NULL,
    goals_c boolean NOT NULL,
    id_player integer,
    "time" interval NOT NULL
);


ALTER TABLE public.match_and_player_goals OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18862)
-- Name: match_and_player_time_played; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_and_player_time_played (
    id_ms integer NOT NULL,
    id_player integer NOT NULL,
    time_played interval NOT NULL
);


ALTER TABLE public.match_and_player_time_played OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 18802)
-- Name: match_and_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_and_schedule (
    id_ms integer NOT NULL,
    home_club character varying(30) NOT NULL,
    visiting_club character varying(30) NOT NULL,
    home_score integer NOT NULL,
    visiting_score integer NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.match_and_schedule OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 18801)
-- Name: match_and_schedule_id_ms_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.match_and_schedule_id_ms_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.match_and_schedule_id_ms_seq OWNER TO postgres;

--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 219
-- Name: match_and_schedule_id_ms_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.match_and_schedule_id_ms_seq OWNED BY public.match_and_schedule.id_ms;


--
-- TOC entry 217 (class 1259 OID 18774)
-- Name: player_club; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_club (
    id_p integer NOT NULL,
    name_cl character varying(30) NOT NULL
);


ALTER TABLE public.player_club OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 18761)
-- Name: player_id_p_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_id_p_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.player_id_p_seq OWNER TO postgres;

--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 215
-- Name: player_id_p_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_id_p_seq OWNED BY public.player.id_p;


--
-- TOC entry 226 (class 1259 OID 18930)
-- Name: schedule_match; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.schedule_match AS
 SELECT match_and_schedule.date,
    match_and_schedule.home_club,
    match_and_schedule.visiting_club,
    match_and_schedule.home_score,
    match_and_schedule.visiting_score,
    club.stadium,
    player.name,
    player.surname,
    player."position",
    player.name_cl,
    match_and_player_cards.cards_y,
    match_and_player_cards.cards_r,
    match_and_player_time_played.time_played,
    match_and_player_goals.goals_s,
    match_and_player_goals."time"
   FROM (((((public.match_and_schedule
     FULL JOIN public.club ON (((match_and_schedule.home_club)::text = (club.name_cl)::text)))
     FULL JOIN public.player ON ((((match_and_schedule.home_club)::text = (player.name_cl)::text) OR ((match_and_schedule.visiting_club)::text = (player.name_cl)::text))))
     LEFT JOIN public.match_and_player_cards ON (((player.id_p = match_and_player_cards.id_player) AND (match_and_schedule.id_ms = match_and_player_cards.id_ms))))
     FULL JOIN public.match_and_player_goals ON (((match_and_schedule.id_ms = match_and_player_goals.id_ms) AND (match_and_player_goals.id_player = player.id_p))))
     FULL JOIN public.match_and_player_time_played ON (((match_and_player_time_played.id_ms = match_and_schedule.id_ms) AND (match_and_player_time_played.id_player = player.id_p))))
  WHERE ((match_and_schedule.date = '2023-06-29'::date) AND (player.is_active = true));


ALTER TABLE public.schedule_match OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18935)
-- Name: season_matches; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.season_matches AS
 SELECT match_and_schedule.date,
    match_and_schedule.home_club,
    match_and_schedule.visiting_club,
    match_and_schedule.home_score,
    match_and_schedule.visiting_score,
    club.stadium
   FROM (public.match_and_schedule
     JOIN public.club ON (((match_and_schedule.home_club)::text = (club.name_cl)::text)))
  WHERE ((match_and_schedule.date >= '2023-04-01'::date) AND (match_and_schedule.date <= '2023-06-30'::date))
  ORDER BY match_and_schedule.date;


ALTER TABLE public.season_matches OWNER TO postgres;

--
-- TOC entry 3222 (class 2604 OID 18792)
-- Name: coach id_p; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach ALTER COLUMN id_p SET DEFAULT nextval('public.player_id_p_seq'::regclass);


--
-- TOC entry 3223 (class 2604 OID 18805)
-- Name: match_and_schedule id_ms; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_schedule ALTER COLUMN id_ms SET DEFAULT nextval('public.match_and_schedule_id_ms_seq'::regclass);


--
-- TOC entry 3221 (class 2604 OID 18765)
-- Name: player id_p; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player ALTER COLUMN id_p SET DEFAULT nextval('public.player_id_p_seq'::regclass);


--
-- TOC entry 3419 (class 0 OID 18750)
-- Dependencies: 214
-- Data for Name: club; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.club (name_cl, stadium, story, wins_home, wins_away, losses_home, losses_away, draws_home, draws_away) VALUES ('Olympiacos', 'Georgios Karaiskakis', 'Founded on 10 March 1925, Olympiacos is the most successful club in Greek football history,having won 47 League titles, 28 Cups (18 Doubles) and 4 Super Cups, all records. Τotalling 79 national trophies, Olympiacos is 9th in the world in total titles won by a football club', 5, 2, 0, 1, 1, 1);
INSERT INTO public.club (name_cl, stadium, story, wins_home, wins_away, losses_home, losses_away, draws_home, draws_away) VALUES ('Aek', 'OPAP Arena', 'The large Greek population of Constantinople, not unlike that of the other Ottoman urban centres, continued its athletic traditions in the form of numerous athletic clubs. Clubs such as Énosis Tatávlon (Ένωσις Ταταύλων) and Iraklís (Ηρακλής) from the Tatavla district, Mégas Aléxandros (Μέγας Αλέξανδρος) and Ermís (Ερμής) of Galata, and Olympiás (Ολυμπιάς) of Therapia existed to promote Hellenic athletic and cultural ideals. These were amongst a dozen Greek-backed clubs that dominated the sporting landscape of the city in the years preceding World War I.', 4, 2, 1, 1, 0, 2);
INSERT INTO public.club (name_cl, stadium, story, wins_home, wins_away, losses_home, losses_away, draws_home, draws_away) VALUES ('Panathinaikos', 'Apostolos Nikolaidis', 'Created in 1908 as "Podosfairikos Omilos Athinon" (Football Club of Athens) by Georgios Kalafatis,they play in Super League Greece, being one of the most successful clubs in Greek football and one of the three clubs which have never been relegated from the top division', 4, 0, 2, 1, 1, 2);


--
-- TOC entry 3423 (class 0 OID 18789)
-- Dependencies: 218
-- Data for Name: coach; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.coach (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active, is_coach, name_cl_coach) VALUES (1, 'Παναγιώτης', 'Ρέτσος', 'Olympiacos', 'Defender', 2, 0, 0, false, true, 'Olympiacos');
INSERT INTO public.coach (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active, is_coach, name_cl_coach) VALUES (15, 'Ρούμπεν', 'Πέρεθ', 'Panathinaikos', 'Midfielder', 0, 0, 12, false, true, 'Panathinaikos');


--
-- TOC entry 3430 (class 0 OID 18911)
-- Dependencies: 225
-- Data for Name: drop_category_club; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drop_category_club (name_cl, stadium, story, wins_home, wins_away, losses_home, losses_away, draws_home, draws_away, deleted_at) VALUES ('PP', 'Georgios Kis', 'Founded on 10 March 192Greek football history,having won 47 League titles, 28 Cups (18 Doubles) and 4 Super Cups, all records. Τotalling 79 national trophies, Olympiacos is 9th in the world in total titles won by a football club', 5, 2, 0, 1, 1, 1, '2023-06-24 13:28:53.627974');


--
-- TOC entry 3427 (class 0 OID 18835)
-- Dependencies: 222
-- Data for Name: match_and_corners; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (1, true, '10:42:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (1, true, '17:35:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (1, true, '60:55:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (2, true, '17:38:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (3, true, '68:39:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (5, true, '90:01:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (8, true, '48:47:00');
INSERT INTO public.match_and_corners (id_ms, corner, "time") VALUES (10, true, '89:15:00');


--
-- TOC entry 3428 (class 0 OID 18845)
-- Dependencies: 223
-- Data for Name: match_and_player_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.match_and_player_cards (id_ms, cards_y, cards_r, id_player, "time") VALUES (1, true, false, 2, '13:25:00');
INSERT INTO public.match_and_player_cards (id_ms, cards_y, cards_r, id_player, "time") VALUES (2, true, false, 3, '54:05:00');
INSERT INTO public.match_and_player_cards (id_ms, cards_y, cards_r, id_player, "time") VALUES (10, true, false, 11, '46:19:00');
INSERT INTO public.match_and_player_cards (id_ms, cards_y, cards_r, id_player, "time") VALUES (9, false, true, 11, '61:05:00');
INSERT INTO public.match_and_player_cards (id_ms, cards_y, cards_r, id_player, "time") VALUES (10, false, true, 12, '65:08:00');


--
-- TOC entry 3426 (class 0 OID 18820)
-- Dependencies: 221
-- Data for Name: match_and_player_goals; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (1, false, true, false, 2, '10:35:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (2, false, false, true, 3, '27:13:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (3, false, true, false, 7, '32:59:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (4, false, true, false, 8, '32:39:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (5, false, true, false, 11, '81:10:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (6, true, false, false, 12, '91:50:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (7, false, false, true, 9, '45:10:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (8, false, true, false, 12, '90:15:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (9, true, false, false, 13, '10:29:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (10, false, true, false, 14, '01:10:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (1, true, false, false, 2, '10:45:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (2, false, false, true, 3, '11:47:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (3, false, false, true, 7, '87:40:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (4, true, false, false, 8, '41:01:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (5, false, true, false, 12, '61:15:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (6, true, false, false, 12, '71:11:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (7, false, true, false, 8, '68:17:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (8, false, true, false, 13, '69:39:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (9, false, true, false, 13, '28:48:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (10, false, true, false, 14, '18:39:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (10, false, true, false, 3, '67:59:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (5, false, true, false, 4, '13:17:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (5, false, true, false, 3, '28:54:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (5, false, true, false, 4, '89:11:00');
INSERT INTO public.match_and_player_goals (id_ms, penalty, goals_s, goals_c, id_player, "time") VALUES (7, true, false, false, 14, '20:45:00');


--
-- TOC entry 3429 (class 0 OID 18862)
-- Dependencies: 224
-- Data for Name: match_and_player_time_played; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 2, '09:42:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 3, '83:27:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 4, '15:01:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 5, '98:58:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 7, '20:33:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 8, '52:09:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 9, '43:17:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (1, 10, '115:22:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 2, '34:11:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 3, '60:19:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 4, '23:40:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 5, '95:50:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 7, '09:08:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 8, '72:54:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 9, '30:47:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (2, 10, '86:38:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 7, '16:14:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 8, '53:56:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 9, '74:27:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 10, '39:05:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 11, '107:39:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 12, '29:46:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 13, '65:59:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (3, 14, '12:54:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 7, '45:32:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 8, '27:04:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 9, '91:15:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 10, '61:27:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 11, '102:58:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 12, '20:05:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 13, '58:37:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (4, 14, '34:41:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 2, '73:51:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 3, '16:24:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 4, '88:40:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 5, '54:16:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 11, '112:45:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 12, '41:18:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 13, '76:59:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (5, 14, '22:37:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 2, '39:57:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 3, '75:43:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 4, '48:26:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 5, '84:55:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 11, '33:12:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 12, '65:35:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 13, '21:48:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (6, 14, '52:57:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 7, '59:08:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 8, '32:40:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 9, '76:52:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 10, '45:09:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 11, '91:01:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 12, '18:14:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 13, '62:27:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (7, 14, '27:37:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 7, '20:02:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 8, '47:43:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 9, '88:22:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 10, '11:36:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 11, '105:49:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 12, '23:30:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 13, '54:58:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (8, 14, '30:19:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 7, '61:28:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 8, '28:04:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 9, '82:12:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 10, '17:32:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 11, '95:53:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 12, '37:14:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 13, '68:44:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (9, 14, '43:06:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 2, '94:05:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 3, '45:28:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 4, '116:07:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 5, '60:33:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 11, '14:50:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 12, '87:03:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 13, '28:16:00');
INSERT INTO public.match_and_player_time_played (id_ms, id_player, time_played) VALUES (10, 14, '75:22:00');


--
-- TOC entry 3425 (class 0 OID 18802)
-- Dependencies: 220
-- Data for Name: match_and_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (1, 'Olympiacos', 'Aek', 1, 0, '2023-02-15');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (2, 'Aek', 'Olympiacos', 0, 0, '2023-02-26');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (3, 'Aek', 'Panathinaikos', 1, 0, '2023-03-21');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (4, 'Panathinaikos', 'Aek', 0, 1, '2023-04-01');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (5, 'Olympiacos', 'Panathinaikos', 0, 2, '2023-04-09');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (6, 'Panathinaikos', 'Olympiacos', 0, 0, '2023-04-23');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (7, 'Aek', 'Panathinaikos', 1, 0, '2023-05-17');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (8, 'Olympiacos', 'Panathinaikos', 0, 2, '2023-05-30');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (9, 'Panathinaikos', 'Aek', 1, 0, '2023-06-14');
INSERT INTO public.match_and_schedule (id_ms, home_club, visiting_club, home_score, visiting_score, date) VALUES (10, 'Panathinaikos', 'Olympiacos', 2, 1, '2023-06-29');


--
-- TOC entry 3421 (class 0 OID 18762)
-- Dependencies: 216
-- Data for Name: player; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (1, 'Παναγιώτης', 'Ρέτσος', 'Olympiacos', 'Defender', 2, 0, 0, false);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (2, 'Κώστας', 'Φορτούνης', 'Olympiacos', 'Midfielder', 0, 0, 2, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (3, 'Υούσεφ', 'Ελ-Αραμπί', 'Olympiacos', 'Forward', 0, 0, 1, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (4, 'Τζέιμς', 'Ροντρίγκες', 'Olympiacos', 'Midfielder', 0, 0, 0, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (5, 'Μαρσέλο', 'Βιέιρα', 'Olympiacos', 'Defender', 0, 0, 2, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (6, 'Γιώργος', 'Τζαβέλας', 'Aek', 'Defender', 0, 0, 1, false);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (7, 'Πέτρος', 'Μάνταλος', 'Aek', 'Forward', 0, 0, 8, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (8, 'Γιώργος', 'Αθανασιάδης', 'Aek', 'GoalKeeper', 1, 0, 2, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (9, 'Κωνσταντίνος', 'Γαλανόπουλος', 'Aek', 'Midfielder', 0, 0, 7, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (10, 'Λάζαρος', 'Ρότας', 'Aek', 'Defender', 0, 0, 2, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (11, 'Φώτης', 'Ιωαννίδης', 'Panathinaikos', 'Forward', 0, 0, 12, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (12, 'Λεονάρντο', 'Φρόκκου', 'Panathinaikos', 'Midfielder', 0, 1, 0, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (13, 'Αλμπέρτο', 'Μπρινιόλι', 'Panathinaikos', 'Goalkeeper', 0, 0, 12, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (14, 'Σεμπαστιάν', 'Παλάσιος', 'Panathinaikos', 'Midfielder', 0, 0, 12, true);
INSERT INTO public.player (id_p, name, surname, name_cl, "position", cards_y, cards_r, goals, is_active) VALUES (15, 'Ρούμπεν', 'Πέρεθ', 'Panathinaikos', 'Midfielder', 0, 0, 12, false);


--
-- TOC entry 3422 (class 0 OID 18774)
-- Dependencies: 217
-- Data for Name: player_club; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.player_club (id_p, name_cl) VALUES (1, 'Olympiacos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (2, 'Olympiacos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (3, 'Olympiacos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (4, 'Olympiacos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (5, 'Olympiacos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (6, 'Aek');
INSERT INTO public.player_club (id_p, name_cl) VALUES (7, 'Aek');
INSERT INTO public.player_club (id_p, name_cl) VALUES (8, 'Aek');
INSERT INTO public.player_club (id_p, name_cl) VALUES (9, 'Aek');
INSERT INTO public.player_club (id_p, name_cl) VALUES (10, 'Aek');
INSERT INTO public.player_club (id_p, name_cl) VALUES (11, 'Panathinaikos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (12, 'Panathinaikos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (13, 'Panathinaikos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (14, 'Panathinaikos');
INSERT INTO public.player_club (id_p, name_cl) VALUES (15, 'Panathinaikos');


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 219
-- Name: match_and_schedule_id_ms_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.match_and_schedule_id_ms_seq', 10, true);


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 215
-- Name: player_id_p_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_id_p_seq', 15, true);


--
-- TOC entry 3230 (class 2606 OID 18756)
-- Name: club club_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club
    ADD CONSTRAINT club_pkey PRIMARY KEY (name_cl);


--
-- TOC entry 3232 (class 2606 OID 18758)
-- Name: club club_stadium_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club
    ADD CONSTRAINT club_stadium_key UNIQUE (stadium);


--
-- TOC entry 3234 (class 2606 OID 18760)
-- Name: club club_story_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.club
    ADD CONSTRAINT club_story_key UNIQUE (story);


--
-- TOC entry 3240 (class 2606 OID 18795)
-- Name: coach coach_name_cl_coach_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach
    ADD CONSTRAINT coach_name_cl_coach_key UNIQUE (name_cl_coach);


--
-- TOC entry 3254 (class 2606 OID 18918)
-- Name: drop_category_club drop_category_club_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drop_category_club
    ADD CONSTRAINT drop_category_club_pkey PRIMARY KEY (name_cl);


--
-- TOC entry 3256 (class 2606 OID 18920)
-- Name: drop_category_club drop_category_club_stadium_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drop_category_club
    ADD CONSTRAINT drop_category_club_stadium_key UNIQUE (stadium);


--
-- TOC entry 3258 (class 2606 OID 18922)
-- Name: drop_category_club drop_category_club_story_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drop_category_club
    ADD CONSTRAINT drop_category_club_story_key UNIQUE (story);


--
-- TOC entry 3248 (class 2606 OID 18839)
-- Name: match_and_corners match_and_corners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_corners
    ADD CONSTRAINT match_and_corners_pkey PRIMARY KEY (id_ms, "time");


--
-- TOC entry 3250 (class 2606 OID 18851)
-- Name: match_and_player_cards match_and_player_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_cards
    ADD CONSTRAINT match_and_player_cards_pkey PRIMARY KEY (id_ms, "time");


--
-- TOC entry 3246 (class 2606 OID 18824)
-- Name: match_and_player_goals match_and_player_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_goals
    ADD CONSTRAINT match_and_player_goals_pkey PRIMARY KEY (id_ms, "time");


--
-- TOC entry 3252 (class 2606 OID 18866)
-- Name: match_and_player_time_played match_and_player_time_played_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_time_played
    ADD CONSTRAINT match_and_player_time_played_pkey PRIMARY KEY (id_ms, id_player);


--
-- TOC entry 3242 (class 2606 OID 18807)
-- Name: match_and_schedule match_and_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_schedule
    ADD CONSTRAINT match_and_schedule_pkey PRIMARY KEY (id_ms);


--
-- TOC entry 3238 (class 2606 OID 18778)
-- Name: player_club player_club_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_club
    ADD CONSTRAINT player_club_pkey PRIMARY KEY (id_p, name_cl);


--
-- TOC entry 3236 (class 2606 OID 18768)
-- Name: player player_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_pkey PRIMARY KEY (id_p);


--
-- TOC entry 3244 (class 2606 OID 18809)
-- Name: match_and_schedule unique_match_teams_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_schedule
    ADD CONSTRAINT unique_match_teams_date UNIQUE (home_club, visiting_club, date);


--
-- TOC entry 3274 (class 2620 OID 18880)
-- Name: match_and_schedule check_match_schedule_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_match_schedule_trigger BEFORE INSERT ON public.match_and_schedule FOR EACH ROW EXECUTE FUNCTION public.check_match_schedule();


--
-- TOC entry 3272 (class 2620 OID 18924)
-- Name: club clubs_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER clubs_log AFTER DELETE ON public.club FOR EACH ROW EXECUTE FUNCTION public.clubs_log_function();


--
-- TOC entry 3273 (class 2620 OID 18878)
-- Name: player limit_player_count; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER limit_player_count BEFORE INSERT ON public.player FOR EACH ROW EXECUTE FUNCTION public.check_player_count();


--
-- TOC entry 3262 (class 2606 OID 18796)
-- Name: coach coach_name_cl_coach_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach
    ADD CONSTRAINT coach_name_cl_coach_fkey FOREIGN KEY (name_cl_coach) REFERENCES public.club(name_cl);


--
-- TOC entry 3267 (class 2606 OID 18840)
-- Name: match_and_corners match_and_corners_id_ms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_corners
    ADD CONSTRAINT match_and_corners_id_ms_fkey FOREIGN KEY (id_ms) REFERENCES public.match_and_schedule(id_ms);


--
-- TOC entry 3268 (class 2606 OID 18852)
-- Name: match_and_player_cards match_and_player_cards_id_ms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_cards
    ADD CONSTRAINT match_and_player_cards_id_ms_fkey FOREIGN KEY (id_ms) REFERENCES public.match_and_schedule(id_ms);


--
-- TOC entry 3269 (class 2606 OID 18857)
-- Name: match_and_player_cards match_and_player_cards_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_cards
    ADD CONSTRAINT match_and_player_cards_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.player(id_p);


--
-- TOC entry 3265 (class 2606 OID 18825)
-- Name: match_and_player_goals match_and_player_goals_id_ms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_goals
    ADD CONSTRAINT match_and_player_goals_id_ms_fkey FOREIGN KEY (id_ms) REFERENCES public.match_and_schedule(id_ms);


--
-- TOC entry 3266 (class 2606 OID 18830)
-- Name: match_and_player_goals match_and_player_goals_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_goals
    ADD CONSTRAINT match_and_player_goals_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.player(id_p);


--
-- TOC entry 3270 (class 2606 OID 18867)
-- Name: match_and_player_time_played match_and_player_time_played_id_ms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_time_played
    ADD CONSTRAINT match_and_player_time_played_id_ms_fkey FOREIGN KEY (id_ms) REFERENCES public.match_and_schedule(id_ms);


--
-- TOC entry 3271 (class 2606 OID 18872)
-- Name: match_and_player_time_played match_and_player_time_played_id_player_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_player_time_played
    ADD CONSTRAINT match_and_player_time_played_id_player_fkey FOREIGN KEY (id_player) REFERENCES public.player(id_p);


--
-- TOC entry 3263 (class 2606 OID 18810)
-- Name: match_and_schedule match_and_schedule_home_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_schedule
    ADD CONSTRAINT match_and_schedule_home_club_fkey FOREIGN KEY (home_club) REFERENCES public.club(name_cl);


--
-- TOC entry 3264 (class 2606 OID 18815)
-- Name: match_and_schedule match_and_schedule_visiting_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_and_schedule
    ADD CONSTRAINT match_and_schedule_visiting_club_fkey FOREIGN KEY (visiting_club) REFERENCES public.club(name_cl);


--
-- TOC entry 3260 (class 2606 OID 18779)
-- Name: player_club player_club_id_p_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_club
    ADD CONSTRAINT player_club_id_p_fkey FOREIGN KEY (id_p) REFERENCES public.player(id_p);


--
-- TOC entry 3261 (class 2606 OID 18784)
-- Name: player_club player_club_name_cl_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_club
    ADD CONSTRAINT player_club_name_cl_fkey FOREIGN KEY (name_cl) REFERENCES public.club(name_cl);


--
-- TOC entry 3259 (class 2606 OID 18769)
-- Name: player player_name_cl_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_name_cl_fkey FOREIGN KEY (name_cl) REFERENCES public.club(name_cl);


-- Completed on 2023-06-29 12:41:35

--
-- PostgreSQL database dump complete
--

