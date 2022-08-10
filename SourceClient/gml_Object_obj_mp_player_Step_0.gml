if (!isSpectator) {
	visible = (room == room_id)
} else {
	visible = false
}

if (floor(inputxy) != 0)
{
	lookdir = floor(inputxy)
}