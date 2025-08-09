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

var score: int = 0
var current_lives: int
var ghosts: Array = []
var dot_counter: int = 0
var global_dot_counter_active: bool = false
var global_dot_counter: int = 0
var ghosts_frightened: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()
	
	$Player.player_hit.connect(_on_player_hit)
	$ReadyTimer.timeout.connect(_on_ready_timer_timeout)
	$BigPellets/BigPellet.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	$BigPellets/BigPellet2.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	$BigPellets/BigPellet3.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	$BigPellets/BigPellet4.big_pellet_picked_up.connect(_on_big_pellet_picked_up)
	
	blinky.enter_frightened.connect(_on_enter_frightened)
	blinky.exit_frightened.connect(_on_exit_frightened)
	pinky.enter_frightened.connect(_on_enter_frightened)
	pinky.exit_frightened.connect(_on_exit_frightened)
	inky.enter_frightened.connect(_on_enter_frightened)
	inky.exit_frightened.connect(_on_exit_frightened)
	clyde.enter_frightened.connect(_on_enter_frightened)
	clyde.exit_frightened.connect(_on_exit_frightened)
	
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
	ghosts_frightened = false
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
	reset_ghost_position()
	
	blinky.set_current_state("CHASING")
	pinky.set_current_state("IDLE")
	inky.set_current_state("IDLE")
	clyde.set_current_state("IDLE")
	
	blinky.show()
	pinky.show()
	inky.show()
	clyde.show()
	
func reset_ghost_position():
	blinky.return_to_start()
	pinky.return_to_start()
	inky.return_to_start()
	clyde.return_to_start()
	
func activate_ghost(ghost: Ghost) -> void:
	if ghost.get_current_state() == Ghost.BehaviorMode.IDLE:
		ghost.set_current_state("CHASING")
	
func scatter():
	pass
	
func _on_big_pellet_picked_up():
	score += 50
	$UI/HUD.update_score(score)
	
	blinky.become_frightened()
	pinky.become_frightened()
	inky.become_frightened()
	clyde.become_frightened()
	
func _on_small_pellet_picked_up():
	score += 10
	$UI/HUD.update_score(score)
	dot_counter += 1
	if not global_dot_counter_active:
		if dot_counter >= 0:
			activate_ghost(pinky)
			dot_counter = 0
		if dot_counter >= 19:
			activate_ghost(inky)
			dot_counter = 0
		if dot_counter >= 38:
			activate_ghost(clyde)
			dot_counter = 0
	else:
		global_dot_counter += 1
		if global_dot_counter >= 4:
			activate_ghost(pinky)
			global_dot_counter = 0
		if global_dot_counter >= 11:
			activate_ghost(inky)
			global_dot_counter = 0
		if global_dot_counter >= 20:
			activate_ghost(clyde)
			global_dot_counter = 0
			global_dot_counter_active = false
			
func _on_enter_frightened():
	ghosts_frightened = true
	
func _on_exit_frightened():
	ghosts_frightened = false
	
func _on_player_hit(body):
	if ghosts_frightened == false:
		current_lives -= 1
		$UI/HUD.update_lives(current_lives)
		# TODO: add lives counter
		if current_lives <= 0:
			game_over()
		else:
			get_tree().paused = true
			$Player.reset_player()
			$Player.position = player_start.position
			reset_ghost_position()
			global_dot_counter_active = true
			$ReadyTimer.start()
			$UI/HUD.show_message("GET READY")
	else:
		score += 200
		$UI/HUD.update_score(score)
		body.return_to_start()
	
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
	
