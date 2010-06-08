package ;

#if cpp 
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import hxCLEye.CLEye;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import org.casalib.util.ColorUtil;

class Main extends Sprite {
	public var cameras:Array<CLEye>;
	public var cameraDisplays:Array<Bitmap>;
	public var camDimension: { width:Int, height:Int };
	
	public function new():Void {
		super();
		
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
	}
	
	private function init(evt:Event):Void {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		cameras = [];
		cameraDisplays = [];
		for (i in 0...CLEye.getCameraCount()) {
			var cam = new CLEye(CLEye.getCameraUUID(i), CLEYE_COLOR_RAW, CLEYE_QVGA, 120);
			cameras.push(cam);
			cam.start();
			
			camDimension = cam.getFrameDimensions();
			var bd = new BitmapData(camDimension.width, camDimension.height, false);
			var sp = new Bitmap(bd);
			sp.x = camDimension.width * Std.int(i/2);
			sp.y = camDimension.height * i % 2;
			addChild(sp);
			cameraDisplays.push(sp);
		}
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(evt:Event):Void {
		var camWidth = camDimension.width;
		var camHeight = camDimension.height;
		for (i in 0...cameras.length) {
			var cam = cameras[i];
			var bd = cameraDisplays[i].bitmapData;
			bd.lock();
			var b = cam.getFrame();
			for (y in 0...camHeight) {
				for (x in 0...camWidth) {
					var channelNum = cam.getNumOfChannel();
					if (channelNum == 1) {
						var val = b.get(x + y * camWidth);
						bd.setPixel(x, y, ColorUtil.getColor(val, val, val));
					} else if (channelNum == 4) {
						var pos = (x + y * camWidth) * 4;
						bd.setPixel(x, y, ColorUtil.getColor(b.get(pos + 2), b.get(pos + 1), b.get(pos)));
					}
				}
			}
			bd.unlock();
		}
	}
	
	static function main():Void {
		nme.Lib.create(function():Void { 
			nme.Lib.current.addChild(new Main());
		}, 800, 600, 30, 0xFFFFFF, nme.Lib.RESIZABLE, "CLEye Test");
	}
}