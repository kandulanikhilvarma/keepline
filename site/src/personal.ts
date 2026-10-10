import './style.css';
import './personal.css';
import { emptyLibrary, validate, cleanText, count, bounds, dayKey, active, selected, widgetCode, labels, type PersonalLibrary, type PersonalLine } from './personal-model';
const el = <T extends HTMLElement>(id: string) => document.getElementById(id) as T;
const text = el<HTMLTextAreaElement>('personal-text'), period = el<HTMLSelectElement>('personal-period-input');
const start = el<HTMLInputElement>('personal-start'), end = el<HTMLInputElement>('personal-end'), status = el('personal-status');
const key = 'keepline.personal.v1';
let data = emptyLibrary(), editing: string | null = null, renew = false, damaged = false;
start.value = end.value = dayKey(new Date());
function message(value: string) { status.textContent = value; }
try { const stored = localStorage.getItem(key); if (stored) { data = validate(JSON.parse(stored)); message('Your saved personal library is ready.'); } }
catch { damaged = true; message('Your library cannot be read. Import a personal backup or reset this library before you save.'); }
function commit(next: PersonalLibrary, success: string, replace = false) {
  try {
    if (damaged && !replace) throw new Error('Import a backup or reset the unreadable library first.');
    const checked = validate(next); localStorage.setItem(key, JSON.stringify(checked)); data = checked; damaged = false;
    render(); message(success); return true;
  } catch (error) { message(error instanceof Error ? error.message === 'QuotaExceededError' ? 'Browser storage is full. Export a backup, then free storage and retry.' : `Could not save: ${error.message}. Your saved lines are unchanged.` : 'This browser cannot save. Enable browser storage and retry.'); return false; }
}
function button(label: string, action: () => void, disabled = false) {
  const b = document.createElement('button'); b.type = 'button'; b.className = 'text-button'; b.textContent = label; b.disabled = disabled; b.addEventListener('click', action); return b;
}
function resetEditor() { editing = null; renew = false; text.value = ''; period.value = 'always'; start.value = end.value = dayKey(new Date()); el('editor-title').textContent = data.lines.length ? 'Add another line' : 'Save your first line'; formState(); }
function formState() {
  el('personal-count').textContent = `${count(text.value)} / 140 characters`;
  el<HTMLButtonElement>('personal-save').disabled = damaged || !text.value.trim() || count(text.value.trim()) > 140;
  el('personal-dates').hidden = period.value !== 'custom'; el('cancel-edit').hidden = editing === null;
  const line = data.lines.find(l => l.id === editing);
  el('saved-period').textContent = line && line.period === period.value && line.startDay && !renew ? `Saved period: ${line.startDay} to ${line.endDay}` : '';
  el('renew-period').hidden = !line || !['today', 'month', 'year'].includes(period.value);
}
function preview() {
  const line = selected(data);
  el('personal-line').textContent = line?.text ?? (data.lines.length ? 'No active lines today.' : 'Your words belong here.');
  el('personal-line').classList.toggle('long-line', !!line && count(line.text) > 60);
  el('personal-period').textContent = line ? labels[line.period] : 'Keepline'; el('personal-name').textContent = data.name;
  el('personal-pin').textContent = line ? line.id === data.pinnedID ? 'Pinned · keep it in sight.' : 'Your own words, in sight.' : 'Save an active line below.';
  el('personal-widget').setAttribute('aria-label', line ? `Saved widget preview: ${line.text}` : 'Empty personal widget');
}
function render() {
  preview();
  if (editing === null) el('editor-title').textContent = data.lines.length ? 'Add another line' : 'Save your first line';
  el<HTMLInputElement>('owner-name').value = data.name; el<HTMLSelectElement>('personal-interval').value = String(data.intervalMinutes);
  const list = el('personal-lines'); list.replaceChildren();
  const archived = el<HTMLSelectElement>('line-filter').value === 'archived';
  const lines = data.lines.filter(l => l.archived === archived);
  el('library-empty').hidden = lines.length > 0; el('library-empty').textContent = archived ? 'No archived lines.' : 'No saved lines yet.';
  for (const line of [...lines].reverse()) {
    const item = document.createElement('li');
    const p = document.createElement('p'); p.className = 'saved-line-text'; p.textContent = line.text; item.append(p);
    const meta = document.createElement('p'); meta.className = 'line-meta'; meta.textContent = `${labels[line.period]} · ${line.archived ? 'Archived' : active(line) ? 'Active' : 'Outside its period'}${line.endDay ? ` · until ${line.endDay}` : ''}${data.pinnedID === line.id ? ' · Pinned' : ''}`; item.append(meta);
    const actions = document.createElement('div'); actions.className = 'line-actions';
    actions.append(button('Edit', () => { editing = line.id; renew = false; text.value = line.text; period.value = line.period; start.value = line.startDay ?? dayKey(new Date()); end.value = line.endDay ?? dayKey(new Date()); el('editor-title').textContent = 'Edit my line'; formState(); text.focus(); }));
    actions.append(button(data.pinnedID === line.id ? 'Unpin' : 'Pin', () => commit({ ...data, pinnedID: data.pinnedID === line.id ? null : line.id }, 'Pin updated. Copy the new widget code to Scriptable.'), !active(line)));
    actions.append(button(line.archived ? 'Restore' : 'Archive', () => commit({ ...data, pinnedID: data.pinnedID === line.id ? null : data.pinnedID, lines: data.lines.map(l => l.id === line.id ? { ...l, archived: !l.archived } : l) }, 'Library updated. Copy the new widget code to Scriptable.')));
    actions.append(button('Delete', () => { if (confirm('Delete this personal line?')) { if (commit({ ...data, pinnedID: data.pinnedID === line.id ? null : data.pinnedID, lines: data.lines.filter(l => l.id !== line.id) }, 'Line deleted. Copy the new widget code to Scriptable.')) { if (editing === line.id) resetEditor(); } } }));
    item.append(actions); list.append(item);
  }
  const ready = data.lines.length > 0 && !damaged;
  for (const id of ['copy-widget', 'download-widget', 'show-code']) el<HTMLButtonElement>(id).disabled = !ready;
  el('export-status').textContent = ready ? 'Your widget file is ready. Copy it to Scriptable after each change.' : 'Save a line to prepare your widget file.';
  el<HTMLTextAreaElement>('widget-code').value = ready ? widgetCode(data) : '';
  formState();
}
for (const input of [text, period, start, end]) input.addEventListener('input', formState);
el('line-filter').addEventListener('change', render);
el('renew-period').addEventListener('click', () => { renew = true; formState(); message('The current period will apply when you save.'); });
el('cancel-edit').addEventListener('click', resetEditor);
el<HTMLFormElement>('personal-form').addEventListener('submit', event => {
  event.preventDefault();
  try {
    const value = cleanText(text.value);
    const existing = data.lines.find(l => l.id === editing);
    if (!existing && data.lines.length >= 50) throw new Error('This personal library holds 50 lines. Delete one before adding another.');
    let dates = existing && existing.period === period.value && !renew ? [existing.startDay, existing.endDay] : bounds(period.value);
    if (period.value === 'custom') dates = [start.value, end.value];
    const line: PersonalLine = { id: existing?.id ?? crypto.randomUUID(), text: value, period: period.value, startDay: dates[0], endDay: dates[1], archived: existing?.archived ?? false };
    if (commit({ ...data, lines: existing ? data.lines.map(l => l.id === line.id ? line : l) : [...data.lines, line] }, 'Line saved on this browser. Copy the updated widget code to Scriptable.')) resetEditor();
  } catch (error) { message(error instanceof Error ? error.message : 'Check your line and dates.'); text.focus(); }
});
el<HTMLFormElement>('settings-form').addEventListener('submit', event => { event.preventDefault(); commit({ ...data, name: el<HTMLInputElement>('owner-name').value, intervalMinutes: Number(el<HTMLSelectElement>('personal-interval').value) }, 'Widget settings saved. Copy the updated code to Scriptable.'); });
function download(content: string, filename: string, type: string) { const url = URL.createObjectURL(new Blob([content], { type })); const a = document.createElement('a'); a.href = url; a.download = filename; document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(url), 60000); }
el('download-widget').addEventListener('click', () => { download(widgetCode(data), 'Keepline.js', 'text/javascript;charset=utf-8'); el('export-status').textContent = 'File prepared. Open Downloads in Safari or Files. The copy route is available if your browser opens the file instead.'; });
el('show-code').addEventListener('click', () => { el('code-panel').hidden = !el('code-panel').hidden; });
el('copy-widget').addEventListener('click', async () => { try { await navigator.clipboard.writeText(widgetCode(data)); el('export-status').textContent = 'Widget code copied. Paste it into Scriptable and name the script Keepline.'; } catch { el('code-panel').hidden = false; el<HTMLTextAreaElement>('widget-code').focus(); el<HTMLTextAreaElement>('widget-code').select(); el('export-status').textContent = 'Copying is blocked. Select all the shown code and copy it yourself, or download the file.'; } });
el('export-backup').addEventListener('click', () => { download(JSON.stringify(data, null, 2), 'Keepline-personal-backup.json', 'application/json'); message('Personal backup prepared. Keep the file private.'); });
el<HTMLInputElement>('import-backup').addEventListener('change', async event => {
  const input = event.target as HTMLInputElement, file = input.files?.[0]; if (!file) return;
  try { if (file.size > 1048576) throw new Error('Use a personal backup smaller than 1 MB.'); const backup = validate(JSON.parse(await file.text())); if (confirm('Replace your personal library with this backup?')) { if (commit(backup, 'Personal backup imported. Copy the new widget code to Scriptable.', true)) resetEditor(); } }
  catch (error) { message(error instanceof Error ? `Cannot import: ${error.message}. Your library is unchanged.` : 'Cannot import this file.'); }
  finally { input.value = ''; }
});
el('reset-library').addEventListener('click', () => { if (confirm('Remove all personal lines from this browser? Keep a backup first.')) { if (commit(emptyLibrary(), 'Personal library reset.', true)) resetEditor(); } });
render();
setInterval(preview, 60000);
if ('serviceWorker' in navigator) navigator.serviceWorker.register('/personal-sw.js').then(() => navigator.serviceWorker.ready).then(() => { el('offline-state').textContent = 'Offline ready. You can add this editor to your Safari home screen.'; }).catch(() => { el('offline-state').textContent = 'Offline setup is unavailable here. Keep an internet connection to reopen the editor.'; });
