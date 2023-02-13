package core;

import haxe.Exception;
import haxe.ValueException;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.zip.Entry;
import haxe.zip.Reader;
import haxe.zip.Tools;
import haxe.zip.Uncompress;
import haxe.zip.Writer;
#if sys
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end

using StringTools;

/**
 * import ZipCore;
 * ZipUtils.uncompressZip(ZipUtils.openZip('theZip location'), 'destination');
 * 
 * import ZipCore;
 * var daCore = ZipCore.createZipFile("gjnsdghs.ycemod");
 * ZipCore.writeFolderToZip(e, "./mods/Friday Night Funkin'/", "Friday Night Funkin'/");
 * e.flush();
 * e.close();
 * 
 * @author YoshiCrafter
 */

class ZipCore
{
	#if sys
	public static var bannedNames:Array<String> = [".git"];

	/**
	 * [Description] Uncompresses `zip` into the `destFolder` folder
	 * @param zip 
	 * @param destFolder 
	 */
	public static function uncompressZip(zip:Reader, destFolder:String, ?prefix:String, ?prog:ZipProgress):ZipProgress
	{
		FileSystem.createDirectory(destFolder);

		var fields:List<Entry> = zip.read();

		try
		{
			if (prefix != null)
			{
				var f:List<Entry> = fields;
				fields = new List<Entry>();
				for (field in f)
					if (field.fileName.startsWith(prefix))
						fields.push(field);
			}

			if (prog == null)
				prog = new ZipProgress();

			prog.fileCount = fields.length;

			for (k => field in fields)
			{
				prog.curFile = k;
				if (field.fileName.endsWith("/") && field.fileSize == 0)
					FileSystem.createDirectory('${destFolder}/${field.fileName}');
				else
				{
					var split:Array<String> = [for (e in field.fileName.split("/")) e.trim()];
					split.pop();
					FileSystem.createDirectory('${destFolder}/${split.join("/")}');

					File.saveBytes('${destFolder}/${field.fileName}', unzip(field));
				}
			}

			prog.curFile = fields.length;
			prog.done = true;
		}
		catch (e)
		{
			prog.done = true;
			prog.error = e;
		}

		return prog;
	}

	#if !macro
	public static function uncompressZipAsync(zip:Reader, destFolder:String, ?prog:ZipProgress, ?prefix:String):ZipProgress
	{
		if (prog == null)
			prog = new ZipProgress();

		// threads are meant to fix lag btw
		#if (target.threaded)
		Thread.create(function()
		{
			uncompressZip(zip, destFolder, prefix, prog);
		});
		#else
		uncompressZip(zip, destFolder, prefix, prog);
		#end

		return prog;
	}
	#end

	/**
	 * [Description] Returns a `zip.Reader` instance from path.
	 * @param zipPath 
	 * @return Reader
	 */
	public static function openZip(zipPath:String):Reader
		return new ZipReader(File.read(zipPath));

	/**
	 * [Description] Logs every file within the zip.
	 * @param zip Zip reader
	 */
	public static function logZipFiles(zip:Reader)
	{
		for (field in zip.read())
			trace('${field.fileName} - Size: ${CoolUtil.getInterval(field.fileSize)} - Compressed: ${field.compressed} - Data Size: ${CoolUtil.getInterval(field.dataSize)}');
	}

	/**
	 * [Description] Copy of haxe's Zip unzip function cause lime replaced it.
	 * @param f Zip entry
	 */
	public static function unzip(f:Entry)
	{
		if (!f.compressed)
			return f.data;
		var c:Uncompress = new haxe.zip.Uncompress(-15);
		var s:Bytes = Bytes.alloc(f.fileSize);
		var r:Dynamic = c.execute(f.data, 0, s, 0);
		c.close();
		if (!r.done || r.read != f.data.length || r.write != f.fileSize)
			new ValueException("Invalid compressed data for " + f.fileName);
		f.compressed = false;
		f.dataSize = f.fileSize;
		f.data = s;
		return f.data;
	}

	/**
	 * [Description] Creates a ZIP file at the specified location and returns the Writer.
	 * @param path 
	 * @return Writer
	 */
	public static function createZipFile(path:String):ZipWriter
		return new ZipWriter(File.write(path));

