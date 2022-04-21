extends Node

signal connected(to_url)
#signal on_data()
signal disconnected()

onready var websocketURL = ""

var client = WebSocketClient.new()
var connected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	client.connect("data_received", self, "on_data")

func _process(delta):
	client.poll()

func send_data(data):
	if !connected: return
	client.get_peer(1).put_packet(str(data).to_utf8())

func connect_ws(url):
	print(client.get_connection_status())
	var err = client.connect_to_url(url)
	websocketURL = url
	if err != OK:
		print("Unable to connect...")

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	if !was_clean:
		client.disconnect_from_host()
	connected = false
	emit_signal("disconnected")

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	connected = true
	emit_signal("connected", client.get_connected_host())

#func _on_data(id):
	#var gametype =  JSON.parse(client.get_peer(id).get_packet().get_string_from_utf8()).result
	#if gametype["GameID"] == "Message Runner":
	#	var game_type = "Message Runner"

func kicked():
	get_tree().network_peer = null
