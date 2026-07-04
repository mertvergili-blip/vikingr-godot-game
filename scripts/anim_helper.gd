class_name AnimHelper

## Finds the first AnimationPlayer anywhere under root, regardless of its
## node name or depth — glTF imports don't always put it where you'd expect.
static func find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root
	for child in root.get_children():
		var found := find_animation_player(child)
		if found:
			return found
	return null


## Resolves anim_name against the player's actual animation list. glTF
## imports can namespace clips under a named AnimationLibrary
## ("library_name/clip_name") instead of the bare clip name, so a direct
## has_animation("Idle_Loop") check can silently fail even though the clip
## exists — this is the likely cause of characters getting stuck in their
## T-pose bind pose instead of playing any animation at all.
static func resolve_animation_name(anim_player: AnimationPlayer, anim_name: String) -> String:
	if anim_player == null:
		return ""
	if anim_player.has_animation(anim_name):
		return anim_name
	for full_name in anim_player.get_animation_list():
		if full_name == anim_name or full_name.ends_with("/" + anim_name):
			return full_name
	return ""
