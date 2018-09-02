extends Node


func _ready():
	pass
	
func _process(delta):
	pass

func _on_MessageTimer_timeout():
	hide_message()

func set_message(text):
	$Message/MessageLabel.text = text

func show_message():
	$Message/ColorRect.show()
	$Message/MessageLabel.show()
	$Message/MessageTimer.start()

func hide_message():
	$Message/ColorRect.hide()
	$Message/MessageLabel.hide()
