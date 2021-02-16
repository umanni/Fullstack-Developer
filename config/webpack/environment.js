const { environment } = require('@rails/webpacker')
const custonConfig = require('./custom')

environment.config.merge(custonConfig)

module.exports = environment
