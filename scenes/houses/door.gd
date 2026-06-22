extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var interactalbe_component: InteractalbeComponet = $InteractalbeComponent

func _ready() -> void:
	interactalbe_component.interacrtable_activated.connect(on_interacrtable_activated)
	interactalbe_component.interacrtable_deactivated.connect(on_interacrtable_deactivated)
	collision_layer = 1
	
func on_interacrtable_activated() -> void:
	animated_sprite_2d.play("open_door")
	print("activated")
	collision_layer = 2
	# 临时将碰撞层改为玩家同一层以允许玩家通过
	
func on_interacrtable_deactivated() -> void:
	animated_sprite_2d.play("close_door")
	print("deactivated")
	collision_layer = 1
