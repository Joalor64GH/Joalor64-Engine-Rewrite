Your .swf movies go here!

If you're editing the source code and want to play a flash movie, add this code:

case 'song-name':
	camFollow.x = x;
	camFollow.y = y;       /*MUSIC IS OPTIONAL*/       
	new SwfVideo('movie', 'assets/music/music.ogg');

Otherwise, use this:

new SwfVideo('movie', new PlayState());