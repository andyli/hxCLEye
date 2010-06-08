#define IMPLEMENT_API
#include <hx/CFFI.h>

#include <CLEyeMulticam.h>

#include <Rpc.h>

DEFINE_KIND(CameraInstance);

value _CLEyeGetCameraCount() {
	return alloc_int(CLEyeGetCameraCount());
}
DEFINE_PRIM(_CLEyeGetCameraCount,0);

value _CLEyeGetCameraUUID(value a) {
	GUID guid = CLEyeGetCameraUUID(val_int(a));
	char ret[40];
	sprintf_s(	ret, 40, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
				guid.Data1, guid.Data2, guid.Data3,
				guid.Data4[0], guid.Data4[1], guid.Data4[2],
				guid.Data4[3], guid.Data4[4], guid.Data4[5],
				guid.Data4[6], guid.Data4[7]);
	return alloc_string_len(ret,40);
}
DEFINE_PRIM(_CLEyeGetCameraUUID,1);

void delete_camera(value a) {
	CLEyeCameraInstance cam = (CLEyeCameraInstance) val_data(a);
	CLEyeDestroyCamera(cam);
}

value _CLEyeCreateCamera(value a, value b, value c, value d) {
	GUID guid;
	UuidFromString((RPC_CSTR)val_string(a),&guid);
	
	CLEyeCameraColorMode mode = (CLEyeCameraColorMode) val_int(b);
	CLEyeCameraResolution res = (CLEyeCameraResolution) val_int(c);
	float frameRate = val_float(d);
	
	CLEyeCameraInstance cam = CLEyeCreateCamera(guid, mode, res, frameRate);
	value ret = alloc_abstract(CameraInstance,cam);
	val_gc(ret,delete_camera);
	return ret;
}
DEFINE_PRIM(_CLEyeCreateCamera,4);

value _CLEyeDestroyCamera(value a) {
	return alloc_bool(CLEyeDestroyCamera((CLEyeCameraInstance) val_data(a)));
}
DEFINE_PRIM(_CLEyeDestroyCamera,1);

value _CLEyeCameraStart(value a) {
	return alloc_bool(CLEyeCameraStart((CLEyeCameraInstance) val_data(a)));
}
DEFINE_PRIM(_CLEyeCameraStart,1);

value _CLEyeCameraStop(value a) {
	return alloc_bool(CLEyeCameraStop((CLEyeCameraInstance) val_data(a)));
}
DEFINE_PRIM(_CLEyeCameraStop,1);

value _CLEyeCameraLED(value a, value b) {
	return alloc_bool(CLEyeCameraLED((CLEyeCameraInstance) val_data(a), val_bool(b)));
}
DEFINE_PRIM(_CLEyeCameraLED,2);

value _CLEyeSetCameraParameter(value a, value b, value c) {
	return alloc_bool(CLEyeSetCameraParameter((CLEyeCameraInstance) val_data(a), (CLEyeCameraParameter) val_int(b), val_int(c)));
}
DEFINE_PRIM(_CLEyeSetCameraParameter,3);

value _CLEyeGetCameraParameter(value a, value b) {
	return alloc_int(CLEyeGetCameraParameter((CLEyeCameraInstance) val_data(a), (CLEyeCameraParameter) val_int(b)));
}
DEFINE_PRIM(_CLEyeGetCameraParameter,2);

value _CLEyeCameraGetFrameDimensions(value a, value b) {
	int w,h;
	value ret = alloc_bool(CLEyeCameraGetFrameDimensions((CLEyeCameraInstance) val_data(a), w, h));
	alloc_field(b, val_id("width"), alloc_int(w));
	alloc_field(b, val_id("height"), alloc_int(h));
	return ret;
}
DEFINE_PRIM(_CLEyeCameraGetFrameDimensions,2);

value _CLEyeCameraGetFrame(value a, value b, value c) {
	return alloc_bool(CLEyeCameraGetFrame((CLEyeCameraInstance) val_data(a), (unsigned char*) buffer_data(val_to_buffer(b)), val_int(c)));
}
DEFINE_PRIM(_CLEyeCameraGetFrame,3);