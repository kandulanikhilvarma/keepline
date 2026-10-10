import runtime from './scriptable-runtime.js?raw';
export const labels: Record<string, string> = { always: 'Always', today: 'Today', month: 'This month', year: 'This year', custom: 'Custom dates' };
export type PersonalLine = { id: string; text: string; period: string; startDay: string | null; endDay: string | null; archived: boolean };
export type PersonalLibrary = { version: 1; name: string; intervalMinutes: number; pinnedID: string | null; lines: PersonalLine[] };
export const emptyLibrary = (): PersonalLibrary => ({ version: 1, name: '', intervalMinutes: 60, pinnedID: null, lines: [] });
const segmenter = new Intl.Segmenter(undefined, { granularity: 'grapheme' });
export const count = (text: string) => [...segmenter.segment(text)].length;
export function cleanText(text: string, limit = 140) {
  const clean = text.trim();
  if (!clean || count(clean) > limit || /[\p{Cc}\u2028\u2029]/u.test(clean)) throw new Error(`Use one line with 1 to ${limit} characters.`);
  return clean;
}
export function dayKey(date: Date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}
function validDay(value: unknown): value is string {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const d = new Date(`${value}T12:00:00`); return Number.isFinite(d.getTime()) && dayKey(d) === value;
}
export function bounds(period: string, now = new Date()): [string | null, string | null] {
  const y = now.getFullYear(), m = now.getMonth();
  if (period === 'today') return [dayKey(now), dayKey(now)];
  if (period === 'month') return [dayKey(new Date(y, m, 1)), dayKey(new Date(y, m + 1, 0))];
  if (period === 'year') return [`${y}-01-01`, `${y}-12-31`];
  return [null, null];
}
export function validate(value: unknown): PersonalLibrary {
  if (!value || typeof value !== 'object') throw new Error('This is not a Keepline personal backup.');
  const d = value as PersonalLibrary;
  if (d.version !== 1 || typeof d.name !== 'string' || count(d.name) > 40 || /[\p{Cc}\u2028\u2029]/u.test(d.name) || ![30, 60, 180].includes(d.intervalMinutes) || !Array.isArray(d.lines) || d.lines.length > 50 || (d.pinnedID !== null && typeof d.pinnedID !== 'string')) throw new Error('This personal backup has invalid settings.');
  const ids = new Set<string>();
  const lines = d.lines.map(line => {
    if (!line || typeof line.id !== 'string' || !line.id || line.id.length > 100 || ids.has(line.id) || typeof line.text !== 'string' || !Object.hasOwn(labels, line.period) || typeof line.archived !== 'boolean') throw new Error('This personal backup has an invalid or duplicate line.');
    ids.add(line.id);
    const text = cleanText(line.text);
    if (line.period === 'always') {
      if (line.startDay !== null || line.endDay !== null) throw new Error('An Always line must have no dates.');
    } else if (!validDay(line.startDay) || !validDay(line.endDay) || line.startDay > line.endDay) throw new Error('A line has invalid dates.');
    return { id: line.id, text, period: line.period, startDay: line.startDay, endDay: line.endDay, archived: line.archived };
  });
  return { version: 1, name: d.name.trim(), intervalMinutes: d.intervalMinutes, pinnedID: lines.some(line => line.id === d.pinnedID) ? d.pinnedID : null, lines };
}
export const active = (line: PersonalLine, date = new Date()) => !line.archived && (!line.startDay || line.startDay <= dayKey(date)) && (!line.endDay || line.endDay >= dayKey(date));
export function selected(data: PersonalLibrary, date = new Date()) {
  const lines = data.lines.filter(line => active(line, date));
  return lines.find(line => line.id === data.pinnedID) ?? lines[((Math.floor(date.getTime() / (data.intervalMinutes * 60000)) % lines.length) + lines.length) % lines.length] ?? null;
}
export function widgetCode(data: PersonalLibrary) {
  const json = JSON.stringify(validate(data), null, 2).replace(/\u2028/g, '\\u2028').replace(/\u2029/g, '\\u2029');
  return `// Keepline — your personal rectangular widget.\n// Paste into a Scriptable script named Keepline.\n// Contains your own words. Keep this file private.\nconst PERSONAL = ${json};\n\n${runtime}`;
}
