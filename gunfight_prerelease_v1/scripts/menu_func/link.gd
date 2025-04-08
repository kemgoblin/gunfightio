extends Button

# Set your desired URL here
@export var url: String = "https://example.com"

func _pressed():
	if url != "":
		OS.shell_open(url)
