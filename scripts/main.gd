extends Node2D

@onready var critter: Critter = $Critter
@onready var toast_banner: Label = $CanvasLayer/ToastBanner

var coins: int = 100
var inventory: Array[String] = ["Pho Bo", "Banh Mi"]

func _ready() -> void:
	if toast_banner:
		toast_banner.text = "Welcome to Cozy Critter Haven!"
		toast_banner.position = Vector2(40, 60) # Placed safely above critter
		toast_banner.visible = true

func show_toast(msg: String) -> void:
	if toast_banner:
		toast_banner.text = msg
		toast_banner.visible = true
