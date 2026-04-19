from pathlib import Path
import re
src = Path(r'docs/03-接口文档/openapi-full.yaml')
text = src.read_text(encoding='utf-8')
keys = ['MessageRecord','MessageListResponse','SessionInfo']
parts = []
for key in keys:
    m = re.search(r'(?m)^    ' + re.escape(key) + r':\n', text)
    parts.append('===== ' + key + ' =====')
    if not m:
        parts.append('NOT FOUND\n')
        continue
    start = m.start()
    m2 = re.search(r'(?m)^    [A-Za-z0-9_]+:\n', text[m.end():])
    end = len(text) if not m2 else m.end() + m2.start()
    parts.append(text[start:end].rstrip())
    parts.append('')
out = Path(r'tmp/openapi-more-snippets.txt')
out.write_text('\n'.join(parts), encoding='utf-8')
print(str(out))
