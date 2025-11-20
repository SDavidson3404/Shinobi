# GameState.gd
extends Node

var init = false
# Use a dictionary to track collected items by unique ID
var collected_items : Dictionary = {
	"1" : false,
	"2" : false,
	"3" : false
}
