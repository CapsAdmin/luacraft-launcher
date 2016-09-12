-- I lua finnes det forskjellige type variabler. nil, boolean, number, string, function, table er de viktigste.

-- number er tall:
local tall = 12345
local pai = 3.14159

-- string er tekst
local tekst = "hei på deg"
local tekst2 = 'hei på deg'
local tekst3 = [[hei på deg]]

-- function er funksjoner
local en_funksjon = function() end

-- nil er ingenting og kan bli brukt til å sette en variabel til ingenting.
local tekst = "hei på deg"
tekst = nil

-- boolean skrives enten true eller false
local sannt = true
local ikke_sannt = false

-- table er tabeller eller lister. Det står mere info om dette lengere ned.
local liste = {50, 20, 6, 83}
local liste = {hei = "test", ja = true, min_funksjon = function() end}

-- Når man kjører funksjoner kan man skrive alt dette uten å skrive local blablah = først:
en_funksjon("hei på deg", 12345, true, nil, false, {50, 20, 6, 83}, function() end)