--usage: cat export.sql | sqlite3 gh_users.db
.header on
.mode csv
.once out.csv
SELECT * FROM users WHERE stars IS NOT NULL;