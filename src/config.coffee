fs = require 'fs'

# Read config file
CONFIG = {}

try
  CONFIG = JSON.parse(fs.readFileSync(__dirname+"/../config.json", 'utf8'))
catch err
  CONFIG = JSON.parse(fs.readFileSync(__dirname+"/../config.default.json", 'utf8'))

module.exports = CONFIG
