CREATE DATABASE random_words;
USE random_words;

CREATE TABLE users (
    id int auto_increment PRIMARY KEY,
    username varchar(20) NOT NULL,
    password varchar(72) NOT NULL,

    UNIQUE (username)
);

CREATE TABLE favorites (
    user_id int,
    word varchar(20),

    UNIQUE (word),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);