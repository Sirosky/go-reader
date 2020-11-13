
extends Camera2D

onready var Main = get_node("/root/Main")
onready var Streamer = get_node("/root/Main/Core/Streamer")


# Camera control settings:
# key - by keyboard
# drag - by clicking mouse button, right mouse button by default;
# edge - by moving mouse to the window edge
# wheel - zoom in/out by mouse wheel
# set current to to true! (inspector)
export (bool) var key = true
export (bool) var drag = true
export (bool) var edge = false
export (bool) var wheel = true
export (bool) var active = true

export (int) var zoom_out_limit = 4
export (int) var zoom_in_limit = .6

# Camera speed in px/s.
export (int) var camera_speed = 1200
export (int) var camera_scroll_speed = 150

# Initial zoom value taken from Editor.
var camera_zoom = get_zoom()

# Value meaning how near to the window edge (in px) the mouse must be,
# to move a view.
export (int) var camera_margin = 50

# It changes a camera zoom value in units... (?, but it works... it probably
# multiplies camera size by 1+camera_zoom_speed)
const camera_zoom_speed = Vector2(0.1, 0.1)

# Vector of camera's movement / second.
var camera_movement = Vector2()

# Previous mouse position used to count delta of the mouse movement.
var _prev_mouse_pos = null

#Backup values that can be used when camera is disabled
var position_x
var position_y
var _zoom

var camera_origin = Vector2() #Top left of camera
#Limits of camera
var camera_limit_x1 = -4000
var camera_limit_y1 = -24
var camera_limit_x2 = 4000
var camera_limit_y2 = 999999

signal camera_moved

#Backup loading
var camera_dir = 0 #0 up, 1 down
var camera_timer_check = 1 #How long load timer should be set after movement
onready var Timer = get_node("Timer")

# INPUTS

# Right mouse button was or is pressed.
var __rmbk = false
# Move camera by keys: left, top, right, bottom.
var __keys = [false, false, false, false]

func _ready():
	set_h_drag_enabled(false)
	set_v_drag_enabled(false)
	set_enable_follow_smoothing(true)
	set_follow_smoothing(10)
	Timer.connect("timeout", Streamer, "_on_Timer_timeout")
	position.x = 0
	position.y = OS.get_screen_size().y/2
	
func _physics_process(delta):
	if active == true:
		#Calculate camera origin
		camera_origin.x = position.x - OS.get_screen_size().x/2
		camera_origin.y = position.y - OS.get_screen_size().y/2
	
		# Move camera by keys defined in InputMap (ui_left/top/right/bottom).
		if key:
			if __keys[0]:
				camera_movement.x -= camera_speed * delta
			if __keys[1]:
				camera_movement.y -= camera_speed * delta
			if __keys[2]:
				camera_movement.x += camera_speed * delta
			if __keys[3]:
				camera_movement.y += camera_speed * delta

		
		# When RMB is pressed, move camera by difference of mouse position
		if drag and __rmbk:
			camera_movement = _prev_mouse_pos - get_local_mouse_position()
		
		#Bind camera to limits. Not 100% perfect but good enough here.
		if position.x - OS.get_screen_size().x/2 - camera_movement.x < camera_limit_x1 and camera_movement.x < 0:
#			print(position.x - OS.get_screen_size().x/2 - camera_movement.x)
#			print("stop")
			camera_movement.x = 0
		if position.y - OS.get_screen_size().y/2 - camera_movement.y < camera_limit_y1 and camera_movement.y < 0:
			camera_movement.y = 0
		if position.x + OS.get_screen_size().x/2 + camera_movement.x > camera_limit_x2 and camera_movement.x > 0:
			camera_movement.x = 0
		if position.y + OS.get_screen_size().y/2 + camera_movement.y > camera_limit_y2 and camera_movement.y > 0:
			camera_movement.y = 0
			
#		print("camera_movement.x: " + str(camera_movement.x))

		# Update position of the camera.
		if camera_movement.y != 0 or camera_movement.x != 0: #Only checking y, because X doesn't matter for infinite scroll
			position += camera_movement * get_zoom()
			emit_signal("camera_moved")
			
			#For 2nd buffer loading
			if camera_movement.y > 0: camera_dir = 1
			if camera_movement.y < 0: camera_dir = 0
			
			Timer.start(camera_timer_check)
			
		
		# Set camera movement to zero, update old mouse position.
		camera_movement = Vector2(0,0)
		_prev_mouse_pos = get_local_mouse_position()
		
		#Limits
#		camera_limit_y2 = Tex.rect_size.y
		
		

func _unhandled_input( event ):
	if active == true:
		if event is InputEventMouseButton:
			
			#Dragging
			if drag and\
			   event.button_index == BUTTON_LEFT:
				# Control by right mouse button.
				if event.pressed: __rmbk = true
				else: __rmbk = false
			
			# ZOOOOOOOM
			if event.button_index in [BUTTON_WHEEL_UP, BUTTON_WHEEL_DOWN] and event.control:
				# Checking if future zoom won't be under 0.
				# In that cause engine will flip screen.
				if event.button_index == BUTTON_WHEEL_UP and\
				camera_zoom.x - camera_zoom_speed.x > zoom_in_limit and\
				camera_zoom.y - camera_zoom_speed.y > zoom_in_limit:
					camera_zoom -= camera_zoom_speed
					set_zoom(camera_zoom)
					# Checking if future zoom won't be above zoom_out_limit.
				if event.button_index == BUTTON_WHEEL_DOWN and\
				camera_zoom.x + camera_zoom_speed.x < zoom_out_limit and\
				camera_zoom.y + camera_zoom_speed.y < zoom_out_limit:
					camera_zoom += camera_zoom_speed
					set_zoom(camera_zoom)
			
			# Scrolling
			if event.button_index == BUTTON_WHEEL_UP and !event.control:
				camera_movement.y -= camera_scroll_speed
			if event.button_index == BUTTON_WHEEL_DOWN and !event.control:
				camera_movement.y += camera_scroll_speed
			
				
		
		# Control by keyboard handled by InpuMap.
		if event.is_action_pressed("ui_left"):
			__keys[0] = true
		if event.is_action_pressed("ui_up"):
			__keys[1] = true
		if event.is_action_pressed("ui_right"):
			__keys[2] = true
		if event.is_action_pressed("ui_down"):
			__keys[3] = true
		if event.is_action_released("ui_left"):
			__keys[0] = false
		if event.is_action_released("ui_up"):
			__keys[1] = false
		if event.is_action_released("ui_right"):
			__keys[2] = false
		if event.is_action_released("ui_down"):
			__keys[3] = false

func pos_in_bounds(x, y): #Check if the proposed position is within camera bounds
	if x > camera_limit_x1 and y > camera_limit_y1 and x < camera_limit_x2 and y < camera_limit_y2:
		return true
	else:
		return false
