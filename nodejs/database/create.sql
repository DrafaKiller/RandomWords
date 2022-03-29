CREATE DATABASE random_words;

/*
CREATE TABLE words (
    id int auto_increment PRIMARY KEY,
    text varchar(20),

    UNIQUE(text)
);
*/

CREATE TABLE users (
    id int auto_increment PRIMARY KEY,
    username varchar(20),
    password varchar(72),

    UNIQUE (username)
);

CREATE TABLE favorites (
    user_id int,
    word varchar(20),

    UNIQUE (word),
    FOREIGN KEY (user_id) REFERENCES users(id)
);