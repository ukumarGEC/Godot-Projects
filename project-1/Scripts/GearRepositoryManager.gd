@tool
extends Node
class_name GearRepositoryManager

enum DunnageType
{
	Loader,
	GoodDunnage,
	BadDunnage
}

@export var capacity_threshold := 7
@export var Loader_Gears:Array[Node3D] 
@export var Bad_Dunnage_Gears:Array[Node3D] 
@export var Good_Dunnage_Gears:Array[Node3D] 

signal LoaderEmpty
signal GoodDunnageFull
signal BadDunnageFull

var loader_count := 0
var good_dunnage_count := 0
var bad_dunnage_count := 0

func _ready() -> void:
	loader_count = capacity_threshold

#func _process(delta: float) -> void:
	#reload()
	#reset_bad_dunnage()
	#reset_good_dunnage()
	#pass

# -------------------------------------------------------------------------
# Bad Dunnage
# -------------------------------------------------------------------------

func reset_bad_dunnage() -> void:
	bad_dunnage_count = 0
	print("Bad Dunnage reset")
	update_gears(DunnageType.BadDunnage, bad_dunnage_count)


func add_to_bad_dunnage() -> void:
	if bad_dunnage_count >= capacity_threshold:
		return

	bad_dunnage_count += 1

	# TODO: Play bad dunnage add animation using gear
	print("Gear added to bad dunnage")
	update_gears(DunnageType.BadDunnage, bad_dunnage_count)

	if bad_dunnage_count == capacity_threshold:
		BadDunnageFull.emit()

func remove_from_bad_dunnage() -> void:
	if bad_dunnage_count == 0:
		return

	bad_dunnage_count -= 1

	# TODO: Play bad dunnage remove animation using gear
	print("Gear removed from bad dunnage")
	update_gears(DunnageType.BadDunnage, bad_dunnage_count)

# -------------------------------------------------------------------------
# Good Dunnage
# -------------------------------------------------------------------------

func reset_good_dunnage() -> void:
	good_dunnage_count = 0
	print("Good Dunnage reset")
	update_gears(DunnageType.GoodDunnage, good_dunnage_count)


func add_to_good_dunnage() -> void:
	if good_dunnage_count >= capacity_threshold:
		return

	good_dunnage_count += 1

	# TODO: Play good dunnage add animation using gear
	print("Gear added to good dunnage")
	update_gears(DunnageType.GoodDunnage, good_dunnage_count)

	if good_dunnage_count == capacity_threshold:
		GoodDunnageFull.emit()

func remove_from_good_dunnage() -> void:
	if good_dunnage_count == 0:
		return

	good_dunnage_count -= 1

	# TODO: Play good dunnage remove animation using gear
	print("Gear removed from good dunnage")
	update_gears(DunnageType.GoodDunnage, good_dunnage_count)

# -------------------------------------------------------------------------
# Loader
# -------------------------------------------------------------------------

func reset_loader() -> void:
	loader_count = 0
	update_gears(DunnageType.Loader, loader_count)

func reload()-> void:
	print("Gear input dunnage reloaded")
	loader_count = capacity_threshold
	update_gears(DunnageType.Loader, loader_count)

func add_to_loader() -> void:
	if loader_count >= capacity_threshold:
		return

	loader_count += 1

	# TODO: Play loader add animation using gear
	print("Gear added to loader")
	update_gears(DunnageType.Loader, loader_count)


func remove_from_loader() -> void:
	if loader_count == 0:
		return

	loader_count -= 1

	# TODO: Play loader remove animation using gear
	print("Gear removed from loader")
	update_gears(DunnageType.Loader, loader_count)
	
	if loader_count == 0:
		LoaderEmpty.emit()
	


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
	
func update_gears(type:DunnageType, count:int)->void:
	match type:
		DunnageType.Loader: _update_loader_gears(count)
		DunnageType.GoodDunnage: _update_good_dunnage_gears(count)
		DunnageType.BadDunnage: _update_bad_dunnage_gears(count)
	pass
	
func _update_loader_gears(count:int)->void:
	for i in range(Loader_Gears.size()):
		var gear := Loader_Gears[i]
		gear.visible = i < count
	pass
	
func _update_bad_dunnage_gears(count:int)->void:
	for i in range(Bad_Dunnage_Gears.size()):
		var gear := Bad_Dunnage_Gears[i]
		gear.visible = i < count
	pass
	
func _update_good_dunnage_gears(count:int)->void:
	for i in range(Good_Dunnage_Gears.size()):
		var gear := Good_Dunnage_Gears[i]
		gear.visible = i < count
	pass
