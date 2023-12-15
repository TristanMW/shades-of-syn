extends Node

### Collision data -> 
# Blue team is player 1 -> hurtbox layer 1
# Red team is player 2 -> hurtbox layer 2
# White team are third party enemies -> hurtbox layer 3

const BLUE_TEAM_HURTBOX_LAYER: int = 1
const RED_TEAM_HURTBOX_LAYER: int = 2
const WHITE_TEAM_HURTBOX_LAYER: int = 4 # layer 3 ( bit value is 2, 2^2 = 4)


### Map data
const SIZE_OF_VORTEX: float = 600.0
const SIZE_OF_SPAWN_AREA: float = 640.0
const SIZE_OF_HEXAGON: float = 5500.0



### Special abilities -> 
# Evade
const DASH_LENGTH: float = 0.5
const DASH_SPEED_INCREASE: float = 4.0
const DASH_ACCEL_INCREASE: float = 8.0

# War Cry, extra damage dealt
const WAR_CRY_DAMAGE_BOOST: float = 0.25

# Amplify - objective boost, chance to earn double favor
const AMPLIFY_CHANCE: float = 10.0

# Cloaking
const INVISIBILITY_LENGTH: float = 5.0

# Rejuvenate
const REJUVENATE_HEALTH_PERCENTAGE: float = 25.0

# Dispel, clear negative fx 

# Suppress (poison), slow damage + debuff 
const SUPPRESS_LENGTH: float = 5.0
const SUPPRESS_DAMAGE_PER_SECOND: float = 10.0
const SUPPRESS_SPEED_DECREASE: float = 0.25




enum character_type  {
	MAIN,
	ALLY,
	AD
}

# Player state constants
enum player_state {
	IDLE,
	WALK,
	ATTACK,
	CHARGED_ATTACK,
	ULTRA_ATTACK,
	DEATH,
}
# LOCKSTEP STATE
enum ally_movement_state {
	NORMAL,
	LOCKSTEP
}
const MIN_PLACE_OBJECT_DISTANCE: float = 400 # Distance the character is allowed to place a strcuture relative to their position

var structure_data = {
	"tower": {
		"class": "Unknown",
		"description": "Allows you to erect a tower (in or out of battle - can kill objectives).",
		"baseStats": {
			"health": 200,
			"damage": 30,
			"attackSpeed": 0.8,
			"movementSpeed": 10,
			"attackRange": 3
		},
	},
	"bio-forge": {
		"class": "Unknown",
		"description": "Produces minions to attack nearby enemies.",
		"baseStats": {
			"health": 200,
			"attackSpeed": 0.8,
			"movementSpeed": 10,
			"attackRange": 3
		},
	},
}

var ad_data = {
	"ghoul": {
		"class": "Unknown",
		"description": "A slow-moving swordsman.",
		"baseStats": {
			"health": 200,
			"damage": 30,
			"attackSpeed": 0.8,
			"movementSpeed": 10,
			"attackRange": 3
		},
	},
}

var character_data = {
	"technomancer": {
		"class": "Unknown",
		"description": "Placeholder description for Technomancer.",
		"baseStats": {
			"health": 330,
			"damage": 42,
			"attackSpeed": 1.0,
			"movementSpeed": 13,
			"attackRange": 8
		},
		"chargedAttack": {
			"description": "Triggers every 6th hit, dealing double damage.",
			"damage": 84
		},
		"ultimate": {
			"name": "Placeholder Ultimate Name",
			"type": "Placeholder Type",
			"description": "Placeholder description for the Ultimate Ability.",
			"totalDamage": 300,
			"damagePerAction": 100.0,  ## Individual damage per action
			"range": 10,
			"cooldown": 9
		}
	},
	"magmaul": {
		"class": "Unknown",
		"description": "Placeholder description for Magmaul.",
		"baseStats": {
			"health": 800,
			"damage": 25,
			"attackSpeed": 1.2,
			"movementSpeed": 9,
			"attackRange": 2
		},
	"chargedAttack": {
		"description": "Triggers every 6th hit, dealing double damage.",
		"damage": 50
		},
	"ultimate": {
		"name": "Placeholder Ultimate Name",
		"type": "Placeholder Type",
		"description": "Placeholder description for the Ultimate Ability.",
		"totalDamage": 180,
		"damagePerAction": 60.0,  ## Assuming the total damage is split into 3 actions
		"range": 4,
		"cooldown": 12
		}
	},
	"steelthorn": {
		"class": "Unknown",
		"description": "Placeholder description for Steelthorn.",
		"baseStats": {
			"health": 700,
			"damage": 25,
			"attackSpeed": 1.0,
			"movementSpeed": 11,
			"attackRange": 3
		},
		"chargedAttack": {
			"description": "Triggers every 6th hit, dealing double damage.",
			"damage": 50
		},
		"ultimate": {
			"name": "Placeholder Ultimate Name",
			"type": "Defense",
			"description": "Blocks a percentage of incoming damage for 3 seconds.",
			"damageBlock": "60.0%",
			"duration": 3,  ## Duration in seconds
			"range": 6,
			"cooldown": 9
		},
	},
	"canix": {
		"class": "Unknown",
		"description": "Placeholder description for Canix.",
		"baseStats": {
			"health": 360,
			"damage": 30,
			"attackSpeed": 0.7,
			"movementSpeed": 16,
			"attackRange": 3
		},
		"chargedAttack": {
			"description": "Triggers every 6th hit, dealing double damage.",
			"damage": 60
		},
		"ultimate": {
			"name": "Placeholder Ultimate Name",
			"type": "Action",
			"description": "Two-action attack: First, lunges forward and bites an enemy causing 100 damage. Second, drags the enemy back to the starting point causing 50 damage.",
			"actionOneDamage": 100,
			"actionTwoDamage": 50,
			"totalDamage": 150,  ## Total damage combining both actions
			"range": 6,
			"cooldown": 11
		}
	},
	"mariselle": {
		"class": "Unknown",
		"description": "Placeholder description for Mariselle.",
		"baseStats": {
			"health": 420,
			"damage": 27,
			"attackSpeed": 0.9,
			"movementSpeed": 13,
			"attackRange": 6
		},
		"chargedAttack": {
			"description": "Triggers every 6th hit, dealing double damage.",
			"damage": 54
		},
		"ultimate": {
			"name": "Placeholder Ultimate Name",
			"type": "Support",
			"description": "Heals all friendlies within range for 26% of their total health, occurring over three actions.",
			"healPercentagePerAction": 26,
			"totalHealPercentage": 78,
			"range": 8,
			"cooldown": 8
		}
	},
	"valkyrie": {
		"class": "Warrior",
		"description": "Melee swordsmith master, of an ancient race.",
		"baseStats": {
			"health": 350,
			"damage": 30,
			"attackSpeed": 0.8,
			"movementSpeed": 14,
			"attackRange": 3
		},
		"abilities": {
			"chargedAttack": {
				"description": "Every 6th Basic Attack does +100% Basic Attack Damage",
				"chargedAttackDamage": "Basic Damage + (Basic Damage*1.0)"
			},
		"ultimate": {
			"name": "Bladefury",
			"type": "Action",
			"description": "Spin around 3 times dealing damage each rotation to anything within range",
			"damagePerRotation": 60,
			"range": 5,
			"cooldown": 10
		}
	}
	}
}


