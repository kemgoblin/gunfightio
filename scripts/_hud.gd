extends Control

## NODES ##
@onready var health_bar := $health/bar
@onready var points_label := $points
@onready var reticle := $reticle
@onready var ammo_counter := $ammo/counter
@onready var ammo_extra := $ammo/extra
@onready var ammo_icon_template := $ammo/counter/_template
@onready var shoot_indicator := $shoot_indicator
@onready var damage_indicator := $damage_indicator

## HEALTH ##
var hp_target = 100
const HP_LERP_RATE = 0.1
const HP_LERP_MARGIN = 2

## AMMO ##
var full_color: Color = Color.WHITE
var empty_color: Color = Color.BLACK
var current_weapon_name := ""

## SHOOT INDICATOR ##
var shoot_indicator_alpha := 0.0
var shoot_indicator_fade_timer := 0.0

func _ready() -> void:
	ammo_counter.remove_child(ammo_icon_template)
	damage_indicator.modulate.a = 0.0  # Ensure invisible at start
	shoot_indicator.modulate.a = 0.0   # Also start fully invisible

func _process(delta: float) -> void:
	# Health
	if abs(hp_target - health_bar.value) > HP_LERP_MARGIN:
		health_bar.value = lerp(health_bar.value, float(hp_target), HP_LERP_RATE)
	else:
		health_bar.value = hp_target

	# Shoot indicator fade
	if shoot_indicator_fade_timer > 0.0:
		shoot_indicator_fade_timer -= delta
	elif shoot_indicator_alpha > 0.0:
		shoot_indicator_alpha = max(shoot_indicator_alpha - delta * 2.5, 0.0)
		shoot_indicator.modulate.a = shoot_indicator_alpha

func update_ammo():
	var weapon: Weapon = get_parent().current_weapon

	if not current_weapon_name == weapon.name:
		# Switching weapons: clear icons
		for bullet in ammo_counter.get_children():
			bullet.name += "F"
			bullet.queue_free()

		for index in range(0, weapon.max_ammo):
			var bullet = ammo_icon_template.duplicate()
			bullet.name = str(index + 1)
			bullet.texture = weapon.ammo_icon
			ammo_counter.add_child(bullet)

		current_weapon_name = weapon.name

	# Update current ammo icons
	for bullet in ammo_counter.get_children():
		var curr_count = bullet.name.to_int()
		bullet.modulate = empty_color
		if curr_count <= weapon.current_ammo:
			bullet.modulate = full_color

	ammo_extra.text = str(get_parent().ammo[weapon.name])

func update_score():
	points_label.text = str(get_parent().current_score)

func fade_reticle(show: bool) -> void:
	var target_alpha = 1.0 if show else 0.0
	var tween = create_tween()
	tween.tween_property(reticle, "modulate:a", target_alpha, 0.2)

func flash_damage_indicator():
	var tween = get_tree().create_tween()
	damage_indicator.modulate.a = 0.8
	tween.tween_property(damage_indicator, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func flash_shoot_indicator():
	shoot_indicator_alpha = 0.4
	shoot_indicator_fade_timer = 0.25  # Seconds before fading starts
	shoot_indicator.modulate.a = shoot_indicator_alpha
