extends Node


@export var pellet_scene: PackedScene
@export var enemy_scene: PackedScene

@onready var player_start = $StartPositions/PlayerStartPosition
@onready var pellet_tilemap: TileMapLayer = $Maze/PelletMarker
@onready var blinky: CharacterBody2D = $Ghosts/Blinky
@onready var pinky: CharacterBody2D = $Ghosts/Pinky
@onready var inky: CharacterBody2D = $Ghosts/Inky
@onready var clyde: CharacterBody2D = $Ghosts/Clyde



const MAX_LIVES: int = 3
const GHOST_COUNT: int = 4

var score: int = 0
var current_lives: int
var ghosts: Array = []
var tile_size = 64


func _ready() -> void:
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()
	
	$Player.player_hit.connect(_on_player_hit)
	$ReadyTimer.timeout.connect(_on_ready_timer_timeout)
	$BigPellets/BigPellet.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	$BigPellets/BigPellet2.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	$BigPellets/BigPellet3.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	$BigPellets/BigPellet4.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	
	$Maze.hide()
	$BigPellets.hide()
	$SmallPellets.hide()
	pellet_tilemap.hide()

func _process(_delta: float) -> void:
	pass

func _on_ui_game_started():
	get_tree().paused = true

	spawn_pellets()
	spawn_enemies()
	current_lives = MAX_LIVES
	score = 0
	$UI/HUD.update_score(score)
	$Player.position = player_start.position
	$Player.reset_player()
	$Maze.show()
	$BigPellets.show()
	play_game_music()
	$ReadyTimer.start()
	$UI/HUD.show_message("GET READY")
	
	$Player.set_process(true)
	$Player.set_physics_process(true)
	$Player.set_process_unhandled_input(true)
	
func setup_ghosts():
	pass
	
func _on_ready_timer_timeout():
	get_tree().paused = false
	
func play_main_menu_music():
	$Audio/AudioGameplay.stop()
	$Audio/AudioMainMenu.play()
	
func play_game_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.play()
	
func stop_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.stop()
	
func spawn_pellets():
	for cell in pellet_tilemap.get_used_cells():
		var world_pos = pellet_tilemap.map_to_local(cell)
		var pellet: Pellet = pellet_scene.instantiate()
		$SmallPellets.add_child(pellet)
		pellet.small_pellet_picked_up.connect(_on_small_pellet_picked_up)
		pellet.add_to_group("small_pellet")
		pellet.position = world_pos
	$SmallPellets.show()
	pellet_tilemap.clear()
	
func spawn_enemies():
	blinky.position = $StartPositions/BlinkyStartPosition.position
	pinky.position = $StartPositions/PinkyStartPosition.position
	inky.position = $StartPositions/InkyStartPosition.position
	clyde.position = $StartPositions/ClydeStartPosition.position
	
	blinky.set_current_state("CHASING")
	pinky.set_current_state("IDLE")
	inky.set_current_state("IDLE")
	clyde.set_current_state("IDLE")
	
	blinky.show()
	pinky.show()
	inky.show()
	clyde.show()
	
func _on_big_pellet_picked_up():
	pass
	#$Ghost.scatter()
	
func _on_small_pellet_picked_up():
	score += 1
	$UI/HUD.update_score(score)
	
func _on_player_hit():
	current_lives -= 1
	$UI/HUD.update_lives(current_lives)
	if current_lives <= 0:
		game_over()
	else:
		get_tree().paused = true
		$Player.reset_player()
		$Player.position = player_start.position
		$ReadyTimer.start()
		$UI/HUD.show_message("GET READY")
		get_tree().paused = false
	
func game_over():
	$Player.set_process(false)
	$Player.set_physics_process(false)
	$Player.set_process_unhandled_input(false)
	stop_music()
	$Player.play_death_animation()
	await $UI/HUD.show_game_over()
	$UI.open_main_menu()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("big_pellet", "queue_free")
	get_tree().call_group("small_pellet", "queue_free")
	play_main_menu_music()
	
