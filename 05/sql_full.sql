create database sharding;

create table sharding.users(
    user_id serial primary key,
    username varchar(20),
    email varchar(50),
    book_id bigint
);

create table sharding.books(
    book_id serial primary key,
    author varchar(50),
    title varchar(50),
    abstract text,
    shop_id bigint
);

create table sharding.shops_base(
    shop_id int primary key,
    director varchar(50),
    nb_employes int,
    square_size float
);

create table sharding.shops_extra(
    shop_id int primary key,
    county varchar(50),
    city varchar(50),
    street varchar(50),
    building int
);