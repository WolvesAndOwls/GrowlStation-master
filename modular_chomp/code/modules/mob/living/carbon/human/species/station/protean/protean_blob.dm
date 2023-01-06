// Simple animal nanogoopeyness
/mob/living/simple_mob/protean_blob
	name = "protean blob"
	desc = "Some sort of big viscous pool of jelly."
	tt_desc = "Animated nanogoop"
	icon = 'modular_chomp/icons/mob/species/protean/protean.dmi'
	icon_state = "to_puddle"
	icon_living = "puddle2"
	icon_rest = "rest"
	icon_dead = "puddle"

	faction = "neutral"
	maxHealth = 200
	health = 200
	say_list_type = /datum/say_list/protean_blob

	show_stat_health = FALSE //We will do it ourselves

	response_help = "pets the"
	response_disarm = "gently pushes aside the "
	response_harm = "hits the"

	harm_intent_damage = 3
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = list("slashed")
	see_in_dark = 10

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	movement_cooldown = 2

	var/mob/living/carbon/human/humanform
	var/obj/item/organ/internal/nano/refactory/refactory
	var/datum/modifier/healing

	var/human_brute = 0
	var/human_burn = 0

	player_msg = "In this form, your health will regenerate as long as you have metal in you."

	can_buckle = 1
	buckle_lying = 1
	mount_offset_x = 0
	mount_offset_y = 0
	has_hands = 1
	shock_resist = 1
	nameset = 1
	holder_type = /obj/item/weapon/holder/protoblob

/datum/say_list/protean_blob
	speak = list("Blrb?","Sqrsh.","Glrsh!")
	emote_hear = list("squishes softly","spluts quietly","makes wet noises")
	emote_see = list("shifts wetly","undulates placidly")

//Constructor allows passing the human to sync damages
/mob/living/simple_mob/protean_blob/New(var/newloc, var/mob/living/carbon/human/H)
	..()
	if(H)
		humanform = H
		updatehealth()
		refactory = locate() in humanform.internal_organs
		verbs |= /mob/living/proc/usehardsuit
		verbs |= /mob/living/simple_mob/protean_blob/proc/nano_partswap
		verbs |= /mob/living/simple_mob/protean_blob/proc/nano_regenerate
		verbs |= /mob/living/simple_mob/protean_blob/proc/nano_blobform
		verbs |= /mob/living/simple_mob/protean_blob/proc/nano_rig_transform
		verbs |= /mob/living/simple_mob/protean_blob/proc/appearance_switch
		verbs -= /mob/living/simple_mob/proc/nutrition_heal
	else
		update_icon()
	verbs |= /mob/living/proc/hide
	verbs |= /mob/living/simple_mob/proc/animal_mount
	verbs |= /mob/living/proc/toggle_rider_reins

//Hidden verbs for macro hotkeying
/mob/living/simple_mob/protean_blob/proc/nano_partswap()
	set name = "Ref - Single Limb"
	set desc = "Allows you to replace and reshape your limbs as you see fit."
	set category = "Abilities"
	set hidden = 1
	humanform.nano_partswap()

/mob/living/simple_mob/protean_blob/proc/nano_regenerate()
	set name = "Total Reassembly (wip)"
	set desc = "Completely reassemble yourself from whatever save slot you have loaded in preferences. Assuming you meet the requirements."
	set category = "Abilities"
	set hidden = 1
	humanform.nano_regenerate()

/mob/living/simple_mob/protean_blob/proc/nano_blobform()
	set name = "Toggle Blobform"
	set desc = "Switch between amorphous and humanoid forms."
	set category = "Abilities"
	set hidden = 1
	humanform.nano_blobform()

/mob/living/simple_mob/protean_blob/proc/nano_rig_transform()
	set name = "Modify Form - Hardsuit"
	set desc = "Allows a protean to retract its mass into its hardsuit module at will."
	set category = "Abilities"
	set hidden = 1
	humanform.nano_rig_transform()

