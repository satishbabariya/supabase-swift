CREATE TABLE key_value_storage(
    "key" text PRIMARY KEY,
    "value" jsonb NOT NULL
);

ALTER publication supabase_realtime
    ADD TABLE key_value_storage;

-- Create a second schema
CREATE SCHEMA personal;

-- USERS
CREATE TYPE public.user_status AS ENUM(
    'ONLINE',
    'OFFLINE'
);

CREATE TABLE public.users(
    username text PRIMARY KEY,
    data jsonb DEFAULT NULL,
    age_range int4range DEFAULT NULL,
    status user_status DEFAULT 'ONLINE' ::public.user_status,
    catchphrase tsvector DEFAULT NULL
);

ALTER TABLE public.users REPLICA IDENTITY
    FULL;

-- Send "previous data" to supabase
COMMENT ON COLUMN public.users.data IS 'For unstructured data and prototyping.';

-- CREATE A ZERO-TO-ONE RELATIONSHIP (User can have profile, but not all of them do)
CREATE TABLE public.user_profiles(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username text REFERENCES users
);

-- CREATE A TABLE WITH TWO RELATIONS TO SAME DESTINATION WHICH WILL NEED HINTING
CREATE TABLE public.best_friends(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    -- Thoses relations should always be satisfied, never be null
    first_user text REFERENCES users NOT NULL,
    second_user text REFERENCES users NOT NULL,
    -- This relation is nullable, it might be null
    third_wheel text REFERENCES users
);

-- CHANNELS
CREATE TABLE public.channels(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    data jsonb DEFAULT NULL,
    slug text
);

ALTER TABLE public.users REPLICA IDENTITY
    FULL;

-- Send "previous data" to supabase
COMMENT ON COLUMN public.channels.data IS 'For unstructured data and prototyping.';

CREATE TABLE public.channel_details(
    id bigint PRIMARY KEY REFERENCES channels(id),
    details text DEFAULT NULL
);

-- MESSAGES
CREATE TABLE public.messages(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    data jsonb DEFAULT NULL,
    message text,
    username text REFERENCES users NOT NULL,
    channel_id bigint REFERENCES channels NOT NULL
);

ALTER TABLE public.messages REPLICA IDENTITY
    FULL;

-- Send "previous data" to supabase
COMMENT ON COLUMN public.messages.data IS 'For unstructured data and prototyping.';

-- SELF REFERENCING TABLE
CREATE TABLE public.collections(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    description text,
    parent_id bigint
);

ALTER TABLE public.messages REPLICA IDENTITY
    FULL;

-- Send "previous data" to supabase
-- SELF REFERENCE via parent_id
ALTER TABLE public.collections
    ADD CONSTRAINT collections_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.collections(id);

COMMENT ON COLUMN public.messages.data IS 'For unstructured data and prototyping.';

-- MANY-TO-MANY RELATIONSHIP USING A JOIN TABLE
-- Create a table for products
CREATE TABLE public.products(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    description text,
    price decimal(10, 2) NOT NULL
);

-- Create a table for categories
CREATE TABLE public.categories(
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    description text
);

-- Create a join table for the many-to-many relationship between products and categories
CREATE TABLE public.product_categories(
    product_id bigint REFERENCES public.products(id) ON DELETE CASCADE,
    category_id bigint REFERENCES public.categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

-- STORED FUNCTION
CREATE FUNCTION public.get_status(name_param text)
    RETURNS user_status
    AS $$
    SELECT
        status
    FROM
        users
    WHERE
        username = name_param;
$$
LANGUAGE SQL
IMMUTABLE;

CREATE FUNCTION public.get_username_and_status(name_param text)
    RETURNS TABLE(
        username text,
        status user_status
    )
    AS $$
    SELECT
        username,
        status
    FROM
        users
    WHERE
        username = name_param;
$$
LANGUAGE SQL
IMMUTABLE;

CREATE FUNCTION public.offline_user(name_param text)
    RETURNS user_status
    AS $$
    UPDATE
        users
    SET
        status = 'OFFLINE'
    WHERE
        username = name_param
    RETURNING
        status;
$$
LANGUAGE SQL
VOLATILE;

CREATE FUNCTION public.void_func()
    RETURNS void
    AS $$
$$
LANGUAGE SQL;

CREATE EXTENSION postgis SCHEMA extensions;

CREATE TABLE public.shops(
    id int PRIMARY KEY,
    address text,
    shop_geom extensions.geometry(point, 4326)
);

CREATE VIEW public.non_updatable_view AS
SELECT
    username
FROM
    public.users
LIMIT 1;

CREATE VIEW public.updatable_view AS
SELECT
    username,
    1 AS non_updatable_column
FROM
    public.users;

-- SECOND SCHEMA USERS
CREATE TYPE personal.user_status AS ENUM(
    'ONLINE',
    'OFFLINE'
);

CREATE TABLE personal.users(
    username text PRIMARY KEY,
    data jsonb DEFAULT NULL,
    age_range int4range DEFAULT NULL,
    status user_status DEFAULT 'ONLINE' ::public.user_status
);

-- SECOND SCHEMA STORED FUNCTION
CREATE FUNCTION personal.get_status(name_param text)
    RETURNS user_status
    AS $$
    SELECT
        status
    FROM
        users
    WHERE
        username = name_param;
$$
LANGUAGE SQL
IMMUTABLE;

CREATE FUNCTION public.function_with_optional_param(param text DEFAULT '')
    RETURNS text
    AS $$
    SELECT
        param;
$$
LANGUAGE SQL
IMMUTABLE;

CREATE FUNCTION public.function_with_array_param(param uuid[])
    RETURNS void
    AS ''
    LANGUAGE sql
    IMMUTABLE;
    CREATE TABLE public.cornercase(
        id int PRIMARY KEY,
        "column whitespace" text,
        array_column text[]
);

    CREATE FUNCTION public.get_array_element(arr int[], INDEX int)
        RETURNS int AS $$
        SELECT
            arr[INDEX];
            $$
            LANGUAGE sql
            IMMUTABLE;
