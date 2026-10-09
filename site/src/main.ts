import './style.css';

const query = <T extends HTMLElement>(id: string) => document.getElementById(id) as T;
const input = query<HTMLTextAreaElement>('line');
const period = query<HTMLSelectElement>('period');
const start = query<HTMLInputElement>('start');
const end = query<HTMLInputElement>('end');
const status = query<HTMLParagraphElement>('form-status');
const save = query<HTMLButtonElement>('save');
const key = 'keepline.preview.v1';
const labels: Record<string, string> = { always: 'Always', today: 'Today', month: 'This month', year: 'This year', custom: 'Custom dates' };
const segmenter = new Intl.Segmenter(undefined, { granularity: 'grapheme' });
const length = (text: string) => [...segmenter.segment(text)].length;
const day = () => {
  const date = new Date();
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
};
start.value = end.value = day();
let persisted = false;

function update() {
  const value = input.value.trim();
  query('count').textContent = `${length(input.value)} / 140`;
  save.disabled = !value || length(value) > 140;
  query('date-fields').hidden = period.value !== 'custom';
  query('widget-line').textContent = value || 'Be calm.';
  query('widget-period').textContent = labels[period.value] ?? 'Always';
  query('inline-line').textContent = value || 'Be calm.';
  query('inline-period').textContent = labels[period.value] ?? 'Always';
  for (const line of [query('widget-line'), query('inline-line')]) line.classList.toggle('long-line', length(value) > 60);
  query('inline-widget').setAttribute('aria-label', `${value ? 'Your browser preview' : 'Example rectangular widget'}: ${value || 'Be calm.'}`);
  const widget = document.querySelector('.widget')!;
  widget.setAttribute('aria-label', `${value ? 'Your browser preview' : 'Example rectangular widget'}: ${value || 'Be calm.'}`);
  query('preview-label').textContent = value ? 'Your browser preview · not synced to iPhone' : 'Illustrative preview · medium rectangular widget';
  if (length(value) > 140) { status.textContent = 'Use 140 characters or fewer.'; input.setAttribute('aria-invalid', 'true'); }
  else { input.removeAttribute('aria-invalid'); }
}

try {
  const stored = localStorage.getItem(key);
  if (stored) {
    const draft: unknown = JSON.parse(stored);
    if (!draft || typeof draft !== 'object') throw new Error('Invalid draft');
    const d = draft as Record<string, unknown>;
    if (typeof d.text !== 'string' || length(d.text) > 140 || typeof d.period !== 'string' || !labels[d.period]) throw new Error('Invalid draft');
    input.value = d.text; period.value = d.period;
    if (typeof d.start === 'string') start.value = d.start;
    if (typeof d.end === 'string') end.value = d.end;
    status.textContent = 'Your saved browser draft is ready.'; persisted = true;
  }
} catch { status.textContent = 'The browser draft cannot be read. Write a new line and save it to replace the draft.'; }
update();

input.addEventListener('input', () => {
  status.textContent = persisted ? 'Changes are not saved yet.' : 'Preview only. Save the draft to keep it in this browser.';
  update();
});
period.addEventListener('change', () => { status.textContent = 'Changes are not saved yet.'; update(); });
for (const field of [start, end]) field.addEventListener('input', () => { status.textContent = 'Changes are not saved yet.'; });
query<HTMLFormElement>('preview-form').addEventListener('submit', (event) => {
  event.preventDefault();
  const value = input.value.trim();
  if (!value || length(value) > 140 || /[\r\n\t\u0000-\u001f\u007f\u2028\u2029]/u.test(value)) {
    status.textContent = 'Use one line of text with 1 to 140 characters.'; input.setAttribute('aria-invalid', 'true'); input.focus(); return;
  }
  if (period.value === 'custom' && (!start.value || !end.value || end.value < start.value)) {
    status.textContent = 'Set both dates. The end date must follow or match the start date.'; end.focus(); return;
  }
  save.disabled = true; save.textContent = 'Save draft…';
  try {
    localStorage.setItem(key, JSON.stringify({ text: value, period: period.value, start: start.value, end: end.value }));
    persisted = true; status.textContent = 'Draft saved in this browser. Your iPhone library stays separate.';
  } catch { status.textContent = 'This browser cannot save the draft. Copy your line before you close this page.'; }
  save.textContent = 'Save browser draft'; update();
});
query<HTMLButtonElement>('clear').addEventListener('click', () => {
  try { localStorage.removeItem(key); }
  catch { status.textContent = 'The saved draft cannot be removed. Enable browser storage, then try again.'; return; }
  input.value = ''; period.value = 'always'; start.value = end.value = day(); persisted = false;
  status.textContent = 'Draft cleared.'; update(); input.focus();
});
