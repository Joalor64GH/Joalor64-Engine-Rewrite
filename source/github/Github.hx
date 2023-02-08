package github;

import haxe.Http;
import haxe.Json;
import haxe.Exception;
import flixel.FlxSprite;
import openfl.display.BitmapData;

/**
 * A class for getting information from Github repositories and such.
 * @see http://api.github.com/
 * also @see https://github.com/YoshiCrafter29/CodenameEngine
 */
class Github {
    // final api_url:String = 'https://api.github.com/repos/';
    // final raw_url:String = 'https://raw.githubusercontent.com/';

    public function getGithubRepositoryAPI(user:String, repo:String, ?onError:Exception->Void):Array<Dynamic>{
        try {
            var url = 'https://api.github.com/repos/${user}/${repo}';

            var data = Json.parse(sendRequestOnGitHubServers(url));
            if(!data is Array){
                throw '[Github Exception]: $data';
            }

            return data;
        }
        catch(e){
            if (onError != null) onError(e);
        }
        return [];
    }

    inline public static function sendRequestOnGitHubServers(url:String) {
        var h = new Http(url);
        h.setHeader("User-Agent", "request");
		var r = null;
		h.onData = function(d) {
			r = d;
		}
		h.onError = function(e) {
			throw e;
		}
		h.request(false);
		return r;
    }

    inline public function getGithubRepository(user:String, repo:String, branch:String):String {
        var http = new Http('https://raw.githubusercontent.com/${user}/${repo}/$branch');

        var poop = null;

        http.onData = function(d) {
            poop = d;
        }    

        http.onError = function(e) {
            trace('Error: $e');
        }
        http.request();

        return poop;
    }

    inline public function getGithubAvatar(user:String):FlxSprite{
        var http = new Http('https://avatars.githubusercontent.com/$user');

        var sprite = new FlxSprite();
        http.onBytes = function(e){
            var b:BitmapData = BitmapData.fromBytes(e);
            sprite.pixels = b;
        }

        http.onError = function(e) {
            trace('Error: $e');
        }
        http.request();

        return sprite;
    }

    inline public function getGithubIdenticon(user:String):FlxSprite{
        var http = new Http('https://github.com/identicons/$user');

        var sprite = new FlxSprite();
        http.onBytes = function(e){
            var b:BitmapData = BitmapData.fromBytes(e);
            sprite.pixels = b;
        }

        http.onError = function(e){
            trace('Error: $e');
        }
        http.request();

        return sprite;
    }
}