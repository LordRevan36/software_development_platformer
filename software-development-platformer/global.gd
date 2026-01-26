#SCRIPT TO STORE GLOBAL VARIABLES THAT CAN BE ACCESSED FROM ANYWHERE
#apparently good coding practice. first needed for accessing player variables from enemies
extends Node
var player_velocity: Vector2 = Vector2(0,0)
var player_position: Vector2 = Vector2(0,0)
var player_facing
var player_health
var player
