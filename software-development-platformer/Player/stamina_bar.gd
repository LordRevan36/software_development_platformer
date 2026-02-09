extends TextureProgressBar

@onready var player := get_tree().get_first_node_in_group("Player")
var stam_tween: Tween
@export var player_path: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = player.MAX_Stamina
	value = player.stamina
	GlobalPlayer.stamina_changed.connect(update_stamina)

func update_stamina(current: float, max_stam: float, duration: float):
	max_value = max_stam
	stam_tween = create_tween()
	stam_tween.tween_property(
		self,
		"value",
		current,
		duration
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
