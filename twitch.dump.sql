PGDMP     $                	    z            twitch #   14.5 (Ubuntu 14.5-0ubuntu0.22.04.1) #   14.5 (Ubuntu 14.5-0ubuntu0.22.04.1) v    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16803    twitch    DATABASE     [   CREATE DATABASE twitch WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
    DROP DATABASE twitch;
                postgres    false            �           0    0    DATABASE twitch    ACL     )   GRANT ALL ON DATABASE twitch TO gb_user;
                   postgres    false    3515            �            1255    17028 2   count_streams_with_selected_tag(character varying)    FUNCTION       CREATE FUNCTION public.count_streams_with_selected_tag(choosed_tag character varying) RETURNS bigint
    LANGUAGE sql
    AS $$
SELECT COUNT(*)
FROM users
    JOIN streams ON users.id = streams.user_id
    JOIN tags ON streams.tags_id = tags.id
WHERE name = choosed_tag;
$$;
 U   DROP FUNCTION public.count_streams_with_selected_tag(choosed_tag character varying);
       public          gb_user    false            �            1255    17029    update_category_trigger()    FUNCTION       CREATE FUNCTION public.update_category_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE is_found BOOLEAN;
BEGIN
is_found := NOT EXISTS(SELECT * FROM categories WHERE NEW.name LIKE categories.name);
IF is_found THEN
NEW.body := 'games+demos';
END IF;
RETURN NEW;
END
$$;
 0   DROP FUNCTION public.update_category_trigger();
       public          gb_user    false            �            1255    17033    update_partnership_trigger()    FUNCTION       CREATE FUNCTION public.update_partnership_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE is_found BOOLEAN;
BEGIN
is_found := EXISTS(
	SELECT user_id FROM streams_statistic
    LEFT JOIN users ON streams_statistic.user_id = users.id
    JOIN partnerships ON users.partnership_id = partnerships.id
WHERE partnership_type != 'full partner' AND streamed_in_month < 20
ORDER BY streamed_in_month);
IF is_found THEN
RAISE EXCEPTION 'User streamed less then 20 hours in month';
END IF;
RETURN NEW;
END
$$;
 3   DROP FUNCTION public.update_partnership_trigger();
       public          gb_user    false            �            1259    16871 
   categories    TABLE     \   CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(30)
);
    DROP TABLE public.categories;
       public         heap    gb_user    false            �            1259    16870    categories_id_seq    SEQUENCE     �   CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.categories_id_seq;
       public          gb_user    false    224            �           0    0    categories_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;
          public          gb_user    false    223            �            1259    16880    chats    TABLE     �   CREATE TABLE public.chats (
    id integer NOT NULL,
    from_user_id integer NOT NULL,
    to_user_id integer NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone
);
    DROP TABLE public.chats;
       public         heap    gb_user    false            �            1259    16879    chats_id_seq    SEQUENCE     �   CREATE SEQUENCE public.chats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.chats_id_seq;
       public          gb_user    false    226            �           0    0    chats_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.chats_id_seq OWNED BY public.chats.id;
          public          gb_user    false    225            �            1259    16862    partnerships    TABLE     b   CREATE TABLE public.partnerships (
    id integer NOT NULL,
    partnership_type text NOT NULL
);
     DROP TABLE public.partnerships;
       public         heap    gb_user    false            �            1259    16861    partnerships_id_seq    SEQUENCE     �   CREATE SEQUENCE public.partnerships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.partnerships_id_seq;
       public          gb_user    false    222            �           0    0    partnerships_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.partnerships_id_seq OWNED BY public.partnerships.id;
          public          gb_user    false    221            �            1259    16925    photo    TABLE     �   CREATE TABLE public.photo (
    id integer NOT NULL,
    url character varying(250) NOT NULL,
    owner_id integer NOT NULL,
    uploaded_at timestamp without time zone NOT NULL,
    size integer NOT NULL
);
    DROP TABLE public.photo;
       public         heap    gb_user    false            �            1259    16924    photo_id_seq    SEQUENCE     �   CREATE SEQUENCE public.photo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.photo_id_seq;
       public          gb_user    false    232            �           0    0    photo_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.photo_id_seq OWNED BY public.photo.id;
          public          gb_user    false    231            �            1259    16828    private_messages    TABLE     �   CREATE TABLE public.private_messages (
    id integer NOT NULL,
    from_user_id integer NOT NULL,
    to_user_id integer NOT NULL,
    body text,
    created_at timestamp without time zone
);
 $   DROP TABLE public.private_messages;
       public         heap    gb_user    false            �            1259    16827    private_messages_id_seq    SEQUENCE     �   CREATE SEQUENCE public.private_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.private_messages_id_seq;
       public          gb_user    false    214            �           0    0    private_messages_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.private_messages_id_seq OWNED BY public.private_messages.id;
          public          gb_user    false    213            �            1259    16815    profiles    TABLE     B  CREATE TABLE public.profiles (
    user_id integer NOT NULL,
    first_name character varying(40),
    last_name character varying(40),
    phone character varying(20) NOT NULL,
    avatar_photo_id integer,
    banner_photo_id integer,
    description character varying(200),
    created_at timestamp without time zone
);
    DROP TABLE public.profiles;
       public         heap    gb_user    false            �            1259    16889    streams    TABLE     �   CREATE TABLE public.streams (
    id integer NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    tags_id integer NOT NULL,
    viewers integer,
    created_at timestamp without time zone
);
    DROP TABLE public.streams;
       public         heap    gb_user    false            �            1259    16837    tags    TABLE     V   CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying(30)
);
    DROP TABLE public.tags;
       public         heap    gb_user    false            �            1259    16805    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    nickname character varying(50) NOT NULL,
    email character varying(120) NOT NULL,
    stream_key character varying(40) NOT NULL,
    partnership_id integer NOT NULL
);
    DROP TABLE public.users;
       public         heap    gb_user    false            �            1259    17020    russian_streamers    VIEW     �   CREATE VIEW public.russian_streamers AS
 SELECT users.nickname
   FROM ((public.users
     JOIN public.streams ON ((users.id = streams.user_id)))
     JOIN public.tags ON ((streams.tags_id = tags.id)))
  WHERE ((tags.name)::text = 'russian'::text);
 $   DROP VIEW public.russian_streamers;
       public          gb_user    false    216    210    210    216    228    228            �            1259    16822    streams_statistic    TABLE     �   CREATE TABLE public.streams_statistic (
    user_id integer NOT NULL,
    followers integer,
    subscribers integer,
    streamed_in_month integer
);
 %   DROP TABLE public.streams_statistic;
       public         heap    gb_user    false            �            1259    17024    streamed_hours_of_partners    VIEW     �  CREATE VIEW public.streamed_hours_of_partners AS
 SELECT streams_statistic.user_id,
    streams_statistic.streamed_in_month
   FROM ((public.streams_statistic
     LEFT JOIN public.users ON ((streams_statistic.user_id = users.id)))
     JOIN public.partnerships ON ((users.partnership_id = partnerships.id)))
  WHERE ((partnerships.partnership_type = 'full partner'::text) AND (streams_statistic.streamed_in_month < 40))
  ORDER BY streams_statistic.streamed_in_month;
 -   DROP VIEW public.streamed_hours_of_partners;
       public          gb_user    false    212    222    222    210    210    212            �            1259    16888    streams_id_seq    SEQUENCE     �   CREATE SEQUENCE public.streams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.streams_id_seq;
       public          gb_user    false    228            �           0    0    streams_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.streams_id_seq OWNED BY public.streams.id;
          public          gb_user    false    227            �            1259    16853    subscription_types    TABLE     i   CREATE TABLE public.subscription_types (
    id integer NOT NULL,
    subscription_type text NOT NULL
);
 &   DROP TABLE public.subscription_types;
       public         heap    gb_user    false            �            1259    16852    subscription_types_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subscription_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.subscription_types_id_seq;
       public          gb_user    false    220            �           0    0    subscription_types_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.subscription_types_id_seq OWNED BY public.subscription_types.id;
          public          gb_user    false    219            �            1259    16846    subscriptions    TABLE     �   CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    subscriber_user_id integer NOT NULL,
    subscribe_to_id integer NOT NULL,
    subscription_type_id integer NOT NULL,
    created_at timestamp without time zone
);
 !   DROP TABLE public.subscriptions;
       public         heap    gb_user    false            �            1259    16845    subscriptions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.subscriptions_id_seq;
       public          gb_user    false    218            �           0    0    subscriptions_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;
          public          gb_user    false    217            �            1259    16836    tags_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.tags_id_seq;
       public          gb_user    false    216            �           0    0    tags_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;
          public          gb_user    false    215            �            1259    16804    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          gb_user    false    210            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          gb_user    false    209            �            1259    16905    video    TABLE       CREATE TABLE public.video (
    id integer NOT NULL,
    url character varying(250) NOT NULL,
    owner_id integer NOT NULL,
    description character varying(250) NOT NULL,
    uploaded_at timestamp without time zone NOT NULL,
    size integer NOT NULL
);
    DROP TABLE public.video;
       public         heap    gb_user    false            �            1259    16904    video_id_seq    SEQUENCE     �   CREATE SEQUENCE public.video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.video_id_seq;
       public          gb_user    false    230            �           0    0    video_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.video_id_seq OWNED BY public.video.id;
          public          gb_user    false    229            �           2604    16874    categories id    DEFAULT     n   ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);
 <   ALTER TABLE public.categories ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    224    223    224            �           2604    16883    chats id    DEFAULT     d   ALTER TABLE ONLY public.chats ALTER COLUMN id SET DEFAULT nextval('public.chats_id_seq'::regclass);
 7   ALTER TABLE public.chats ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    225    226    226            �           2604    16865    partnerships id    DEFAULT     r   ALTER TABLE ONLY public.partnerships ALTER COLUMN id SET DEFAULT nextval('public.partnerships_id_seq'::regclass);
 >   ALTER TABLE public.partnerships ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    222    221    222            �           2604    16928    photo id    DEFAULT     d   ALTER TABLE ONLY public.photo ALTER COLUMN id SET DEFAULT nextval('public.photo_id_seq'::regclass);
 7   ALTER TABLE public.photo ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    231    232    232            �           2604    16831    private_messages id    DEFAULT     z   ALTER TABLE ONLY public.private_messages ALTER COLUMN id SET DEFAULT nextval('public.private_messages_id_seq'::regclass);
 B   ALTER TABLE public.private_messages ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    213    214    214            �           2604    16892 
   streams id    DEFAULT     h   ALTER TABLE ONLY public.streams ALTER COLUMN id SET DEFAULT nextval('public.streams_id_seq'::regclass);
 9   ALTER TABLE public.streams ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    227    228    228            �           2604    16856    subscription_types id    DEFAULT     ~   ALTER TABLE ONLY public.subscription_types ALTER COLUMN id SET DEFAULT nextval('public.subscription_types_id_seq'::regclass);
 D   ALTER TABLE public.subscription_types ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    220    219    220            �           2604    16849    subscriptions id    DEFAULT     t   ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);
 ?   ALTER TABLE public.subscriptions ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    218    217    218            �           2604    16840    tags id    DEFAULT     b   ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);
 6   ALTER TABLE public.tags ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    216    215    216            �           2604    16808    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    210    209    210            �           2604    16908    video id    DEFAULT     d   ALTER TABLE ONLY public.video ALTER COLUMN id SET DEFAULT nextval('public.video_id_seq'::regclass);
 7   ALTER TABLE public.video ALTER COLUMN id DROP DEFAULT;
       public          gb_user    false    229    230    230            �          0    16871 
   categories 
   TABLE DATA           .   COPY public.categories (id, name) FROM stdin;
    public          gb_user    false    224   ��       �          0    16880    chats 
   TABLE DATA           O   COPY public.chats (id, from_user_id, to_user_id, body, created_at) FROM stdin;
    public          gb_user    false    226   ��       �          0    16862    partnerships 
   TABLE DATA           <   COPY public.partnerships (id, partnership_type) FROM stdin;
    public          gb_user    false    222   ʘ       �          0    16925    photo 
   TABLE DATA           E   COPY public.photo (id, url, owner_id, uploaded_at, size) FROM stdin;
    public          gb_user    false    232   
