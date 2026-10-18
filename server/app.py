"""Small real HTTP server for the training app. Not production-grade auth."""
import argparse
import json
import time
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from crypto_helpers import sign_grant

HERE = Path(__file__).resolve().parent
ACCOUNTS_FILE = HERE / 'accounts.json'


def make_grant(account_id, nonce, current_time=None):
    accounts = json.loads(ACCOUNTS_FILE.read_text(encoding='utf-8'))
    if account_id not in accounts:
        raise KeyError(account_id)
    account = accounts[account_id]
    now = int(time.time()) if current_time is None else int(current_time)
    return {
        'accountID': account_id,
        'tier': account['tier'],
        'state': account['state'],
        'issuedAt': now,
        'expiresAt': int(account['expires_at']),
        'leaseUntil': now + 900,
        'revision': int(account['revision']),
        'features': account['features'],
        'nonce': nonce,
    }


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, data):
        raw = json.dumps(data, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Content-Length', str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        url = urllib.parse.urlsplit(self.path)
        if url.path == '/health':
            return self.send_json(200, {'ok': True, 'service': 'AtlasLabX-demo'})
        if url.path != '/v1/grant':
            return self.send_json(404, {'error': 'unknown endpoint'})
        params = urllib.parse.parse_qs(url.query)
        account_id = params.get('account_id', [''])[0]
        nonce = params.get('nonce', [''])[0]
        if not nonce or len(nonce) > 128 or len(account_id) > 32:
            return self.send_json(400, {'error': 'invalid account or nonce'})
        try:
            grant = make_grant(account_id, nonce)
        except KeyError:
            return self.send_json(404, {'error': 'unknown profile'})
        return self.send_json(200, {'envelope': sign_grant(grant)})


def main():
    parser = argparse.ArgumentParser(description='Training entitlements server')
    parser.add_argument('--host', default='127.0.0.1', help='For iPhone on LAN, set 0.0.0.0')
    parser.add_argument('--port', type=int, default=8765)
    args = parser.parse_args()
    httpd = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f'Atlas demo server: http://{args.host}:{args.port}/health')
    print('For educational use only. Avoid public exposure and real credentials.')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()


if __name__ == '__main__':
    main()
