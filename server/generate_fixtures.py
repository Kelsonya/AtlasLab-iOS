"""Generate signed offline demo responses that iOS can validate without network."""
import json
import time
from pathlib import Path
from app import make_grant
from crypto_helpers import public_key_b64, sign_grant

HERE = Path(__file__).resolve().parent
RESOURCES = HERE.parent / 'App' / 'Resources'


def generate():
    profiles = json.loads((HERE / 'accounts.json').read_text(encoding='utf-8'))
    # Fixed reference issue date is intentional to make the archive reproducible.
    # Offline fixtures have a long validation lease; subscription expiry is a separate field.
    reference = 1792281600  # 2026-10-18 00:00:00 UTC
    fixture = {'publicKey': public_key_b64(), 'grants': {}}
    for profile in sorted(profiles):
        grant = make_grant(profile, 'fixture', current_time=reference)
        grant['leaseUntil'] = 4102444799
        fixture['grants'][profile] = sign_grant(grant)
    (RESOURCES / 'SignedFixtures.json').write_text(json.dumps(fixture, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print('Updated SignedFixtures.json with Ed25519 signatures')


if __name__ == '__main__':
    generate()
