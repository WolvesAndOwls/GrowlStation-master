/datum/instrument/fun
	name = "Generic Fun Instrument"
	category = "Fun"
	instrument_type = /datum/instrument/fun

/datum/instrument/fun/honk
	name = "!!HONK!!"
	id = "honk"
	real_samples = list("74"='sound/items/bikehorn.ogg') // Cluwne Heaven

/datum/instrument/fun/signal
	name = "Ping"
	id = "ping"
	real_samples = list("79"='sound/machines/ping.ogg')

/datum/instrument/fun/chime
	name = "Chime"
	id = "chime"
	real_samples = list("79"='sound/machines/chime.ogg')

/datum/instrument/fun/mothscream
	name = "Moth Scream"
	id = "mothscream"
	real_samples = list("60"='sound/voice/moth/scream_moth.ogg')
	admin_only = TRUE
