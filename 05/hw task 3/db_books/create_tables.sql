create table sharding.books(
    book_id serial primary key,
    author varchar(50),
    title varchar(50),
    abstract text,
    shop_id bigint
);
