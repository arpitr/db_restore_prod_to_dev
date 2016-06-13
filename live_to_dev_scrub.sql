
-- Here we strip out private information that should not be floating around
-- on developer systems, disable modules that should not or need not be
-- enabled, etc. admin user passwords are set for ease of testing.

UPDATE users SET mail = CONCAT(name, '@localhost'), init = CONCAT(name, '@localhost'), pass = MD5(CONCAT('MILDSECRET', name)), picture = CONCAT(name, '@localhost'), signature=CONCAT(name, '@localhost') WHERE uid NOT IN  (SELECT uid FROM users_roles WHERE rid=3) AND uid > 0;

UPDATE authmap SET authname = CONCAT(aid, '@localhost');

-- Turn off modules which shouldn't be active in development (if this is going to production, remove this line).
DELETE FROM system WHERE name IN ('twitter', 'googleanalytics', 'securepages');


-- Admin user should not be same but not really well known
UPDATE users SET pass = MD5('supersecret!') WHERE uid = 1;

-- don't leave e-mail addresses, etc in comments table.
UPDATE comment SET name='SCRUBBED', mail='scrubbed@example.com', homepage='http://example.com' WHERE uid=0;

-- Remove sensitive data from other tables
TRUNCATE cache;
TRUNCATE cache_filter;
TRUNCATE cache_menu;
TRUNCATE cache_page;
TRUNCATE flood;
TRUNCATE history;
TRUNCATE search_dataset;
TRUNCATE search_index;
TRUNCATE search_total;
TRUNCATE sessions;
TRUNCATE watchdog;
