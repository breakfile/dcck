class_name Equipment extends Item

enum Slot {
	WEAPON,
	PROTECTION
}

@export var slot: Slot = Slot.WEAPON
@export var attack_increase := 0
@export var defense_increase := 0
@export var skills: Array[Skill]

@export var change_fire_mult := false
@export var change_ice_mult := false
@export var change_phys_mult := false
@export var fire_mult := 1.0
@export var ice_mult := 1.0
@export var phys_mult := 1.0

func on_use(caster: Character):
	var enemy = false
	if caster.target.bs:
		if caster.target in caster.target.bs.enemies:
			enemy = true
	
	if slot == Slot.WEAPON:
		if caster.target.weapon.name != "Fist" and not enemy: Global.items.append(caster.target.weapon)
		caster.target.weapon = self
	elif slot == Slot.PROTECTION:
		if caster.target.protection.name != "Resiliance" and not enemy: Global.items.append(caster.target.protection)
		caster.target.protection = self
	
	if slot == Slot.PROTECTION:
		if change_fire_mult: caster.target.fire_mult = fire_mult
		else: caster.target.fire_mult = caster.target.default_fire_mult
		if change_ice_mult: caster.target.freeze_mult = ice_mult
		else: caster.target.freeze_mult = caster.target.default_freeze_mult
		if change_phys_mult: caster.target.phys_mult = phys_mult
		else: caster.target.phys_mult = caster.target.default_phys_mult
	
	await DialogueBox.type("> %s equipped %s." % [caster.target.character_name, name])
	if DialogueBox.verbose: # TODO: Find out why I did this at all (don't remember)
		Global.items.erase(self)
