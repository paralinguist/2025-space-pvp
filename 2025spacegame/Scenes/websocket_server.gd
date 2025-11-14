class_name WebSocketServer extends Node
class PendingPeer:
	var connect_time: int
	var tcp: StreamPeerTCP
	var connection: StreamPeer
	var ws: WebSocketPeer
	
	func _init(p_tcp: StreamPeerTCP) -> void:
		tcp = p_tcp
		connection = p_tcp
		connect_time = Time.get_ticks_msec()


const PORT: int = 9876
const TECH_TEAM: int = 0
const RETRO_TEAM: int = 1

var api_version := "0.9"
var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
var pending_peers: Array[PendingPeer] = []
var peers: Dictionary
var clients: Dictionary

@export var TechShip: Ship
@export var RetroShip: Ship


@export var handshake_timeout := 3000

signal message_received(peer_id: int, message: String)
signal client_connected(peer_id: int)
signal new_client(peer_id: int, role: String, team: int)
signal client_disconnected(peer_id: int)
#signal action(role: String, team: int, action: String)

func log_message(message: String) -> void:
	var time := "[color=#aaaaaa] %s |[/color] " % Time.get_time_string_from_system()
	print_rich(time + message + "\n")

func _ready() -> void:
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server.")
		set_process(false)
	
func _process(_delta: float) -> void:
	poll()
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			log_message(socket.get_packet().get_string_from_ascii())

func _connect_pending(p: PendingPeer) -> bool:
	if p.ws != null:
		#Poll WS client if doing handshake
		p.ws.poll()
		var state := p.ws.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			var id := randi_range(2, 1 << 30)
			peers[id] = p.ws
			client_connected.emit(id)
			print("Client connected: " + str(id))
			return true #Successful connection
		elif state != WebSocketPeer.STATE_CONNECTING:
			return true #Failed connection
		return false #Connection still in progress
	elif p.tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return true #TCP disconnected
	#TCP ready, create WS peer
	p.ws = WebSocketPeer.new()
	p.ws.accept_stream(p.tcp)
	return false #WS peer connection is pending

func get_message(peer_id: int) -> String:
	assert(peers.has(peer_id))
	var message_socket: WebSocketPeer = peers[peer_id]
	if message_socket.get_available_packet_count() < 1:
		return "Not OK"
	var pkt: PackedByteArray = message_socket.get_packet()
	if message_socket.was_string_packet():
		var message = pkt.get_string_from_utf8()
		var ship_instruction = JSON.new()
		if ship_instruction.parse(message) == OK:
			var instruction = ship_instruction.data
			if instruction["action"] == "join":
				print(instruction["team"] + " " + instruction["role"] + " has joined!" + "(API:" + instruction["version"] + ")")
				clients[peer_id] = {"team":instruction["team"], "role":instruction["role"]}
				emit_signal("new_client", clients[peer_id])
				if instruction["role"] == "weapons":
					send_weapon_info(peer_id)
				elif instruction["role"] == "pilot":
					pass
			else:
				var ship = TechShip
				if clients[peer_id]["team"] == "retro":
					ship = RetroShip
				if instruction["action"] == "move":
					if instruction["direction"] == "right":
						ship.move(1)
					else:
						ship.move(-1)
				elif instruction["action"] == "shoot":
					ship.shoot(int(instruction["weapon_id"]))
				elif instruction["action"] == "shield":
					ship.add_shield()
	return "OK"
	
func poll() -> void:
	if not tcp_server.is_listening():
		return
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		pending_peers.append(PendingPeer.new(conn))
	
	var to_remove := []
	
	for p in pending_peers:
		if not _connect_pending(p):
			if p.connect_time + handshake_timeout < Time.get_ticks_msec():
				print("Removing peer: " + str(p))
				to_remove.append(p)
			continue
		to_remove.append(p)
		
	for r: RefCounted in to_remove:
		pending_peers.erase(r)
		
	to_remove.clear()

	for id: int in peers:
		var p: WebSocketPeer = peers[id]
		p.poll()
		
		if p.get_ready_state() != WebSocketPeer.STATE_OPEN:
			client_disconnected.emit(id)
			to_remove.append(id)
			if id in clients:
				log_message(clients[id]["team"] + clients[id]["role"] + " has disconnected")
				clients.erase(id)
			continue
		
		while p.get_available_packet_count():
			message_received.emit(id, get_message(id))
		
	for r: int in to_remove:
		peers.erase(r)
	to_remove.clear()

func send(peer_id: int, message: String) -> int:
	var type := typeof(message)
	if peer_id <= 0:
		for id: int in peers:
			if id == -peer_id:
				continue
			peers[id].put_packet(message.to_utf8_buffer())
		return OK
	
	assert(peers.has(peer_id))
	var send_socket: WebSocketPeer = peers[peer_id]
	if type == TYPE_STRING:
		return send_socket.send_text(message)
	return send_socket.send(var_to_bytes(message))

func send_weapon_info(peer_id: int):
	var team = clients[peer_id]["team"]
	var weapons = []
	if team == "tech":
		weapons = TechShip.get_weapons()
	else:
		weapons = RetroShip.get_weapons()
	var message = {"type":"weapon_info", "data":weapons}
	send(peer_id, JSON.stringify(message))

#Update message: Send data about power, immobilised/disabled, free moves, shields, HP?
func _on_status_timer_timeout():
	var status_message = {"type": "status"}
	var tech_status = TechShip.get_status()
	var retro_status = RetroShip.get_status()
	for client in clients:
		if clients[client]["team"] == "tech":
			status_message["data"] = tech_status
		else:
			status_message["data"] = retro_status
		send(client, JSON.stringify(status_message))
