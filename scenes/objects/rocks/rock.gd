extends Sprite2D
# 从small_tree.gd修改

@onready var damage_component: DamageComponent = $DamageComponent
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var mining_particles: GPUParticles2D = $MiningParticles
# 引入组件，这个脚本将用于连接组件和粒子效果
var stone_scene = preload("res://scenes/objects/rocks/stone.tscn")
# 加载石头场景
var shake_tween: Tween
# 摇晃动画的 Tween 引用，用于快速连续击中时重置


func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	# 连接受击组件的hurt信号到on_hurt函数
	damage_component.max_damage_reached.connect(on_max_damage_reached)
	# 连接伤害组件的max_damage_reached信号到max_damage_reached函数
	mining_particles.emitting = false
	# 确保粒子初始不发射

func on_hurt(hit_damage : int) -> void :
	damage_component.apply_damage(hit_damage)
	# 受到伤害时，将伤害发送到伤害组件

	# 杀掉旧的摇晃动画，防止多次击中时动画重叠
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()

	material.set_shader_parameter("shake_intensity", 0.0)
	

	# 用 Tween 替代 await：每次新击中都会 kill 旧动画重新计时
	shake_tween = create_tween()
	shake_tween.tween_interval(0.3)
	# 等待0.3秒后发射粒子并开始摇晃
	shake_tween.tween_callback(func():
		mining_particles.emitting = true
		material.set_shader_parameter("shake_intensity", 0.3)
	)
	shake_tween.tween_interval(0.5)
	# 摇晃持续0.5秒
	shake_tween.tween_callback(func(): material.set_shader_parameter("shake_intensity", 0.0))
	# 取消摇晃效果
	
func on_max_damage_reached() -> void :
	call_deferred("add_stone_scene")
	# 达到最大伤害时，删除自己
	queue_free()

func add_stone_scene() -> void :
	var stone_instance = stone_scene.instantiate() as Node2D
	# 实例化一个石头对象并转换为Node2D
	stone_instance.global_position = global_position
	get_parent().add_child(stone_instance)
	
