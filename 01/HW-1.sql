set schema 'HW-1';

create table personnel (
    id serial primary key,
    firstname varchar(50),
    lastname varchar(50),
    middlename varchar(50)
);

create table projects (
    id serial primary key ,
    project_name varchar(50)
);

create table projects_assignments(
    id serial primary key ,
    personnel_id int references personnel,
    project_id int references projects
);

create table positions (
    id serial primary key,
    position_name varchar(50)
);

create table regions(
    id serial primary key ,
    region_name varchar(50)
);

create table cities(
    id serial primary key ,
    city_name varchar(50),
    region_id int references regions
);

create table branches(
    id serial primary key ,
    city_code int references cities,
    office_address varchar(250)
);

create table departments_type(
    id serial primary key ,
    department_type_name varchar(50)
);

create table departments(
    id serial primary key ,
    department_name varchar(50),
    department_type_id int references departments_type,
    branch_id int references branches
);

create table current_position(
    id serial primary key ,
    personnel_id int references personnel,
    position_id int references positions,
    department_id int references departments,
    salary float,
    date_started date
);





