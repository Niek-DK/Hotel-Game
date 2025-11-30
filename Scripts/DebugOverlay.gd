extends Node

var _label_cache: Dictionary[String, Label] = {}
var _overlay: FlowContainer

func _ready():
	if not OS.is_debug_build():
		return
		
	_overlay = FlowContainer.new()
	_overlay.position = Vector2.ZERO
	self.add_child(_overlay)

func _input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or not event.is_action_pressed("debug_overlay_toggle") or event.echo:
		return
	
	_overlay.visible = not _overlay.visible
	
func push_item(id: String, message: String, color: Color = Color.CHARTREUSE) -> void:
	var label: Label = null

	if _label_cache.has(id) and is_instance_valid(_label_cache[id]):
		label = _label_cache[id]
	else:
		label = Label.new()
		_label_cache[id] = label
		_overlay.add_child(label)  
	
	label.text = "[Debug]: {msg}".format({"msg": message}) 
	label.modulate = color

func pop_item(id: String) -> void:
	if not _label_cache.has(id):
		print("Overlay does not contain a item with id: {id}".format({"id": id}))
		return
	
	_label_cache[id].queue_free()
	_label_cache.erase(id)	
