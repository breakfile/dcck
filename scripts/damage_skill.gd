class_name DamageSkill extends Skill
@export var multiplier: float = 1
@export var attack_type: Character.AttackType = Character.AttackType.PHYS

func cast(caster: Character):
	await super.cast(caster)
	var damage = ((((caster.at + caster.at_w + caster.weapon.attack_increase + caster.protection.attack_increase) * multiplier)) * 1.5) - (caster.target.df + caster.target.df_w + caster.target.weapon.defense_increase + caster.target.protection.defense_increase)
	await caster.target.hurt(damage, attack_type)
