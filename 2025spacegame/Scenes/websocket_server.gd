class_name WebSocketServer
extends Node
class PendingPeer:
	var connect_time: int
	var tcp: StreamPeerTCP
	var connection: StreamPeer
	var ws: WebSocketPeer
	
	func _init(p_tcp: StreamPeerTCP) -> void:
		var tcp: StreamPeerTCP = p_tcp
		var connection: StreamPeerTCP = p_tcp
		var connect_time: int = Time.get_ticks_msec()


const PORT: int = 9876
const TECH_TEAM: int = 0
const RETRO_TEAM: int = 1

var api_version := "0.9"
var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
var pending_peers: Array[PendingPeer] = []
var peers: Dictionary
var clients: Dictionary

@export var handshake_timeout := 3000

signal message_received(peer_id: int, message: String)
signal client_connected(peer_id: int)
signal new_client(peer_id: int, role: String, team: int)
signal client_disconnected(peer_id: int)
signal action(role: String, team: int, action: String)

func log_message(message: String) -> void:
	var time := "[color=#aaaaaa] %s |[/color] " % Time.get_time_string_from_system()
	print(time + message + "\n")
	
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
		elif state == WebSocketPeer.STATE_CONNECTING:
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
	var socket: WebSocketPeer = peers[peer_id]
	if socket.get_available_packet_count() < 1:
		return "Not OK"
	var pkt: PackedByteArray = socket.get_packet()
	if socket.was_string_packet():
		var message = pkt.get_string_from_utf8()
		if message.begins_with("join|"):
			var client_role = message.right(len(message) - 5)
			emit_signal("new_client", client_role)
			print(client_role + "has joined!")
			clients[peer_id] = client_role
		else:
			var ship_instruction = JSON.new()
			if ship_instruction.parse(message) == OK:
				var instruction = ship_instruction.data
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
				log_message(clients[id] + " has disconnected")
				clients.erase(id)
			continue
		
		while p.get_available_packet_count():
			message_received.emit(id, get_message(id))
		
	for r: int in to_remove:
		peers.erase(r)
	to_remove.clear()