/mob/living/simple_mob/protean_blob/proc/appearance_switch()
	set name = "Switch Blob Appearance"
	set desc = "Allows a protean blob to switch its outwards appearance."
	set category = "Abilities"
	set hidden = 1
	humanform.appearance_switch()

/mob/living/simple_mob/protean_blob/Login()
	..()
	plane_holder.set_vis(VIS_AUGMENTED, 1)
	plane_holder.set_vis(VIS_CH_HEALTH_VR, 1)
	plane_holder.set_vis(VIS_CH_ID, 1)
	plane_holder.set_vis(VIS_CH_STATUS_R, 1)
	plane_holder.set_vis(VIS_CH_BACKUP, 1)	//Gonna need these so we can see the status of our host. Could probably write it so this only happens when worn, but eeehhh
	if(!riding_datum)
		riding_datum = new /datum/riding/simple_mob/protean_blob(src)

/datum/riding/simple_mob/protean_blob/handle_vehicle_layer()
	ridden.layer = OBJ_LAYER

/mob/living/simple_mob/protean_blob/MouseDrop_T()
	return

/mob/living/simple_mob/protean_blob/runechat_y_offset(width, height)
	return (..()) - (20*size_multiplier)

/mob/living/simple_mob/protean_blob/Destroy()
	humanform = null
	refactory = null
	vore_organs = null
	vore_selected = null
	if(healing)
		healing.expire()
	return ..()

/mob/living/simple_mob/protean_blob/say_understands(var/mob/other, var/datum/language/speaking = null)
	// The parent of this proc and its parent are SHAMS and should be rewritten, but I'm not up to it right now.
	if(!speaking)
		return TRUE // can understand common, they're like, a normal person thing
	return ..()

/mob/living/simple_mob/protean_blob/speech_bubble_appearance()
	return "synthetic"

/mob/living/simple_mob/protean_blob/get_available_emotes()
	return global._robot_default_emotes.Copy()

/mob/living/simple_mob/protean_blob/init_vore()
	return //Don't make a random belly, don't waste your time

/mob/living/simple_mob/protean_blob/isSynthetic()
	return TRUE // yup

/mob/living/simple_mob/protean_blob/Stat()
	..()
	if(humanform)
		humanform.species.Stat(humanform)

/mob/living/simple_mob/protean_blob/updatehealth()
	if(!humanform)
		return ..()

	//Set the max
	maxHealth = humanform.getMaxHealth()*2 //HUMANS, and their 'double health', bleh.
	human_brute = humanform.getActualBruteLoss()
	human_burn = humanform.getActualFireLoss()
	health = maxHealth - humanform.getOxyLoss() - humanform.getToxLoss() - humanform.getCloneLoss() - humanform.getBruteLoss() - humanform.getFireLoss()

	//Alive, becoming dead
	if((stat < DEAD) && (health <= 0))
		death()

	nutrition = humanform.nutrition

	//Overhealth
	if(health > getMaxHealth())
		health = getMaxHealth()

	//Update our hud if we have one
	if(healths)
		if(stat != DEAD)
			var/heal_per = (health / getMaxHealth()) * 100
			switch(heal_per)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

// All the damage and such to the blob translates to the human
/mob/living/simple_mob/protean_blob/apply_effect(var/effect = 0, var/effecttype = STUN, var/blocked = 0, var/check_protection = 1)
	if(humanform)
		return humanform.apply_effect(effect, effecttype, blocked, check_protection)
	else
		return ..()

/mob/living/simple_mob/protean_blob/adjustBruteLoss(var/amount,var/include_robo)
	if(humanform)
		return humanform.adjustBruteLoss(amount)
	else
		return ..()

/mob/living/simple_mob/protean_blob/adjustFireLoss(var/amount,var/include_robo)
	if(humanform)
		return humanform.adjustFireLoss(amount)
	else
		return ..()

/mob/living/simple_mob/protean_blob/adjustToxLoss(amount)
	if(humanform)
		return humanform.adjustToxLoss(amount)
	else
		return ..()

