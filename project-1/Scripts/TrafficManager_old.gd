extends Node
class_name TrafficManager_old

class Station:
	var pallet : Pallet_Path = null

var roads := {}
#signal station_released(path: Path3D, station : float)
signal station_released(path:Path3D, station:int)

func _ready()-> void:
	add_to_group("traffic_manager")

func register_path(path:Path3D) -> void:
	if roads.has(path):
		return
	var stations: Array = []
	for i in range(path.curve.point_count):
		stations.append(Station.new())
	roads[path] = stations


func occupy(path:Path3D, station:int, pallet:Pallet_Path) -> void:
	#print("Occupied")
	register_path(path)
	if roads[path][station].pallet == null:
		roads[path][station].pallet = pallet
		
func release(path: Path3D, station: int) -> void:
	print("Released")
	register_path(path)
	if roads[path][station].pallet != null:
		roads[path][station].pallet = null
		station_released.emit(path, station)

func is_free(path:Path3D, station:int)->bool:
	register_path(path)
	if station >= roads[path].size():
		return true
	return roads[path][station].pallet == null
	
func reset() -> void:
	for road_variant:Path3D in roads.keys():
		var road:Path3D = road_variant
		var stations:Array = roads[road]
		for station_variant:Station in stations:
			var station:Station = station_variant
			station.pallet = null
	print("TrafficManager: all stations released")
