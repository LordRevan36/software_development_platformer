extends Node

#smoothly increases the size of the text when hovering
func growTween(button):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.2,1.2), 0.1)
	
#smoothly decreases the size of the text when hovering
func shrinkTween(button):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1,1), 0.1)