/mob/living/simple_mob/protean_blob/adjustOxyLoss(amount)
	if(humanform)
		return humanform.adjustOxyLoss(amount)
	else
		return ..()

/mob/living/simple_mob/protean_blob/adjustHalLoss(amount)
	if(humanform)
		return humanform.adjustHalLoss(amount)
	else
		return ..()

/mob/living/simple_mob/protean_blob/adjustCloneLoss(amount)
	if(humanform)
		return humanform.adjustCloneLoss(amount)
	else
		return ..()

/mob/living/simple_mob/protean_blob/emp_act(severity)
	if(humanform)
		return humanform.emp_act(severity)
	else
		return ..()

/mob/living/simple_mob/protean_blob/ex_act(severity)
	if(humanform)
		return humanform.ex_act(severity)
	else
		return ..()

/mob/living/simple_mob/protean_blob/rad_act(severity)
	if(humanform)
		return humanform.rad_act(severity)
	else
		return ..()

/mob/living/simple_mob/protean_blob/bullet_act(obj/item/projectile/P)
	if(humanform)
		return humanform.bullet_act(P)
	else
		return ..()

/mob/living/simple_mob/protean_blob/death(gibbed, deathmessage = "dissolves away, leaving only a few spare parts!")
	if(humanform)
		humanform.death(gibbed, deathmessage)
	else
		animate(src, alpha = 0, time = 2 SECONDS)
		sleep(2 SECONDS)

	if(!QDELETED(src)) // Human's handle death should have taken us, but maybe we were adminspawned or something without a human counterpart
		qdel(src)

/mob/living/simple_mob/protean_blob/Life()
	. = ..()
	if(. && istype(refactory) && humanform)
		if(!healing && (human_brute || human_burn) && refactory.get_stored_material(MAT_STEEL) >= 100)
			healing = humanform.add_modifier(/datum/modifier/protean/steel, origin = refactory)
		else if(healing && !(human_brute || human_burn))
			healing.expire()
			healing = null

/mob/living/simple_mob/protean_blob/lay_down()
	..()
	if(resting)
		mouse_opacity = 0
		plane = ABOVE_OBJ_PLANE
	else
		mouse_opacity = 1
		icon_state = "wake"
		plane = MOB_PLANE
		sleep(7)
		update_icon()
		//Potential glob noms
		if(can_be_drop_pred) //Toggleable in vore panel
			var/list/potentials = living_mobs(0)
			if(potentials.len)
				var/mob/living/target = pick(potentials)
				if(istype(target) && target.devourable && target.can_be_drop_prey && vore_selected)
					if(target.buckled)
						target.buckled.unbuckle_mob(target, force = TRUE)
					target.forceMove(vore_selected)
					to_chat(target,"<span class='warning'>\The [src] quickly engulfs you, [vore_selected.vore_verb]ing you into their [vore_selected.name]!</span>")

/mob/living/simple_mob/protean_blob/attack_target(var/atom/A)
	if(refactory && istype(A,/obj/item/stack/material))
		var/obj/item/stack/material/S = A
		var/substance = S.material.name
		var allowed = FALSE
		for(var/material in PROTEAN_EDIBLE_MATERIALS)
			if(material == substance) allowed = TRUE
		if(!allowed)
			return
		if(refactory.add_stored_material(S.material.name,1*S.perunit) && S.use(1))
			visible_message("<b>[name]</b> gloms over some of \the [S], absorbing it.")
	else if(isitem(A) && a_intent == "grab") //CHOMP Add all this block, down to I.forceMove.
		var/obj/item/I = A
		if(!vore_selected)
			to_chat(src,"<span class='warning'>You either don't have a belly selected, or don't have a belly!</span>")
			return FALSE
		if(is_type_in_list(I,item_vore_blacklist) || I.anchored)
			to_chat(src, "<span class='warning'>You can't eat this.</span>")
			return

		if(is_type_in_list(I,edible_trash) | adminbus_trash)
			if(I.hidden_uplink)
				to_chat(src, "<span class='warning'>You really should not be eating this.</span>")
				message_admins("[key_name(src)] has attempted to ingest an uplink item. ([src ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>" : "null"])")
				return
		visible_message("<b>[name]</b> stretches itself over the [I], engulfing it whole!")
		I.forceMove(vore_selected)
	else
		return ..()

