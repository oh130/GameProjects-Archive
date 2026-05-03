extends Node

const FIREBASE_API_KEY := "AIzaSyBwHlufSVaZOJ2XMdWUFMKyrxOnVBDN8SU"
const FIRESTORE_PROJECT_ID := "gamedb-a8ef4" # Firebase 콘솔에서 확인한 프로젝트 ID
const FIRESTORE_BASE_URL := "https://firestore.googleapis.com/v1/projects/" + FIRESTORE_PROJECT_ID + "/databases/(default)/documents/"

var http_request := HTTPRequest.new()

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(http_request_completed)

# save data -> dictionary.
func refine_data_to_dict():
	var data :=\
	{
		"players" : 
		[
			{
				"id" : "hero",
				"items" :
				[
					"item0",
					"item1"
				]
			},
			{
				"id" : "witch",
			}
		],
		"cleared_chapters" :
		[
			"forest",
			"costsea"
		]
	}
	
	var json_data := JSON.stringify(data)

# dictionary -> firestore value dict.
func _to_firestore_value(value : Variant) -> Dictionary:
	match typeof(value):
		TYPE_STRING:
			return {"stringValue": value}
		TYPE_INT:
			return {"integerValue": str(value)}
		TYPE_FLOAT:
			return {"doubleValue": str(value)}
		TYPE_BOOL:
			return {"booleanValue": value}
		TYPE_ARRAY:
			var array_values := []
			for item in value:
				# 배열 내부의 각 항목에 대해 재귀 호출
				var converted_item := _to_firestore_value(item)
				if converted_item.is_empty(): # 변환할 수 없는 타입은 건너뛰기
					printerr("Warning: Could not convert array item: ", item)
					continue
				array_values.append(converted_item)
			return {"arrayValue": {"values": array_values}}
		TYPE_DICTIONARY:
			var map_fields := {}
			for key in value.keys():
				# 딕셔너리 내부의 각 값에 대해 재귀 호출
				var converted_val := _to_firestore_value(value[key])
				if converted_val.is_empty(): # 변환할 수 없는 타입은 건너뛰기
					printerr("Warning: Could not convert dictionary value for key '", key, "': ", value[key])
					continue
				map_fields[key] = converted_val
			return {"mapValue": {"fields": map_fields}}
		TYPE_NIL:
			return {"nullValue": null}
		_:
			# 지원하지 않는 타입
			printerr("Error: Unsupported data type for Firestore conversion: ", typeof(value), " value: ", value)
			return {} # 빈 딕셔너리를 반환하여 변환 실패를 알림

func create_firestore_request_body(data_to_send: Dictionary) -> String:
	var firestore_formatted_fields := {}
	for key in data_to_send.keys():
		var converted_value := _to_firestore_value(data_to_send[key])
		if converted_value.is_empty():
			printerr("Warning: Skipping top-level key '", key, "' due to unsupported type.")
			continue
		firestore_formatted_fields[key] = converted_value

	var request_body_dict := {"fields": firestore_formatted_fields}
	return JSON.stringify(request_body_dict)

# 데이터를 Firestore에 전송하는 함수
func send_telemetry_data(collection_id: String, document_id: String, data_to_send: Dictionary):
	var url := FIRESTORE_BASE_URL + collection_id + "/" + document_id + "?key=" + FIREBASE_API_KEY
	print("Firestore URL: ", url)

	# dictionary data -> firestore body.
	var firestore_formatted_fields := {}
	for key in data_to_send.keys():
		var converted_value := _to_firestore_value(data_to_send[key])
		if converted_value.is_empty():
			printerr("Warning: Skipping top-level key '", key, "' due to unsupported type.")
			continue
		firestore_formatted_fields[key] = converted_value

	var request_body_dict := {"fields": firestore_formatted_fields}
	
	# http request.
	var body := JSON.stringify(request_body_dict)
	print("Sending data to Firestore: ", body) 
	var headers := ["Content-Type: application/json"]
	var error := http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		printerr("HttpRequest request error: ", error)
		return

func http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("Firestore Response Code: ", response_code)
	if body.size() > 0:
		var response_json : Variant = JSON.parse_string(body.get_string_from_utf8())
		print("Firestore Response Body: ", response_json)
		if response_code >= 200 and response_code < 300:
			print("Telemetry data sent successfully!")
		else:
			printerr("Failed to send telemetry data. Response: ", response_json)
	else:
		print("No response body received.")
