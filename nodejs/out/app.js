"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
exports.__esModule = true;
var express_1 = __importDefault(require("express"));
var words_1 = __importDefault(require("./words"));
var database_1 = __importDefault(require("./database/database"));
var bcrypt_1 = __importDefault(require("bcrypt"));
var jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
var body_parser_1 = __importDefault(require("body-parser"));
var secretKey = 'cool_random_words';
var app = (0, express_1["default"])();
app.use(body_parser_1["default"].urlencoded({ extended: true }));
app.post('/login', function (request, response) {
    var _a = request.body, username = _a.username, password = _a.password;
    if (!username || username.length < 3 || !password || password.length < 3) {
        response.status(400).send({ error: 'Invalid username or password' });
        return;
    }
    database_1["default"].query('SELECT * FROM users WHERE username = ?', username, function (error, results) {
        if (error || results.length <= 0) {
            response.status(400).json('Wrong username or password');
            return;
        }
        bcrypt_1["default"].compare(password, results[0].password, function (error, result) {
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
                    token: jsonwebtoken_1["default"].sign({ id: results[0].id }, secretKey)
                });
            }
            else {
                response.status(400).json('Wrong username or password');
            }
        });
    });
});
app.post('/register', function (request, response) {
    var _a = request.body, username = _a.username, password = _a.password;
    if (!username || username.length < 3) {
        response.status(400).json('Username needs to be 3 or more characters');
        return;
    }
    if (!password || password.length < 5) {
        response.status(400).json('Password needs to be 5 or more characters');
        return;
    }
    bcrypt_1["default"].hash(password, 10, function (error, hash) {
        if (error) {
            response.status(400).json('Wrong username or password');
            return;
        }
        database_1["default"].query('INSERT INTO users (username, password) VALUES (?, ?)', [username, hash], function (error, results) {
            if (error) {
                response.status(400).json('User already registered');
                return;
            }
            response.status(200).json('User registered');
        });
    });
});
app.use(function (request, response, next) {
    var _a, _b, _c;
    var token = request.headers['x-access-token'] || ((_a = request.body) === null || _a === void 0 ? void 0 : _a.token);
    if (!token) {
        token = (_c = (_b = request.headers.authorization) === null || _b === void 0 ? void 0 : _b.match(/Bearer (.+)/)) === null || _c === void 0 ? void 0 : _c[1];
    }
    if (!token) {
        response.status(401).json('Unauthorized');
        return;
    }
    jsonwebtoken_1["default"].verify(token, secretKey, function (error, decoded) {
        if (error) {
            response.status(401).json('Unauthorized');
            return;
        }
        request.userId = decoded.id;
        next();
    });
});
app.get('/words', function (request, response) {
    var amount = Number(request.query.amount) || 10;
    var words = [];
    for (var i = 0; i < amount; i++) {
        words.push(words_1["default"].getRandomWordPair());
    }
    response.json(words);
});
app.use('/users/:id', function (request, response, next) {
    if (request.userId != request.params.id) {
        response.status(401).json('Unauthorized');
        return;
    }
    database_1["default"].query('SELECT id, username FROM users WHERE users.id = ?', request.params.id, function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }
        if (results.length > 0) {
            request.user = __assign({}, results[0]);
            next();
        }
        else {
            response.status(404).json('User not found');
        }
    });
});
app.get('/users/:id/favorites', function (request, response) {
    database_1["default"].query('SELECT word FROM favorites WHERE favorites.user_id = ?', request.params.id, function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }
        if (results.length > 0) {
            response.status(200).json(results.map(function (result) { return result.word; }));
        }
        else {
            response.status(404).json('No words found');
        }
    });
});
app.post('/users/:id/favorites/:word', function (request, response) {
    database_1["default"].query('INSERT INTO favorites VALUES (?, ?)', [request.params.id, request.params.word], function (error, results) {
        if (error) {
            if (error.code == 'ER_DUP_ENTRY') {
                response.status(400).json('Word already added');
            }
            else {
                response.sendStatus(500);
            }
            return;
        }
        response.json('Word added');
    });
});
app["delete"]('/users/:id/favorites/:word', function (request, response) {
    database_1["default"].query('DELETE FROM favorites WHERE favorites.user_id = ? and favorites.word = ?', [request.params.id, request.params.word], function (error, results) {
        if (error) {
            response.sendStatus(500);
            return;
        }
        if (results.affectedRows > 0) {
            response.status(200).json('Word deleted');
        }
        else {
            response.status(404).json('Word not found');
        }
    });
});
var server = app.listen(process.env.PORT || 3000, function () {
    var info = server.address();
    if (info instanceof Object)
        console.log("Running server on ".concat(info.address == '::' ? 'localhost' : info.address, ":").concat(info.port));
    else
        console.log("Running server...");
});
