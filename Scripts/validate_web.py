from pathlib import Path

html = Path('App/Web/index.html').read_text(encoding='utf-8')
required = [
    'window.webkit.messageHandlers.lorisVoice',
    'action:"saveModel"',
    'action:"speak"',
    'action:"pickPhoto"',
    'action:"exportBoard"',
    'action:"importBoard"',
    'window.nativePhotoSelected',
    'window.nativeImportBoard',
]
missing = [item for item in required if item not in html]
if missing:
    raise SystemExit('Missing native bridge markers: ' + ', '.join(missing))
print('Lori\'s Voice web/native bridge markers verified.')
