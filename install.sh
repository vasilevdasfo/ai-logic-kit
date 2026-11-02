#!/usr/bin/env bash
# Установка ai-logic-kit для Codex и Claude Code (macOS / Linux).
# Повторный запуск безопасен: блок правил обновляется, а не дублируется.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
SKILL="logic-4-laws"
START="<!-- ai-logic-kit:start -->"
END="<!-- ai-logic-kit:end -->"

install_rules() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  # бэкап только при первой установке — чтобы сохранился исходный файл
  [ -e "$file.bak-ai-logic-kit" ] || cp "$file" "$file.bak-ai-logic-kit"
  # убрать старый блок, если он уже был
  local tmp; tmp="$(mktemp)"
  awk -v s="$START" -v e="$END" '
    $0==s {skip=1; next}
    $0==e {skip=0; next}
    !skip {print}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
  printf '\n' >> "$file"
  cat "$KIT/rules/ALWAYS_ON.md" >> "$file"
  echo "  правила → $file (бэкап: $file.bak-ai-logic-kit)"
}

install_for() {
  local name="$1" home="$2" rules="$3"
  echo "$name:"
  mkdir -p "$home/skills"
  rm -rf "$home/skills/$SKILL"
  cp -R "$KIT/skills/$SKILL" "$home/skills/$SKILL"
  mkdir -p "$home/naming"
  cp "$KIT/naming/SESSION_NAMING.md" "$home/naming/SESSION_NAMING.md"
  echo "  скилл   → $home/skills/$SKILL"
  install_rules "$home/$rules"
}

install_for "Codex"       "$HOME/.codex"  "AGENTS.md"
install_for "Claude Code" "$HOME/.claude" "CLAUDE.md"

echo
echo "Готово. Перезапустите Codex / Claude Code и откройте НОВЫЙ чат."
echo "Проверка: спросите что угодно — в конце ответа должен быть блок «🧠 Логика:»."
