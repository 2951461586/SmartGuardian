from pathlib import Path
import re

src = Path(r'docs/03-接口文档/openapi-full.yaml')
out = Path(r'tmp/openapi-snippets.txt')
text = src.read_text(encoding='utf-8')
keys = [
    'TimelineEvent', 'TimelineListResponse', 'PaymentCreateRequest', 'PaymentCallbackRequest', 'PaymentDetail',
    'ServiceProduct', 'ServiceProductCreateRequest', 'ServiceProductUpdateRequest', 'ServiceProductListResponse',
    'OrderDetail', 'SessionSchedule', 'SessionStudent', 'SessionListResponse', 'SessionStudentListResponse', 'SessionUpdateRequest', 'SessionGenerateRequest',
    'AttendanceRecord', 'AbnormalEvent', 'AbnormalEventPageResponse', 'AbnormalHandleRequest',
    'HomeworkTask', 'HomeworkTaskListResponse', 'HomeworkTaskCreateRequest', 'HomeworkTaskUpdateRequest', 'HomeworkFeedbackCreateRequest',
    'MessageRecord', 'MessageSendRequest', 'Conversation', 'ConversationListResponse'
]
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
out.write_text('\n'.join(parts), encoding='utf-8')
print(str(out))
