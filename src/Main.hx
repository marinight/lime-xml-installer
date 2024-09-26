import sys.FileSystem;
import sys.Http;
import sys.io.File;

class Main {
	static function main() {
		var args = Sys.args();
		var XML:Xml;	
		if (FileSystem.exists(args[0]))
		XML = Xml.parse(File.getContent(args[0]));
		else {
			trace("Could not find file " + args[0]);
			return;
		}

		var haxelibs = XML.firstElement().elementsNamed("haxelib");

		var count:Int = 1;
		var length:Int = [for (i in haxelibs) i].length;
		for (h in haxelibs) {
			var name = h.get("name");
			var gitLink = h.get("git");
			
			trace("Installing " + name + '[Library $count/$length]');

			if (gitLink == null) {
				
				var httpReq = new Http("https://lib.haxe.org/p/" + name + "/");

				httpReq.onStatus = function(code:Int) {
					if (code >= 200 && code < 300) {
						Sys.command("haxelib", ['install', name]);
					} else {
						trace("Failed to install " + name + " (HTTP Code: " + code + ")");
					}
				}

				httpReq.onError = function(msg) {
					trace("Failed to install " + name + " (Error message: " + msg + ")");
				}

				httpReq.request();
			} else {
				var httpReq = new Http(gitLink);
				httpReq.onStatus = function(code:Int) {
					if (code >= 200 && code < 300) {
						Sys.command("haxelib", ['git', gitLink]);
					} else {
						trace("Failed to install " + name + " from " + gitLink + " (HTTP Code: " + code + ")");		
					}
				}

				httpReq.onError = function(msg) {
					trace("Failed to install " + name + " from " + gitLink + " (Error message: " + msg + ")");
				}
				
				httpReq.request();
			}

			count++;
		}
	}
}
