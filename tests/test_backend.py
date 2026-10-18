import base64
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'server'))
from app import make_grant
from crypto_helpers import sign_grant, verify_grant, public_key_b64

class BackendTest(unittest.TestCase):
    def test_grants(self):
        for user in ('orion', 'nova', 'quartz', 'echo'):
            grant = make_grant(user, 'challenge', current_time=1792281600)
            signature = sign_grant(grant)
            decoded = verify_grant(signature)
            self.assertEqual(decoded['accountID'], user)
            self.assertEqual(decoded['nonce'], 'challenge')

    def test_tampering_fails(self):
        token = sign_grant(make_grant('orion', 'x', current_time=1792281600))
        payload = json.loads(base64.b64decode(token['payload']))
        payload['expiresAt'] = 4102444799
        token['payload'] = base64.b64encode(json.dumps(payload).encode()).decode()
        with self.assertRaises(Exception): verify_grant(token)

    def test_key_length(self):
        self.assertEqual(len(base64.b64decode(public_key_b64())), 32)

if __name__ == '__main__': unittest.main()
