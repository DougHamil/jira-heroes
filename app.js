require('coffee-script');
require('./src/jiraheroes');
var Server = require('./src/server');

var options = {
	databaseServer:'localhost',
	databasePort:27017,
	database:'jira-heroes'
};

Server(options);
