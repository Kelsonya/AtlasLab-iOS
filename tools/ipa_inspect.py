"""Windows-friendly read-only IPA inventory. python tools/ipa_inspect.py file.ipa"""
import argparse
import hashlib
import plistlib
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('ipa', type=Path)
args = parser.parse_args()

if not args.ipa.is_file():
    parser.error('IPA file not found')

print('File:', args.ipa)
print('SHA-256:', hashlib.sha256(args.ipa.read_bytes()).hexdigest())
with zipfile.ZipFile(args.ipa) as archive:
    names = archive.namelist()
    print('Members:', len(names))
    for name in sorted(names):
        if name.endswith('Info.plist') and name.count('/') <= 2:
            try:
                info = plistlib.loads(archive.read(name))
                print('App:', info.get('CFBundleDisplayName', info.get('CFBundleName')))
                print('Bundle ID:', info.get('CFBundleIdentifier'))
            except Exception as exc: print('Could not parse plist:', exc)
        if ('.framework/' in name and not name.endswith('/')) or name.endswith('/AtlasLabX'):
            parts = name.split('/')
            if len(parts) > 2 and (name.endswith('AtlasLabX') or ('.framework' in parts[-2] and parts[-2][:-10] == parts[-1])):
                print(f"Mach-O candidate: {name} ({archive.getinfo(name).file_size:,} bytes)")
