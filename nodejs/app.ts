import express from 'express';

import Words from './words';
import connection from './database/database';



let app = express();

app.get('/words', function (request, response) {
    let words = [];
    for (let i = 0; i < 10; i++) {
        words.push(Words.getRandomWordPair());
    }
    response.json(words);
});

app.use('/users/:id', function (request, response, next) {
    connection.query('SELECT id, username FROM users WHERE users.id = ?', request.params.id, function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }

        if (results.length > 0) {
            (request as any).user = { ... results[0] };
            next();
        } else {
            response.status(404);
            response.json('User not found');
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
            response.json(results.map((result: any) => result.word));
        } else {
            response.status(404);
            response.json('No words found');
        }
    });
});

app.post('/users/:id/favorites/:word', function (request, response) {
    connection.query('INSERT INTO favorites VALUES (?, ?)', [ request.params.id, request.params.word ], function (error, results) {
        if (error) {
            if (error.code == 'ER_DUP_ENTRY') {
                response.status(400);
                response.json('Word already added');
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
            response.json('Word deleted');
        } else {
            response.status(404);
            response.json('Word not found');
        }
    });
});



let server = app.listen(process.env.PORT || 3000, () => {
    let info = server.address();
    if (info instanceof Object) console.log(`Running server on ${info.address == '::' ? 'localhost' : info.address}:${info.port}`);
    else console.log(`Running server...`);
});