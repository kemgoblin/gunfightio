extends Node

# Dictionary to hold all preloaded particle scenes
var particle_cache = {}

# List of paths to your particle scenes
var particle_paths = [
	"res://assets/pfx/bloodspatter/blood_spatter.tscn",
	"res://addons/MrMinimal'sVFX/game/entities/vfx/sparks_metal/sparks_metal.tscn",
	"res://core/player.tscn",
	"res://assets/rigs/arms-AKS74.tscn",
	"res://assets/rigs/arms-TarusJudge.tscn",
]

func _ready():
	preload_particles()

func preload_particles():
	for path in particle_paths:
		var scene = load(path)
		if scene:
			# Store it in the cache using its filename (or full path)
			var key = path.get_file().get_basename()
			particle_cache[key] = scene
			print("Preloaded:", key)
		else:
			print("Failed to load particle at:", path)

# You can call this function anywhere in your game to instance a particle
func spawn_particle(particle_name: String) -> Node:
	if particle_name in particle_cache:
		return particle_cache[particle_name].instantiate()
	else:
		push_error("Particle not found in cache: %s" % particle_name)
		return null
