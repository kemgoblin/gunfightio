@tool
extends StaticBody3D
class_name Map


func _ready() -> void:
	### This bit of the _ready function simplifies the process of creating new maps in the editor.
	### It auto-creates child nodes that would otherwise be tedious to manually add every time.
	if Engine.is_editor_hint(): 
		if get_child_count() > 0: return
		
		#var TEMPLATE = Node.new()
		#TEMPLATE.name = ""
		#add_child(TEMPLATE)
		#TEMPLATE.set_owner(get_tree().edited_scene_root)
		
		var mesh = MeshInstance3D.new()
		mesh.name = "mesh"
		add_child(mesh)
		mesh.set_owner(get_tree().edited_scene_root)
		
		# Add collection-type nodes
		for collection_name in ["spawns", "lights"]:
			var collection = Node3D.new()
			collection.name = collection_name
			add_child(collection)
			collection.set_owner(get_tree().edited_scene_root)
		return
	
	# Rename spawns to numbers for in-game processing.
	var index = 0
	for spawn in $spawns.get_children():
		spawn.name = str(index)
		index += 1
