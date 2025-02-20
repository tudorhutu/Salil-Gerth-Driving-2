extends TextureProgressBar

@export var base_fill_rate: float = 1.0
@export var speed_multiplier: float = 0.1
@export var obstacle_hit_amount: float = 1000.0

var is_triggered: bool = false
var hue: float = 0.0
var under_mat: ShaderMaterial

func _ready() -> void:
	SignalBus.connect("obstacle_hit", Callable(self, "on_obstacle_hit"))
	SignalBus.connect("powerup_hit", Callable(self, "on_powerup_hit"))
	# Get the "under" texture from this TextureProgressBar.
	var under_tex: Texture2D = get("under") as Texture2D
	# Create a shader that applies a hue shift.
	var shader: Shader = Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float hue_offset : hint_range(0.0, 1.0) = 0.0;
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(0.0, 1.0/3.0, 2.0/3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}
void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 hsv = rgb2hsv(tex_color.rgb);
	hsv.x = fract(hsv.x + hue_offset);
	vec3 rgb = hsv2rgb(hsv);
	COLOR = vec4(rgb, tex_color.a);
}
	"""
	under_mat = ShaderMaterial.new()
	under_mat.shader = shader
	under_mat.set_shader_parameter("hue_offset", 0.0)
	material = under_mat

func _process(delta: float) -> void:
	value += (base_fill_rate + Global.player_speed * speed_multiplier) * delta * 100
	if value > max_value:
		value = max_value
	if value >= max_value and not is_triggered:
		is_triggered = true
		trigger_borasc()
	Global.distance += Global.player_speed * delta
	
	hue += delta * 0.1
	if under_mat:
		under_mat.set_shader_parameter("hue_offset", fmod(hue, 1.0))

func on_obstacle_hit(area: Area2D) -> void:
	value += obstacle_hit_amount
	if value > max_value:
		value = max_value
		
func on_powerup_hit(area: Area2D) -> void:	
	value -= 700.0
	if value < 0:
		value = 0
		
func trigger_borasc() -> void:
	SignalBus.emit_signal("BORASC")
	await get_tree().create_timer(2.0).timeout
	value = 0
	is_triggered = false
