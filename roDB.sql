create table Network (
id integer primary key autoincrement,
name varchar(50) not null,
description text not null,
nick varchar(50) not null,
altnicks varchar(200) not null,
fullname varchar(50) not null,
email varchar(100) not null,
created datetime not null,
modified datetime not null
);

create table Server (
id integer primary key autoincrement,
network_id integer not null,
name varchar(50) not null,
description text not null,
host varchar(50) not null,
defaultport integer not null,
ports varchar(50) not null,
connectusermode integer not null,
created datetime not null,
modified datetime not null,
lastconnect datetime null,
constraint FK_Server_Network foreign key (network_id) references Network (id)
);