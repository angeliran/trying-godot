extends CharacterBody2D

@onready var collision_shape = $CollisionShape2D
@onready var slide_shape = RectangleShape2D.new()
@onready var attack_shape = RectangleShape2D.new()

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SLIDE_DURATION = 0.7  
const ATACK_DURATION = 0.7 

var is_atacking = false  
var is_sliding = false  

func _ready():
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.extents = Vector2(16, 32) 

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_sliding and not is_atacking:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0 and not is_atacking:
		$AnimatedSprite2D.flip_h = false
		collision_shape.position.x = -10
	elif direction < 0 and not is_atacking:
		$AnimatedSprite2D.flip_h = true
		collision_shape.position.x = 10

	if direction != 0 and not is_atacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif is_sliding:
		pass
	elif is_atacking:
		pass
	elif velocity.x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and not is_atacking:
		start_slide_animation()

	if Input.is_action_just_pressed("atack") and is_on_floor() and not is_sliding and not is_atacking:
		start_atack_animation()	

	move_and_slide()

func start_atack_animation() -> void:
	var original_pos = collision_shape.position  
	var orientation = 50 if not $AnimatedSprite2D.flip_h else -50
	is_atacking = true

	$AnimatedSprite2D.play("atack2")

	change_collision_shape(attack_shape, Vector2(62, 32), Vector2(orientation, original_pos.y))

	await get_tree().create_timer(ATACK_DURATION).timeout

	is_atacking = false

	change_collision_shape(RectangleShape2D.new(), Vector2(16, 32), original_pos)

func start_slide_animation() -> void:
	var original_pos = collision_shape.position  
	is_sliding = true

	$AnimatedSprite2D.play("slide")

	change_collision_shape(slide_shape, Vector2(32, 16), Vector2(0, 60))

	await get_tree().create_timer(SLIDE_DURATION).timeout
	
	is_sliding = false

	change_collision_shape(RectangleShape2D.new(), Vector2(16, 32), original_pos)

func change_collision_shape(new_shape: RectangleShape2D, new_extents: Vector2, new_position: Vector2) -> void:
	collision_shape.shape = new_shape
	collision_shape.shape.extents = new_extents
	collision_shape.position = new_position
