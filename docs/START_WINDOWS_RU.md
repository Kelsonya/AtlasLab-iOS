# Atlas Lab X — запуск с Windows

У нас уже существует репозиторий `https://github.com/Kelsonya/AtlasLab-iOS`, поэтому **создавать новый не требуется**.

## Обновление репозитория

### Через Git / PowerShell

Распакуй ZIP, открой PowerShell в корне `AtlasLab_X` и выполни:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\publish_to_github.ps1
```

Сценарий **спрашивает подтверждение `REPLACE`**, затем клонирует существующий репозиторий, удаляет старые файлы **в новой локальной копии**, добавляет содержимое Atlas Lab X и создаёт commit/push. История репозитория остаётся. Требуется установленный Git и авторизация GitHub. Если Git отсутствует, можно сделать ту же замену вручную через GitHub Desktop.

**Важно:** этот сценарий заменяет ранее загруженные файлы в репозитории. Если там уже есть несохранённые важные изменения, сначала сделай копию.

### Через GitHub Desktop

1. `File → Clone repository` → выбери `AtlasLab-iOS`.
2. В локальном каталоге клона удали старое содержимое, **кроме `.git`**, и скопируй туда все файлы/папки `AtlasLab_X`, включая скрытую `.github`.
3. В GitHub Desktop убедись, что видны изменения и добавление `.github/workflows/build-ios.yml`.
4. Впиши commit message и нажми `Commit to main`, потом `Push origin`.

## Бесплатная сборка

Открой `https://github.com/Kelsonya/AtlasLab-iOS/actions`.

Выбери `Atlas Lab X — build unsigned IPA`. При пуше сценарий запускается автоматически, а также доступна команда `Run workflow`.

При успехе скачай архив `AtlasLabX-iOS-binaries`: там `AtlasLabX-UNSIGNED.ipa` и три отдельных ARM64 Mach-O.

Если сборка завершилась с ошибкой, скачай `AtlasLabX-build-log` или открой неуспешный шаг. **Мы ещё не проверяли компиляцию именно в Xcode**, поэтому ошибки нужно исправлять по фактическому логу, не угадывая.

## Изучение в IDA

Начни с `MachO/AtlasLabX-main-arm64`, затем изучи `AtlasPolicy-arm64` и `AtlasSignals-arm64`. Для инвентаризации можно открыть скрипт `tools/ida_inventory.py` через `File → Script file…` в IDA. Он ничего не меняет в базе.

Не вставляй в IDA архив `.ipa` как обычный Mach-O. IPA — ZIP с `Payload/*.app`, а отдельно экспортированные файлы уже готовы к открытию.
