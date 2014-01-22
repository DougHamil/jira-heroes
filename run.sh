#!/bin/bash
npm install
coffee -o ./public/js -wc ./src/web &
coffee -o ./public/js -wc ./lib/common &
nodemon app.js $@
