extends Node

# Autoload singleton for database operations
var db_manager = null

func _ready():
	# Load and instantiate DatabaseManager
	var DatabaseManager = load("res://Scripts/DatabaseManager.gd")
	db_manager = DatabaseManager.new()
	add_child(db_manager)
	print("Database system initialized")
