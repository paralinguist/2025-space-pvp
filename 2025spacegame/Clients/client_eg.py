import space_api
import time

ip = "127.0.0.1"
port = 9876
role = "weapons"
team = "tech"

space_api.connect(role, team, ip, port)

message = ""

while message != "quit":
    message = input('> ')
    if message == "print":
      print(f"My ID: {space_api.connection_id}")
      print(space_api.message_stack)
    elif message == "left":
        space_api.move("left")
    elif message == "right":
        space_api.move("right")
    elif message.split(" ")[0] in ["shoot", "power"]:
        message_list = message.split(" ")
        target_id = int(message_list[1])
        match message_list[0]:
            case "shoot":
                space_api.shoot(weapon_id)
    else:
        print("Not an option.")
    time.sleep(0.1)
    for response_number in range(len(space_api.message_stack)):
        response = space_api.message_stack.pop()
        #You can iterate over the environment list and look for objects of a type relevant to your character
        if response["type"] == "environment":
            for item in response["response"]:
                if item['type'] != 'none':
                    print(item)
        elif response["type"] == "safe":
            print(response["data"])
        elif response["type"] == "begin_action":
            print(response["data"])
        elif response["type"] == "earpiece_info":
            print(response["data"])

space_api.disconnect()
