@tool
class_name Layer extends PanelContainer


enum COLOR{GREEN, RED, GRAY}
var _color_map = {
	COLOR.GREEN : Color.GREEN,
	COLOR.RED : Color.RED,
	COLOR.GRAY : Color.GRAY,
}
@export var color:COLOR = COLOR.GRAY:
	set(new):
		color = new
		#print(%ColorPanel["theme_override_styles/panel"])
		if is_node_ready():
			%ColorPanel["theme_override_styles/panel"]["bg_color"] = _color_map[new]
	get: return color

@export_multiline
var text:String = "this is a Line .....":
	set(new): 
		text = new
		if is_node_ready():
			%Line.text = new
	get: 
		return text
