# THE SIXTH NIGHT — VS Code + Rojo (Windows)

## Что это такое
Этот архив — **проект исходных файлов**, а не Roblox-плагин. Две части: VS Code и Rojo-плагин в Roblox Studio. Rojo переносит изменения скриптов с диска в открытую игру Roblox Studio. Это **не даёт ChatGPT доступа к вашему ПК** и само по себе не подключает ИИ к Roblox Studio. Общие сцены/3D-объекты можно продолжать строить в Studio.

## ВАЖНО: сначала резервная копия
1. В Roblox Studio нажмите Stop.
2. File -> Save to File (лучше Save to File As...) -> сохраните отдельную резервную копию THE_SIXTH_NIGHT_BACKUP.rbxl.
3. Если работаете с Team Create, предупредите товарища перед синхронизацией. Не начинайте с уже открытой совместной сессии без резервной копии.

## Шаг 1: открыть проект
Распакуйте ZIP целиком, например в `C:\RobloxProjects\THE_SIXTH_NIGHT`. Дважды нажмите `OPEN_FOLDER_VSCODE.bat`, либо откройте папку через VS Code -> File -> Open Folder. **Не открывайте один lua-файл вместо всей папки**.

## Шаг 2: установить расширение Rojo в VS Code
В VS Code: Ctrl+Shift+X -> найдите `Rojo` издателя evaera -> Install.
Официальная ссылка: https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo
Откройте Ctrl+Shift+P -> `Rojo: Open Menu`. Если расширение предложит установить Rojo — подтвердите установку. Если не предложит, используйте официальный способ из документации: https://rojo.space/docs/v7/getting-started/installation/ .
В меню Rojo нажмите `Install Roblox Studio Plugin` (если такое действие доступно). Альтернативно после установки CLI выполните в терминале `rojo plugin install`, перезапустите Roblox Studio.

## Шаг 3: безопасное первое соединение
В VS Code Ctrl+Shift+P -> `Rojo: Open Menu`. Выберите проект `default.project.json` и запустите сервер (Serve/Start).
Если установлен CLI, вместо меню можно запустить `START_SAFE_CHECK_CLI.bat`.
В Studio остановите Play, откройте вкладку Plugins -> Rojo -> Connect, обычно на localhost:34872. Если предложит синхронизацию, посмотрите список изменений и подтвердите: должен добавиться лишь `ReplicatedStorage/TSN_RojoBridge/Connected`.

## Шаг 4: убедиться, что всё работает
В Studio откройте Explorer -> ReplicatedStorage -> TSN_RojoBridge -> Connected.
В VS Code откройте `src/rojo-check/Connected.lua`, поменяйте `version = 1` на `version = 2` и нажмите Ctrl+S.
Содержимое `Connected` в Studio должно обновиться автоматически — синхронизация работает!
Если нет: убедитесь, что сервер Rojo работает, Studio Plugin подключен, а VS Code открыл всю папку.

## Шаг 5: перенос настоящих игровых скриптов — ТОЛЬКО после успешной проверки
Файлы уже подготовлены:
- `src/server/ForestGenerator.server.lua` — генератор леса версии v0.3
- `src/server/TSN_CarIntro.server.lua` — автомобильная сцена, сервер v0.2
- `src/client/TSN_CarIntroClient.client.lua` — автомобильная сцена, клиент v0.2
- `legacy/Chapter1_FirstBeat.DISABLED_REFERENCE.lua.txt` — старый сюжетный тест, **не синхронизируется**.

Чтобы перенести скрипты под управление Rojo: остановите безопасный Rojo-сервер, ещё раз проверьте сохранённую резервную копию, отключите старые LocalScript `Chapter1_FirstBeat` (если есть несколько — все). В VS Code Rojo Menu выберите **`game.project.json`** и запустите сервер для него. После проверки списка изменений подключите Studio.

Важно: `game.project.json` управляет именованными скриптами ForestGenerator / TSN_CarIntro / TSN_CarIntroClient. При подключении он может **перезаписать их Source**, поэтому всегда держите резервную копию.

Не запускайте сразу оба проекта Rojo на одном порту. Не создавайте два экземпляра одинаковых скриптов. Если хотите сохранить произвольные изменения из Studio, сначала скопируйте их в VS Code.

## Где появятся объекты
```
Roblox Studio
  ReplicatedStorage
    TSN_RojoBridge
      Connected                    -- тест соединения
  ServerScriptService
    ForestGenerator                -- full sync only
    TSN_CarIntro                   -- full sync only
  StarterPlayer
    StarterPlayerScripts
      TSN_CarIntroClient           -- full sync only
      Chapter1_FirstBeat           -- old one must stay disabled
```

## Работа с другом
Roblox Team Create синхронизирует совместное место, а VS Code+Rojo синхронизирует исходники с компьютера того, кто запустил Rojo. Для двух программистов впоследствии лучше GitHub/Git, чтобы не перезаписывать код друг друга. Не синхронизируйте разные копии Rojo в одну и ту же игру одновременно.

## Официальные ресурсы
- https://rojo.space/docs/v7/getting-started/new-game/
- https://rojo.space/docs/v7/getting-started/installation/
- https://rojo.space/docs/v7/project-format/
- https://github.com/rojo-rbx/rojo/releases

## Что делать при ошибке
Пришлите скрин VS Code, открытый Rojo menu, и вкладку Plugins в Roblox Studio. В Output обратите внимание на строки с Rojo и ошибки красного цвета.
