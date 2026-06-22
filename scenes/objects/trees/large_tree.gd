extends Sprite2D

@onready var hurt_component: HurtComponent = $HurtComponent
@onready var damage_component: DamageComponent = $DamageComponent
# 引入俩个组件，这个脚本将用于连接俩个组件
var log_scene = preload("res://scenes/objects/trees/log.tscn")
# 加载原木场景


func _ready() -> void:
	hurt_component.hurt.connect(on_hurt)
	# 连接受击组件的hurt信号到on_hurt函数
	damage_component.max_damage_reached.connect(on_max_damage_reached)
	# 连接伤害组件的max_damage_reached信号到max_damage_reached函数
	
func on_hurt(hit_damage : int) -> void :
	damage_component.apply_damage(hit_damage)
	# 受到伤害时，将伤害发送到伤害组件
	await get_tree().create_timer(0.4).timeout
	# 等待0.4秒后开始摇晃
	material.set_shader_parameter("shake_intensity",0.8)
	# 调用着色器的设置参数函数修改摇晃强度为0.8
	await get_tree().create_timer(1.2).timeout
	# 临时1.2秒定时器
	material.set_shader_parameter("shake_intensity",0.0)
	# 取消摇晃效果
	
func on_max_damage_reached() -> void :
	call_deferred("add_log_scene")
	# 因为涉及到删除自己，使用call_deferred延迟到安全时机调用add_log_scene
	print("Max damage reached")
	# 达到最大伤害时，删除自己
	queue_free()

func add_log_scene() -> void :
	var log_instance = log_scene.instantiate() as Node2D
	# 实例化一个原木对象并转换为Node2D
	log_instance.global_position = global_position
	# 将原木的位置设置为树的全局位置
	get_parent().add_child(log_instance)
	# 将原木添加到当前节点同层级
	
