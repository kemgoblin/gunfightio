extends Button

func _ready():
	# Ensure child starts hidden
	if get_child_count() > 0:
		get_child(0).visible = false

func _pressed():
	# Show the first child
	if get_child_count() > 0:
		get_child(0).visible = true

func _process(delta):
	if Input.is_action_just_pressed("back"):
		if get_child_count() > 0:
			get_child(0).visible = false
