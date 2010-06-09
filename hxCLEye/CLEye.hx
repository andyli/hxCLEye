package hxCLEye;

#if cpp 
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import haxe.io.Bytes;
import haxe.io.BytesData;

enum CLEyeCameraColorMode {
	CLEYE_MONO_PROCESSED;
	CLEYE_COLOR_PROCESSED;
	CLEYE_MONO_RAW;
	CLEYE_COLOR_RAW;
	CLEYE_BAYER_RAW;
}

enum CLEyeCameraResolution { 
	CLEYE_QVGA;
	CLEYE_VGA;
}

// camera parameters
enum CLEyeCameraParameter{
	// camera sensor parameters
	CLEYE_AUTO_GAIN;			// [false, true]
	CLEYE_GAIN;					// [0, 79]
	CLEYE_AUTO_EXPOSURE;		// [false, true]
	CLEYE_EXPOSURE;				// [0, 511]
	CLEYE_AUTO_WHITEBALANCE;	// [false, true]
	CLEYE_WHITEBALANCE_RED;		// [0, 255]
	CLEYE_WHITEBALANCE_GREEN;	// [0, 255]
	CLEYE_WHITEBALANCE_BLUE;	// [0, 255]
	// camera linear transform parameters (valid for CLEYE_MONO_PROCESSED, CLEYE_COLOR_PROCESSED modes)
	CLEYE_HFLIP;				// [false, true]
	CLEYE_VFLIP;				// [false, true]
	CLEYE_HKEYSTONE;			// [-500, 500]
	CLEYE_VKEYSTONE;			// [-500, 500]
	CLEYE_XOFFSET;				// [-500, 500]
	CLEYE_YOFFSET;				// [-500, 500]
	CLEYE_ROTATION;				// [-500, 500]
	CLEYE_ZOOM;					// [-500, 500]
	// camera non-linear transform parameters (valid for CLEYE_MONO_PROCESSED, CLEYE_COLOR_PROCESSED modes)
	CLEYE_LENSCORRECTION1;		// [-500, 500]
	CLEYE_LENSCORRECTION2;		// [-500, 500]
	CLEYE_LENSCORRECTION3;		// [-500, 500]
	CLEYE_LENSBRIGHTNESS;		// [-500, 500]
}

class CLEye 
{	
	public function new(uuid:String, ?mode:CLEyeCameraColorMode, ?res:CLEyeCameraResolution, ?frameRate:Float = 30) {
		this.uuid = uuid;
		colorMode = mode == null ? CLEYE_COLOR_RAW : mode;
		handle = _CLEyeCreateCamera(uuid, CLEyeCameraColorModeToInt(colorMode), CLEyeCameraResolutionToInt(res == null? CLEYE_QVGA : res), frameRate);
		
		var area = getFrameDimensions();
		buffer = Bytes.alloc(area.width * area.height * getNumOfChannel()).getData();
	}
	
	public function destroy():Bool {
		return _CLEyeDestroyCamera(handle);
	}
	
	public function start():Bool {
		return _CLEyeCameraStart(handle);
	}
	
	public function stop():Bool {
		return _CLEyeCameraStop(handle);
	}
	
	public function setLED(val:Bool):Bool {
		return _CLEyeCameraLED(handle, val);
	}
	
	public function setParameter(parm:CLEyeCameraParameter, val:Int):Bool {
		return _CLEyeSetCameraParameter(handle, CLEyeCameraParameterToInt(parm), val);
	}
	
	public function getParameter(parm:CLEyeCameraParameter, val:Int):Int {
		return _CLEyeGetCameraParameter(handle, CLEyeCameraParameterToInt(parm));
	}
	
	public function getFrameDimensions(): { width:Int, height:Int } {
		var ret = { width:0, height:0 };
		_CLEyeCameraGetFrameDimensions(handle, ret);
		return ret;
	}
	
	public function getFrame(waitTimeout:Int = 2000):BytesData {
		_CLEyeCameraGetFrame(handle, buffer, waitTimeout);
		return buffer;
	}
	
	public function getNumOfChannel():Int {
		return (colorMode == CLEYE_MONO_RAW || colorMode == CLEYE_MONO_PROCESSED) ? 1 : 4;
	}
	
