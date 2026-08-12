class_name StatsScreen extends Control

func show_stats(member: Character):
	visible = true
	
	%LevelNo.text = str(member.lv)
	%ExpNo.text   = str(member.xp)
	var next_xp = ceil(10.0 * pow(member.lv, 1.0 / 0.87))
	%NextNo.text = str(int(next_xp - member.xp))
	%HPNo.text    = str("%d/%d" % [member.hp, member.max_hp])
	%MPNo.text    = str("%d/%d" % [member.mp, member.max_mp])
	%AtkNo.text   = str(member.at + member.weapon.attack_increase + member.protection.attack_increase)
	%DefNo.text   = str(member.df + member.weapon.defense_increase + member.protection.defense_increase)
	
	%Weapon.text = member.weapon.name
	%Protector.text = member.protection.name
	
	%FireINo.text = str(int(member.fire_mult*100)) + "%"
	%IceINo.text  = str(int(member.freeze_mult*100)) + "%"
	%PhysINo.text = str(int(member.phys_mult*100)) + "%"

func show_improvements(member: Character, tool: Equipment):
	visible = true
	
	%LevelNo.text = str(member.lv)
	%ExpNo.text   = str(member.xp)
	%HPNo.text    = str("%d/%d" % [member.hp, member.max_hp])
	%MPNo.text    = str("%d/%d" % [member.mp, member.max_mp])
	
	var a := member.at + member.weapon.attack_increase + member.protection.attack_increase
	var b := member.df + member.weapon.defense_increase + member.protection.defense_increase
	
	var x = a
	var y = b
	
	var up = " (↑)"
	var down = " (↓)"
	var same = " (=)"
	
	if tool.slot == tool.Slot.WEAPON:
		x -= member.weapon.attack_increase
		y -= member.weapon.defense_increase
	elif tool.slot == tool.Slot.PROTECTION:
		x -= member.protection.defense_increase
		y -= member.weapon.defense_increase
	
	x += tool.attack_increase
	y += tool.defense_increase
	
	%AtkNo.text   = str(x)
	if x > a:
		%AtkNo.text += up
	elif x < a:
		%AtkNo.text += down
	elif x == a:
		%AtkNo.text += same
		
	%DefNo.text   = str(y)
	if y > b:
		%DefNo.text += up
	elif y < b:
		%DefNo.text += down
	elif y == b:
		%DefNo.text += same
	
	if tool.slot == tool.Slot.WEAPON:
		%Weapon.text = tool.name
	else:
		%Weapon.text = member.weapon.name
	
	if tool.slot == tool.Slot.PROTECTION:
		%Protector.text = tool.name
	else:
		%Protector.text = member.protection.name
	
	if tool.change_fire_mult:
		if tool.fire_mult > member.protection.fire_mult:
			%FireINo.text = str(int(tool.fire_mult*100)) + "%" + up
		elif tool.fire_mult < member.protection.fire_mult:
			%FireINo.text = str(int(tool.fire_mult*100)) + "%" + down
		else:
			%FireINo.text = str(int(tool.fire_mult*100)) + "%" + same
	else:
		%FireINo.text = str(int(member.fire_mult*100)) + "%"
		
	if tool.change_ice_mult:
		if tool.ice_mult > member.protection.ice_mult:
			%IceINo.text = str(int(tool.ice_mult*100)) + "%" + up
		elif tool.ice_mult < member.protection.ice_mult:
			%IceINo.text = str(int(tool.ice_mult*100)) + "%" + down
		else:
			%IceINo.text = str(int(tool.ice_mult*100)) + "%" + same
	else:
		%IceINo.text = str(int(member.freeze_mult*100)) + "%"
	
	if tool.change_phys_mult:
		if tool.phys_mult > member.protection.phys_mult:
			%PhysINo.text = str(int(tool.phys_mult*100)) + "%" + up
		elif tool.phys_mult < member.protection.phys_mult:
			%PhysINo.text = str(int(tool.phys_mult*100)) + "%" + down
		else:
			%PhysINo.text = str(int(tool.phys_mult*100)) + "%" + same
	else:
		%PhysINo.text = str(int(member.phys_mult*100)) + "%"
