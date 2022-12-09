create table sharding.users(
    user_id serial primary key,
    username varchar(20),
    email varchar(50),
    book_id bigint
);
