class_name PrisonerActiveDisplay extends Control


@onready var headshot: TextureRect = %headshot
@onready var prisoner_name: Label = %prisoner_name
@onready var prisoner_sentence: Label = %prisoner_sentence
@onready var prisoner_doi: Label = %prisoner_doi

var prisoner_data:PrisonerData


func setup_data(new_prisoner:PrisonerData) -> void:
	prisoner_data = new_prisoner
	headshot.texture = prisoner_data.headshot
	prisoner_name.text = tr(prisoner_data.display_name)
	prisoner_sentence.text = tr(prisoner_data.sentence)
	prisoner_doi.text = tr(prisoner_data.doi)