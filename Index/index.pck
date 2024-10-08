GDPC                                                                                          T   res://.godot/exported/133200997/export-76e0adcbc83681695885bae615f516ae-world.scn   �      �      h3�4bw������%�    T   res://.godot/exported/133200997/export-a53284a8164c2bc57dbb020cbec96c69-player.scn  �(      @      /�ĩ.�x���~��O    T   res://.godot/exported/133200997/export-a72371f07eede78412de7b96ea39a6a0-world.scn   �,      �      �0�a]���QA�F    ,   res://.godot/global_script_class_cache.cfg  `�             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex �            ：Qt�E�cO���    \   res://.godot/imported/the thing.apple-touch-icon.png-cadae2f34c66269d0d3cc3675f2a38b3.ctex  �0      �      ꛲���� ��ܶ�    P   res://.godot/imported/the thing.icon.png-79027cd0e96f7fce49f61c0e0fdc2e2a.ctex  @P            ：Qt�E�cO���    L   res://.godot/imported/the thing.png-849b6c804b32037f44cd16b57e05772d.ctex   0^      -      �%�$����<�׿�+       res://.godot/uid_cache.bin  @�      <      m�,�c> +B�=d5��    @   res://The thing went here/the thing.apple-touch-icon.png.import `O      �       ��*��}��(��!b�    4   res://The thing went here/the thing.icon.png.import `]      �       ��������e�
    0   res://The thing went here/the thing.png.import  P�      �       ���߈iN�uS�O:�2    (   res://addons/AS2P/InspectorConvertor.gd         �
      O>�R�(��4vޖ��    ,   res://addons/AS2P/NodeSelectorProperty.gd          �      �UϸOL	t�݊#]       res://addons/AS2P/plugin.gd �!      �      ����) {��1l��       res://icon.svg  ��      �      k����X3Y���f       res://icon.svg.import   @�      �       ���Qc
��e�@4�       res://player/Scene/player.gdP$      *      Ӭ�ƪ�BW�`ۊy�/    $   res://player/Scene/player.tscn.remap�      c       ׬����D}�M[��e=    $   res://player/Scene/world.tscn.remap ��      b       ��'���R|:�&gh?A       res://project.binary��      M      K�V�[����)C�jQ�       res://world.tscn.remap  �      b       �t�׵B�}��6�x    @tool
extends EditorInspectorPlugin

const NodeSelectorProperty = preload("./NodeSelectorProperty.gd")

var node_selector: NodeSelectorProperty

# Properties
var anim_player: AnimationPlayer

# Signals
signal animation_updated(animation_player: AnimationPlayer)

func _can_handle(object):
	if object is AnimationPlayer:
		anim_player = object

		return true
	return false

## Create UI here
func _parse_end(object: Object):
	var header = CustomEditorInspectorCategory.new("Import AnimatedSprite2D/3D")

	# AnimatedSprite2D Node selector
	node_selector = NodeSelectorProperty.new(anim_player)
	node_selector.label = "AnimatedSprite2D/3D Node"

	node_selector.animation_updated.connect(
		_on_animation_updated,
		CONNECT_DEFERRED
		)


	# Import button
	var button := Button.new()
	button.text = "Import"
	button.get_minimum_size().y = 26
	button.button_down.connect(node_selector.convert_sprites)

	var buttonstyle = StyleBoxFlat.new()
	buttonstyle.bg_color = Color8(32, 37, 49)
	button.set("custom_styles/normal", buttonstyle)

	var container = VBoxContainer.new()
	container.add_spacer(true)

	container.add_child(header)
	container.add_child(node_selector)
	container.add_spacer(false)
	container.add_child(button)

	add_custom_control(container)


func _on_animation_updated():
	emit_signal("animation_updated", anim_player)

# Child class
class CustomEditorInspectorCategory extends Control:
	var title: String = ""
	var icon: Texture2D = null

	func _init(p_title: String, p_icon: Texture2D = null):
		title = p_title
		icon = p_icon

		tooltip_text = "AnimatedSprite to AnimationPlayer Plugin"

	func _get_minimum_size() -> Vector2:
		var font := get_theme_font(&"bold", &"EditorFonts");
		var font_size := get_theme_font_size(&"bold_size", &"EditorFonts");

		var ms: Vector2
		ms.y = font.get_height(font_size);
		if icon:
			ms.y = max(icon.get_height(), ms.y);

		ms.y += get_theme_constant(&"v_separation", &"Tree");

		return ms;

	func _draw() -> void:
		var sb := get_theme_stylebox(&"bg", &"EditorInspectorCategory")
		draw_style_box(sb, Rect2(Vector2.ZERO, size))

		var font := get_theme_font(&"bold", &"EditorFonts")
		var font_size := get_theme_font_size(&"bold_size", &"EditorFonts")

		var hs := get_theme_constant(&"h_separation", &"Tree")

		var w: int = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x;
		if icon:
			w += hs + icon.get_width();


		var ofs := (get_size().x - w) / 2;

		if icon:
			draw_texture(icon, Vector2(ofs, (get_size().y - icon.get_height()) / 2).floor())
			ofs += hs + icon.get_width()

		var color := get_theme_color(&"font_color", &"Tree")
		draw_string(font, Vector2(ofs, font.get_ascent(font_size) + (get_size().y - font.get_height(font_size)) / 2).floor(), title, HORIZONTAL_ALIGNMENT_LEFT, get_size().x, font_size, color);

           @tool
extends EditorProperty
## @desc Inspector property for selecting the animation node,
##			and handles the animation import process.
##

var anim_player: AnimationPlayer
var drop_down := OptionButton.new()

signal animation_updated()

func get_animatedsprite():
	var root = get_tree().edited_scene_root
	return _get_animated_sprites(root)[drop_down.selected]

func _get_animated_sprites(root: Node) -> Array:
	var asNodes := []

	for child in root.get_children():
		asNodes += _get_animated_sprites(child)

	if root is AnimatedSprite2D or root is AnimatedSprite3D:
		asNodes.append(root)

	return asNodes

func _init(_anim_player):
	anim_player = _anim_player

	drop_down.clip_text = true
	# Add the control as a direct child of EditorProperty node.
	add_child(drop_down)
	# Make sure the control is able to retain the focus.
	add_focusable(drop_down)

	drop_down.clear()

func _ready():
	get_items()


func get_items():
	drop_down.clear()

	var root = get_tree().edited_scene_root
	var anim_sprites := _get_animated_sprites(root)

	for i in range(len(anim_sprites)):
		var anim_sprite = anim_sprites[i]

		drop_down.add_item(anim_player.get_path_to(anim_sprite), i)

func convert_sprites():
	var animated_sprite = get_node(get_animatedsprite().get_path())

	var count := 0
	var updated_count := 0

	var sprite_frames = animated_sprite.sprite_frames

	if not sprite_frames:
		print("[AS2P] Selected AnimatedSprite2D has no frames!")

	for anim in sprite_frames.get_animation_names():
		if anim.is_empty():
			printerr("[AS2P] SpriteFrames on AnimatedSprite2D '%s' has an \
animation named empty string '', it will be ignored" % animated_sprite.name)
			continue

		var updated = add_animation(
				anim_player.get_node(anim_player.root_node).get_path_to(animated_sprite),
				anim,
				sprite_frames
			)

		count += 1

		if updated:
			updated_count += 1

	if count - updated_count > 0:
		print("[AS2P] Added %d animations!" % [count - updated_count])
	if updated_count > 0:
		print("[AS2P] Updated %d animations!" % updated_count)

	emit_signal("animation_updated")

func add_animation(anim_sprite: NodePath, anim: String, sprite_frames: SpriteFrames):
	var frame_count = sprite_frames.get_frame_count(anim)
	var fps = sprite_frames.get_animation_speed(anim)
	var looping = sprite_frames.get_animation_loop(anim)
	# Determine the total animation duration in seconds. First sum the duration
	# of each frame, then divide duration by FPS to get the length in seconds.
	var duration: float = 0
	for i in range(frame_count):
		duration += sprite_frames.get_frame_duration(anim, i)
	duration = duration / fps

	# We add the converted animation to the [Global] animation library,
	# which corresponding to the empty string "" key
	var global_animation_library: AnimationLibrary
	if anim_player.has_animation_library(&""):
		# The [Global] animation library already exists, so get it
		# The only reason we check has_animation_library then call
		# get_animation_library instead of just checking if get_animation_library
		# returns null, is that get_animation_library causes an error when no
		# library is found.
		global_animation_library = anim_player.get_animation_library(&"")
	else:
		# The [Global] animation library does not exist yet, so create it
		global_animation_library = AnimationLibrary.new()
		anim_player.add_animation_library(&"", global_animation_library)

	# SpriteFrames allow characters ":" and "[" in animation names, but not
	# Animation Player library, so sanitize the name
	var sanitized_anim_name = anim.replace(":", "_")
	sanitized_anim_name = sanitized_anim_name.replace("[", "_")

	var updated := false
	var animation: Animation = null

	if global_animation_library.has_animation(sanitized_anim_name):
		animation = global_animation_library.get_animation(sanitized_anim_name)

		updated = true
	else:
		animation = Animation.new()
		global_animation_library.add_animation(sanitized_anim_name, animation)

	var spf = 1/fps
	animation.length = duration

	# SpriteFrames only supports linear looping (not ping-pong),
	# so set loop mode to either None or Linear
	animation.loop_mode = Animation.LOOP_LINEAR if looping else Animation.LOOP_NONE

	# Remove existing tracks
	var animation_name_path := "%s:animation" % anim_sprite
	var frame_path := "%s:frame" % anim_sprite

	var anim_track: int = animation.find_track(animation_name_path, Animation.TYPE_VALUE)
	var frame_track: int = animation.find_track(frame_path, Animation.TYPE_VALUE)

	if frame_track >= 0:
		animation.remove_track(anim_track)
	if anim_track >= 0:
		animation.remove_track(frame_track)

	# Add and create tracks

	frame_track = animation.add_track(Animation.TYPE_VALUE, 0)
	anim_track = animation.add_track(Animation.TYPE_VALUE, 1)

	animation.track_set_path(anim_track, animation_name_path)

	# Use the original animation name from SpriteFrames here,
	# since the track expects a SpriteFrames animation key for the AnimatedSprite2D
	animation.track_insert_key(anim_track, 0, anim)

	animation.track_set_path(frame_track, frame_path)

	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	animation.value_track_set_update_mode(anim_track, Animation.UPDATE_DISCRETE)

	# Initialize first sprite key time
	var next_key_time := 0.0

	for i in range(frame_count):
		# Insert key at next key time
		animation.track_insert_key(frame_track, next_key_time, i)

		# Prepare key time for next sprite by adding duration of current sprite
		# including Frame Duration multiplier
		var frame_duration_multiplier = sprite_frames.get_frame_duration(anim, i)
		next_key_time += frame_duration_multiplier * spf

	global_animation_library.add_animation(sanitized_anim_name, animation)

	return updated

func get_tooltip_text():
	return "AnimationSprite node to import frames from."
  @tool
extends EditorPlugin

const Convertor = preload("res://addons/AS2P/InspectorConvertor.gd")

var plugin: Convertor

func _enter_tree():
	plugin = Convertor.new()
	plugin.animation_updated.connect(_refresh, CONNECT_DEFERRED)
	add_inspector_plugin(plugin)

func _refresh(anim_player):
	var interface = get_editor_interface()

	# Hacky way to force the editor to deselect and reselect
	#	the animation panel, as the panel won't update until then
	interface.inspect_object(interface.get_edited_scene_root())
	interface.get_selection().clear()
	await get_tree().create_timer(0.05).timeout
	interface.inspect_object(anim_player)

func _exit_tree():
	remove_inspector_plugin(plugin)

      extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration : float = 15.0
@export var jumps = 1

enum state {IDLE, RUNNING, JUMPUP, JUMPDOWN, HURT,}
 
var anim_state = state.IDLE

@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration/2)

	move_and_slide()
      RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    animations    script    custom_solver_bias    radius    height 	   _bundled       Script    res://player/Scene/player.gd ��������      local://SpriteFrames_cnnwm �         local://CapsuleShape2D_p7ady �         local://PackedScene_42l8f �         SpriteFrames             CapsuleShape2D             PackedScene          	         names "   	      Player    script    CharacterBody2D    AnimatedSprite2D    sprite_frames    CollisionShape2D 	   position    shape    AnimationPlayer    	   variants                           
     C  %C               node_count             nodes     $   ��������       ����                            ����                           ����                                 ����              conn_count              conns               node_paths              editable_instances              version             RSRCRSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       PackedScene    res://player/Scene/player.tscn �s+9vD�[      local://RectangleShape2D_6cqj7 f         local://PackedScene_utn33 �         RectangleShape2D       
    0�D  fB         PackedScene          	         names "         World    Node2D    StaticBody2D    CollisionShape2D 	   position    shape    Player    	   variants       
    �D ��C                    
     C  fC      node_count             nodes     "   ��������       ����                      ����                     ����                            ���                         conn_count              conns               node_paths              editable_instances              version             RSRC GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /��,� j�Fj���'|$"���X��qj��mC�$� �O� �\E�$)} `��;�� m9�����������r� \.��-�q
%;���{~��s�(hۆIß�.��� �H-(]m۔�����0+�|�1�3���Aݶ���Ke���U����0��"�N!���F��H��a��p��h�?�����#I�$I�="�������>ti�ʐc�ڲ'�{��V����O���ҹK�ܨ��:�	�m��ȶm����"3;8#9f�ҸFi��8�Q�"Sg�9�:�(釯�Ғ:�pٶ��n�>�����'��̌5�Zd	���L����,?�m��mۖ����K�N���f�5�@���Ysѻ�G�@T"Y �������A2�? ���7M��m�J���p�m#I�Ĭm�ݽ7Spd�V��C�����-t���Q��	�D �HW;��z �'���s����b��}�c�J�-hA9hC$l1�?���OO����ߞ���ŧ8�  �(�t��	�����:k�z ����s���������MV5�Q@14"g��l����p���#�?��P����ٞ|?l��h ��  ,9��lmD�)!9��ܞֱ�s8�,�&`��������;�G/�v唱�~����5 �p��7�3�xά��+�t��\�2�"hSdІ�y����W�.w��.�rMO� �N <��3�9����ӵ�vݮ�Ё4*"Dȱ�ͺw����\�*j u�����(�qӸ|qױ��  R�DB�	 ��eԆJW�  Ĩc��w~z7n��%t!_'  v<۞	��/��4�z�� Bdd�W�"�T�D4B ��i�R���  4��©'ǝ뤁 [�lur��x��d{��F��S�1�" 2��P�"� �`d1T&+;����% P���x�F��F]��θ��Xv<GKN���_�o`E�\�b�t�,� �
 "�,��+���P�$ �����bn#>�f��z��Ҏ灿vi-� IJ�� �I��Lj�6I  F���?��θ�(ͺ��4W�t�v=�6 H�T&}��ZjM��  �������g� ���.b��\F �2i��f���.&c� :�k��m`���j��G��;�TE ���ж!�b��*N�XO�G
�{��c�v�!� �1V�
�6P�Q� �(�}���s�w������p>�"�c��@w�� p��1�刯��Wz��I �1hY���PI �r��}C����x���,@�,�"	h�$:�E@�ܝ�ys�3� $�WL@GtJ �JXsUR��"��B�E @��"A �K�%��  ��� �H�FDB �����0�J  P@*� �62 @U�  �h�  d����$ ��� ��'�GCu���n��ִ�)3�������w��
		�/�}�>_u:9)��3�����+i�t���N�o�k�Mj]8  ���&ɩN�� @�r5�Yf�%�-��S44�x�I ��m4����ih���Ӛ�9�,s�.3-ݪ,�zZj�N�o&
<��2,s�r���3�:�  Pɦ�'TK;�|�j<}�T��vע5�P��=���E���HM|�i1���>{��YI5)�|���l���d""�F$�>�ӝ�7g/=��*�LI����õ�n�L��I��pj�VI p�`;[���$���gj��\���sp�`�|���$-� G6P�.\�p�.�nMpYKФE8�<9X5���� `���'�!d�0��e���iJ.�㮚�s��3��� LF"K \lY,.#G�@��9@5�,��\.$a�aW�:ȯ|���&`p� �\��-�j�2Xr�J9Yt`���fk#r��}��&�.K�lg��&.[Er��&`a�H.���	���`6�M�:ӓqHR�E@]�,�<�N���v))���{cD� �G�H�@��!kYs4�q�%	i�>��/Ph³>�����L�!	G���(_�<�ҹ���b�֯���|I��+u����1Bf-�y�w�c��O	��呵�1�ј.��Tl��G�ߍfC�� @�E<�1{cD�O��Ox�����ƾz*��]c����#Һ�3&�iq �D]�h?�)�r���  D@�ۚw��SGx5���AK���nOp�7���;igI��v8�x$P�j�ǫ��z (<�^j� �ݙ��Z	
%���7)�;��;�p��|� `��g�G������ޓiLcn̫��;�( @�z�l^S����F#��'@P�)i׵L`E�@����7lolϺ��'E��E�8J}�Q`]�H; @��%"v�l�*r�����?�SaHCD"�J&�1c�
"	�:Cd%ʉ �,�����b�#�숞7!� 5�xD�
�é�D�ː:�����m��W%*P���M��?��M��p��@�7�z����=uc�$�*?����ɻϦٚ%�Ru�������i���ɲ�n�Q��|/�?sfӀ��WUw����Og���Ɓ�\G���{]�hW���I��:�u��qT�=X=��/���̙"�e�2]�u\\4*�W�ҧM���_~���BrR������]}o_��9����R��U��O]�`����&\�l]Z�1*�m��:��&���^���|��U��߃d�6{���|gπ�,�2�?�K�շ��O;��[=x�H@�u����Up�?P��a���%7Īb�m���-��o�f���'���w�O�BÌs���jg��{��g�Cn�Z\9{s�Y"d��ֹh�p�S�1��]��&�;{mqE��)^�P�Y��{����ے��a����7��_��?*8�,��s��=��N��&�u����[r�廎^8��uy�rpйp��v7|X�|T����=������k�F�J����?����E����_��m'/����JP[���|�[�Q?�0�pp0x�;��[�m�iёȦ��Oz�S��'B���)��{�>�������������i���_��GO��ٔ�����$�F��ξ5���*8x��>+: �+N����bZ������^��wm=�l��=��ջ�o��d�ew=n�����e DB=�=�Ȕ]p������ `b�y�{�u��ː��ۜj�l�I�O�^��LmEG�Yކ��}��cO�-�Ϻ��Ι ��)�fo0&� ��W;S@�5���w�O�������H  p��]��q)@��'��D&�j�=��C�sr�L���$��k}����I  �	�-~���w�P��-Urr�8o���c �O���ߺܯ��_��0����Q����~������������_�����ޡ�P�ֿ������@��k�{�ߛ�2 �ٖ��*���=��#�]��)���Ϻ�t?@+8h��\P[k��z��=~f���Gm=����g�~\���RK�y*<��#��'��)g|�u5�-@Vmt��Tn����EF,W�ˏ� kZ>��$Ƅ��6k5ν����� r�>��5�[�[z�C�����&��r�� �j��r�g ��R���#�X�v�32k��yN5  �۵Χ����yjˑ�y]v`m抏;}  �rS+�ݝS���-K;g�Lp �!WTw���H�Mz	��eXL9�l  �TWn��cJL`4�R �'�]�Z�Rnd cn�  Qn�n�.*��-&�f��%w�i�|y�w�}�3̲���  @c(���� @�ƣ9��Ms�������|fק���¯,�nTr �*�r[\7��9�P�Y�2t��ܚ������n��7n�GĊ�:���\\�n�r[�M%8d����7��3k�����_��~�S�Ϣ.�^�a��	G������⑵�[���yw�C�f6_�ͱ�}���r�z�������?�-k����_���˿�\M�2���a�uW�h���?�������vYC�W_#=P��UN֛���X����"˻�������?ߗ�,��G
������������g��N.���+����_�y5�~�}�3n��vm��v^�z 6���zs0J.֗�S�8`�_�����}����#� �o�?�|��?��?���������W�8�+��׉gj��u/��n��壻z`zO|����ƕ޻��f6\`���EKJ�U»yK<h%�������������֏?��	辷�W��?��������_7?�t�Ω��S���E=���Ͽ�����?�O>q���=n�n��y����p8�y﮷��m}����m5�,�����w��VG�Y���j�:�1x�Kq�����('�U�b܃���uk������t�{����[����0k��>{�� l-��>�M �r���<����Ts�8�.��JǬ.W�w_��a��-i���Jq��s��R���'�m��q���p`[�]�u��M,I�t��7���c�W�p1z�D_t�32Mk�8z��:�.�Zp�\�:���؟���w�م�-N��o�դ��3.P�:G���P]�D��J�r5���Z%2+�}�w�~u`�`1�ӜL �n��U�}�����2k�n1o����JV�ۢ�F�Ο�bL�Y��sUG�����M��>_�R�x]\������x&J�|�Ï�n!~�*e-
�V��۵hd��b�|1�u+R���īpV�?Y&�`q���ف_LF$����?n��pr3'����G��"LD���&�DDZ�_J�H���g��a��}v؝�V<sŸr+��u�xf�bU2�$��A+��C �\�'7r#7r�\�\��O��+�bZ=~��z=.���0�)mq��$	I�uI�1�4�+�r�uuj
*P�@A�KB ������b!j�O�aW�,�s�lYٲr�s�}�|�%%�h6b]\)Yb��Ȓ�����W�M�bcp-����D��( @ ֜�>���S�X�򔓱E��ȣư�3�X��rf�a�V�`��b�bӸT@0R�P@�@(2@�La���:��=�i�]��v���!��xn����� \0.���!�$I-��fg�bq,�����w�@��<���9�||���,*�Č̓����y�x(r�օ��X�ʁJa�.��X-�4)itӤI�F�cq�����/�7)�*`-j2  �B�S()�:�B�P]��%�$��c�.5�������*��La��e;��f��L�����fb�Yx �Ű�Q�Y����z5�5T��j+� �Ȭx�D%˃��Yr3�2�a��}�;m�
�1��3�<��0]u���Oc�{�W2���9�:5s+�ѱ��Õ.. h�?mQX�(rY�-G˱�'��W�>�����	d�ΑM�Dq K�#^`�b�
�xE#�-@��T&)?*�u��j5e�+6�������D�" �hl���Wł�ø��m, �*�����`,W� �Sl%�"XYi�$� `t�e��3g_^�x���1u�L�t8 �p�C�*��*�K�v�X�Ԃ���u�hg���"�
7_ ���V6^���Ã�ӥ����fr��X �}��X��-���<�lYg�:����l5h�
�բLa��l�]8���j��y�$2���Ȓ&K"#:�u��᯿�Ѹ�M���O�=�(� 2�N� x<�E���4��^�ҕ�.]i��՜�%F�X�����7�ڟ��LuQQ���&JH��(1C���� �t���I��~��lod�������o����  �x`�x�0c1<1,b��S�s������f=}��������PTZ���Њ
EE+p/���y��Ԧ���x��^��ԟ���������z�@������ܔ��řk�ց��/:��j�&6�vF��S���G&��=����~��}��&6bC+��h��F[bMlhK����F� nJ�7�2s-}��Kɻܞغ��x�=7�=���x�=���~n�}n�M���M������@Vǁ��(茧5�!2 ��/���w������y�y'�iމ��w��;���? ��g��N��|(��Cg��쯧��q�\�W�^^zu�Rz���~H_�/�W���/K?�^�/�����+��JE���1%�իy-�2�"�āX�hE[bMlh%6���m���m��:N���g�o�|�c��ܝ<�^��o���gE����M�&{���=�����p��>7�p{n�}n?nr{����~Չ�~���Օ)_y�<��ɣ���u<�<1ܝ��>���eo����a��O($"( ��;3e�m�u�^��Ł�d��т�Qj�՞�l@)R@� Y�,��Ws�Q	.@T8�	��3���Y@�|lA�����m��3e6i�@�Bu����#��b-H-(�p��H]3!Ji1FIK���o۶l{DC�
%��űp��E�X���i8��(I�r���!E��֦M�<���ҹ��ʢ�(oEc6Pw��7O��pr�m�Uͻf1�@�CDHg6���)��k˺���I��q��A�ѤEs无p�D��t̴�80P��jմ�F(_�)	(a\�R�X�|6�r���T��fZ�i5|	��D�(��q�����f��f�rp@�
d)RU�z�VS(����[z��B%�ș�q@5�|�����CI�f
���d��b12���t#M�d��#Q*k\��J�̏'����Q~x��t  �"��q���q.̸x�hR����tҖ(�����]��V  ��R���4Q��dOH���ř�ŕ3�9s�e�f��� �q������D$�BG ..x\\\���p~�ue~���  �F8a�3 @,v�F�  $l1� ,���	  ���R$ ��|Z!����_8����P*I4Qy �a��u��q��(�ICM�J �O���� !�be��4Q4���xL��뼗׵��� �����+I4Pn$'5J���`1�>���O���1�A��-��M��Ɖd�<�  0[V������i<�&@��Z� ���/ ���ыŧ���ەy��b JQj���ٜʹd  p�߻��}��(�2�~8�3ku�$�b���M��S�: �~�Zp�п�u�so�=�  $Q*����D4�hd�й�" ���R<���  ����K߶���& $1cmԚȩ�;�( ������� `z��5���:n�
���A�*]$�$���$��%�  p�n��J4�m�� Lo�\j7��҅SO0�2b "c��ND���F�� 	#$�9ϸX ��WoKԫ�U�Y����@��'��:��<^`e �It�)}�EB(�f�S�7�\#5��  ����V�}.�E޿�=����� �������Q-KH  B$�#&"�"	B�)  Tt_7����s�12l'��)���� ��u���l�^gЁ*bhW6�������x��E ����Ǔ�v u`��g��{����u�Q@�$� 81�]���*��5&g������6�A� ��θAiֽ���~���d�т\� a��.ﻗw�6l�V���߳���N `��3n`�l>���y����r_htߩ��5�PDYd��#��a���ˮ��פy���B���M{Vu?  og���θ�Yw _|5�}�/G|C�n�~�5�J��-�"�8a�)�2�����ca�ŤqgO MO�i�ڿ>��                [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://l0bglgvhot7y"
path="res://.godot/imported/the thing.apple-touch-icon.png-cadae2f34c66269d0d3cc3675f2a38b3.ctex"
metadata={
"vram_texture": false
}
           GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cegflpm6e6rjq"
path="res://.godot/imported/the thing.icon.png-79027cd0e96f7fce49f61c0e0fdc2e2a.ctex"
metadata={
"vram_texture": false
}
      GST2      X     ����                X       �,  RIFF�,  WEBPVP8L�,  /Õ�mۆq�����1�Ve���G�N^6۶�'�����L �	���������'�G�n$�V����p����̿���H�9��L߃�E۶c��ۘhd�1�Nc��6���I܁���[�(�#�m�9��'�mۦL���f�����~�=��!i�f��&�"�	Y���,�A����z����I�mmN����#%)Ȩ��b��P
��l"��m'���U�,���FQ�S�m�$�pD��жm�m۶m#�0�F�m�6����$I�3���s�������oI�,I�l���Cn����Bm&�*&sӹEP���|[=Ij[�m۝m��m���l۶m��g{gK�jm���$�vۦ�W=n�  q��I$Ij�	�J�x����U��޽�� I�i[up�m۶m۶m۶m۶m�ټ�47�$)Ι�j�E�|�C?����/�����/�����/�����/�����/�����/�����/�����̸k*�u����j_R�.�ΗԳ�K+�%�=�A�V0#��������3��[ނs$�r�H�9xޱ�	T�:T��iiW��V�`������h@`��w�L�"\�����@|�
a2�T� ��8b����~�z��'`	$� KśϾ�OS��	���;$�^�L����α��b�R鷺�EI%��9  �7� ,0 @Nk�p�Uu��R�����Ω��5p7�T�'`/p����N�گ�
�F%V�9;!�9�)�9��D�h�zo���N`/<T�����֡cv��t�EIL���t  �qw�AX�q �a�VKq���JS��ֱ؁�0F�A�
�L��2�ѾK�I%�}\ �	�*�	1���i.'���e.�c�W��^�?�Hg���Tm�%�o�
oO-  x"6�& `��R^���WU��N��" �?���kG�-$#���B��#���ˋ�銀�z֊�˧(J�'��c  ��� vNmŅZX���OV�5X R�B%an	8b!		e���6�j��k0C�k�*-|�Z  ��I� \���v  ��Qi�+PG�F������E%����o&Ӎ��z���k��;	Uq�E>Yt�����D��z��Q����tɖA�kӥ���|���1:�
v�T��u/Z�����t)�e����[K㡯{1<�;[��xK���f�%���L�"�i�����S'��󔀛�D|<�� ��u�={�����L-ob{��be�s�V�]���"m!��*��,:ifc$T����u@8 	!B}� ���u�J�_  ��!B!�-� _�Y ��	��@�����NV]�̀����I��,|����`)0��p+$cAO�e5�sl������j�l0 vB�X��[a��,�r��ς���Z�,| % ȹ���?;9���N�29@%x�.
k�(B��Y��_  `fB{4��V�_?ZQ��@Z�_?�	,��� � ��2�gH8C9��@���;[�L�kY�W�
*B@� 8f=:;]*LQ��D
��T�f=�` T����t���ʕ�￀�p�f�m@��*.>��OU�rk1e�����5{�w��V!���I[����X3�Ip�~�����rE6�nq�ft��b��f_���J�����XY�+��JI�vo9��x3�x�d�R]�l�\�N��˂��d�'jj<����ne������8��$����p'��X�v����K���~ � �q�V������u/�&PQR�m����=��_�EQ�3���#����K���r  ��J	��qe��@5՗�/# l:�N�r0u���>��ׁd��ie2� ���G'& �`5���s����'����[%9���ۓ�Хމ�\15�ƀ�9C#A#8%��=%�Z%y��Bmy�#�$4�)dA�+��S��N}��Y�%�Q�a�W��?��$�3x $��6��pE<Z�Dq��8���p��$H�< �֡�h�cާ���u�  �"Hj$����E%�@z�@w+$�	��cQ��
1�)��������R9T��v�-  xG�1�?����PO�}Eq�i�p�iJ@Q�=@�ݹ:t�o��{�d`5�����/W^�m��g���B~ h�  ����l  נ�6rߙ�����^�?r���   ���⤖��  �!��#�3\?��/  �ݝRG��\�9;6���}P6������K>��V̒=l��n)��p	 ����0n䯂���}   ���S*	 ��t%ͤ+@�����T�~��s����oL)�J� 0>��W�-  �*N�%x=�8ikfV^���3�,�=�,}�<Z��T�+'��\�;x�Y���=���`}�y�>0����/'ـ�!z9�pQ��v/ֶ�Ǜ����㗬��9r���}��D���ל���	{�y����0&�Q����W��y ����l��.�LVZ��C���*W��v����r���cGk�
^�Ja%k��S���D"j���2���RW/������ض1 ����
.bVW&�gr��U\�+���!���m ;+۞�&�6]�4R�/��Y�L�Ά`"�sl,Y/��x��|&Dv�_
Q*� V�NWYu�%��-�&D�(&��"  Wc��ZS���(�x� ,�!����!�L�AM�E�]}X�!��wB�o��-  �-���16���i���ю�z��� ���B��oB�0������v]���ȓ�����3�� +S�χ�=Q_�����˨�d��|)D>��k ��uȣ���Y[9̂�����! ^�!��r���j0Y+i��΍e(�ț� ���x��
��{��<6 R���پ�b��Y
C����+���������;���a ���,�o��bC�{�?���1 �(��¤ �V�������;�=��I��� ���EI���Z��)D����t=S ��] X��9K�= �.~�K[��Ŋ��,2��� p}>w<n�g h�
�t���R�u�G�1k���!��x���������� �L���|>D�0�Ǣ(Qc�� ����= �ۊ�Z0�^��c �
|�����L�%�d��q���(�WB� ��(	���� �J��8D�0�~$�Dsy�Ѿ!������j�^ ��mOa�8.�qce��s|%Dq~,X�u�������=T	���Q�M�ȣm�Y�%Y+�[�0|"DΞ�j�u�L6�(Qe��qw�V�э���ǂ���!j�K � �:�wQ�dÛ������R�
��C���X�u�`����\"j讀Dq21� �F>B[��[������]@K-���C�e�q�tWP�:W�۞X�z��,��t�p���P��Se����T���{dG��
KA���w�t3t��[ܘ�4^>�5ŉ�^�n�Eq�U��Ӎ��α�v�O6C�
�F%�+8eů��M����hk��w�欹񔈓����C��y訫���J�Is�����Po|��{�Ѿ)+~�W��N,�ů��޽���O��J�_�w��N8����x�?�=X��t�R�BM�8���VSyI5=ݫ�	-�� �ֶ��oV�����G������3��D��aEI��ZI5�݋����t��b��j��G����U���΃�C�������ق�в����b���}s����xkn��`5�����>��M�Ev�-�͇\��|�=� '�<ތ�Ǜ���<O�LM�n.f>Z�,~��>��㷾�����x8���<x�����h}��#g�ж��������d�1xwp�yJO�v�	TV����گ�.�=��N����oK_={?-����@/�~�,��m ��9r.�6K_=�7#�SS����Ao�"�,TW+I��gt���F�;S���QW/�|�$�q#��W�Ƞ(�)H�W�}u�Ry�#���᎞�ͦ�˜QQ�R_��J}�O���w�����F[zjl�dn�`$� =�+cy��x3������U�d�d����v��,&FA&'kF�Y22�1z�W!�����1H�Y0&Ӎ W&^�O�NW�����U����-�|��|&HW������"�q����� ��#�R�$����?�~���� �z'F��I���w�'&����se���l�̂L�����-�P���s��fH�`�M��#H[�`,,s]��T����*Jqã��ł�� )-|yč��G�^J5]���e�hk�l;4�O��� ���[�������.��������������xm�p�w�չ�Y��(s�a�9[0Z�f&^��&�ks�w�s�_F^���2΂d��RU� �s��O0_\읅�,���2t�f�~�'t�p{$`6���WĽU.D"j�=�d��}��}���S["NB�_MxQCA[����\	�6}7Y����K���K6���{���Z۔s�2 �L�b�3��T��ݹ����&'ks����ܓ�ЛϾ�}f��,�Dq&������s��ϼ��{������&'k�����Qw窭�_i�+x�6ڥ��f�{j)���ퟎƍ3ou�R�Y����徙�k����X�Z
m.Y+=Z��m3�L47�j�3o�=�!J
5s���(��A ��t)���N�]68�u< Ƞ��_�im>d ��z(���(��⤶�� �&�ۥ� ��  Vc�8�'��qo9 �t��i�ρdn��Of���O�RQP���h'������P֡���n ���č����k�K@�>����pH>z)-|��B��j���!j:�+������˧��t�������1����.`v�M�k�q#�$���N:�����-M5a10y����(�T��� X5 \�:� ?+�7#�?�*Y+-,s� ~�|\)뀀ap �drn�g��RN�X�er ��@ĕ���;��z��8ɱ�����	�- �
�bKc����kt�U]�䎚���hgu���|�_J{ �`p��o�p�T�U��p���/���Hϑ�H�$X ܬm3���ŉ�U'��뻩t��G9�}�)O������p�΃g���JO���\9�׫�����ڳ�!k����/��9R���^�%��C����T���;ji<�>�KY����;�J��ƶm .P��pT��
@HA��r��98V���b�v���YwaZ>�$oւ?-փ��ʹ|0�.��3���b駁�c��;?8E;���V�B�؀����|%\\s��%����e{o��Z�i�������^���s�Jx������B jh�\ �h�<��V��sh@:���.�ІYl��˂�`3hE.,P�2^����J��+�����p��
�ЊJd��x�*�@�7R��� �"�G="!�� �p����u�o��wV�m�g���~F��?����/�����}~����sо7� ���\,,k�J�T�6������Z�y�rBZ[D�>v�HQ�R��mq�������DD�-6+�V`���J�E�����\� 9!ߑ�`��6���ml�~ZM�Z�ȎV���g���������3?*u3���ctW����YQa�Cb�P�,B5�p0�m�cͺEt�{,��>s9f�^��`OG��]����2�Fk�9_�G�vd��	��)��=�1^Ų�Wl3{�����1��H)�e������9�هZ�]}�b���)b�C��es}�cVi~x���e
Z�)܃��39������C�(�+R����!�j����F�n���<?�p��l�8a�4xOb��������c�8&�UA�|	/l�8�8���3t�6�͏���v���� ����סy�wU��`� =��|M�Y?�'�A��&�@*�c~!�/{��),�>�=xr"	�qlF:��L&���=<5t�h.�#ᣭ���O�z�!�&`A�F�yK=�c<\GZ�� 4HG�0i�F녠uB"���<��c�Jeۈ�3!����O��q萞PiZ&�$M[���(G��e���ؤ���ã��O���5����'�gH~�����=��g�F|8�+�X�4�u���G�2����'��.��5[�OlB��$f4���`��mS�L�,y�t&V�#P�3{ ��763�7N���"��P��I�X��BgV�n�a:$:�FZ���'�7����f������z!�����KA�G��D#������ˑ`ڶs���&� ݱ��4�j��n�� ݷ�~s��F�pD�LE�q+wX;t,�i�y��Y��A�۩`p�m#�x�kS�c��@bVL��w?��C�.|n{.gBP�Tr��v1�T�;"��v����XSS��(4�Ύ�-T�� (C�*>�-
�8��&�;��f;�[Փ���`,�Y�#{�lQ�!��Q��ّ�t9����b��5�#%<0)-%	��yhKx2+���V��Z� �j�˱RQF_�8M���{N]���8�m��ps���L���'��y�Ҍ}��$A`��i��O�r1p0�%��茮�:;�e���K A��qObQI,F�؟�o��A�\�V�����p�g"F���zy�0���9"� �8X�o�v����ߕڄ��E �5�3�J�ص�Ou�SbVis�I���ص�Z���ڒ�X��r�(��w��l��r"�`]�\�B���Ija:�O\���/�*]�þR������|���ʑ@�����W�8f�lA���Xl��촻�K<�dq1+x�*U�;�'�Vnl`"_L�3�B����u�����M���'�!-�<;S�F�܊�bSgq� ���Xt�肦�a��RZ�Y_ި��ZRSGA��-:8����yw_}XW�Z���-k�g.U��|�7P�
&���$˳��+��~?7�k�bQ���g������~�Z�e����H�-p�7S�� 
�w"XK�`K%?�`Tr|p���"��\�a�?�٧ ��'u�cv�&��<LM�Ud��T���Ak��������'+7��XR`��[\�-0���e�AiW]�Dk���$u���0[?�-���L����X�ĚSK-�.%�9=j�3t^���(c�yM-��/�ao����\%�?�б �~���b][
tٵ�<qF�)�
�J�'QZY�����*pB�I4�޸�,������.Т�1���/
t�1-1������E�*��Cl/Ю©f�<,0�S�bf�^���[8Z$��@���kw�M<?�[`��)3)1� �U����:��/pR��XV`XE,/0���d���1>ѫ��i�z��*o�}&R{���$f�JV=5͉Ύ��Rl�/�N4.�U~Cm�N~��HPRS�?G��g�-���qvT{�G _�[ua�;���kco�9�Kw����n����E{d�j��C���,q����Y���cwY<$#�ؤ�m+�LL-�z� �y<{/7���[��X�?�-6(cO ?�XZ�M�������sb�[
�.����j|;d�!0lCIqZ�z�&��~�|7�A���A~��á@�� 417��}t ��,� X�6��lS)6v�G
��I:�).~��8R���#'��߶;9�'���U�$1nC�L��찦3�+b黙u�NJ�����8���X�?5�0��^��[B/+�0�Ur(��J��+Xr�H�����HZm&�#�p	�Y ����*���hM]��m���b�ݢ����G����s��z-�x��������� �J�"���Ћ�g�Ҝ �Aа��?��?6��c�Zx�$�t��{s
-R�E�24�?�{�l�-��1�3S�EJ��v6X]L�B^ ��]N��R�yN��62�����'R�p-�����n2�d�?Th|�h��3X������Rc8&��_,��;T�8�� �hΗv�(7I;�3Obn;��O�!����Lߍ*�E~wU,���n�MN1���Z��Y̖��tY;5�^�<Z�Ǩ�T#�bt�xfA�n�cq����"9GD*�^JL��HJ���4���V�-�܉��4*��u]�[
���,"ҏ�i!�r~L��_�����8 ]j�?x���<k+%w��Bk��=�u�ڤ��>%2Bۃ�Y�n<jBo������Κ�0M~�t>�#b/jZ�}���B��Q��#���6R$v�����k�R$c/:�~���(V�7;)��ߊ[̣0?F��;.�*ݪd������{A`w>~�i=D�c��������Y2�X�q~�r2��8@v=f�?��X��S�"X�j?��@$?�����x�(�k���c7��\�����>A�=fpM?9d?�׻{���)f�.⪝���3�������f,N;"��,N���X��*�"V���"��C��?���(2=���A��1�Ul���h�8Ao(5X�B�X�>S�j��s�!
l����GgGp��>�v;c���V�N1���-��K�S�=6PiN�fNq������,
�3SWx�ei����f'�*�r�rʹ̙�e�7���b�o���>_i��M�_��V�p�r�9��X�$�����B���t5�4#�B(E���3�������`����I�M�e��b6_����{~�f/��@��B��Y����E�4��޲�d�O�$���M�����ݖv�P����TR�oj~��+}��#���"�]1Υ_���nR���œ����^pQ2�7첾b��3�ba�\��uu2�~O�G�����5�^>v������m��?���mC;$eT��C񎋋��V��8�:��
���ʱlt��~e]�cC7dl���.�i����\w����/..F�Q5���œ��`�o���E����E�͛�ٽ-�o�z�"n��/��[�����ͳI���S��Dڢ��V�6��!��esq��AC���ڻ���OMk�y��{7`c0�ٺ���5C5�yiw��`ps�OC��f�X�5oQ�\_*m�f�)稹"���a2$O;�]C�A�;V.���c��iޢ�R5�X��t%�s����ȸ�; 5�����)��X|?����9&��wĽjdn�{��7��/����q]3Ɲ�}�[��yF~�Q0����x��U�� ���˘?����a�;���/yޫ�����6.��C}���&L��9�_�ս�w�o���W�^�;�^u�xoݖ��Q8����4��kW��'����:9>����Xp5H��ONtL��=��_�&�0��H"Q��|H���4!���]�'�!޹Eܢ���}=soϢ~	K�$���`"!]j�+{'e�M��D]��=�>c��xS��Y����X��7�7+�Me̯/���u�Q����i���Eg�9�g�RU��#'��ޑW\r�aS�/3�"/v
IgX���}ٻ���ʏr�r���_��<�6�Gʋ&���z%�Pl^d����㑭v�ʎو�w�[���Q��k�K�����IWˈ��`/�Y�X��9J"��_��V{��je�i��6�<�ZS��� �t���W�Bg��@5���..��X�eʡ��*�HRgkD^>�y裝"�9�+wQ4ABR������^�k3�>2�����x�C�l���f:��#gщ�s� ��ߜ��ȁ���+���A��˾�g�1K9Cܹ��:���T"!I������Hs�;���ue��9@#ChE5&!��'�2�����w*a/Q��I	�E������I�w�����?��v })B��GQ�n�h"]0��]Z֑���.}�&~x2��
eĞsF�n�+�b�e�i����0Ix�y��Aѕ���
[1�B�R$$����:�4E疳��#�4���y���ӈ�6o1O�V'��7]�H�.)/)�OwW./�g�l��£���"$d���}[���t���U~�MQԲ�$��~��c��S�M�a���ш=��diH��(N�+U�D����f"V�"�����.ƈ�#Ͼ�eH:�x��d!k 6�J�f9�GW�4����Kp��T��3��~��G�؀��,�zZ��澰؋7����v#� &�r+O�@Ud7͐�$�\�D�O��W_�Ew�ͻ�7��oD����y��,��Ƣ�cƙd	���U�u�:�#�h6]�R
�U~	V�՟R�V������/�:r�F¬�k?|Ī�r\�<.�^9����?��]Aʻ�iT;vg�PpyM���1��},�dY\e8��I��2�wjM��S/�p�1�\^�6$4�F��(:�\nۢ�2�}�Pm�X�'.����U�3��bq�nXK�i_BD�_H}�r;Y^�t�<���o��#gw��2q_�|�^�<��E�h���O�����R�-Ɖ���S�	!��z�1�+iH�1G���+<����~�;|�F�{�}v�;s�j�Q;�٩�;&f�}�������tL ���#��Ъ>;��z���?U˽�~������e��{K%��/:F�/<�n�2k�8�x��S-�5�`��ԗ�H�{���R�y�S�(w��ѥe
�	0���w�޻�U1��7V-Q�̶ꪸ�g�X��3V&�T[+)b����2���(���B��,��z����9���B`��!��o�ע(�W�RZ���m��%/V�&��|g��f��*[_��nn��M�M`�%��)��Z�K$�����F�� ��$r^�k�K,	u;w������X���;�L�eoI�6��y%����~����)���0"�zc�BH�<�kW�E\.�b��R>mٺ��<����͑Թ���a=2X���=/��_;	Ρ�e&o.����]��2!�嫈�"I������j�höR��͒\L�0�e������,)ýf�; ��E��0��<%�Q�Aø�x8�� �]eQL�;|���꼬z�W2
�H�z�_��
/K`J�O�O�Y�~j���>����d�v��%�ެ7�4{%��٥7Z��>����|��5^�\ױ���:��Z^;��U��s�)��#�|�.̡���R2��j����şBб���*cMvD�W^{�������m�D��0�,������#���?O����
����?z�{ȓ'�|����/�����/�����/�����/�����/�����/�����/�����/|�           [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://c051f8jffhfn1"
path="res://.godot/imported/the thing.png-849b6c804b32037f44cd16b57e05772d.ctex"
metadata={
"vram_texture": false
}
           GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://c6w5ot2juvj14"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    radius    height    script    animations 	   _bundled           local://CapsuleShape2D_dm6r7 l         local://SpriteFrames_p6xtl �         local://PackedScene_yenn0 �         CapsuleShape2D             SpriteFrames             PackedScene          	         names "         World    Node2D    CharacterBody2D    CollisionShape2D    shape    AnimatedSprite2D    sprite_frames    AnimationPlayer    	   variants                                node_count             nodes     '   ��������       ����                      ����                     ����                           ����                          ����              conn_count              conns               node_paths              editable_instances              version             RSRC              [remap]

path="res://.godot/exported/133200997/export-a53284a8164c2bc57dbb020cbec96c69-player.scn"
             [remap]

path="res://.godot/exported/133200997/export-a72371f07eede78412de7b96ea39a6a0-world.scn"
              [remap]

path="res://.godot/exported/133200997/export-76e0adcbc83681695885bae615f516ae-world.scn"
              list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              �s+9vD�[   res://player/Scene/player.tscn\��"��   res://player/Scene/world.tscn������a   res://icon.svg��u��O   res://world.tscn�s�}6�n8   res://The thing went here/the thing.apple-touch-icon.png��ڭ*;x['   res://The thing went here/the thing.png�:j#OF,   res://The thing went here/the thing.icon.png    ECFG      application/config/name      	   Downloads      application/run/main_scene(         res://player/Scene/world.tscn      application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg     editor_plugins/enabled,   "         res://addons/AS2P/plugin.cfg       