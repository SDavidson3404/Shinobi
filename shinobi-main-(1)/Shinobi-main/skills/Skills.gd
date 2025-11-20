extends Node
# ========== SKILLS ===========
var skill_data := {
	"dodge": {
		"name": "Dodge",
		"cost": 1,
		"prereq": []
	},
	"double_jump": {
		"name": "Double Jump",
		"cost": 2,
		"prereq": ["dodge"]
	},
	"wall_run" : {
		"name": "Wall Run",
		"cost": 3,
		"prereq": ["double_jump"]
	},
	"wall_scramble" : {
		"name": "Wall Scramble",
		"cost": 4,
		"prereq": ["wall_run"]
	},
	"weapon_throw" : {
		"name": "Weapon Throw",
		"cost": 5,
		"prereq": ["wall_scramble"]
	},
	"spear_unlock" : {
		"name": "Spear Unlock",
		"cost": 1,
		"prereq": ["dodge"]
	},
	"dagger_unlock" : {
		"name": "Dagger unlock",
		"cost": 3,
		"prereq": ["spear_unlock"]
	},
	"burst_mode" : {
		"name": "Burst Mode",
		"cost": 4,
		"prereq": ["dagger_unlock"]
	},
	"stamina1" : {
		"name": "Stamina +5",
		"cost": 1,
		"prereq": ["dodge"]
	},
	"stamina2" : {
		"name": "Stamina +10",
		"cost": 2,
		"prereq": ["stamina1"]
	},
	"stamina3" : {
		"name": "Stamina +15",
		"cost": 3,
		"prereq": ["stamina2"]
	},
	"stamina4" : {
		"name": "Stamina +20",
		"cost": 4,
		"prereq": ["stamina3"]
	},
	"stamina5" : {
		"name": "Stamina +25",
		"cost": 5,
		"prereq": ["stamina4"]
	},
	"health1" : {
		"name": "Health +5",
		"cost": 1,
		"prereq": ["dodge"]
	},
	"health2" : {
		"name": "Health +10",
		"cost": 2,
		"prereq": ["health1"]
	},
	"health3" : {
		"name": "Health +15",
		"cost": 3,
		"prereq": ["health2"]
	},
	"health4" : {
		"name": "Health +20",
		"cost": 4,
		"prereq": ["health3"]
	},
	"health5" : {
		"name": "Health +25",
		"cost": 5,
		"prereq": ["health4"]
	},
	"dull_dagger" : {
		"name": "Dull Dagger",
		"cost": 1,
		"prereq": ["dagger_unlock"]
	},
	"sharp_dagger" : {
		"name": "Sharp Dagger",
		"cost": 2,
		"prereq": ["dull_dagger"]
	},
	"iron_dagger" : {
		"name": "Iron Dagger",
		"cost": 3,
		"prereq": ["sharp_dagger"]
	},
	"gem_dagger" : {
		"name": "Gem Dagger",
		"cost": 4,
		"prereq": ["iron_dagger"]
	},
	"buster_dagger" : {
		"name": "Buster Dagger",
		"cost": 5,
		"prereq": ["gem_dagger"]
	},
	"dull_spear" : {
		"name": "Dull Spear",
		"cost": 1,
		"prereq": ["spear_unlock"]
	},
	"sharp_spear" : {
		"name": "Sharp Spear",
		"cost": 2,
		"prereq": ["dull_spear"]
	},
	"steel_spear" : {
		"name": "Steel Spear",
		"cost": 3,
		"prereq": ["sharp_spear"]
	},
	"gilded_spear" : {
		"name": "Gilded Spear",
		"cost": 4,
		"prereq": ["steel_spear"]
	},
	"the_ultima_spear" : {
		"name": "The Ultima Spear",
		"cost": 5,
		"prereq": ["gilded_spear"]
	},
	"dull_sword" : {
		"name": "Dull Sword",
		"cost": 1,
		"prereq": ["dodge"]
	},
	"sharp_sword" : {
		"name": "Sharp Sword",
		"cost": 2,
		"prereq": ["dull_sword"]
	},
	"forged_sword" : {
		"name": "Forged Sword",
		"cost": 3,
		"prereq": ["sharp_sword"]
	},
	"steel_sword" : {
		"name": "Steel Sword",
		"cost": 4,
		"prereq": ["forged_sword"]
	},
	"pure_sword" : {
		"name": "Pure Sword",
		"cost": 5,
		"prereq": ["steel_sword"]
	},
}
