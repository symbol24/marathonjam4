class_name Prisoner extends CharacterBody2D





func _mouse_enter() -> void:
	Signals.MouseEnterPrisoner.emit(self)


func _mouse_exit() -> void:
	Signals.MouseExitPrisoner.emit()