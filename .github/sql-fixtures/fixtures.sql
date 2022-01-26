PGDMP  	    $                     z            taiga    12.3 (Debian 12.3-1.pgdg100+1)    13.4 �              0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    317641    taiga    DATABASE     Y   CREATE DATABASE taiga WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';
    DROP DATABASE taiga;
                taiga    false            �           1255    318790    array_distinct(anyarray)    FUNCTION     �   CREATE FUNCTION public.array_distinct(anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
              SELECT ARRAY(SELECT DISTINCT unnest($1))
            $_$;
 /   DROP FUNCTION public.array_distinct(anyarray);
       public          taiga    false            �           1255    319201 '   clean_key_in_custom_attributes_values()    FUNCTION     �  CREATE FUNCTION public.clean_key_in_custom_attributes_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                       DECLARE
                               key text;
                               project_id int;
                               object_id int;
                               attribute text;
                               tablename text;
                               custom_attributes_tablename text;
                         BEGIN
                               key := OLD.id::text;
                               project_id := OLD.project_id;
                               attribute := TG_ARGV[0]::text;
                               tablename := TG_ARGV[1]::text;
                               custom_attributes_tablename := TG_ARGV[2]::text;

                               EXECUTE 'UPDATE ' || quote_ident(custom_attributes_tablename) || '
                                           SET attributes_values = json_object_delete_keys(attributes_values, ' || quote_literal(key) || ')
                                          FROM ' || quote_ident(tablename) || '
                                         WHERE ' || quote_ident(tablename) || '.project_id = ' || project_id || '
                                           AND ' || quote_ident(custom_attributes_tablename) || '.' || quote_ident(attribute) || ' = ' || quote_ident(tablename) || '.id';
                               RETURN NULL;
                           END; $$;
 >   DROP FUNCTION public.clean_key_in_custom_attributes_values();
       public          taiga    false            ~           1255    318760 !   inmutable_array_to_string(text[])    FUNCTION     �   CREATE FUNCTION public.inmutable_array_to_string(text[]) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT array_to_string($1, ' ', '')$_$;
 8   DROP FUNCTION public.inmutable_array_to_string(text[]);
       public          taiga    false            �           1255    319200 %   json_object_delete_keys(json, text[])    FUNCTION     �  CREATE FUNCTION public.json_object_delete_keys(json json, VARIADIC keys_to_delete text[]) RETURNS json
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
                   SELECT COALESCE ((SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
                                       FROM json_each("json")
                                      WHERE "key" <> ALL ("keys_to_delete")),
                                    '{}')::json $$;
 Y   DROP FUNCTION public.json_object_delete_keys(json json, VARIADIC keys_to_delete text[]);
       public          taiga    false            �           1255    319325 &   json_object_delete_keys(jsonb, text[])    FUNCTION     �  CREATE FUNCTION public.json_object_delete_keys(json jsonb, VARIADIC keys_to_delete text[]) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
                   SELECT COALESCE ((SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
                                       FROM jsonb_each("json")
                                      WHERE "key" <> ALL ("keys_to_delete")),
                                    '{}')::text::jsonb $$;
 Z   DROP FUNCTION public.json_object_delete_keys(json jsonb, VARIADIC keys_to_delete text[]);
       public          taiga    false                       1255    318788    reduce_dim(anyarray)    FUNCTION     �  CREATE FUNCTION public.reduce_dim(anyarray) RETURNS SETOF anyarray
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
            DECLARE
                s $1%TYPE;
            BEGIN
                IF $1 = '{}' THEN
                	RETURN;
                END IF;
                FOREACH s SLICE 1 IN ARRAY $1 LOOP
                    RETURN NEXT s;
                END LOOP;
                RETURN;
            END;
            $_$;
 +   DROP FUNCTION public.reduce_dim(anyarray);
       public          taiga    false            �           1255    318791    update_project_tags_colors()    FUNCTION     �  CREATE FUNCTION public.update_project_tags_colors() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            DECLARE
            	tags text[];
            	project_tags_colors text[];
            	tag_color text[];
            	project_tags text[];
            	tag text;
            	project_id integer;
            BEGIN
            	tags := NEW.tags::text[];
            	project_id := NEW.project_id::integer;
            	project_tags := '{}';

            	-- Read project tags_colors into project_tags_colors
            	SELECT projects_project.tags_colors INTO project_tags_colors
                FROM projects_project
                WHERE id = project_id;

            	-- Extract just the project tags to project_tags_colors
                IF project_tags_colors != ARRAY[]::text[] THEN
                    FOREACH tag_color SLICE 1 in ARRAY project_tags_colors
                    LOOP
                        project_tags := array_append(project_tags, tag_color[1]);
                    END LOOP;
                END IF;

            	-- Add to project_tags_colors the new tags
                IF tags IS NOT NULL THEN
                    FOREACH tag in ARRAY tags
                    LOOP
                        IF tag != ALL(project_tags) THEN
                            project_tags_colors := array_cat(project_tags_colors,
                                                             ARRAY[ARRAY[tag, NULL]]);
                        END IF;
                    END LOOP;
                END IF;

            	-- Save the result in the tags_colors column
                UPDATE projects_project
                SET tags_colors = project_tags_colors
                WHERE id = project_id;

            	RETURN NULL;
            END; $$;
 3   DROP FUNCTION public.update_project_tags_colors();
       public          taiga    false            �           1255    318789    array_agg_mult(anyarray) 	   AGGREGATE     w   CREATE AGGREGATE public.array_agg_mult(anyarray) (
    SFUNC = array_cat,
    STYPE = anyarray,
    INITCOND = '{}'
);
 0   DROP AGGREGATE public.array_agg_mult(anyarray);
       public          taiga    false            �           3600    318688    english_stem_nostop    TEXT SEARCH DICTIONARY     {   CREATE TEXT SEARCH DICTIONARY public.english_stem_nostop (
    TEMPLATE = pg_catalog.snowball,
    language = 'english' );
 8   DROP TEXT SEARCH DICTIONARY public.english_stem_nostop;
       public          taiga    false            �           3602    318689    english_nostop    TEXT SEARCH CONFIGURATION     �  CREATE TEXT SEARCH CONFIGURATION public.english_nostop (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR asciiword WITH public.english_stem_nostop;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR word WITH public.english_stem_nostop;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR hword_part WITH public.english_stem_nostop;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR hword_asciipart WITH public.english_stem_nostop;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR asciihword WITH public.english_stem_nostop;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR hword WITH public.english_stem_nostop;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.english_nostop
    ADD MAPPING FOR uint WITH simple;
 6   DROP TEXT SEARCH CONFIGURATION public.english_nostop;
       public          taiga    false    2224            �            1259    317950    attachments_attachment    TABLE     �  CREATE TABLE public.attachments_attachment (
    id integer NOT NULL,
    object_id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    attached_file character varying(500),
    is_deprecated boolean NOT NULL,
    description text NOT NULL,
    "order" integer NOT NULL,
    content_type_id integer NOT NULL,
    owner_id integer,
    project_id integer NOT NULL,
    name character varying(500) NOT NULL,
    size integer,
    sha1 character varying(40) NOT NULL,
    from_comment boolean NOT NULL,
    CONSTRAINT attachments_attachment_object_id_check CHECK ((object_id >= 0))
);
 *   DROP TABLE public.attachments_attachment;
       public         heap    taiga    false            �            1259    317948    attachments_attachment_id_seq    SEQUENCE     �   CREATE SEQUENCE public.attachments_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.attachments_attachment_id_seq;
       public          taiga    false    233                       0    0    attachments_attachment_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.attachments_attachment_id_seq OWNED BY public.attachments_attachment.id;
          public          taiga    false    232            �            1259    317997 
   auth_group    TABLE     f   CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);
    DROP TABLE public.auth_group;
       public         heap    taiga    false            �            1259    317995    auth_group_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.auth_group_id_seq;
       public          taiga    false    237                       0    0    auth_group_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;
          public          taiga    false    236            �            1259    318007    auth_group_permissions    TABLE     �   CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);
 *   DROP TABLE public.auth_group_permissions;
       public         heap    taiga    false            �            1259    318005    auth_group_permissions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.auth_group_permissions_id_seq;
       public          taiga    false    239                       0    0    auth_group_permissions_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;
          public          taiga    false    238            �            1259    317989    auth_permission    TABLE     �   CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);
 #   DROP TABLE public.auth_permission;
       public         heap    taiga    false            �            1259    317987    auth_permission_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.auth_permission_id_seq;
       public          taiga    false    235                        0    0    auth_permission_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;
          public          taiga    false    234                       1259    318880    contact_contactentry    TABLE     �   CREATE TABLE public.contact_contactentry (
    id integer NOT NULL,
    comment text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL
);
 (   DROP TABLE public.contact_contactentry;
       public         heap    taiga    false                       1259    318878    contact_contactentry_id_seq    SEQUENCE     �   CREATE SEQUENCE public.contact_contactentry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.contact_contactentry_id_seq;
       public          taiga    false    271            !           0    0    contact_contactentry_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.contact_contactentry_id_seq OWNED BY public.contact_contactentry.id;
          public          taiga    false    270            &           1259    319216 %   custom_attributes_epiccustomattribute    TABLE     �  CREATE TABLE public.custom_attributes_epiccustomattribute (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    type character varying(16) NOT NULL,
    "order" bigint NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    extra jsonb
);
 9   DROP TABLE public.custom_attributes_epiccustomattribute;
       public         heap    taiga    false            %           1259    319214 ,   custom_attributes_epiccustomattribute_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_epiccustomattribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 C   DROP SEQUENCE public.custom_attributes_epiccustomattribute_id_seq;
       public          taiga    false    294            "           0    0 ,   custom_attributes_epiccustomattribute_id_seq    SEQUENCE OWNED BY     }   ALTER SEQUENCE public.custom_attributes_epiccustomattribute_id_seq OWNED BY public.custom_attributes_epiccustomattribute.id;
          public          taiga    false    293            (           1259    319227 ,   custom_attributes_epiccustomattributesvalues    TABLE     �   CREATE TABLE public.custom_attributes_epiccustomattributesvalues (
    id integer NOT NULL,
    version integer NOT NULL,
    attributes_values jsonb NOT NULL,
    epic_id integer NOT NULL
);
 @   DROP TABLE public.custom_attributes_epiccustomattributesvalues;
       public         heap    taiga    false            '           1259    319225 3   custom_attributes_epiccustomattributesvalues_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_epiccustomattributesvalues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 J   DROP SEQUENCE public.custom_attributes_epiccustomattributesvalues_id_seq;
       public          taiga    false    296            #           0    0 3   custom_attributes_epiccustomattributesvalues_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.custom_attributes_epiccustomattributesvalues_id_seq OWNED BY public.custom_attributes_epiccustomattributesvalues.id;
          public          taiga    false    295                       1259    319091 &   custom_attributes_issuecustomattribute    TABLE     �  CREATE TABLE public.custom_attributes_issuecustomattribute (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    "order" bigint NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    type character varying(16) NOT NULL,
    extra jsonb
);
 :   DROP TABLE public.custom_attributes_issuecustomattribute;
       public         heap    taiga    false                       1259    319089 -   custom_attributes_issuecustomattribute_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_issuecustomattribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 D   DROP SEQUENCE public.custom_attributes_issuecustomattribute_id_seq;
       public          taiga    false    282            $           0    0 -   custom_attributes_issuecustomattribute_id_seq    SEQUENCE OWNED BY        ALTER SEQUENCE public.custom_attributes_issuecustomattribute_id_seq OWNED BY public.custom_attributes_issuecustomattribute.id;
          public          taiga    false    281                        1259    319148 -   custom_attributes_issuecustomattributesvalues    TABLE     �   CREATE TABLE public.custom_attributes_issuecustomattributesvalues (
    id integer NOT NULL,
    version integer NOT NULL,
    attributes_values jsonb NOT NULL,
    issue_id integer NOT NULL
);
 A   DROP TABLE public.custom_attributes_issuecustomattributesvalues;
       public         heap    taiga    false                       1259    319146 4   custom_attributes_issuecustomattributesvalues_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_issuecustomattributesvalues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 K   DROP SEQUENCE public.custom_attributes_issuecustomattributesvalues_id_seq;
       public          taiga    false    288            %           0    0 4   custom_attributes_issuecustomattributesvalues_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.custom_attributes_issuecustomattributesvalues_id_seq OWNED BY public.custom_attributes_issuecustomattributesvalues.id;
          public          taiga    false    287                       1259    319102 %   custom_attributes_taskcustomattribute    TABLE     �  CREATE TABLE public.custom_attributes_taskcustomattribute (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    "order" bigint NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    type character varying(16) NOT NULL,
    extra jsonb
);
 9   DROP TABLE public.custom_attributes_taskcustomattribute;
       public         heap    taiga    false                       1259    319100 ,   custom_attributes_taskcustomattribute_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_taskcustomattribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 C   DROP SEQUENCE public.custom_attributes_taskcustomattribute_id_seq;
       public          taiga    false    284            &           0    0 ,   custom_attributes_taskcustomattribute_id_seq    SEQUENCE OWNED BY     }   ALTER SEQUENCE public.custom_attributes_taskcustomattribute_id_seq OWNED BY public.custom_attributes_taskcustomattribute.id;
          public          taiga    false    283            "           1259    319161 ,   custom_attributes_taskcustomattributesvalues    TABLE     �   CREATE TABLE public.custom_attributes_taskcustomattributesvalues (
    id integer NOT NULL,
    version integer NOT NULL,
    attributes_values jsonb NOT NULL,
    task_id integer NOT NULL
);
 @   DROP TABLE public.custom_attributes_taskcustomattributesvalues;
       public         heap    taiga    false            !           1259    319159 3   custom_attributes_taskcustomattributesvalues_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_taskcustomattributesvalues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 J   DROP SEQUENCE public.custom_attributes_taskcustomattributesvalues_id_seq;
       public          taiga    false    290            '           0    0 3   custom_attributes_taskcustomattributesvalues_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.custom_attributes_taskcustomattributesvalues_id_seq OWNED BY public.custom_attributes_taskcustomattributesvalues.id;
          public          taiga    false    289                       1259    319113 *   custom_attributes_userstorycustomattribute    TABLE     �  CREATE TABLE public.custom_attributes_userstorycustomattribute (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    description text NOT NULL,
    "order" bigint NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    type character varying(16) NOT NULL,
    extra jsonb
);
 >   DROP TABLE public.custom_attributes_userstorycustomattribute;
       public         heap    taiga    false                       1259    319111 1   custom_attributes_userstorycustomattribute_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_userstorycustomattribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 H   DROP SEQUENCE public.custom_attributes_userstorycustomattribute_id_seq;
       public          taiga    false    286            (           0    0 1   custom_attributes_userstorycustomattribute_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.custom_attributes_userstorycustomattribute_id_seq OWNED BY public.custom_attributes_userstorycustomattribute.id;
          public          taiga    false    285            $           1259    319174 1   custom_attributes_userstorycustomattributesvalues    TABLE     �   CREATE TABLE public.custom_attributes_userstorycustomattributesvalues (
    id integer NOT NULL,
    version integer NOT NULL,
    attributes_values jsonb NOT NULL,
    user_story_id integer NOT NULL
);
 E   DROP TABLE public.custom_attributes_userstorycustomattributesvalues;
       public         heap    taiga    false            #           1259    319172 8   custom_attributes_userstorycustomattributesvalues_id_seq    SEQUENCE     �   CREATE SEQUENCE public.custom_attributes_userstorycustomattributesvalues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 O   DROP SEQUENCE public.custom_attributes_userstorycustomattributesvalues_id_seq;
       public          taiga    false    292            )           0    0 8   custom_attributes_userstorycustomattributesvalues_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.custom_attributes_userstorycustomattributesvalues_id_seq OWNED BY public.custom_attributes_userstorycustomattributesvalues.id;
          public          taiga    false    291            �            1259    317679    django_admin_log    TABLE     �  CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);
 $   DROP TABLE public.django_admin_log;
       public         heap    taiga    false            �            1259    317677    django_admin_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.django_admin_log_id_seq;
       public          taiga    false    209            *           0    0    django_admin_log_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;
          public          taiga    false    208            �            1259    317655    django_content_type    TABLE     �   CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);
 '   DROP TABLE public.django_content_type;
       public         heap    taiga    false            �            1259    317653    django_content_type_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.django_content_type_id_seq;
       public          taiga    false    205            +           0    0    django_content_type_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;
          public          taiga    false    204            �            1259    317644    django_migrations    TABLE     �   CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);
 %   DROP TABLE public.django_migrations;
       public         heap    taiga    false            �            1259    317642    django_migrations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.django_migrations_id_seq;
       public          taiga    false    203            ,           0    0    django_migrations_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;
          public          taiga    false    202            E           1259    319683    django_session    TABLE     �   CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);
 "   DROP TABLE public.django_session;
       public         heap    taiga    false            )           1259    319326    djmail_message    TABLE     �  CREATE TABLE public.djmail_message (
    uuid character varying(40) NOT NULL,
    from_email character varying(1024) NOT NULL,
    to_email text NOT NULL,
    body_text text NOT NULL,
    body_html text NOT NULL,
    subject character varying(1024) NOT NULL,
    data text NOT NULL,
    retry_count smallint NOT NULL,
    status smallint NOT NULL,
    priority smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    sent_at timestamp with time zone,
    exception text NOT NULL
);
 "   DROP TABLE public.djmail_message;
       public         heap    taiga    false            +           1259    319337    easy_thumbnails_source    TABLE     �   CREATE TABLE public.easy_thumbnails_source (
    id integer NOT NULL,
    storage_hash character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    modified timestamp with time zone NOT NULL
);
 *   DROP TABLE public.easy_thumbnails_source;
       public         heap    taiga    false            *           1259    319335    easy_thumbnails_source_id_seq    SEQUENCE     �   CREATE SEQUENCE public.easy_thumbnails_source_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.easy_thumbnails_source_id_seq;
       public          taiga    false    299            -           0    0    easy_thumbnails_source_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.easy_thumbnails_source_id_seq OWNED BY public.easy_thumbnails_source.id;
          public          taiga    false    298            -           1259    319345    easy_thumbnails_thumbnail    TABLE     �   CREATE TABLE public.easy_thumbnails_thumbnail (
    id integer NOT NULL,
    storage_hash character varying(40) NOT NULL,
    name character varying(255) NOT NULL,
    modified timestamp with time zone NOT NULL,
    source_id integer NOT NULL
);
 -   DROP TABLE public.easy_thumbnails_thumbnail;
       public         heap    taiga    false            ,           1259    319343     easy_thumbnails_thumbnail_id_seq    SEQUENCE     �   CREATE SEQUENCE public.easy_thumbnails_thumbnail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.easy_thumbnails_thumbnail_id_seq;
       public          taiga    false    301            .           0    0     easy_thumbnails_thumbnail_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.easy_thumbnails_thumbnail_id_seq OWNED BY public.easy_thumbnails_thumbnail.id;
          public          taiga    false    300            /           1259    319371 #   easy_thumbnails_thumbnaildimensions    TABLE     K  CREATE TABLE public.easy_thumbnails_thumbnaildimensions (
    id integer NOT NULL,
    thumbnail_id integer NOT NULL,
    width integer,
    height integer,
    CONSTRAINT easy_thumbnails_thumbnaildimensions_height_check CHECK ((height >= 0)),
    CONSTRAINT easy_thumbnails_thumbnaildimensions_width_check CHECK ((width >= 0))
);
 7   DROP TABLE public.easy_thumbnails_thumbnaildimensions;
       public         heap    taiga    false            .           1259    319369 *   easy_thumbnails_thumbnaildimensions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.easy_thumbnails_thumbnaildimensions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 A   DROP SEQUENCE public.easy_thumbnails_thumbnaildimensions_id_seq;
       public          taiga    false    303            /           0    0 *   easy_thumbnails_thumbnaildimensions_id_seq    SEQUENCE OWNED BY     y   ALTER SEQUENCE public.easy_thumbnails_thumbnaildimensions_id_seq OWNED BY public.easy_thumbnails_thumbnaildimensions.id;
          public          taiga    false    302                       1259    319032 
   epics_epic    TABLE     �  CREATE TABLE public.epics_epic (
    id integer NOT NULL,
    tags text[],
    version integer NOT NULL,
    is_blocked boolean NOT NULL,
    blocked_note text NOT NULL,
    ref bigint,
    epics_order bigint NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    subject text NOT NULL,
    description text NOT NULL,
    client_requirement boolean NOT NULL,
    team_requirement boolean NOT NULL,
    assigned_to_id integer,
    owner_id integer,
    project_id integer NOT NULL,
    status_id integer,
    color character varying(32) NOT NULL,
    external_reference text[]
);
    DROP TABLE public.epics_epic;
       public         heap    taiga    false                       1259    319030    epics_epic_id_seq    SEQUENCE     �   CREATE SEQUENCE public.epics_epic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.epics_epic_id_seq;
       public          taiga    false    278            0           0    0    epics_epic_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.epics_epic_id_seq OWNED BY public.epics_epic.id;
          public          taiga    false    277                       1259    319043    epics_relateduserstory    TABLE     �   CREATE TABLE public.epics_relateduserstory (
    id integer NOT NULL,
    "order" bigint NOT NULL,
    epic_id integer NOT NULL,
    user_story_id integer NOT NULL
);
 *   DROP TABLE public.epics_relateduserstory;
       public         heap    taiga    false                       1259    319041    epics_relateduserstory_id_seq    SEQUENCE     �   CREATE SEQUENCE public.epics_relateduserstory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.epics_relateduserstory_id_seq;
       public          taiga    false    280            1           0    0    epics_relateduserstory_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.epics_relateduserstory_id_seq OWNED BY public.epics_relateduserstory.id;
          public          taiga    false    279            0           1259    319412    external_apps_application    TABLE     �   CREATE TABLE public.external_apps_application (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    icon_url text,
    web character varying(255),
    description text,
    next_url text NOT NULL
);
 -   DROP TABLE public.external_apps_application;
       public         heap    taiga    false            2           1259    319422    external_apps_applicationtoken    TABLE       CREATE TABLE public.external_apps_applicationtoken (
    id integer NOT NULL,
    auth_code character varying(255),
    token character varying(255),
    state character varying(255),
    application_id character varying(255) NOT NULL,
    user_id integer NOT NULL
);
 2   DROP TABLE public.external_apps_applicationtoken;
       public         heap    taiga    false            1           1259    319420 %   external_apps_applicationtoken_id_seq    SEQUENCE     �   CREATE SEQUENCE public.external_apps_applicationtoken_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.external_apps_applicationtoken_id_seq;
       public          taiga    false    306            2           0    0 %   external_apps_applicationtoken_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.external_apps_applicationtoken_id_seq OWNED BY public.external_apps_applicationtoken.id;
          public          taiga    false    305            4           1259    319449    feedback_feedbackentry    TABLE     �   CREATE TABLE public.feedback_feedbackentry (
    id integer NOT NULL,
    full_name character varying(256) NOT NULL,
    email character varying(255) NOT NULL,
    comment text NOT NULL,
    created_date timestamp with time zone NOT NULL
);
 *   DROP TABLE public.feedback_feedbackentry;
       public         heap    taiga    false            3           1259    319447    feedback_feedbackentry_id_seq    SEQUENCE     �   CREATE SEQUENCE public.feedback_feedbackentry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.feedback_feedbackentry_id_seq;
       public          taiga    false    308            3           0    0    feedback_feedbackentry_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.feedback_feedbackentry_id_seq OWNED BY public.feedback_feedbackentry.id;
          public          taiga    false    307                       1259    318994    history_historyentry    TABLE     /  CREATE TABLE public.history_historyentry (
    id character varying(255) NOT NULL,
    "user" jsonb,
    created_at timestamp with time zone,
    type smallint,
    is_snapshot boolean,
    key character varying(255),
    diff jsonb,
    snapshot jsonb,
    "values" jsonb,
    comment text,
    comment_html text,
    delete_comment_date timestamp with time zone,
    delete_comment_user jsonb,
    is_hidden boolean,
    comment_versions jsonb,
    edit_comment_date timestamp with time zone,
    project_id integer NOT NULL,
    values_diff_cache jsonb
);
 (   DROP TABLE public.history_historyentry;
       public         heap    taiga    false            �            1259    318108    issues_issue    TABLE     �  CREATE TABLE public.issues_issue (
    id integer NOT NULL,
    tags text[],
    version integer NOT NULL,
    is_blocked boolean NOT NULL,
    blocked_note text NOT NULL,
    ref bigint,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    finished_date timestamp with time zone,
    subject text NOT NULL,
    description text NOT NULL,
    assigned_to_id integer,
    milestone_id integer,
    owner_id integer,
    priority_id integer,
    project_id integer NOT NULL,
    severity_id integer,
    status_id integer,
    type_id integer,
    external_reference text[],
    due_date date,
    due_date_reason text NOT NULL
);
     DROP TABLE public.issues_issue;
       public         heap    taiga    false            �            1259    318106    issues_issue_id_seq    SEQUENCE     �   CREATE SEQUENCE public.issues_issue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.issues_issue_id_seq;
       public          taiga    false    243            4           0    0    issues_issue_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.issues_issue_id_seq OWNED BY public.issues_issue.id;
          public          taiga    false    242                       1259    318694 
   likes_like    TABLE       CREATE TABLE public.likes_like (
    id integer NOT NULL,
    object_id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    content_type_id integer NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT likes_like_object_id_check CHECK ((object_id >= 0))
);
    DROP TABLE public.likes_like;
       public         heap    taiga    false            
           1259    318692    likes_like_id_seq    SEQUENCE     �   CREATE SEQUENCE public.likes_like_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.likes_like_id_seq;
       public          taiga    false    267            5           0    0    likes_like_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.likes_like_id_seq OWNED BY public.likes_like.id;
          public          taiga    false    266            �            1259    318057    milestones_milestone    TABLE     )  CREATE TABLE public.milestones_milestone (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    slug character varying(250) NOT NULL,
    estimated_start date NOT NULL,
    estimated_finish date NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    closed boolean NOT NULL,
    disponibility double precision,
    "order" smallint NOT NULL,
    owner_id integer,
    project_id integer NOT NULL,
    CONSTRAINT milestones_milestone_order_check CHECK (("order" >= 0))
);
 (   DROP TABLE public.milestones_milestone;
       public         heap    taiga    false            �            1259    318055    milestones_milestone_id_seq    SEQUENCE     �   CREATE SEQUENCE public.milestones_milestone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.milestones_milestone_id_seq;
       public          taiga    false    241            6           0    0    milestones_milestone_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.milestones_milestone_id_seq OWNED BY public.milestones_milestone.id;
          public          taiga    false    240            �            1259    318368 '   notifications_historychangenotification    TABLE     V  CREATE TABLE public.notifications_historychangenotification (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    created_datetime timestamp with time zone NOT NULL,
    updated_datetime timestamp with time zone NOT NULL,
    history_type smallint NOT NULL,
    owner_id integer NOT NULL,
    project_id integer NOT NULL
);
 ;   DROP TABLE public.notifications_historychangenotification;
       public         heap    taiga    false            �            1259    318376 7   notifications_historychangenotification_history_entries    TABLE     �   CREATE TABLE public.notifications_historychangenotification_history_entries (
    id integer NOT NULL,
    historychangenotification_id integer NOT NULL,
    historyentry_id character varying(255) NOT NULL
);
 K   DROP TABLE public.notifications_historychangenotification_history_entries;
       public         heap    taiga    false            �            1259    318374 >   notifications_historychangenotification_history_entries_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_historychangenotification_history_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 U   DROP SEQUENCE public.notifications_historychangenotification_history_entries_id_seq;
       public          taiga    false    253            7           0    0 >   notifications_historychangenotification_history_entries_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.notifications_historychangenotification_history_entries_id_seq OWNED BY public.notifications_historychangenotification_history_entries.id;
          public          taiga    false    252            �            1259    318366 .   notifications_historychangenotification_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_historychangenotification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 E   DROP SEQUENCE public.notifications_historychangenotification_id_seq;
       public          taiga    false    251            8           0    0 .   notifications_historychangenotification_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.notifications_historychangenotification_id_seq OWNED BY public.notifications_historychangenotification.id;
          public          taiga    false    250            �            1259    318384 4   notifications_historychangenotification_notify_users    TABLE     �   CREATE TABLE public.notifications_historychangenotification_notify_users (
    id integer NOT NULL,
    historychangenotification_id integer NOT NULL,
    user_id integer NOT NULL
);
 H   DROP TABLE public.notifications_historychangenotification_notify_users;
       public         heap    taiga    false            �            1259    318382 ;   notifications_historychangenotification_notify_users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_historychangenotification_notify_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 R   DROP SEQUENCE public.notifications_historychangenotification_notify_users_id_seq;
       public          taiga    false    255            9           0    0 ;   notifications_historychangenotification_notify_users_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.notifications_historychangenotification_notify_users_id_seq OWNED BY public.notifications_historychangenotification_notify_users.id;
          public          taiga    false    254            �            1259    318325    notifications_notifypolicy    TABLE     d  CREATE TABLE public.notifications_notifypolicy (
    id integer NOT NULL,
    notify_level smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    modified_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    live_notify_level smallint NOT NULL,
    web_notify_level boolean NOT NULL
);
 .   DROP TABLE public.notifications_notifypolicy;
       public         heap    taiga    false            �            1259    318323 !   notifications_notifypolicy_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_notifypolicy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.notifications_notifypolicy_id_seq;
       public          taiga    false    249            :           0    0 !   notifications_notifypolicy_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.notifications_notifypolicy_id_seq OWNED BY public.notifications_notifypolicy.id;
          public          taiga    false    248                       1259    318435    notifications_watched    TABLE     O  CREATE TABLE public.notifications_watched (
    id integer NOT NULL,
    object_id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    content_type_id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    CONSTRAINT notifications_watched_object_id_check CHECK ((object_id >= 0))
);
 )   DROP TABLE public.notifications_watched;
       public         heap    taiga    false                        1259    318433    notifications_watched_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_watched_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.notifications_watched_id_seq;
       public          taiga    false    257            ;           0    0    notifications_watched_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.notifications_watched_id_seq OWNED BY public.notifications_watched.id;
          public          taiga    false    256            6           1259    319508    notifications_webnotification    TABLE     R  CREATE TABLE public.notifications_webnotification (
    id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    read timestamp with time zone,
    event_type integer NOT NULL,
    data jsonb NOT NULL,
    user_id integer NOT NULL,
    CONSTRAINT notifications_webnotification_event_type_check CHECK ((event_type >= 0))
);
 1   DROP TABLE public.notifications_webnotification;
       public         heap    taiga    false            5           1259    319506 $   notifications_webnotification_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_webnotification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public.notifications_webnotification_id_seq;
       public          taiga    false    310            <           0    0 $   notifications_webnotification_id_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.notifications_webnotification_id_seq OWNED BY public.notifications_webnotification.id;
          public          taiga    false    309                       1259    318801    projects_epicstatus    TABLE     "  CREATE TABLE public.projects_epicstatus (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    "order" integer NOT NULL,
    is_closed boolean NOT NULL,
    color character varying(20) NOT NULL,
    project_id integer NOT NULL
);
 '   DROP TABLE public.projects_epicstatus;
       public         heap    taiga    false                       1259    318799    projects_epicstatus_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_epicstatus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.projects_epicstatus_id_seq;
       public          taiga    false    269            =           0    0    projects_epicstatus_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.projects_epicstatus_id_seq OWNED BY public.projects_epicstatus.id;
          public          taiga    false    268            :           1259    319551    projects_issueduedate    TABLE       CREATE TABLE public.projects_issueduedate (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    by_default boolean NOT NULL,
    color character varying(20) NOT NULL,
    days_to_due integer,
    project_id integer NOT NULL
);
 )   DROP TABLE public.projects_issueduedate;
       public         heap    taiga    false            9           1259    319549    projects_issueduedate_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_issueduedate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.projects_issueduedate_id_seq;
       public          taiga    false    314            >           0    0    projects_issueduedate_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.projects_issueduedate_id_seq OWNED BY public.projects_issueduedate.id;
          public          taiga    false    313            �            1259    317769    projects_issuestatus    TABLE     #  CREATE TABLE public.projects_issuestatus (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    is_closed boolean NOT NULL,
    color character varying(20) NOT NULL,
    project_id integer NOT NULL,
    slug character varying(255) NOT NULL
);
 (   DROP TABLE public.projects_issuestatus;
       public         heap    taiga    false            �            1259    317767    projects_issuestatus_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_issuestatus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.projects_issuestatus_id_seq;
       public          taiga    false    217            ?           0    0    projects_issuestatus_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.projects_issuestatus_id_seq OWNED BY public.projects_issuestatus.id;
          public          taiga    false    216            �            1259    317777    projects_issuetype    TABLE     �   CREATE TABLE public.projects_issuetype (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    color character varying(20) NOT NULL,
    project_id integer NOT NULL
);
 &   DROP TABLE public.projects_issuetype;
       public         heap    taiga    false            �            1259    317775    projects_issuetype_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_issuetype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.projects_issuetype_id_seq;
       public          taiga    false    219            @           0    0    projects_issuetype_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.projects_issuetype_id_seq OWNED BY public.projects_issuetype.id;
          public          taiga    false    218            �            1259    317716    projects_membership    TABLE     �  CREATE TABLE public.projects_membership (
    id integer NOT NULL,
    is_admin boolean NOT NULL,
    email character varying(255),
    created_at timestamp with time zone NOT NULL,
    token character varying(60),
    user_id integer,
    project_id integer NOT NULL,
    role_id integer NOT NULL,
    invited_by_id integer,
    invitation_extra_text text,
    user_order bigint NOT NULL
);
 '   DROP TABLE public.projects_membership;
       public         heap    taiga    false            �            1259    317714    projects_membership_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_membership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.projects_membership_id_seq;
       public          taiga    false    213            A           0    0    projects_membership_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.projects_membership_id_seq OWNED BY public.projects_membership.id;
          public          taiga    false    212            �            1259    317785    projects_points    TABLE     �   CREATE TABLE public.projects_points (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    value double precision,
    project_id integer NOT NULL
);
 #   DROP TABLE public.projects_points;
       public         heap    taiga    false            �            1259    317783    projects_points_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_points_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.projects_points_id_seq;
       public          taiga    false    221            B           0    0    projects_points_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.projects_points_id_seq OWNED BY public.projects_points.id;
          public          taiga    false    220            �            1259    317793    projects_priority    TABLE     �   CREATE TABLE public.projects_priority (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    color character varying(20) NOT NULL,
    project_id integer NOT NULL
);
 %   DROP TABLE public.projects_priority;
       public         heap    taiga    false            �            1259    317791    projects_priority_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_priority_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.projects_priority_id_seq;
       public          taiga    false    223            C           0    0    projects_priority_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.projects_priority_id_seq OWNED BY public.projects_priority.id;
          public          taiga    false    222            �            1259    317724    projects_project    TABLE     ;  CREATE TABLE public.projects_project (
    id integer NOT NULL,
    tags text[],
    name character varying(250) NOT NULL,
    slug character varying(250) NOT NULL,
    description text,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    total_milestones integer,
    total_story_points double precision,
    is_backlog_activated boolean NOT NULL,
    is_kanban_activated boolean NOT NULL,
    is_wiki_activated boolean NOT NULL,
    is_issues_activated boolean NOT NULL,
    videoconferences character varying(250),
    videoconferences_extra_data character varying(250),
    anon_permissions text[],
    public_permissions text[],
    is_private boolean NOT NULL,
    tags_colors text[],
    owner_id integer,
    creation_template_id integer,
    default_issue_status_id integer,
    default_issue_type_id integer,
    default_points_id integer,
    default_priority_id integer,
    default_severity_id integer,
    default_task_status_id integer,
    default_us_status_id integer,
    issues_csv_uuid character varying(32),
    tasks_csv_uuid character varying(32),
    userstories_csv_uuid character varying(32),
    is_featured boolean NOT NULL,
    is_looking_for_people boolean NOT NULL,
    total_activity integer NOT NULL,
    total_activity_last_month integer NOT NULL,
    total_activity_last_week integer NOT NULL,
    total_activity_last_year integer NOT NULL,
    total_fans integer NOT NULL,
    total_fans_last_month integer NOT NULL,
    total_fans_last_week integer NOT NULL,
    total_fans_last_year integer NOT NULL,
    totals_updated_datetime timestamp with time zone NOT NULL,
    logo character varying(500),
    looking_for_people_note text NOT NULL,
    blocked_code character varying(255),
    transfer_token character varying(255),
    is_epics_activated boolean NOT NULL,
    default_epic_status_id integer,
    epics_csv_uuid character varying(32),
    is_contact_activated boolean NOT NULL,
    default_swimlane_id integer,
    workspace_id integer,
    color integer NOT NULL,
    workspace_member_permissions text[],
    CONSTRAINT projects_project_total_activity_check CHECK ((total_activity >= 0)),
    CONSTRAINT projects_project_total_activity_last_month_check CHECK ((total_activity_last_month >= 0)),
    CONSTRAINT projects_project_total_activity_last_week_check CHECK ((total_activity_last_week >= 0)),
    CONSTRAINT projects_project_total_activity_last_year_check CHECK ((total_activity_last_year >= 0)),
    CONSTRAINT projects_project_total_fans_check CHECK ((total_fans >= 0)),
    CONSTRAINT projects_project_total_fans_last_month_check CHECK ((total_fans_last_month >= 0)),
    CONSTRAINT projects_project_total_fans_last_week_check CHECK ((total_fans_last_week >= 0)),
    CONSTRAINT projects_project_total_fans_last_year_check CHECK ((total_fans_last_year >= 0))
);
 $   DROP TABLE public.projects_project;
       public         heap    taiga    false            �            1259    317722    projects_project_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.projects_project_id_seq;
       public          taiga    false    215            D           0    0    projects_project_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.projects_project_id_seq OWNED BY public.projects_project.id;
          public          taiga    false    214                       1259    318619    projects_projectmodulesconfig    TABLE     �   CREATE TABLE public.projects_projectmodulesconfig (
    id integer NOT NULL,
    config jsonb,
    project_id integer NOT NULL
);
 1   DROP TABLE public.projects_projectmodulesconfig;
       public         heap    taiga    false                       1259    318617 $   projects_projectmodulesconfig_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_projectmodulesconfig_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public.projects_projectmodulesconfig_id_seq;
       public          taiga    false    263            E           0    0 $   projects_projectmodulesconfig_id_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.projects_projectmodulesconfig_id_seq OWNED BY public.projects_projectmodulesconfig.id;
          public          taiga    false    262            �            1259    317801    projects_projecttemplate    TABLE       CREATE TABLE public.projects_projecttemplate (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    slug character varying(250) NOT NULL,
    description text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    default_owner_role character varying(50) NOT NULL,
    is_backlog_activated boolean NOT NULL,
    is_kanban_activated boolean NOT NULL,
    is_wiki_activated boolean NOT NULL,
    is_issues_activated boolean NOT NULL,
    videoconferences character varying(250),
    videoconferences_extra_data character varying(250),
    default_options jsonb,
    us_statuses jsonb,
    points jsonb,
    task_statuses jsonb,
    issue_statuses jsonb,
    issue_types jsonb,
    priorities jsonb,
    severities jsonb,
    roles jsonb,
    "order" bigint NOT NULL,
    epic_statuses jsonb,
    is_epics_activated boolean NOT NULL,
    is_contact_activated boolean NOT NULL,
    epic_custom_attributes jsonb,
    is_looking_for_people boolean NOT NULL,
    issue_custom_attributes jsonb,
    looking_for_people_note text NOT NULL,
    tags text[],
    tags_colors text[],
    task_custom_attributes jsonb,
    us_custom_attributes jsonb,
    issue_duedates jsonb,
    task_duedates jsonb,
    us_duedates jsonb
);
 ,   DROP TABLE public.projects_projecttemplate;
       public         heap    taiga    false            �            1259    317799    projects_projecttemplate_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_projecttemplate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.projects_projecttemplate_id_seq;
       public          taiga    false    225            F           0    0    projects_projecttemplate_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.projects_projecttemplate_id_seq OWNED BY public.projects_projecttemplate.id;
          public          taiga    false    224            �            1259    317814    projects_severity    TABLE     �   CREATE TABLE public.projects_severity (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    color character varying(20) NOT NULL,
    project_id integer NOT NULL
);
 %   DROP TABLE public.projects_severity;
       public         heap    taiga    false            �            1259    317812    projects_severity_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_severity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.projects_severity_id_seq;
       public          taiga    false    227            G           0    0    projects_severity_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.projects_severity_id_seq OWNED BY public.projects_severity.id;
          public          taiga    false    226            @           1259    319606    projects_swimlane    TABLE     �   CREATE TABLE public.projects_swimlane (
    id integer NOT NULL,
    name text NOT NULL,
    "order" bigint NOT NULL,
    project_id integer NOT NULL
);
 %   DROP TABLE public.projects_swimlane;
       public         heap    taiga    false            ?           1259    319604    projects_swimlane_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_swimlane_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.projects_swimlane_id_seq;
       public          taiga    false    320            H           0    0    projects_swimlane_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.projects_swimlane_id_seq OWNED BY public.projects_swimlane.id;
          public          taiga    false    319            B           1259    319623     projects_swimlaneuserstorystatus    TABLE     �   CREATE TABLE public.projects_swimlaneuserstorystatus (
    id integer NOT NULL,
    wip_limit integer,
    status_id integer NOT NULL,
    swimlane_id integer NOT NULL
);
 4   DROP TABLE public.projects_swimlaneuserstorystatus;
       public         heap    taiga    false            A           1259    319621 '   projects_swimlaneuserstorystatus_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_swimlaneuserstorystatus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 >   DROP SEQUENCE public.projects_swimlaneuserstorystatus_id_seq;
       public          taiga    false    322            I           0    0 '   projects_swimlaneuserstorystatus_id_seq    SEQUENCE OWNED BY     s   ALTER SEQUENCE public.projects_swimlaneuserstorystatus_id_seq OWNED BY public.projects_swimlaneuserstorystatus.id;
          public          taiga    false    321            <           1259    319559    projects_taskduedate    TABLE       CREATE TABLE public.projects_taskduedate (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    by_default boolean NOT NULL,
    color character varying(20) NOT NULL,
    days_to_due integer,
    project_id integer NOT NULL
);
 (   DROP TABLE public.projects_taskduedate;
       public         heap    taiga    false            ;           1259    319557    projects_taskduedate_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_taskduedate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.projects_taskduedate_id_seq;
       public          taiga    false    316            J           0    0    projects_taskduedate_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.projects_taskduedate_id_seq OWNED BY public.projects_taskduedate.id;
          public          taiga    false    315            �            1259    317822    projects_taskstatus    TABLE     "  CREATE TABLE public.projects_taskstatus (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    is_closed boolean NOT NULL,
    color character varying(20) NOT NULL,
    project_id integer NOT NULL,
    slug character varying(255) NOT NULL
);
 '   DROP TABLE public.projects_taskstatus;
       public         heap    taiga    false            �            1259    317820    projects_taskstatus_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_taskstatus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.projects_taskstatus_id_seq;
       public          taiga    false    229            K           0    0    projects_taskstatus_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.projects_taskstatus_id_seq OWNED BY public.projects_taskstatus.id;
          public          taiga    false    228            >           1259    319567    projects_userstoryduedate    TABLE       CREATE TABLE public.projects_userstoryduedate (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    by_default boolean NOT NULL,
    color character varying(20) NOT NULL,
    days_to_due integer,
    project_id integer NOT NULL
);
 -   DROP TABLE public.projects_userstoryduedate;
       public         heap    taiga    false            =           1259    319565     projects_userstoryduedate_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_userstoryduedate_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.projects_userstoryduedate_id_seq;
       public          taiga    false    318            L           0    0     projects_userstoryduedate_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.projects_userstoryduedate_id_seq OWNED BY public.projects_userstoryduedate.id;
          public          taiga    false    317            �            1259    317830    projects_userstorystatus    TABLE     `  CREATE TABLE public.projects_userstorystatus (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "order" integer NOT NULL,
    is_closed boolean NOT NULL,
    color character varying(20) NOT NULL,
    wip_limit integer,
    project_id integer NOT NULL,
    slug character varying(255) NOT NULL,
    is_archived boolean NOT NULL
);
 ,   DROP TABLE public.projects_userstorystatus;
       public         heap    taiga    false            �            1259    317828    projects_userstorystatus_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_userstorystatus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.projects_userstorystatus_id_seq;
       public          taiga    false    231            M           0    0    projects_userstorystatus_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.projects_userstorystatus_id_seq OWNED BY public.projects_userstorystatus.id;
          public          taiga    false    230            ^           1259    320109    references_project1    SEQUENCE     |   CREATE SEQUENCE public.references_project1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project1;
       public          taiga    false            g           1259    320127    references_project10    SEQUENCE     }   CREATE SEQUENCE public.references_project10
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project10;
       public          taiga    false            h           1259    320129    references_project11    SEQUENCE     }   CREATE SEQUENCE public.references_project11
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project11;
       public          taiga    false            i           1259    320131    references_project12    SEQUENCE     }   CREATE SEQUENCE public.references_project12
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project12;
       public          taiga    false            j           1259    320133    references_project13    SEQUENCE     }   CREATE SEQUENCE public.references_project13
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project13;
       public          taiga    false            k           1259    320135    references_project14    SEQUENCE     }   CREATE SEQUENCE public.references_project14
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project14;
       public          taiga    false            l           1259    320137    references_project15    SEQUENCE     }   CREATE SEQUENCE public.references_project15
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project15;
       public          taiga    false            m           1259    320139    references_project16    SEQUENCE     }   CREATE SEQUENCE public.references_project16
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project16;
       public          taiga    false            n           1259    320141    references_project17    SEQUENCE     }   CREATE SEQUENCE public.references_project17
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project17;
       public          taiga    false            o           1259    320143    references_project18    SEQUENCE     }   CREATE SEQUENCE public.references_project18
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project18;
       public          taiga    false            p           1259    320145    references_project19    SEQUENCE     }   CREATE SEQUENCE public.references_project19
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project19;
       public          taiga    false            _           1259    320111    references_project2    SEQUENCE     |   CREATE SEQUENCE public.references_project2
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project2;
       public          taiga    false            q           1259    320147    references_project20    SEQUENCE     }   CREATE SEQUENCE public.references_project20
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project20;
       public          taiga    false            r           1259    320149    references_project21    SEQUENCE     }   CREATE SEQUENCE public.references_project21
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project21;
       public          taiga    false            s           1259    320151    references_project22    SEQUENCE     }   CREATE SEQUENCE public.references_project22
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project22;
       public          taiga    false            t           1259    320153    references_project23    SEQUENCE     }   CREATE SEQUENCE public.references_project23
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project23;
       public          taiga    false            u           1259    320155    references_project24    SEQUENCE     }   CREATE SEQUENCE public.references_project24
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project24;
       public          taiga    false            v           1259    320157    references_project25    SEQUENCE     }   CREATE SEQUENCE public.references_project25
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project25;
       public          taiga    false            w           1259    320159    references_project26    SEQUENCE     }   CREATE SEQUENCE public.references_project26
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project26;
       public          taiga    false            x           1259    320161    references_project27    SEQUENCE     }   CREATE SEQUENCE public.references_project27
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project27;
       public          taiga    false            y           1259    320163    references_project28    SEQUENCE     }   CREATE SEQUENCE public.references_project28
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project28;
       public          taiga    false            z           1259    320165    references_project29    SEQUENCE     }   CREATE SEQUENCE public.references_project29
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project29;
       public          taiga    false            `           1259    320113    references_project3    SEQUENCE     |   CREATE SEQUENCE public.references_project3
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project3;
       public          taiga    false            {           1259    320167    references_project30    SEQUENCE     }   CREATE SEQUENCE public.references_project30
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project30;
       public          taiga    false            |           1259    320169    references_project31    SEQUENCE     }   CREATE SEQUENCE public.references_project31
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project31;
       public          taiga    false            }           1259    320171    references_project32    SEQUENCE     }   CREATE SEQUENCE public.references_project32
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.references_project32;
       public          taiga    false            a           1259    320115    references_project4    SEQUENCE     |   CREATE SEQUENCE public.references_project4
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project4;
       public          taiga    false            b           1259    320117    references_project5    SEQUENCE     |   CREATE SEQUENCE public.references_project5
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project5;
       public          taiga    false            c           1259    320119    references_project6    SEQUENCE     |   CREATE SEQUENCE public.references_project6
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project6;
       public          taiga    false            d           1259    320121    references_project7    SEQUENCE     |   CREATE SEQUENCE public.references_project7
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project7;
       public          taiga    false            e           1259    320123    references_project8    SEQUENCE     |   CREATE SEQUENCE public.references_project8
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project8;
       public          taiga    false            f           1259    320125    references_project9    SEQUENCE     |   CREATE SEQUENCE public.references_project9
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.references_project9;
       public          taiga    false            D           1259    319662    references_reference    TABLE     F  CREATE TABLE public.references_reference (
    id integer NOT NULL,
    object_id integer NOT NULL,
    ref bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    content_type_id integer NOT NULL,
    project_id integer NOT NULL,
    CONSTRAINT references_reference_object_id_check CHECK ((object_id >= 0))
);
 (   DROP TABLE public.references_reference;
       public         heap    taiga    false            C           1259    319660    references_reference_id_seq    SEQUENCE     �   CREATE SEQUENCE public.references_reference_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.references_reference_id_seq;
       public          taiga    false    324            N           0    0    references_reference_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.references_reference_id_seq OWNED BY public.references_reference.id;
          public          taiga    false    323            G           1259    319695    settings_userprojectsettings    TABLE       CREATE TABLE public.settings_userprojectsettings (
    id integer NOT NULL,
    homepage smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    modified_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL
);
 0   DROP TABLE public.settings_userprojectsettings;
       public         heap    taiga    false            F           1259    319693 #   settings_userprojectsettings_id_seq    SEQUENCE     �   CREATE SEQUENCE public.settings_userprojectsettings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.settings_userprojectsettings_id_seq;
       public          taiga    false    327            O           0    0 #   settings_userprojectsettings_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.settings_userprojectsettings_id_seq OWNED BY public.settings_userprojectsettings.id;
          public          taiga    false    326                       1259    318464 
   tasks_task    TABLE     �  CREATE TABLE public.tasks_task (
    id integer NOT NULL,
    tags text[],
    version integer NOT NULL,
    is_blocked boolean NOT NULL,
    blocked_note text NOT NULL,
    ref bigint,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    finished_date timestamp with time zone,
    subject text NOT NULL,
    description text NOT NULL,
    is_iocaine boolean NOT NULL,
    assigned_to_id integer,
    milestone_id integer,
    owner_id integer,
    project_id integer NOT NULL,
    status_id integer,
    user_story_id integer,
    taskboard_order bigint NOT NULL,
    us_order bigint NOT NULL,
    external_reference text[],
    due_date date,
    due_date_reason text NOT NULL
);
    DROP TABLE public.tasks_task;
       public         heap    taiga    false                       1259    318462    tasks_task_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tasks_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.tasks_task_id_seq;
       public          taiga    false    259            P           0    0    tasks_task_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.tasks_task_id_seq OWNED BY public.tasks_task.id;
          public          taiga    false    258            I           1259    319751    telemetry_instancetelemetry    TABLE     �   CREATE TABLE public.telemetry_instancetelemetry (
    id integer NOT NULL,
    instance_id character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL
);
 /   DROP TABLE public.telemetry_instancetelemetry;
       public         heap    taiga    false            H           1259    319749 "   telemetry_instancetelemetry_id_seq    SEQUENCE     �   CREATE SEQUENCE public.telemetry_instancetelemetry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.telemetry_instancetelemetry_id_seq;
       public          taiga    false    329            Q           0    0 "   telemetry_instancetelemetry_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.telemetry_instancetelemetry_id_seq OWNED BY public.telemetry_instancetelemetry.id;
          public          taiga    false    328            	           1259    318644    timeline_timeline    TABLE     �  CREATE TABLE public.timeline_timeline (
    id integer NOT NULL,
    object_id integer NOT NULL,
    namespace character varying(250) NOT NULL,
    event_type character varying(250) NOT NULL,
    project_id integer,
    data jsonb NOT NULL,
    data_content_type_id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    content_type_id integer NOT NULL,
    CONSTRAINT timeline_timeline_object_id_check CHECK ((object_id >= 0))
);
 %   DROP TABLE public.timeline_timeline;
       public         heap    taiga    false                       1259    318642    timeline_timeline_id_seq    SEQUENCE     �   CREATE SEQUENCE public.timeline_timeline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.timeline_timeline_id_seq;
       public          taiga    false    265            R           0    0    timeline_timeline_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.timeline_timeline_id_seq OWNED BY public.timeline_timeline.id;
          public          taiga    false    264            M           1259    319792    token_denylist_denylistedtoken    TABLE     �   CREATE TABLE public.token_denylist_denylistedtoken (
    id bigint NOT NULL,
    denylisted_at timestamp with time zone NOT NULL,
    token_id bigint NOT NULL
);
 2   DROP TABLE public.token_denylist_denylistedtoken;
       public         heap    taiga    false            L           1259    319790 %   token_denylist_denylistedtoken_id_seq    SEQUENCE     �   CREATE SEQUENCE public.token_denylist_denylistedtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.token_denylist_denylistedtoken_id_seq;
       public          taiga    false    333            S           0    0 %   token_denylist_denylistedtoken_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.token_denylist_denylistedtoken_id_seq OWNED BY public.token_denylist_denylistedtoken.id;
          public          taiga    false    332            K           1259    319779    token_denylist_outstandingtoken    TABLE       CREATE TABLE public.token_denylist_outstandingtoken (
    id bigint NOT NULL,
    jti character varying(255) NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    user_id integer
);
 3   DROP TABLE public.token_denylist_outstandingtoken;
       public         heap    taiga    false            J           1259    319777 &   token_denylist_outstandingtoken_id_seq    SEQUENCE     �   CREATE SEQUENCE public.token_denylist_outstandingtoken_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.token_denylist_outstandingtoken_id_seq;
       public          taiga    false    331            T           0    0 &   token_denylist_outstandingtoken_id_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.token_denylist_outstandingtoken_id_seq OWNED BY public.token_denylist_outstandingtoken.id;
          public          taiga    false    330                       1259    318546    users_authdata    TABLE     �   CREATE TABLE public.users_authdata (
    id integer NOT NULL,
    key character varying(50) NOT NULL,
    value character varying(300) NOT NULL,
    extra jsonb NOT NULL,
    user_id integer NOT NULL
);
 "   DROP TABLE public.users_authdata;
       public         heap    taiga    false                       1259    318544    users_authdata_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_authdata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.users_authdata_id_seq;
       public          taiga    false    261            U           0    0    users_authdata_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.users_authdata_id_seq OWNED BY public.users_authdata.id;
          public          taiga    false    260            �            1259    317703 
   users_role    TABLE       CREATE TABLE public.users_role (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    slug character varying(250) NOT NULL,
    permissions text[],
    "order" integer NOT NULL,
    computable boolean NOT NULL,
    project_id integer,
    is_admin boolean NOT NULL
);
    DROP TABLE public.users_role;
       public         heap    taiga    false            �            1259    317701    users_role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.users_role_id_seq;
       public          taiga    false    211            V           0    0    users_role_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.users_role_id_seq OWNED BY public.users_role.id;
          public          taiga    false    210            �            1259    317665 
   users_user    TABLE     �  CREATE TABLE public.users_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    is_active boolean NOT NULL,
    full_name character varying(256) NOT NULL,
    color character varying(9) NOT NULL,
    bio text NOT NULL,
    photo character varying(500),
    date_joined timestamp with time zone NOT NULL,
    lang character varying(20),
    timezone character varying(20),
    colorize_tags boolean NOT NULL,
    token character varying(200),
    email_token character varying(200),
    new_email character varying(254),
    is_system boolean NOT NULL,
    theme character varying(100),
    max_private_projects integer,
    max_public_projects integer,
    max_memberships_private_projects integer,
    max_memberships_public_projects integer,
    uuid character varying(32) NOT NULL,
    accepted_terms boolean NOT NULL,
    read_new_terms boolean NOT NULL,
    verified_email boolean NOT NULL,
    is_staff boolean NOT NULL,
    date_cancelled timestamp with time zone
);
    DROP TABLE public.users_user;
       public         heap    taiga    false            �            1259    317663    users_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.users_user_id_seq;
       public          taiga    false    207            W           0    0    users_user_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users_user.id;
          public          taiga    false    206            O           1259    319836    users_workspacerole    TABLE       CREATE TABLE public.users_workspacerole (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    slug character varying(250) NOT NULL,
    permissions text[],
    "order" integer NOT NULL,
    is_admin boolean NOT NULL,
    workspace_id integer NOT NULL
);
 '   DROP TABLE public.users_workspacerole;
       public         heap    taiga    false            N           1259    319834    users_workspacerole_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_workspacerole_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.users_workspacerole_id_seq;
       public          taiga    false    335            X           0    0    users_workspacerole_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.users_workspacerole_id_seq OWNED BY public.users_workspacerole.id;
          public          taiga    false    334            Q           1259    319857    userstorage_storageentry    TABLE       CREATE TABLE public.userstorage_storageentry (
    id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    key character varying(255) NOT NULL,
    value jsonb,
    owner_id integer NOT NULL
);
 ,   DROP TABLE public.userstorage_storageentry;
       public         heap    taiga    false            P           1259    319855    userstorage_storageentry_id_seq    SEQUENCE     �   CREATE SEQUENCE public.userstorage_storageentry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.userstorage_storageentry_id_seq;
       public          taiga    false    337            Y           0    0    userstorage_storageentry_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.userstorage_storageentry_id_seq OWNED BY public.userstorage_storageentry.id;
          public          taiga    false    336            �            1259    318190    userstories_rolepoints    TABLE     �   CREATE TABLE public.userstories_rolepoints (
    id integer NOT NULL,
    points_id integer,
    role_id integer NOT NULL,
    user_story_id integer NOT NULL
);
 *   DROP TABLE public.userstories_rolepoints;
       public         heap    taiga    false            �            1259    318188    userstories_rolepoints_id_seq    SEQUENCE     �   CREATE SEQUENCE public.userstories_rolepoints_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.userstories_rolepoints_id_seq;
       public          taiga    false    245            Z           0    0    userstories_rolepoints_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.userstories_rolepoints_id_seq OWNED BY public.userstories_rolepoints.id;
          public          taiga    false    244            �            1259    318198    userstories_userstory    TABLE     �  CREATE TABLE public.userstories_userstory (
    id integer NOT NULL,
    tags text[],
    version integer NOT NULL,
    is_blocked boolean NOT NULL,
    blocked_note text NOT NULL,
    ref bigint,
    is_closed boolean NOT NULL,
    backlog_order bigint NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    finish_date timestamp with time zone,
    subject text NOT NULL,
    description text NOT NULL,
    client_requirement boolean NOT NULL,
    team_requirement boolean NOT NULL,
    assigned_to_id integer,
    generated_from_issue_id integer,
    milestone_id integer,
    owner_id integer,
    project_id integer NOT NULL,
    status_id integer,
    sprint_order bigint NOT NULL,
    kanban_order bigint NOT NULL,
    external_reference text[],
    tribe_gig text,
    due_date date,
    due_date_reason text NOT NULL,
    generated_from_task_id integer,
    from_task_ref text,
    swimlane_id integer
);
 )   DROP TABLE public.userstories_userstory;
       public         heap    taiga    false            S           1259    319928 $   userstories_userstory_assigned_users    TABLE     �   CREATE TABLE public.userstories_userstory_assigned_users (
    id integer NOT NULL,
    userstory_id integer NOT NULL,
    user_id integer NOT NULL
);
 8   DROP TABLE public.userstories_userstory_assigned_users;
       public         heap    taiga    false            R           1259    319926 +   userstories_userstory_assigned_users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.userstories_userstory_assigned_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE public.userstories_userstory_assigned_users_id_seq;
       public          taiga    false    339            [           0    0 +   userstories_userstory_assigned_users_id_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE public.userstories_userstory_assigned_users_id_seq OWNED BY public.userstories_userstory_assigned_users.id;
          public          taiga    false    338            �            1259    318196    userstories_userstory_id_seq    SEQUENCE     �   CREATE SEQUENCE public.userstories_userstory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.userstories_userstory_id_seq;
       public          taiga    false    247            \           0    0    userstories_userstory_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.userstories_userstory_id_seq OWNED BY public.userstories_userstory.id;
          public          taiga    false    246            U           1259    319967 
   votes_vote    TABLE       CREATE TABLE public.votes_vote (
    id integer NOT NULL,
    object_id integer NOT NULL,
    content_type_id integer NOT NULL,
    user_id integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    CONSTRAINT votes_vote_object_id_check CHECK ((object_id >= 0))
);
    DROP TABLE public.votes_vote;
       public         heap    taiga    false            T           1259    319965    votes_vote_id_seq    SEQUENCE     �   CREATE SEQUENCE public.votes_vote_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.votes_vote_id_seq;
       public          taiga    false    341            ]           0    0    votes_vote_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.votes_vote_id_seq OWNED BY public.votes_vote.id;
          public          taiga    false    340            W           1259    319976    votes_votes    TABLE     !  CREATE TABLE public.votes_votes (
    id integer NOT NULL,
    object_id integer NOT NULL,
    count integer NOT NULL,
    content_type_id integer NOT NULL,
    CONSTRAINT votes_votes_count_check CHECK ((count >= 0)),
    CONSTRAINT votes_votes_object_id_check CHECK ((object_id >= 0))
);
    DROP TABLE public.votes_votes;
       public         heap    taiga    false            V           1259    319974    votes_votes_id_seq    SEQUENCE     �   CREATE SEQUENCE public.votes_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.votes_votes_id_seq;
       public          taiga    false    343            ^           0    0    votes_votes_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.votes_votes_id_seq OWNED BY public.votes_votes.id;
          public          taiga    false    342            Y           1259    320014    webhooks_webhook    TABLE     �   CREATE TABLE public.webhooks_webhook (
    id integer NOT NULL,
    url character varying(200) NOT NULL,
    key text NOT NULL,
    project_id integer NOT NULL,
    name character varying(250) NOT NULL
);
 $   DROP TABLE public.webhooks_webhook;
       public         heap    taiga    false            X           1259    320012    webhooks_webhook_id_seq    SEQUENCE     �   CREATE SEQUENCE public.webhooks_webhook_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.webhooks_webhook_id_seq;
       public          taiga    false    345            _           0    0    webhooks_webhook_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.webhooks_webhook_id_seq OWNED BY public.webhooks_webhook.id;
          public          taiga    false    344            [           1259    320025    webhooks_webhooklog    TABLE     �  CREATE TABLE public.webhooks_webhooklog (
    id integer NOT NULL,
    url character varying(200) NOT NULL,
    status integer NOT NULL,
    request_data jsonb NOT NULL,
    response_data text NOT NULL,
    webhook_id integer NOT NULL,
    created timestamp with time zone NOT NULL,
    duration double precision NOT NULL,
    request_headers jsonb NOT NULL,
    response_headers jsonb NOT NULL
);
 '   DROP TABLE public.webhooks_webhooklog;
       public         heap    taiga    false            Z           1259    320023    webhooks_webhooklog_id_seq    SEQUENCE     �   CREATE SEQUENCE public.webhooks_webhooklog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.webhooks_webhooklog_id_seq;
       public          taiga    false    347            `           0    0    webhooks_webhooklog_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.webhooks_webhooklog_id_seq OWNED BY public.webhooks_webhooklog.id;
          public          taiga    false    346                       1259    318903    wiki_wikilink    TABLE     �   CREATE TABLE public.wiki_wikilink (
    id integer NOT NULL,
    title character varying(500) NOT NULL,
    href character varying(500) NOT NULL,
    "order" bigint NOT NULL,
    project_id integer NOT NULL
);
 !   DROP TABLE public.wiki_wikilink;
       public         heap    taiga    false                       1259    318901    wiki_wikilink_id_seq    SEQUENCE     �   CREATE SEQUENCE public.wiki_wikilink_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.wiki_wikilink_id_seq;
       public          taiga    false    273            a           0    0    wiki_wikilink_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.wiki_wikilink_id_seq OWNED BY public.wiki_wikilink.id;
          public          taiga    false    272                       1259    318915    wiki_wikipage    TABLE     `  CREATE TABLE public.wiki_wikipage (
    id integer NOT NULL,
    version integer NOT NULL,
    slug character varying(500) NOT NULL,
    content text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    last_modifier_id integer,
    owner_id integer,
    project_id integer NOT NULL
);
 !   DROP TABLE public.wiki_wikipage;
       public         heap    taiga    false                       1259    318913    wiki_wikipage_id_seq    SEQUENCE     �   CREATE SEQUENCE public.wiki_wikipage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.wiki_wikipage_id_seq;
       public          taiga    false    275            b           0    0    wiki_wikipage_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.wiki_wikipage_id_seq OWNED BY public.wiki_wikipage.id;
          public          taiga    false    274            8           1259    319528    workspaces_workspace    TABLE     U  CREATE TABLE public.workspaces_workspace (
    id integer NOT NULL,
    name character varying(40) NOT NULL,
    slug character varying(250),
    color integer NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    owner_id integer NOT NULL,
    is_premium boolean NOT NULL
);
 (   DROP TABLE public.workspaces_workspace;
       public         heap    taiga    false            7           1259    319526    workspaces_workspace_id_seq    SEQUENCE     �   CREATE SEQUENCE public.workspaces_workspace_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.workspaces_workspace_id_seq;
       public          taiga    false    312            c           0    0    workspaces_workspace_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.workspaces_workspace_id_seq OWNED BY public.workspaces_workspace.id;
          public          taiga    false    311            ]           1259    320072    workspaces_workspacemembership    TABLE     �   CREATE TABLE public.workspaces_workspacemembership (
    id integer NOT NULL,
    user_id integer,
    workspace_id integer NOT NULL,
    workspace_role_id integer NOT NULL
);
 2   DROP TABLE public.workspaces_workspacemembership;
       public         heap    taiga    false            \           1259    320070 %   workspaces_workspacemembership_id_seq    SEQUENCE     �   CREATE SEQUENCE public.workspaces_workspacemembership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.workspaces_workspacemembership_id_seq;
       public          taiga    false    349            d           0    0 %   workspaces_workspacemembership_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.workspaces_workspacemembership_id_seq OWNED BY public.workspaces_workspacemembership.id;
          public          taiga    false    348                        2604    317953    attachments_attachment id    DEFAULT     �   ALTER TABLE ONLY public.attachments_attachment ALTER COLUMN id SET DEFAULT nextval('public.attachments_attachment_id_seq'::regclass);
 H   ALTER TABLE public.attachments_attachment ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    233    232    233            #           2604    318000    auth_group id    DEFAULT     n   ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);
 <   ALTER TABLE public.auth_group ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    237    236    237            $           2604    318010    auth_group_permissions id    DEFAULT     �   ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);
 H   ALTER TABLE public.auth_group_permissions ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    238    239    239            "           2604    317992    auth_permission id    DEFAULT     x   ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);
 A   ALTER TABLE public.auth_permission ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    235    234    235            8           2604    318883    contact_contactentry id    DEFAULT     �   ALTER TABLE ONLY public.contact_contactentry ALTER COLUMN id SET DEFAULT nextval('public.contact_contactentry_id_seq'::regclass);
 F   ALTER TABLE public.contact_contactentry ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    271    270    271            C           2604    319219 (   custom_attributes_epiccustomattribute id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_epiccustomattribute_id_seq'::regclass);
 W   ALTER TABLE public.custom_attributes_epiccustomattribute ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    294    293    294            D           2604    319230 /   custom_attributes_epiccustomattributesvalues id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_epiccustomattributesvalues_id_seq'::regclass);
 ^   ALTER TABLE public.custom_attributes_epiccustomattributesvalues ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    295    296    296            =           2604    319094 )   custom_attributes_issuecustomattribute id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_issuecustomattribute_id_seq'::regclass);
 X   ALTER TABLE public.custom_attributes_issuecustomattribute ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    281    282    282            @           2604    319151 0   custom_attributes_issuecustomattributesvalues id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_issuecustomattributesvalues_id_seq'::regclass);
 _   ALTER TABLE public.custom_attributes_issuecustomattributesvalues ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    288    287    288            >           2604    319105 (   custom_attributes_taskcustomattribute id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_taskcustomattribute_id_seq'::regclass);
 W   ALTER TABLE public.custom_attributes_taskcustomattribute ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    283    284    284            A           2604    319164 /   custom_attributes_taskcustomattributesvalues id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_taskcustomattributesvalues_id_seq'::regclass);
 ^   ALTER TABLE public.custom_attributes_taskcustomattributesvalues ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    289    290    290            ?           2604    319116 -   custom_attributes_userstorycustomattribute id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_userstorycustomattribute_id_seq'::regclass);
 \   ALTER TABLE public.custom_attributes_userstorycustomattribute ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    286    285    286            B           2604    319177 4   custom_attributes_userstorycustomattributesvalues id    DEFAULT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues ALTER COLUMN id SET DEFAULT nextval('public.custom_attributes_userstorycustomattributesvalues_id_seq'::regclass);
 c   ALTER TABLE public.custom_attributes_userstorycustomattributesvalues ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    291    292    292                       2604    317682    django_admin_log id    DEFAULT     z   ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);
 B   ALTER TABLE public.django_admin_log ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    209    208    209            	           2604    317658    django_content_type id    DEFAULT     �   ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);
 E   ALTER TABLE public.django_content_type ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    204    205    205                       2604    317647    django_migrations id    DEFAULT     |   ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);
 C   ALTER TABLE public.django_migrations ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    203    202    203            E           2604    319340    easy_thumbnails_source id    DEFAULT     �   ALTER TABLE ONLY public.easy_thumbnails_source ALTER COLUMN id SET DEFAULT nextval('public.easy_thumbnails_source_id_seq'::regclass);
 H   ALTER TABLE public.easy_thumbnails_source ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    299    298    299            F           2604    319348    easy_thumbnails_thumbnail id    DEFAULT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnail ALTER COLUMN id SET DEFAULT nextval('public.easy_thumbnails_thumbnail_id_seq'::regclass);
 K   ALTER TABLE public.easy_thumbnails_thumbnail ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    300    301    301            G           2604    319374 &   easy_thumbnails_thumbnaildimensions id    DEFAULT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions ALTER COLUMN id SET DEFAULT nextval('public.easy_thumbnails_thumbnaildimensions_id_seq'::regclass);
 U   ALTER TABLE public.easy_thumbnails_thumbnaildimensions ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    303    302    303            ;           2604    319035    epics_epic id    DEFAULT     n   ALTER TABLE ONLY public.epics_epic ALTER COLUMN id SET DEFAULT nextval('public.epics_epic_id_seq'::regclass);
 <   ALTER TABLE public.epics_epic ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    277    278    278            <           2604    319046    epics_relateduserstory id    DEFAULT     �   ALTER TABLE ONLY public.epics_relateduserstory ALTER COLUMN id SET DEFAULT nextval('public.epics_relateduserstory_id_seq'::regclass);
 H   ALTER TABLE public.epics_relateduserstory ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    279    280    280            J           2604    319425 !   external_apps_applicationtoken id    DEFAULT     �   ALTER TABLE ONLY public.external_apps_applicationtoken ALTER COLUMN id SET DEFAULT nextval('public.external_apps_applicationtoken_id_seq'::regclass);
 P   ALTER TABLE public.external_apps_applicationtoken ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    305    306    306            K           2604    319452    feedback_feedbackentry id    DEFAULT     �   ALTER TABLE ONLY public.feedback_feedbackentry ALTER COLUMN id SET DEFAULT nextval('public.feedback_feedbackentry_id_seq'::regclass);
 H   ALTER TABLE public.feedback_feedbackentry ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    308    307    308            '           2604    318111    issues_issue id    DEFAULT     r   ALTER TABLE ONLY public.issues_issue ALTER COLUMN id SET DEFAULT nextval('public.issues_issue_id_seq'::regclass);
 >   ALTER TABLE public.issues_issue ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    242    243    243            5           2604    318697    likes_like id    DEFAULT     n   ALTER TABLE ONLY public.likes_like ALTER COLUMN id SET DEFAULT nextval('public.likes_like_id_seq'::regclass);
 <   ALTER TABLE public.likes_like ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    266    267    267            %           2604    318060    milestones_milestone id    DEFAULT     �   ALTER TABLE ONLY public.milestones_milestone ALTER COLUMN id SET DEFAULT nextval('public.milestones_milestone_id_seq'::regclass);
 F   ALTER TABLE public.milestones_milestone ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    241    240    241            +           2604    318371 *   notifications_historychangenotification id    DEFAULT     �   ALTER TABLE ONLY public.notifications_historychangenotification ALTER COLUMN id SET DEFAULT nextval('public.notifications_historychangenotification_id_seq'::regclass);
 Y   ALTER TABLE public.notifications_historychangenotification ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    251    250    251            ,           2604    318379 :   notifications_historychangenotification_history_entries id    DEFAULT     �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries ALTER COLUMN id SET DEFAULT nextval('public.notifications_historychangenotification_history_entries_id_seq'::regclass);
 i   ALTER TABLE public.notifications_historychangenotification_history_entries ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    253    252    253            -           2604    318387 7   notifications_historychangenotification_notify_users id    DEFAULT     �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users ALTER COLUMN id SET DEFAULT nextval('public.notifications_historychangenotification_notify_users_id_seq'::regclass);
 f   ALTER TABLE public.notifications_historychangenotification_notify_users ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    254    255    255            *           2604    318328    notifications_notifypolicy id    DEFAULT     �   ALTER TABLE ONLY public.notifications_notifypolicy ALTER COLUMN id SET DEFAULT nextval('public.notifications_notifypolicy_id_seq'::regclass);
 L   ALTER TABLE public.notifications_notifypolicy ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    249    248    249            .           2604    318438    notifications_watched id    DEFAULT     �   ALTER TABLE ONLY public.notifications_watched ALTER COLUMN id SET DEFAULT nextval('public.notifications_watched_id_seq'::regclass);
 G   ALTER TABLE public.notifications_watched ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    257    256    257            L           2604    319511     notifications_webnotification id    DEFAULT     �   ALTER TABLE ONLY public.notifications_webnotification ALTER COLUMN id SET DEFAULT nextval('public.notifications_webnotification_id_seq'::regclass);
 O   ALTER TABLE public.notifications_webnotification ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    310    309    310            7           2604    318804    projects_epicstatus id    DEFAULT     �   ALTER TABLE ONLY public.projects_epicstatus ALTER COLUMN id SET DEFAULT nextval('public.projects_epicstatus_id_seq'::regclass);
 E   ALTER TABLE public.projects_epicstatus ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    268    269    269            O           2604    319554    projects_issueduedate id    DEFAULT     �   ALTER TABLE ONLY public.projects_issueduedate ALTER COLUMN id SET DEFAULT nextval('public.projects_issueduedate_id_seq'::regclass);
 G   ALTER TABLE public.projects_issueduedate ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    313    314    314                       2604    317772    projects_issuestatus id    DEFAULT     �   ALTER TABLE ONLY public.projects_issuestatus ALTER COLUMN id SET DEFAULT nextval('public.projects_issuestatus_id_seq'::regclass);
 F   ALTER TABLE public.projects_issuestatus ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    217    216    217                       2604    317780    projects_issuetype id    DEFAULT     ~   ALTER TABLE ONLY public.projects_issuetype ALTER COLUMN id SET DEFAULT nextval('public.projects_issuetype_id_seq'::regclass);
 D   ALTER TABLE public.projects_issuetype ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    219    218    219                       2604    317719    projects_membership id    DEFAULT     �   ALTER TABLE ONLY public.projects_membership ALTER COLUMN id SET DEFAULT nextval('public.projects_membership_id_seq'::regclass);
 E   ALTER TABLE public.projects_membership ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    213    212    213                       2604    317788    projects_points id    DEFAULT     x   ALTER TABLE ONLY public.projects_points ALTER COLUMN id SET DEFAULT nextval('public.projects_points_id_seq'::regclass);
 A   ALTER TABLE public.projects_points ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    220    221    221                       2604    317796    projects_priority id    DEFAULT     |   ALTER TABLE ONLY public.projects_priority ALTER COLUMN id SET DEFAULT nextval('public.projects_priority_id_seq'::regclass);
 C   ALTER TABLE public.projects_priority ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    222    223    223                       2604    317727    projects_project id    DEFAULT     z   ALTER TABLE ONLY public.projects_project ALTER COLUMN id SET DEFAULT nextval('public.projects_project_id_seq'::regclass);
 B   ALTER TABLE public.projects_project ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    215    214    215            2           2604    318622     projects_projectmodulesconfig id    DEFAULT     �   ALTER TABLE ONLY public.projects_projectmodulesconfig ALTER COLUMN id SET DEFAULT nextval('public.projects_projectmodulesconfig_id_seq'::regclass);
 O   ALTER TABLE public.projects_projectmodulesconfig ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    262    263    263                       2604    317804    projects_projecttemplate id    DEFAULT     �   ALTER TABLE ONLY public.projects_projecttemplate ALTER COLUMN id SET DEFAULT nextval('public.projects_projecttemplate_id_seq'::regclass);
 J   ALTER TABLE public.projects_projecttemplate ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    224    225    225                       2604    317817    projects_severity id    DEFAULT     |   ALTER TABLE ONLY public.projects_severity ALTER COLUMN id SET DEFAULT nextval('public.projects_severity_id_seq'::regclass);
 C   ALTER TABLE public.projects_severity ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    227    226    227            R           2604    319609    projects_swimlane id    DEFAULT     |   ALTER TABLE ONLY public.projects_swimlane ALTER COLUMN id SET DEFAULT nextval('public.projects_swimlane_id_seq'::regclass);
 C   ALTER TABLE public.projects_swimlane ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    319    320    320            S           2604    319626 #   projects_swimlaneuserstorystatus id    DEFAULT     �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus ALTER COLUMN id SET DEFAULT nextval('public.projects_swimlaneuserstorystatus_id_seq'::regclass);
 R   ALTER TABLE public.projects_swimlaneuserstorystatus ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    321    322    322            P           2604    319562    projects_taskduedate id    DEFAULT     �   ALTER TABLE ONLY public.projects_taskduedate ALTER COLUMN id SET DEFAULT nextval('public.projects_taskduedate_id_seq'::regclass);
 F   ALTER TABLE public.projects_taskduedate ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    316    315    316                       2604    317825    projects_taskstatus id    DEFAULT     �   ALTER TABLE ONLY public.projects_taskstatus ALTER COLUMN id SET DEFAULT nextval('public.projects_taskstatus_id_seq'::regclass);
 E   ALTER TABLE public.projects_taskstatus ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    228    229    229            Q           2604    319570    projects_userstoryduedate id    DEFAULT     �   ALTER TABLE ONLY public.projects_userstoryduedate ALTER COLUMN id SET DEFAULT nextval('public.projects_userstoryduedate_id_seq'::regclass);
 K   ALTER TABLE public.projects_userstoryduedate ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    317    318    318                       2604    317833    projects_userstorystatus id    DEFAULT     �   ALTER TABLE ONLY public.projects_userstorystatus ALTER COLUMN id SET DEFAULT nextval('public.projects_userstorystatus_id_seq'::regclass);
 J   ALTER TABLE public.projects_userstorystatus ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    231    230    231            T           2604    319665    references_reference id    DEFAULT     �   ALTER TABLE ONLY public.references_reference ALTER COLUMN id SET DEFAULT nextval('public.references_reference_id_seq'::regclass);
 F   ALTER TABLE public.references_reference ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    324    323    324            V           2604    319698    settings_userprojectsettings id    DEFAULT     �   ALTER TABLE ONLY public.settings_userprojectsettings ALTER COLUMN id SET DEFAULT nextval('public.settings_userprojectsettings_id_seq'::regclass);
 N   ALTER TABLE public.settings_userprojectsettings ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    327    326    327            0           2604    318467    tasks_task id    DEFAULT     n   ALTER TABLE ONLY public.tasks_task ALTER COLUMN id SET DEFAULT nextval('public.tasks_task_id_seq'::regclass);
 <   ALTER TABLE public.tasks_task ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    259    258    259            W           2604    319754    telemetry_instancetelemetry id    DEFAULT     �   ALTER TABLE ONLY public.telemetry_instancetelemetry ALTER COLUMN id SET DEFAULT nextval('public.telemetry_instancetelemetry_id_seq'::regclass);
 M   ALTER TABLE public.telemetry_instancetelemetry ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    328    329    329            3           2604    318647    timeline_timeline id    DEFAULT     |   ALTER TABLE ONLY public.timeline_timeline ALTER COLUMN id SET DEFAULT nextval('public.timeline_timeline_id_seq'::regclass);
 C   ALTER TABLE public.timeline_timeline ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    264    265    265            Y           2604    319795 !   token_denylist_denylistedtoken id    DEFAULT     �   ALTER TABLE ONLY public.token_denylist_denylistedtoken ALTER COLUMN id SET DEFAULT nextval('public.token_denylist_denylistedtoken_id_seq'::regclass);
 P   ALTER TABLE public.token_denylist_denylistedtoken ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    333    332    333            X           2604    319782 "   token_denylist_outstandingtoken id    DEFAULT     �   ALTER TABLE ONLY public.token_denylist_outstandingtoken ALTER COLUMN id SET DEFAULT nextval('public.token_denylist_outstandingtoken_id_seq'::regclass);
 Q   ALTER TABLE public.token_denylist_outstandingtoken ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    330    331    331            1           2604    318549    users_authdata id    DEFAULT     v   ALTER TABLE ONLY public.users_authdata ALTER COLUMN id SET DEFAULT nextval('public.users_authdata_id_seq'::regclass);
 @   ALTER TABLE public.users_authdata ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    260    261    261                       2604    317706    users_role id    DEFAULT     n   ALTER TABLE ONLY public.users_role ALTER COLUMN id SET DEFAULT nextval('public.users_role_id_seq'::regclass);
 <   ALTER TABLE public.users_role ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    211    210    211            
           2604    317668    users_user id    DEFAULT     n   ALTER TABLE ONLY public.users_user ALTER COLUMN id SET DEFAULT nextval('public.users_user_id_seq'::regclass);
 <   ALTER TABLE public.users_user ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    207    206    207            Z           2604    319839    users_workspacerole id    DEFAULT     �   ALTER TABLE ONLY public.users_workspacerole ALTER COLUMN id SET DEFAULT nextval('public.users_workspacerole_id_seq'::regclass);
 E   ALTER TABLE public.users_workspacerole ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    335    334    335            [           2604    319860    userstorage_storageentry id    DEFAULT     �   ALTER TABLE ONLY public.userstorage_storageentry ALTER COLUMN id SET DEFAULT nextval('public.userstorage_storageentry_id_seq'::regclass);
 J   ALTER TABLE public.userstorage_storageentry ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    336    337    337            (           2604    318193    userstories_rolepoints id    DEFAULT     �   ALTER TABLE ONLY public.userstories_rolepoints ALTER COLUMN id SET DEFAULT nextval('public.userstories_rolepoints_id_seq'::regclass);
 H   ALTER TABLE public.userstories_rolepoints ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    244    245    245            )           2604    318201    userstories_userstory id    DEFAULT     �   ALTER TABLE ONLY public.userstories_userstory ALTER COLUMN id SET DEFAULT nextval('public.userstories_userstory_id_seq'::regclass);
 G   ALTER TABLE public.userstories_userstory ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    246    247    247            \           2604    319931 '   userstories_userstory_assigned_users id    DEFAULT     �   ALTER TABLE ONLY public.userstories_userstory_assigned_users ALTER COLUMN id SET DEFAULT nextval('public.userstories_userstory_assigned_users_id_seq'::regclass);
 V   ALTER TABLE public.userstories_userstory_assigned_users ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    339    338    339            ]           2604    319970    votes_vote id    DEFAULT     n   ALTER TABLE ONLY public.votes_vote ALTER COLUMN id SET DEFAULT nextval('public.votes_vote_id_seq'::regclass);
 <   ALTER TABLE public.votes_vote ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    341    340    341            _           2604    319979    votes_votes id    DEFAULT     p   ALTER TABLE ONLY public.votes_votes ALTER COLUMN id SET DEFAULT nextval('public.votes_votes_id_seq'::regclass);
 =   ALTER TABLE public.votes_votes ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    343    342    343            b           2604    320017    webhooks_webhook id    DEFAULT     z   ALTER TABLE ONLY public.webhooks_webhook ALTER COLUMN id SET DEFAULT nextval('public.webhooks_webhook_id_seq'::regclass);
 B   ALTER TABLE public.webhooks_webhook ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    345    344    345            c           2604    320028    webhooks_webhooklog id    DEFAULT     �   ALTER TABLE ONLY public.webhooks_webhooklog ALTER COLUMN id SET DEFAULT nextval('public.webhooks_webhooklog_id_seq'::regclass);
 E   ALTER TABLE public.webhooks_webhooklog ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    347    346    347            9           2604    318906    wiki_wikilink id    DEFAULT     t   ALTER TABLE ONLY public.wiki_wikilink ALTER COLUMN id SET DEFAULT nextval('public.wiki_wikilink_id_seq'::regclass);
 ?   ALTER TABLE public.wiki_wikilink ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    273    272    273            :           2604    318918    wiki_wikipage id    DEFAULT     t   ALTER TABLE ONLY public.wiki_wikipage ALTER COLUMN id SET DEFAULT nextval('public.wiki_wikipage_id_seq'::regclass);
 ?   ALTER TABLE public.wiki_wikipage ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    275    274    275            N           2604    319531    workspaces_workspace id    DEFAULT     �   ALTER TABLE ONLY public.workspaces_workspace ALTER COLUMN id SET DEFAULT nextval('public.workspaces_workspace_id_seq'::regclass);
 F   ALTER TABLE public.workspaces_workspace ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    311    312    312            d           2604    320075 !   workspaces_workspacemembership id    DEFAULT     �   ALTER TABLE ONLY public.workspaces_workspacemembership ALTER COLUMN id SET DEFAULT nextval('public.workspaces_workspacemembership_id_seq'::regclass);
 P   ALTER TABLE public.workspaces_workspacemembership ALTER COLUMN id DROP DEFAULT;
       public          taiga    false    348    349    349            �          0    317950    attachments_attachment 
   TABLE DATA           �   COPY public.attachments_attachment (id, object_id, created_date, modified_date, attached_file, is_deprecated, description, "order", content_type_id, owner_id, project_id, name, size, sha1, from_comment) FROM stdin;
    public          taiga    false    233   �      �          0    317997 
   auth_group 
   TABLE DATA           .   COPY public.auth_group (id, name) FROM stdin;
    public          taiga    false    237   �      �          0    318007    auth_group_permissions 
   TABLE DATA           M   COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
    public          taiga    false    239   	      �          0    317989    auth_permission 
   TABLE DATA           N   COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
    public          taiga    false    235   &      �          0    318880    contact_contactentry 
   TABLE DATA           ^   COPY public.contact_contactentry (id, comment, created_date, project_id, user_id) FROM stdin;
    public          taiga    false    271   3      �          0    319216 %   custom_attributes_epiccustomattribute 
   TABLE DATA           �   COPY public.custom_attributes_epiccustomattribute (id, name, description, type, "order", created_date, modified_date, project_id, extra) FROM stdin;
    public          taiga    false    294   P      �          0    319227 ,   custom_attributes_epiccustomattributesvalues 
   TABLE DATA           o   COPY public.custom_attributes_epiccustomattributesvalues (id, version, attributes_values, epic_id) FROM stdin;
    public          taiga    false    296   m      �          0    319091 &   custom_attributes_issuecustomattribute 
   TABLE DATA           �   COPY public.custom_attributes_issuecustomattribute (id, name, description, "order", created_date, modified_date, project_id, type, extra) FROM stdin;
    public          taiga    false    282   �      �          0    319148 -   custom_attributes_issuecustomattributesvalues 
   TABLE DATA           q   COPY public.custom_attributes_issuecustomattributesvalues (id, version, attributes_values, issue_id) FROM stdin;
    public          taiga    false    288   �      �          0    319102 %   custom_attributes_taskcustomattribute 
   TABLE DATA           �   COPY public.custom_attributes_taskcustomattribute (id, name, description, "order", created_date, modified_date, project_id, type, extra) FROM stdin;
    public          taiga    false    284   �      �          0    319161 ,   custom_attributes_taskcustomattributesvalues 
   TABLE DATA           o   COPY public.custom_attributes_taskcustomattributesvalues (id, version, attributes_values, task_id) FROM stdin;
    public          taiga    false    290   �      �          0    319113 *   custom_attributes_userstorycustomattribute 
   TABLE DATA           �   COPY public.custom_attributes_userstorycustomattribute (id, name, description, "order", created_date, modified_date, project_id, type, extra) FROM stdin;
    public          taiga    false    286   �      �          0    319174 1   custom_attributes_userstorycustomattributesvalues 
   TABLE DATA           z   COPY public.custom_attributes_userstorycustomattributesvalues (id, version, attributes_values, user_story_id) FROM stdin;
    public          taiga    false    292         j          0    317679    django_admin_log 
   TABLE DATA           �   COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
    public          taiga    false    209   8      f          0    317655    django_content_type 
   TABLE DATA           C   COPY public.django_content_type (id, app_label, model) FROM stdin;
    public          taiga    false    205   U      d          0    317644    django_migrations 
   TABLE DATA           C   COPY public.django_migrations (id, app, name, applied) FROM stdin;
    public          taiga    false    203         �          0    319683    django_session 
   TABLE DATA           P   COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
    public          taiga    false    325   (      �          0    319326    djmail_message 
   TABLE DATA           �   COPY public.djmail_message (uuid, from_email, to_email, body_text, body_html, subject, data, retry_count, status, priority, created_at, sent_at, exception) FROM stdin;
    public          taiga    false    297   *(      �          0    319337    easy_thumbnails_source 
   TABLE DATA           R   COPY public.easy_thumbnails_source (id, storage_hash, name, modified) FROM stdin;
    public          taiga    false    299   G(      �          0    319345    easy_thumbnails_thumbnail 
   TABLE DATA           `   COPY public.easy_thumbnails_thumbnail (id, storage_hash, name, modified, source_id) FROM stdin;
    public          taiga    false    301   d(      �          0    319371 #   easy_thumbnails_thumbnaildimensions 
   TABLE DATA           ^   COPY public.easy_thumbnails_thumbnaildimensions (id, thumbnail_id, width, height) FROM stdin;
    public          taiga    false    303   �(      �          0    319032 
   epics_epic 
   TABLE DATA             COPY public.epics_epic (id, tags, version, is_blocked, blocked_note, ref, epics_order, created_date, modified_date, subject, description, client_requirement, team_requirement, assigned_to_id, owner_id, project_id, status_id, color, external_reference) FROM stdin;
    public          taiga    false    278   �(      �          0    319043    epics_relateduserstory 
   TABLE DATA           U   COPY public.epics_relateduserstory (id, "order", epic_id, user_story_id) FROM stdin;
    public          taiga    false    280   �(      �          0    319412    external_apps_application 
   TABLE DATA           c   COPY public.external_apps_application (id, name, icon_url, web, description, next_url) FROM stdin;
    public          taiga    false    304   �(      �          0    319422    external_apps_applicationtoken 
   TABLE DATA           n   COPY public.external_apps_applicationtoken (id, auth_code, token, state, application_id, user_id) FROM stdin;
    public          taiga    false    306   �(      �          0    319449    feedback_feedbackentry 
   TABLE DATA           ]   COPY public.feedback_feedbackentry (id, full_name, email, comment, created_date) FROM stdin;
    public          taiga    false    308   )      �          0    318994    history_historyentry 
   TABLE DATA             COPY public.history_historyentry (id, "user", created_at, type, is_snapshot, key, diff, snapshot, "values", comment, comment_html, delete_comment_date, delete_comment_user, is_hidden, comment_versions, edit_comment_date, project_id, values_diff_cache) FROM stdin;
    public          taiga    false    276   /)      �          0    318108    issues_issue 
   TABLE DATA           +  COPY public.issues_issue (id, tags, version, is_blocked, blocked_note, ref, created_date, modified_date, finished_date, subject, description, assigned_to_id, milestone_id, owner_id, priority_id, project_id, severity_id, status_id, type_id, external_reference, due_date, due_date_reason) FROM stdin;
    public          taiga    false    243   L)      �          0    318694 
   likes_like 
   TABLE DATA           [   COPY public.likes_like (id, object_id, created_date, content_type_id, user_id) FROM stdin;
    public          taiga    false    267   i)      �          0    318057    milestones_milestone 
   TABLE DATA           �   COPY public.milestones_milestone (id, name, slug, estimated_start, estimated_finish, created_date, modified_date, closed, disponibility, "order", owner_id, project_id) FROM stdin;
    public          taiga    false    241   �)      �          0    318368 '   notifications_historychangenotification 
   TABLE DATA           �   COPY public.notifications_historychangenotification (id, key, created_datetime, updated_datetime, history_type, owner_id, project_id) FROM stdin;
    public          taiga    false    251   �)      �          0    318376 7   notifications_historychangenotification_history_entries 
   TABLE DATA           �   COPY public.notifications_historychangenotification_history_entries (id, historychangenotification_id, historyentry_id) FROM stdin;
    public          taiga    false    253   �)      �          0    318384 4   notifications_historychangenotification_notify_users 
   TABLE DATA           y   COPY public.notifications_historychangenotification_notify_users (id, historychangenotification_id, user_id) FROM stdin;
    public          taiga    false    255   �)      �          0    318325    notifications_notifypolicy 
   TABLE DATA           �   COPY public.notifications_notifypolicy (id, notify_level, created_at, modified_at, project_id, user_id, live_notify_level, web_notify_level) FROM stdin;
    public          taiga    false    249   �)      �          0    318435    notifications_watched 
   TABLE DATA           r   COPY public.notifications_watched (id, object_id, created_date, content_type_id, user_id, project_id) FROM stdin;
    public          taiga    false    257   V1      �          0    319508    notifications_webnotification 
   TABLE DATA           e   COPY public.notifications_webnotification (id, created, read, event_type, data, user_id) FROM stdin;
    public          taiga    false    310   s1      �          0    318801    projects_epicstatus 
   TABLE DATA           d   COPY public.projects_epicstatus (id, name, slug, "order", is_closed, color, project_id) FROM stdin;
    public          taiga    false    269   �1      �          0    319551    projects_issueduedate 
   TABLE DATA           n   COPY public.projects_issueduedate (id, name, "order", by_default, color, days_to_due, project_id) FROM stdin;
    public          taiga    false    314   P4      r          0    317769    projects_issuestatus 
   TABLE DATA           e   COPY public.projects_issuestatus (id, name, "order", is_closed, color, project_id, slug) FROM stdin;
    public          taiga    false    217   �5      t          0    317777    projects_issuetype 
   TABLE DATA           R   COPY public.projects_issuetype (id, name, "order", color, project_id) FROM stdin;
    public          taiga    false    219   �;      n          0    317716    projects_membership 
   TABLE DATA           �   COPY public.projects_membership (id, is_admin, email, created_at, token, user_id, project_id, role_id, invited_by_id, invitation_extra_text, user_order) FROM stdin;
    public          taiga    false    213   1=      v          0    317785    projects_points 
   TABLE DATA           O   COPY public.projects_points (id, name, "order", value, project_id) FROM stdin;
    public          taiga    false    221   WD      x          0    317793    projects_priority 
   TABLE DATA           Q   COPY public.projects_priority (id, name, "order", color, project_id) FROM stdin;
    public          taiga    false    223   FI      p          0    317724    projects_project 
   TABLE DATA             COPY public.projects_project (id, tags, name, slug, description, created_date, modified_date, total_milestones, total_story_points, is_backlog_activated, is_kanban_activated, is_wiki_activated, is_issues_activated, videoconferences, videoconferences_extra_data, anon_permissions, public_permissions, is_private, tags_colors, owner_id, creation_template_id, default_issue_status_id, default_issue_type_id, default_points_id, default_priority_id, default_severity_id, default_task_status_id, default_us_status_id, issues_csv_uuid, tasks_csv_uuid, userstories_csv_uuid, is_featured, is_looking_for_people, total_activity, total_activity_last_month, total_activity_last_week, total_activity_last_year, total_fans, total_fans_last_month, total_fans_last_week, total_fans_last_year, totals_updated_datetime, logo, looking_for_people_note, blocked_code, transfer_token, is_epics_activated, default_epic_status_id, epics_csv_uuid, is_contact_activated, default_swimlane_id, workspace_id, color, workspace_member_permissions) FROM stdin;
    public          taiga    false    215   �J      �          0    318619    projects_projectmodulesconfig 
   TABLE DATA           O   COPY public.projects_projectmodulesconfig (id, config, project_id) FROM stdin;
    public          taiga    false    263   	^      z          0    317801    projects_projecttemplate 
   TABLE DATA           �  COPY public.projects_projecttemplate (id, name, slug, description, created_date, modified_date, default_owner_role, is_backlog_activated, is_kanban_activated, is_wiki_activated, is_issues_activated, videoconferences, videoconferences_extra_data, default_options, us_statuses, points, task_statuses, issue_statuses, issue_types, priorities, severities, roles, "order", epic_statuses, is_epics_activated, is_contact_activated, epic_custom_attributes, is_looking_for_people, issue_custom_attributes, looking_for_people_note, tags, tags_colors, task_custom_attributes, us_custom_attributes, issue_duedates, task_duedates, us_duedates) FROM stdin;
    public          taiga    false    225   &^      |          0    317814    projects_severity 
   TABLE DATA           Q   COPY public.projects_severity (id, name, "order", color, project_id) FROM stdin;
    public          taiga    false    227   �c      �          0    319606    projects_swimlane 
   TABLE DATA           J   COPY public.projects_swimlane (id, name, "order", project_id) FROM stdin;
    public          taiga    false    320   ?f      �          0    319623     projects_swimlaneuserstorystatus 
   TABLE DATA           a   COPY public.projects_swimlaneuserstorystatus (id, wip_limit, status_id, swimlane_id) FROM stdin;
    public          taiga    false    322   \f      �          0    319559    projects_taskduedate 
   TABLE DATA           m   COPY public.projects_taskduedate (id, name, "order", by_default, color, days_to_due, project_id) FROM stdin;
    public          taiga    false    316   yf      ~          0    317822    projects_taskstatus 
   TABLE DATA           d   COPY public.projects_taskstatus (id, name, "order", is_closed, color, project_id, slug) FROM stdin;
    public          taiga    false    229   #h      �          0    319567    projects_userstoryduedate 
   TABLE DATA           r   COPY public.projects_userstoryduedate (id, name, "order", by_default, color, days_to_due, project_id) FROM stdin;
    public          taiga    false    318   �k      �          0    317830    projects_userstorystatus 
   TABLE DATA           �   COPY public.projects_userstorystatus (id, name, "order", is_closed, color, wip_limit, project_id, slug, is_archived) FROM stdin;
    public          taiga    false    231   �m      �          0    319662    references_reference 
   TABLE DATA           k   COPY public.references_reference (id, object_id, ref, created_at, content_type_id, project_id) FROM stdin;
    public          taiga    false    324   -r      �          0    319695    settings_userprojectsettings 
   TABLE DATA           r   COPY public.settings_userprojectsettings (id, homepage, created_at, modified_at, project_id, user_id) FROM stdin;
    public          taiga    false    327   Jr      �          0    318464 
   tasks_task 
   TABLE DATA           <  COPY public.tasks_task (id, tags, version, is_blocked, blocked_note, ref, created_date, modified_date, finished_date, subject, description, is_iocaine, assigned_to_id, milestone_id, owner_id, project_id, status_id, user_story_id, taskboard_order, us_order, external_reference, due_date, due_date_reason) FROM stdin;
    public          taiga    false    259   gr      �          0    319751    telemetry_instancetelemetry 
   TABLE DATA           R   COPY public.telemetry_instancetelemetry (id, instance_id, created_at) FROM stdin;
    public          taiga    false    329   �r      �          0    318644    timeline_timeline 
   TABLE DATA           �   COPY public.timeline_timeline (id, object_id, namespace, event_type, project_id, data, data_content_type_id, created, content_type_id) FROM stdin;
    public          taiga    false    265   �r      �          0    319792    token_denylist_denylistedtoken 
   TABLE DATA           U   COPY public.token_denylist_denylistedtoken (id, denylisted_at, token_id) FROM stdin;
    public          taiga    false    333   �      �          0    319779    token_denylist_outstandingtoken 
   TABLE DATA           j   COPY public.token_denylist_outstandingtoken (id, jti, token, created_at, expires_at, user_id) FROM stdin;
    public          taiga    false    331   �      �          0    318546    users_authdata 
   TABLE DATA           H   COPY public.users_authdata (id, key, value, extra, user_id) FROM stdin;
    public          taiga    false    261   !�      l          0    317703 
   users_role 
   TABLE DATA           l   COPY public.users_role (id, name, slug, permissions, "order", computable, project_id, is_admin) FROM stdin;
    public          taiga    false    211   >�      h          0    317665 
   users_user 
   TABLE DATA           �  COPY public.users_user (id, password, last_login, is_superuser, username, email, is_active, full_name, color, bio, photo, date_joined, lang, timezone, colorize_tags, token, email_token, new_email, is_system, theme, max_private_projects, max_public_projects, max_memberships_private_projects, max_memberships_public_projects, uuid, accepted_terms, read_new_terms, verified_email, is_staff, date_cancelled) FROM stdin;
    public          taiga    false    207   ��      �          0    319836    users_workspacerole 
   TABLE DATA           k   COPY public.users_workspacerole (id, name, slug, permissions, "order", is_admin, workspace_id) FROM stdin;
    public          taiga    false    335   d�      �          0    319857    userstorage_storageentry 
   TABLE DATA           i   COPY public.userstorage_storageentry (id, created_date, modified_date, key, value, owner_id) FROM stdin;
    public          taiga    false    337   ߑ      �          0    318190    userstories_rolepoints 
   TABLE DATA           W   COPY public.userstories_rolepoints (id, points_id, role_id, user_story_id) FROM stdin;
    public          taiga    false    245   ��      �          0    318198    userstories_userstory 
   TABLE DATA           �  COPY public.userstories_userstory (id, tags, version, is_blocked, blocked_note, ref, is_closed, backlog_order, created_date, modified_date, finish_date, subject, description, client_requirement, team_requirement, assigned_to_id, generated_from_issue_id, milestone_id, owner_id, project_id, status_id, sprint_order, kanban_order, external_reference, tribe_gig, due_date, due_date_reason, generated_from_task_id, from_task_ref, swimlane_id) FROM stdin;
    public          taiga    false    247   �      �          0    319928 $   userstories_userstory_assigned_users 
   TABLE DATA           Y   COPY public.userstories_userstory_assigned_users (id, userstory_id, user_id) FROM stdin;
    public          taiga    false    339   6�      �          0    319967 
   votes_vote 
   TABLE DATA           [   COPY public.votes_vote (id, object_id, content_type_id, user_id, created_date) FROM stdin;
    public          taiga    false    341   S�      �          0    319976    votes_votes 
   TABLE DATA           L   COPY public.votes_votes (id, object_id, count, content_type_id) FROM stdin;
    public          taiga    false    343   p�      �          0    320014    webhooks_webhook 
   TABLE DATA           J   COPY public.webhooks_webhook (id, url, key, project_id, name) FROM stdin;
    public          taiga    false    345   ��      �          0    320025    webhooks_webhooklog 
   TABLE DATA           �   COPY public.webhooks_webhooklog (id, url, status, request_data, response_data, webhook_id, created, duration, request_headers, response_headers) FROM stdin;
    public          taiga    false    347   ��      �          0    318903    wiki_wikilink 
   TABLE DATA           M   COPY public.wiki_wikilink (id, title, href, "order", project_id) FROM stdin;
    public          taiga    false    273   ǒ      �          0    318915    wiki_wikipage 
   TABLE DATA           �   COPY public.wiki_wikipage (id, version, slug, content, created_date, modified_date, last_modifier_id, owner_id, project_id) FROM stdin;
    public          taiga    false    275   �      �          0    319528    workspaces_workspace 
   TABLE DATA           x   COPY public.workspaces_workspace (id, name, slug, color, created_date, modified_date, owner_id, is_premium) FROM stdin;
    public          taiga    false    312   �      �          0    320072    workspaces_workspacemembership 
   TABLE DATA           f   COPY public.workspaces_workspacemembership (id, user_id, workspace_id, workspace_role_id) FROM stdin;
    public          taiga    false    349   ×      e           0    0    attachments_attachment_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.attachments_attachment_id_seq', 1, false);
          public          taiga    false    232            f           0    0    auth_group_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);
          public          taiga    false    236            g           0    0    auth_group_permissions_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);
          public          taiga    false    238            h           0    0    auth_permission_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.auth_permission_id_seq', 284, true);
          public          taiga    false    234            i           0    0    contact_contactentry_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.contact_contactentry_id_seq', 1, false);
          public          taiga    false    270            j           0    0 ,   custom_attributes_epiccustomattribute_id_seq    SEQUENCE SET     [   SELECT pg_catalog.setval('public.custom_attributes_epiccustomattribute_id_seq', 1, false);
          public          taiga    false    293            k           0    0 3   custom_attributes_epiccustomattributesvalues_id_seq    SEQUENCE SET     b   SELECT pg_catalog.setval('public.custom_attributes_epiccustomattributesvalues_id_seq', 1, false);
          public          taiga    false    295            l           0    0 -   custom_attributes_issuecustomattribute_id_seq    SEQUENCE SET     \   SELECT pg_catalog.setval('public.custom_attributes_issuecustomattribute_id_seq', 1, false);
          public          taiga    false    281            m           0    0 4   custom_attributes_issuecustomattributesvalues_id_seq    SEQUENCE SET     c   SELECT pg_catalog.setval('public.custom_attributes_issuecustomattributesvalues_id_seq', 1, false);
          public          taiga    false    287            n           0    0 ,   custom_attributes_taskcustomattribute_id_seq    SEQUENCE SET     [   SELECT pg_catalog.setval('public.custom_attributes_taskcustomattribute_id_seq', 1, false);
          public          taiga    false    283            o           0    0 3   custom_attributes_taskcustomattributesvalues_id_seq    SEQUENCE SET     b   SELECT pg_catalog.setval('public.custom_attributes_taskcustomattributesvalues_id_seq', 1, false);
          public          taiga    false    289            p           0    0 1   custom_attributes_userstorycustomattribute_id_seq    SEQUENCE SET     `   SELECT pg_catalog.setval('public.custom_attributes_userstorycustomattribute_id_seq', 1, false);
          public          taiga    false    285            q           0    0 8   custom_attributes_userstorycustomattributesvalues_id_seq    SEQUENCE SET     g   SELECT pg_catalog.setval('public.custom_attributes_userstorycustomattributesvalues_id_seq', 1, false);
          public          taiga    false    291            r           0    0    django_admin_log_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);
          public          taiga    false    208            s           0    0    django_content_type_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.django_content_type_id_seq', 71, true);
          public          taiga    false    204            t           0    0    django_migrations_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.django_migrations_id_seq', 278, true);
          public          taiga    false    202            u           0    0    easy_thumbnails_source_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.easy_thumbnails_source_id_seq', 1, false);
          public          taiga    false    298            v           0    0     easy_thumbnails_thumbnail_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.easy_thumbnails_thumbnail_id_seq', 1, false);
          public          taiga    false    300            w           0    0 *   easy_thumbnails_thumbnaildimensions_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.easy_thumbnails_thumbnaildimensions_id_seq', 1, false);
          public          taiga    false    302            x           0    0    epics_epic_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.epics_epic_id_seq', 1, false);
          public          taiga    false    277            y           0    0    epics_relateduserstory_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.epics_relateduserstory_id_seq', 1, false);
          public          taiga    false    279            z           0    0 %   external_apps_applicationtoken_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public.external_apps_applicationtoken_id_seq', 1, false);
          public          taiga    false    305            {           0    0    feedback_feedbackentry_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.feedback_feedbackentry_id_seq', 1, false);
          public          taiga    false    307            |           0    0    issues_issue_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.issues_issue_id_seq', 1, false);
          public          taiga    false    242            }           0    0    likes_like_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.likes_like_id_seq', 1, false);
          public          taiga    false    266            ~           0    0    milestones_milestone_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.milestones_milestone_id_seq', 1, false);
          public          taiga    false    240                       0    0 >   notifications_historychangenotification_history_entries_id_seq    SEQUENCE SET     m   SELECT pg_catalog.setval('public.notifications_historychangenotification_history_entries_id_seq', 1, false);
          public          taiga    false    252            �           0    0 .   notifications_historychangenotification_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.notifications_historychangenotification_id_seq', 1, false);
          public          taiga    false    250            �           0    0 ;   notifications_historychangenotification_notify_users_id_seq    SEQUENCE SET     j   SELECT pg_catalog.setval('public.notifications_historychangenotification_notify_users_id_seq', 1, false);
          public          taiga    false    254            �           0    0 !   notifications_notifypolicy_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.notifications_notifypolicy_id_seq', 136, true);
          public          taiga    false    248            �           0    0    notifications_watched_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.notifications_watched_id_seq', 1, false);
          public          taiga    false    256            �           0    0 $   notifications_webnotification_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.notifications_webnotification_id_seq', 1, false);
          public          taiga    false    309            �           0    0    projects_epicstatus_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.projects_epicstatus_id_seq', 160, true);
          public          taiga    false    268            �           0    0    projects_issueduedate_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.projects_issueduedate_id_seq', 96, true);
          public          taiga    false    313            �           0    0    projects_issuestatus_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.projects_issuestatus_id_seq', 224, true);
          public          taiga    false    216            �           0    0    projects_issuetype_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.projects_issuetype_id_seq', 96, true);
          public          taiga    false    218            �           0    0    projects_membership_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.projects_membership_id_seq', 136, true);
          public          taiga    false    212            �           0    0    projects_points_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.projects_points_id_seq', 384, true);
          public          taiga    false    220            �           0    0    projects_priority_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.projects_priority_id_seq', 96, true);
          public          taiga    false    222            �           0    0    projects_project_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.projects_project_id_seq', 32, true);
          public          taiga    false    214            �           0    0 $   projects_projectmodulesconfig_id_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.projects_projectmodulesconfig_id_seq', 1, false);
          public          taiga    false    262            �           0    0    projects_projecttemplate_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.projects_projecttemplate_id_seq', 2, true);
          public          taiga    false    224            �           0    0    projects_severity_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.projects_severity_id_seq', 160, true);
          public          taiga    false    226            �           0    0    projects_swimlane_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.projects_swimlane_id_seq', 1, false);
          public          taiga    false    319            �           0    0 '   projects_swimlaneuserstorystatus_id_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public.projects_swimlaneuserstorystatus_id_seq', 1, false);
          public          taiga    false    321            �           0    0    projects_taskduedate_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.projects_taskduedate_id_seq', 96, true);
          public          taiga    false    315            �           0    0    projects_taskstatus_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.projects_taskstatus_id_seq', 160, true);
          public          taiga    false    228            �           0    0     projects_userstoryduedate_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.projects_userstoryduedate_id_seq', 96, true);
          public          taiga    false    317            �           0    0    projects_userstorystatus_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.projects_userstorystatus_id_seq', 192, true);
          public          taiga    false    230            �           0    0    references_project1    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project1', 1, false);
          public          taiga    false    350            �           0    0    references_project10    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project10', 1, false);
          public          taiga    false    359            �           0    0    references_project11    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project11', 1, false);
          public          taiga    false    360            �           0    0    references_project12    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project12', 1, false);
          public          taiga    false    361            �           0    0    references_project13    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project13', 1, false);
          public          taiga    false    362            �           0    0    references_project14    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project14', 1, false);
          public          taiga    false    363            �           0    0    references_project15    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project15', 1, false);
          public          taiga    false    364            �           0    0    references_project16    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project16', 1, false);
          public          taiga    false    365            �           0    0    references_project17    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project17', 1, false);
          public          taiga    false    366            �           0    0    references_project18    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project18', 1, false);
          public          taiga    false    367            �           0    0    references_project19    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project19', 1, false);
          public          taiga    false    368            �           0    0    references_project2    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project2', 1, false);
          public          taiga    false    351            �           0    0    references_project20    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project20', 1, false);
          public          taiga    false    369            �           0    0    references_project21    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project21', 1, false);
          public          taiga    false    370            �           0    0    references_project22    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project22', 1, false);
          public          taiga    false    371            �           0    0    references_project23    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project23', 1, false);
          public          taiga    false    372            �           0    0    references_project24    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project24', 1, false);
          public          taiga    false    373            �           0    0    references_project25    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project25', 1, false);
          public          taiga    false    374            �           0    0    references_project26    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project26', 1, false);
          public          taiga    false    375            �           0    0    references_project27    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project27', 1, false);
          public          taiga    false    376            �           0    0    references_project28    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project28', 1, false);
          public          taiga    false    377            �           0    0    references_project29    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project29', 1, false);
          public          taiga    false    378            �           0    0    references_project3    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project3', 1, false);
          public          taiga    false    352            �           0    0    references_project30    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project30', 1, false);
          public          taiga    false    379            �           0    0    references_project31    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project31', 1, false);
          public          taiga    false    380            �           0    0    references_project32    SEQUENCE SET     C   SELECT pg_catalog.setval('public.references_project32', 1, false);
          public          taiga    false    381            �           0    0    references_project4    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project4', 1, false);
          public          taiga    false    353            �           0    0    references_project5    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project5', 1, false);
          public          taiga    false    354            �           0    0    references_project6    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project6', 1, false);
          public          taiga    false    355            �           0    0    references_project7    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project7', 1, false);
          public          taiga    false    356            �           0    0    references_project8    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project8', 1, false);
          public          taiga    false    357            �           0    0    references_project9    SEQUENCE SET     B   SELECT pg_catalog.setval('public.references_project9', 1, false);
          public          taiga    false    358            �           0    0    references_reference_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.references_reference_id_seq', 1, false);
          public          taiga    false    323            �           0    0 #   settings_userprojectsettings_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.settings_userprojectsettings_id_seq', 1, false);
          public          taiga    false    326            �           0    0    tasks_task_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.tasks_task_id_seq', 1, false);
          public          taiga    false    258            �           0    0 "   telemetry_instancetelemetry_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.telemetry_instancetelemetry_id_seq', 1, false);
          public          taiga    false    328            �           0    0    timeline_timeline_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.timeline_timeline_id_seq', 221, true);
          public          taiga    false    264            �           0    0 %   token_denylist_denylistedtoken_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public.token_denylist_denylistedtoken_id_seq', 1, false);
          public          taiga    false    332            �           0    0 &   token_denylist_outstandingtoken_id_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.token_denylist_outstandingtoken_id_seq', 1, false);
          public          taiga    false    330            �           0    0    users_authdata_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.users_authdata_id_seq', 1, false);
          public          taiga    false    260            �           0    0    users_role_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.users_role_id_seq', 67, true);
          public          taiga    false    210            �           0    0    users_user_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.users_user_id_seq', 17, true);
          public          taiga    false    206            �           0    0    users_workspacerole_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.users_workspacerole_id_seq', 39, true);
          public          taiga    false    334            �           0    0    userstorage_storageentry_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.userstorage_storageentry_id_seq', 1, false);
          public          taiga    false    336            �           0    0    userstories_rolepoints_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.userstories_rolepoints_id_seq', 1, false);
          public          taiga    false    244            �           0    0 +   userstories_userstory_assigned_users_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.userstories_userstory_assigned_users_id_seq', 1, false);
          public          taiga    false    338            �           0    0    userstories_userstory_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.userstories_userstory_id_seq', 1, false);
          public          taiga    false    246            �           0    0    votes_vote_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.votes_vote_id_seq', 1, false);
          public          taiga    false    340            �           0    0    votes_votes_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.votes_votes_id_seq', 1, false);
          public          taiga    false    342            �           0    0    webhooks_webhook_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.webhooks_webhook_id_seq', 1, false);
          public          taiga    false    344            �           0    0    webhooks_webhooklog_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.webhooks_webhooklog_id_seq', 1, false);
          public          taiga    false    346            �           0    0    wiki_wikilink_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.wiki_wikilink_id_seq', 1, false);
          public          taiga    false    272            �           0    0    wiki_wikipage_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.wiki_wikipage_id_seq', 1, false);
          public          taiga    false    274            �           0    0    workspaces_workspace_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.workspaces_workspace_id_seq', 25, true);
          public          taiga    false    311            �           0    0 %   workspaces_workspacemembership_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public.workspaces_workspacemembership_id_seq', 96, true);
          public          taiga    false    348            �           2606    317959 2   attachments_attachment attachments_attachment_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.attachments_attachment
    ADD CONSTRAINT attachments_attachment_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.attachments_attachment DROP CONSTRAINT attachments_attachment_pkey;
       public            taiga    false    233            �           2606    318037    auth_group auth_group_name_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);
 H   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_name_key;
       public            taiga    false    237            �           2606    318033 R   auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);
 |   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq;
       public            taiga    false    239    239                       2606    318012 2   auth_group_permissions auth_group_permissions_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_pkey;
       public            taiga    false    239            �           2606    318002    auth_group auth_group_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_pkey;
       public            taiga    false    237            �           2606    318019 F   auth_permission auth_permission_content_type_id_codename_01ab375a_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);
 p   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq;
       public            taiga    false    235    235            �           2606    317994 $   auth_permission auth_permission_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_pkey;
       public            taiga    false    235            {           2606    318888 .   contact_contactentry contact_contactentry_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.contact_contactentry
    ADD CONSTRAINT contact_contactentry_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.contact_contactentry DROP CONSTRAINT contact_contactentry_pkey;
       public            taiga    false    271            �           2606    319240 \   custom_attributes_epiccustomattribute custom_attributes_epiccu_project_id_name_3850c31d_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute
    ADD CONSTRAINT custom_attributes_epiccu_project_id_name_3850c31d_uniq UNIQUE (project_id, name);
 �   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute DROP CONSTRAINT custom_attributes_epiccu_project_id_name_3850c31d_uniq;
       public            taiga    false    294    294            �           2606    319224 P   custom_attributes_epiccustomattribute custom_attributes_epiccustomattribute_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute
    ADD CONSTRAINT custom_attributes_epiccustomattribute_pkey PRIMARY KEY (id);
 z   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute DROP CONSTRAINT custom_attributes_epiccustomattribute_pkey;
       public            taiga    false    294            �           2606    319237 e   custom_attributes_epiccustomattributesvalues custom_attributes_epiccustomattributesvalues_epic_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues
    ADD CONSTRAINT custom_attributes_epiccustomattributesvalues_epic_id_key UNIQUE (epic_id);
 �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues DROP CONSTRAINT custom_attributes_epiccustomattributesvalues_epic_id_key;
       public            taiga    false    296            �           2606    319235 ^   custom_attributes_epiccustomattributesvalues custom_attributes_epiccustomattributesvalues_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues
    ADD CONSTRAINT custom_attributes_epiccustomattributesvalues_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues DROP CONSTRAINT custom_attributes_epiccustomattributesvalues_pkey;
       public            taiga    false    296            �           2606    319127 ]   custom_attributes_issuecustomattribute custom_attributes_issuec_project_id_name_6f71f010_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute
    ADD CONSTRAINT custom_attributes_issuec_project_id_name_6f71f010_uniq UNIQUE (project_id, name);
 �   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute DROP CONSTRAINT custom_attributes_issuec_project_id_name_6f71f010_uniq;
       public            taiga    false    282    282            �           2606    319099 R   custom_attributes_issuecustomattribute custom_attributes_issuecustomattribute_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute
    ADD CONSTRAINT custom_attributes_issuecustomattribute_pkey PRIMARY KEY (id);
 |   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute DROP CONSTRAINT custom_attributes_issuecustomattribute_pkey;
       public            taiga    false    282            �           2606    319158 h   custom_attributes_issuecustomattributesvalues custom_attributes_issuecustomattributesvalues_issue_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues
    ADD CONSTRAINT custom_attributes_issuecustomattributesvalues_issue_id_key UNIQUE (issue_id);
 �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues DROP CONSTRAINT custom_attributes_issuecustomattributesvalues_issue_id_key;
       public            taiga    false    288            �           2606    319156 `   custom_attributes_issuecustomattributesvalues custom_attributes_issuecustomattributesvalues_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues
    ADD CONSTRAINT custom_attributes_issuecustomattributesvalues_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues DROP CONSTRAINT custom_attributes_issuecustomattributesvalues_pkey;
       public            taiga    false    288            �           2606    319125 \   custom_attributes_taskcustomattribute custom_attributes_taskcu_project_id_name_c1c55ac2_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute
    ADD CONSTRAINT custom_attributes_taskcu_project_id_name_c1c55ac2_uniq UNIQUE (project_id, name);
 �   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute DROP CONSTRAINT custom_attributes_taskcu_project_id_name_c1c55ac2_uniq;
       public            taiga    false    284    284            �           2606    319110 P   custom_attributes_taskcustomattribute custom_attributes_taskcustomattribute_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute
    ADD CONSTRAINT custom_attributes_taskcustomattribute_pkey PRIMARY KEY (id);
 z   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute DROP CONSTRAINT custom_attributes_taskcustomattribute_pkey;
       public            taiga    false    284            �           2606    319169 ^   custom_attributes_taskcustomattributesvalues custom_attributes_taskcustomattributesvalues_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues
    ADD CONSTRAINT custom_attributes_taskcustomattributesvalues_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues DROP CONSTRAINT custom_attributes_taskcustomattributesvalues_pkey;
       public            taiga    false    290            �           2606    319171 e   custom_attributes_taskcustomattributesvalues custom_attributes_taskcustomattributesvalues_task_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues
    ADD CONSTRAINT custom_attributes_taskcustomattributesvalues_task_id_key UNIQUE (task_id);
 �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues DROP CONSTRAINT custom_attributes_taskcustomattributesvalues_task_id_key;
       public            taiga    false    290            �           2606    319123 a   custom_attributes_userstorycustomattribute custom_attributes_userst_project_id_name_86c6b502_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute
    ADD CONSTRAINT custom_attributes_userst_project_id_name_86c6b502_uniq UNIQUE (project_id, name);
 �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute DROP CONSTRAINT custom_attributes_userst_project_id_name_86c6b502_uniq;
       public            taiga    false    286    286            �           2606    319121 Z   custom_attributes_userstorycustomattribute custom_attributes_userstorycustomattribute_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute
    ADD CONSTRAINT custom_attributes_userstorycustomattribute_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute DROP CONSTRAINT custom_attributes_userstorycustomattribute_pkey;
       public            taiga    false    286            �           2606    319184 q   custom_attributes_userstorycustomattributesvalues custom_attributes_userstorycustomattributesva_user_story_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues
    ADD CONSTRAINT custom_attributes_userstorycustomattributesva_user_story_id_key UNIQUE (user_story_id);
 �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues DROP CONSTRAINT custom_attributes_userstorycustomattributesva_user_story_id_key;
       public            taiga    false    292            �           2606    319182 h   custom_attributes_userstorycustomattributesvalues custom_attributes_userstorycustomattributesvalues_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues
    ADD CONSTRAINT custom_attributes_userstorycustomattributesvalues_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues DROP CONSTRAINT custom_attributes_userstorycustomattributesvalues_pkey;
       public            taiga    false    292            z           2606    317688 &   django_admin_log django_admin_log_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_pkey;
       public            taiga    false    209            h           2606    317662 E   django_content_type django_content_type_app_label_model_76bd3d3b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);
 o   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq;
       public            taiga    false    205    205            j           2606    317660 ,   django_content_type django_content_type_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_pkey;
       public            taiga    false    205            f           2606    317652 (   django_migrations django_migrations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.django_migrations DROP CONSTRAINT django_migrations_pkey;
       public            taiga    false    203                       2606    319690 "   django_session django_session_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);
 L   ALTER TABLE ONLY public.django_session DROP CONSTRAINT django_session_pkey;
       public            taiga    false    325            �           2606    319333 "   djmail_message djmail_message_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.djmail_message
    ADD CONSTRAINT djmail_message_pkey PRIMARY KEY (uuid);
 L   ALTER TABLE ONLY public.djmail_message DROP CONSTRAINT djmail_message_pkey;
       public            taiga    false    297            �           2606    319342 2   easy_thumbnails_source easy_thumbnails_source_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.easy_thumbnails_source
    ADD CONSTRAINT easy_thumbnails_source_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.easy_thumbnails_source DROP CONSTRAINT easy_thumbnails_source_pkey;
       public            taiga    false    299            �           2606    319354 M   easy_thumbnails_source easy_thumbnails_source_storage_hash_name_481ce32d_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.easy_thumbnails_source
    ADD CONSTRAINT easy_thumbnails_source_storage_hash_name_481ce32d_uniq UNIQUE (storage_hash, name);
 w   ALTER TABLE ONLY public.easy_thumbnails_source DROP CONSTRAINT easy_thumbnails_source_storage_hash_name_481ce32d_uniq;
       public            taiga    false    299    299            �           2606    319352 Y   easy_thumbnails_thumbnail easy_thumbnails_thumbnai_storage_hash_name_source_fb375270_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnail
    ADD CONSTRAINT easy_thumbnails_thumbnai_storage_hash_name_source_fb375270_uniq UNIQUE (storage_hash, name, source_id);
 �   ALTER TABLE ONLY public.easy_thumbnails_thumbnail DROP CONSTRAINT easy_thumbnails_thumbnai_storage_hash_name_source_fb375270_uniq;
       public            taiga    false    301    301    301            �           2606    319350 8   easy_thumbnails_thumbnail easy_thumbnails_thumbnail_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.easy_thumbnails_thumbnail
    ADD CONSTRAINT easy_thumbnails_thumbnail_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.easy_thumbnails_thumbnail DROP CONSTRAINT easy_thumbnails_thumbnail_pkey;
       public            taiga    false    301            �           2606    319378 L   easy_thumbnails_thumbnaildimensions easy_thumbnails_thumbnaildimensions_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions
    ADD CONSTRAINT easy_thumbnails_thumbnaildimensions_pkey PRIMARY KEY (id);
 v   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions DROP CONSTRAINT easy_thumbnails_thumbnaildimensions_pkey;
       public            taiga    false    303            �           2606    319380 X   easy_thumbnails_thumbnaildimensions easy_thumbnails_thumbnaildimensions_thumbnail_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions
    ADD CONSTRAINT easy_thumbnails_thumbnaildimensions_thumbnail_id_key UNIQUE (thumbnail_id);
 �   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions DROP CONSTRAINT easy_thumbnails_thumbnaildimensions_thumbnail_id_key;
       public            taiga    false    303            �           2606    319040    epics_epic epics_epic_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.epics_epic
    ADD CONSTRAINT epics_epic_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.epics_epic DROP CONSTRAINT epics_epic_pkey;
       public            taiga    false    278            �           2606    319048 2   epics_relateduserstory epics_relateduserstory_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.epics_relateduserstory
    ADD CONSTRAINT epics_relateduserstory_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.epics_relateduserstory DROP CONSTRAINT epics_relateduserstory_pkey;
       public            taiga    false    280            �           2606    319387 Q   epics_relateduserstory epics_relateduserstory_user_story_id_epic_id_ad704d40_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.epics_relateduserstory
    ADD CONSTRAINT epics_relateduserstory_user_story_id_epic_id_ad704d40_uniq UNIQUE (user_story_id, epic_id);
 {   ALTER TABLE ONLY public.epics_relateduserstory DROP CONSTRAINT epics_relateduserstory_user_story_id_epic_id_ad704d40_uniq;
       public            taiga    false    280    280            �           2606    319432 \   external_apps_applicationtoken external_apps_applicatio_application_id_user_id_b6a9e9a8_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.external_apps_applicationtoken
    ADD CONSTRAINT external_apps_applicatio_application_id_user_id_b6a9e9a8_uniq UNIQUE (application_id, user_id);
 �   ALTER TABLE ONLY public.external_apps_applicationtoken DROP CONSTRAINT external_apps_applicatio_application_id_user_id_b6a9e9a8_uniq;
       public            taiga    false    306    306            �           2606    319419 8   external_apps_application external_apps_application_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.external_apps_application
    ADD CONSTRAINT external_apps_application_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.external_apps_application DROP CONSTRAINT external_apps_application_pkey;
       public            taiga    false    304            �           2606    319430 B   external_apps_applicationtoken external_apps_applicationtoken_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.external_apps_applicationtoken
    ADD CONSTRAINT external_apps_applicationtoken_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.external_apps_applicationtoken DROP CONSTRAINT external_apps_applicationtoken_pkey;
       public            taiga    false    306            �           2606    319457 2   feedback_feedbackentry feedback_feedbackentry_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.feedback_feedbackentry
    ADD CONSTRAINT feedback_feedbackentry_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.feedback_feedbackentry DROP CONSTRAINT feedback_feedbackentry_pkey;
       public            taiga    false    308            �           2606    319001 .   history_historyentry history_historyentry_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.history_historyentry
    ADD CONSTRAINT history_historyentry_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.history_historyentry DROP CONSTRAINT history_historyentry_pkey;
       public            taiga    false    276                       2606    318116    issues_issue issues_issue_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_pkey;
       public            taiga    false    243            m           2606    318714 E   likes_like likes_like_content_type_id_object_id_user_id_e20903f0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.likes_like
    ADD CONSTRAINT likes_like_content_type_id_object_id_user_id_e20903f0_uniq UNIQUE (content_type_id, object_id, user_id);
 o   ALTER TABLE ONLY public.likes_like DROP CONSTRAINT likes_like_content_type_id_object_id_user_id_e20903f0_uniq;
       public            taiga    false    267    267    267            o           2606    318700    likes_like likes_like_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.likes_like
    ADD CONSTRAINT likes_like_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.likes_like DROP CONSTRAINT likes_like_pkey;
       public            taiga    false    267                       2606    318075 G   milestones_milestone milestones_milestone_name_project_id_fe19fd36_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.milestones_milestone
    ADD CONSTRAINT milestones_milestone_name_project_id_fe19fd36_uniq UNIQUE (name, project_id);
 q   ALTER TABLE ONLY public.milestones_milestone DROP CONSTRAINT milestones_milestone_name_project_id_fe19fd36_uniq;
       public            taiga    false    241    241                       2606    318063 .   milestones_milestone milestones_milestone_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.milestones_milestone
    ADD CONSTRAINT milestones_milestone_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.milestones_milestone DROP CONSTRAINT milestones_milestone_pkey;
       public            taiga    false    241                       2606    318073 G   milestones_milestone milestones_milestone_slug_project_id_e59bac6a_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.milestones_milestone
    ADD CONSTRAINT milestones_milestone_slug_project_id_e59bac6a_uniq UNIQUE (slug, project_id);
 q   ALTER TABLE ONLY public.milestones_milestone DROP CONSTRAINT milestones_milestone_slug_project_id_e59bac6a_uniq;
       public            taiga    false    241    241            ?           2606    318428 t   notifications_historychangenotification_notify_users notifications_historycha_historychangenotificatio_3b0f323b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users
    ADD CONSTRAINT notifications_historycha_historychangenotificatio_3b0f323b_uniq UNIQUE (historychangenotification_id, user_id);
 �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users DROP CONSTRAINT notifications_historycha_historychangenotificatio_3b0f323b_uniq;
       public            taiga    false    255    255            8           2606    319012 w   notifications_historychangenotification_history_entries notifications_historycha_historychangenotificatio_8fb55cdd_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries
    ADD CONSTRAINT notifications_historycha_historychangenotificatio_8fb55cdd_uniq UNIQUE (historychangenotification_id, historyentry_id);
 �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries DROP CONSTRAINT notifications_historycha_historychangenotificatio_8fb55cdd_uniq;
       public            taiga    false    253    253            2           2606    318432 g   notifications_historychangenotification notifications_historycha_key_owner_id_project_id__869f948f_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification
    ADD CONSTRAINT notifications_historycha_key_owner_id_project_id__869f948f_uniq UNIQUE (key, owner_id, project_id, history_type);
 �   ALTER TABLE ONLY public.notifications_historychangenotification DROP CONSTRAINT notifications_historycha_key_owner_id_project_id__869f948f_uniq;
       public            taiga    false    251    251    251    251            =           2606    319014 t   notifications_historychangenotification_history_entries notifications_historychangenotification_history_entries_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries
    ADD CONSTRAINT notifications_historychangenotification_history_entries_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries DROP CONSTRAINT notifications_historychangenotification_history_entries_pkey;
       public            taiga    false    253            C           2606    318389 n   notifications_historychangenotification_notify_users notifications_historychangenotification_notify_users_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users
    ADD CONSTRAINT notifications_historychangenotification_notify_users_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users DROP CONSTRAINT notifications_historychangenotification_notify_users_pkey;
       public            taiga    false    255            5           2606    318373 T   notifications_historychangenotification notifications_historychangenotification_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification
    ADD CONSTRAINT notifications_historychangenotification_pkey PRIMARY KEY (id);
 ~   ALTER TABLE ONLY public.notifications_historychangenotification DROP CONSTRAINT notifications_historychangenotification_pkey;
       public            taiga    false    251            ,           2606    318330 :   notifications_notifypolicy notifications_notifypolicy_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.notifications_notifypolicy
    ADD CONSTRAINT notifications_notifypolicy_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.notifications_notifypolicy DROP CONSTRAINT notifications_notifypolicy_pkey;
       public            taiga    false    249            /           2606    318332 V   notifications_notifypolicy notifications_notifypolicy_project_id_user_id_e7aa5cf2_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_notifypolicy
    ADD CONSTRAINT notifications_notifypolicy_project_id_user_id_e7aa5cf2_uniq UNIQUE (project_id, user_id);
 �   ALTER TABLE ONLY public.notifications_notifypolicy DROP CONSTRAINT notifications_notifypolicy_project_id_user_id_e7aa5cf2_uniq;
       public            taiga    false    249    249            F           2606    318443 R   notifications_watched notifications_watched_content_type_id_object_i_e7c27769_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.notifications_watched
    ADD CONSTRAINT notifications_watched_content_type_id_object_i_e7c27769_uniq UNIQUE (content_type_id, object_id, user_id, project_id);
 |   ALTER TABLE ONLY public.notifications_watched DROP CONSTRAINT notifications_watched_content_type_id_object_i_e7c27769_uniq;
       public            taiga    false    257    257    257    257            H           2606    318441 0   notifications_watched notifications_watched_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.notifications_watched
    ADD CONSTRAINT notifications_watched_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.notifications_watched DROP CONSTRAINT notifications_watched_pkey;
       public            taiga    false    257            �           2606    319517 @   notifications_webnotification notifications_webnotification_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public.notifications_webnotification
    ADD CONSTRAINT notifications_webnotification_pkey PRIMARY KEY (id);
 j   ALTER TABLE ONLY public.notifications_webnotification DROP CONSTRAINT notifications_webnotification_pkey;
       public            taiga    false    310            r           2606    318809 ,   projects_epicstatus projects_epicstatus_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.projects_epicstatus
    ADD CONSTRAINT projects_epicstatus_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.projects_epicstatus DROP CONSTRAINT projects_epicstatus_pkey;
       public            taiga    false    269            u           2606    318815 E   projects_epicstatus projects_epicstatus_project_id_name_b71c417e_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_epicstatus
    ADD CONSTRAINT projects_epicstatus_project_id_name_b71c417e_uniq UNIQUE (project_id, name);
 o   ALTER TABLE ONLY public.projects_epicstatus DROP CONSTRAINT projects_epicstatus_project_id_name_b71c417e_uniq;
       public            taiga    false    269    269            w           2606    318817 E   projects_epicstatus projects_epicstatus_project_id_slug_f67857e5_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_epicstatus
    ADD CONSTRAINT projects_epicstatus_project_id_slug_f67857e5_uniq UNIQUE (project_id, slug);
 o   ALTER TABLE ONLY public.projects_epicstatus DROP CONSTRAINT projects_epicstatus_project_id_slug_f67857e5_uniq;
       public            taiga    false    269    269            �           2606    319556 0   projects_issueduedate projects_issueduedate_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.projects_issueduedate
    ADD CONSTRAINT projects_issueduedate_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.projects_issueduedate DROP CONSTRAINT projects_issueduedate_pkey;
       public            taiga    false    314            �           2606    319578 I   projects_issueduedate projects_issueduedate_project_id_name_cba303bc_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_issueduedate
    ADD CONSTRAINT projects_issueduedate_project_id_name_cba303bc_uniq UNIQUE (project_id, name);
 s   ALTER TABLE ONLY public.projects_issueduedate DROP CONSTRAINT projects_issueduedate_project_id_name_cba303bc_uniq;
       public            taiga    false    314    314            �           2606    317774 .   projects_issuestatus projects_issuestatus_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.projects_issuestatus
    ADD CONSTRAINT projects_issuestatus_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.projects_issuestatus DROP CONSTRAINT projects_issuestatus_pkey;
       public            taiga    false    217            �           2606    317849 G   projects_issuestatus projects_issuestatus_project_id_name_a88dd6c0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_issuestatus
    ADD CONSTRAINT projects_issuestatus_project_id_name_a88dd6c0_uniq UNIQUE (project_id, name);
 q   ALTER TABLE ONLY public.projects_issuestatus DROP CONSTRAINT projects_issuestatus_project_id_name_a88dd6c0_uniq;
       public            taiga    false    217    217            �           2606    319598 G   projects_issuestatus projects_issuestatus_project_id_slug_ca3e758d_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_issuestatus
    ADD CONSTRAINT projects_issuestatus_project_id_slug_ca3e758d_uniq UNIQUE (project_id, slug);
 q   ALTER TABLE ONLY public.projects_issuestatus DROP CONSTRAINT projects_issuestatus_project_id_slug_ca3e758d_uniq;
       public            taiga    false    217    217            �           2606    317782 *   projects_issuetype projects_issuetype_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.projects_issuetype
    ADD CONSTRAINT projects_issuetype_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.projects_issuetype DROP CONSTRAINT projects_issuetype_pkey;
       public            taiga    false    219            �           2606    317847 C   projects_issuetype projects_issuetype_project_id_name_41b47d87_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_issuetype
    ADD CONSTRAINT projects_issuetype_project_id_name_41b47d87_uniq UNIQUE (project_id, name);
 m   ALTER TABLE ONLY public.projects_issuetype DROP CONSTRAINT projects_issuetype_project_id_name_41b47d87_uniq;
       public            taiga    false    219    219            �           2606    317721 ,   projects_membership projects_membership_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.projects_membership
    ADD CONSTRAINT projects_membership_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.projects_membership DROP CONSTRAINT projects_membership_pkey;
       public            taiga    false    213            �           2606    317739 H   projects_membership projects_membership_user_id_project_id_a2829f61_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_membership
    ADD CONSTRAINT projects_membership_user_id_project_id_a2829f61_uniq UNIQUE (user_id, project_id);
 r   ALTER TABLE ONLY public.projects_membership DROP CONSTRAINT projects_membership_user_id_project_id_a2829f61_uniq;
       public            taiga    false    213    213            �           2606    317790 $   projects_points projects_points_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.projects_points
    ADD CONSTRAINT projects_points_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.projects_points DROP CONSTRAINT projects_points_pkey;
       public            taiga    false    221            �           2606    317845 =   projects_points projects_points_project_id_name_900c69f4_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_points
    ADD CONSTRAINT projects_points_project_id_name_900c69f4_uniq UNIQUE (project_id, name);
 g   ALTER TABLE ONLY public.projects_points DROP CONSTRAINT projects_points_project_id_name_900c69f4_uniq;
       public            taiga    false    221    221            �           2606    317798 (   projects_priority projects_priority_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.projects_priority
    ADD CONSTRAINT projects_priority_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.projects_priority DROP CONSTRAINT projects_priority_pkey;
       public            taiga    false    223            �           2606    317843 A   projects_priority projects_priority_project_id_name_ca316bb1_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_priority
    ADD CONSTRAINT projects_priority_project_id_name_ca316bb1_uniq UNIQUE (project_id, name);
 k   ALTER TABLE ONLY public.projects_priority DROP CONSTRAINT projects_priority_project_id_name_ca316bb1_uniq;
       public            taiga    false    223    223            �           2606    318813 <   projects_project projects_project_default_epic_status_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_epic_status_id_key UNIQUE (default_epic_status_id);
 f   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_epic_status_id_key;
       public            taiga    false    215            �           2606    317851 =   projects_project projects_project_default_issue_status_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_issue_status_id_key UNIQUE (default_issue_status_id);
 g   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_issue_status_id_key;
       public            taiga    false    215            �           2606    317853 ;   projects_project projects_project_default_issue_type_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_issue_type_id_key UNIQUE (default_issue_type_id);
 e   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_issue_type_id_key;
       public            taiga    false    215            �           2606    317855 7   projects_project projects_project_default_points_id_key 
   CONSTRAINT        ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_points_id_key UNIQUE (default_points_id);
 a   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_points_id_key;
       public            taiga    false    215            �           2606    317857 9   projects_project projects_project_default_priority_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_priority_id_key UNIQUE (default_priority_id);
 c   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_priority_id_key;
       public            taiga    false    215            �           2606    317859 9   projects_project projects_project_default_severity_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_severity_id_key UNIQUE (default_severity_id);
 c   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_severity_id_key;
       public            taiga    false    215            �           2606    319644 9   projects_project projects_project_default_swimlane_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_swimlane_id_key UNIQUE (default_swimlane_id);
 c   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_swimlane_id_key;
       public            taiga    false    215            �           2606    317861 <   projects_project projects_project_default_task_status_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_task_status_id_key UNIQUE (default_task_status_id);
 f   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_task_status_id_key;
       public            taiga    false    215            �           2606    317863 :   projects_project projects_project_default_us_status_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_us_status_id_key UNIQUE (default_us_status_id);
 d   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_us_status_id_key;
       public            taiga    false    215            �           2606    317732 &   projects_project projects_project_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_pkey;
       public            taiga    false    215            �           2606    317736 *   projects_project projects_project_slug_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_slug_key UNIQUE (slug);
 T   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_slug_key;
       public            taiga    false    215            \           2606    318627 @   projects_projectmodulesconfig projects_projectmodulesconfig_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public.projects_projectmodulesconfig
    ADD CONSTRAINT projects_projectmodulesconfig_pkey PRIMARY KEY (id);
 j   ALTER TABLE ONLY public.projects_projectmodulesconfig DROP CONSTRAINT projects_projectmodulesconfig_pkey;
       public            taiga    false    263            ^           2606    318629 J   projects_projectmodulesconfig projects_projectmodulesconfig_project_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_projectmodulesconfig
    ADD CONSTRAINT projects_projectmodulesconfig_project_id_key UNIQUE (project_id);
 t   ALTER TABLE ONLY public.projects_projectmodulesconfig DROP CONSTRAINT projects_projectmodulesconfig_project_id_key;
       public            taiga    false    263            �           2606    317809 6   projects_projecttemplate projects_projecttemplate_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.projects_projecttemplate
    ADD CONSTRAINT projects_projecttemplate_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.projects_projecttemplate DROP CONSTRAINT projects_projecttemplate_pkey;
       public            taiga    false    225            �           2606    317811 :   projects_projecttemplate projects_projecttemplate_slug_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.projects_projecttemplate
    ADD CONSTRAINT projects_projecttemplate_slug_key UNIQUE (slug);
 d   ALTER TABLE ONLY public.projects_projecttemplate DROP CONSTRAINT projects_projecttemplate_slug_key;
       public            taiga    false    225            �           2606    317819 (   projects_severity projects_severity_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.projects_severity
    ADD CONSTRAINT projects_severity_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.projects_severity DROP CONSTRAINT projects_severity_pkey;
       public            taiga    false    227            �           2606    317841 A   projects_severity projects_severity_project_id_name_6187c456_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_severity
    ADD CONSTRAINT projects_severity_project_id_name_6187c456_uniq UNIQUE (project_id, name);
 k   ALTER TABLE ONLY public.projects_severity DROP CONSTRAINT projects_severity_project_id_name_6187c456_uniq;
       public            taiga    false    227    227                       2606    319614 (   projects_swimlane projects_swimlane_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.projects_swimlane
    ADD CONSTRAINT projects_swimlane_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.projects_swimlane DROP CONSTRAINT projects_swimlane_pkey;
       public            taiga    false    320                       2606    319651 A   projects_swimlane projects_swimlane_project_id_name_a949892d_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_swimlane
    ADD CONSTRAINT projects_swimlane_project_id_name_a949892d_uniq UNIQUE (project_id, name);
 k   ALTER TABLE ONLY public.projects_swimlane DROP CONSTRAINT projects_swimlane_project_id_name_a949892d_uniq;
       public            taiga    false    320    320                       2606    319640 ]   projects_swimlaneuserstorystatus projects_swimlaneusersto_swimlane_id_status_id_d6ff394d_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus
    ADD CONSTRAINT projects_swimlaneusersto_swimlane_id_status_id_d6ff394d_uniq UNIQUE (swimlane_id, status_id);
 �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus DROP CONSTRAINT projects_swimlaneusersto_swimlane_id_status_id_d6ff394d_uniq;
       public            taiga    false    322    322                       2606    319628 F   projects_swimlaneuserstorystatus projects_swimlaneuserstorystatus_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus
    ADD CONSTRAINT projects_swimlaneuserstorystatus_pkey PRIMARY KEY (id);
 p   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus DROP CONSTRAINT projects_swimlaneuserstorystatus_pkey;
       public            taiga    false    322            �           2606    319564 .   projects_taskduedate projects_taskduedate_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.projects_taskduedate
    ADD CONSTRAINT projects_taskduedate_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.projects_taskduedate DROP CONSTRAINT projects_taskduedate_pkey;
       public            taiga    false    316                       2606    319576 G   projects_taskduedate projects_taskduedate_project_id_name_6270950e_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_taskduedate
    ADD CONSTRAINT projects_taskduedate_project_id_name_6270950e_uniq UNIQUE (project_id, name);
 q   ALTER TABLE ONLY public.projects_taskduedate DROP CONSTRAINT projects_taskduedate_project_id_name_6270950e_uniq;
       public            taiga    false    316    316            �           2606    317827 ,   projects_taskstatus projects_taskstatus_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.projects_taskstatus
    ADD CONSTRAINT projects_taskstatus_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.projects_taskstatus DROP CONSTRAINT projects_taskstatus_pkey;
       public            taiga    false    229            �           2606    317839 E   projects_taskstatus projects_taskstatus_project_id_name_4b65b78f_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_taskstatus
    ADD CONSTRAINT projects_taskstatus_project_id_name_4b65b78f_uniq UNIQUE (project_id, name);
 o   ALTER TABLE ONLY public.projects_taskstatus DROP CONSTRAINT projects_taskstatus_project_id_name_4b65b78f_uniq;
       public            taiga    false    229    229            �           2606    318614 E   projects_taskstatus projects_taskstatus_project_id_slug_30401ba3_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_taskstatus
    ADD CONSTRAINT projects_taskstatus_project_id_slug_30401ba3_uniq UNIQUE (project_id, slug);
 o   ALTER TABLE ONLY public.projects_taskstatus DROP CONSTRAINT projects_taskstatus_project_id_slug_30401ba3_uniq;
       public            taiga    false    229    229                       2606    319572 8   projects_userstoryduedate projects_userstoryduedate_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.projects_userstoryduedate
    ADD CONSTRAINT projects_userstoryduedate_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.projects_userstoryduedate DROP CONSTRAINT projects_userstoryduedate_pkey;
       public            taiga    false    318                       2606    319574 Q   projects_userstoryduedate projects_userstoryduedate_project_id_name_177c510a_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_userstoryduedate
    ADD CONSTRAINT projects_userstoryduedate_project_id_name_177c510a_uniq UNIQUE (project_id, name);
 {   ALTER TABLE ONLY public.projects_userstoryduedate DROP CONSTRAINT projects_userstoryduedate_project_id_name_177c510a_uniq;
       public            taiga    false    318    318            �           2606    317835 6   projects_userstorystatus projects_userstorystatus_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.projects_userstorystatus
    ADD CONSTRAINT projects_userstorystatus_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.projects_userstorystatus DROP CONSTRAINT projects_userstorystatus_pkey;
       public            taiga    false    231            �           2606    317837 O   projects_userstorystatus projects_userstorystatus_project_id_name_7c0a1351_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_userstorystatus
    ADD CONSTRAINT projects_userstorystatus_project_id_name_7c0a1351_uniq UNIQUE (project_id, name);
 y   ALTER TABLE ONLY public.projects_userstorystatus DROP CONSTRAINT projects_userstorystatus_project_id_name_7c0a1351_uniq;
       public            taiga    false    231    231            �           2606    318616 O   projects_userstorystatus projects_userstorystatus_project_id_slug_97a888b5_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.projects_userstorystatus
    ADD CONSTRAINT projects_userstorystatus_project_id_slug_97a888b5_uniq UNIQUE (project_id, slug);
 y   ALTER TABLE ONLY public.projects_userstorystatus DROP CONSTRAINT projects_userstorystatus_project_id_slug_97a888b5_uniq;
       public            taiga    false    231    231                       2606    319668 .   references_reference references_reference_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.references_reference
    ADD CONSTRAINT references_reference_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.references_reference DROP CONSTRAINT references_reference_pkey;
       public            taiga    false    324                       2606    319670 F   references_reference references_reference_project_id_ref_82d64d63_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.references_reference
    ADD CONSTRAINT references_reference_project_id_ref_82d64d63_uniq UNIQUE (project_id, ref);
 p   ALTER TABLE ONLY public.references_reference DROP CONSTRAINT references_reference_project_id_ref_82d64d63_uniq;
       public            taiga    false    324    324                       2606    319700 >   settings_userprojectsettings settings_userprojectsettings_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.settings_userprojectsettings
    ADD CONSTRAINT settings_userprojectsettings_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.settings_userprojectsettings DROP CONSTRAINT settings_userprojectsettings_pkey;
       public            taiga    false    327                        2606    319702 Z   settings_userprojectsettings settings_userprojectsettings_project_id_user_id_330ddee9_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.settings_userprojectsettings
    ADD CONSTRAINT settings_userprojectsettings_project_id_user_id_330ddee9_uniq UNIQUE (project_id, user_id);
 �   ALTER TABLE ONLY public.settings_userprojectsettings DROP CONSTRAINT settings_userprojectsettings_project_id_user_id_330ddee9_uniq;
       public            taiga    false    327    327            O           2606    318472    tasks_task tasks_task_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_pkey;
       public            taiga    false    259            #           2606    319756 <   telemetry_instancetelemetry telemetry_instancetelemetry_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.telemetry_instancetelemetry
    ADD CONSTRAINT telemetry_instancetelemetry_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.telemetry_instancetelemetry DROP CONSTRAINT telemetry_instancetelemetry_pkey;
       public            taiga    false    329            i           2606    318653 (   timeline_timeline timeline_timeline_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.timeline_timeline
    ADD CONSTRAINT timeline_timeline_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.timeline_timeline DROP CONSTRAINT timeline_timeline_pkey;
       public            taiga    false    265            +           2606    319797 B   token_denylist_denylistedtoken token_denylist_denylistedtoken_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.token_denylist_denylistedtoken
    ADD CONSTRAINT token_denylist_denylistedtoken_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.token_denylist_denylistedtoken DROP CONSTRAINT token_denylist_denylistedtoken_pkey;
       public            taiga    false    333            -           2606    319799 J   token_denylist_denylistedtoken token_denylist_denylistedtoken_token_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.token_denylist_denylistedtoken
    ADD CONSTRAINT token_denylist_denylistedtoken_token_id_key UNIQUE (token_id);
 t   ALTER TABLE ONLY public.token_denylist_denylistedtoken DROP CONSTRAINT token_denylist_denylistedtoken_token_id_key;
       public            taiga    false    333            &           2606    319789 G   token_denylist_outstandingtoken token_denylist_outstandingtoken_jti_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.token_denylist_outstandingtoken
    ADD CONSTRAINT token_denylist_outstandingtoken_jti_key UNIQUE (jti);
 q   ALTER TABLE ONLY public.token_denylist_outstandingtoken DROP CONSTRAINT token_denylist_outstandingtoken_jti_key;
       public            taiga    false    331            (           2606    319787 D   token_denylist_outstandingtoken token_denylist_outstandingtoken_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.token_denylist_outstandingtoken
    ADD CONSTRAINT token_denylist_outstandingtoken_pkey PRIMARY KEY (id);
 n   ALTER TABLE ONLY public.token_denylist_outstandingtoken DROP CONSTRAINT token_denylist_outstandingtoken_pkey;
       public            taiga    false    331            W           2606    318556 5   users_authdata users_authdata_key_value_7ee3acc9_uniq 
   CONSTRAINT     v   ALTER TABLE ONLY public.users_authdata
    ADD CONSTRAINT users_authdata_key_value_7ee3acc9_uniq UNIQUE (key, value);
 _   ALTER TABLE ONLY public.users_authdata DROP CONSTRAINT users_authdata_key_value_7ee3acc9_uniq;
       public            taiga    false    261    261            Y           2606    318554 "   users_authdata users_authdata_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.users_authdata
    ADD CONSTRAINT users_authdata_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.users_authdata DROP CONSTRAINT users_authdata_pkey;
       public            taiga    false    261            }           2606    317711    users_role users_role_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.users_role
    ADD CONSTRAINT users_role_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.users_role DROP CONSTRAINT users_role_pkey;
       public            taiga    false    211            �           2606    318040 3   users_role users_role_slug_project_id_db8c270c_uniq 
   CONSTRAINT     z   ALTER TABLE ONLY public.users_role
    ADD CONSTRAINT users_role_slug_project_id_db8c270c_uniq UNIQUE (slug, project_id);
 ]   ALTER TABLE ONLY public.users_role DROP CONSTRAINT users_role_slug_project_id_db8c270c_uniq;
       public            taiga    false    211    211            m           2606    318048 )   users_user users_user_email_243f6e77_uniq 
   CONSTRAINT     e   ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_email_243f6e77_uniq UNIQUE (email);
 S   ALTER TABLE ONLY public.users_user DROP CONSTRAINT users_user_email_243f6e77_uniq;
       public            taiga    false    207            o           2606    317673    users_user users_user_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.users_user DROP CONSTRAINT users_user_pkey;
       public            taiga    false    207            t           2606    318051 "   users_user users_user_username_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_username_key UNIQUE (username);
 L   ALTER TABLE ONLY public.users_user DROP CONSTRAINT users_user_username_key;
       public            taiga    false    207            w           2606    319827 (   users_user users_user_uuid_6fe513d7_uniq 
   CONSTRAINT     c   ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_uuid_6fe513d7_uniq UNIQUE (uuid);
 R   ALTER TABLE ONLY public.users_user DROP CONSTRAINT users_user_uuid_6fe513d7_uniq;
       public            taiga    false    207            /           2606    319844 ,   users_workspacerole users_workspacerole_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.users_workspacerole
    ADD CONSTRAINT users_workspacerole_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.users_workspacerole DROP CONSTRAINT users_workspacerole_pkey;
       public            taiga    false    335            3           2606    319851 G   users_workspacerole users_workspacerole_slug_workspace_id_1c9aef12_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.users_workspacerole
    ADD CONSTRAINT users_workspacerole_slug_workspace_id_1c9aef12_uniq UNIQUE (slug, workspace_id);
 q   ALTER TABLE ONLY public.users_workspacerole DROP CONSTRAINT users_workspacerole_slug_workspace_id_1c9aef12_uniq;
       public            taiga    false    335    335            7           2606    319867 L   userstorage_storageentry userstorage_storageentry_owner_id_key_746399cb_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.userstorage_storageentry
    ADD CONSTRAINT userstorage_storageentry_owner_id_key_746399cb_uniq UNIQUE (owner_id, key);
 v   ALTER TABLE ONLY public.userstorage_storageentry DROP CONSTRAINT userstorage_storageentry_owner_id_key_746399cb_uniq;
       public            taiga    false    337    337            9           2606    319865 6   userstorage_storageentry userstorage_storageentry_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.userstorage_storageentry
    ADD CONSTRAINT userstorage_storageentry_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.userstorage_storageentry DROP CONSTRAINT userstorage_storageentry_pkey;
       public            taiga    false    337                       2606    318195 2   userstories_rolepoints userstories_rolepoints_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.userstories_rolepoints
    ADD CONSTRAINT userstories_rolepoints_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.userstories_rolepoints DROP CONSTRAINT userstories_rolepoints_pkey;
       public            taiga    false    245                       2606    318217 Q   userstories_rolepoints userstories_rolepoints_user_story_id_role_id_dc0ba15e_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.userstories_rolepoints
    ADD CONSTRAINT userstories_rolepoints_user_story_id_role_id_dc0ba15e_uniq UNIQUE (user_story_id, role_id);
 {   ALTER TABLE ONLY public.userstories_rolepoints DROP CONSTRAINT userstories_rolepoints_user_story_id_role_id_dc0ba15e_uniq;
       public            taiga    false    245    245            ;           2606    319945 `   userstories_userstory_assigned_users userstories_userstory_as_userstory_id_user_id_beae1231_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory_assigned_users
    ADD CONSTRAINT userstories_userstory_as_userstory_id_user_id_beae1231_uniq UNIQUE (userstory_id, user_id);
 �   ALTER TABLE ONLY public.userstories_userstory_assigned_users DROP CONSTRAINT userstories_userstory_as_userstory_id_user_id_beae1231_uniq;
       public            taiga    false    339    339            =           2606    319933 N   userstories_userstory_assigned_users userstories_userstory_assigned_users_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory_assigned_users
    ADD CONSTRAINT userstories_userstory_assigned_users_pkey PRIMARY KEY (id);
 x   ALTER TABLE ONLY public.userstories_userstory_assigned_users DROP CONSTRAINT userstories_userstory_assigned_users_pkey;
       public            taiga    false    339            &           2606    318207 0   userstories_userstory userstories_userstory_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstory_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstory_pkey;
       public            taiga    false    247            B           2606    319987 E   votes_vote votes_vote_content_type_id_object_id_user_id_97d16fa0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.votes_vote
    ADD CONSTRAINT votes_vote_content_type_id_object_id_user_id_97d16fa0_uniq UNIQUE (content_type_id, object_id, user_id);
 o   ALTER TABLE ONLY public.votes_vote DROP CONSTRAINT votes_vote_content_type_id_object_id_user_id_97d16fa0_uniq;
       public            taiga    false    341    341    341            D           2606    319973    votes_vote votes_vote_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.votes_vote
    ADD CONSTRAINT votes_vote_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.votes_vote DROP CONSTRAINT votes_vote_pkey;
       public            taiga    false    341            H           2606    319985 ?   votes_votes votes_votes_content_type_id_object_id_5abfc91b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.votes_votes
    ADD CONSTRAINT votes_votes_content_type_id_object_id_5abfc91b_uniq UNIQUE (content_type_id, object_id);
 i   ALTER TABLE ONLY public.votes_votes DROP CONSTRAINT votes_votes_content_type_id_object_id_5abfc91b_uniq;
       public            taiga    false    343    343            J           2606    319983    votes_votes votes_votes_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.votes_votes
    ADD CONSTRAINT votes_votes_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.votes_votes DROP CONSTRAINT votes_votes_pkey;
       public            taiga    false    343            L           2606    320022 &   webhooks_webhook webhooks_webhook_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.webhooks_webhook
    ADD CONSTRAINT webhooks_webhook_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.webhooks_webhook DROP CONSTRAINT webhooks_webhook_pkey;
       public            taiga    false    345            O           2606    320033 ,   webhooks_webhooklog webhooks_webhooklog_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.webhooks_webhooklog
    ADD CONSTRAINT webhooks_webhooklog_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.webhooks_webhooklog DROP CONSTRAINT webhooks_webhooklog_pkey;
       public            taiga    false    347            �           2606    318912     wiki_wikilink wiki_wikilink_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.wiki_wikilink
    ADD CONSTRAINT wiki_wikilink_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.wiki_wikilink DROP CONSTRAINT wiki_wikilink_pkey;
       public            taiga    false    273            �           2606    318935 9   wiki_wikilink wiki_wikilink_project_id_href_a39ae7e7_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.wiki_wikilink
    ADD CONSTRAINT wiki_wikilink_project_id_href_a39ae7e7_uniq UNIQUE (project_id, href);
 c   ALTER TABLE ONLY public.wiki_wikilink DROP CONSTRAINT wiki_wikilink_project_id_href_a39ae7e7_uniq;
       public            taiga    false    273    273            �           2606    318923     wiki_wikipage wiki_wikipage_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.wiki_wikipage
    ADD CONSTRAINT wiki_wikipage_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.wiki_wikipage DROP CONSTRAINT wiki_wikipage_pkey;
       public            taiga    false    275            �           2606    318933 9   wiki_wikipage wiki_wikipage_project_id_slug_cb5b63e2_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.wiki_wikipage
    ADD CONSTRAINT wiki_wikipage_project_id_slug_cb5b63e2_uniq UNIQUE (project_id, slug);
 c   ALTER TABLE ONLY public.wiki_wikipage DROP CONSTRAINT wiki_wikipage_project_id_slug_cb5b63e2_uniq;
       public            taiga    false    275    275            �           2606    319533 .   workspaces_workspace workspaces_workspace_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.workspaces_workspace
    ADD CONSTRAINT workspaces_workspace_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.workspaces_workspace DROP CONSTRAINT workspaces_workspace_pkey;
       public            taiga    false    312            �           2606    319535 2   workspaces_workspace workspaces_workspace_slug_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.workspaces_workspace
    ADD CONSTRAINT workspaces_workspace_slug_key UNIQUE (slug);
 \   ALTER TABLE ONLY public.workspaces_workspace DROP CONSTRAINT workspaces_workspace_slug_key;
       public            taiga    false    312            R           2606    320094 Z   workspaces_workspacemembership workspaces_workspacememb_user_id_workspace_id_92c1b27f_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.workspaces_workspacemembership
    ADD CONSTRAINT workspaces_workspacememb_user_id_workspace_id_92c1b27f_uniq UNIQUE (user_id, workspace_id);
 �   ALTER TABLE ONLY public.workspaces_workspacemembership DROP CONSTRAINT workspaces_workspacememb_user_id_workspace_id_92c1b27f_uniq;
       public            taiga    false    349    349            T           2606    320077 B   workspaces_workspacemembership workspaces_workspacemembership_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.workspaces_workspacemembership
    ADD CONSTRAINT workspaces_workspacemembership_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.workspaces_workspacemembership DROP CONSTRAINT workspaces_workspacemembership_pkey;
       public            taiga    false    349            �           1259    317975 /   attachments_attachment_content_type_id_35dd9d5d    INDEX     }   CREATE INDEX attachments_attachment_content_type_id_35dd9d5d ON public.attachments_attachment USING btree (content_type_id);
 C   DROP INDEX public.attachments_attachment_content_type_id_35dd9d5d;
       public            taiga    false    233            �           1259    317985 =   attachments_attachment_content_type_id_object_id_3f2e447c_idx    INDEX     �   CREATE INDEX attachments_attachment_content_type_id_object_id_3f2e447c_idx ON public.attachments_attachment USING btree (content_type_id, object_id);
 Q   DROP INDEX public.attachments_attachment_content_type_id_object_id_3f2e447c_idx;
       public            taiga    false    233    233            �           1259    317976 (   attachments_attachment_owner_id_720defb8    INDEX     o   CREATE INDEX attachments_attachment_owner_id_720defb8 ON public.attachments_attachment USING btree (owner_id);
 <   DROP INDEX public.attachments_attachment_owner_id_720defb8;
       public            taiga    false    233            �           1259    317977 *   attachments_attachment_project_id_50714f52    INDEX     s   CREATE INDEX attachments_attachment_project_id_50714f52 ON public.attachments_attachment USING btree (project_id);
 >   DROP INDEX public.attachments_attachment_project_id_50714f52;
       public            taiga    false    233            �           1259    318038    auth_group_name_a6ea08ec_like    INDEX     h   CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);
 1   DROP INDEX public.auth_group_name_a6ea08ec_like;
       public            taiga    false    237            �           1259    318034 (   auth_group_permissions_group_id_b120cbf9    INDEX     o   CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);
 <   DROP INDEX public.auth_group_permissions_group_id_b120cbf9;
       public            taiga    false    239            �           1259    318035 -   auth_group_permissions_permission_id_84c5c92e    INDEX     y   CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);
 A   DROP INDEX public.auth_group_permissions_permission_id_84c5c92e;
       public            taiga    false    239            �           1259    318020 (   auth_permission_content_type_id_2f476e4b    INDEX     o   CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);
 <   DROP INDEX public.auth_permission_content_type_id_2f476e4b;
       public            taiga    false    235            |           1259    318899 (   contact_contactentry_project_id_27bfec4e    INDEX     o   CREATE INDEX contact_contactentry_project_id_27bfec4e ON public.contact_contactentry USING btree (project_id);
 <   DROP INDEX public.contact_contactentry_project_id_27bfec4e;
       public            taiga    false    271            }           1259    318900 %   contact_contactentry_user_id_f1f19c5f    INDEX     i   CREATE INDEX contact_contactentry_user_id_f1f19c5f ON public.contact_contactentry USING btree (user_id);
 9   DROP INDEX public.contact_contactentry_user_id_f1f19c5f;
       public            taiga    false    271            �           1259    319238 -   custom_attributes_epiccu_epic_id_d413e57a_idx    INDEX     �   CREATE INDEX custom_attributes_epiccu_epic_id_d413e57a_idx ON public.custom_attributes_epiccustomattributesvalues USING btree (epic_id);
 A   DROP INDEX public.custom_attributes_epiccu_epic_id_d413e57a_idx;
       public            taiga    false    296            �           1259    319247 9   custom_attributes_epiccustomattribute_project_id_ad2cfaa8    INDEX     �   CREATE INDEX custom_attributes_epiccustomattribute_project_id_ad2cfaa8 ON public.custom_attributes_epiccustomattribute USING btree (project_id);
 M   DROP INDEX public.custom_attributes_epiccustomattribute_project_id_ad2cfaa8;
       public            taiga    false    294            �           1259    319211 .   custom_attributes_issuec_issue_id_868161f8_idx    INDEX     �   CREATE INDEX custom_attributes_issuec_issue_id_868161f8_idx ON public.custom_attributes_issuecustomattributesvalues USING btree (issue_id);
 B   DROP INDEX public.custom_attributes_issuec_issue_id_868161f8_idx;
       public            taiga    false    288            �           1259    319133 :   custom_attributes_issuecustomattribute_project_id_3b4acff5    INDEX     �   CREATE INDEX custom_attributes_issuecustomattribute_project_id_3b4acff5 ON public.custom_attributes_issuecustomattribute USING btree (project_id);
 N   DROP INDEX public.custom_attributes_issuecustomattribute_project_id_3b4acff5;
       public            taiga    false    282            �           1259    319212 -   custom_attributes_taskcu_task_id_3d1ccf5e_idx    INDEX     �   CREATE INDEX custom_attributes_taskcu_task_id_3d1ccf5e_idx ON public.custom_attributes_taskcustomattributesvalues USING btree (task_id);
 A   DROP INDEX public.custom_attributes_taskcu_task_id_3d1ccf5e_idx;
       public            taiga    false    290            �           1259    319139 9   custom_attributes_taskcustomattribute_project_id_f0f622a8    INDEX     �   CREATE INDEX custom_attributes_taskcustomattribute_project_id_f0f622a8 ON public.custom_attributes_taskcustomattribute USING btree (project_id);
 M   DROP INDEX public.custom_attributes_taskcustomattribute_project_id_f0f622a8;
       public            taiga    false    284            �           1259    319213 3   custom_attributes_userst_user_story_id_99b10c43_idx    INDEX     �   CREATE INDEX custom_attributes_userst_user_story_id_99b10c43_idx ON public.custom_attributes_userstorycustomattributesvalues USING btree (user_story_id);
 G   DROP INDEX public.custom_attributes_userst_user_story_id_99b10c43_idx;
       public            taiga    false    292            �           1259    319145 >   custom_attributes_userstorycustomattribute_project_id_2619cf6c    INDEX     �   CREATE INDEX custom_attributes_userstorycustomattribute_project_id_2619cf6c ON public.custom_attributes_userstorycustomattribute USING btree (project_id);
 R   DROP INDEX public.custom_attributes_userstorycustomattribute_project_id_2619cf6c;
       public            taiga    false    286            x           1259    317699 )   django_admin_log_content_type_id_c4bce8eb    INDEX     q   CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);
 =   DROP INDEX public.django_admin_log_content_type_id_c4bce8eb;
       public            taiga    false    209            {           1259    317700 !   django_admin_log_user_id_c564eba6    INDEX     a   CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);
 5   DROP INDEX public.django_admin_log_user_id_c564eba6;
       public            taiga    false    209                       1259    319692 #   django_session_expire_date_a5c62663    INDEX     e   CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);
 7   DROP INDEX public.django_session_expire_date_a5c62663;
       public            taiga    false    325                       1259    319691 (   django_session_session_key_c0390e0f_like    INDEX     ~   CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);
 <   DROP INDEX public.django_session_session_key_c0390e0f_like;
       public            taiga    false    325            �           1259    319334 !   djmail_message_uuid_8dad4f24_like    INDEX     p   CREATE INDEX djmail_message_uuid_8dad4f24_like ON public.djmail_message USING btree (uuid varchar_pattern_ops);
 5   DROP INDEX public.djmail_message_uuid_8dad4f24_like;
       public            taiga    false    297            �           1259    319357 $   easy_thumbnails_source_name_5fe0edc6    INDEX     g   CREATE INDEX easy_thumbnails_source_name_5fe0edc6 ON public.easy_thumbnails_source USING btree (name);
 8   DROP INDEX public.easy_thumbnails_source_name_5fe0edc6;
       public            taiga    false    299            �           1259    319358 )   easy_thumbnails_source_name_5fe0edc6_like    INDEX     �   CREATE INDEX easy_thumbnails_source_name_5fe0edc6_like ON public.easy_thumbnails_source USING btree (name varchar_pattern_ops);
 =   DROP INDEX public.easy_thumbnails_source_name_5fe0edc6_like;
       public            taiga    false    299            �           1259    319355 ,   easy_thumbnails_source_storage_hash_946cbcc9    INDEX     w   CREATE INDEX easy_thumbnails_source_storage_hash_946cbcc9 ON public.easy_thumbnails_source USING btree (storage_hash);
 @   DROP INDEX public.easy_thumbnails_source_storage_hash_946cbcc9;
       public            taiga    false    299            �           1259    319356 1   easy_thumbnails_source_storage_hash_946cbcc9_like    INDEX     �   CREATE INDEX easy_thumbnails_source_storage_hash_946cbcc9_like ON public.easy_thumbnails_source USING btree (storage_hash varchar_pattern_ops);
 E   DROP INDEX public.easy_thumbnails_source_storage_hash_946cbcc9_like;
       public            taiga    false    299            �           1259    319366 '   easy_thumbnails_thumbnail_name_b5882c31    INDEX     m   CREATE INDEX easy_thumbnails_thumbnail_name_b5882c31 ON public.easy_thumbnails_thumbnail USING btree (name);
 ;   DROP INDEX public.easy_thumbnails_thumbnail_name_b5882c31;
       public            taiga    false    301            �           1259    319367 ,   easy_thumbnails_thumbnail_name_b5882c31_like    INDEX     �   CREATE INDEX easy_thumbnails_thumbnail_name_b5882c31_like ON public.easy_thumbnails_thumbnail USING btree (name varchar_pattern_ops);
 @   DROP INDEX public.easy_thumbnails_thumbnail_name_b5882c31_like;
       public            taiga    false    301            �           1259    319368 ,   easy_thumbnails_thumbnail_source_id_5b57bc77    INDEX     w   CREATE INDEX easy_thumbnails_thumbnail_source_id_5b57bc77 ON public.easy_thumbnails_thumbnail USING btree (source_id);
 @   DROP INDEX public.easy_thumbnails_thumbnail_source_id_5b57bc77;
       public            taiga    false    301            �           1259    319364 /   easy_thumbnails_thumbnail_storage_hash_f1435f49    INDEX     }   CREATE INDEX easy_thumbnails_thumbnail_storage_hash_f1435f49 ON public.easy_thumbnails_thumbnail USING btree (storage_hash);
 C   DROP INDEX public.easy_thumbnails_thumbnail_storage_hash_f1435f49;
       public            taiga    false    301            �           1259    319365 4   easy_thumbnails_thumbnail_storage_hash_f1435f49_like    INDEX     �   CREATE INDEX easy_thumbnails_thumbnail_storage_hash_f1435f49_like ON public.easy_thumbnails_thumbnail USING btree (storage_hash varchar_pattern_ops);
 H   DROP INDEX public.easy_thumbnails_thumbnail_storage_hash_f1435f49_like;
       public            taiga    false    301            �           1259    319072 "   epics_epic_assigned_to_id_13e08004    INDEX     c   CREATE INDEX epics_epic_assigned_to_id_13e08004 ON public.epics_epic USING btree (assigned_to_id);
 6   DROP INDEX public.epics_epic_assigned_to_id_13e08004;
       public            taiga    false    278            �           1259    319073    epics_epic_owner_id_b09888c4    INDEX     W   CREATE INDEX epics_epic_owner_id_b09888c4 ON public.epics_epic USING btree (owner_id);
 0   DROP INDEX public.epics_epic_owner_id_b09888c4;
       public            taiga    false    278            �           1259    319074    epics_epic_project_id_d98aaef7    INDEX     [   CREATE INDEX epics_epic_project_id_d98aaef7 ON public.epics_epic USING btree (project_id);
 2   DROP INDEX public.epics_epic_project_id_d98aaef7;
       public            taiga    false    278            �           1259    319071    epics_epic_ref_aa52eb4a    INDEX     M   CREATE INDEX epics_epic_ref_aa52eb4a ON public.epics_epic USING btree (ref);
 +   DROP INDEX public.epics_epic_ref_aa52eb4a;
       public            taiga    false    278            �           1259    319075    epics_epic_status_id_4cf3af1a    INDEX     Y   CREATE INDEX epics_epic_status_id_4cf3af1a ON public.epics_epic USING btree (status_id);
 1   DROP INDEX public.epics_epic_status_id_4cf3af1a;
       public            taiga    false    278            �           1259    319086 '   epics_relateduserstory_epic_id_57605230    INDEX     m   CREATE INDEX epics_relateduserstory_epic_id_57605230 ON public.epics_relateduserstory USING btree (epic_id);
 ;   DROP INDEX public.epics_relateduserstory_epic_id_57605230;
       public            taiga    false    280            �           1259    319087 -   epics_relateduserstory_user_story_id_329a951c    INDEX     y   CREATE INDEX epics_relateduserstory_user_story_id_329a951c ON public.epics_relateduserstory USING btree (user_story_id);
 A   DROP INDEX public.epics_relateduserstory_user_story_id_329a951c;
       public            taiga    false    280            �           1259    319433 *   external_apps_application_id_e9988cf8_like    INDEX     �   CREATE INDEX external_apps_application_id_e9988cf8_like ON public.external_apps_application USING btree (id varchar_pattern_ops);
 >   DROP INDEX public.external_apps_application_id_e9988cf8_like;
       public            taiga    false    304            �           1259    319444 6   external_apps_applicationtoken_application_id_0e934655    INDEX     �   CREATE INDEX external_apps_applicationtoken_application_id_0e934655 ON public.external_apps_applicationtoken USING btree (application_id);
 J   DROP INDEX public.external_apps_applicationtoken_application_id_0e934655;
       public            taiga    false    306            �           1259    319445 ;   external_apps_applicationtoken_application_id_0e934655_like    INDEX     �   CREATE INDEX external_apps_applicationtoken_application_id_0e934655_like ON public.external_apps_applicationtoken USING btree (application_id varchar_pattern_ops);
 O   DROP INDEX public.external_apps_applicationtoken_application_id_0e934655_like;
       public            taiga    false    306            �           1259    319446 /   external_apps_applicationtoken_user_id_6e2f1e8a    INDEX     }   CREATE INDEX external_apps_applicationtoken_user_id_6e2f1e8a ON public.external_apps_applicationtoken USING btree (user_id);
 C   DROP INDEX public.external_apps_applicationtoken_user_id_6e2f1e8a;
       public            taiga    false    306            �           1259    319007 %   history_historyentry_id_ff18cc9f_like    INDEX     x   CREATE INDEX history_historyentry_id_ff18cc9f_like ON public.history_historyentry USING btree (id varchar_pattern_ops);
 9   DROP INDEX public.history_historyentry_id_ff18cc9f_like;
       public            taiga    false    276            �           1259    319008 !   history_historyentry_key_c088c4ae    INDEX     a   CREATE INDEX history_historyentry_key_c088c4ae ON public.history_historyentry USING btree (key);
 5   DROP INDEX public.history_historyentry_key_c088c4ae;
       public            taiga    false    276            �           1259    319009 &   history_historyentry_key_c088c4ae_like    INDEX     z   CREATE INDEX history_historyentry_key_c088c4ae_like ON public.history_historyentry USING btree (key varchar_pattern_ops);
 :   DROP INDEX public.history_historyentry_key_c088c4ae_like;
       public            taiga    false    276            �           1259    319010 (   history_historyentry_project_id_9b008f70    INDEX     o   CREATE INDEX history_historyentry_project_id_9b008f70 ON public.history_historyentry USING btree (project_id);
 <   DROP INDEX public.history_historyentry_project_id_9b008f70;
       public            taiga    false    276                       1259    318166 $   issues_issue_assigned_to_id_c6054289    INDEX     g   CREATE INDEX issues_issue_assigned_to_id_c6054289 ON public.issues_issue USING btree (assigned_to_id);
 8   DROP INDEX public.issues_issue_assigned_to_id_c6054289;
       public            taiga    false    243                       1259    318167 "   issues_issue_milestone_id_3c2695ee    INDEX     c   CREATE INDEX issues_issue_milestone_id_3c2695ee ON public.issues_issue USING btree (milestone_id);
 6   DROP INDEX public.issues_issue_milestone_id_3c2695ee;
       public            taiga    false    243                       1259    318168    issues_issue_owner_id_5c361b47    INDEX     [   CREATE INDEX issues_issue_owner_id_5c361b47 ON public.issues_issue USING btree (owner_id);
 2   DROP INDEX public.issues_issue_owner_id_5c361b47;
       public            taiga    false    243                       1259    318169 !   issues_issue_priority_id_93842a93    INDEX     a   CREATE INDEX issues_issue_priority_id_93842a93 ON public.issues_issue USING btree (priority_id);
 5   DROP INDEX public.issues_issue_priority_id_93842a93;
       public            taiga    false    243                       1259    318170     issues_issue_project_id_4b0f3e2f    INDEX     _   CREATE INDEX issues_issue_project_id_4b0f3e2f ON public.issues_issue USING btree (project_id);
 4   DROP INDEX public.issues_issue_project_id_4b0f3e2f;
       public            taiga    false    243                       1259    318165    issues_issue_ref_4c1e7f8f    INDEX     Q   CREATE INDEX issues_issue_ref_4c1e7f8f ON public.issues_issue USING btree (ref);
 -   DROP INDEX public.issues_issue_ref_4c1e7f8f;
       public            taiga    false    243                       1259    318171 !   issues_issue_severity_id_695dade0    INDEX     a   CREATE INDEX issues_issue_severity_id_695dade0 ON public.issues_issue USING btree (severity_id);
 5   DROP INDEX public.issues_issue_severity_id_695dade0;
       public            taiga    false    243                       1259    318172    issues_issue_status_id_64473cf1    INDEX     ]   CREATE INDEX issues_issue_status_id_64473cf1 ON public.issues_issue USING btree (status_id);
 3   DROP INDEX public.issues_issue_status_id_64473cf1;
       public            taiga    false    243                       1259    318173    issues_issue_type_id_c1063362    INDEX     Y   CREATE INDEX issues_issue_type_id_c1063362 ON public.issues_issue USING btree (type_id);
 1   DROP INDEX public.issues_issue_type_id_c1063362;
       public            taiga    false    243            k           1259    318725 #   likes_like_content_type_id_8ffc2116    INDEX     e   CREATE INDEX likes_like_content_type_id_8ffc2116 ON public.likes_like USING btree (content_type_id);
 7   DROP INDEX public.likes_like_content_type_id_8ffc2116;
       public            taiga    false    267            p           1259    318726    likes_like_user_id_aae4c421    INDEX     U   CREATE INDEX likes_like_user_id_aae4c421 ON public.likes_like USING btree (user_id);
 /   DROP INDEX public.likes_like_user_id_aae4c421;
       public            taiga    false    267                       1259    318086 "   milestones_milestone_name_23fb0698    INDEX     c   CREATE INDEX milestones_milestone_name_23fb0698 ON public.milestones_milestone USING btree (name);
 6   DROP INDEX public.milestones_milestone_name_23fb0698;
       public            taiga    false    241                       1259    318087 '   milestones_milestone_name_23fb0698_like    INDEX     |   CREATE INDEX milestones_milestone_name_23fb0698_like ON public.milestones_milestone USING btree (name varchar_pattern_ops);
 ;   DROP INDEX public.milestones_milestone_name_23fb0698_like;
       public            taiga    false    241                       1259    318090 &   milestones_milestone_owner_id_216ba23b    INDEX     k   CREATE INDEX milestones_milestone_owner_id_216ba23b ON public.milestones_milestone USING btree (owner_id);
 :   DROP INDEX public.milestones_milestone_owner_id_216ba23b;
       public            taiga    false    241            	           1259    318091 (   milestones_milestone_project_id_6151cb75    INDEX     o   CREATE INDEX milestones_milestone_project_id_6151cb75 ON public.milestones_milestone USING btree (project_id);
 <   DROP INDEX public.milestones_milestone_project_id_6151cb75;
       public            taiga    false    241            
           1259    318088 "   milestones_milestone_slug_08e5995e    INDEX     c   CREATE INDEX milestones_milestone_slug_08e5995e ON public.milestones_milestone USING btree (slug);
 6   DROP INDEX public.milestones_milestone_slug_08e5995e;
       public            taiga    false    241                       1259    318089 '   milestones_milestone_slug_08e5995e_like    INDEX     |   CREATE INDEX milestones_milestone_slug_08e5995e_like ON public.milestones_milestone USING btree (slug varchar_pattern_ops);
 ;   DROP INDEX public.milestones_milestone_slug_08e5995e_like;
       public            taiga    false    241            9           1259    318416 6   notifications_historycha_historyentry_id_ad550852_like    INDEX     �   CREATE INDEX notifications_historycha_historyentry_id_ad550852_like ON public.notifications_historychangenotification_history_entries USING btree (historyentry_id varchar_pattern_ops);
 J   DROP INDEX public.notifications_historycha_historyentry_id_ad550852_like;
       public            taiga    false    253            :           1259    318414 >   notifications_historychang_historychangenotification__65e52ffd    INDEX     �   CREATE INDEX notifications_historychang_historychangenotification__65e52ffd ON public.notifications_historychangenotification_history_entries USING btree (historychangenotification_id);
 R   DROP INDEX public.notifications_historychang_historychangenotification__65e52ffd;
       public            taiga    false    253            @           1259    318429 >   notifications_historychang_historychangenotification__d8e98e97    INDEX     �   CREATE INDEX notifications_historychang_historychangenotification__d8e98e97 ON public.notifications_historychangenotification_notify_users USING btree (historychangenotification_id);
 R   DROP INDEX public.notifications_historychang_historychangenotification__d8e98e97;
       public            taiga    false    255            ;           1259    318415 3   notifications_historychang_historyentry_id_ad550852    INDEX     �   CREATE INDEX notifications_historychang_historyentry_id_ad550852 ON public.notifications_historychangenotification_history_entries USING btree (historyentry_id);
 G   DROP INDEX public.notifications_historychang_historyentry_id_ad550852;
       public            taiga    false    253            A           1259    318430 +   notifications_historychang_user_id_f7bd2448    INDEX     �   CREATE INDEX notifications_historychang_user_id_f7bd2448 ON public.notifications_historychangenotification_notify_users USING btree (user_id);
 ?   DROP INDEX public.notifications_historychang_user_id_f7bd2448;
       public            taiga    false    255            3           1259    318400 9   notifications_historychangenotification_owner_id_6f63be8a    INDEX     �   CREATE INDEX notifications_historychangenotification_owner_id_6f63be8a ON public.notifications_historychangenotification USING btree (owner_id);
 M   DROP INDEX public.notifications_historychangenotification_owner_id_6f63be8a;
       public            taiga    false    251            6           1259    318401 ;   notifications_historychangenotification_project_id_52cf5e2b    INDEX     �   CREATE INDEX notifications_historychangenotification_project_id_52cf5e2b ON public.notifications_historychangenotification USING btree (project_id);
 O   DROP INDEX public.notifications_historychangenotification_project_id_52cf5e2b;
       public            taiga    false    251            -           1259    318343 .   notifications_notifypolicy_project_id_aa5da43f    INDEX     {   CREATE INDEX notifications_notifypolicy_project_id_aa5da43f ON public.notifications_notifypolicy USING btree (project_id);
 B   DROP INDEX public.notifications_notifypolicy_project_id_aa5da43f;
       public            taiga    false    249            0           1259    318344 +   notifications_notifypolicy_user_id_2902cbeb    INDEX     u   CREATE INDEX notifications_notifypolicy_user_id_2902cbeb ON public.notifications_notifypolicy USING btree (user_id);
 ?   DROP INDEX public.notifications_notifypolicy_user_id_2902cbeb;
       public            taiga    false    249            D           1259    318459 .   notifications_watched_content_type_id_7b3ab729    INDEX     {   CREATE INDEX notifications_watched_content_type_id_7b3ab729 ON public.notifications_watched USING btree (content_type_id);
 B   DROP INDEX public.notifications_watched_content_type_id_7b3ab729;
       public            taiga    false    257            I           1259    318461 )   notifications_watched_project_id_c88baa46    INDEX     q   CREATE INDEX notifications_watched_project_id_c88baa46 ON public.notifications_watched USING btree (project_id);
 =   DROP INDEX public.notifications_watched_project_id_c88baa46;
       public            taiga    false    257            J           1259    318460 &   notifications_watched_user_id_1bce1955    INDEX     k   CREATE INDEX notifications_watched_user_id_1bce1955 ON public.notifications_watched USING btree (user_id);
 :   DROP INDEX public.notifications_watched_user_id_1bce1955;
       public            taiga    false    257            �           1259    319524 .   notifications_webnotification_created_b17f50f8    INDEX     {   CREATE INDEX notifications_webnotification_created_b17f50f8 ON public.notifications_webnotification USING btree (created);
 B   DROP INDEX public.notifications_webnotification_created_b17f50f8;
       public            taiga    false    310            �           1259    319525 .   notifications_webnotification_user_id_f32287d5    INDEX     {   CREATE INDEX notifications_webnotification_user_id_f32287d5 ON public.notifications_webnotification USING btree (user_id);
 B   DROP INDEX public.notifications_webnotification_user_id_f32287d5;
       public            taiga    false    310            s           1259    318820 '   projects_epicstatus_project_id_d2c43c29    INDEX     m   CREATE INDEX projects_epicstatus_project_id_d2c43c29 ON public.projects_epicstatus USING btree (project_id);
 ;   DROP INDEX public.projects_epicstatus_project_id_d2c43c29;
       public            taiga    false    269            x           1259    318818 !   projects_epicstatus_slug_63c476c8    INDEX     a   CREATE INDEX projects_epicstatus_slug_63c476c8 ON public.projects_epicstatus USING btree (slug);
 5   DROP INDEX public.projects_epicstatus_slug_63c476c8;
       public            taiga    false    269            y           1259    318819 &   projects_epicstatus_slug_63c476c8_like    INDEX     z   CREATE INDEX projects_epicstatus_slug_63c476c8_like ON public.projects_epicstatus USING btree (slug varchar_pattern_ops);
 :   DROP INDEX public.projects_epicstatus_slug_63c476c8_like;
       public            taiga    false    269            �           1259    319584 )   projects_issueduedate_project_id_ec077eb7    INDEX     q   CREATE INDEX projects_issueduedate_project_id_ec077eb7 ON public.projects_issueduedate USING btree (project_id);
 =   DROP INDEX public.projects_issueduedate_project_id_ec077eb7;
       public            taiga    false    314            �           1259    317869 (   projects_issuestatus_project_id_1988ebf4    INDEX     o   CREATE INDEX projects_issuestatus_project_id_1988ebf4 ON public.projects_issuestatus USING btree (project_id);
 <   DROP INDEX public.projects_issuestatus_project_id_1988ebf4;
       public            taiga    false    217            �           1259    318602 "   projects_issuestatus_slug_2c528947    INDEX     c   CREATE INDEX projects_issuestatus_slug_2c528947 ON public.projects_issuestatus USING btree (slug);
 6   DROP INDEX public.projects_issuestatus_slug_2c528947;
       public            taiga    false    217            �           1259    318603 '   projects_issuestatus_slug_2c528947_like    INDEX     |   CREATE INDEX projects_issuestatus_slug_2c528947_like ON public.projects_issuestatus USING btree (slug varchar_pattern_ops);
 ;   DROP INDEX public.projects_issuestatus_slug_2c528947_like;
       public            taiga    false    217            �           1259    317875 &   projects_issuetype_project_id_e831e4ae    INDEX     k   CREATE INDEX projects_issuetype_project_id_e831e4ae ON public.projects_issuetype USING btree (project_id);
 :   DROP INDEX public.projects_issuetype_project_id_e831e4ae;
       public            taiga    false    219            �           1259    318314 *   projects_membership_invited_by_id_a2c6c913    INDEX     s   CREATE INDEX projects_membership_invited_by_id_a2c6c913 ON public.projects_membership USING btree (invited_by_id);
 >   DROP INDEX public.projects_membership_invited_by_id_a2c6c913;
       public            taiga    false    213            �           1259    317755 '   projects_membership_project_id_5f65bf3f    INDEX     m   CREATE INDEX projects_membership_project_id_5f65bf3f ON public.projects_membership USING btree (project_id);
 ;   DROP INDEX public.projects_membership_project_id_5f65bf3f;
       public            taiga    false    213            �           1259    317761 $   projects_membership_role_id_c4bd36ef    INDEX     g   CREATE INDEX projects_membership_role_id_c4bd36ef ON public.projects_membership USING btree (role_id);
 8   DROP INDEX public.projects_membership_role_id_c4bd36ef;
       public            taiga    false    213            �           1259    317749 $   projects_membership_user_id_13374535    INDEX     g   CREATE INDEX projects_membership_user_id_13374535 ON public.projects_membership USING btree (user_id);
 8   DROP INDEX public.projects_membership_user_id_13374535;
       public            taiga    false    213            �           1259    317881 #   projects_points_project_id_3b8f7b42    INDEX     e   CREATE INDEX projects_points_project_id_3b8f7b42 ON public.projects_points USING btree (project_id);
 7   DROP INDEX public.projects_points_project_id_3b8f7b42;
       public            taiga    false    221            �           1259    317887 %   projects_priority_project_id_936c75b2    INDEX     i   CREATE INDEX projects_priority_project_id_936c75b2 ON public.projects_priority USING btree (project_id);
 9   DROP INDEX public.projects_priority_project_id_936c75b2;
       public            taiga    false    223            �           1259    317907 .   projects_project_creation_template_id_b5a97819    INDEX     {   CREATE INDEX projects_project_creation_template_id_b5a97819 ON public.projects_project USING btree (creation_template_id);
 B   DROP INDEX public.projects_project_creation_template_id_b5a97819;
       public            taiga    false    215            �           1259    318831 (   projects_project_epics_csv_uuid_cb50f2ee    INDEX     o   CREATE INDEX projects_project_epics_csv_uuid_cb50f2ee ON public.projects_project USING btree (epics_csv_uuid);
 <   DROP INDEX public.projects_project_epics_csv_uuid_cb50f2ee;
       public            taiga    false    215            �           1259    318832 -   projects_project_epics_csv_uuid_cb50f2ee_like    INDEX     �   CREATE INDEX projects_project_epics_csv_uuid_cb50f2ee_like ON public.projects_project USING btree (epics_csv_uuid varchar_pattern_ops);
 A   DROP INDEX public.projects_project_epics_csv_uuid_cb50f2ee_like;
       public            taiga    false    215            �           1259    318636 )   projects_project_issues_csv_uuid_e6a84723    INDEX     q   CREATE INDEX projects_project_issues_csv_uuid_e6a84723 ON public.projects_project USING btree (issues_csv_uuid);
 =   DROP INDEX public.projects_project_issues_csv_uuid_e6a84723;
       public            taiga    false    215            �           1259    318637 .   projects_project_issues_csv_uuid_e6a84723_like    INDEX     �   CREATE INDEX projects_project_issues_csv_uuid_e6a84723_like ON public.projects_project USING btree (issues_csv_uuid varchar_pattern_ops);
 B   DROP INDEX public.projects_project_issues_csv_uuid_e6a84723_like;
       public            taiga    false    215            �           1259    318759 %   projects_project_name_id_44f44a5f_idx    INDEX     f   CREATE INDEX projects_project_name_id_44f44a5f_idx ON public.projects_project USING btree (name, id);
 9   DROP INDEX public.projects_project_name_id_44f44a5f_idx;
       public            taiga    false    215    215            �           1259    317743 "   projects_project_owner_id_b940de39    INDEX     c   CREATE INDEX projects_project_owner_id_b940de39 ON public.projects_project USING btree (owner_id);
 6   DROP INDEX public.projects_project_owner_id_b940de39;
       public            taiga    false    215            �           1259    317742 #   projects_project_slug_2d50067a_like    INDEX     t   CREATE INDEX projects_project_slug_2d50067a_like ON public.projects_project USING btree (slug varchar_pattern_ops);
 7   DROP INDEX public.projects_project_slug_2d50067a_like;
       public            taiga    false    215            �           1259    318638 (   projects_project_tasks_csv_uuid_ecd0b1b5    INDEX     o   CREATE INDEX projects_project_tasks_csv_uuid_ecd0b1b5 ON public.projects_project USING btree (tasks_csv_uuid);
 <   DROP INDEX public.projects_project_tasks_csv_uuid_ecd0b1b5;
       public            taiga    false    215            �           1259    318639 -   projects_project_tasks_csv_uuid_ecd0b1b5_like    INDEX     �   CREATE INDEX projects_project_tasks_csv_uuid_ecd0b1b5_like ON public.projects_project USING btree (tasks_csv_uuid varchar_pattern_ops);
 A   DROP INDEX public.projects_project_tasks_csv_uuid_ecd0b1b5_like;
       public            taiga    false    215            �           1259    319544    projects_project_textquery_idx    INDEX     �  CREATE INDEX projects_project_textquery_idx ON public.projects_project USING gin ((((setweight(to_tsvector('simple'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, COALESCE(public.inmutable_array_to_string(tags), ''::text)), 'B'::"char")) || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'C'::"char"))));
 2   DROP INDEX public.projects_project_textquery_idx;
       public            taiga    false    215    215    382    215    215            �           1259    318750 (   projects_project_total_activity_edf1a486    INDEX     o   CREATE INDEX projects_project_total_activity_edf1a486 ON public.projects_project USING btree (total_activity);
 <   DROP INDEX public.projects_project_total_activity_edf1a486;
       public            taiga    false    215            �           1259    318751 3   projects_project_total_activity_last_month_669bff3e    INDEX     �   CREATE INDEX projects_project_total_activity_last_month_669bff3e ON public.projects_project USING btree (total_activity_last_month);
 G   DROP INDEX public.projects_project_total_activity_last_month_669bff3e;
       public            taiga    false    215            �           1259    318752 2   projects_project_total_activity_last_week_961ca1b0    INDEX     �   CREATE INDEX projects_project_total_activity_last_week_961ca1b0 ON public.projects_project USING btree (total_activity_last_week);
 F   DROP INDEX public.projects_project_total_activity_last_week_961ca1b0;
       public            taiga    false    215            �           1259    318753 2   projects_project_total_activity_last_year_12ea6dbe    INDEX     �   CREATE INDEX projects_project_total_activity_last_year_12ea6dbe ON public.projects_project USING btree (total_activity_last_year);
 F   DROP INDEX public.projects_project_total_activity_last_year_12ea6dbe;
       public            taiga    false    215            �           1259    318754 $   projects_project_total_fans_436fe323    INDEX     g   CREATE INDEX projects_project_total_fans_436fe323 ON public.projects_project USING btree (total_fans);
 8   DROP INDEX public.projects_project_total_fans_436fe323;
       public            taiga    false    215            �           1259    318755 /   projects_project_total_fans_last_month_455afdbb    INDEX     }   CREATE INDEX projects_project_total_fans_last_month_455afdbb ON public.projects_project USING btree (total_fans_last_month);
 C   DROP INDEX public.projects_project_total_fans_last_month_455afdbb;
       public            taiga    false    215            �           1259    318756 .   projects_project_total_fans_last_week_c65146b1    INDEX     {   CREATE INDEX projects_project_total_fans_last_week_c65146b1 ON public.projects_project USING btree (total_fans_last_week);
 B   DROP INDEX public.projects_project_total_fans_last_week_c65146b1;
       public            taiga    false    215            �           1259    318757 .   projects_project_total_fans_last_year_167b29c2    INDEX     {   CREATE INDEX projects_project_total_fans_last_year_167b29c2 ON public.projects_project USING btree (total_fans_last_year);
 B   DROP INDEX public.projects_project_total_fans_last_year_167b29c2;
       public            taiga    false    215            �           1259    318758 1   projects_project_totals_updated_datetime_1bcc5bfa    INDEX     �   CREATE INDEX projects_project_totals_updated_datetime_1bcc5bfa ON public.projects_project USING btree (totals_updated_datetime);
 E   DROP INDEX public.projects_project_totals_updated_datetime_1bcc5bfa;
       public            taiga    false    215            �           1259    318640 .   projects_project_userstories_csv_uuid_6e83c6c1    INDEX     {   CREATE INDEX projects_project_userstories_csv_uuid_6e83c6c1 ON public.projects_project USING btree (userstories_csv_uuid);
 B   DROP INDEX public.projects_project_userstories_csv_uuid_6e83c6c1;
       public            taiga    false    215            �           1259    318641 3   projects_project_userstories_csv_uuid_6e83c6c1_like    INDEX     �   CREATE INDEX projects_project_userstories_csv_uuid_6e83c6c1_like ON public.projects_project USING btree (userstories_csv_uuid varchar_pattern_ops);
 G   DROP INDEX public.projects_project_userstories_csv_uuid_6e83c6c1_like;
       public            taiga    false    215            �           1259    319652 &   projects_project_workspace_id_7ea54f67    INDEX     k   CREATE INDEX projects_project_workspace_id_7ea54f67 ON public.projects_project USING btree (workspace_id);
 :   DROP INDEX public.projects_project_workspace_id_7ea54f67;
       public            taiga    false    215            �           1259    317888 +   projects_projecttemplate_slug_2731738e_like    INDEX     �   CREATE INDEX projects_projecttemplate_slug_2731738e_like ON public.projects_projecttemplate USING btree (slug varchar_pattern_ops);
 ?   DROP INDEX public.projects_projecttemplate_slug_2731738e_like;
       public            taiga    false    225            �           1259    317894 %   projects_severity_project_id_9ab920cd    INDEX     i   CREATE INDEX projects_severity_project_id_9ab920cd ON public.projects_severity USING btree (project_id);
 9   DROP INDEX public.projects_severity_project_id_9ab920cd;
       public            taiga    false    227            	           1259    319620 %   projects_swimlane_project_id_06871cf8    INDEX     i   CREATE INDEX projects_swimlane_project_id_06871cf8 ON public.projects_swimlane USING btree (project_id);
 9   DROP INDEX public.projects_swimlane_project_id_06871cf8;
       public            taiga    false    320                       1259    319641 3   projects_swimlaneuserstorystatus_status_id_2f3fda91    INDEX     �   CREATE INDEX projects_swimlaneuserstorystatus_status_id_2f3fda91 ON public.projects_swimlaneuserstorystatus USING btree (status_id);
 G   DROP INDEX public.projects_swimlaneuserstorystatus_status_id_2f3fda91;
       public            taiga    false    322                       1259    319642 5   projects_swimlaneuserstorystatus_swimlane_id_1d3f2b21    INDEX     �   CREATE INDEX projects_swimlaneuserstorystatus_swimlane_id_1d3f2b21 ON public.projects_swimlaneuserstorystatus USING btree (swimlane_id);
 I   DROP INDEX public.projects_swimlaneuserstorystatus_swimlane_id_1d3f2b21;
       public            taiga    false    322            �           1259    319590 (   projects_taskduedate_project_id_775d850d    INDEX     o   CREATE INDEX projects_taskduedate_project_id_775d850d ON public.projects_taskduedate USING btree (project_id);
 <   DROP INDEX public.projects_taskduedate_project_id_775d850d;
       public            taiga    false    316            �           1259    317900 '   projects_taskstatus_project_id_8b32b2bb    INDEX     m   CREATE INDEX projects_taskstatus_project_id_8b32b2bb ON public.projects_taskstatus USING btree (project_id);
 ;   DROP INDEX public.projects_taskstatus_project_id_8b32b2bb;
       public            taiga    false    229            �           1259    318604 !   projects_taskstatus_slug_cf358ffa    INDEX     a   CREATE INDEX projects_taskstatus_slug_cf358ffa ON public.projects_taskstatus USING btree (slug);
 5   DROP INDEX public.projects_taskstatus_slug_cf358ffa;
       public            taiga    false    229            �           1259    318605 &   projects_taskstatus_slug_cf358ffa_like    INDEX     z   CREATE INDEX projects_taskstatus_slug_cf358ffa_like ON public.projects_taskstatus USING btree (slug varchar_pattern_ops);
 :   DROP INDEX public.projects_taskstatus_slug_cf358ffa_like;
       public            taiga    false    229                       1259    319596 -   projects_userstoryduedate_project_id_ab7b1680    INDEX     y   CREATE INDEX projects_userstoryduedate_project_id_ab7b1680 ON public.projects_userstoryduedate USING btree (project_id);
 A   DROP INDEX public.projects_userstoryduedate_project_id_ab7b1680;
       public            taiga    false    318            �           1259    317906 ,   projects_userstorystatus_project_id_cdf95c9c    INDEX     w   CREATE INDEX projects_userstorystatus_project_id_cdf95c9c ON public.projects_userstorystatus USING btree (project_id);
 @   DROP INDEX public.projects_userstorystatus_project_id_cdf95c9c;
       public            taiga    false    231            �           1259    318606 &   projects_userstorystatus_slug_d574ed51    INDEX     k   CREATE INDEX projects_userstorystatus_slug_d574ed51 ON public.projects_userstorystatus USING btree (slug);
 :   DROP INDEX public.projects_userstorystatus_slug_d574ed51;
       public            taiga    false    231            �           1259    318607 +   projects_userstorystatus_slug_d574ed51_like    INDEX     �   CREATE INDEX projects_userstorystatus_slug_d574ed51_like ON public.projects_userstorystatus USING btree (slug varchar_pattern_ops);
 ?   DROP INDEX public.projects_userstorystatus_slug_d574ed51_like;
       public            taiga    false    231                       1259    319681 -   references_reference_content_type_id_c134e05e    INDEX     y   CREATE INDEX references_reference_content_type_id_c134e05e ON public.references_reference USING btree (content_type_id);
 A   DROP INDEX public.references_reference_content_type_id_c134e05e;
       public            taiga    false    324                       1259    319682 (   references_reference_project_id_00275368    INDEX     o   CREATE INDEX references_reference_project_id_00275368 ON public.references_reference USING btree (project_id);
 <   DROP INDEX public.references_reference_project_id_00275368;
       public            taiga    false    324                       1259    319713 0   settings_userprojectsettings_project_id_0bc686ce    INDEX        CREATE INDEX settings_userprojectsettings_project_id_0bc686ce ON public.settings_userprojectsettings USING btree (project_id);
 D   DROP INDEX public.settings_userprojectsettings_project_id_0bc686ce;
       public            taiga    false    327            !           1259    319714 -   settings_userprojectsettings_user_id_0e7fdc25    INDEX     y   CREATE INDEX settings_userprojectsettings_user_id_0e7fdc25 ON public.settings_userprojectsettings USING btree (user_id);
 A   DROP INDEX public.settings_userprojectsettings_user_id_0e7fdc25;
       public            taiga    false    327            K           1259    318512 "   tasks_task_assigned_to_id_e8821f61    INDEX     c   CREATE INDEX tasks_task_assigned_to_id_e8821f61 ON public.tasks_task USING btree (assigned_to_id);
 6   DROP INDEX public.tasks_task_assigned_to_id_e8821f61;
       public            taiga    false    259            L           1259    318513     tasks_task_milestone_id_64cc568f    INDEX     _   CREATE INDEX tasks_task_milestone_id_64cc568f ON public.tasks_task USING btree (milestone_id);
 4   DROP INDEX public.tasks_task_milestone_id_64cc568f;
       public            taiga    false    259            M           1259    318514    tasks_task_owner_id_db3dcc3e    INDEX     W   CREATE INDEX tasks_task_owner_id_db3dcc3e ON public.tasks_task USING btree (owner_id);
 0   DROP INDEX public.tasks_task_owner_id_db3dcc3e;
       public            taiga    false    259            P           1259    318515    tasks_task_project_id_a2815f0c    INDEX     [   CREATE INDEX tasks_task_project_id_a2815f0c ON public.tasks_task USING btree (project_id);
 2   DROP INDEX public.tasks_task_project_id_a2815f0c;
       public            taiga    false    259            Q           1259    318511    tasks_task_ref_9f55bd37    INDEX     M   CREATE INDEX tasks_task_ref_9f55bd37 ON public.tasks_task USING btree (ref);
 +   DROP INDEX public.tasks_task_ref_9f55bd37;
       public            taiga    false    259            R           1259    318516    tasks_task_status_id_899d2b90    INDEX     Y   CREATE INDEX tasks_task_status_id_899d2b90 ON public.tasks_task USING btree (status_id);
 1   DROP INDEX public.tasks_task_status_id_899d2b90;
       public            taiga    false    259            S           1259    318517 !   tasks_task_user_story_id_47ceaf1d    INDEX     a   CREATE INDEX tasks_task_user_story_id_47ceaf1d ON public.tasks_task USING btree (user_story_id);
 5   DROP INDEX public.tasks_task_user_story_id_47ceaf1d;
       public            taiga    false    259            _           1259    319776    timeline_ti_content_1af26f_idx    INDEX     �   CREATE INDEX timeline_ti_content_1af26f_idx ON public.timeline_timeline USING btree (content_type_id, object_id, created DESC);
 2   DROP INDEX public.timeline_ti_content_1af26f_idx;
       public            taiga    false    265    265    265            `           1259    319775    timeline_ti_namespa_89bca1_idx    INDEX     o   CREATE INDEX timeline_ti_namespa_89bca1_idx ON public.timeline_timeline USING btree (namespace, created DESC);
 2   DROP INDEX public.timeline_ti_namespa_89bca1_idx;
       public            taiga    false    265    265            a           1259    318676 *   timeline_timeline_content_type_id_5731a0c6    INDEX     s   CREATE INDEX timeline_timeline_content_type_id_5731a0c6 ON public.timeline_timeline USING btree (content_type_id);
 >   DROP INDEX public.timeline_timeline_content_type_id_5731a0c6;
       public            taiga    false    265            b           1259    319757 "   timeline_timeline_created_4e9e3a68    INDEX     c   CREATE INDEX timeline_timeline_created_4e9e3a68 ON public.timeline_timeline USING btree (created);
 6   DROP INDEX public.timeline_timeline_created_4e9e3a68;
       public            taiga    false    265            c           1259    318675 /   timeline_timeline_data_content_type_id_0689742e    INDEX     }   CREATE INDEX timeline_timeline_data_content_type_id_0689742e ON public.timeline_timeline USING btree (data_content_type_id);
 C   DROP INDEX public.timeline_timeline_data_content_type_id_0689742e;
       public            taiga    false    265            d           1259    318677 %   timeline_timeline_event_type_cb2fcdb2    INDEX     i   CREATE INDEX timeline_timeline_event_type_cb2fcdb2 ON public.timeline_timeline USING btree (event_type);
 9   DROP INDEX public.timeline_timeline_event_type_cb2fcdb2;
       public            taiga    false    265            e           1259    318678 *   timeline_timeline_event_type_cb2fcdb2_like    INDEX     �   CREATE INDEX timeline_timeline_event_type_cb2fcdb2_like ON public.timeline_timeline USING btree (event_type varchar_pattern_ops);
 >   DROP INDEX public.timeline_timeline_event_type_cb2fcdb2_like;
       public            taiga    false    265            f           1259    318680 $   timeline_timeline_namespace_26f217ed    INDEX     g   CREATE INDEX timeline_timeline_namespace_26f217ed ON public.timeline_timeline USING btree (namespace);
 8   DROP INDEX public.timeline_timeline_namespace_26f217ed;
       public            taiga    false    265            g           1259    318681 )   timeline_timeline_namespace_26f217ed_like    INDEX     �   CREATE INDEX timeline_timeline_namespace_26f217ed_like ON public.timeline_timeline USING btree (namespace varchar_pattern_ops);
 =   DROP INDEX public.timeline_timeline_namespace_26f217ed_like;
       public            taiga    false    265            j           1259    318674 %   timeline_timeline_project_id_58d5eadd    INDEX     i   CREATE INDEX timeline_timeline_project_id_58d5eadd ON public.timeline_timeline USING btree (project_id);
 9   DROP INDEX public.timeline_timeline_project_id_58d5eadd;
       public            taiga    false    265            $           1259    319805 1   token_denylist_outstandingtoken_jti_70fa66b5_like    INDEX     �   CREATE INDEX token_denylist_outstandingtoken_jti_70fa66b5_like ON public.token_denylist_outstandingtoken USING btree (jti varchar_pattern_ops);
 E   DROP INDEX public.token_denylist_outstandingtoken_jti_70fa66b5_like;
       public            taiga    false    331            )           1259    319806 0   token_denylist_outstandingtoken_user_id_c6f48986    INDEX        CREATE INDEX token_denylist_outstandingtoken_user_id_c6f48986 ON public.token_denylist_outstandingtoken USING btree (user_id);
 D   DROP INDEX public.token_denylist_outstandingtoken_user_id_c6f48986;
       public            taiga    false    331            T           1259    318562    users_authdata_key_c3b89eef    INDEX     U   CREATE INDEX users_authdata_key_c3b89eef ON public.users_authdata USING btree (key);
 /   DROP INDEX public.users_authdata_key_c3b89eef;
       public            taiga    false    261            U           1259    318563     users_authdata_key_c3b89eef_like    INDEX     n   CREATE INDEX users_authdata_key_c3b89eef_like ON public.users_authdata USING btree (key varchar_pattern_ops);
 4   DROP INDEX public.users_authdata_key_c3b89eef_like;
       public            taiga    false    261            Z           1259    318564    users_authdata_user_id_9625853a    INDEX     ]   CREATE INDEX users_authdata_user_id_9625853a ON public.users_authdata USING btree (user_id);
 3   DROP INDEX public.users_authdata_user_id_9625853a;
       public            taiga    false    261            ~           1259    318041    users_role_project_id_2837f877    INDEX     [   CREATE INDEX users_role_project_id_2837f877 ON public.users_role USING btree (project_id);
 2   DROP INDEX public.users_role_project_id_2837f877;
       public            taiga    false    211                       1259    317712    users_role_slug_ce33b471    INDEX     O   CREATE INDEX users_role_slug_ce33b471 ON public.users_role USING btree (slug);
 ,   DROP INDEX public.users_role_slug_ce33b471;
       public            taiga    false    211            �           1259    317713    users_role_slug_ce33b471_like    INDEX     h   CREATE INDEX users_role_slug_ce33b471_like ON public.users_role USING btree (slug varchar_pattern_ops);
 1   DROP INDEX public.users_role_slug_ce33b471_like;
       public            taiga    false    211            k           1259    318049    users_user_email_243f6e77_like    INDEX     j   CREATE INDEX users_user_email_243f6e77_like ON public.users_user USING btree (email varchar_pattern_ops);
 2   DROP INDEX public.users_user_email_243f6e77_like;
       public            taiga    false    207            p           1259    319823    users_user_upper_idx    INDEX     ^   CREATE INDEX users_user_upper_idx ON public.users_user USING btree (upper('username'::text));
 (   DROP INDEX public.users_user_upper_idx;
       public            taiga    false    207            q           1259    319824    users_user_upper_idx1    INDEX     \   CREATE INDEX users_user_upper_idx1 ON public.users_user USING btree (upper('email'::text));
 )   DROP INDEX public.users_user_upper_idx1;
       public            taiga    false    207            r           1259    318052 !   users_user_username_06e46fe6_like    INDEX     p   CREATE INDEX users_user_username_06e46fe6_like ON public.users_user USING btree (username varchar_pattern_ops);
 5   DROP INDEX public.users_user_username_06e46fe6_like;
       public            taiga    false    207            u           1259    319828    users_user_uuid_6fe513d7_like    INDEX     h   CREATE INDEX users_user_uuid_6fe513d7_like ON public.users_user USING btree (uuid varchar_pattern_ops);
 1   DROP INDEX public.users_user_uuid_6fe513d7_like;
       public            taiga    false    207            0           1259    319852 !   users_workspacerole_slug_2db99758    INDEX     a   CREATE INDEX users_workspacerole_slug_2db99758 ON public.users_workspacerole USING btree (slug);
 5   DROP INDEX public.users_workspacerole_slug_2db99758;
       public            taiga    false    335            1           1259    319853 &   users_workspacerole_slug_2db99758_like    INDEX     z   CREATE INDEX users_workspacerole_slug_2db99758_like ON public.users_workspacerole USING btree (slug varchar_pattern_ops);
 :   DROP INDEX public.users_workspacerole_slug_2db99758_like;
       public            taiga    false    335            4           1259    319854 )   users_workspacerole_workspace_id_30155f00    INDEX     q   CREATE INDEX users_workspacerole_workspace_id_30155f00 ON public.users_workspacerole USING btree (workspace_id);
 =   DROP INDEX public.users_workspacerole_workspace_id_30155f00;
       public            taiga    false    335            5           1259    319873 *   userstorage_storageentry_owner_id_c4c1ffc0    INDEX     s   CREATE INDEX userstorage_storageentry_owner_id_c4c1ffc0 ON public.userstorage_storageentry USING btree (owner_id);
 >   DROP INDEX public.userstorage_storageentry_owner_id_c4c1ffc0;
       public            taiga    false    337                       1259    318228 )   userstories_rolepoints_points_id_cfcc5a79    INDEX     q   CREATE INDEX userstories_rolepoints_points_id_cfcc5a79 ON public.userstories_rolepoints USING btree (points_id);
 =   DROP INDEX public.userstories_rolepoints_points_id_cfcc5a79;
       public            taiga    false    245                       1259    318229 '   userstories_rolepoints_role_id_94ac7663    INDEX     m   CREATE INDEX userstories_rolepoints_role_id_94ac7663 ON public.userstories_rolepoints USING btree (role_id);
 ;   DROP INDEX public.userstories_rolepoints_role_id_94ac7663;
       public            taiga    false    245                       1259    318281 -   userstories_rolepoints_user_story_id_ddb4c558    INDEX     y   CREATE INDEX userstories_rolepoints_user_story_id_ddb4c558 ON public.userstories_rolepoints USING btree (user_story_id);
 A   DROP INDEX public.userstories_rolepoints_user_story_id_ddb4c558;
       public            taiga    false    245                        1259    318261 -   userstories_userstory_assigned_to_id_5ba80653    INDEX     y   CREATE INDEX userstories_userstory_assigned_to_id_5ba80653 ON public.userstories_userstory USING btree (assigned_to_id);
 A   DROP INDEX public.userstories_userstory_assigned_to_id_5ba80653;
       public            taiga    false    247            >           1259    319947 5   userstories_userstory_assigned_users_user_id_6de6e8a7    INDEX     �   CREATE INDEX userstories_userstory_assigned_users_user_id_6de6e8a7 ON public.userstories_userstory_assigned_users USING btree (user_id);
 I   DROP INDEX public.userstories_userstory_assigned_users_user_id_6de6e8a7;
       public            taiga    false    339            ?           1259    319946 :   userstories_userstory_assigned_users_userstory_id_fcb98e26    INDEX     �   CREATE INDEX userstories_userstory_assigned_users_userstory_id_fcb98e26 ON public.userstories_userstory_assigned_users USING btree (userstory_id);
 N   DROP INDEX public.userstories_userstory_assigned_users_userstory_id_fcb98e26;
       public            taiga    false    339            !           1259    318262 6   userstories_userstory_generated_from_issue_id_afe43198    INDEX     �   CREATE INDEX userstories_userstory_generated_from_issue_id_afe43198 ON public.userstories_userstory USING btree (generated_from_issue_id);
 J   DROP INDEX public.userstories_userstory_generated_from_issue_id_afe43198;
       public            taiga    false    247            "           1259    319948 5   userstories_userstory_generated_from_task_id_8e958d43    INDEX     �   CREATE INDEX userstories_userstory_generated_from_task_id_8e958d43 ON public.userstories_userstory USING btree (generated_from_task_id);
 I   DROP INDEX public.userstories_userstory_generated_from_task_id_8e958d43;
       public            taiga    false    247            #           1259    318263 +   userstories_userstory_milestone_id_37f31d22    INDEX     u   CREATE INDEX userstories_userstory_milestone_id_37f31d22 ON public.userstories_userstory USING btree (milestone_id);
 ?   DROP INDEX public.userstories_userstory_milestone_id_37f31d22;
       public            taiga    false    247            $           1259    318264 '   userstories_userstory_owner_id_df53c64e    INDEX     m   CREATE INDEX userstories_userstory_owner_id_df53c64e ON public.userstories_userstory USING btree (owner_id);
 ;   DROP INDEX public.userstories_userstory_owner_id_df53c64e;
       public            taiga    false    247            '           1259    318265 )   userstories_userstory_project_id_03e85e9c    INDEX     q   CREATE INDEX userstories_userstory_project_id_03e85e9c ON public.userstories_userstory USING btree (project_id);
 =   DROP INDEX public.userstories_userstory_project_id_03e85e9c;
       public            taiga    false    247            (           1259    318260 "   userstories_userstory_ref_824701c0    INDEX     c   CREATE INDEX userstories_userstory_ref_824701c0 ON public.userstories_userstory USING btree (ref);
 6   DROP INDEX public.userstories_userstory_ref_824701c0;
       public            taiga    false    247            )           1259    318266 (   userstories_userstory_status_id_858671dd    INDEX     o   CREATE INDEX userstories_userstory_status_id_858671dd ON public.userstories_userstory USING btree (status_id);
 <   DROP INDEX public.userstories_userstory_status_id_858671dd;
       public            taiga    false    247            *           1259    319959 *   userstories_userstory_swimlane_id_8ecab79d    INDEX     s   CREATE INDEX userstories_userstory_swimlane_id_8ecab79d ON public.userstories_userstory USING btree (swimlane_id);
 >   DROP INDEX public.userstories_userstory_swimlane_id_8ecab79d;
       public            taiga    false    247            @           1259    319998 #   votes_vote_content_type_id_c8375fe1    INDEX     e   CREATE INDEX votes_vote_content_type_id_c8375fe1 ON public.votes_vote USING btree (content_type_id);
 7   DROP INDEX public.votes_vote_content_type_id_c8375fe1;
       public            taiga    false    341            E           1259    319999    votes_vote_user_id_24a74629    INDEX     U   CREATE INDEX votes_vote_user_id_24a74629 ON public.votes_vote USING btree (user_id);
 /   DROP INDEX public.votes_vote_user_id_24a74629;
       public            taiga    false    341            F           1259    320005 $   votes_votes_content_type_id_29583576    INDEX     g   CREATE INDEX votes_votes_content_type_id_29583576 ON public.votes_votes USING btree (content_type_id);
 8   DROP INDEX public.votes_votes_content_type_id_29583576;
       public            taiga    false    343            M           1259    320039 $   webhooks_webhook_project_id_76846b5e    INDEX     g   CREATE INDEX webhooks_webhook_project_id_76846b5e ON public.webhooks_webhook USING btree (project_id);
 8   DROP INDEX public.webhooks_webhook_project_id_76846b5e;
       public            taiga    false    345            P           1259    320045 '   webhooks_webhooklog_webhook_id_646c2008    INDEX     m   CREATE INDEX webhooks_webhooklog_webhook_id_646c2008 ON public.webhooks_webhooklog USING btree (webhook_id);
 ;   DROP INDEX public.webhooks_webhooklog_webhook_id_646c2008;
       public            taiga    false    347            ~           1259    318941    wiki_wikilink_href_46ee8855    INDEX     U   CREATE INDEX wiki_wikilink_href_46ee8855 ON public.wiki_wikilink USING btree (href);
 /   DROP INDEX public.wiki_wikilink_href_46ee8855;
       public            taiga    false    273                       1259    318942     wiki_wikilink_href_46ee8855_like    INDEX     n   CREATE INDEX wiki_wikilink_href_46ee8855_like ON public.wiki_wikilink USING btree (href varchar_pattern_ops);
 4   DROP INDEX public.wiki_wikilink_href_46ee8855_like;
       public            taiga    false    273            �           1259    318943 !   wiki_wikilink_project_id_7dc700d7    INDEX     a   CREATE INDEX wiki_wikilink_project_id_7dc700d7 ON public.wiki_wikilink USING btree (project_id);
 5   DROP INDEX public.wiki_wikilink_project_id_7dc700d7;
       public            taiga    false    273            �           1259    318961 '   wiki_wikipage_last_modifier_id_38be071c    INDEX     m   CREATE INDEX wiki_wikipage_last_modifier_id_38be071c ON public.wiki_wikipage USING btree (last_modifier_id);
 ;   DROP INDEX public.wiki_wikipage_last_modifier_id_38be071c;
       public            taiga    false    275            �           1259    318962    wiki_wikipage_owner_id_f1f6c5fd    INDEX     ]   CREATE INDEX wiki_wikipage_owner_id_f1f6c5fd ON public.wiki_wikipage USING btree (owner_id);
 3   DROP INDEX public.wiki_wikipage_owner_id_f1f6c5fd;
       public            taiga    false    275            �           1259    318963 !   wiki_wikipage_project_id_03a1e2ca    INDEX     a   CREATE INDEX wiki_wikipage_project_id_03a1e2ca ON public.wiki_wikipage USING btree (project_id);
 5   DROP INDEX public.wiki_wikipage_project_id_03a1e2ca;
       public            taiga    false    275            �           1259    318959    wiki_wikipage_slug_10d80dc1    INDEX     U   CREATE INDEX wiki_wikipage_slug_10d80dc1 ON public.wiki_wikipage USING btree (slug);
 /   DROP INDEX public.wiki_wikipage_slug_10d80dc1;
       public            taiga    false    275            �           1259    318960     wiki_wikipage_slug_10d80dc1_like    INDEX     n   CREATE INDEX wiki_wikipage_slug_10d80dc1_like ON public.wiki_wikipage USING btree (slug varchar_pattern_ops);
 4   DROP INDEX public.wiki_wikipage_slug_10d80dc1_like;
       public            taiga    false    275            �           1259    319543 )   workspaces_workspace_name_id_69b27cd8_idx    INDEX     n   CREATE INDEX workspaces_workspace_name_id_69b27cd8_idx ON public.workspaces_workspace USING btree (name, id);
 =   DROP INDEX public.workspaces_workspace_name_id_69b27cd8_idx;
       public            taiga    false    312    312            �           1259    319542 &   workspaces_workspace_owner_id_d8b120c0    INDEX     k   CREATE INDEX workspaces_workspace_owner_id_d8b120c0 ON public.workspaces_workspace USING btree (owner_id);
 :   DROP INDEX public.workspaces_workspace_owner_id_d8b120c0;
       public            taiga    false    312            �           1259    319541 '   workspaces_workspace_slug_c37054a2_like    INDEX     |   CREATE INDEX workspaces_workspace_slug_c37054a2_like ON public.workspaces_workspace USING btree (slug varchar_pattern_ops);
 ;   DROP INDEX public.workspaces_workspace_slug_c37054a2_like;
       public            taiga    false    312            U           1259    320095 /   workspaces_workspacemembership_user_id_091e94f3    INDEX     }   CREATE INDEX workspaces_workspacemembership_user_id_091e94f3 ON public.workspaces_workspacemembership USING btree (user_id);
 C   DROP INDEX public.workspaces_workspacemembership_user_id_091e94f3;
       public            taiga    false    349            V           1259    320096 4   workspaces_workspacemembership_workspace_id_d634b215    INDEX     �   CREATE INDEX workspaces_workspacemembership_workspace_id_d634b215 ON public.workspaces_workspacemembership USING btree (workspace_id);
 H   DROP INDEX public.workspaces_workspacemembership_workspace_id_d634b215;
       public            taiga    false    349            W           1259    320097 9   workspaces_workspacemembership_workspace_role_id_39c459bf    INDEX     �   CREATE INDEX workspaces_workspacemembership_workspace_role_id_39c459bf ON public.workspaces_workspacemembership USING btree (workspace_role_id);
 M   DROP INDEX public.workspaces_workspacemembership_workspace_role_id_39c459bf;
       public            taiga    false    349            �           2620    319241 ^   custom_attributes_epiccustomattribute update_epiccustomvalues_after_remove_epiccustomattribute    TRIGGER       CREATE TRIGGER update_epiccustomvalues_after_remove_epiccustomattribute AFTER DELETE ON public.custom_attributes_epiccustomattribute FOR EACH ROW EXECUTE FUNCTION public.clean_key_in_custom_attributes_values('epic_id', 'epics_epic', 'custom_attributes_epiccustomattributesvalues');
 w   DROP TRIGGER update_epiccustomvalues_after_remove_epiccustomattribute ON public.custom_attributes_epiccustomattribute;
       public          taiga    false    294    399            �           2620    319210 a   custom_attributes_issuecustomattribute update_issuecustomvalues_after_remove_issuecustomattribute    TRIGGER     !  CREATE TRIGGER update_issuecustomvalues_after_remove_issuecustomattribute AFTER DELETE ON public.custom_attributes_issuecustomattribute FOR EACH ROW EXECUTE FUNCTION public.clean_key_in_custom_attributes_values('issue_id', 'issues_issue', 'custom_attributes_issuecustomattributesvalues');
 z   DROP TRIGGER update_issuecustomvalues_after_remove_issuecustomattribute ON public.custom_attributes_issuecustomattribute;
       public          taiga    false    399    282            �           2620    319050 4   epics_epic update_project_tags_colors_on_epic_insert    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_epic_insert AFTER INSERT ON public.epics_epic FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 M   DROP TRIGGER update_project_tags_colors_on_epic_insert ON public.epics_epic;
       public          taiga    false    278    385            �           2620    319049 4   epics_epic update_project_tags_colors_on_epic_update    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_epic_update AFTER UPDATE ON public.epics_epic FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 M   DROP TRIGGER update_project_tags_colors_on_epic_update ON public.epics_epic;
       public          taiga    false    278    385            �           2620    318797 7   issues_issue update_project_tags_colors_on_issue_insert    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_issue_insert AFTER INSERT ON public.issues_issue FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 P   DROP TRIGGER update_project_tags_colors_on_issue_insert ON public.issues_issue;
       public          taiga    false    243    385            �           2620    318796 7   issues_issue update_project_tags_colors_on_issue_update    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_issue_update AFTER UPDATE ON public.issues_issue FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 P   DROP TRIGGER update_project_tags_colors_on_issue_update ON public.issues_issue;
       public          taiga    false    243    385            �           2620    318795 4   tasks_task update_project_tags_colors_on_task_insert    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_task_insert AFTER INSERT ON public.tasks_task FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 M   DROP TRIGGER update_project_tags_colors_on_task_insert ON public.tasks_task;
       public          taiga    false    259    385            �           2620    318794 4   tasks_task update_project_tags_colors_on_task_update    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_task_update AFTER UPDATE ON public.tasks_task FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 M   DROP TRIGGER update_project_tags_colors_on_task_update ON public.tasks_task;
       public          taiga    false    385    259            �           2620    318793 D   userstories_userstory update_project_tags_colors_on_userstory_insert    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_userstory_insert AFTER INSERT ON public.userstories_userstory FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 ]   DROP TRIGGER update_project_tags_colors_on_userstory_insert ON public.userstories_userstory;
       public          taiga    false    385    247            �           2620    318792 D   userstories_userstory update_project_tags_colors_on_userstory_update    TRIGGER     �   CREATE TRIGGER update_project_tags_colors_on_userstory_update AFTER UPDATE ON public.userstories_userstory FOR EACH ROW EXECUTE FUNCTION public.update_project_tags_colors();
 ]   DROP TRIGGER update_project_tags_colors_on_userstory_update ON public.userstories_userstory;
       public          taiga    false    247    385            �           2620    319209 ^   custom_attributes_taskcustomattribute update_taskcustomvalues_after_remove_taskcustomattribute    TRIGGER       CREATE TRIGGER update_taskcustomvalues_after_remove_taskcustomattribute AFTER DELETE ON public.custom_attributes_taskcustomattribute FOR EACH ROW EXECUTE FUNCTION public.clean_key_in_custom_attributes_values('task_id', 'tasks_task', 'custom_attributes_taskcustomattributesvalues');
 w   DROP TRIGGER update_taskcustomvalues_after_remove_taskcustomattribute ON public.custom_attributes_taskcustomattribute;
       public          taiga    false    284    399            �           2620    319208 j   custom_attributes_userstorycustomattribute update_userstorycustomvalues_after_remove_userstorycustomattrib    TRIGGER     <  CREATE TRIGGER update_userstorycustomvalues_after_remove_userstorycustomattrib AFTER DELETE ON public.custom_attributes_userstorycustomattribute FOR EACH ROW EXECUTE FUNCTION public.clean_key_in_custom_attributes_values('user_story_id', 'userstories_userstory', 'custom_attributes_userstorycustomattributesvalues');
 �   DROP TRIGGER update_userstorycustomvalues_after_remove_userstorycustomattrib ON public.custom_attributes_userstorycustomattribute;
       public          taiga    false    399    286            r           2606    317960 Q   attachments_attachment attachments_attachme_content_type_id_35dd9d5d_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.attachments_attachment
    ADD CONSTRAINT attachments_attachme_content_type_id_35dd9d5d_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 {   ALTER TABLE ONLY public.attachments_attachment DROP CONSTRAINT attachments_attachme_content_type_id_35dd9d5d_fk_django_co;
       public          taiga    false    205    3434    233            s           2606    317970 L   attachments_attachment attachments_attachme_project_id_50714f52_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.attachments_attachment
    ADD CONSTRAINT attachments_attachme_project_id_50714f52_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.attachments_attachment DROP CONSTRAINT attachments_attachme_project_id_50714f52_fk_projects_;
       public          taiga    false    233    215    3493            t           2606    317979 P   attachments_attachment attachments_attachment_owner_id_720defb8_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.attachments_attachment
    ADD CONSTRAINT attachments_attachment_owner_id_720defb8_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.attachments_attachment DROP CONSTRAINT attachments_attachment_owner_id_720defb8_fk_users_user_id;
       public          taiga    false    233    3439    207            v           2606    318027 O   auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm;
       public          taiga    false    3574    239    235            w           2606    318022 P   auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id;
       public          taiga    false    3579    237    239            u           2606    318013 E   auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 o   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co;
       public          taiga    false    3434    235    205            �           2606    318889 T   contact_contactentry contact_contactentry_project_id_27bfec4e_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.contact_contactentry
    ADD CONSTRAINT contact_contactentry_project_id_27bfec4e_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.contact_contactentry DROP CONSTRAINT contact_contactentry_project_id_27bfec4e_fk_projects_project_id;
       public          taiga    false    215    3493    271            �           2606    318894 K   contact_contactentry contact_contactentry_user_id_f1f19c5f_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.contact_contactentry
    ADD CONSTRAINT contact_contactentry_user_id_f1f19c5f_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.contact_contactentry DROP CONSTRAINT contact_contactentry_user_id_f1f19c5f_fk_users_user_id;
       public          taiga    false    3439    271    207            �           2606    319248 _   custom_attributes_epiccustomattributesvalues custom_attributes_ep_epic_id_d413e57a_fk_epics_epi    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues
    ADD CONSTRAINT custom_attributes_ep_epic_id_d413e57a_fk_epics_epi FOREIGN KEY (epic_id) REFERENCES public.epics_epic(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_epiccustomattributesvalues DROP CONSTRAINT custom_attributes_ep_epic_id_d413e57a_fk_epics_epi;
       public          taiga    false    296    278    3735            �           2606    319242 [   custom_attributes_epiccustomattribute custom_attributes_ep_project_id_ad2cfaa8_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute
    ADD CONSTRAINT custom_attributes_ep_project_id_ad2cfaa8_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_epiccustomattribute DROP CONSTRAINT custom_attributes_ep_project_id_ad2cfaa8_fk_projects_;
       public          taiga    false    294    215    3493            �           2606    319185 a   custom_attributes_issuecustomattributesvalues custom_attributes_is_issue_id_868161f8_fk_issues_is    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues
    ADD CONSTRAINT custom_attributes_is_issue_id_868161f8_fk_issues_is FOREIGN KEY (issue_id) REFERENCES public.issues_issue(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_issuecustomattributesvalues DROP CONSTRAINT custom_attributes_is_issue_id_868161f8_fk_issues_is;
       public          taiga    false    3602    243    288            �           2606    319128 \   custom_attributes_issuecustomattribute custom_attributes_is_project_id_3b4acff5_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute
    ADD CONSTRAINT custom_attributes_is_project_id_3b4acff5_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_issuecustomattribute DROP CONSTRAINT custom_attributes_is_project_id_3b4acff5_fk_projects_;
       public          taiga    false    3493    215    282            �           2606    319134 [   custom_attributes_taskcustomattribute custom_attributes_ta_project_id_f0f622a8_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute
    ADD CONSTRAINT custom_attributes_ta_project_id_f0f622a8_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_taskcustomattribute DROP CONSTRAINT custom_attributes_ta_project_id_f0f622a8_fk_projects_;
       public          taiga    false    3493    284    215            �           2606    319190 _   custom_attributes_taskcustomattributesvalues custom_attributes_ta_task_id_3d1ccf5e_fk_tasks_tas    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues
    ADD CONSTRAINT custom_attributes_ta_task_id_3d1ccf5e_fk_tasks_tas FOREIGN KEY (task_id) REFERENCES public.tasks_task(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_taskcustomattributesvalues DROP CONSTRAINT custom_attributes_ta_task_id_3d1ccf5e_fk_tasks_tas;
       public          taiga    false    290    259    3663            �           2606    319140 `   custom_attributes_userstorycustomattribute custom_attributes_us_project_id_2619cf6c_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute
    ADD CONSTRAINT custom_attributes_us_project_id_2619cf6c_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattribute DROP CONSTRAINT custom_attributes_us_project_id_2619cf6c_fk_projects_;
       public          taiga    false    3493    215    286            �           2606    319195 j   custom_attributes_userstorycustomattributesvalues custom_attributes_us_user_story_id_99b10c43_fk_userstori    FK CONSTRAINT     �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues
    ADD CONSTRAINT custom_attributes_us_user_story_id_99b10c43_fk_userstori FOREIGN KEY (user_story_id) REFERENCES public.userstories_userstory(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.custom_attributes_userstorycustomattributesvalues DROP CONSTRAINT custom_attributes_us_user_story_id_99b10c43_fk_userstori;
       public          taiga    false    292    247    3622            X           2606    317689 G   django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 q   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co;
       public          taiga    false    209    205    3434            Y           2606    317694 C   django_admin_log django_admin_log_user_id_c564eba6_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 m   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_user_id_c564eba6_fk_users_user_id;
       public          taiga    false    209    207    3439            �           2606    319359 N   easy_thumbnails_thumbnail easy_thumbnails_thum_source_id_5b57bc77_fk_easy_thum    FK CONSTRAINT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnail
    ADD CONSTRAINT easy_thumbnails_thum_source_id_5b57bc77_fk_easy_thum FOREIGN KEY (source_id) REFERENCES public.easy_thumbnails_source(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.easy_thumbnails_thumbnail DROP CONSTRAINT easy_thumbnails_thum_source_id_5b57bc77_fk_easy_thum;
       public          taiga    false    301    3791    299            �           2606    319381 [   easy_thumbnails_thumbnaildimensions easy_thumbnails_thum_thumbnail_id_c3a0c549_fk_easy_thum    FK CONSTRAINT     �   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions
    ADD CONSTRAINT easy_thumbnails_thum_thumbnail_id_c3a0c549_fk_easy_thum FOREIGN KEY (thumbnail_id) REFERENCES public.easy_thumbnails_thumbnail(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.easy_thumbnails_thumbnaildimensions DROP CONSTRAINT easy_thumbnails_thum_thumbnail_id_c3a0c549_fk_easy_thum;
       public          taiga    false    303    3801    301            �           2606    319407 >   epics_epic epics_epic_assigned_to_id_13e08004_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.epics_epic
    ADD CONSTRAINT epics_epic_assigned_to_id_13e08004_fk_users_user_id FOREIGN KEY (assigned_to_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 h   ALTER TABLE ONLY public.epics_epic DROP CONSTRAINT epics_epic_assigned_to_id_13e08004_fk_users_user_id;
       public          taiga    false    207    3439    278            �           2606    319056 8   epics_epic epics_epic_owner_id_b09888c4_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.epics_epic
    ADD CONSTRAINT epics_epic_owner_id_b09888c4_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 b   ALTER TABLE ONLY public.epics_epic DROP CONSTRAINT epics_epic_owner_id_b09888c4_fk_users_user_id;
       public          taiga    false    3439    278    207            �           2606    319061 @   epics_epic epics_epic_project_id_d98aaef7_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.epics_epic
    ADD CONSTRAINT epics_epic_project_id_d98aaef7_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.epics_epic DROP CONSTRAINT epics_epic_project_id_d98aaef7_fk_projects_project_id;
       public          taiga    false    3493    215    278            �           2606    319066 B   epics_epic epics_epic_status_id_4cf3af1a_fk_projects_epicstatus_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.epics_epic
    ADD CONSTRAINT epics_epic_status_id_4cf3af1a_fk_projects_epicstatus_id FOREIGN KEY (status_id) REFERENCES public.projects_epicstatus(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.epics_epic DROP CONSTRAINT epics_epic_status_id_4cf3af1a_fk_projects_epicstatus_id;
       public          taiga    false    3698    278    269            �           2606    319081 O   epics_relateduserstory epics_relatedusersto_user_story_id_329a951c_fk_userstori    FK CONSTRAINT     �   ALTER TABLE ONLY public.epics_relateduserstory
    ADD CONSTRAINT epics_relatedusersto_user_story_id_329a951c_fk_userstori FOREIGN KEY (user_story_id) REFERENCES public.userstories_userstory(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.epics_relateduserstory DROP CONSTRAINT epics_relatedusersto_user_story_id_329a951c_fk_userstori;
       public          taiga    false    280    3622    247            �           2606    319076 O   epics_relateduserstory epics_relateduserstory_epic_id_57605230_fk_epics_epic_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.epics_relateduserstory
    ADD CONSTRAINT epics_relateduserstory_epic_id_57605230_fk_epics_epic_id FOREIGN KEY (epic_id) REFERENCES public.epics_epic(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.epics_relateduserstory DROP CONSTRAINT epics_relateduserstory_epic_id_57605230_fk_epics_epic_id;
       public          taiga    false    3735    278    280            �           2606    319434 X   external_apps_applicationtoken external_apps_applic_application_id_0e934655_fk_external_    FK CONSTRAINT     �   ALTER TABLE ONLY public.external_apps_applicationtoken
    ADD CONSTRAINT external_apps_applic_application_id_0e934655_fk_external_ FOREIGN KEY (application_id) REFERENCES public.external_apps_application(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.external_apps_applicationtoken DROP CONSTRAINT external_apps_applic_application_id_0e934655_fk_external_;
       public          taiga    false    306    304    3811            �           2606    319439 Q   external_apps_applicationtoken external_apps_applic_user_id_6e2f1e8a_fk_users_use    FK CONSTRAINT     �   ALTER TABLE ONLY public.external_apps_applicationtoken
    ADD CONSTRAINT external_apps_applic_user_id_6e2f1e8a_fk_users_use FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 {   ALTER TABLE ONLY public.external_apps_applicationtoken DROP CONSTRAINT external_apps_applic_user_id_6e2f1e8a_fk_users_use;
       public          taiga    false    306    3439    207            �           2606    319025 T   history_historyentry history_historyentry_project_id_9b008f70_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.history_historyentry
    ADD CONSTRAINT history_historyentry_project_id_9b008f70_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.history_historyentry DROP CONSTRAINT history_historyentry_project_id_9b008f70_fk_projects_project_id;
       public          taiga    false    3493    215    276            z           2606    318125 B   issues_issue issues_issue_assigned_to_id_c6054289_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_assigned_to_id_c6054289_fk_users_user_id FOREIGN KEY (assigned_to_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_assigned_to_id_c6054289_fk_users_user_id;
       public          taiga    false    243    207    3439            {           2606    318130 J   issues_issue issues_issue_milestone_id_3c2695ee_fk_milestones_milestone_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_milestone_id_3c2695ee_fk_milestones_milestone_id FOREIGN KEY (milestone_id) REFERENCES public.milestones_milestone(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_milestone_id_3c2695ee_fk_milestones_milestone_id;
       public          taiga    false    241    3592    243            |           2606    318135 <   issues_issue issues_issue_owner_id_5c361b47_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_owner_id_5c361b47_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 f   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_owner_id_5c361b47_fk_users_user_id;
       public          taiga    false    243    3439    207            }           2606    318768 F   issues_issue issues_issue_priority_id_93842a93_fk_projects_priority_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_priority_id_93842a93_fk_projects_priority_id FOREIGN KEY (priority_id) REFERENCES public.projects_priority(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_priority_id_93842a93_fk_projects_priority_id;
       public          taiga    false    243    223    3532            ~           2606    318145 D   issues_issue issues_issue_project_id_4b0f3e2f_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_project_id_4b0f3e2f_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_project_id_4b0f3e2f_fk_projects_project_id;
       public          taiga    false    3493    215    243                       2606    319470 F   issues_issue issues_issue_severity_id_695dade0_fk_projects_severity_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_severity_id_695dade0_fk_projects_severity_id FOREIGN KEY (severity_id) REFERENCES public.projects_severity(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_severity_id_695dade0_fk_projects_severity_id;
       public          taiga    false    3542    227    243            �           2606    319475 G   issues_issue issues_issue_status_id_64473cf1_fk_projects_issuestatus_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_status_id_64473cf1_fk_projects_issuestatus_id FOREIGN KEY (status_id) REFERENCES public.projects_issuestatus(id) DEFERRABLE INITIALLY DEFERRED;
 q   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_status_id_64473cf1_fk_projects_issuestatus_id;
       public          taiga    false    217    3513    243            �           2606    319480 C   issues_issue issues_issue_type_id_c1063362_fk_projects_issuetype_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.issues_issue
    ADD CONSTRAINT issues_issue_type_id_c1063362_fk_projects_issuetype_id FOREIGN KEY (type_id) REFERENCES public.projects_issuetype(id) DEFERRABLE INITIALLY DEFERRED;
 m   ALTER TABLE ONLY public.issues_issue DROP CONSTRAINT issues_issue_type_id_c1063362_fk_projects_issuetype_id;
       public          taiga    false    3522    243    219            �           2606    318715 H   likes_like likes_like_content_type_id_8ffc2116_fk_django_content_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.likes_like
    ADD CONSTRAINT likes_like_content_type_id_8ffc2116_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 r   ALTER TABLE ONLY public.likes_like DROP CONSTRAINT likes_like_content_type_id_8ffc2116_fk_django_content_type_id;
       public          taiga    false    205    267    3434            �           2606    318720 7   likes_like likes_like_user_id_aae4c421_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.likes_like
    ADD CONSTRAINT likes_like_user_id_aae4c421_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 a   ALTER TABLE ONLY public.likes_like DROP CONSTRAINT likes_like_user_id_aae4c421_fk_users_user_id;
       public          taiga    false    3439    207    267            x           2606    318076 L   milestones_milestone milestones_milestone_owner_id_216ba23b_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.milestones_milestone
    ADD CONSTRAINT milestones_milestone_owner_id_216ba23b_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.milestones_milestone DROP CONSTRAINT milestones_milestone_owner_id_216ba23b_fk_users_user_id;
       public          taiga    false    207    3439    241            y           2606    318081 T   milestones_milestone milestones_milestone_project_id_6151cb75_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.milestones_milestone
    ADD CONSTRAINT milestones_milestone_project_id_6151cb75_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.milestones_milestone DROP CONSTRAINT milestones_milestone_project_id_6151cb75_fk_projects_project_id;
       public          taiga    false    241    3493    215            �           2606    319490 w   notifications_historychangenotification_history_entries notifications_histor_historychangenotific_65e52ffd_fk_notificat    FK CONSTRAINT     +  ALTER TABLE ONLY public.notifications_historychangenotification_history_entries
    ADD CONSTRAINT notifications_histor_historychangenotific_65e52ffd_fk_notificat FOREIGN KEY (historychangenotification_id) REFERENCES public.notifications_historychangenotification(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries DROP CONSTRAINT notifications_histor_historychangenotific_65e52ffd_fk_notificat;
       public          taiga    false    3637    253    251            �           2606    319500 t   notifications_historychangenotification_notify_users notifications_histor_historychangenotific_d8e98e97_fk_notificat    FK CONSTRAINT     (  ALTER TABLE ONLY public.notifications_historychangenotification_notify_users
    ADD CONSTRAINT notifications_histor_historychangenotific_d8e98e97_fk_notificat FOREIGN KEY (historychangenotification_id) REFERENCES public.notifications_historychangenotification(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users DROP CONSTRAINT notifications_histor_historychangenotific_d8e98e97_fk_notificat;
       public          taiga    false    251    3637    255            �           2606    319485 r   notifications_historychangenotification_history_entries notifications_histor_historyentry_id_ad550852_fk_history_h    FK CONSTRAINT       ALTER TABLE ONLY public.notifications_historychangenotification_history_entries
    ADD CONSTRAINT notifications_histor_historyentry_id_ad550852_fk_history_h FOREIGN KEY (historyentry_id) REFERENCES public.history_historyentry(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_historychangenotification_history_entries DROP CONSTRAINT notifications_histor_historyentry_id_ad550852_fk_history_h;
       public          taiga    false    276    3730    253            �           2606    318390 [   notifications_historychangenotification notifications_histor_owner_id_6f63be8a_fk_users_use    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification
    ADD CONSTRAINT notifications_histor_owner_id_6f63be8a_fk_users_use FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_historychangenotification DROP CONSTRAINT notifications_histor_owner_id_6f63be8a_fk_users_use;
       public          taiga    false    251    207    3439            �           2606    318395 ]   notifications_historychangenotification notifications_histor_project_id_52cf5e2b_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification
    ADD CONSTRAINT notifications_histor_project_id_52cf5e2b_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_historychangenotification DROP CONSTRAINT notifications_histor_project_id_52cf5e2b_fk_projects_;
       public          taiga    false    3493    215    251            �           2606    319495 g   notifications_historychangenotification_notify_users notifications_histor_user_id_f7bd2448_fk_users_use    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users
    ADD CONSTRAINT notifications_histor_user_id_f7bd2448_fk_users_use FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_historychangenotification_notify_users DROP CONSTRAINT notifications_histor_user_id_f7bd2448_fk_users_use;
       public          taiga    false    207    3439    255            �           2606    318333 P   notifications_notifypolicy notifications_notify_project_id_aa5da43f_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_notifypolicy
    ADD CONSTRAINT notifications_notify_project_id_aa5da43f_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.notifications_notifypolicy DROP CONSTRAINT notifications_notify_project_id_aa5da43f_fk_projects_;
       public          taiga    false    249    3493    215            �           2606    318338 W   notifications_notifypolicy notifications_notifypolicy_user_id_2902cbeb_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_notifypolicy
    ADD CONSTRAINT notifications_notifypolicy_user_id_2902cbeb_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_notifypolicy DROP CONSTRAINT notifications_notifypolicy_user_id_2902cbeb_fk_users_user_id;
       public          taiga    false    207    249    3439            �           2606    318444 P   notifications_watched notifications_watche_content_type_id_7b3ab729_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_watched
    ADD CONSTRAINT notifications_watche_content_type_id_7b3ab729_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.notifications_watched DROP CONSTRAINT notifications_watche_content_type_id_7b3ab729_fk_django_co;
       public          taiga    false    3434    205    257            �           2606    318454 K   notifications_watched notifications_watche_project_id_c88baa46_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_watched
    ADD CONSTRAINT notifications_watche_project_id_c88baa46_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.notifications_watched DROP CONSTRAINT notifications_watche_project_id_c88baa46_fk_projects_;
       public          taiga    false    215    3493    257            �           2606    318449 M   notifications_watched notifications_watched_user_id_1bce1955_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_watched
    ADD CONSTRAINT notifications_watched_user_id_1bce1955_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 w   ALTER TABLE ONLY public.notifications_watched DROP CONSTRAINT notifications_watched_user_id_1bce1955_fk_users_user_id;
       public          taiga    false    207    257    3439            �           2606    319519 ]   notifications_webnotification notifications_webnotification_user_id_f32287d5_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications_webnotification
    ADD CONSTRAINT notifications_webnotification_user_id_f32287d5_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.notifications_webnotification DROP CONSTRAINT notifications_webnotification_user_id_f32287d5_fk_users_user_id;
       public          taiga    false    3439    310    207            �           2606    318821 R   projects_epicstatus projects_epicstatus_project_id_d2c43c29_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_epicstatus
    ADD CONSTRAINT projects_epicstatus_project_id_d2c43c29_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.projects_epicstatus DROP CONSTRAINT projects_epicstatus_project_id_d2c43c29_fk_projects_project_id;
       public          taiga    false    269    3493    215            �           2606    319579 K   projects_issueduedate projects_issueduedat_project_id_ec077eb7_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_issueduedate
    ADD CONSTRAINT projects_issueduedat_project_id_ec077eb7_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.projects_issueduedate DROP CONSTRAINT projects_issueduedat_project_id_ec077eb7_fk_projects_;
       public          taiga    false    314    215    3493            k           2606    317864 T   projects_issuestatus projects_issuestatus_project_id_1988ebf4_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_issuestatus
    ADD CONSTRAINT projects_issuestatus_project_id_1988ebf4_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.projects_issuestatus DROP CONSTRAINT projects_issuestatus_project_id_1988ebf4_fk_projects_project_id;
       public          taiga    false    215    3493    217            l           2606    317870 P   projects_issuetype projects_issuetype_project_id_e831e4ae_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_issuetype
    ADD CONSTRAINT projects_issuetype_project_id_e831e4ae_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.projects_issuetype DROP CONSTRAINT projects_issuetype_project_id_e831e4ae_fk_projects_project_id;
       public          taiga    false    3493    215    219            [           2606    318315 O   projects_membership projects_membership_invited_by_id_a2c6c913_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_membership
    ADD CONSTRAINT projects_membership_invited_by_id_a2c6c913_fk_users_user_id FOREIGN KEY (invited_by_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.projects_membership DROP CONSTRAINT projects_membership_invited_by_id_a2c6c913_fk_users_user_id;
       public          taiga    false    3439    213    207            \           2606    317756 R   projects_membership projects_membership_project_id_5f65bf3f_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_membership
    ADD CONSTRAINT projects_membership_project_id_5f65bf3f_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.projects_membership DROP CONSTRAINT projects_membership_project_id_5f65bf3f_fk_projects_project_id;
       public          taiga    false    3493    215    213            ]           2606    317762 I   projects_membership projects_membership_role_id_c4bd36ef_fk_users_role_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_membership
    ADD CONSTRAINT projects_membership_role_id_c4bd36ef_fk_users_role_id FOREIGN KEY (role_id) REFERENCES public.users_role(id) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.projects_membership DROP CONSTRAINT projects_membership_role_id_c4bd36ef_fk_users_role_id;
       public          taiga    false    3453    213    211            ^           2606    317750 I   projects_membership projects_membership_user_id_13374535_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_membership
    ADD CONSTRAINT projects_membership_user_id_13374535_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.projects_membership DROP CONSTRAINT projects_membership_user_id_13374535_fk_users_user_id;
       public          taiga    false    3439    213    207            m           2606    317876 J   projects_points projects_points_project_id_3b8f7b42_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_points
    ADD CONSTRAINT projects_points_project_id_3b8f7b42_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.projects_points DROP CONSTRAINT projects_points_project_id_3b8f7b42_fk_projects_project_id;
       public          taiga    false    215    3493    221            n           2606    317882 N   projects_priority projects_priority_project_id_936c75b2_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_priority
    ADD CONSTRAINT projects_priority_project_id_936c75b2_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.projects_priority DROP CONSTRAINT projects_priority_project_id_936c75b2_fk_projects_project_id;
       public          taiga    false    3493    223    215            _           2606    318833 L   projects_project projects_project_creation_template_id_b5a97819_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_creation_template_id_b5a97819_fk_projects_ FOREIGN KEY (creation_template_id) REFERENCES public.projects_projecttemplate(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_creation_template_id_b5a97819_fk_projects_;
       public          taiga    false    225    3537    215            `           2606    318826 L   projects_project projects_project_default_epic_status__1915e581_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_epic_status__1915e581_fk_projects_ FOREIGN KEY (default_epic_status_id) REFERENCES public.projects_epicstatus(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_epic_status__1915e581_fk_projects_;
       public          taiga    false    215    269    3698            a           2606    317913 L   projects_project projects_project_default_issue_status_6aebe7fd_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_issue_status_6aebe7fd_fk_projects_ FOREIGN KEY (default_issue_status_id) REFERENCES public.projects_issuestatus(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_issue_status_6aebe7fd_fk_projects_;
       public          taiga    false    217    3513    215            b           2606    317918 L   projects_project projects_project_default_issue_type_i_89e9b202_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_issue_type_i_89e9b202_fk_projects_ FOREIGN KEY (default_issue_type_id) REFERENCES public.projects_issuetype(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_issue_type_i_89e9b202_fk_projects_;
       public          taiga    false    215    219    3522            c           2606    317923 I   projects_project projects_project_default_points_id_6c6701c2_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_points_id_6c6701c2_fk_projects_ FOREIGN KEY (default_points_id) REFERENCES public.projects_points(id) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_points_id_6c6701c2_fk_projects_;
       public          taiga    false    215    3527    221            d           2606    317928 K   projects_project projects_project_default_priority_id_498ad5e0_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_priority_id_498ad5e0_fk_projects_ FOREIGN KEY (default_priority_id) REFERENCES public.projects_priority(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_priority_id_498ad5e0_fk_projects_;
       public          taiga    false    3532    223    215            e           2606    317933 K   projects_project projects_project_default_severity_id_34b7fa94_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_severity_id_34b7fa94_fk_projects_ FOREIGN KEY (default_severity_id) REFERENCES public.projects_severity(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_severity_id_34b7fa94_fk_projects_;
       public          taiga    false    227    3542    215            f           2606    319645 K   projects_project projects_project_default_swimlane_id_14643d1a_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_swimlane_id_14643d1a_fk_projects_ FOREIGN KEY (default_swimlane_id) REFERENCES public.projects_swimlane(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_swimlane_id_14643d1a_fk_projects_;
       public          taiga    false    215    320    3848            g           2606    317938 L   projects_project projects_project_default_task_status__3be95fee_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_task_status__3be95fee_fk_projects_ FOREIGN KEY (default_task_status_id) REFERENCES public.projects_taskstatus(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_task_status__3be95fee_fk_projects_;
       public          taiga    false    3547    215    229            h           2606    317943 L   projects_project projects_project_default_us_status_id_cc989d55_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_default_us_status_id_cc989d55_fk_projects_ FOREIGN KEY (default_us_status_id) REFERENCES public.projects_userstorystatus(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_default_us_status_id_cc989d55_fk_projects_;
       public          taiga    false    3556    215    231            i           2606    319599 D   projects_project projects_project_owner_id_b940de39_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_owner_id_b940de39_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_owner_id_b940de39_fk_users_user_id;
       public          taiga    false    3439    215    207            j           2606    319653 D   projects_project projects_project_workspace_id_7ea54f67_fk_workspace    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_project
    ADD CONSTRAINT projects_project_workspace_id_7ea54f67_fk_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces_workspace(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.projects_project DROP CONSTRAINT projects_project_workspace_id_7ea54f67_fk_workspace;
       public          taiga    false    215    312    3828            �           2606    318630 S   projects_projectmodulesconfig projects_projectmodu_project_id_eff1c253_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_projectmodulesconfig
    ADD CONSTRAINT projects_projectmodu_project_id_eff1c253_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 }   ALTER TABLE ONLY public.projects_projectmodulesconfig DROP CONSTRAINT projects_projectmodu_project_id_eff1c253_fk_projects_;
       public          taiga    false    215    263    3493            o           2606    317889 N   projects_severity projects_severity_project_id_9ab920cd_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_severity
    ADD CONSTRAINT projects_severity_project_id_9ab920cd_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.projects_severity DROP CONSTRAINT projects_severity_project_id_9ab920cd_fk_projects_project_id;
       public          taiga    false    227    3493    215            �           2606    319615 N   projects_swimlane projects_swimlane_project_id_06871cf8_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_swimlane
    ADD CONSTRAINT projects_swimlane_project_id_06871cf8_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.projects_swimlane DROP CONSTRAINT projects_swimlane_project_id_06871cf8_fk_projects_project_id;
       public          taiga    false    215    3493    320            �           2606    319629 U   projects_swimlaneuserstorystatus projects_swimlaneuse_status_id_2f3fda91_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus
    ADD CONSTRAINT projects_swimlaneuse_status_id_2f3fda91_fk_projects_ FOREIGN KEY (status_id) REFERENCES public.projects_userstorystatus(id) DEFERRABLE INITIALLY DEFERRED;
    ALTER TABLE ONLY public.projects_swimlaneuserstorystatus DROP CONSTRAINT projects_swimlaneuse_status_id_2f3fda91_fk_projects_;
       public          taiga    false    3556    231    322            �           2606    319634 W   projects_swimlaneuserstorystatus projects_swimlaneuse_swimlane_id_1d3f2b21_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus
    ADD CONSTRAINT projects_swimlaneuse_swimlane_id_1d3f2b21_fk_projects_ FOREIGN KEY (swimlane_id) REFERENCES public.projects_swimlane(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.projects_swimlaneuserstorystatus DROP CONSTRAINT projects_swimlaneuse_swimlane_id_1d3f2b21_fk_projects_;
       public          taiga    false    322    320    3848            �           2606    319585 T   projects_taskduedate projects_taskduedate_project_id_775d850d_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_taskduedate
    ADD CONSTRAINT projects_taskduedate_project_id_775d850d_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.projects_taskduedate DROP CONSTRAINT projects_taskduedate_project_id_775d850d_fk_projects_project_id;
       public          taiga    false    215    3493    316            p           2606    317895 R   projects_taskstatus projects_taskstatus_project_id_8b32b2bb_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_taskstatus
    ADD CONSTRAINT projects_taskstatus_project_id_8b32b2bb_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.projects_taskstatus DROP CONSTRAINT projects_taskstatus_project_id_8b32b2bb_fk_projects_project_id;
       public          taiga    false    229    3493    215            �           2606    319591 O   projects_userstoryduedate projects_userstorydu_project_id_ab7b1680_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_userstoryduedate
    ADD CONSTRAINT projects_userstorydu_project_id_ab7b1680_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.projects_userstoryduedate DROP CONSTRAINT projects_userstorydu_project_id_ab7b1680_fk_projects_;
       public          taiga    false    318    215    3493            q           2606    317901 N   projects_userstorystatus projects_userstoryst_project_id_cdf95c9c_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.projects_userstorystatus
    ADD CONSTRAINT projects_userstoryst_project_id_cdf95c9c_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.projects_userstorystatus DROP CONSTRAINT projects_userstoryst_project_id_cdf95c9c_fk_projects_;
       public          taiga    false    215    231    3493            �           2606    319671 O   references_reference references_reference_content_type_id_c134e05e_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.references_reference
    ADD CONSTRAINT references_reference_content_type_id_c134e05e_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.references_reference DROP CONSTRAINT references_reference_content_type_id_c134e05e_fk_django_co;
       public          taiga    false    324    205    3434            �           2606    319676 T   references_reference references_reference_project_id_00275368_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.references_reference
    ADD CONSTRAINT references_reference_project_id_00275368_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.references_reference DROP CONSTRAINT references_reference_project_id_00275368_fk_projects_project_id;
       public          taiga    false    3493    324    215            �           2606    319703 R   settings_userprojectsettings settings_userproject_project_id_0bc686ce_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.settings_userprojectsettings
    ADD CONSTRAINT settings_userproject_project_id_0bc686ce_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.settings_userprojectsettings DROP CONSTRAINT settings_userproject_project_id_0bc686ce_fk_projects_;
       public          taiga    false    3493    327    215            �           2606    319708 [   settings_userprojectsettings settings_userprojectsettings_user_id_0e7fdc25_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.settings_userprojectsettings
    ADD CONSTRAINT settings_userprojectsettings_user_id_0e7fdc25_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.settings_userprojectsettings DROP CONSTRAINT settings_userprojectsettings_user_id_0e7fdc25_fk_users_user_id;
       public          taiga    false    327    207    3439            �           2606    318481 >   tasks_task tasks_task_assigned_to_id_e8821f61_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_assigned_to_id_e8821f61_fk_users_user_id FOREIGN KEY (assigned_to_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 h   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_assigned_to_id_e8821f61_fk_users_user_id;
       public          taiga    false    259    3439    207            �           2606    318539 F   tasks_task tasks_task_milestone_id_64cc568f_fk_milestones_milestone_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_milestone_id_64cc568f_fk_milestones_milestone_id FOREIGN KEY (milestone_id) REFERENCES public.milestones_milestone(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_milestone_id_64cc568f_fk_milestones_milestone_id;
       public          taiga    false    241    3592    259            �           2606    318491 8   tasks_task tasks_task_owner_id_db3dcc3e_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_owner_id_db3dcc3e_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 b   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_owner_id_db3dcc3e_fk_users_user_id;
       public          taiga    false    259    207    3439            �           2606    318496 @   tasks_task tasks_task_project_id_a2815f0c_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_project_id_a2815f0c_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_project_id_a2815f0c_fk_projects_project_id;
       public          taiga    false    215    3493    259            �           2606    318534 B   tasks_task tasks_task_status_id_899d2b90_fk_projects_taskstatus_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_status_id_899d2b90_fk_projects_taskstatus_id FOREIGN KEY (status_id) REFERENCES public.projects_taskstatus(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_status_id_899d2b90_fk_projects_taskstatus_id;
       public          taiga    false    259    229    3547            �           2606    319744 H   tasks_task tasks_task_user_story_id_47ceaf1d_fk_userstories_userstory_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.tasks_task
    ADD CONSTRAINT tasks_task_user_story_id_47ceaf1d_fk_userstories_userstory_id FOREIGN KEY (user_story_id) REFERENCES public.userstories_userstory(id) DEFERRABLE INITIALLY DEFERRED;
 r   ALTER TABLE ONLY public.tasks_task DROP CONSTRAINT tasks_task_user_story_id_47ceaf1d_fk_userstories_userstory_id;
       public          taiga    false    3622    259    247            �           2606    318665 I   timeline_timeline timeline_timeline_content_type_id_5731a0c6_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.timeline_timeline
    ADD CONSTRAINT timeline_timeline_content_type_id_5731a0c6_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.timeline_timeline DROP CONSTRAINT timeline_timeline_content_type_id_5731a0c6_fk_django_co;
       public          taiga    false    3434    205    265            �           2606    318660 N   timeline_timeline timeline_timeline_data_content_type_id_0689742e_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.timeline_timeline
    ADD CONSTRAINT timeline_timeline_data_content_type_id_0689742e_fk_django_co FOREIGN KEY (data_content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.timeline_timeline DROP CONSTRAINT timeline_timeline_data_content_type_id_0689742e_fk_django_co;
       public          taiga    false    3434    205    265            �           2606    318682 N   timeline_timeline timeline_timeline_project_id_58d5eadd_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.timeline_timeline
    ADD CONSTRAINT timeline_timeline_project_id_58d5eadd_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.timeline_timeline DROP CONSTRAINT timeline_timeline_project_id_58d5eadd_fk_projects_project_id;
       public          taiga    false    265    3493    215            �           2606    319807 R   token_denylist_denylistedtoken token_denylist_denyl_token_id_dca79910_fk_token_den    FK CONSTRAINT     �   ALTER TABLE ONLY public.token_denylist_denylistedtoken
    ADD CONSTRAINT token_denylist_denyl_token_id_dca79910_fk_token_den FOREIGN KEY (token_id) REFERENCES public.token_denylist_outstandingtoken(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.token_denylist_denylistedtoken DROP CONSTRAINT token_denylist_denyl_token_id_dca79910_fk_token_den;
       public          taiga    false    333    3880    331            �           2606    319800 R   token_denylist_outstandingtoken token_denylist_outst_user_id_c6f48986_fk_users_use    FK CONSTRAINT     �   ALTER TABLE ONLY public.token_denylist_outstandingtoken
    ADD CONSTRAINT token_denylist_outst_user_id_c6f48986_fk_users_use FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.token_denylist_outstandingtoken DROP CONSTRAINT token_denylist_outst_user_id_c6f48986_fk_users_use;
       public          taiga    false    3439    207    331            �           2606    318565 ?   users_authdata users_authdata_user_id_9625853a_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.users_authdata
    ADD CONSTRAINT users_authdata_user_id_9625853a_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 i   ALTER TABLE ONLY public.users_authdata DROP CONSTRAINT users_authdata_user_id_9625853a_fk_users_user_id;
       public          taiga    false    3439    207    261            Z           2606    318042 @   users_role users_role_project_id_2837f877_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.users_role
    ADD CONSTRAINT users_role_project_id_2837f877_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 j   ALTER TABLE ONLY public.users_role DROP CONSTRAINT users_role_project_id_2837f877_fk_projects_project_id;
       public          taiga    false    211    215    3493            �           2606    319845 J   users_workspacerole users_workspacerole_workspace_id_30155f00_fk_workspace    FK CONSTRAINT     �   ALTER TABLE ONLY public.users_workspacerole
    ADD CONSTRAINT users_workspacerole_workspace_id_30155f00_fk_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces_workspace(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.users_workspacerole DROP CONSTRAINT users_workspacerole_workspace_id_30155f00_fk_workspace;
       public          taiga    false    312    3828    335            �           2606    319868 T   userstorage_storageentry userstorage_storageentry_owner_id_c4c1ffc0_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstorage_storageentry
    ADD CONSTRAINT userstorage_storageentry_owner_id_c4c1ffc0_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.userstorage_storageentry DROP CONSTRAINT userstorage_storageentry_owner_id_c4c1ffc0_fk_users_user_id;
       public          taiga    false    3439    337    207            �           2606    318282 O   userstories_rolepoints userstories_rolepoin_user_story_id_ddb4c558_fk_userstori    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_rolepoints
    ADD CONSTRAINT userstories_rolepoin_user_story_id_ddb4c558_fk_userstori FOREIGN KEY (user_story_id) REFERENCES public.userstories_userstory(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.userstories_rolepoints DROP CONSTRAINT userstories_rolepoin_user_story_id_ddb4c558_fk_userstori;
       public          taiga    false    245    3622    247            �           2606    318287 V   userstories_rolepoints userstories_rolepoints_points_id_cfcc5a79_fk_projects_points_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_rolepoints
    ADD CONSTRAINT userstories_rolepoints_points_id_cfcc5a79_fk_projects_points_id FOREIGN KEY (points_id) REFERENCES public.projects_points(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.userstories_rolepoints DROP CONSTRAINT userstories_rolepoints_points_id_cfcc5a79_fk_projects_points_id;
       public          taiga    false    221    245    3527            �           2606    318223 O   userstories_rolepoints userstories_rolepoints_role_id_94ac7663_fk_users_role_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_rolepoints
    ADD CONSTRAINT userstories_rolepoints_role_id_94ac7663_fk_users_role_id FOREIGN KEY (role_id) REFERENCES public.users_role(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.userstories_rolepoints DROP CONSTRAINT userstories_rolepoints_role_id_94ac7663_fk_users_role_id;
       public          taiga    false    245    211    3453            �           2606    318309 U   userstories_userstory userstories_userstor_generated_from_issue_afe43198_fk_issues_is    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstor_generated_from_issue_afe43198_fk_issues_is FOREIGN KEY (generated_from_issue_id) REFERENCES public.issues_issue(id) DEFERRABLE INITIALLY DEFERRED;
    ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstor_generated_from_issue_afe43198_fk_issues_is;
       public          taiga    false    3602    247    243            �           2606    319949 U   userstories_userstory userstories_userstor_generated_from_task__8e958d43_fk_tasks_tas    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstor_generated_from_task__8e958d43_fk_tasks_tas FOREIGN KEY (generated_from_task_id) REFERENCES public.tasks_task(id) DEFERRABLE INITIALLY DEFERRED;
    ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstor_generated_from_task__8e958d43_fk_tasks_tas;
       public          taiga    false    3663    247    259            �           2606    318240 M   userstories_userstory userstories_userstor_milestone_id_37f31d22_fk_milestone    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstor_milestone_id_37f31d22_fk_milestone FOREIGN KEY (milestone_id) REFERENCES public.milestones_milestone(id) DEFERRABLE INITIALLY DEFERRED;
 w   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstor_milestone_id_37f31d22_fk_milestone;
       public          taiga    false    241    3592    247            �           2606    318250 K   userstories_userstory userstories_userstor_project_id_03e85e9c_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstor_project_id_03e85e9c_fk_projects_ FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstor_project_id_03e85e9c_fk_projects_;
       public          taiga    false    3493    215    247            �           2606    318255 J   userstories_userstory userstories_userstor_status_id_858671dd_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstor_status_id_858671dd_fk_projects_ FOREIGN KEY (status_id) REFERENCES public.projects_userstorystatus(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstor_status_id_858671dd_fk_projects_;
       public          taiga    false    3556    231    247            �           2606    319960 L   userstories_userstory userstories_userstor_swimlane_id_8ecab79d_fk_projects_    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstor_swimlane_id_8ecab79d_fk_projects_ FOREIGN KEY (swimlane_id) REFERENCES public.projects_swimlane(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstor_swimlane_id_8ecab79d_fk_projects_;
       public          taiga    false    3848    247    320            �           2606    319939 W   userstories_userstory_assigned_users userstories_userstor_user_id_6de6e8a7_fk_users_use    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory_assigned_users
    ADD CONSTRAINT userstories_userstor_user_id_6de6e8a7_fk_users_use FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.userstories_userstory_assigned_users DROP CONSTRAINT userstories_userstor_user_id_6de6e8a7_fk_users_use;
       public          taiga    false    339    207    3439            �           2606    319934 \   userstories_userstory_assigned_users userstories_userstor_userstory_id_fcb98e26_fk_userstori    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory_assigned_users
    ADD CONSTRAINT userstories_userstor_userstory_id_fcb98e26_fk_userstori FOREIGN KEY (userstory_id) REFERENCES public.userstories_userstory(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.userstories_userstory_assigned_users DROP CONSTRAINT userstories_userstor_userstory_id_fcb98e26_fk_userstori;
       public          taiga    false    247    3622    339            �           2606    318230 T   userstories_userstory userstories_userstory_assigned_to_id_5ba80653_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstory_assigned_to_id_5ba80653_fk_users_user_id FOREIGN KEY (assigned_to_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstory_assigned_to_id_5ba80653_fk_users_user_id;
       public          taiga    false    207    3439    247            �           2606    319954 N   userstories_userstory userstories_userstory_owner_id_df53c64e_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.userstories_userstory
    ADD CONSTRAINT userstories_userstory_owner_id_df53c64e_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.userstories_userstory DROP CONSTRAINT userstories_userstory_owner_id_df53c64e_fk_users_user_id;
       public          taiga    false    247    207    3439            �           2606    319988 H   votes_vote votes_vote_content_type_id_c8375fe1_fk_django_content_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.votes_vote
    ADD CONSTRAINT votes_vote_content_type_id_c8375fe1_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 r   ALTER TABLE ONLY public.votes_vote DROP CONSTRAINT votes_vote_content_type_id_c8375fe1_fk_django_content_type_id;
       public          taiga    false    205    341    3434            �           2606    320007 7   votes_vote votes_vote_user_id_24a74629_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.votes_vote
    ADD CONSTRAINT votes_vote_user_id_24a74629_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 a   ALTER TABLE ONLY public.votes_vote DROP CONSTRAINT votes_vote_user_id_24a74629_fk_users_user_id;
       public          taiga    false    207    341    3439            �           2606    320000 J   votes_votes votes_votes_content_type_id_29583576_fk_django_content_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.votes_votes
    ADD CONSTRAINT votes_votes_content_type_id_29583576_fk_django_content_type_id FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.votes_votes DROP CONSTRAINT votes_votes_content_type_id_29583576_fk_django_content_type_id;
       public          taiga    false    343    3434    205            �           2606    320034 L   webhooks_webhook webhooks_webhook_project_id_76846b5e_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.webhooks_webhook
    ADD CONSTRAINT webhooks_webhook_project_id_76846b5e_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.webhooks_webhook DROP CONSTRAINT webhooks_webhook_project_id_76846b5e_fk_projects_project_id;
       public          taiga    false    3493    345    215            �           2606    320040 R   webhooks_webhooklog webhooks_webhooklog_webhook_id_646c2008_fk_webhooks_webhook_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.webhooks_webhooklog
    ADD CONSTRAINT webhooks_webhooklog_webhook_id_646c2008_fk_webhooks_webhook_id FOREIGN KEY (webhook_id) REFERENCES public.webhooks_webhook(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.webhooks_webhooklog DROP CONSTRAINT webhooks_webhooklog_webhook_id_646c2008_fk_webhooks_webhook_id;
       public          taiga    false    347    345    3916            �           2606    318936 F   wiki_wikilink wiki_wikilink_project_id_7dc700d7_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wiki_wikilink
    ADD CONSTRAINT wiki_wikilink_project_id_7dc700d7_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.wiki_wikilink DROP CONSTRAINT wiki_wikilink_project_id_7dc700d7_fk_projects_project_id;
       public          taiga    false    215    273    3493            �           2606    318944 F   wiki_wikipage wiki_wikipage_last_modifier_id_38be071c_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wiki_wikipage
    ADD CONSTRAINT wiki_wikipage_last_modifier_id_38be071c_fk_users_user_id FOREIGN KEY (last_modifier_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.wiki_wikipage DROP CONSTRAINT wiki_wikipage_last_modifier_id_38be071c_fk_users_user_id;
       public          taiga    false    207    275    3439            �           2606    318949 >   wiki_wikipage wiki_wikipage_owner_id_f1f6c5fd_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wiki_wikipage
    ADD CONSTRAINT wiki_wikipage_owner_id_f1f6c5fd_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 h   ALTER TABLE ONLY public.wiki_wikipage DROP CONSTRAINT wiki_wikipage_owner_id_f1f6c5fd_fk_users_user_id;
       public          taiga    false    207    275    3439            �           2606    318954 F   wiki_wikipage wiki_wikipage_project_id_03a1e2ca_fk_projects_project_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wiki_wikipage
    ADD CONSTRAINT wiki_wikipage_project_id_03a1e2ca_fk_projects_project_id FOREIGN KEY (project_id) REFERENCES public.projects_project(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.wiki_wikipage DROP CONSTRAINT wiki_wikipage_project_id_03a1e2ca_fk_projects_project_id;
       public          taiga    false    3493    275    215            �           2606    319536 L   workspaces_workspace workspaces_workspace_owner_id_d8b120c0_fk_users_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.workspaces_workspace
    ADD CONSTRAINT workspaces_workspace_owner_id_d8b120c0_fk_users_user_id FOREIGN KEY (owner_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.workspaces_workspace DROP CONSTRAINT workspaces_workspace_owner_id_d8b120c0_fk_users_user_id;
       public          taiga    false    207    3439    312            �           2606    320078 Q   workspaces_workspacemembership workspaces_workspace_user_id_091e94f3_fk_users_use    FK CONSTRAINT     �   ALTER TABLE ONLY public.workspaces_workspacemembership
    ADD CONSTRAINT workspaces_workspace_user_id_091e94f3_fk_users_use FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;
 {   ALTER TABLE ONLY public.workspaces_workspacemembership DROP CONSTRAINT workspaces_workspace_user_id_091e94f3_fk_users_use;
       public          taiga    false    207    3439    349            �           2606    320083 V   workspaces_workspacemembership workspaces_workspace_workspace_id_d634b215_fk_workspace    FK CONSTRAINT     �   ALTER TABLE ONLY public.workspaces_workspacemembership
    ADD CONSTRAINT workspaces_workspace_workspace_id_d634b215_fk_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces_workspace(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.workspaces_workspacemembership DROP CONSTRAINT workspaces_workspace_workspace_id_d634b215_fk_workspace;
       public          taiga    false    3828    349    312            �           2606    320088 [   workspaces_workspacemembership workspaces_workspace_workspace_role_id_39c459bf_fk_users_wor    FK CONSTRAINT     �   ALTER TABLE ONLY public.workspaces_workspacemembership
    ADD CONSTRAINT workspaces_workspace_workspace_role_id_39c459bf_fk_users_wor FOREIGN KEY (workspace_role_id) REFERENCES public.users_workspacerole(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.workspaces_workspacemembership DROP CONSTRAINT workspaces_workspace_workspace_role_id_39c459bf_fk_users_wor;
       public          taiga    false    349    3887    335            �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �   �
  xڍ��r�:���S�	nY��z�3ۙͭ�Rlu��m�l�Sy��H�8 ����E~e$!�"��p����6�/��1�׬�L��!/-u���]��eO�y\"ֵ![[��4~IrmA�	^����-+����y��Q�w�zD�w��������8_����ۘU�	ߴ���}�`���,⽃�/�ψ��
�
^?F�^k�ʋ�e���}d̻��]c�z�.xt��w���w�X�̳}̋:��w���B�{�rϮ!g�c��=�=k�c�?�RL���q����n8 &���u����1��_^���br�^�� ��_v Lm�m����=<���iX���~}^�J�iļL�ٌ�w�I���YϘ��5�?���x�.�F;�JLg%��F1��ƻi`�+�@��,�}0ι	h��G��&a%���)4�Dā�P�����P��Ș��c�����[����j�V@�m�k3I����hJJ����,)���2���x�>O�e<�ȭ5��%"2S*?<%���)!DrJf��D��y:�]a��My#�\����h�<<��va�l��ZǾ��6�� X�����XX�G�mrX,��e�.��m�?>�[V�Ր[�F$��� -r��� �n!H���$g��}��x\�­��1o��!�'w���ސ8�2����pԚm�sM~��|d�sͶ������G!Q��B ���k���vWv���u{�5�賃�1�诃��[B�Wr$��麘�e�=�:F�g���/��G��3�'�D�p���򝕵���9�r&2�"����L�����g#s~:��d����yX���p����
�����T	�(��2�05p��=��7�4��C+�����<Q0�D�P��?V�Ѵ��xn�^�|��"�"�{������"1��_D+qְ��o�>�<l;i���dp$�&>�(%�U��������T\���<>�C��=+:�������
	m@Fd�OE��!cD�(�{)��Kd g�?��1�=~6�>���6�[u���ɿ�b/�D�� x�"ޏY�"��+�x�=���ɣ<��e�6�'^T�2Ƣ��"\�X�`��Ƃ(m0^���B��!y�D��@aI�BP���4B&�m���Ʉ�[��qBau:��V&V�A�k�����]��g�4p�
1*΀�2P� !��!�
�a"mV{�s�=Ym��P4(m�J�1m+��U뗐�$^�����x�G��p�uh0�,}!I0�ea*��%1D]a�x�~|��\vòܧ��a����}yQ%��)���Ķ>es�6���)�#��J�J-oB���Z�Δr�6Ѩ\�29U�h�ܚ2r��w�\�m�2�j;��ܛ2�`m����)kqNVְ.����R�"r���ٜ��z�A�k��@B�?۬^���!��f�*���f�����֪~+��V�2��v0���eL����d��!���B����l��c���N���_2/�0�����f���7��1��p%O2:aT�L�R�,�n�ᘣM4꼓2'm���@)�0����o��i��&�m^�4��b�b�������,b��������x���ܤt��jw�����,5+��Fd{��#�4�͕)�9[_�e�������hp��u����"+�E�Wi�("�T�����^��#}��+�e�@^���[�GK�+R���9�{&͕���0�?u�g����c<e��~�G��}���d ҧ� B��}g���-�۰��h4"��d�R�,�R� b%��S:7*��aR�p���@�jw"���!Y�"�������C�����(g���/�(���O�^"������fժ������R��M��OxD�!�OxB� ;T�]	�V�\0�^��N�P{a!pc�Z�E�#+ �X��h�:f�;o���O�H�V��V��k�K� �}_P�����ө��k?,�Q��u� Q�w��l��(�~��Ms�Pu������EE��2Tk�8*ڤġz�Ģ����j���}il�p��l,e�7��V���.�p'+𥼚t���T�7k�j��6J�+B�Q�]��Ta�d�ve�1���8�fW�L�!>���p�4H-WN�y�%Y�tG���J�������t�`��`��̿"|�7 G���9����8�o�����P"�H�-�"nK+,�&�tk*s���6���t���9/eES��g�%��g��K"�����M���e�>��5��B��;*��M�����V���p/���H�L��G��CX�>�2b]?L�!ֵ	]4L���L�Ja�@�
Z�ѹL��L�1kݚG�1��
FE�"J9�Q�W]�`����8�ކ��M[�R��MeyMK�˱JD�Vy�cĴ�؁Ċ�������Ǽ�e-�x���"��Ȼ{�bWOm�=TŞ�W���F�L�!넃K'�$�$^���V�K4���N�L��V�J6�!y%y%����w�W8����X���l�"q�.���t.���в%�G",T����B<<a�Nݶ�z9f��(���x��J��+��� "p�
�+	�
`�XI �'`�N%A���y_<�%pOy)�'��_�D42Fs	�Xd�}�%>�}</o�a:g���@�󐤴��l�0%f���.5�iOw'�����f�Ⱥ�t�����t?��#��"����;��r�B;��z����b��e\�έ��:�Nny�R��&�r/�T��8��MrR�v�J��_y���$�u      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      j      xڋ���� � �      f   �  xڕUђ� }&sGT��˝�PM+���]��FE�jwf�����D8���Y��S�)�!^��5C	+����{t����l�V�U�4k̓Xv����W����������e�3z	�A%�-�7V>��}q�9�A}�P��r���;/u��c� ���U�*0�_���U�=}��[UJ?��ӟ��\�ޚ,�cv7
�V=��x~�:S-:��]=�/���T���_^�Z�1��h��(�	�o�ՀTN�8~)�t��&�o�t�2V��]�?qw	�=p��������>���=U�J��Dg�X��������i3�w��K�	]tW�U���R��@H�7�-�[�aOU=�7Ĺ'f��Hݧl�����ft�]�+?�~�f�Y���}��4f�xu����j5�&m�-k�i��T���S���
RqT���e�(\Y���v2�9kUC�M+��4S��
�ew�NQ;{�	�D|i�y����vV�o�l�H�2&CO���fg"�6�WY�e���jԼ�46A/�U�,.�H��_�0�#jm�i�._[{+`���U���bvG�n�l6!�K����4n KO=��ד�{v�5��2 �Y��I�� vnJ7+J7^}=t7M�f��r�l"���ʊ���9� [��2dJOO�� �?����      d      xڕ\�v㸎}vż�:^$�kˬ��؊�S�dl']5_? IK��:�P�؅-���J���ӭ?�n>��J)���4܆�a
�_J��i�7���_m���V�/X}]��Ĉ�Ep�����=:1�t��Vz��]�����6_�s���dO�!c�	'��6��p>u�;�~��-�@�
F��Xn�5���FEBVQ;Y:z ��~�y9�������}�Ah�J��`��js�m�G���'���Tz�VsIHz��G�?�����w�C�]e��9j=G�qVimhֈZ�U>���T V����
c�+�9�������	���h��ܸ�+�we�,�b� �^���|��#�"#9o�r�)����贲O�4�d��?8�_��E�ߤ�PY���aE��xmh�)ڈ�Y���_���r�W���ʎ��ݡ?��oIXFǨ�V�:ܱ�`����f8��A4�vz�15��t���Fo�Ydo0b�㰹�������	���GGg�_�e<�tZ�M���J f�e)ߛð��Ηk����r�t��z���';�Q�dt`G� j畞]�t��F����EHA��'�ߡ�*P����sL��du��u��I�;r���T&)��j6E:�S��G�meq�7�a���M-���Q�~�F�9��I�1�Ϗ��,�:et�!Va}�jF+T�\Q�2]�{��ކ����W{}��E����8���|�D(�b��)���Z$C�9,Q�LX"#y��?���c�J��B!n20s����Η�Ә�h<q��@�>2�����C	�F�Al;��A�rŻ=i��»��'�X��n�A|�����]ˁ<�{�O�^�󨳚��B�&�l�J֎����A�=,NKȁ^��w��,�9��������Z�)�3�h�:����Ƙ��Z���7����I��{�m'&u_6ݍ�'�+�V��mx�I��m"р2����!�𵔧S�IV�R��ӎ�+���)x�d�V� �w#�&DC~.@`��K�+�>�ݮ?� ��O ��8�Cm?6'�S��e���]w~@��8 29~���o����H���G����m?m;��Q�L!�ܫ�{�*�r� �%���Y�#��2���~؋(�lB	�����g��2^��m�d�K?�蒓8=2ktj�$��q%K�.]P�'��cei��!��I�.ȱ���*�I�����0� ـeW&��I�7�d�1�$qO�z���N��n=I�?N@k �s@��Oz3�_�,��E�'�S/RԲx�P�&�P�'߮$q�V�!g.�b�������<Cڻ�X#�Qܤ�G'�k:��W=��p�éuaH�|a&!�x��NG%"�������7tlJ�;7A奛!<"��� �q9> �H���	̤��[w<ﾈ�r��.z,B11$��Ml&�W/#�V^ц���T�a�=hg��Q!'�>6����4��K�<`P���������'���(�grtU�R�|�k :�dZ�1N������W���7�(؉x�Amr��P"	C���ߜ�S�<�	�u2��X�n��%]S�:��И�n�Y�4x�\!��C�i<W��5��K5/�g�xQD@J�}�Eh�:�KY�x��`h���KU�ؔ���-��`s>cݔ�%! /�L#66
�2��s�/#8�!�-bc�P+�ӊ8x�D�b��6�	�2_Z"D2��.���7DN#)ϓ"�����,���̒.�������xP����Z6	�)f$Î��$�y��tU�{r>��s�dU���*����k8��m�ϟ�^ ���qu~�/�'��X�� �G�+@U�ڒ�b@��!��&Q��8��gY8Rz���1G�Z�$�(�Ec=�!{DLidw���v���*c8ou�<4�����؋�2^�ʕ55��v�{;������b�ld��Dэ �+�������c�a,��r>������M�D�6���v;�PCP�$��"��k�q�+�tв�9
�nLՌ���)wz��y�q��f{�:�dp���Ѝ��g1q#"�b!�!tc��4�w�d���uc�F��)���(�j �� G��Q� �N�w�خ��e�?�
�ޝvUi���d�`�s���W0���>Q �H,* �,#5k�Ј�#�X�e9���Xmn�
�ݭ4+䇼Ҭ��X Zkt\���ٚi1�Ip������"њ|6�Z�o���;@�͚Xb�W
�Dh �X�dBG����4k��ucd�z[��˴S��[R�����v2J����n�Wm}�<-D1��u�.w���6���C���7��R[{ʍ)��0�W6��Rk
�VL��{�R�-�8Sks�B(��7A�r�>��l��Vir��Id�!�)DH�������5�)���̬Rˌ�P|)�h4��_��c���9�Qf�T������ڮ-�<��э8�?̽e�r�q*��dw�菽,={éJ����u���?_Nj*i\��I#��|SՉ*�ٹ�Z�,O:+�n��b��;ڌ��y���n��z��5܇+-V^�'�+��NN�q'�&n���{:9/��M2��+Y`w9sͦj�悁՝�;!�e\�r�/)�6�x�Q��!k�۾XNf�H�K�atwd&�XH<��Y�����d�ܚSւ��v��r�h[ʁ���xJ=�g�ϹB]���N�鼯�����,�R��d>q��	��#��2���S�Fḧ́�V2Bp��c� ȹ7��D�4I�=��5�����n<�o�u5,F�0���Mx���mt%��%�J�O�K�#�U>_W�/Z�.��׭_�`NGs��%f������ؕp3��Wc]T�^\O���G��W�1�[��=���"21��*2�鶗��n����l����7YF��oOl�ӕ�w�P~�m.y@�a"��ed,W�9���{d,���9+c-�9~Ma���s2Vh��S�ȃ�x���Xq���H��ڒ�Ͼ�J�e�sX.eL��F����뀮�>i/߳���4��DW��^K<��-�XS��8W�����e,�VT���8�	=Ol��e�^���M��$4<��ɌeV��h�+o8�+�VB�$d7(֋ӈ�re\ԭ���ޯ�ۉ�������L/����n8�'q�.A2E�U@hR�4�
����3���I~a�(����2�I�怴�������@�R#pƄR"	����\pd�1a|S*��P�A�_�C���#V���:@���m�'��>��@>3'��=��|�����~����z���:�f�j?��-�rA�ZK6/�"e���"p��T�6B����+�2������~(Wꊱƚ�l�c	��k��?�h<+�)Q��09�W~���ޑ]PĪ(�� � �⣩�C`�}��dAnve�zd4.�lqMʕjEtS[�n�hT�O����~6�:^���
�.>��f��nȑ�)�6�ǩ/��0�su��l艏8���g_��_���]���?y�?�a���'ݡ��e����d�~����ȝ�� /-P��YE�G��6D!I��cV��/����m��
Gcln�@�Ȳ��\+�"�%ʠlyx[n5��ұ��"�N�*Ϸ�-,+��Y��C.e����&��@"�A���R����DLD�Z"�RF�����U '�]� ,O 䍴�*��j�Z�h�Km�ʙ���p<lN�,�2�%����(8��q�Qe��.��:���}�u��� ��D Lj���IefG�`g�}O�y���?�!����:�tA5mX��G���ve�u������Ҏ\��1L��h`^��A W���1L?&}�����a�*�d@۴�XCh^��"�Q�s��F�75���r�N�y����6��}�x�
"���¬F*��[��W����卝�b��N��n�i�@.���"����&�~�iX���*��$��Ɉ����!�4���)Ұ�C�\e�2J.�`@t��ߖC�������^L�g�H��<�I���@��aP� ] �  �<��/[��eiO*��F�W����[kC���"TA�Ξ�Ȃ�Ʈs!��fG����U�V"yL_�9ՖN@����H� a|g��m����!G&�����c՜\p�� O>A՗�f��)x𲼷�� U_
lyQl>�X�� T��jl-(��Zz��@�w���Q����?�7'�����Q��<2��TM'�i����(j���
 �֖�W60u��q3^y�ZI3�$OL8����U�#�G�H�KG
3��Ny�i�b�H�Z�L��w]�1N������|֝�L��/D5��svv�6���;����du��v�X��`'���~�<�F9V>t;�ضٿ�g����\�7��i�=�^*H�]ɣ�b���	aS���u��#bY���L��H(1R�X4:�˹?G`�&��s�����GM�<m���O�:Ksғ������������_hE���pܗIӦ ����]�Y��>ת�=��jY�b�n*CQ�-y����ITr��![1k��Η����:a!�VAd�����
έx|�%U4\���9?	5S �ӥ��IK�w������ׂ���	���F���/;��]S %)�n��t٤z;CŒ�n L�������e}B�@}���k�H��.�Ӽ�BOA�\�����]��"i~�%d��݌��*����^"a�8�?'�M��'Gi�q�9�9atSͯ�����(�8";�4�g��_�?p퀅      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �   L  x�}�M�7��3��>�@�����?B6���Ux�z�LQ%�d���k��-���/���~��C���ׂ�~T��������*�c۹9���#j�8):ѣN<�0�[0'�h��� Nd
rR=É�����]qJ�Y�2��.������K�,U�O=�  �8���x~���<��S1
� �M� �M"Dr�u )�ݠ�4B�6Z���K�3�������>�N6!ci0<������FΎ�n0ۥƀn�?{�VX����j��Y# Z������$9���@��g8}D(G� G>����'��9���e6m �G��T����F !?pe���Q��� oR��.�oH��ߌ@�	=E��6h�$��rR�	hl����}cP�:�!c�BWd��C�&!gk��� ���d� ��jrZ�T���v��mU��Tj[��>�ݶc;&�<'6������	�R�<1��r���A����5�޾��[�	�/�����E�-K}w��t�����ReiR�����&�l5��+�#��, (����^
DRt�*{H����$��J���KLt|'[�Y��v#��
�j�s��\�㵹�R;��6e��T����8ߓI����Y��bP�}U���ٛ��e�R���wq��̚U$���7���JY}B��/�� �>&���h:%do͚[0(՗����j�BR�������nK� ��sէW��=[��&H��;����&Aw�>�Dқ�����=΁�n�rC ���b�T�ߐ���53^\�ڏx��N>�\��n�V���/]%�' J�(R?J��ΐ��Mz�\7 mVxg��o*�-��v��*�k�B��QF(gAg���&UP'��(B�jgP�*E����R}����H��^�}����Ȩgӆc*�����Q���m�0)ոy��!�sV�)	RϾ�>2�����S��}tg_���z��J��O��CF�#�М%��S�Y�y���N �\R�������R���&Q��uAR�v�j��y����+u�3Gϐ�#�C*��z�D�l�I6D�j��{��塶�x��r�7�?�ܲ~��n�/�wX����E�U��'Н��A���P%ժ�!����FTI�� ��l��ܳ��l׍i+W�ڄg�vOMw��HyHܼR�j,� ���Tej�w"�P'���T�a�L,��_���naj4���s����R�&Q��@>�-�OL�|c��Ԡ�R�K�<!�K^h�CJuJ�wV��c���&��L �[�0�A�Cz'5��y���~@߮8�,�-U���m��<�`M��<ﴆ2z�ʶ�b� ��Z���?����ϤG�}Q:��P�+D�R*�j�:��GQ����nX�Qj1@�\a��u��	@����R�i���µ��`������� 됲b�zú�rD��@!)՞'UT<�@,�&�a��<�M<�֙?NG������ޙr|N��#U������� ��R����B�gsRxzJ�O�t�]D������W^�r���LV���}]J��*yha�J�q˛,dxu�,Z�w��ђ����{X�a��#Ǜ���xK��K:2|due0�R�����5c1T�:��~Q����P����΋: ����VǤ����VB�j��������&��s�)���-��/u�`yj��e�U�!�>���V���'V-�&��Gß��B�J7j��X����h�:�����EM�>�o�I%��P��8�d`Ԯ~����X"�j�<���b�R!��~�~/�u�(�e�f߈��ôו��"V�T��EuX��|��	(�      �      xڋ���� � �      �      xڋ���� � �      �   �  xڕ�1kA��z�S\+������v M��i�C)H��o�7+H�o�)ll�o����9};�Mg|��==թ��%͒���Ϸ�ڿgm��LkE[��������z���������cW�˄]y�����z��n��;��c��<�ϯ}��������ۚ���s�����1K�Ϙ���1�x�,�Di>�"3�D�Yb�Ĝi"�9�����aD�Hf�Hc�U2E�bŜ�"�E7�\�'�aDt���"�E�,\�'�aDs&�4m�pQD�(��&��"�Ew)\�'�aDs&�4�')�T��T�T�W��m�:�-a��P��&,C/'���	��fY[T�-�!�,�E#��l�-��ː-�����[T�-�!�"�ڢ�U�a���2d�=�E#��T��i�e�v�Fmшm�fآ:m��bOmшm�fآ:m��6٩-��e7lQ��X�l���h�B0�n\	P��,Cׂ	�z1�8��3����ۧ�~�	�H��
dkv"�4��W,���(��c\�zv*�4����F��[�q�٩�Ӑ2�+Y�DyE2�5;�uR�TY#Qސe�Ne���q�^�z$��P��T�iHYPe�D�!ʚ��:)� ���H�w$CY�SY�!e=@�5���e�{\�>�>�(�z��|0���q�����NC����F����q��٩�Ӑ2�K�O"��ț�      �   �  x�}�;N$0E��oH�#W��C:�����A@���Z�%��|TV^�����^����y���������<�O�__��˭<�n��Z�Gk�������������:V��N�����I��E�M�-6Y��.3܌�4���P<�ш�F�M����7�F;4��G#�Fs��;�F4z�G#.����W��o_�*~����!�NQTD$e�ƨ�"��˚�ʊ�"v�e]�yeE_�u��eDc6�YVT����`gYZF�f[��eEk�֖�eDo^5�[ԉ�2�77M���e�w�#��XD��M��eEoz��޲����͇{ˊ�2�7�Z�-+zˈ�|i����-#z��޲����͏6{ˊ�2��V��[ԃ�2��f:�-+zˈޚ밷��-��I?΃��      r   y  x�}�Mo7����W�����2MS ��躛"Q�������y�w�Ý!Fz/l�����?,_�w�e�_/??���|z���������y��yp���p9��p�vr��翾�w�����������K?��!�˥O��������SX>���|����ey�z��U����嵜�<�}z�����>��|}I���o��S�<�?��/����]���?�>���)/�?>�||�\�_o��/�r����O��浻�n�n�Y8�����o�Jg�?n�ގ ���#v��Z�$��ϳ|��Q�����m>�8������M>�������`�f���8�o�L*?��<�M~��ͯ]~��{'����,?�=G��-�{��|��q��Q��&ߧ.?��Y�'�_f��˯�����Y�6?`����@������|�A�g��,?w���(?o�Y�g�_���ɯ"?7��u��!�ɏ��c~�������_����eϏI�6?w�u�/2���:˯���F��-?A�W��q~�����O�玻������ R���u�C��mE�ǙT���)��f
�V��	����~���~���Ɵ�_V�k�'�
0��j����2U :�!�9�H�@���`QDK��S��� ,���4X����"9��*<��U��k/B�$����&�S�Ca��
�T!�`!V�B�0�=��N����h�Ct:����$a�'��ƈp
�h��3�6E��0�TD�1�"6-��0^шPdDkF�G#V5���n�pD�?4鈼C��C���$ZA�=!�Ԉ�U$8e$:G�CH��;IIK��h4	*N��a��D�C��0�)*ѩ~�Jl����D�+AK4��W�D�K���\y	�}I�K�)0��a�I�C��C���0)d�E&B�L��D�̤e&�ԙ윉0�&7h"Hi�HAP�h���I�a���c�r<��|��o�x����^<��cT��v����n{s���<l �T��w�q�N�[�(�I�N$O6�DR�d+O����e��'�=���d�O��>��I��C����(�F/P���@yh�
��@�P����@i��@�
4+��4��M�Y���@�4�]�E
�V�E��@�(�@K/P�Z�@yh�
��@�P��Z�@iZ�@�
�(�����M�U��֩@���]�U
�V�U��@�(�@k/P�Z�@yh�
��@��&P:)PV���(��)��(]/P�
�N�[��M�]?��@�ۇ!���w�|J��(��߾݆��%���@��@�&PB
��B��0�@=�0z�zކ��@ɩ@}'Pr(P�	���F���oJ*��V��t:���X�~      t   �  x�u�;N$@�������w
;؜�0��q�^;�/U��R~^��˵�:Vh��s��~��-�!k�mvn�z{���>n���ʥ�k�Z�nB1�	�L&�M4�h��$R�F�H4bwMV,5�2 =Z��HV,M�2!+Z��NV,���5Z��$+�ԭlh�V�ޓKí�V쾒K�k��z�h5gM����ZH�Z�xE�B�`6OXZ��!cl�{���C��d6OYzh�!���5�D93d��<hY�h��4�7-#D͐�f��`��2�l^�V�P����f�U0C��l��޲=��1[H_�5/[f(�!�mmy�ڱB��l6/[V(�!���e��
e3d�ټl]ءl�L6���;�͐�f��`��2�l^v�ءl'���e7�	e3d�ټ�8�l�L���? ~gKK      n     xڍ�I�%������P"8�^�>�6,^<���R�fYY��F�_1~2;������W��??��?�������?L��O�A�ߧ ��<~��|�����7�.9�p����a����P8t�|rtXt9A^9|�rd��rX1���O�i�3'�Q���/?�`�q�D
�r/�^�wLl>�X0z]�w� �r\&���v��ə#49��?
�[��A�yG��� 7�r�z���3�O"���^12ğ |�4_هA�2�a�4q ݘ}]��mL^ˊ1%`y�(r�$�M���Vb�3|2��V�,ab��(%�|�S�ЩlSi�c	��1�����<�΄	,�%i��H��B�ߤ��Ϟ���+MW�{���"��ˁ��53��,��R��Kҽ̑w�)d�����u�=Nv��`V8��p�r0B��t@ִ'�@VT��*e@�Z�C��՞Rt��8u��
����.gDqsɁL%l���7�v����NpA�r���I�ص&e��nL-4���Y�S�(~솒V"�?�꤯��|PA��w�W.���n��
P1�*-Y4�	��f�Э2�˗�6�u�.�:�]t9��疢xKh�O���'Փ�۝�y=1c��pJ
���gTA����h�=�q��|�9��E��dx�:���Z��{��z	��:J	�bR��N,�0��]���Nw��t���R\���t�Wi�w �\�7Pv��qR`���t����@��%;.έ#
?�&g�S���9��d�P@��)�"K\�B'�1\�j3Pc��ٍ�G�u�	��F�ؚzv)�1%!3����s�`��_o�J��>e]S���Y٨4��|���)H����y���
ie}���5��Hg .�R����.'��\s��):�E��o�\6T�${F��1/Y�dSv�� �Q2V�u���:b>�{��m����y�'p,ט�][W���"m
����
s�8Y[s6Wߜ[i�bE
徴�.R%��Vv�=��\�)b=��h���%�u0u1�k����i�§[��(��Vӿ�#�+]�e���s�퟾��p�����sz9q�u!�e������)�KQ^��o�E��n�N-Q�%��+���x����e0u9ӳ���3z�,q1e��V�2���������x��0������v]̵fZ]#��П#WsZ�}����
��O�t˴��2%ݮ�ѥ��
-�M�a��'"�nJ�d�f��)�m�+��J�����_|�|�~F�]x�^��wX��#x�/9"tqj�Ift92.�=5�t��0vb�K���0�a2M<n��&>T���K��-Mb(t1������դ��옘m?U]�� �a�ef����j���y^N�){�����A��r�p�>,ɞ�]�S��Wz[��SrO�}��
��=��,�@�oU����э��`&%qS���i��|2�d�N����sڳވ�����^1[��\fq�r��Ս��(J�5�|T���%+`�U�(���*�sn�&(�^����_ܺ��`�z���65�*)�m�{��ʖ�[y�ۖ�k]a"Z�g�����X*�=LJ�̞nr2j);<s�a���{���NU��h�Gs�%/'���)	��Q�!D�� �J-E�i�O3�K��9L�n��G9o��wz�Kݟŀ��hJ9ߋ�a��������:��B��6��&�X����6e�D�;7�rM7Eq<M'��v�o��M������T
/�7nb*{M�p���1�� ��׷      v   �  x�U�ͱ�8�ѵ�-�_+g����&TS����E�u��g�˿�Ko۲.���/��������~z;����v�W����?�=��?��K_��?�e�l�/�??[ߖ������,[���3��1����g��;&��'?#��k&`�3A��	:�L����]c&�	|�L8�c����	�>f�q3��L�1g��9t͙��3m�L8�1���h&��	�m̄�>f��3�x�L�5g��9�̙��3��\�L8��	��L8�c&�1��	�k̄�]3Ϝ	z�Lg��9�=��./7��ݠ�G�7�^p��8z�q�;~�;v��bǡ����qs�A�8��q��8z���x�q�;ĎC��P�8T;���;�c�8���;���;��wG�8�sǁ�q(v��j���z�q��l���-��kγ��g/:�sөXu2v��e'k���G��]ȍׅw^���{��/x����b��[4 W��z���</�QO�Ӟ�>Q�|��D<��@�g?�O:��t����݇����Dp'�K!�"�Z��E�b�hF�j��!�х�\q��	nH��ё%�ђ\5�rOBŋ�I	nJpT����0�#,9ʒ#-y�u�O�j���ŋj����j����j����l�ζ�'ۢg[Tm��xQm�Qm�Qm��f[t�Eg[�l놪-��/�-��"�-�ں�W�j����l�ζ�l��m=P�E|��E�ET[@���j����h�̶�l�ζ���U[ħ-\l�Qm�Qm�m���m��]mm+��분lKnKp[��ܖ඄ٖm��}D[r�����p[B���%�-�m	nKp[�l�<�-9ڒ�-y����]���/����7��a�z��z�!�M��w:�f�|������4nKȶt��E�nKp[��f[b�%G[r�%W[��-!�����%�-�m	nK�m�іm�і<�:�Xm��xQm�Qm�Qm��m��։�l��m]P�E|��E�ET[D�ET[D�ED[`~ g[t�E϶n��">m��"�-��"�-`~G@D[d�Eg[t�E϶��">m��"�-��7�-��"�-2ۢ�-:ۢg[/Tm��pQ�%�Qm�Qm��m���m��־���_�-]�-�m	nKp[��f[b�%G[t~� W[{�ܖ�m��m	nKp[��ܖ0�"�{9ڒ�-���7�m	ٖ.ܖ��%�-���f[b�%G[r����Z�1]�      x   �  x�m�=j]a���h�͙���kcp��4��@�!M��Q���u���׿ˮ��y<^^/�_߿����}�����;b��}�����0V�.K��K�ԥcɲa�e��e��2�0�ۨ��hM���8��q�)�	[yu�8ڑ��y�t�e��-��vG2>��Q���m�q�O��F������T񊜁ETb�h2�ČQ�YC+�1'l�j��^pcN���Bs"Ǩ�l�蘓:Feg�pǜ�1�<�=�d�Q���(�1'~���o��_��1�?7��s�ǘ..�:����"�?o��?��/�Rޱ
�����U�cN�՟O��s�Ǩ�|a���?F����ǜ�1�??؅?��Q�����$��N�9�cT�q
��_�� �d�<      p      xڽ[[s�F�}�޿���e���\|��^WR[�5���$� (������!Y�IY�R� K$�	s�������+^�ݦ[7����]p�1�E��T���-U�}7?�֍�\EJߵ]_6�7nl��k#�U�VL�T���1� �)���sVj&�^矱H�7��p���/5���'��A���w2����;�}�[��/�R.��2�S4�W+L`A%�N1i%Y�JyN$�KV�!�	kE\��EW������W�����	ˏ��bSׯ�?bߕc���m|,}��]3�ȫ�^խW5{U���/~yY��E,�˫&^���1��=c���CA��}(�A#�.
]�e��(5'QQ����
�b^K[�h.e$F�4�)���b�Q`E�	Ϗ�t�u�'s(�n�u�6b߅���f��Suǩ��T]�e����e�kZ\0��f�ǲ,���l.J����&��8IjW�p�ղ� ��������!�U�zi�ޫ��B��=M\�@d4J(
��6��dt
�kϴ���m������1�v��? S�k�	U蛫�)��6�a��c��q��ܪc���뷿�*^�5��}yk9�VL
~
X{<$��,GPػHx$-�����h�����ާ�j���n����Ղ	M�s����ڳ{�$d~��2��U	K7�7~Ճ-vC9�K��xTw=�٣���i���Ǯ.]?6��e�b[v�
8�}�]�U7l���Xa�P�V� �y,j>��"Lqq�
7�P �n�g�B�5�S��Ľ�L����T2��ZE��;��QH�"��<,9���ծ�ʯ�f[��n{��P!�lB�7y|{�C�>v�>s�n��.���z7c�/�]9��R۰vm�(��B��.p	D#`�n��0.NR�Os�Ɋ`{<ؾ���B2a���E,�\��N1$=�Jb]'�x�5�ab�j�ᜨPK�l"��hi:���6���Sj������fh�+�/��0������U��OJ^W����j,��z��UJ�7$���n���7>.�ד�C���r�R߭O#'��J�CVL� g������3V3z$�����N��	TqNq�� lM��E"�u��D���H���	8}p���L������3�q
>DW����?�^���֫ڤ��T�߻��
�ٔ}w]^C#���QMR��C��}<�%��H��
$;�A�i&��*NYr˜"�y�gub6)�����J �l)�M��O�=��J vY�"G���À�%�r&8���\4uo�
�J���S}�>�To^��;Z��/�p*s&���!	�~՜$)<�ͪ�4�����%�%�B(L�c��e���,���9�\���w!ղA�b�C�X�R�V��m�,���	r�[����o;�ڲYo۸�L#Z����ձ��TO���-��mNm�$��mh.2븮*��d��a�Φ\#a��uV��w'����N�2��8}���B#oYv�B4$ý�����%��&6
^�E-�a"\<�p}d���xOuJٍҩ2ڡΙ�5�����ۮ_��K���
w�S�>����jn|�7��1��;��Z�P�l�1�4(7.���z�L��b<�f�E�D�j��̆�{Dz>�C��0��qjS��S	:.��F�U��@%�49�ւ�4Pb���֩��А���O�����	����4\�6@�aO��D*����.7۫[{u�^}��V=+�������i�����r��[��M�巻p�� !�� �5P|�^�0@���8��d��!�:��$J�/�؈�!p���!�IP�=M��"��u�SP"��Q�Zc���X{qѹ�@�~�ە�Za���&�t��t�:��i+T�-}�����u��U9t�����PKƕ>7�0����P��j쨅!�ڣ�K�7�`��!H�jrǐ�5�5�4	F��Yc����$)M�4�g����S��y�� ~1��v7H�9~�h�-��P}�PM�K�~���=�&�D�߸��(��u��v�h��Y�]u.�m�kY޹8��a�rv,�Q�	��������Bn��v�"<%�4&@*���˚jc�24Ȅ#��(�!̂#J�HR�$��J� :�>lP���	�Mp����t�P��Fp���֣:����Z١�4�*"�� ���n��I��n]7� ��5T�d�^"?�S7hJ�m����Qu@X9��?V-�����q�E0QZzRSF"�4F"e45��'^�6��M\T��;e�qҐ�܃��}�w��G��9�m��M��l��t����ճW/�o�}�wݺ�r-J�Դ�rt�/N?�b��i MV�0��+���JԱ �S�ZM�'2!���{�&���5:���$P�$1��5���L�a����8�$	PGN-�X4��;���\�����*���5 1=� �ϡ[�Ypoc��Ӑ(��C�A���Aq!	��8���xq!��@��kB��	���P
F�FҼ"S"P̈́L$$�����-��sܵ����}����9����ӳ��T}�T���{�Q�]y�U���_u]�u��f���jQ>��:�5�v��7-�ӈa�s�a�����jYx�B�iY�3��yo�W͜e:�9�A�/l�R{�n N�7�Ƞ=7/�����\��ss*�($]�s�rXj�linNiٯ��W���__/]Q����e���]�/���06�$@���-�ݮb��\3��85�uw��0f\	u&NV)�Z���H�d�.��J�#�lJ(I�����������F����.Ԃ9�FQBz{b@h�{a�����ix�w �!'�C�a�c.\6�&�{���톃�:�+�:���\��'6����J��B�ŝA�A%5砀Ui��P|���B+�8=΂yP-��9-�؄ͫ5ĒV�Ռ%��2&Z�LȉTBBI�j�=K����aS+��zyu�:�ە�v����C�ZkS^�6ȎdX݌�E��ClaD�bXyĭ_g���\�����˦��e֗���f���u��W����u����@��,Z\��.t;���j�Nu�:U�N5_���Nu�N��r%�x��R�n��#襝�gX5�,�	�]�ҵ�B^M{�����a7�D,�����ms	B�jZ��q�e]�@z�rH�ˬʜU���k��W-ʏ�}��n�-���O�`�.%R�!�����>��|�p�ޔ!"r�9��X�hv��|	���0��i��Z���f�ӫ��	w7����c&b�_�Ě�M�ri8��f���4�s=Q�J�����vnR�h�_<������B�|�Ka*
6��:B�E����B����Е"2��������B��?�Y��3$e�����9��t�'C��d�~����/�S(�y�6�[WM�e�fADn�˾�z�.��\eg�pi�d�4�7��{�o\����n�g\~bǘ_��Ф}~5}����[��������������j�@.i��a��$"I��*�����!����D�k����DE#8��IV�A���� ��4��I_��m�b
�6��w3�f'��9�e����c��]��w��h^��⸛�����(u���͘��o��ffe�:���e�m��鐗�e��2u:��b��+��م@j8�������p�N&�(- �q��j������'�[�h �3B�j)��7LBk����3�J�D���V�an�V���p�z�������]N�yI���e�w����MS�f��O*!�5;7��ڇ��q�5�� �?m�Ȓ��q�j�U?B�2h���y�[�	5����:��1�N�j������9�]��y�$���������T��������Mw�W�8�-a��`�/���G\3m���n��w��/��G2Ҫ���B�2$$<��OF�y��B��rs��$��u�}-En�$�<�	�8�+d�;������[���{���kc���;���n����F   Ӎ���[���o�.�C�\#��7^v�������=Ē�
b�@��]�IsLR�4HH��gA���G�� d�4ǋ�f�)���Y�yŌ�LX�7&i_ז����ڹ(X�B#�5
~�jOe�7,�Uf�r��e��3����`�����U�ś��}�qj�����	����/YQ�-Ϲ߼(8,`�q��y'�G:إ30Yi?�\��2{q��"���&�HJy�9$Gj��@t0nD�S-n�
%Cp&2mQ�� �[<U�.Q���0��~I$���1��~{�~���g7��1���h<�񯲮�]��M;mw����?����ҟb�<x�3��V� �M�#����j&�O�p�e��8D7cHd�&j�%>EJlD%��t���)k�<����ǯ3��'Ϻ���j��P��nJ�5U��v'��������\9�\��ۜŦ���#9u��x0���ܕ��{��,"$B�W�81���܂I�,�x���q\����hG�4y��}?ot����+�ӷ��06�x�{5��n\͓�E�D���B���lisU{r ���`�U��*�=^NΠ�bDk���������@�!2$�)�tu�Ds�����Գ�M��R�7�-�O$��Ѓ�:�u��&�T��?�V�[����-I�>!un|u�7��ni�8�/��5�׼�Z�LB����F"�:�W|j2Zˍ�D��/2m�.P#��IIk�`�I��n#'(S4� �|�-�ww ~G��k��ɓ��_�      �      xڋ���� � �      z   �  x��X�o�6~v�
�{��lO����K�&�Vt�@��`���F"U�����w�%��S;풢�<�>�������e��T�����H!ERƚ���6s�8�	S��S&$��_HH
T�ɘ��)�ωZ�Ih��	��H	�2��<6�1�2L�%���#�n�Т�V�Z�~@��Q.4��RT��Di��0����3�s�XHY��HS�	g$".s@��#�c��X����z�;QP!7s����KByB��s�"��`T3�������V�3�H\*-r��x~8��a?<���x���y���Л���ǧ��i荦ad�$g��{)�����^�S�W�?%����[�2�K!s���;ؕ�j���e5��FƔ*a�W��rn�P�xWUSu�9���w���i����6�z�LH3�a�M��/F&dF�Wfgq&$8Ni� eKV�2�3�2^f�Z��x���u��de���`�Uz��<���d���a0>��6��y��`�O�G�hPz',C|2l�ؐ�_��§�t!8�@�z�u65d��Z�,���Y��B@-������幍��+Q��k���h'��J��;x�v�6���s���vmU#W�����߲���QZ��v��qK1�'�b�R�ڊSKq�^��{5;!r`����8f}{���]7W}{�B�{���_9�AOu��z:_?�<�ɾK"|�x:�/E^�T�;��!��[�?�^���Bk����M��{ww��$S���%��w�c��P��W�c�j#ۗ��ÙYz�"�;��,q���?�;pf��X5�U���J�-N�� �C9�ܖ�{3ҙ��/݅���S�	<Ȏ�?G�C���zL�&�_������y���{M���]��0��3ӝ`($�B:�Qշ<p���R)yQjz��VV�̱�0�$
��w����3�q�6?MS����z~�n�jD�u6���k@�$�1�l���(�4ԃ\$,]���?�d�
{z3�4��D3tp������Է葾]��,�����~�>ݛ?�u��Hi��p�$1x���7�YRkoR;�+5�b�<�p\�@�h_�izr��T����8��}��yK�&�Ɂ?�z���"�E�1�9
zo(���w��Z��Thz!����)�sCU�r�� �Y
y[���@^,��Y����Xg5ˁ�-���\���p���8�M�9�j�9��o@���(4�� i�4좡D$�"G�)�}MIV��ļaixǍC��90kJ�*2����
*���
,TŴT������V�)�XB	��y���h2�>�jF���j���v�f�jv�f�jv�f�jv�f�j~���7��ٱ��d5w�x���͛ì�N"<��f(����ϲ�;�#X̓o�j~_�fб���qw]d��|��~ttt�K���      |   R  x�uױn1Eњ��%��䖁 .�6M#M��@��#o��N{���i�QN�ί����3�tiK+�%e+���y��.u��vU[������=����j]kz��w<�>���˭^o�o��8���|�ܮ#���bm�\�>�؁�+���z���g�"U���ꈬ�g�"0U�Y��S���٩NUvj@�::w+�S����mE�::���S���ԀNutv[g�"8U�٭�S���٩NUvj@�::�bu�z�g�j���b�x�T�!R�"-�i`q�Ī$V��vk`�j;�UI����X��� V%�r ��X��ś5��X9ka���@�Jb�@�[g�7� V%�r ��b,��A�Jb�@��`�v�X��ʁX�5�Y����*���q�����4��eF��љ=&t���~��3ѽv�����u�y52ٽv����u<��52ٽvM|n����{&�����}a�����=�k�l,loZ�����Ol���]�=��{`��g�X�~h�g�{�>����z��F죳�'>�������62�������T��v�Cp��Lv�]lZ~3��IB�&      �      xڋ���� � �      �      xڋ���� � �      �   �  x�}�;N$0E��oH�#W��C:�����A@���Z�%��|TV^�����^����y���������<�O�__��˭<�n��Z�Gk�������������:V��N�����I��E�M�-6Y��.3܌�4���P<�ш�F�M����7�F;4��G#�Fs��;�F4z�G#.����W��o_�*~����!�NQTD$e�ƨ�"��˚�ʊ�"v�e]�yeE_�u��eDc6�YVT����`gYZF�f[��eEk�֖�eDo^5�[ԉ�2�77M���e�w�#��XD��M��eEoz��޲����͇{ˊ�2�7�Z�-+zˈ�|i����-#z��޲����͏6{ˊ�2��V��[ԃ�2��f:�-+zˈޚ밷��-��I?΃��      ~   �  x�}�Mk�@��ү0�좙�>�4�\z蹗�8%P�bB�}e����|܌w1�<c��
�o�����!M	������1��|��=�~��ˀ��'��4�������?_��^O�����>�z��i�z������p������2��}x����r�����,������z��w���-����|0F���IM�$q�c��H��&-2�G`�ݒt̎����S�ڵ�*iGbsԾ��Y{ۄ�Yl����F������v��i�v �Ѥ��(�-�J;�؜v��uڑ�6iG[�o��J;��v�vZb;�v���v�c;�vj�Uډ��s����4�I;��"�|��U��>�������Mڅ=�Eڥ�Vi�Ӟ�Kn�|�7yϗ��"����6*�%Z�8r���$�%��I�� �r3��J�� p��w��`sg�2��̨s'Ҍ�j�hp�ڌ6w��(so�:wb�(p��w��hsg�2�fϤs'�L���dp�M6wf�$so
M:w��$p�Mwj�dsgM2��Ѭs'"��j�lp�*�6w��,so2�:wb�,p�:�w��lsgB�2�fԢs'J-���bp�R-6wf�"soZ-:w��"����b�!��b"��"W�i�Dz)"b����jV�t�H�
���[a�#l��� ~\0�c7�� ���Z�QK�^*l`m�F5Ů���y;��)n�T/�H�PQq��FIŮ��5yO��*6ׂ^U�����a}7`l���̷ WV� �@�@\06��D>���f]��+�P`�z�
��{?co����i@�@��� �r7�����7��z�E"`J-V�Qk�*�b���#�7P��: ߀������܀�� ��fb��:jb����F�u���븉��6�=�QE׭&6���LlW]�M,w]��X/����ǧq�,@3      �   �  x�}�;N$0E��oH�#W��C:�����A@���Z�%��|TV^�����^����y���������<�O�__��˭<�n��Z�Gk�������������:V��N�����I��E�M�-6Y��.3܌�4���P<�ш�F�M����7�F;4��G#�Fs��;�F4z�G#.����W��o_�*~����!�NQTD$e�ƨ�"��˚�ʊ�"v�e]�yeE_�u��eDc6�YVT����`gYZF�f[��eEk�֖�eDo^5�[ԉ�2�77M���e�w�#��XD��M��eEoz��޲����͇{ˊ�2�7�Z�-+zˈ�|i����-#z��޲����͏6{ˊ�2��V��[ԃ�2��f:�-+zˈޚ밷��-��I?΃��      �   �  xڅ�?oG����)�Vp3�KEv�4.R�1"2q#�� �>��ݽ�{g�4�@��G?-_��.���Oq��~[�}�����������O�-����s����珏OY~�����������������k?������]����r�{;��-���������_��<?��������m��������?=��p���?�OK�x%?<��x}�{y�v�h#�6&����lm�a#����IWrYI����L�Sn;��R����ʸ4L�
X�R�K��T��-u�v�K]]�d-u�R��R�_��������m��GK}Y�RߖFk����R�f�ԗ���K�v�ZnKE�(4�L�°Tf��R���T�(tK�G�,U@�m�)R՝��K)��N)n�:(R�-u�H�.u�Hi\:)��X�T��"�n))ߖzE�\�zS�<,�3�2�U�E�e��E�ۥ�t��w���ty�n5M��8���T��[�U��Z�Ag���fo�.QI��5R��`WҘIa�I ��RJ-��V�b)@���RPx�L���d�3�4S�BQ���E]5Eh�l�
RԺ)�J�Nq��r��)��u��k���OI��Z=%�*�)Ͱ"�O	kE5���u��W%���Uk�d{5FT�z**)^ՌʆW]Ge�U	��y�J*�^�)��^��ʊW5���UWS{Ur*k^��ʶWq�'�,�T�*bը�� ��*Z�Y%�h��jiE��Vڭ����jŭ�Vp�~5��D�FW�,"ۮ1���xe���W�-"��.���_���
`�nV���[=#�W��k;d�q]�P1.�E�0�-��M�x�.�dK��V�1����j�Xś���jw����
��D�Y���W��l5�z�E3ޜ��Ԍw�+�i��|%X3n,�5���%P3v�\�h�-�ș��Xb�f�1H1rX3�-FN׌�#�5�u���߬�5��S�<Z�hV����Y�d�f���k���q��l�2�S�@��W4m��Y�Wc�b]�i7�m�vm���6�f�͂�Y�fkV�,h�m�,ؚ��,L5Cm�Z�C���֬�Y�4۴Y�5۵Y�j��,*��6��f}�E���6��f�i�hj&�6�3��YĚIk��k&}�%���6K�f�i�dj&�6K3��YIk��k&}�%���6K�f�i�dj&�6�3��YƚIk��k&]�}��p8�m���      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      x���[s�� �k�W`��+5đ��v7ۤi��l�L:��IHbL*I�Q:�� ��$�"N,�q�!��+�pDG�B淛/���w�2,�����2�xu��*����#6B>ĞO<�o	�Ep@��?b7HXW��d�*��y�HnQp��q�����M��]���Z1!<@�ZɈoj�v���
��R:�J�]��h��"��M�l�M�ۯO���Ss��7A��Z���K9��_�� �V�,+FG+f2l*#��cˊ���h[���d[3����9���gB���Z~� =^3�P�m�hG�\�*����x.�w�Ufɢz�_"W�l�����,���zϓ,)�<,U^��C�h/�������]>U��'�W�{�k��Rע�rj
ɪ��-�my2���sa�Ʋ��dQ&*3�|/S��L�1�T�r�d��,4�t�JKi�}*<��"��\Bm�۟!Gu�JK���
uQ�=*|
?(�ZU��UQx��&*���e�@�_0�H�(ɣeR�բ�<s�W_�m/�����������p*��<+�C"��0#���6���b=Řx�d��T14m����Ϗ1�z�_�L���{=}�X1�x]��JqXǱt/ǿxdᗍE!�tY����8��B�,�����l�l&�p��갎ci+2�?|��C�����A���GQ$���Rbp��Rͽ4����U����!)Wm��)��{���tE%��A*�Kp�LR�jrb��>R��N��{�u�(ɦ`���c2�]��ꏪ�b���8�9�Z�]::ŵkr�@���Ȯ��,��4=Uhe�{�{�.x~���"�i�xFI�]�lu�'1��R�����Sf�.�m�zMQo�����Cϗ7jr���!L�L�t���\������_�1C�<��CQ7ql�e��INv���G'�vNLD=$��e�q>ɩ5ш��I�8�gp���e�O�I�a���Mc9�؋��Af�X.��R�Zj�˶뢺�۹�۽�����������_袠.��&�Ua�-��έq�ldT?Rn;.t�M��v�SL[u�=ԝ�Ry���*�f��Բ �e-�I���.�m{�|��|z@�[u¼L�T�T>��r��,�e���T�Hʮ�22��{������jB�W��2D��EX��:�Æ��??�o՞aׅ� �붠h�~9:{:vC���]p]x�gۨ#�Y��l��x̉��C"V��l5&�辠�r��qwdދ�#"���Z�btz_�i<6��&ݍ���|��x\��G�0�d*c�\<�y앹�b3nd�hN��`~}���5^u�7[N¯���F2+���2�L-��0M���2�e�6Օ�h�L�W[�.\�}
����N�4Y�/�G��W��Q5vH�����=U��P���K�3T�K�ek�鞪�q��c�J�B(P�^������������VXw{,��=k9w{>�󶱿����^!�")��s�"Ymڢu��w�����翡���������j^��A�̗,ԣ�uo�̓�I$��ú\�K��Ed�q'��w� 	^�vRj�.�?X���G0��n;��^�{���嗏_44� 1N�;��\�ဟ�n���k��Ww`f7u�tO�ո���_p�!�Zp�l*8�g k������|9��	`j�`�鞮�q{近�S�Yo��4�`�{��o�i=�ƄU��{�.�	�Q�����}韰0�����~fW�DE��H���^��ܣ�~�2�c���^�����&�Ĕp�Z)�"�-�0��4W���l���_�|�U?��Z�Q�v	:�����n'GjE�EQoQ�������� [np�V�Z���쌱�렄>$�z��j��AvBjGv�d�L���E�A`5� ;!�#�xL���K�0����[βے�p��qɯ��H�>�V�v�	�����["_�[���L���Ԓ���T�J,p�#�S�zg�m�)/��9���J,��=�<�\��,�-5%�����}K~F�����G]ޛ���te�|�ir��j7�hA.�Ž����>��d��Ə�4̒��'J��aN�\���$�B#�d���n�Ǒ���(�QӲy���M������ϳ0�W��0�|�ʹ�._�ۂ޺��[лg���1=`�:M�$�T93�0�dj�6oD�*��K�Xj��UV���d_���reR=��]wƙښjRtV��s��\(>�����t�ObjK�GtZ�рsT-D��Н�Ӟ�����u�>���6�.3��|�RS�l�8�}���Az�Tp'���T�u�߹��i����p1K"�s�I6���*�m�{�Mq/��{���3?d��Tf��n��f��0�R�t�l��q��P�Բ��S^u����J�xT�������t|��\`Q���o�N�IvHH�GT�+����>X��v=t�x��(�^��Z-D�>)ѷ���$;$$�%*�UZ���c47J��@N�C�@���9�z�
,)�QG��\��$;$5$쥧î��3X���y��ӝ�1E��F�h�S��篢�R��d�{?��Sc3�F�d�]�C�I4��㶨W��E����Y��iƱ�:KT��#��E�����7�x*��f>��ȇ$��X[Di����D#G{
��%��-.G7�Vj��w�'�Y�Gܲ��b��z�$�v;���	������`l1o:V�r�ȱZ�jU���:�c˸�'�!��`r�'��^zc|(��}�'D�SP���հ�����Ő��t ���r�'��^zb��Z��!�P���X��Z#�KoL�V �6��:ҹ��Y�?j��R����%�:r_��J>�B�]q��˓�l����.��Mo[�{L����w�(��(T��r�eØ@��%����rH2�5g%��>�y=b�m�$�Ĉ�>�D��M�6au�P�'�<�#F���	�61b��f���#�/o��uG�9�!xh⏚F�S�5�o���ڶ�_��>h�B����2eRl�"ɴ�o�z{e�uY������u=�&�G��lH'���s�'Q����[����t��֧9�;��lڥ*�h��Bb�v�6�������2��"U�2��(�o������h�z��w���1�K�//���a�ۢ�m�)�޿}����7jr���!L�L�t���\��"�.b�[q!h��������f��IO�����?f�~�Eh��"��a���zLe<�w������*�Յ����7꛷KyD�\��S��d��`j�(,��:��|�'�4	�*+���$��e���Ph���t����$vɮ���ֆ���b�ޘ���Av��Llc�ϊn쟳��d�fb���!?YS��h>r���Ks�P��ڞY䠟m�Q1͆)� m,R�txN�����r�&�&�4�Q�m�p�|h��z�i��BPQ/�����~6�q�gxl��Sc��f��=��A?�̔��͔�?ax�̗�S�^�Űm#b�sK���2�^��	�g1�u~�a[*�Kd�/WK�0�Ȳn$��P�>"��X,�(�;�r�N�)�ZͱZ��j�0(|��#��K5>�4̓�e��2�����24��x{���꽪�ה��(��ɏ�D�����S}t6�M�h��I���?2���1x]˹wR���=Ѝ�D�g�����_@�}�N�ta�΋bv�$��R��,�0���G��Z#K��[>[V� j�p�������l�|�CJQs��LB�\�]+�}��� �Î����;�h�,���[1[q���C�ū���հ���b}����v8W{Wê�a�!ް�~�&5�gur�K���(�E���ȷc�j!3��"��=2��۾��%�ء��k_���7?}�?@�]�O%����(����$�_�]�I���4_�2LR�R˼���t�A��U�;���FLPT��8�Rp��il�Gt�scH �׈p�]1��,j#�{�o�!{c.H=>���
�}���~���aB�6�5��Y�F�r����͹ߤ�֙��y����$�7ѷZ�J���D�}����7Ɇ�M�M 1  ��rJ�Q�Em�{�M�!s�zY��\��Ϣf7H��;[���?��>)Yˑ�W����)W�\E� A�"��iU�&Kx6M��ES�[�6E�MQ�1EÏ�߇��,�Lʙ��B�I��WҢ]	���!�Y5��|��	��3n�ǘc/]�R�irv��Z�f��Y�F�sN}Af�:��m�jub�(c}D�d�v��i!?�j�9�M��>"L�t2sDL`v�8-_P���Ψs���%���i缣�&�~���)�N����
����}���B&�@*K�פ��]2�&�niN#���"Yw��]F� ��9�h���ݫ"�/tl�w,c�9j��vc��<i�y�7����������������Y�h]5�������UG���;T-N�[�M�� ��@(�k?�5�9��\}�� �_���wR�lxI�-~�6����������*e����$yIP,d���'ij(:������Hj��їF�HG[�fu7���vRq�?�4`^d��H?�Z�b�ۊW��w�?�i�3&�y&��E��\�c4̰�c`Rь�?�X����|�23��$շ�"���`�֠9ҁfsN�[�`��G�nq� ��闞��㹓�癟���o�����e�j�Xi�l��{�ʙ~��K��YDa'�~w��j����Y��G
���e4:�/�4�n����R�9�����d�Y~�\�5^���x,�F���B���5e�I�K�?榴��[5;@�)W��He��V��u�*@�W��K��.ŀ`��mc�2d7��onn��'�      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      l   B  x�͘Mk�@�ϫ�R�ڙݕu��C �BQ�u�F���v��ﾲ�~��:�h��
ͣYs�ݮ��Ԥq�M�S���������)nҫ��0�����ƚ�_A�*���������ڦm�t3C�%�m�c������_��9q56x�~99�X����Z��,	���p�Q�%�8
�qTI�h�(�ˁjI ��RQ"�Y+�I"��P!�&2T�$B��4�a�H"8Ԉ��5"��ѐ߱���;�$�]�A�9@H�y M���A�B H%,�D�����	� ( �
0	��*��@�`( �
�	��:��@�`( �
0
��`N(F�D� ��
�Q8�׈�s���0
'�(�K��k��=EsLx�;MsLx���ݿ��1�/�n�\>\ܗ���S9t}�Ӹ��k�S��4���q'�>U����᛾n��M�c|�6�;��W�*��^��DO6�ϳ�'��(��{M�`}>�B��|�)�ϯE�`}��7�y(X(E;@���t۠`A4�����`A4�����`A4��K8Ç޽.��'����      h   �  xڕ�kO"i�?3��d�f��|0�d��"*0���s�V��2;3�̫P�M��u?UwU�inj_|$���"�9���_�l����m~�\^ߕQ��Ȳ��r1�7��>�O:��x^*��W�W�����u����<��6���d`�}��,���th&I8i-�,��F��b�\� B�>#��"/9�P"O������G�����ÒKi0b�-"E�ZꨲZ(�������f�7_�]����_FT�jW�=e��X��km3Z�^�{�r�GJ�N���Ϫ�`�������LN�f��>p����SL�1\�v��gN*%�Ձ	�V��=\�9.nׇ�޺��6�x���חX7�Lr�nW�[�Q2Ӄg=��Z�ү�;�}���
/� |���W�����X�c��ckQtʇ���R%JJB�w{��sX�N���j4G�w��{3�7�<��޸w�/�}�X���͸<�7��dv�5�`���\_� �K� �+�f�s`}΄$���rLD+�#����`-��F����d�����3)��2��]�״7.����<k5/�c�2/-R�v�����t�>0���\2�`O�Ga�L���k��fNT�1f�4RB`�(b�:#���rd���=�_>H\pu.g�s6��½��LX�2ZI�B!�\-�>b��q�w	�>�2�.?��l#<��T|AP�i�vmP������N!��;&��4��F*��PU���|
����5�}56�*�c�E,��2�2-��U���1H���-q����i+M@A
Q���q�jU�������/�w�4�����w^�%���`YR+�Q N8�<���>,��aF��J%/�:���Jӊ�@�C2�^0�[[�=��f��V�_�Fƞi�$��G#Ai%�Π`=����~��րVNF���J�Z~���P�q��h���jΈ��G�"�I(�H*��'a������J��.-�Ѽ★�=�8)��h�Q*��x�J�?Z�����9���@D���.P�"�����	ސ�J�s}WI�N��T4�
F0��I%m�K��"k�b#䒄̥�(8�	�](Uc������B�9�G�i�E(�e�����Ko�0���fK7�[ܡo�������*�;6��N���Bê��r9�D�u�`�$/�?�1=C'H^P��h�a�Y�xp�m��#��t����d��L��r.��$���.������eA`(q�Aǖ�� ��f�J�Oe�M�WS[lє�Z'�f��im�ؔ���e��^�#���Jdvݜ��b��Z�v{�6�w��t66'��|fPX\���ER�h�2,�"h�舷`�rʑG#�V�@��eg�V�P3����^��Z�ڤrj�zJ���j�����jn�Kt�;}�m�iIg��d=%K㈗�u��2�$9ښe�Zp��C���t�N����7[��iu�n~�항u2ȷ���=)>r�T{-���lt�����b�{ZOl��b\wh�6�ӖGɻ�!�<��?�0��pWkA��R!�2��X�*8-������k��sZY~nTʊ�j��U�W�ֺ��7ܺ�f+T���J������Xt�^Nd��|ۡe���\�d�Moغ��.���:��5fMa���2ĨI�� ��.�9�(��|e��l����p\6r!�W)��٘7��mޤ�jft�h7e	���m܇�Y��4�I6H�a�QAo��9�J�����B�4��0�XZAZ����y���.�W��:����ꦨ��I%�m��T��]��}_����M?���b�y�Ð�tNn N<����r���l�v0�bM#�'�h����6���N�s��k{JHZ)��M����ë���W{�~k�K�o�kR��(<��{���"�w��6����[M�z�e��^��G�`����(��1�[(R&�(�i��/_��E�r      �   k  xڝ�MK�@E�s�Jޛ|.�T���R��%�	�%V�hj���Xw�y����=��}�F��~�����}۩��U}}�����{͟ʳ|�Y7eS���"O���B�����C��~t��<,��?{*��(�@H�-��h�V���H �!K���̧�C2�yȲ"	�Ė�M1�V;��!�0,I�B(�D���p�;D�PG ig�A��:S��]�I�q,-�`�T���L.U�Hׅ��;�}Ku���4p�D�1�������-��b�R5�ti(K���g�ӼOs��D�6L���dn�}��I6̖.U�H�5�=8�Q�GϮ8�H;�>�ݙ�z�]��"���}��}F��� � ~ 4���      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �      xڋ���� � �      �   �  xڅV�r�8<C_��nm�K���Ŏŕ؎�u�[{�(H�ŗR���;|����s�U�.N�1�CJ�K�T����SF��/�R�j'�X�Ҍ0%�S���H@���X�P�-�o;�h�����Z��oА�f��JK��*G5"�%��R.���@�N�����'4��`J+᳸=?�&�xa�Q7��B��NV5�H��R����*���BWB;�Afρ�q`��v���O$�����%�A����)�TZ�FUxNQ�LQ�D:"i�@U23�S#&4��JP7/w��G{���U�4�dU�`pJ�y�6�c��n���  |��wķ��x������Л��<�9>^���);uj#u���[@�p���۵�}kiDyܕ�f��]�6Wr�g��@jz  z ���u��V<�.����Ec|層�U�3�4�!�qL���[�Aa�B��p6�4�O�|�R��w���������7�|�/
��ǫ���u�����^�
u����d�TP�`�%&G&+���G�=���_>�}���S��-�h����d���1�^I{>F��W�~����W<
�W��#]q����F��\�̛�^:�L6y�k%[?zL80� �����xш��.	Q�{I�G�z���3Z�N)�X�ufFZN�Ͽ^���0|�=�h;��Z�O��$��C�v��n�R��6qX�W6cb�2��v3��И�d�;��ē�C*��1�,7�Y���n��ux�!)u���i"Re%�U���ƌ��`���/�tn���ř�fg�FA/
��$�Ӟ�P	�bH��A�D��[��LN�<�v	!���o|��B��&z���J%
��c^�~�00�p	W��n�,QSקv!����"&�g�.���%�z�L���GL8��
����SK�b3�^l����j�|��X�^I�ɥjF��/�� ��d6F��O$IБJ�xW�-����S�Qq�����6U�9υ��QI�� ��w����G�5:���C��SFj��Q��M�g��7nOAa�6yޜ�p����7ut0Ⓚ{�g������O�)���s��G�T���q����T%�]��ݸ�{¸5N{ԧ�$���>�ZҪ�Eׄ-��D�MR���()�%��8�#d�B;;Ӟ��QԨ�g����?KHv_����5�Y�Q�.D٨�ߓ�l�����      �   �  x�-�ۑ� C��bvb�y�r��c-��N�)ܖ�9����m�&f��i��6V��bۭ?��sǭ�b��=^F�Y�Ը�CP�O���Ŵ�W@essC���#>e�rs�q�~ю�Q����I��d �d��U�6O���.�C>X��u@�<�-��m�YEd�K��HD��E�<�: p.UT�A��Q�`Қ(+����Q�=��QҦ:�r�-Hyhd���������Kg�ݔf�z|������k�r{]?XjJ�|1��m�ر���%k͊N�X�ǒ���e�<�][$���kf�T��ff�'^
��j(M<n퉏*��zo.K�gt�T�aiGݟ���܇��f^��p���J���)��라��Z/Nܾ?�����S�qS�i��.��������?     