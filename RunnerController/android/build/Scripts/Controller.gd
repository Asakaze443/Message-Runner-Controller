extends Control

onready var ws = $WSClient
onready var debugText : Label = $Connection/Control/ColorRect2/debugText
onready var ip : LineEdit = $Connection/Control/ColorRect2/IPLE
onready var step_number : LinkButton = $LandscapeUI/Steps
onready var step_number2 : LinkButton = $PortraitControls/Steps2

onready var sensitivity_sb : SpinBox = $LandscapeUI/SensitivitySB
onready var gameName_le : LineEdit = $LandscapeUI/GameNameLE


const GRAVITY: float = 9.8
const OFFSET_MAX: float = 620.0
const PORT = 5353

var pedometer_step = 0
var x_accel = 0
var y_accel = 0
var z_accel = 0
var magnitude_prev = 0

var coefficient = 0.35
var sensitivity = 11 #default

var data = {
	"move_forward": false,
	"view_up": false,
	"view_down": false,
	"view_left": false,
	"view_right": false,
	"ui_accept": false,
	"ui_cancel": false,
	"step":pedometer_step
}

var pressed_A = false
var pressed_B = false
var pressed_up = false
var pressed_down = false
var pressed_left = false
var pressed_right = false

var moved_forward

func _process(delta):
	var accel = Input.get_accelerometer()
	var timer = 0.3
	##ACCEL
	if accel != null:
		
		#smoothing the inputs
		#x_accel = x_accel + coefficient * (accel.x - x_accel)
		#y_accel = y_accel + coefficient * (accel.y - y_accel)
		#z_accel = z_accel + coefficient * (accel.z - z_accel)
		
		#rounding inputs
		x_accel = roDec(accel.x)
		y_accel = roDec(accel.y)
		z_accel = roDec(accel.z)		
		
		#x_accel = roDec(x_accel)
		#y_accel = roDec(y_accel)
		#z_accel = roDec(z_accel)
	
	var magnitude_accel = sqrt(x_accel*x_accel + y_accel*y_accel + z_accel*z_accel)
	var magnitude_delta = magnitude_accel - magnitude_prev
	magnitude_prev = magnitude_accel
	step_number.text = String(pedometer_step)
	step_number2.text = String(pedometer_step)
	
	sensitivity = $LandscapeUI/SensitivitySB.value #assign spinbox value to sensitivity
	
	var proceed
	if magnitude_delta > sensitivity:
		pedometer_step += 1
		moved_forward = true
	
	else:
		moved_forward = false

#Send updated data
	data = {
	"move_forward": moved_forward,
	"view_up": pressed_up,
	"view_down": pressed_down,
	"view_left": pressed_left,
	"view_right": pressed_right,
	"ui_accept": pressed_A,
	"ui_cancel": pressed_B,
	"step": pedometer_step
	}
	ws.send_data(JSON.print(data))


func roDec(num): #round off decimal
	return round(num * pow(10.0, 5)) / pow(10.0, 5)

func connect_ws():
	#ws.connect_ws("ws://" + ip.text + ": 5353")
	ws.connect_ws("ws://" + ip.text + ":" + String(PORT))

func _on_ConnectBtn_pressed():
	if $Connection/Control/ColorRect2/IPLE.text.empty():
		debugText.text = "Incomplete form, please try again"
		return
	else:
		debugText.text = "Change IP if connection fails"

		
	print("CONNECTING")
	connect_ws()

func _on_WSClient_connected(to_url):
	$Connection.visible = false
	$LandscapeUI.show()
	$LandscapeControls.show()
	$MarginContainer/HBoxContainer/ServerIP.text = to_url
	$MarginContainer/HBoxContainer/Status.text = "CONNECTED"
	
func _on_WSClient_disconnected():
	_on_Reset_Btn_pressed()
	$Connection.visible = true
	#$LandscapeUI/SensitivitySB.hide()
	#$ToPortrait.hide()
	$MarginContainer/HBoxContainer/ServerIP.text = ""
	$MarginContainer/HBoxContainer/Status.text = "DISCONNECTED"
	

func _on_TS_ABtn_pressed(): #A Pressed
	#data = {"ui_accept": true}
	pressed_A = true

func _on_TS_ABtn_released():
	#data = {"ui_accept": false}
	pressed_A = false

func _on_TS_BBtn_pressed(): #B Pressed
	#data = {"ui_cancel": true}
	pressed_B = true

func _on_TS_BBtn_released():
	#data = {"ui_cancel": false}
	pressed_B = false
	
#DIRECTIONAL KEYS
func _on_TS_UpBtn_pressed(): #Up pressed
	#data = {"view_up": true}
	pressed_up = true

func _on_TS_UpBtn_released():
	#data = {"view_up": false}
	pressed_up = false

func _on_TS_DownBtn_pressed(): #Down pressed
	#data = {"view_down": true}
	pressed_down = true

func _on_TS_DownBtn_released():
	#data = {"view_down": false}
	pressed_down = false

func _on_TS_RBtn_pressed(): #Right pressed
	#data = {"view_right": true}
	pressed_right = true
	

func _on_TS_RBtn_released():
	#data = {"view_right": false}
	pressed_right = false

func _on_TS_LBtn_pressed(): #Left pressed
	#data = {"view_left": true}
	pressed_left = true

func _on_TS_LBtn_released():
	#data = {"view_left": false}
	pressed_left = false


func _on_Reset_Btn_pressed():
	pedometer_step = 0
	var data = {
	"move_forward": false,
	"view_up": false,
	"view_down": false,
	"view_left": false,
	"view_right": false,
	"ui_accept": false,
	"ui_cancel": false,
	"step":pedometer_step
}


func _on_ExitBtn_pressed():
	get_tree().quit()




func _on_ToLandscape_pressed():
	$PortraitControls.hide()
	$LandscapeControls.show()
	$LandscapeUI.show()


func _on_ToPortrait_pressed():
	$LandscapeControls.hide()
	$LandscapeUI.hide()
	$PortraitControls.show()