	static public function getCameraCount():Int {
		return _CLEyeGetCameraCount();
	}
	
	static public function getCameraUUID(index:Int):String {
		return _CLEyeGetCameraUUID(index);
	}
	
	
	public var handle(default, null):Dynamic;
	public var buffer:BytesData;
	public var uuid(default, null):String;
	public var colorMode(default, null):CLEyeCameraColorMode;
	
	static var _CLEyeGetCameraCount = Lib.load("CLEye", "_CLEyeGetCameraCount", 0);
	static var _CLEyeGetCameraUUID = Lib.load("CLEye", "_CLEyeGetCameraUUID", 1);
	static var _CLEyeCreateCamera = Lib.load("CLEye", "_CLEyeCreateCamera", 4);
	static var _CLEyeDestroyCamera = Lib.load("CLEye", "_CLEyeDestroyCamera", 1);
	static var _CLEyeCameraStart = Lib.load("CLEye", "_CLEyeCameraStart", 1);
	static var _CLEyeCameraStop = Lib.load("CLEye", "_CLEyeCameraStop", 1);
	static var _CLEyeCameraLED = Lib.load("CLEye", "_CLEyeCameraLED", 2);
	static var _CLEyeSetCameraParameter = Lib.load("CLEye", "_CLEyeSetCameraParameter", 3);
	static var _CLEyeGetCameraParameter = Lib.load("CLEye", "_CLEyeGetCameraParameter", 2);
	static var _CLEyeCameraGetFrameDimensions = Lib.load("CLEye", "_CLEyeCameraGetFrameDimensions", 2);
	static var _CLEyeCameraGetFrame = Lib.load("CLEye", "_CLEyeCameraGetFrame", 3);
	
	static function CLEyeCameraColorModeToInt(val:CLEyeCameraColorMode):Int {
		return switch(val) {
			case CLEYE_MONO_PROCESSED: 0;
			case CLEYE_COLOR_PROCESSED: 1;
			case CLEYE_MONO_RAW: 2;
			case CLEYE_COLOR_RAW: 3;
			case CLEYE_BAYER_RAW: 4;
		};
	}
	
	static function CLEyeCameraResolutionToInt(val:CLEyeCameraResolution):Int {
		return switch(val) {
			case CLEYE_QVGA: 0;
			case CLEYE_VGA: 1;
		};
	}
	
	static function CLEyeCameraParameterToInt(val:CLEyeCameraParameter):Int {
		return switch(val) {
			// camera sensor parameters
			case CLEYE_AUTO_GAIN: 0;			// [false, true]
			case CLEYE_GAIN: 1;					// [0, 79]
			case CLEYE_AUTO_EXPOSURE: 2;		// [false, true]
			case CLEYE_EXPOSURE: 3;				// [0, 511]
			case CLEYE_AUTO_WHITEBALANCE: 4;	// [false, true]
			case CLEYE_WHITEBALANCE_RED: 5;		// [0, 255]
			case CLEYE_WHITEBALANCE_GREEN: 6;	// [0, 255]
			case CLEYE_WHITEBALANCE_BLUE: 7;	// [0, 255]
			// camera linear transform parameters (valid for CLEYE_MONO_PROCESSED, CLEYE_COLOR_PROCESSED modes)
			case CLEYE_HFLIP: 8;				// [false, true]
			case CLEYE_VFLIP: 9;				// [false, true]
			case CLEYE_HKEYSTONE: 10;			// [-500, 500]
			case CLEYE_VKEYSTONE: 11;			// [-500, 500]
			case CLEYE_XOFFSET: 12;				// [-500, 500]
			case CLEYE_YOFFSET: 13;				// [-500, 500]
			case CLEYE_ROTATION: 14;			// [-500, 500]
			case CLEYE_ZOOM: 15;				// [-500, 500]
			// camera non-linear transform parameters (valid for CLEYE_MONO_PROCESSED, CLEYE_COLOR_PROCESSED modes)
			case CLEYE_LENSCORRECTION1: 16;		// [-500, 500]
			case CLEYE_LENSCORRECTION2: 17;		// [-500, 500]
			case CLEYE_LENSCORRECTION3: 18;		// [-500, 500]
			case CLEYE_LENSBRIGHTNESS: 19;		// [-500, 500]
		};
	}
}