-- Runs once, when the postgres accessory starts with an empty data directory.
CREATE DATABASE umanni_users_production_queue OWNER umanni;
CREATE DATABASE umanni_users_production_cache OWNER umanni;
CREATE DATABASE umanni_users_production_cable OWNER umanni;
