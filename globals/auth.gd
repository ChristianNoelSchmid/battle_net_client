extends Node

var REFRESH_TOKEN_FILE_PATH = "user://_refresh_token.txt"

# The access token belonging to the logged-in user.
# used to access all features in the game.
var access_token: String = ""

# Refresh token for refreshing the access token.
var _refresh_token: String = ""
# The unix timestamp at which the access token expires.
var _access_token_expir_unix_s: int = 0

var _login_request: HTTPRequest
var _refresh_request: HTTPRequest
var _cookie_regex: RegEx

# Emitted after a log-in is attempted
signal on_auth_success()
signal on_login_failure()			

func _ready():	
	_login_request = HTTPRequest.new()
	_login_request.request_completed.connect(_on_login_response)
	add_child(_login_request)

	_refresh_request = HTTPRequest.new()
	_refresh_request.request_completed.connect(_on_refresh_response)
	add_child(_refresh_request)	

	_cookie_regex = RegEx.new()
	_cookie_regex.compile("set-cookie:.*refresh-token=([^;]+);.*")

	# Try an immediate refresh
	_try_refresh()

func try_login(username: String, password: String):
	var body = { "email": username, "pwd": password }
	_login_request.request(
		"%s/auth/login" % Config.URL_ROOT,
		["Content-Type: application/json"], 
		HTTPClient.METHOD_POST, 
		JSON.stringify(body)
	)

func logout():
	access_token = ""
	_refresh_token = ""
	DirAccess.remove_absolute(ProjectSettings.globalize_path(REFRESH_TOKEN_FILE_PATH))

func _try_refresh():
	# If the refresh token cache doesn't exist, return
	if not FileAccess.file_exists(REFRESH_TOKEN_FILE_PATH):
		return

	# Attempt to open the file, read the token, and push up to 
	var file = FileAccess.open(REFRESH_TOKEN_FILE_PATH, FileAccess.READ)
	var refresh_token = file.get_as_text()

	_refresh_request.request(
		"%s/auth/refresh" % Config.URL_ROOT, 
		["Cookie: refresh-token=%s" % refresh_token],
		HTTPClient.METHOD_PUT
	)

func _on_login_response(_result, _response_code, _headers, _body):
	# If not OK, signal the failure and return
	if _response_code != 200:
		on_login_failure.emit(_body.get_string_from_utf8())	
		return

	_extract_tokens(_body.get_string_from_utf8(), _headers)
	on_auth_success.emit()

func _on_refresh_response(_result, _response_code, _headers, _body):
	# If not OK, delete the refresh token cache and return
	if _response_code != 200:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(REFRESH_TOKEN_FILE_PATH))
		return

	_extract_tokens(_body.get_string_from_utf8(), _headers)
	on_auth_success.emit()
	
func _extract_tokens(body: String, headers: PackedStringArray):
	access_token = body.replace("\"", "")
	_refresh_token = _extract_refresh_token(headers)

	# Save the refresh token
	var file = FileAccess.open(REFRESH_TOKEN_FILE_PATH, FileAccess.WRITE)
	file.store_string(_refresh_token)

	# Extract the time to expiration from the access token
	var jwt_body = access_token.split(".")[1]
	var decoded = Marshalls.base64_to_utf8(jwt_body)
	var json_body = JSON.parse_string(decoded)
	_access_token_expir_unix_s = Time.get_unix_time_from_datetime_string(json_body["expires"])

	print("Access Token: %s" % access_token)
	print("Refresh Token: %s" % _refresh_token)
	print("Access Token expiration: %d" % _access_token_expir_unix_s)
	
func _extract_refresh_token(headers):
	for header in headers:
		var cookie_search = _cookie_regex.search(header)
		if cookie_search:
			return cookie_search.get_string(1)
