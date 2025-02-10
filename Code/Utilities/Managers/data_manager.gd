class_name DataManager extends RidManager


@export_group("Gameplay")


@export_group("Prisoners")
@export var prisoner_scene:PackedScene
@export var prisoner_target_move_scene:PackedScene
@export var prisoners:Array[PrisonerData]

@export_group("UI")
@export var large_popup:PackedScene
@export var small_popup:PackedScene
@export var context_popup:PackedScene
@export var context_button:PackedScene