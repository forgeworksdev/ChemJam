class_name PlayerController extends CharacterBody3D

@onready var head_pivot: Node3D = $HeadPivot
@onready var camera: Camera3D = $HeadPivot/Camera3D

@onready var standing_collision: CollisionShape3D = $StandingCollisionShape3D
@onready var crouching_collision: CollisionShape3D = $CrouchingCollisionShape3D
@onready var interact_ray_cast_3d: RayCast3D = $HeadPivot/Camera3D/InteractRayCast3D
@onready var hand: Node3D = %Hand

@onready var ray_cast: RayCast3D = $RayCast3D

@export_group("Flags")
@export var can_move: bool
@export var can_jump: bool
@export var has_gravity: bool
@export var can_crouch: bool
@export var has_movement_vfx: bool
@export var can_interact: bool
@export var can_pickup: bool

@export_group("Speed Vars")
@export var WALK_SPEED: float = 5.0
@export var SPRINT_SPEED: float = 10.0
@export var CROUCH_SPEED: float = 2.5
@export var JUMP_VELOCITY: float = 4.5
@export var CROUCH_ACCEL: float = 7.0
@export var SPRINT_ACCEL: float = 7.0
@export var ACCEL: float = 7.0
@export var AIRBORNE_ACCEL: float = 2.0
@export var CAMERA_ZOOM_ACCEL: float = 8.0 #FIXME better var names and maybe tweak how these work


var speed: float = 0.0

var is_crouching: bool = false
var is_sprinting: bool = false
var default_height: float

const BOB_FREQ: float = 2.0
const BOB_AMP: float = .08
var bob_time: float = 0.0

@export_group("Camera Options")
@export var fov: float
@export var fov_increment: float = 5.0
@export_range(0.0, 100.0, 0.1) var mouse_sensitivity: float = 50.0
@export_range(-90.0, 0.0, 0.1) var min_look_angle: float = -90.0
@export_range(0.0, 90.0, 0.1) var max_look_angle: float = 90.0
@export var crouch_height: float = 1.0

@warning_ignore("unused_signal")
signal can_interact_signal
@warning_ignore("unused_signal")
signal can_pickup_signal

var current_helth: int = 0

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if fov == 0.0:
		fov = camera.fov
	else:
		camera.fov = fov
	default_height = head_pivot.position.y

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sensitivity = (mouse_sensitivity / 1000.0)
		head_pivot.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_look_angle), deg_to_rad(max_look_angle))

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_jump() -> void:
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ /2) * BOB_AMP
	return pos

func _crouch(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		head_pivot.position.y = lerp(head_pivot.position.y, crouch_height, delta * CROUCH_ACCEL)
	elif not ray_cast.is_colliding():
		is_crouching = false
		head_pivot.position.y = lerp(head_pivot.position.y, default_height, delta * CROUCH_ACCEL)

	standing_collision.disabled = is_crouching
	crouching_collision.disabled = not is_crouching

func _handle_movement(delta: float) -> void:
	is_sprinting = Input.is_action_pressed("sprint")
	if is_crouching:
		speed = CROUCH_SPEED
	elif is_sprinting:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	#checking head.transform.basis instead of transform.basis
	var direction: Vector3 = (head_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			#We can just set velocity to zero if there is no movement, but inertia yk?
			velocity.x = lerp(velocity.x, direction.x * speed, delta * ACCEL)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * ACCEL)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIRBORNE_ACCEL)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIRBORNE_ACCEL)

func _physics_process(delta: float) -> void:
	if has_gravity:
		_handle_gravity(delta)
	if can_jump:
		_handle_jump()
	if can_crouch:
		_crouch(delta)
	if can_move:
		_handle_movement(delta)
	if can_interact:
		pass
		#handle_interactions()

	if has_movement_vfx:
		#headbob
		bob_time += delta * velocity.length() * float(is_on_floor())
		if velocity.length() > 0.1 and is_on_floor():
			camera.transform.origin = _headbob(bob_time)
		else:
			camera.transform.origin = Vector3.ZERO

		#fov
		var clamped_velocity = clamp(Vector2(velocity.x, velocity.z).length() / SPRINT_SPEED, 0.0, 1)
		var target_fov = fov + (fov_increment * clamped_velocity)
		camera.fov = lerp(camera.fov, target_fov, delta * CAMERA_ZOOM_ACCEL)

	move_and_slide()
