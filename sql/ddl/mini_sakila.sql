--
-- Name: mpaa_rating; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE mpaa_rating AS ENUM (
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17'
);

--
-- Name: film_film_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE film_film_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: year; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN year AS integer
    CONSTRAINT year_check CHECK (((VALUE >= 1901) AND (VALUE <= 2155)));

--
-- Name: film; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE film (
    film_id integer DEFAULT nextval('film_film_id_seq'::regclass) NOT NULL,
    title text NOT NULL,
    description text,
    release_year year,
    language_id smallint NOT NULL,
    original_language_id smallint,
    rental_duration smallint DEFAULT 3 NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    length smallint,
    replacement_cost numeric(5,2) DEFAULT 19.99 NOT NULL,
    rating mpaa_rating DEFAULT 'G'::mpaa_rating,
    last_update timestamp with time zone DEFAULT now() NOT NULL,
    special_features text[],
    fulltext tsvector NOT NULL
);

--
-- Name: actor_actor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE actor_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: actor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE actor (
    actor_id integer DEFAULT nextval('actor_actor_id_seq'::regclass) NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: film_actor; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE film_actor (
    actor_id smallint NOT NULL,
    film_id smallint NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: film_actor film_actor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY film_actor
    ADD CONSTRAINT film_actor_pkey PRIMARY KEY (actor_id, film_id);

ALTER TABLE ONLY actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (actor_id);

ALTER TABLE ONLY film
    ADD CONSTRAINT film_pkey PRIMARY KEY (film_id);


--
-- Name: idx_fk_film_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fk_film_id ON film_actor USING btree (film_id);


--
-- Name: film_actor film_actor_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY film_actor
    ADD CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_actor film_actor_film_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY film_actor
    ADD CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;
