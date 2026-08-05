@tool
extends Node
class_name GearRepositoryManager

@export var capacity_threshold := 7

var loader_count := 0
var good_dunnage_count := 0
var bad_dunnage_count := 0

func _ready() -> void:
	loader_count = capacity_threshold


# -------------------------------------------------------------------------
# Bad Dunnage
# -------------------------------------------------------------------------

func reset_bad_dunnage() -> void:
	bad_dunnage_count = 0
	print("Bad Dunnage reset")


func add_to_bad_dunnage() -> void:
	if bad_dunnage_count >= capacity_threshold:
		return

	bad_dunnage_count += 1

	# TODO: Play bad dunnage add animation using gear
	print("Gear added to bad dunnage")


func remove_from_bad_dunnage() -> void:
	if bad_dunnage_count == 0:
		return

	bad_dunnage_count -= 1

	# TODO: Play bad dunnage remove animation using gear
	print("Gear removed from bad dunnage")


# -------------------------------------------------------------------------
# Good Dunnage
# -------------------------------------------------------------------------

func reset_good_dunnage() -> void:
	good_dunnage_count = 0
	print("Good Dunnage reset")


func add_to_good_dunnage() -> void:
	if good_dunnage_count >= capacity_threshold:
		return

	good_dunnage_count += 1

	# TODO: Play good dunnage add animation using gear
	print("Gear added to good dunnage")


func remove_from_good_dunnage() -> void:
	if good_dunnage_count == 0:
		return

	good_dunnage_count -= 1

	# TODO: Play good dunnage remove animation using gear
	print("Gear removed from good dunnage")


# -------------------------------------------------------------------------
# Loader
# -------------------------------------------------------------------------

func reset_loader() -> void:
	loader_count = 0

func reload()-> void:
	print("Gear input dunnage reloaded")
	loader_count = capacity_threshold

func add_to_loader() -> void:
	if loader_count >= capacity_threshold:
		return

	loader_count += 1

	# TODO: Play loader add animation using gear
	print("Gear added to loader")


func remove_from_loader() -> void:
	if loader_count == 0:
		return

	loader_count -= 1

	# TODO: Play loader remove animation using gear
	print("Gear removed from loader")

	


# -------------------------------------------------------------------------
# Utility
# -------------------------------------------------------------------------

func is_loader_full() -> bool:
	return loader_count >= capacity_threshold


func is_good_dunnage_full() -> bool:
	return good_dunnage_count >= capacity_threshold


func is_bad_dunnage_full() -> bool:
	return bad_dunnage_count >= capacity_threshold
	
func print_status() -> void:
	print("================ Repository Status ================")
	print("Loader        : %d / %d" % [loader_count, capacity_threshold])
	print("Good Dunnage : %d / %d" % [good_dunnage_count, capacity_threshold])
	print("Bad Dunnage  : %d / %d" % [bad_dunnage_count, capacity_threshold])
	print("===================================================")
