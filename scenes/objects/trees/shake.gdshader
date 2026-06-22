shader_type canvas_item;
// 这个着色器用于实现树木的晃动效果

// uniform参数类似gdscript中的@export，用于在着色器面板中直接填写
uniform float shake_intensity = 0.0;
// 晃动强度
uniform float shake_speed = 20 ;
// 晃动速度

void vertex() {
	// 顶点着色器
	vec2 shake = vec2(0,0);
	
	if(VERTEX.y < 0.0){
		// 只对y<0(即树木躯干和以上)部分施加摇晃效果
		shake.x = sin(TIME * shake_speed + VERTEX.y) * shake_intensity;
		// 使用时间和sin函数来制造摇晃
	}
	
	VERTEX.xy += shake;
	// 应用摇晃效果
}
