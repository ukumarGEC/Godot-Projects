extends CanvasLayer

@onready var output_log: RichTextLabel = %RichTextLabel

func _ready() -> void:
	print("UI loaded")
	
func add_message(message: String) -> void:
	output_log.append_text(message + "\n")
	
	# Scroll to latest message
	await get_tree().process_frame
	output_log.scroll_to_line(output_log.get_line_count())
