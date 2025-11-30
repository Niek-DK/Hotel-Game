extends CharacterBody3D


@export_category("movement")
@export var movement_speed: float = 5.0
@export var accelaration_lerp_speed: float = 3.5
@export var decelaration_lerp_speed: float = 5.5

@export_category("head bobbing")
@export var head_bobbing_frequency: float = 2.5
@export var head_bobbing_amplitude: float = 0.05
var         head_bobbing_index: float = 0

@export_category("camera")
@export var sensitivity: float = 0.2

@onready var head: Node3D = $head
@onready var camera: Camera3D = $"head/first person camera"

func on_door_interact() -> bool:
	if Input.is_action_pressed("player_interact"):
		return true
	return false

func get_input_direction() -> Vector3:
	var input_direction: Vector2 = Input.get_vector("player_moveLeft", "player_moveRight", "player_moveForward", "player_moveBackward")
	return (self.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
func get_headbob_direction(delta: float) -> Vector3:
		
	var offset: Vector3 = Vector3.ZERO
	
	self.head_bobbing_index += delta * self.velocity.length()
	offset.y = sin(self.head_bobbing_index * self.head_bobbing_frequency) * head_bobbing_amplitude
	offset.x = cos(self.head_bobbing_index * self.head_bobbing_frequency / 2) * head_bobbing_amplitude / 2
	
	return offset
	
func move(direction: Vector3, delta: float) -> void:
	#slowly come to a stop if not input is given
	if not direction:
		self.velocity.x = lerpf(self.velocity.x, 0.0, delta * self.decelaration_lerp_speed)
		self.velocity.z = lerpf(self.velocity.z, 0.0, delta * self.decelaration_lerp_speed)
		return
		
	self.velocity.x = lerpf(self.velocity.x, direction.x * self.movement_speed, delta * self.accelaration_lerp_speed)
	self.velocity.z = lerpf(self.velocity.z, direction.z * self.movement_speed, delta * self.accelaration_lerp_speed)
		
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is not InputEventMouseMotion:
		return
	
	#horizonatal
	self.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
	
	#vertical
	head.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
	head.rotation.x = clampf(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _process(delta: float) -> void:
	DebugOverlay.push_item("id_player_label_position", "player position: {pos}".format({"pos": self.position}))
	DebugOverlay.push_item("id_player_label_velocity", "player velocity: {vel}".format({"vel": self.velocity}))
	

func _physics_process(delta: float) -> void:
	
	#gravity
	if not is_on_floor():
		self.velocity += get_gravity() * delta

	#head bobbing
	camera.transform.origin = self.get_headbob_direction(delta)
	
	#moving
	self.move(self.get_input_direction(), delta)

	move_and_slide()
