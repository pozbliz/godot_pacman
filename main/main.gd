extends Node


var score: int = 0


func _ready() -> void:
	$UI.game_started.connect(_on_ui_game_started)
	$UI.open_main_menu()
	$Audio/AudioMainMenu.play()
	
	$Player.player_died.connect(_on_player_died)

func _process(delta: float) -> void:
	pass

func _on_ui_game_started():
	get_tree().paused = false

	score = 0
	$UI/HUD.update_score(score)
	$Player.reset_player()
	$Player.position = $PlayerStartPosition.position
	$Player.set_process(true)
	$Player.set_physics_process(true)
	$Player.set_process_unhandled_input(true)
	play_game_music()
	
func play_main_menu_music():
	$Audio/AudioGameplay.stop()
	$Audio/AudioMainMenu.play()
	
func play_game_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.play()
	
func stop_music():
	$Audio/AudioMainMenu.stop()
	$Audio/AudioGameplay.stop()
	
func _on_player_died():
	$Player.set_process(false)
	$Player.set_physics_process(false)
	$Player.set_process_unhandled_input(false)
	stop_music()
	$Player.play_death_animation()
	await $UI/HUD.show_game_over()
	$UI.open_main_menu()
	get_tree().call_group("enemies", "queue_free")
	play_main_menu_music()
	
