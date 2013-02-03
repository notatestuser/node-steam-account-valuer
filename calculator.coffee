#!/usr/bin/env coffee

unless process.argv.length > 2
	console.error "Usage: #{process.argv[0] or './calculator'} [steam username]"
	process.exit 1

#####

http     = require 'http'
async    = require 'async'
{decode} = require 'entities'

#####

accountName       = process.argv[2]
userGamesUrl      = "http://steamcommunity.com/id/#{accountName}/games/?tab=all"
concurrentFetches = 6
priceListDots     = 40

getUrlFn = (url, errorFn, callbackFn) ->
	buf = ''
	http.get(url)
		.on 'response', (res) ->
			res.on 'data', (data) ->
				buf += data.toString('utf8')
			res.on 'end', ->
				console.log "#{res.statusCode} #{url}"
				callbackFn(buf)
		.on 'error', (e) ->
			console.error "Error while fetching #{url}: #{e.message}"
			errorFn?(e)

handleResponseFn = (pageHtml) ->
	gameData = extractGameDataFn pageHtml
	storeFetchFns = buildFetchFns gameData
	console.log "Fetching pricing information for #{storeFetchFns.length} games"
	async.parallelLimit storeFetchFns, concurrentFetches, (err, results) ->
		console.error err if err?
		printGamesAndPrices results

extractGameDataFn = (pageHtml) ->
	code = pageHtml.match(/var rgGames \= .*\;/g)[0]
	eval code
	rgGames

buildFetchFns = (gameData = {}) ->
	gameData.map (game) ->
		(callback) ->
			getUrlFn "http://store.steampowered.com/app/#{game.appid}", callback, (pageHtml) ->
				productNameMatches = pageHtml.match(/h1>([^<]+)</)
				productPriceMatches = pageHtml.match(/itemprop="price">\s+([^<\s]+)\s+</)
				productName = game.name
				priceListDots = Math.max(productName.length + 1, priceListDots)
				callback null,
					productName: decode(productName)
					productPrice: if productPriceMatches?.length > 1 then decode(productPriceMatches[1]) else 'n/a'
			undefined

printGamesAndPrices = (products) ->
	priceSum = 0
	products.map (product) ->
		if product?
			line = product.productName
			for i in [0..(priceListDots - product.productName.length)]
				line += '.'
			line += product.productPrice
			console.log line
			priceSum += parseFloat(product.productPrice.substring(1)) or 0
	console.log "\nTotal R.R.P. value: #{priceSum}"

getUrlFn userGamesUrl, null, handleResponseFn
