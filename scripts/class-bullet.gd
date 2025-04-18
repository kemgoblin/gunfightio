extends Node3D
class_name BulletBase

## Base bullet class. DO NOT INSTANCE THIS. 
## Instance either a RayBullet or a PhysBullet when adding projectiles to the game.

@export_category("Bullet")
@export_range(0, 100) var damage := 0
@export_range(0.1, 10.0) var lifetime := 0.1
var user : Player


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0: queue_free()