/mob/living/simple_mob/protean_blob/attackby(var/obj/item/O, var/mob/user)
	if(refactory && istype(O,/obj/item/stack/material))
		var/obj/item/stack/material/S = O
		var/substance = S.material.name
		var allowed = FALSE
		for(var/material in PROTEAN_EDIBLE_MATERIALS)
			if(material == substance) allowed = TRUE
		if(!allowed)
			return
		if(refactory.add_stored_material(S.material.name,1*S.perunit) && S.use(1))
			visible_message("<b>[name]</b> gloms over some of \the [S], absorbing it.")
	else
		return ..()

/mob/living/simple_mob/protean_blob/attack_hand(mob/living/L)
	if(L.get_effective_size() >= (src.get_effective_size() + 0.5) )
		src.get_scooped(L)
	else
		..()

/mob/living/simple_mob/protean_blob/MouseDrop(var/atom/over_object)
	if(ishuman(over_object) && usr == src && src.Adjacent(over_object))
		var/mob/living/carbon/human/H = over_object
		get_scooped(H, TRUE)
	else
		return ..()

/mob/living/simple_mob/protean_blob/MouseEntered(location,control,params)
	if(resting)
		return
	..()

var/global/list/disallowed_protean_accessories = list(
	/obj/item/clothing/accessory/holster,
	/obj/item/clothing/accessory/storage,
	/obj/item/clothing/accessory/armor
	)

// Helpers - Unsafe, WILL perform change.
/mob/living/carbon/human/proc/nano_intoblob(force)
	if(loc == /obj/item/weapon/rig/protean)
		return
	if(!force && !isturf(loc))
		to_chat(src,"<span class='warning'>You can't change forms while inside something.</span>")
		return

	handle_grasp() //It's possible to blob out before some key parts of the life loop. This results in things getting dropped at null. TODO: Fix the code so this can be done better.
	remove_micros(src, src) //Living things don't fare well in roblobs.
	if(buckled)
		buckled.unbuckle_mob()
	if(LAZYLEN(buckled_mobs))
		for(var/buckledmob in buckled_mobs)
			riding_datum.force_dismount(buckledmob)
	if(pulledby)
		pulledby.stop_pulling()
	stop_pulling()

	var/client/C = client

	//Record where they should go
	var/atom/creation_spot = drop_location()

	//Create our new blob
	var/mob/living/simple_mob/protean_blob/blob = new(creation_spot,src)

	//Size update
	blob.transform = matrix()*size_multiplier
	blob.size_multiplier = size_multiplier

	if(l_hand) drop_from_inventory(l_hand)
	if(r_hand) drop_from_inventory(r_hand)

	//Put our owner in it (don't transfer var/mind)
	blob.ckey = ckey
	blob.ooc_notes = ooc_notes
	temporary_form = blob
	var/obj/item/device/radio/R = null
	if(isradio(l_ear))
		R = l_ear
	if(isradio(r_ear))
		R = r_ear
	if(R)
		blob.mob_radio = R
		R.forceMove(blob)
	if(wear_id)
		blob.myid = wear_id
		wear_id.forceMove(blob)

	//Mail them to nullspace
	moveToNullspace()

	//Message
	blob.visible_message("<b>[src.name]</b> collapses into a gooey blob!")

	//Duration of the to_puddle iconstate that the blob starts with
	sleep(13)
	blob.update_icon() //Will remove the collapse anim

	//Transfer vore organs
	blob.vore_organs = vore_organs.Copy()
	blob.vore_selected = vore_selected
	for(var/obj/belly/B as anything in vore_organs)
		B.forceMove(blob)
		B.owner = blob
	vore_organs.Cut()

	//We can still speak our languages!
	blob.languages = languages.Copy()
	blob.name = real_name
	blob.voice_name = name
	var/datum/species/protean/S = src.species
	blob.icon_living = S.blob_appearance
	blob.item_state = S.blob_appearance
	blob.update_icon()

	//Flip them to the protean panel
	addtimer(CALLBACK(src, .proc/nano_set_panel, C), 4)

	//Return our blob in case someone wants it
	return blob

