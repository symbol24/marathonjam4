class_name DataManager extends RidManager


@export_group("Gameplay")


@export_group("Prisoners")
@export var prisoner_datas:Array[PrisonerData] = []
@export var prisoner_scene:PackedScene
@export var prisoner_target_move_scene:PackedScene

@export_group("UI")
@export var large_popup:PackedScene
@export var small_popup:PackedScene
@export var context_popup:PackedScene
@export var context_button:PackedScene

@export_category("Map Generation")
@export var map_generator:PackedScene
@export var map_icon_btn_encounter:PackedScene
@export var map_icon_btn_treasure:PackedScene
@export var map_icon_btn_station:PackedScene
@export var map_icon_btn_shop:PackedScene
@export var map_icon_btn_boss:PackedScene
@export var map_icon_btn_start:PackedScene
@export var map_icon_spaceship:PackedScene
@export var map_line:PackedScene