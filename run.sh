#!/bin/bash
npm install
coffee -o ./public/js -wc ./src/web &
nodemon app.js
