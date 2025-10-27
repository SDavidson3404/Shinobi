extends CanvasLayer

@onready var color_rect := ColorRect.new()

func _ready():
	color_rect.color = Color.BLACK
	color_rect.visible = true
	color_rect.modulate.a = 1.0
	add_child(color_rect)
	await get_tree().create_timer(0.2).timeout
	await fade_in()

func fade_in(duration := 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished

func fade_out(duration := 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

func change_scene_with_fade(scene_path: String) -> void:
	await fade_out(1.0)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().create_timer(0.1).timeout
	await fade_in(1.0)
