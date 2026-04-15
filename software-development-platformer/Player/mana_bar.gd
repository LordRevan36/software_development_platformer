extends TextureProgressBar

@onready var player := get_tree().get_first_node_in_group("Player")
var mana_tween: Tween
@export var player_path: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = GlobalPlayer.MAX_Mana
	value = player.Mana
	GlobalPlayer.mana_changed.connect(update_mana)

func update_mana(current: float, max_mana: float, duration):
	max_value = max_mana
	mana_tween = create_tween()
	mana_tween.tween_property(
		self,
		"value",
		current,
		duration
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
