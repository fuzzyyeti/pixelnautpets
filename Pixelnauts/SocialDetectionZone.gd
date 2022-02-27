extends Area2D

var friend = null

func can_see_friend():
	return friend != null
	

func _on_SocialDetectionZone_body_entered(body):
	if body.is_playable: 
		print('hit')
		friend = body


func _on_SocialDetectionZone_body_exited(body):
	if body.is_playable: friend = null
