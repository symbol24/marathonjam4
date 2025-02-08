class_name DebugCommandMenu extends PanelContainer


@onready var output: RichTextLabel = %output
@onready var input: LineEdit = %input

var command_log:Array[String] = []
var command_log_pos:int = 0


func _ready() -> void:
	Debug.DebugPrint.connect(_output_text)
	visibility_changed.connect(_visibility_changed)


func _output_text(text:String = "") -> void:
	output.text += "\n"
	output.text += text


func _visibility_changed() -> void:
	if visible:
		input.grab_focus()
		input.text = ""