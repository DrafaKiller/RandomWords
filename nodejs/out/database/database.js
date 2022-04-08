"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
exports.__esModule = true;
var mysql_1 = __importDefault(require("mysql"));
exports["default"] = mysql_1["default"].createConnection({
    host: 'localhost',
    user: 'root',
    database: 'random_words'
});
