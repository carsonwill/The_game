extends CharacterBody2D
@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration : float = 15.0
@export var jumps = 1
enum state {IDLE, RUNNING, JUMPUP, JUMPDOWN, HURT,}
var anim_state = state.IDLE
@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration/2)
	move_and_slide()
