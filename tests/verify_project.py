import json
import plistlib
from pathlib import Path
import yaml
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
all_swift = list(ROOT.rglob('*.swift'))
assert len(all_swift) >= 10, len(all_swift)
assert (ROOT / '.github/workflows/build-ios.yml').exists()
assert (ROOT / 'server/dev-private-key.pem').exists()
assert (ROOT / 'App/AtlasLab-Bridging-Header.h').exists()
for file in ROOT.rglob('*.json'):
    json.loads(file.read_text('utf-8'))
for file in ROOT.rglob('*.yml'):
    yaml.safe_load(file.read_text('utf-8'))
with (ROOT / 'App/Info.plist').open('rb') as handle:
    plistlib.load(handle)
articles = json.loads((ROOT / 'App/Resources/Articles.json').read_text('utf-8'))
features = json.loads((ROOT / 'App/Resources/FeaturePolicies.json').read_text('utf-8'))
assert len(articles) == 24
assert len(set(x['id'] for x in articles)) == 24
policies = {x['feature'] for x in features['policies']}
assert {x['feature'] for x in articles}.issubset(policies)
keys = json.loads((ROOT / 'App/Resources/SignedFixtures.json').read_text('utf-8'))
assert len(keys['grants']) == 4
assert Counter(x['category'] for x in articles)
print(f'Project assets OK: {len(articles)} articles, {len(policies)} gates, {len(all_swift)} Swift files, 4 signed profiles')
