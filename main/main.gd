extends Node


@export var pellet_scene: PackedScene
@export var enemy_scene: PackedScene

@onready var player_start = $StartPositions/PlayerStartPosition
@onready var pellet_tilemap: TileMapLayer = $Maze/PelletMarker


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
	$BigPellets.hide()
	spawn_pellets()

func _process(_delta: float) -> void:
	pass

func _on_ui_game_started():
	get_tree().paused = true

	current_lives = MAX_LIVES
	score = 0
	$UI/HUD.update_score(score)
	$Player.position = player_start.position
	$Player.reset_player()
	$Maze/TileMapLayer.show()
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
	for cell in pellet_tilemap.get_used_cells(0):
		var world_pos = pellet_tilemap.map_to_local(cell)
		var pellet: Pellet = pellet_scene.instantiate()
		$SmallPellets.add_child(pellet)
		pellet.pellet_picked_up.connect(_on_small_pellet_picked_up)
	pellet_tilemap.clear()
	
func spawn_enemies():
	pass
	
	var first_ghost: Ghost = enemy_scene.instantiate()
	add_child(first_ghost)
	first_ghost.position = $StartPositions/GhostStartPosition.position
	
	
	
func _on_big_pellet_picked_up():
	pass
	
func _on_small_pellet_picked_up():
	score += 1
	$HUD.update_score(score)
	
func _on_player_hit():
	current_lives -= 1
	$HUD.update_lives(current_lives)
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
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("big_pellet", "queue_free")
	get_tree().call_group("small_pellet", "queue_free")
	play_main_menu_music()
	