�       �          0    16828    private_messages 
   TABLE DATA           Z   COPY public.private_messages (id, from_user_id, to_user_id, body, created_at) FROM stdin;
    public          gb_user    false    214   ��       �          0    16815    profiles 
   TABLE DATA           �   COPY public.profiles (user_id, first_name, last_name, phone, avatar_photo_id, banner_photo_id, description, created_at) FROM stdin;
    public          gb_user    false    211   �       �          0    16889    streams 
   TABLE DATA           Y   COPY public.streams (id, user_id, category_id, tags_id, viewers, created_at) FROM stdin;
    public          gb_user    false    228   ]�       �          0    16822    streams_statistic 
   TABLE DATA           _   COPY public.streams_statistic (user_id, followers, subscribers, streamed_in_month) FROM stdin;
    public          gb_user    false    212   ��       �          0    16853    subscription_types 
   TABLE DATA           C   COPY public.subscription_types (id, subscription_type) FROM stdin;
    public          gb_user    false    220   ��       �          0    16846    subscriptions 
   TABLE DATA           r   COPY public.subscriptions (id, subscriber_user_id, subscribe_to_id, subscription_type_id, created_at) FROM stdin;
    public          gb_user    false    218   ��       �          0    16837    tags 
   TABLE DATA           (   COPY public.tags (id, name) FROM stdin;
    public          gb_user    false    216   ��       �          0    16805    users 
   TABLE DATA           P   COPY public.users (id, nickname, email, stream_key, partnership_id) FROM stdin;
    public          gb_user    false    210   K�       �          0    16905    video 
   TABLE DATA           R   COPY public.video (id, url, owner_id, description, uploaded_at, size) FROM stdin;
    public          gb_user    false    230   ��       �           0    0    categories_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.categories_id_seq', 20, true);
          public          gb_user    false    223            �           0    0    chats_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.chats_id_seq', 100, true);
          public          gb_user    false    225            �           0    0    partnerships_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.partnerships_id_seq', 3, true);
          public          gb_user    false    221            �           0    0    photo_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.photo_id_seq', 100, true);
          public          gb_user    false    231            �           0    0    private_messages_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.private_messages_id_seq', 100, true);
          public          gb_user    false    213            �           0    0    streams_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.streams_id_seq', 100, true);
          public          gb_user    false    227            �           0    0    subscription_types_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.subscription_types_id_seq', 2, true);
          public          gb_user    false    219            �           0    0    subscriptions_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.subscriptions_id_seq', 100, true);
          public          gb_user    false    217            �           0    0    tags_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.tags_id_seq', 6, true);
          public          gb_user    false    215            �           0    0    users_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.users_id_seq', 100, true);
          public          gb_user    false    209            �           0    0    video_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.video_id_seq', 101, true);
          public          gb_user    false    229            �           2606    16878    categories categories_name_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);
 H   ALTER TABLE ONLY public.categories DROP CONSTRAINT categories_name_key;
       public            gb_user    false    224            �           2606    16876    categories categories_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.categories DROP CONSTRAINT categories_pkey;
       public            gb_user    false    224            �           2606    16887    chats chats_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.chats DROP CONSTRAINT chats_pkey;
       public            gb_user    false    226            �           2606    16869    partnerships partnerships_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.partnerships
    ADD CONSTRAINT partnerships_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.partnerships DROP CONSTRAINT partnerships_pkey;
       public            gb_user    false    222            �           2606    16930    photo photo_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.photo DROP CONSTRAINT photo_pkey;
       public            gb_user    false    232            �           2606    16932    photo photo_url_key 
   CONSTRAINT     M   ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_url_key UNIQUE (url);
 =   ALTER TABLE ONLY public.photo DROP CONSTRAINT photo_url_key;
       public            gb_user    false    232            �           2606    16835 &   private_messages private_messages_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT private_messages_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.private_messages DROP CONSTRAINT private_messages_pkey;
       public            gb_user    false    214            �           2606    16821    profiles profiles_phone_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_phone_key UNIQUE (phone);
 E   ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_phone_key;
       public            gb_user    false    211            �           2606    16819    profiles profiles_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (user_id);
 @   ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_pkey;
       public            gb_user    false    211            �           2606    16894    streams streams_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.streams DROP CONSTRAINT streams_pkey;
       public            gb_user    false    228            �           2606    16826 (   streams_statistic streams_statistic_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.streams_statistic
    ADD CONSTRAINT streams_statistic_pkey PRIMARY KEY (user_id);
 R   ALTER TABLE ONLY public.streams_statistic DROP CONSTRAINT streams_statistic_pkey;
       public            gb_user    false    212            �           2606    16860 *   subscription_types subscription_types_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.subscription_types
    ADD CONSTRAINT subscription_types_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.subscription_types DROP CONSTRAINT subscription_types_pkey;
       public            gb_user    false    220            �           2606    16851     subscriptions subscriptions_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_pkey;
       public            gb_user    false    218            �           2606    16844    tags tags_name_key 
   CONSTRAINT     M   ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_name_key UNIQUE (name);
 <   ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_name_key;
       public            gb_user    false    216            �           2606    16842    tags tags_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.tags DROP CONSTRAINT tags_pkey;
       public            gb_user    false    216            �           2606    16812    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            gb_user    false    210            �           2606    16810    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            gb_user    false    210            �           2606    16814    users users_stream_key_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_stream_key_key UNIQUE (stream_key);
 D   ALTER TABLE ONLY public.users DROP CONSTRAINT users_stream_key_key;
       public            gb_user    false    210            �           2606    16912    video video_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.video DROP CONSTRAINT video_pkey;
       public            gb_user    false    230            �           2606    16914    video video_url_key 
   CONSTRAINT     M   ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_url_key UNIQUE (url);
 =   ALTER TABLE ONLY public.video DROP CONSTRAINT video_url_key;
       public            gb_user    false    230                       2620    17034    users update_partnership    TRIGGER     �   CREATE TRIGGER update_partnership BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_partnership_trigger();
 1   DROP TRIGGER update_partnership ON public.users;
       public          gb_user    false    210    237            	           2606    16980    chats chats_from_user_id_fk    FK CONSTRAINT        ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_from_user_id_fk FOREIGN KEY (from_user_id) REFERENCES public.users(id);
 E   ALTER TABLE ONLY public.chats DROP CONSTRAINT chats_from_user_id_fk;
       public          gb_user    false    3290    210    226            
           2606    16985    chats chats_to_user_id_fk    FK CONSTRAINT     {   ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_to_user_id_fk FOREIGN KEY (to_user_id) REFERENCES public.users(id);
 C   ALTER TABLE ONLY public.chats DROP CONSTRAINT chats_to_user_id_fk;
       public          gb_user    false    3290    226    210                       2606    17005    photo photo_owner_id_fk    FK CONSTRAINT     w   ALTER TABLE ONLY public.photo
    ADD CONSTRAINT photo_owner_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id);
 A   ALTER TABLE ONLY public.photo DROP CONSTRAINT photo_owner_id_fk;
       public          gb_user    false    232    210    3290                       2606    16945 $   profiles profiles_avatar_photo_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_avatar_photo_id_fk FOREIGN KEY (avatar_photo_id) REFERENCES public.photo(id);
 N   ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_avatar_photo_id_fk;
       public          gb_user    false    211    3324    232                       2606    16950 $   profiles profiles_banner_photo_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_banner_photo_id_fk FOREIGN KEY (banner_photo_id) REFERENCES public.photo(id);
 N   ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_banner_photo_id_fk;
       public          gb_user    false    3324    211    232                       2606    16955 )   private_messages profiles_from_user_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT profiles_from_user_id_fk FOREIGN KEY (from_user_id) REFERENCES public.users(id);
 S   ALTER TABLE ONLY public.private_messages DROP CONSTRAINT profiles_from_user_id_fk;
       public          gb_user    false    210    3290    214                       2606    16960 '   private_messages profiles_to_user_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.private_messages
    ADD CONSTRAINT profiles_to_user_id_fk FOREIGN KEY (to_user_id) REFERENCES public.users(id);
 Q   ALTER TABLE ONLY public.private_messages DROP CONSTRAINT profiles_to_user_id_fk;
       public          gb_user    false    210    214    3290                        2606    16940    profiles profiles_user_id_fk    FK CONSTRAINT     {   ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 F   ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_user_id_fk;
       public          gb_user    false    210    3290    211                       2606    16995    streams streams_category_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_category_id_fk FOREIGN KEY (category_id) REFERENCES public.categories(id);
 H   ALTER TABLE ONLY public.streams DROP CONSTRAINT streams_category_id_fk;
       public          gb_user    false    228    224    3314                       2606    17015 .   streams_statistic streams_statistic_user_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.streams_statistic
    ADD CONSTRAINT streams_statistic_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 X   ALTER TABLE ONLY public.streams_statistic DROP CONSTRAINT streams_statistic_user_id_fk;
       public          gb_user    false    210    3290    212                       2606    17000    streams streams_tags_id_fk    FK CONSTRAINT     x   ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_tags_id_fk FOREIGN KEY (tags_id) REFERENCES public.tags(id);
 D   ALTER TABLE ONLY public.streams DROP CONSTRAINT streams_tags_id_fk;
       public          gb_user    false    3304    228    216                       2606    16990    streams streams_user_id_fk    FK CONSTRAINT     y   ALTER TABLE ONLY public.streams
    ADD CONSTRAINT streams_user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);
 D   ALTER TABLE ONLY public.streams DROP CONSTRAINT streams_user_id_fk;
       public          gb_user    false    228    3290    210                       2606    16970 .   subscriptions subscriptions_subscribe_to_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscribe_to_id_fk FOREIGN KEY (subscribe_to_id) REFERENCES public.users(id);
 X   ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_subscribe_to_id_fk;
       public          gb_user    false    3290    218    210                       2606    16965 1   subscriptions subscriptions_subscriber_user_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscriber_user_id_fk FOREIGN KEY (subscriber_user_id) REFERENCES public.users(id);
 [   ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_subscriber_user_id_fk;
       public          gb_user    false    218    3290    210                       2606    16975 3   subscriptions subscriptions_subscription_type_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_subscription_type_id_fk FOREIGN KEY (subscription_type_id) REFERENCES public.subscription_types(id);
 ]   ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_subscription_type_id_fk;
       public          gb_user    false    220    3308    218            �           2606    16935    users users_partnership_id_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_partnership_id_fk FOREIGN KEY (partnership_id) REFERENCES public.partnerships(id);
 G   ALTER TABLE ONLY public.users DROP CONSTRAINT users_partnership_id_fk;
       public          gb_user    false    3310    210    222                       2606    17010    video video_owner_id_fk    FK CONSTRAINT     w   ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_owner_id_fk FOREIGN KEY (owner_id) REFERENCES public.users(id);
 A   ALTER TABLE ONLY public.video DROP CONSTRAINT video_owner_id_fk;
       public          gb_user    false    210    3290    230            �   �   x�-��n1��������!�[o�P/]�{�6y���4��	z�"��_<��"}�Po3�:�;{�x�1��S���*��~y'd�Ԁn���ڳօ^܄w��D�$f�b:�S�3�U6LG��R�6a:�,2v�l���qx�o�L�p���}���v���"���F��z)�^3�f�憇}��1$�hV~��&�mk�[��x�?'D��^_�      �   	  x�}XɎ�6<�_��L��֛a����4<���2�e���0?����1@��E�-�"�IW�R�q�Ԫg���䗋0��Wm��U�nl֘LQբ.�Gۅ��G�5+��V�n�kt%��q��s�E=�G{S��|;�ò=_]M�����j�D]
