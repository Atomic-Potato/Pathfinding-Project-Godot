class_name MainLevelScene extends Scene

@export var _dungeon_manager_resource: Resource
@export var _pathfinding_grid_resource: Resource

var dungeon_manager: DungeonManager
var pathfinding_grid: Grid 

func load_scene():
	dungeon_manager = load(_dungeon_manager_resource.resource_path).instantiate()
	add_child(dungeon_manager)
	await dungeon_manager.dungeon_generated_signal
	
	pathfinding_grid = load(_pathfinding_grid_resource.resource_path).instantiate()
	pathfinding_grid.is_use_tilemap = true
	pathfinding_grid.the_tilemap_in_question = dungeon_manager.tilemap
	add_child(pathfinding_grid)
	await pathfinding_grid.grid_generated_signal
	
	loaded.emit()

func unload_scene():
	PathfindingManager.grid = null
	PathfindingManager.agents.clear()
	unloaded.emit()