//For some reason, there's no way to force drop all the mobs grabbed. This ought to fix that. And be moved elsewhere. Call with caution, doesn't handle cycles.
/proc/remove_micros(var/src, var/mob/root)
	for(var/obj/item/I in src)
		remove_micros(I, root) //Recursion. I'm honestly depending on there being no containment loop, but at the cost of performance that can be fixed too.
		if(istype(I, /obj/item/weapon/holder))
			root.remove_from_mob(I)

/mob/living/proc/usehardsuit()
	set name = "Utilize Hardsuit Interface"
	set desc = "Allows a protean blob to open hardsuit interface."
	set category = "Abilities"

	if(istype(loc, /obj/item/weapon/rig/protean))
		var/obj/item/weapon/rig/protean/prig = loc
		to_chat(src, "You attempt to interface with the [prig].")
		prig.ui_interact(src, interactive_state)
	else
		to_chat(src, "You are not in RIG form.")
//CHOMP Add end

/mob/living/carbon/human/proc/nano_outofblob(var/mob/living/simple_mob/protean_blob/blob, force)
	if(!istype(blob))
		return
	if(blob.loc == /obj/item/weapon/rig/protean) //CHOMP Add
		return //CHOMP Add
	if(!force && !isturf(blob.loc))
		to_chat(blob,"<span class='warning'>You can't change forms while inside something.</span>")
		return

	if(buckled)
		buckled.unbuckle_mob()
	if(LAZYLEN(buckled_mobs))
		for(var/buckledmob in buckled_mobs)
			riding_datum.force_dismount(buckledmob)
	if(pulledby)
		pulledby.stop_pulling()
	stop_pulling()

	var/client/C = blob.client

	//Stop healing if we are
	if(blob.healing)
		blob.healing.expire()

	if(blob.l_hand) blob.drop_from_inventory(blob.l_hand)
	if(blob.r_hand) blob.drop_from_inventory(blob.r_hand)

	if(blob.mob_radio)
		blob.mob_radio.forceMove(src)
		blob.mob_radio = null
	if(blob.myid)
		blob.myid.forceMove(src)
		blob.myid = null

	//Play the animation
	blob.icon_state = "from_puddle"

	//Message
	blob.visible_message("<b>[src.name]</b> reshapes into a humanoid appearance!")

	//Duration of above animation
	sleep(8)

	//Record where they should go
	var/atom/reform_spot = blob.drop_location()

	//Size update
	resize(blob.size_multiplier, FALSE, ignore_prefs = TRUE)

	//Move them back where the blob was
	forceMove(reform_spot)

	//Put our owner in it (don't transfer var/mind)
	ckey = blob.ckey
	ooc_notes = blob.ooc_notes // Lets give the protean any updated notes from blob form.
	temporary_form = null

	//Transfer vore organs
	vore_organs = blob.vore_organs.Copy()
	vore_selected = blob.vore_selected
	for(var/obj/belly/B as anything in blob.vore_organs)
		B.forceMove(src)
		B.owner = src
	languages = blob.languages.Copy()

	Life(1) //Fix my blindness right meow //Has to be moved up here, there exists a circumstance where blob could be deleted without vore organs moving right.

	//Get rid of friend blob
	qdel(blob)

	//Flip them to the protean panel
	addtimer(CALLBACK(src, .proc/nano_set_panel, C), 4)

	//Return ourselves in case someone wants it
	return src

/mob/living/carbon/human/proc/nano_set_panel(var/client/C)
	if(C)
		C.statpanel = "Protean"