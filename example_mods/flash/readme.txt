Your .swf movies go here!

If you're editing the source code and want to play a flash movie, add this code:

case 'song-name':       /*MUSIC IS OPTIONAL*/       
	new SwfVideo('movie', 'assets/anywhere/music.ogg');

Otherwise, use this:

new SwfVideo('movie', new PlayState());