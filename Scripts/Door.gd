extends Node3D

@onready var animation_player: AnimationPlayer = $DoorFrame/Door/AnimationPlayer
@onready var interact_area: Area3D = $"interact area"
var player_inside_interact_area: Node3D = null
var is_open = false

func _ready():
	#set up the enter callbacks
	self.interact_area.connect("body_entered", Callable(self, "on_body_entered"))
	self.interact_area.connect("body_exited", Callable(self, "on_body_exited"))
	

func on_body_entered(body) -> void:
	if body.is_in_group("group_player"):
		self.player_inside_interact_area = body
		
func on_body_exited(body) -> void:
	if body.is_in_group("group_player") and body == self.player_inside_interact_area:
		self.player_inside_interact_area = null
		
	
func _physics_process(_delta: float) -> void:
	if self.player_inside_interact_area == null or self.animation_player.is_playing():
		return
		
	var interact: bool = player_inside_interact_area.on_door_interact()
	
	if interact:
		self.animation_player.play("close" if self.is_open else "open")
		self.is_open = not self.is_open
		
	
