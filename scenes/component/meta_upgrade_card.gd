extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var learn_button: Button = %LearnButton
@onready var progress_label: Label = %ProgressLabel
var upgrade: MetaUpgrade



func _ready():
	learn_button.pressed.connect(on_learn_button_pressed)


func set_meta_upgrade(upgrade: MetaUpgrade):
	self.upgrade = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()


func update_progress():
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var percent = min((currency / upgrade.experience_cost), 1)
	progress_bar.value = percent
	learn_button.disabled = percent < 1
	progress_label.text = str(currency) + "/" + str(upgrade.experience_cost)


func on_learn_button_pressed():
	if not upgrade: return
	MetaProgression.add_meta_upgrade(upgrade)
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.experience_cost
	MetaProgression.save_file()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
