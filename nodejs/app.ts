import express from 'express';

import Words from './words';
import connection from './database/database';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import bodyParser from 'body-parser';


let secretKey = 'cool_random_words';
let app = express();
app.use(bodyParser.urlencoded({ extended: true }));

app.post('/login', (request, response) => {
    let { username, password } = request.body;
    if (!username || username.length < 3 || !password || password.length < 3) {
        response.status(400).send({ error: 'Invalid username or password' });
        return;
    }

    connection.query('SELECT * FROM users WHERE username = ?', username, (error, results) => {
        if (error || results.length <= 0) {
            response.status(400).json('Wrong username or password');
            return;
        }

        bcrypt.compare(password, results[0].password, (error, result) => {
            if (error) {
                response.status(400).json('Wrong username or password');
                return;
            }
            if (result) {
                response.status(200).json({
                    user: {
                        id: results[0].id,
                        username: results[0].username
                    },
                    token: jwt.sign({ id: results[0].id }, secretKey)
                });
            } else {
                response.status(400).json('Wrong username or password');
            }
        });
    });
});

app.post('/register', (request, response) => {
    let { username, password } = request.body;
    if (!username || username.length < 3) {
        response.status(400).json('Username needs to be 3 or more characters');
        return;
    }
    if (!password || password.length < 5) {
        response.status(400).json('Password needs to be 5 or more characters');
        return;
    }

    bcrypt.hash(password, 10, (error, hash) => {
        if (error) {
            response.status(400).json('Wrong username or password');
            return;
        }
        connection.query('INSERT INTO users (username, password) VALUES (?, ?)', [username, hash], (error, results) => {
            if (error) {
                response.status(400).json('User already registered');
                return;
            }
            response.status(200).json('User registered');
        });
    });
});



app.use((request, response, next) => {
    let token = request.headers['x-access-token'] || request.body?.token;

    if (!token) {
        token = request.headers.authorization?.match(/Bearer (.+)/)?.[1];
    }

    if (!token) {
        response.status(401).json('Unauthorized');
        return;
    }
    
    jwt.verify(token, secretKey, (error: any, decoded: any) => {
        if (error) {
            response.status(401).json('Unauthorized');
            return;
        }
        (request as any).userId = decoded.id;
        next();
    });
});



app.get('/words', function (request, response) {
    let amount = Number(request.query.amount) || 10;
    let words = [];
    for (let i = 0; i < amount; i++) {
        words.push(Words.getRandomWordPair());
    }
    response.json(words);
});

app.use('/users/:id', function (request, response, next) {
    if ((request as any).userId != request.params.id) {
        response.status(401).json('Unauthorized');
        return;
    }

    connection.query('SELECT id, username FROM users WHERE users.id = ?', request.params.id, function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }

        if (results.length > 0) {
            (request as any).user = { ... results[0] };
            next();
        } else {
            response.status(404).json('User not found');
        }
    });
});

app.get('/users/:id/favorites', function (request, response) {
    connection.query('SELECT word FROM favorites WHERE favorites.user_id = ?', request.params.id, function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }

        if (results.length > 0) {
            response.status(200).json(results.map((result: any) => result.word));
        } else {
            response.status(404).json('No words found');
        }
    });
});

app.post('/users/:id/favorites/:word', function (request, response) {
    connection.query('INSERT INTO favorites VALUES (?, ?)', [ request.params.id, request.params.word ], function (error, results) {
        if (error) {
            if (error.code == 'ER_DUP_ENTRY') {
                response.status(400).json('Word already added');
            } else {
                response.sendStatus(500);
            }
            return;
        }

        response.json('Word added');
    });
});

app.delete('/users/:id/favorites/:word', function (request, response) {
    connection.query('DELETE FROM favorites WHERE favorites.user_id = ? and favorites.word = ?', [ request.params.id, request.params.word ], function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }

        if (results.affectedRows > 0) {
            response.status(200).json('Word deleted');
        } else {
            response.status(404).json('Word not found');
        }
    });
});



let server = app.listen(process.env.PORT || 3000, () => {
    let info = server.address();
    if (info instanceof Object) console.log(`Running server on ${info.address == '::' ? 'localhost' : info.address}:${info.port}`);
    else console.log(`Running server...`);
});