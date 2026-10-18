"""Ed25519 for demonstration. NEVER use the bundled key in real software."""
import base64
import json
from pathlib import Path
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

HERE = Path(__file__).resolve().parent
KEY_FILE = HERE / "dev-private-key.pem"


def ensure_demo_key():
    if not KEY_FILE.exists():
        key = Ed25519PrivateKey.generate()
        KEY_FILE.write_bytes(key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()))
    return serialization.load_pem_private_key(KEY_FILE.read_bytes(), password=None)


def public_key_b64():
    key = ensure_demo_key().public_key()
    return base64.b64encode(key.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw)).decode("ascii")


def sign_grant(grant):
    raw = json.dumps(grant, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    sig = ensure_demo_key().sign(raw)
    return {
        "payload": base64.b64encode(raw).decode("ascii"),
        "signature": base64.b64encode(sig).decode("ascii"),
    }


def verify_grant(envelope):
    payload = base64.b64decode(envelope["payload"])
    signature = base64.b64decode(envelope["signature"])
    ensure_demo_key().public_key().verify(signature, payload)
    return json.loads(payload)
