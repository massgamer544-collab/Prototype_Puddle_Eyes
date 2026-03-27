#include <WiFi.h>
#include <WebServer.h>

const char* wifiSsid = "Amanana";
const char* wifiPassword = "183Lavoie";

WebServer server(80);

// Left sensor
constexpr int TRIG_LEFT = 5;
constexpr int ECHO_LEFT = 18;

// Right sensor
constexpr int TRIG_RIGHT = 17;
constexpr int ECHO_RIGHT = 19;

float readDistanceMeters(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(3);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  unsigned long duration = pulseIn(echoPin, HIGH, 35000UL);
  if (duration == 0) return -1.0f;

  float distanceCm = duration * 0.0343f / 2.0f;
  return distanceCm / 100.0f;
}

float readMedianDistanceMeters(int trigPin, int echoPin, int samples = 7) {
  float values[15];
  if (samples > 15) samples = 15;

  int valid = 0;

  for (int i = 0; i < samples; i++) {
    float d = readDistanceMeters(trigPin, echoPin);
    if (d > 0.0f) {
      values[valid++] = d;
    }
    delay(40);
  }

  if (valid == 0) return -1.0f;

  for (int i = 0; i < valid - 1; i++) {
    for (int j = i + 1; j < valid; j++) {
      if (values[j] < values[i]) {
        float tmp = values[i];
        values[i] = values[j];
        values[j] = tmp;
      }
    }
  }

  if (valid % 2 == 1) {
    return values[valid / 2];
  } else {
    return (values[(valid / 2) - 1] + values[valid / 2]) / 2.0f;
  }
}

float distanceToDepth(float distanceM, float referenceGroundM = 0.35f) {
  if (distanceM <= 0.0f) return 0.0f;

  float depth = distanceM - referenceGroundM;
  if (depth < 0.0f) depth = 0.0f;
  if (depth > 1.5f) depth = 1.5f;

  return depth;
}

void handleRaw() {
  float leftM = readMedianDistanceMeters(TRIG_LEFT, ECHO_LEFT, 7);
  float rightM = readMedianDistanceMeters(TRIG_RIGHT, ECHO_RIGHT, 7);

  String json = "{";
  json += "\"left_distance_m\":";
  json += String(leftM, 3);
  json += ",";
  json += "\"right_distance_m\":";
  json += String(rightM, 3);
  json += ",";
  json += "\"left_depth_m\":";
  json += String(distanceToDepth(leftM), 3);
  json += ",";
  json += "\"right_depth_m\":";
  json += String(distanceToDepth(rightM), 3);
  json += "}";

  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

void handleScan() {
  float leftM = readMedianDistanceMeters(TRIG_LEFT, ECHO_LEFT, 7);
  float rightM = readMedianDistanceMeters(TRIG_RIGHT, ECHO_RIGHT, 7);

  float leftDepth = distanceToDepth(leftM);
  float rightDepth = distanceToDepth(rightM);

  // centre reconstruit
  float centerDepth = (leftDepth + rightDepth) / 2.0f;

  // Accentuation légère si asymétrie
  float delta = fabs(leftDepth - rightDepth);
  if (delta > 0.10f) {
    centerDepth += delta * 0.15f;
  }

  String json = "[";

  json += "{";
  json += "\"x\":-0.70,";
  json += "\"y\":1.0,";
  json += "\"z\":";
  json += String(leftDepth, 3);
  json += "},";

  json += "{";
  json += "\"x\":0.00,";
  json += "\"y\":1.0,";
  json += "\"z\":";
  json += String(centerDepth, 3);
  json += "},";

  json += "{";
  json += "\"x\":0.70,";
  json += "\"y\":1.0,";
  json += "\"z\":";
  json += String(rightDepth, 3);
  json += "}";

  json += "]";

  Serial.println(json);

  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

void setup() {
  Serial.begin(115200);

  pinMode(TRIG_LEFT, OUTPUT);
  pinMode(ECHO_LEFT, INPUT);

  pinMode(TRIG_RIGHT, OUTPUT);
  pinMode(ECHO_RIGHT, INPUT);

  WiFi.mode(WIFI_STA);
  WiFi.begin(wifiSsid, wifiPassword);

  Serial.println();
  Serial.print("Connecting to WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.println("Connected to WiFi");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  server.on("/scan", HTTP_GET, handleScan);
  server.on("/raw", HTTP_GET, handleRaw);
  server.begin();
}

void loop() {
  server.handleClient();
}