cD7���f��]���?뼌j��}���SG�F2U)
-�~Z�)����ŋ?�[����jjr#Q������=�������1o$�c�))-a!��{�\Tx�k��W�)cD�D�0NLa^��e�@%K�Mctc���΅�3S�8���������-\�Pw�Ѣ�x��];����w��lɲ�B"3�.i�}(�ޗqڞ3���D�6L�	߅?W��id�����W���A�*��(CV�ӳ1�L+mGf%.7��Z-�W����P�`D����z�0�7^��}����շw�U��8�����I]�*cc���S�ʣ? ��#1 ���.����:c�R�u%p�-�s����թ@�����U;��8H���T���O�������ڭ��(Sz��W�G`B�d� Ƃ���q�G�h�ɿ�8�`����gM�A:���c7�m����@�Z��
�Z�S�UJW��c%�V���6��j�)��t�Rs�p�!J+\������qR�t]NV0
pǔ��H��xkx�8����m�%8>���h��B�C��ᘂ�,aJ\#�\K�jdYBf��v-�J&,��cK4���fQ�25}H��l��L�{x*�}��AӑZ��'>�W�`���(�fkB������s���l�����*�Y>��8eL�����f"GE]z#i �u�B�0���G�czy'�,*�䀨��"<��� *y�0)�_^6r�2��Xo���]�NE�<�����:Q9^��ꇽ.58�h\&1CH������~�d#��&3c�a-�J�!9�39��_�8�(c.�z9$'!��$_0$��$�?��O#���qH�DU�p+ΐ�}!mM*�L�aI���5�xE"F���.5������=�����(��%�.�>���F�lR�p��$
Z)D���9���g��u��s�tT�̑O�e�'�HT<����L�o/���3&��AIj�2U����R'�:�9��a�,پ�s�I����@mЬq�����>�Bې�X-*���>���_Rڇ���n�[  � �s���'DIesP�B�(�u.�_jX��E�2x�^�O���q��ձ�8_�<EFE�/h=���D�V�i0l��\Szpx���31
��(*
��!��h��2\6suځ��i���"˸��䨄5��Q)�7�ڀD 黌l��M�y3�%QO���QrDR��� ɯYT:N�4�H���S��8�(/E��Kj�E�_ܢh��Lu��!iV1}�S^�j���$�%9��ב���V��M��N�-`���>(���դxT��r��-g"��e^��)��jc�sdw� 2@�~��C�^�,��f�,,�������T	t�9����m�j#�Z?��$�dh��2u���������M����b, �<+8=Ё_��-$�>|O�?G'�R�y,�$��	G����?��/Gl�c�\^�jb�c�i�q�_޼ ��jX�4���t;�Լ<rR�	�6���@<\@	��û@8`%����q��o�	6�65}vi�q��Pv�`p��u=���H^�Ɛ �d�U���6�c �G1��25�$,���gk�O�-C���2Иm�4o'�U��xEAC��ٜ����~�� ��T�(�@:�����5�08�C�s���_�}: ���{��C��&�eM"�T�I�Ђ���ȑsm-�N����;�=P��T˂�V��\�N&?]�&�;;~�]�w�G)jd�=�c�6��>zϨ^{}�TGi
	��F0�E�{�G�9�b���������W��_#ბ��	;Z�s)9�^JTm����{X��f���E׈�?m����=��/����N5_W�b��Ax��e�e�)��]�*�������~��;( h8�_vm@��U:P�"1tЏ��t��^��А����s}]x_��~j�n���I�O��uL��d��3%�WG�W�' nV_3�8�e옓�^���:��Z��ƣW�	� �C������Lr.^:~2�F�A��W���TE�z�+������xeZ�G�u��Ǝ.��N���PG��:4?��Ma�~�gb(V~K�J~8��,-����&����e      �   0   x�3�,-.M��2�LLK���L,I�2�L+��Q(H,*�K-����� �      �   �	  x�eXˎ�8<'���2���`fs��.��^Զ���v�����F�4U=�*��GDd�5��˾��D2��7eތ������
C��vK�Y��c\��m_�-}���/�7�ތ�:x������}��C=V�i/U?8<��i#�9]��qߧ��ni�k��:}�Ǎ����7�I��0���s�g
}�*>�t�FP��@˾-�,����/j�a��xjP�|t���c�ׇ����eZ�v��=��E>˶����-�M�^g����y�M�li�e���rM�&��!D�
 ?N���=���/O�:W���t/5���)j-��?���ӺN���t���gr�z{�DjT�ސ�NhM���".�y������jkkj�M��` �J
��qM�����=�G�܁r��^	miZ7kF����q��Z�p��%��hG��L��$/��"�������[���ֻ�zk�9�' �}��j�O�]N���/iEu[�e\p�z��Bk�V@��m�?��+��(tG�;��߸b�ܫ3����t���?G���m�/�?��ɻ#ǅuv��,H�{z~�˴-H�_x�;�0^^�*�+oj~w��\��(�1�N��~{�۸M�?��)n�QHwp���Úp�<�+(Ʊ��uO�`��Ah��r�:f7�S�s�i�n0��;��-�s�{[�%M�Q��F L��U�ѿӏqF��iMg�%wK޹jg�U� 5�k @�_�����38$��s��x��S�����"?0"Ƞ�u��Lg���BWO�'J�g����A��qZ'�P�L�@ǡ��H>���?8'�m��[N����H]he�4�n�j�V�Ut�ag	l�s��q�?�}{��|U��FB-k*�N�|����D0���� ��&6%kPq��Ġ5T��q���;T��f9���Bm�`{��SV �P�qK_�f �oϪ���@��zܴ���u\���(�LHv��
G'9V=�\�hza�st����c�:��Fߦc� N�Fp�(Z�	��d"�
��fh��#-	z���|_��8�5�仦�D�3o�ܳ���F�&((�I�k�F����T��� ���\��K�*S�[��ױx��T�Q�$����t�Y�d�`ʓ1nUd����n7p�P2�����DF�͆�B�:�C�5dVLv�YӪ�D���F�1�י$��+�r(�n�0@�z�Ӯ)[5#Y�)��Dk�%+0��l)�M��:X�W�����S��x
�Ή4'�^e=�1�!l���q�}=��D]l�3�i(�_\�ae��6mꄕ��-1��apx�f	�o�*
��tc����"���s_���2�H�Q�$�L�6�Zu9,L?(��TIg�K�ak�yr���Jl���~y,_��c_��6|m�#w=ܛG�.��bp��Y'����(B�K\� FD^�+�B������E����>02�;w��{	D�Iۘ'1L�E1-��aZ��zڳ�1U���P�qb�l�dvF�YM`��\f*T�M#L]�u�PX�q]"h��\�su2&��1�!B	=�4�뾌_`T����2�5�j�g���Jѿ�lY���_'}I����hҝ����B��qKa&�|�vkp��*�&+�ͧBY;����i��Ms�6���.~�$X�z��|n���<c�<c��J��P����z����p��#��W��c�ΞUs��v����:�d2P��"f/y@
�T�}^��MK9�bžw�3�bbD�I���5*Bl�d0!`vLdg�	�O��ip��U9g��ˬ�9�����	ǜ���-��U|6K�^�+�֎�b��8�nY������4w�P��Z�3�����g�3WK s��s���A}��.�����Y5e�T��7�"Ў*����n��U�L8�������^DE�3�y�=�'�p��P�PTN��e��kcۤ�̲�x�� C4TӇո��f���\��	6�P~^F-��K^19Y����&C)�#>xٺ-�� S��y��Sވ�VhF�5UD7�V@f�I+9�c�U���X{_��Xa���8$��E�%�Y�X.	��[�M޾Yl��b݇0u�{�U^����b��6(}�)~@�5痖�������:���}�+J�_}���k�`I�)�y&�GCy�a}���`n��Y��9*�Ρ&5�OǴ������2�\@H��~r�s�.m�X���ZVjx���w��}��/|C���D�:
���#[����_��=�XȆ[�a�m��gS��sܶ��4���xhz~O�6�f���7���kL4�?0�Up�ɟq��y�љ:^!����m	�9&���+v4��JQ6vy��b�)_p��PE
)�����Y      �   ;  x��Xˎ�<S_��.�/�n�]؃�5ޓ/�*M7�T�G�{G&)J3^�(�%*��T�i��Ű��m��*�a�í_�sZ�~��m{C���m�����/�0l�Х�/e��Z�L�Lg�B�g�=��U�2Oa��i����6^.������y)��IUv��.���N3>r��r	��D5ͷp��\���º�E�+~��<�6��ά^tIg"$�V�Vԕxُ�q��i��G?��C�o�z�Ӱ�O��|RRR�ιNW����8F��=���۲N��
�ʲ��ʺ��5�*�G?�K?�0 �0��6/\�K*�{і^Y�ζE-�ʈqo����w����ނ_����.���^��WRY��+���J�@5�n���i����iC~���m�U�_?o}:�y�Z*�)�Vh���n˳GŖ�����E�JוM��B��B���q���o�Sާ8�G����_��|�G���kG�5 Q ���� ��p�2t����6;[(MM����Ds{JL��װ�q��i~�^֐2F��i����8Z]9��^���_6��oKYV�q��m-��~��H~0�*��*_TM�κB9�*a�@X�Q	|r�.���3,�0��O3����8����})��lqp��z��y�����R�FU5��E�
��QT�V>��b�z.U�"ԭ��T���G�i�}h<��tS������I�ɠ� ��hW+��K�$������hjJVo�C�0��Ɗ4G4R�����R�ڂ�D��|5I�z�$�/�h��!�m��l�y�1���6j�I?�64��������p�.�~��}L9�P��Кhy03bV�jbɟ&<ut���NX"[
g ��-\3"�����P(�ME���{?���%8�t�	K�~��_w���S�1�x��"� 6�{�&z��2�q��ё�1Q�Ԛ�2_:��*��� #�f"�\t1��p�R�u§��(a�D#k��E�Q�)��Py���-2aEt�f��
�����0�N%�k���~?B�*tK�dJ��p�Q�.��@/(3h\CK�k�"�P^���P�����l���Ae��%K�%i��'X��i��a�6��2	���I�h"��Q�:��� �dǹ\��]��Dw�&%��6(��!Eq��(_�Y���9T��n�:uՕ�0�	���Ʃa� t/+Ж�uͤCCSi[S�$�Њ8bl/�'x��G D�֞�¼��FP�m�gK"�0��}�e����`�
�N<9L.�� �I."�c2��R�yJ"q�I�
Mġ8����:�<�xH�\ю�����~Zh	�� ӝ���[;a+����̃�}��0�,H�t�=�,'��F�y��s14�b=�;*�M)�������%v�;[��H�k����Ã����i̹qY�IA�u�E`ڒ�~H���up��ݶ����f%�a�8Y�T�l|CV��|�m�c�����h�t>olp9��L�a�H{�%�ili�]x²���i��[ �d�*X�w
��Z���j�8��2z�LҎo��/ӊ`	x��Z�iV�Io_s�k�"x���¾�03���6�S�u-�e��2 '64_�F�?�
g�T�h� 
ⶳ��3�ŀ��"���Y���x0�	�тm��TP50�^A�=8}K��,�֜��/�r���0�d04�u�v@5ц�i2C$� f��0�&r8܂M�XԢ"6hŶA�|yܻbw~���z� CB�j��Z�2�����7yC�A)�&frLK8��*�����FU��w�0�hw�I�v7Bg7,ْp������cħ.��s�����#e6E���ᶾ�e�[Y�]C���B-�v&�^-ӝ�X&�������C���`� w�� m�'��+��
���u�qȱ���M�M��Cvψ�J�u�ba�\f�(NSKV���v�;H*�<�^�l<qNXS2��^1dyݯjR�>9��\�C��6�FdX�8j͆����-�]Z�������7O��2N�K�r��������Z�`p�n!��
���w��[�8'�Xs�N�]�`��1�=���g���_+��4�kU0\�)<W�҄ �����rgp�ޥM� ���PW�|-�� m?��G#�K�͂�=���G�h,��	�p���TDk��t#�1�O���q}dLF���%M�Dq��پ��+[�ví���е���^����&H� ��c���O޸�ޠ����DH1S!�z�<�-|�GVڊ���t����(mrZ�.�.��J�S'1���BQ��M��w*���Yf[M:�0Ț䴑t�p���n�"�SZ�.�N� �.D�J7�ޫ��J&�r<�� ���.��s�U�=K]�6HY
`䁹����P�k�v<���H"@��;�Vo�3�.��c/w���n�n����H �`M�~ղ/��7>]i����ȣJDc�N1��7�m���l*�
�Fg���-�� �D�Vchkj�ȵHW<���0 �wl��H��KV&�+�6h��[�4���j�~��ǽ�����EӒ�����k�~�xm�M��������^�r�II�4䊠�5�4�Y��}^�����cɲTi(3ibM�W����������"�-�D�[��W�-5H[jl1�1��s�V�2,5��9�
,b���2x��^��hL��ߡ��T�ɾ]�H�W�0k��VxkM���}�~���+��S7�-]ွ�+�m=8S���Sf��@����:�&1�%�͡���JlR��z,��ص?2���Ȼz�K5�ǒ(��׵(���c2�      �      x��ZYs�6�}�*��X���%�ǎ?˓�T��M�9f�.r)�~���N2ɗ*y"��X�g�R�u��i?V�X�Bm�Bot�6.%l!��$���ˏ�(t��&w�*���+��}]���',re�z&g6��R� T!��n��ϗϛM�*�6ls��C�c�V�s������Ϥ)�&8��,�W�����L�<N8�뮭vr_߷�0�Gy��m��|Bdn��o�άx�TǪ�Ǘ��A\��x&��M��J����z��?vMSc�O�8Two�[ă��j�����m��
���&�fw�j��T�q6�}.�ĺ�MG�����ݰ����-l�7����~�u�ī�7�e��!~W��g28���Z���n�~�B���QF��U����]�?�Ps���B��U���3�<q��I�����*L�Dz�QJ��:ᴨ����u.�I�o�ςx�QI�Mlw,%e7F��O�EA���Hܵ�M����kY��񹼙����#���M�؏��1U�/���'�Y)��F�X���z�FZ�M���+�E!�\���Kp�{�'�f�(���}u�@�`X�*�Q��^�|��6m��h��P���߷�.N�������o�%2.�Umm��y��xq����0"kO����P���آ0B[a��=N���)y�b���y��+Li����Q|��}�"K�>�?Z(��X�\ ���M��TY�4�lq?��6M�?!g� ( C3b}ȍ��mמ2IG�Q�!SV�~B�q��[[��L�����|��`��q���`����v)l�]I G�t�B���}�SU	7'r��x�A������QF�8���*AaHE3!�mE�2�3��(/%.a�V#/N��J���:����q�)�k�	�ײ>=��%�s��\��u��(��!~.�LĒ���z[�ma3�ś�'�/ �te�Yfc�X��8�;�05�5J6�Ub�p�)�8Ka��e*�7�I��,�+��3��RS�V���1d�_U����(��j�Ei���� �,�A�!�+�~���?ǡ�RZ�z��H���!'��%�<���8�����֠�T�s�n[���0l�m<�eua��3%�����hJ�z4r�2���T�w`��BpU*��0%��QCLԎ��I'��FfZ��׈��Y"KB����B���1��e[��4_3���$#�ச�블�%�U�����p�L�%�ul�x�P�P��\�4�y֟K!��4+DlW�'p�IH^(*�2d������T��1q��x����P����"A��:�'b���w`byb��T�d��B��p�/��}�$����
!ƿ��WaCE�/@��M�d�r����b�Q:�T�>>_�be�Ud��w�V_kl���w��m����-��ݯF#,6@'�iT<�E.@�nL,��N%�x��iX�w����!��Ѝ٪@cW�Y�?xo�Ǚ�h��z�mJ����!�!t��|A��v�<����|���<�I$�ߔF#q u�&�"�u����媬-��DJb�y$�]+>ǧ#�h0��BE�7�X��Q�+��:�)$hH�Ңp3C��U���0�ʣ�A&�F'�\�Ժ}݁ 	��^��ط٘P��J39��Agef4��<n`RʂՀ3��Z���е;V��G^��:IDC���?t�'�6��ඞn��/K���;�}�Φa�eMLH`M+^�ʧ� q������NA��yA_��!Ln��">.$1�����v!><5T���'V"�!�,IJ*q�Vf���PW�T��P
NM���y,I�'�Xw���y��qF�=ΥL_����L�d�p7�^����,����51�c��x���W`�P[�pX����v�8v$:d<�IDpV$J�P>��W���qCDqqk���k�C���Hx����Hy�Ms�t�Rі�N}���`HX��<��z�u�^
)�Fw4HP�w]����:LZ$EZW@g��3�_�&�� ��p��<�j����v��a$�����Q�8&Q$l+�K7���[Җේ�d�3��
o�
ݱ����?��4� a�ސ�f��.'34��� sGy���z��l�%��� w~����o]�P^��>��6S�x��4�_�c|���\���6�&xn$����Tf�2�������%�9l�f	5�K�Y(�L����k������z�Z��f�I��(�{���l-��QY� T5�jJo!���y[� ��4���/�%��@�Y�1����Ǥ[�;��PA;���hLpH�K��)m��9i8#(gi[Q �XBS�zxL��qR/>T��ċ��:�a��!���h�wdt����~��Y4cf�U�Y�^�d6��`6���>L�a#ti�"�s�B���KH���h�5�-��a#�C7 ���v:�O��l	y��F��ڎ�נ��H��A\r|�RbH��'%���v��Z��#��+��kM���I� ړr,�Y2�E��jJ�^RuW-�=�+�B���_G����P���O��:�$`�'��LNH�0^g�M�[�<��6�DF�U�&�0� �U�ݷ�a"B{X�$*N�o��Y�)N@ЩSD���j{\�����������hu
�7XuYߧ�l��U��cqb7�wdR@�0���gdʿ��	����( D7�'$ �U�����Q��P��Q�?����� D��`��\+�� m��'�E�-!��Aj0Ѫ���S_K ��[��^�cuQW������W������F\YK�@)� �&Y��Ҕ�n�̟���#%C�����#$[�L�T_Y���ҊR��H�<;��.�0�$��Ȋr�M�޻n������+�bFX�]��uP���t�C#���:���`&�v._��e�6��0Ue�)h�ވ4ǈ��t����s_���:����3�t��s
����S�',L2Ʃ�4}stV�^&��'m�L�9"x��{L��C$В�ӡ�7b+����{j�Ϫ���6�')3g�֨��CjO�Z�f��=>�3会G������-v�Ԩ�_��od.u�yAmV&CU��~�oy=�NB�N��x(fr/s�i���nW���׳��+}D����'|�F	����p�P_��eb��=�A��3����C��& Бl�-+�B�yh>��L��I�m��T�
��DI�g "��Q��!�<<���aB�����gU�^\ou���T��vO�ns,_��v�H�)��u�{Ǝڑf��ng,-��'�!3;��A K�[ׇ[���
�L��e��j��uL��b���'��:��K���g5�M�`�@ep�mR��Ӏ�4�8�y��E�lď��E���2�%���#8º��x��:���)a�u�`^��8�(�p��y�96������5��;~�,�ʂ��=�V@k��|qKڎ��H�c=����SL` .u��ؚhCS��?��o�(��o"X�����o�\�B���j���1�nC���U ��n�~'����~��a��X�cUJ<� �����iF�J/]����4䴣����4�:��<�%�"�g�{9���9����Y�������.���4v���G ��*���q~}9t@�4��4Z@���fDN?pP�>6،�Y����"��2ϱđ����Tʡ �`6�"4TF�v� ���˰��A0���#��y��h���r%T�� �Hn�dؙv�1�U�5�`<Ea���|��a��-U�f
09��mn���/5�B���*�%�\�JjU�9d����׺��,�E?ħc%ރ�=�n������P���4�J>��|%�X�m�̀��0Ӊ��%u��A���ў(O-J�(�i�e�v�V�(���%��7��1_ ��P̂
��a��NS7�5M�B�N�ţ�:7��[��¢�Ɵ97S�ϣ9���ͥ���<�ZL������.ī���&1����l���^�1Y�c���#�w6�8j�̀� c  ��[X��m|xH32�$�K��?'��;sh�F�mL�~h��/��O\/G��.��%�!�]�'Ť3C���Q���|��G��{Z�te8��9����p5z���|�I�eJ2T������>�p�j`(ʎ��sa)\w!��h/��g�������Yɗ��K��|�����<�[�]�f��O4���'�|x��#��>u�ě�{�s�S������a�8��[ͤNf~�d�ҟz�t����6���
%Z4�����X6/'b-���@�7�n~�z��RK��Nbx�[ )�뒆N�3/���l��뻻􀖆�����pٶ�����h�@N��ɦ,��IJΐ�ٿ>z�;�Kij?C�SK�f�D3�W&?ڴ��tjE+���3�ݮJc	��y���iV�ž�N�i�+1�������I�0T߁�&}�ŧ���V�bVW8m��q��s8��)�[�*জ[�1�X���Y�}g�eTuV+z*�ځZ��x_�v��P�92ߘ4= � �������E:���&�4. ��=`e���~ ��/d��Y��'@�Ƀ�!�S��Q��'�;Y�˙��4k^�u��@n��<˲��|�"      �     x�UWّd1����z�6�Ų�Ǳ�����fI���h�͛���C�;�;�#�vL��!!����쏬C�0��<��fm�$C����+��I����������8\�>�jiy�^!�+�#qL��}�=�]����|�>9�����s�O  �2 ��-��v����j�x�mg���W�_�1)( m��Lu?-��zL9�:P�hm�!F(�*� `�]��nh�4�-W�f�T�H�~[b-5�x|�Z9dw�m��<}ݩ�="_�!�6!�m#���jV�x6�i��'��g|(^�B Ƈ?�9�|&pg[����{�c1L���[.REۚ+�z9��ءY�Ì���-/a�Y����2�P�'D�(��
`��o���������)2��.��2y�N�_u>�IB��	FL1B�E;��\$�.�e2m�-�!�5�:���.1��+���3�b�hVo���l1���	��Ԝ�}=�S�oP%x�F[�j&2�~�=�ie�ND�{���@	���3Z�4�s��RC��j��6��� ��^v� �*�YKno�5h�A&@���p��=��z);���iB��h�|��P��@��x��S	#En̊���1�62���a�޸��b��q�g#��/#�������9���(AK	k\�9a��'b�T���h�lΖv��bi��R���˛�����;���<�)Xʟ&o\�M8�1Wjn�3 ��. ���~�D�Gw��Jr2~<�����w3���!�CN���zpq �U��2��p��eb��"�o&T�������𒉿� ۱NX�D�q��\��<�$v���W.�;�Sy#�J��})���;_���ܛ��W<��vX�ҿK� �:�+{����%r,Rx�"���
�Oݛ�67�f�v/uVSvDN������� �4�fw�tNt�����/�lԥ�%�?g�cRG�AV�Wq����d���e���{>S|�9S	���y^5��G&��y�%��1�Ԣ��~>8pL��˼M"��(��q��eYLc��F[�|Qʦ��k�^h�D�	0�K�S��x#�E�:3:�졿�c-΍��&� ;��ī��"V���r����r���F����7��#�h�7oJ����ܾ|G
t)��V���ᠾ;��yn�i�6����(z��#�)�{jh٧΂�y���	��$�~���4��	�������&,�1;�sY�z���!A��S �-X�$�fO�f�T�ސILf%[G4"s�"��+�?����u/�(�)�C� �K��F(Wܬk=k���Zl��.jB��R0�q�w�k��$^G=k@�޽�l�ܤ/������xJ����V�wV���:Y����:���~�^��n:�N���J2�В��E��J�3�v�_�,�Z�ȅ��#?�ۤoB��h��}����"��	.������56�E��q�r���㋔<��QH�5��i�'n~���tV�3W�t���<�����w������X0      �   .  x�%��q1�"��\��7>���#!h���kV��cw���+:�K{����3�O�˽��?�g�"�8��b��ܻ�߻�^�"ro�g�^?�uo��6�kw�W����'�{Mv�*�xk��;��5]��}���[�^�zl�C�=�o�wbUo��G�gĎL��hn�S+3�w�ثr6wsᬪ��^�ҧ��Pe�e��b++`���3�H�݀��j���u��ch�m�O`N��2�vku�|n�%��h��� u{{ݨ&��_��dM?�s�	�*��_n%�_�k_���U�����X&�urg�&M��D�Y�a	������hN�pU�aA����%�q����(���;���B(�T��5��h�9�Q�?>w����-s5X*�կ�o�K��˞�ٷA�غ�Tz�H��@�;����R�����qRA3��J��Z�_m�k�m���vz���n�_-<7�*=��/�Y�\\�e����w�|�9?1�vR
�̺�bZ����*�8��V����dX]ey�:��� �r^��xҭM̦Z2JZ��U-�R?$D]O��.?VzB�TG�2�zw4�Hk�=94}�+�Z�>,���\�=�aS�l�ԩ���b ���q�c�%���W���J�~_��v1=���L�)�1񞒾���<�!��Vw3�ô
�d�+���^j�4
|&�
�0�J�Fl��i�djj���^:Aꃱ�G	 �)�]Jd�2��wb��[ݔ�a#vzۧ�>��8�36D��Ļ2vC)�FÌ�û����'��3�_]      �   #   x�3�L����/O-�2�,.M*N.�Lrb���� �/�      �   �  x�UV���J{ޭ"��rۋk����H$��f�ư!	�����4j�1�d]1�1������7�z����|��%W�K���;s�?��\�/�W�K�G�v䓪o���\��J�MP�����r^�.�˼�f���oA�|"�w�������,���4�m��*~��b�G;~W�o��8
��EZ��O��c�X���z'�|~��ɆY��/�Q*CS���e���9��Kв]]�Y��״�m��e�U���"oq�i,���Y�/Yފ�W��;�>�@΂�aȑm3p��f����-��l3T�z�� P����:�W��m7����� *�RcezG'��\q�zR��-B��Fn�5�>�Ϻؕ����4�a'xaCًpn��+e��#�����q`���uN�����w��1�emKeY���?���j;�lLK2�#�T�y?���%P��f�{h{�&�e��.�����c�`��4��Í5�fU\9k����r\��i�AyٹÐ����y��R��j��/ c�C�3n�r|�CP1��o���ŁЊ������6��0��P8�qR>�t����;<R]0*�ܻ�*V�h]a��Z��D�*�M��(M�Y��L"�6�vB&V5B�,d�4׺1Q��lH3�[�#�� ڢ��:��}~�(Rg�klx7��֦~~����-�³�UhHӀ+��,�7s�`��sS�1�칋�B�c/i�����H��ĠK�wi��-*Ģ�i(.�_�/�ʠ�a7@z�7�#�9lx҇o�}�m��֌y)��k�eR|&h��$�N}a%N簶ި��iĹ@���e���ɉ��f�rjًh1�%J[��j�\�hL��M�g����!����>�k�)9Z׎���Y!���
.�%��.l�M�YR�(	�ͣ�� n[T�<�g�F��%�H��*a5�'�:�L2Ͳ�I4͝��I��- Fi�>��12}�$�s��iv�R��Z�ǥLT�:4�U·������]�x�YF�'d�ݧ������A�aβ��u�Ͱ5x��
�B!��a�Pw��&<!7.	�l�,�E�`�8���W���"t4��N*^0�'��!y�Rr��
�}�G����kv�tمI;���yN��{t|N�E_`�^�$MS )NC��s�,V�#�y���p5���iԭ�r�W��~&�hϊ�s\�������wH�U^"t0��ʺy�M��ӱsA���n7�e��c�(gV��֎������A�      �   @   x�3�,*-.�L��2�L�K��,��2�L,*�2�L�����K�2�LO�1�8�3KJ@�=... Kk5      �   p
  x�mXے�@}��B��6��rQ0��Zk�Ap��n��o&�6�n�<t�T�'O�<�H��5�	:^F����pj�$�#It�P\eDz�����f��ц��3��_�8�m�g�QX����N�-�!�5���R���0v7������fp{ ��P�M�5w!����zhҌ�I`� \ۺ��T��Y`�D�����H��WIQw�DX���e�>��Jy==o�S�v���pX#y��iO>Xs�X����i`�Ⱥ)���A�w����	�x�c��W���קN��X�Bז,�$��i ��]om��ֵ���t;�!^�Ҳ*t{���n���(��Bbk/���iU	/��m?��Jτv�Q�������.0�r�� �MI�YsF໼�����8re�r�z\��dcO���W�Q�y�˰Ԥ��^�ɤ�������#�i��zM�J*7V����ME�7j�:��m���P~1�Y�B
7����T���@��#N|ϼ��I?�v�%�}U���TxC#ˎ�C;Ԍ\饁{c���g�?HNI�V����	�ķ�~�{:BO/|x� ���A �y��?k��5�@>�E���x��1L����+W�!�D����_�rG]�n���� ���9Y*f1���XD��;����2A�a��[<(�\P��x�N��� |EZ��n����;z�$��z��Ŀ��,C[�Q�x^&{ޜX3�	�6v���Se����~���VRȁ6��8���l���q�7�?�B@�MC��b��@�.��J��II#!��ENO#3q���[G�\w�8ئ�N����?�)���z����	�ڭ��^x�\x� g�j�w�p�K`yQ�f�
����T'I�A:^1���&��A�o!myA\Y_��}�_N��!��X͐��H��g�r�� tk��*�ӕ�؅#�(�	���J�	(�>�_�š����(o��c/�2�)oP�A.�nW
�b�g��?��-BMJO+&�W��^S�9�4�x4K�wtג�&��x	�����ؙ	�KX ���Y��� �l�������f�&E�FI��(ttW�{/�Dnd(�m�X��2��v|���/��PjRz]m%�@�9$c�h=%8��ąs~m��%�r��NS$�㠜'��8±Cbk���;ltE$	k2i�i��;��l�`�R����b)$p���w�o�@&�Y����~��*U��u���Ș
�s�v�*��D֙`�뵴���XpZ+dY�l�O��?{m��eӍŮ�J�#�nso��!����c^�������'Fo����K���{��k
�f�'WV(0�N�� :�o��ǣ�ZQ��vQM�À�[CLwg"��~�w���R.�En����8�F����$-�b�;�h%�E����_Y}�U{���#�<Uh�z[�tV$T���Q�H{���9�E1�-_D�D��j	`���0h�a���p���`{Ъo�`��	R��A����[)��a@q��I��Ѝ��ߟ~�Y��(�e9֋U
(�*X���֯n@t��J�R��2#�H ު޲�_���ه�^ƾY�8Su0����i^\C��uic�r��GQ���D�1d�����ykZy����S3�k���C�4up*�dztC�̀Y �i����;♭�fe;�Cy�D�}0*�:g�H��f��G��:�0
u�B���?�3*U9�yxA&)?}���}�3� ��J��"2<
�)0��!H��c�z:�toU�6�_SI2�=`'��I �q��1�����(r hy7� c×����L%�|e��^�*R��cw���ل)�PT7v!���:�� > wP�&$�@�0��~:k��~NԚ��4�*1d'�g��`�A������?N�O��l��E��E�r� 8XTM���=������v�s�*$����@��i����{[e�'SK$�c���a�H�{������v��($�����%�����G�ɸU���,��Sa���Ψ���z텒�ۺ�
���=䶧7�\�`k�l�WY��sp�*�:�?�C��9c��-U��l�<�P��d����tk{X���br�X5����S�&9|�W6�>����լ��o���>�=De,� p0t�\�}zi�|/IIi��E$�3
�.EkO5��V��/��T�!|�l�~ �+�8�i�[ݽ�f2!L�7k?/�Z�l�y�|��2�Z��e)�)��J6�	��.��e-̵�j.�ih�\@
�[�Z�t�)e�jktvp��wS<߹�{��g�T䖔��Jt��+�8��m�����y��1���SP�G������6E��^�9^6�3,M�a�J���A=�7$+J�M�	��n ���կa���7��2�7q��Y&ikJ��R�s3�lQ�B[�	;����6�z�ׂ���jfGU:��b�/0b���V�i+sY)����xL��͚��'6<�G�Z�F��q��/MO� ����	��}��.?[&>��
+#�_�L�8&�X���Y��6r��4Ȇ��y,'0�q+~�l_�3L�
K�H�p!�L[�n{���-�W�/H�+knb-���$<�����m�^��r��ooo�M
�      �     x��Zˎ#�<'�� 	E�[�Ŭ����{�Z��&��֣��#��j����]hzT,2322"9���:�y�������ڝwT�t�ߖ���i\�IO��N�߸��A�z��'}v�77��J��vo���GSmG]�J���0�~�^.�A����~_/�u��v�:Sg�^���1Lx�o�~ދYQ�N����YS���E��}������XG~�2΋�"�8�_��8�x�r_�{kua��9=�M�j����u���f���.*|�X��l����'�?l����vz8Q�N��<^��<Nò��O�یq��=f<u[o'�>��ޛ*��td�Z���������xqV=SM���8](�#�����?�@B�ce��+��&����=��\\��@M!oW}s/o���E�ë[���BVʽ�u����X��pE.��j�*ٚf��>�p��}:����Vr� ����)��~Y�ǰ�;�5�;j ��H#F�y���~_T���8�/;e=�qq޸�/韫��dQ_�����^�����Mw����۰�n�ʷǛ��o��u���%Z�l;}^����e��j�pʎ���X���F��nwgx� ����y��+�|���HYʽm4UVG� &�2��������<t���|G]��e亓P�����.HX̄�LH�!��s�L����_�c@w;��~�g�oJ�)2�iY���2M�ν^������$��gy��wwtD��p��:�tc�uu�ԧQ�%��Ta	<JmO���$�V
��/�%8�-�SU
H�O'w��^r]\�/�	 �\O��a����i��i�鸇HXg7 ;J��b��k�J�����{�`�˂oS_ӧ��X��0};�װb��-`4�Ԗ�ABy�i��=�1s9V_Oe�>���`E�ث;Fp�T
 ��LC��?�ց���~��7�k'���\X pw*^܀ю�����Z������p}o�g�4�C���G�R��aKz��L�4�rm%R��~���[�3����,�pR�+�K���XT��E���0#ˏ�{ڂ�,�I���1��4��X�Z�@��tZ�wnh/h�W�z|yL����	Wp+�~c	uź�OyBQ�i�c�PZl]�[�~O/!C�d0,xۺ��蝵��w�~��QS�~�ӈ�?��-����������}���=�%䗘�4�20C�vO��LN���!dQ��|���
��I�(���ώ��ž�H��|N��ֈ�(�7�0:U$�IސU��O���7���i�Cw�t����ԩ	�a���F��rBcS� �He-��ArV���}�}����#"^�V��2w��/���:6��M��:?@ ��7w�ɐ7ar���A����TY�NxIrRo(d��
Z7�O�����D�q�(�BO��K���,l>��zY&��8��O�86�&��M��W�55	�"�}d����9��+A�py��ˀ�-��E���"�*ɔ���gQ�i��?d+l���8-����Y��|3_m\�Q�0:ʙ�V�����	��q�D�FF�bź��!Y�K�PW��[*�e�����=�LqP�"�M��o��?�`��U�"�x5�Tc�F� R�Gɘ�?����O�5�Y	MV�E�Z�%Dh�+H|���	0q\]�ub��tU�:���+�pvl�qXFA]JWfMI���LE	��J3�[���=�S�'v&5��CF�a���o��X�$9���+UGB��]��-��+��
�?^��!��Vtd�ʬ6�}��-�F΢G�� 4�=R�sΒ3��W���h��&���"!2��t����NËc;�Q�P��� 6�B�$��fP�n�Y)�ӓ�m)���l|�����E�����]>k����=��~Z'��1~W��͟��gx7�dj*{va�	q�xi
`H��u����Fv�7���iٖU=�J�f��Hi�o�J}�m�.~TQ'��
j ؋;ܖh�K�1IB�X�6V�tEӈ(��"��֌U#�}�r�r-˝B�8Y8��H���,Va�k ^�UP[����PWE.��[��zua�s����2�n:j��#
�a���6�*�8�W!U���EUrQ�$8�hfN�)Uh:t��2X�X�K-u��X��}2���_>
�o��B�;����Q5��0� ^��(hg@$*d��q}u8�~���K>�P�GmE��������I�*X`p�p��k(vV�T6����j����z_Ѭ05����˃��nn e��N~�H��Yd�o�#�3@��oqI ^�bO�j�oH]��lH��^�E�T��1���xy���"�^�\�َ*y#��=�w�.��d���Y�>ikv*=|B�������B�3,ߎ�ܑ���N�b^�L'�]V�⦍�IVGxRSX��L|���G8OR+�26��7�@]
�)��e;f��Vp�=�A$F�|g^��<�$��a,E�s7k@V��QMK����?��<��i6���8`��I ���Ƽ<�.⻀͙-9�%�\V�7i[q�d����iޔ��@瀈�N�ų�<�4�A��Z��ԡ�-4dU��M�e�l'Ύ	�y��jQщP�����b	�~�"e�#�͈���0�|z5�� ��?�AՖb/��@���D1����XI�3��,����B���Z���}��yHV�ѷt����adz(q��8�Kn��'Q��|���nS�R�<�m�OS�xX�2H�+���J�f�	� =-m�lH�N#�"������?�������\U�/D�y�;`�,.��i��N'��I+e��Fdz���\3�@���Fe�$��M���<n٨���d���d�Aߤ������7C7�D�,X!õ�Gi��}�;#������G�e�U���φ�<��}���@C��6���E?�M��c�@��۫�������*IL>��*͖���XAx_�Xuv~?W��4�NDp?�*x�,�kd�$&R����7�s�o4�M�B��;v�e�����|{��a��5#bL�|q�)H�������J��C0�Cf$�I�������YY + mq���F.����r�!M���� D��ۻ��G�F9Zh�!Ʊo\�y�	�+��.�4�\-�c-5}�@��<W�����1�l��B����{��[�&��D8ǡ�o̸��e����c��g�!�k���D|�ѳ��*L�lժ&��x1����_�lg�Z䑷��E���<�EkC�A�u���ߺ~��O�6QE�ZH��	-V�o� ]d%�]�_��
�m5/}�~�H�-�ϴ2���E�?*{�}Hb��qx�=�YψÕk\tFj9�-�9,4Rd�a�#e���V�sep�dsj8o�e��Y䭣8@�&F���{�|���rG[X�?���7q��ɏ�p2���}���0�mx5��OR������=Ű�'FCX���j�R���&��;��j�|��i"����n
�/N��?��Z�J��E�)4     