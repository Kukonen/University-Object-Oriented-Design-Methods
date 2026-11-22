"""Local HTTP stand for the three read operations of the SurfStudio course API."""

import argparse
import json
import math
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
PLACES = json.loads((ROOT / "assets/json/places.json").read_text(encoding="utf-8"))["places"]
BY_ID = {place["id"]: place for place in PLACES}


def distance_m(lat, lng, place):
    lat1, lat2 = math.radians(lat), math.radians(place["lat"])
    dlat = lat2 - lat1
    dlng = math.radians(place["lng"] - lng)
    chord = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    return 12_742_000 * math.asin(math.sqrt(min(1, chord)))


def filtered(params):
    if not isinstance(params, dict):
        raise ValueError("Expected a JSON object")
    name = params.get("nameFilter") or ""
    types = params.get("typeFilter")
    if not isinstance(name, str) or (
        types is not None and (not isinstance(types, list) or any(not isinstance(t, str) for t in types))
    ):
        raise ValueError("Invalid nameFilter or typeFilter")
    geo = [params.get(field) for field in ("lat", "lng", "radius")]
    use_geo = any(value is not None for value in geo)
    if use_geo:
        if any(type(value) not in (int, float) or not math.isfinite(value) for value in geo):
            raise ValueError("lat, lng and radius must be finite numbers")
        lat, lng, radius = geo
        if not (-90 <= lat <= 90 and -180 <= lng <= 180 and radius >= 0):
            raise ValueError("Invalid coordinates or radius")
    result = []
    for place in PLACES:
        if types is not None and place["placeType"] not in types:
            continue
        if name.casefold().strip() not in place["name"].casefold():
            continue
        if use_geo:
            distance = distance_m(lat, lng, place)
            if distance <= radius:
                result.append(dict(place, distance=round(distance, 2)))
        else:
            result.append(place)
    return result


class Handler(BaseHTTPRequestHandler):
    def respond(self, status, data):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlsplit(self.path).path.rstrip("/")
        if path == "/place":
            self.respond(HTTPStatus.OK, PLACES)
            return
        place_id = path.rsplit("/", maxsplit=1)[-1]
        if path.startswith("/place/") and place_id.isascii() and place_id.isdigit() and len(place_id) <= 9:
            place = BY_ID.get(int(place_id))
            if place is not None:
                self.respond(HTTPStatus.OK, place)
                return
        self.respond(HTTPStatus.NOT_FOUND, {"error": "Not found", "reasons": ["Unknown path or place"]})

    def do_POST(self):
        if urlsplit(self.path).path.rstrip("/") != "/filtered_places":
            self.respond(HTTPStatus.NOT_FOUND, {"error": "Not found", "reasons": ["Unknown path"]})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if not 0 < length <= 16_384:
                raise ValueError("Expected a JSON body of 1–16384 bytes")
            result = filtered(json.loads(self.rfile.read(length)))
        except (ValueError, UnicodeError) as exc:
            self.respond(HTTPStatus.BAD_REQUEST, {"error": "Invalid filter", "reasons": [str(exc)]})
            return
        self.respond(HTTPStatus.OK, result)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8888)
    options = parser.parse_args()
    with ThreadingHTTPServer(("127.0.0.1", options.port), Handler) as server:
        print(f"Course API on http://127.0.0.1:{server.server_port}", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass

