import mysql from 'mysql';

export default mysql.createConnection({
    host: 'localhost',
    user: 'root',
    database: 'random_words'
});