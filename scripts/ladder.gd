# ladder.gd
extends Area2D

@export var scroll_direction := Vector2(0, -240)  # Up by default
@export var entry_point: NodePath  # Set in editor to LadderEntryTop/Bottom marker
