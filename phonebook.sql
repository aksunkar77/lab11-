-- LAB 11: PostgreSQL Functions and Stored Procedures for PhoneBook


CREATE OR REPLACE FUNCTION search_phonebook(pattern TEXT)
RETURNS TABLE(id INT, name TEXT, phone TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM phonebook
    WHERE name ILIKE '%' || pattern || '%'
       OR phone ILIKE '%' || pattern || '%';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE insert_or_update_user(p_name TEXT, p_phone TEXT)
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM phonebook WHERE name = p_name) THEN
        UPDATE phonebook SET phone = p_phone WHERE name = p_name;
    ELSE
        INSERT INTO phonebook (name, phone) VALUES (p_name, p_phone);
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE bulk_insert_users(
    names TEXT[], phones TEXT[], OUT invalids TEXT[]
)
AS $$
DECLARE
    i INT;
BEGIN
    invalids := ARRAY[]::TEXT[];
    FOR i IN 1 .. array_length(names, 1) LOOP
        IF phones[i] ~ '^[0-9]{6,15}$' THEN
            BEGIN
                INSERT INTO phonebook(name, phone) VALUES (names[i], phones[i]);
            EXCEPTION WHEN unique_violation THEN
                UPDATE phonebook SET phone = phones[i] WHERE name = names[i];
            END;
        ELSE
            invalids := array_append(invalids, names[i] || ':' || phones[i]);
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_paginated(limit_value INT, offset_value INT)
RETURNS TABLE(id INT, name TEXT, phone TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM phonebook
    ORDER BY id
    LIMIT limit_value OFFSET offset_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delete_user(p_identifier TEXT)
AS $$
BEGIN
    DELETE FROM phonebook
    WHERE name = p_identifier OR phone = p_identifier;
END;
$$ LANGUAGE plpgsql;