	/**
		[Description] Writes the entirety of a folder to a zip file.
		@param zip ZIP file to write to
		@param path Folder path
		@param prefix (Additional) allows you to set a prefix in the zip itself.
	**/
	public static function writeFolderToZip(zip:ZipWriter, path:String, ?prefix:String, ?prog:ZipProgress, ?whitelist:Array<String>):ZipProgress
	{
		if (prefix == null)
			prefix = "";
		if (whitelist == null)
			whitelist = [];
		if (prog == null)
			prog = new ZipProgress();

		try
		{
			var curPath:Array<String> = ['$path'];
			var destPath:Array<String> = [];
			if (prefix != "")
			{
				prefix = prefix.replace("\\", "/");
				while (prefix.charAt(0) == "/")
					prefix = prefix.substr(1);
				while (prefix.charAt(prefix.length - 1) == "/")
					prefix = prefix.substr(0, prefix.length - 1);
				destPath.push(prefix);
			}

			var files:Array<StrNameLabel> = [];

			var doFolder:Void->Void = null;
			(doFolder = function()
			{
				var path = curPath.join("/");
				var zipPath = destPath.join("/");
				for (e in FileSystem.readDirectory(path))
				{
					if (bannedNames.contains(e.toLowerCase()) && !whitelist.contains(e.toLowerCase()))
						continue;
					if (FileSystem.isDirectory('$path/$e'))
					{
						for (p in [curPath, destPath])
							p.push(e);
						doFolder();
						for (p in [curPath, destPath])
							p.pop();
					}
					else
					{
						// is file, put it in the list
						var zipPath = '$zipPath/$e';
						while (zipPath.charAt(0) == "/")
							zipPath = zipPath.substr(1);
						files.push(new StrNameLabel('$path/$e', zipPath));
					}
				}
			})();

			prog.fileCount = files.length;
			for (k => file in files)
			{
				prog.curFile = k;

				var fileContent:Bytes = File.getBytes(file.name);
				var fileInfo = FileSystem.stat(file.name);
				var entry:Entry = {
					fileName: file.label,
					fileSize: fileInfo.size,
					fileTime: Date.now(),
					dataSize: 0,
					data: fileContent,
					crc32: Crc32.make(fileContent), // TODO???
					compressed: false
				};
				Tools.compress(entry, 1);
				zip.writeFile(entry);
			}
			zip.writeCDR();
		}
		catch (e:Exception)
			prog.error = e;

		prog.done = true;
		return prog;
	}

	public static function writeFolderToZipAsync(zip:ZipWriter, path:String, ?prefix:String):ZipProgress
	{
		var zipProg = new ZipProgress();
		#if (target.threaded)
		Thread.create(function()
		{
			writeFolderToZip(zip, path, prefix, zipProg);
		});
		#else
		writeFolderToZip(zip, path, prefix, zipProg);
		#end
		return zipProg;
	}

	/**
	 * [Description] Converts an `Array<Entry>` to a `List<Entry>`.
	 * @param array 
	 * @return List<Entry>
	 */
	public static function arrayToList(array:Array<Entry>):List<Entry>
	{
		var list = new List<Entry>();
		for (e in array)
			list.push(e);
		return list;
	}
	#end
}

class ZipProgress
{
	public var error:Exception = null;
	public var curFile:Int = 0;
	public var fileCount:Int = 0;
	public var done:Bool = false;
	public var percentage(get, null):Float;

	public function new() {}

	private function get_percentage()
		return fileCount <= 0 ? 0 : curFile / fileCount;
}

class ZipReader extends Reader
{
	public var files:List<Entry>;

	public override function read()
	{
		if (this.files != null)
			return this.files;

		try
		{
			return this.files = super.read();
		}

		return new List<Entry>();
	}
}

class ZipWriter extends Writer
{
	public function flush()
		o.flush();

	public function writeFile(entry:Entry)
	{
		writeEntryHeader(entry);
		o.writeFullBytes(entry.data, 0, entry.data.length);
	}

	public function close()
		o.close();
}

class StrNameLabel
{
	public var name:String;
	public var label:String;

	public function new(name:String, label:String)
	{
		this.name = name;
		this.label = label;
	}
}