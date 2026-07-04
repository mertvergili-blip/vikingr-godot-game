extends DirectionalLight3D

## Rotates the sun according to GameClock.time_of_day and fades its
## color/intensity between warm daylight, dawn/dusk gold, and dim moonlight.

@export var azimuth_degrees: float = 20.0

const DAY_COLOR := Color(1.0, 0.95, 0.85)
const GOLDEN_COLOR := Color(1.0, 0.6, 0.3)
const NIGHT_COLOR := Color(0.4, 0.5, 0.75)

const DAY_ENERGY := 1.1
const NIGHT_ENERGY := 0.05


func _ready() -> void:
	GameClock.time_changed.connect(_on_time_changed)
	_on_time_changed(GameClock.time_of_day)


func _on_time_changed(time_of_day: float) -> void:
	var elevation_deg: float = sin((time_of_day - 0.25) * TAU) * 80.0
	rotation_degrees = Vector3(-elevation_deg, azimuth_degrees, 0.0)

	var day_factor: float = clamp(elevation_deg / 20.0, 0.0, 1.0)
	var twilight_factor: float = clamp(1.0 - abs(elevation_deg) / 15.0, 0.0, 1.0)

	if elevation_deg <= 0.0:
		light_color = NIGHT_COLOR.lerp(GOLDEN_COLOR, twilight_factor)
		light_energy = lerp(NIGHT_ENERGY, DAY_ENERGY * 0.5, twilight_factor)
	else:
		light_color = GOLDEN_COLOR.lerp(DAY_COLOR, day_factor)
		light_energy = lerp(DAY_ENERGY * 0.5, DAY_ENERGY, day_factor)
