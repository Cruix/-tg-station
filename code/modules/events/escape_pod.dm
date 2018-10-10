
/datum/round_event_control/escape_pod
	name = "Time-Travelling Escape Pod"
	typepath = /datum/round_event/escape_pod
	weight = 10
	max_occurrences = 1

/datum/round_event/escape_pod
	startWhen = 10
	announceWhen = 3

/datum/round_event/escape_pod/announce(fake)
	priority_announce("Friendly escape pod detected on collision course with [station_name()].", "Nanotrasen Escape Pod Dispatch")

/datum/round_event/escape_pod/start()
	var/startSide = pick(GLOB.cardinals)
	var/startZ = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/pickedstart = spaceDebrisStartLoc(startSide, startZ)
	var/pickedgoal = locate(round(world.maxx/2) + rand(-20, 20), round(world.maxy/2) + rand(-20, 20), startZ)
	var/obj/effect/meteor/escape_pod/pod = new /obj/effect/meteor/escape_pod(pickedstart, pickedgoal, src)
	pod.dest = pickedgoal

/obj/effect/meteor/escape_pod
	name = "an out-of-control escape pod"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/effects/128x128.dmi'
	icon_state = "escape_pod"
	density = TRUE
	anchored = TRUE
	hits = 16
	hitpwr = 3
	pass_flags = NONE
	heavy = TRUE
	meteorsound = 'sound/effects/meteorimpact.ogg'
	threat = 5
	meteordrop = list()
	dropamt = 0
	ram_radius = 1
	spins = FALSE
	medal_worthy = FALSE
	var/template_id = "escape_pod"

/obj/effect/meteor/escape_pod/Initialize(mapload, target, datum/round_event/ghost_role/escape_pod/spawning_event)
	. = ..()
	setDir(NORTH)

/obj/effect/meteor/escape_pod/setDir(newdir)
	var/matrix/M = matrix()
	M.Translate(0, -48)
	M.Turn(dir2angle(newdir))
	M.Translate(-48, -48)
	transform = M
	..()

/obj/effect/meteor/escape_pod/make_debris()
	var/datum/map_template/shelter/template = SSmapping.shelter_templates[template_id]
	var/turf/T = get_turf(src)
	var/area/A = get_area(T)
	if(T)
		var/status = template.check_deploy(T)
		if((status == SHELTER_DEPLOY_ANCHORED_OBJECTS) || (status == SHELTER_DEPLOY_ALLOWED))
			template.load(T, centered = TRUE)
			message_admins("[ADMIN_JMP(src)] an escape pod has crashed in [A].")
		else
			message_admins("[ADMIN_JMP(src)] an escape pod has crashed in [A], but could not spawn because something was in the way.")


/datum/map_template/shelter/ruined_escape_pod
	name = "Crashed Escape Pod"
	description = "A crashed escape pod, no longer capable of flight."
	mappath = "_maps/templates/ruined_escape_pod.dmm"
	shelter_id = "escape_pod"

/datum/map_template/shelter/ruined_escape_pod/New()
	..()
	blacklisted_turfs = typecacheof(/turf/closed/indestructible)
