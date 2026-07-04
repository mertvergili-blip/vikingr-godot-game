extends DirectionalLight3D

## Rotates the sun over a full day/night cycle and fades its color/intensity
## between warm daylight, dawn/dusk gold, and dim cool moonlight.

@export var day_length_seconds: float = 240.0
@export var start_time_of_day: float = 0.3
@export var azimuth_degrees: float = 20.0

var time_of_day: float

const DAY_COLOR := Color(1.0, 0.95, 0.85)
const GOLDEN_COLOR := Color(1.0, 0.6, 0.3)
const NIGHT_COLOR := Color(0.4, 0.5, 0.75)

const DAY_ENERGY := 1.1
const NIGHT_ENERGY := 0.05


func _ready() -> void:
	time_of_day = start_time_of_day
	_update_sun(0.0)


func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta / day_length_seconds, 1.0)
	_update_sun(delta)


func _update_sun(_delta: float) -> void:
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
