class_name DbgResetSceneSkill extends Skill

func cast(caster: Character):
	await super.cast(caster)
	caster.tree.reload_current_scene()
