package backend;

import haxe.Json;
import sys.FileSystem;
import tjson.TJSON;
import sys.File;
import openfl.Assets;

class Mods {
    static public var currentModDirectory:String = '';

    public static function getPack(?folder:String = null)
    {
        #if MODS_ALLOWED
        if(folder == null) folder = Mods.currentModDirectory;

        var path = Paths.mods(folder + '/pack.json');
        if(FileSystem.exists(path)) {
            try {
                #if sys
                var rawJson:String = File.getContent(path);
                #else
                var rawJson:String = Assets.getText(path);
                #end
                if(rawJson != null && rawJson.length > 0) return tjson.TJSON.parse(rawJson);
            } catch(e:Dynamic) {
                trace(e);
            }
        }
        #end
        return null;
    }
}
