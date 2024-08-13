class_name AgentAnimationManager extends AnimationPlayer

@export var agent : Agent
@export var sprite : Sprite2D

func _process(delta):
	if agent.direction.x < -0.1:
		sprite.flip_h = true
	elif agent.direction.x > 0.1:
		sprite.flip_h = false
	
	if agent.direction.x > 0.1 or agent.direction.x < -0.1:
		if agent.direction.y < -0.1:
			if abs(agent.velocity.length()) > 0.1:
				play("Run NE")
			else:
				play("Idle NE")
		elif agent.direction.y > 0.1:
			if abs(agent.velocity.length()) > 0.1:
				play("Run SE")
			else:
				play("Idle SE")
		else:
			if abs(agent.velocity.length()) > 0.1:
				play("Run E")
			else:
				play("Idle E")
	else:
		if agent.direction.y < -0.1:
			if abs(agent.velocity.length()) > 0.1:
				play("Run N")
			else:
				play("Idle N")
		elif agent.direction.y > 0.1:
			if abs(agent.velocity.length()) > 0.1:
				play("Run S")
			else:
				play("Idle S")
