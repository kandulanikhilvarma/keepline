import { test, expect, type Page } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import fs from 'node:fs';
import vm from 'node:vm';

async function add(page: Page, line: string, period = 'always') {
  await page.getByLabel('Your personal line', { exact: true }).fill(line);
  await page.getByLabel('Period', { exact: true }).selectOption(period);
  await page.getByRole('button', { name: 'Save line', exact: true }).click();
}
async function downloadCode(page: Page) {
  const pending = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Download Keepline.js', exact: true }).click();
  const file = await pending; expect(file.suggestedFilename()).toBe('Keepline.js');
  return fs.readFileSync((await file.path())!, 'utf8');
}
async function runScript(code: string, at: string, family = 'medium', inApp = false) {
  let result: any, completed = false, previewed = false;
  const clock = class extends Date { constructor(...args: any[]) { super(args.length ? args[0] : at); } };
  class Widget { texts: any[] = []; refreshAfterDate?: Date; addText(text: string) { const value = { text }; this.texts.push(value); return value; } addSpacer() {} setPadding() {} async presentMedium() { previewed = true; } }
  class Color { constructor(public value: string) {} static dynamic(light: Color) { return light; } }
  class Font { constructor(public value: string, public size: number) {} static semiboldSystemFont(size: number) { return new Font('system', size); } static regularSystemFont(size: number) { return new Font('system', size); } }
  await vm.runInNewContext(`(async () => { ${code}\n })()`, { ListWidget: Widget, Color, Font, Date: clock, config: { runsInWidget: !inApp, widgetFamily: family }, URLScheme: { forRunningScript: () => 'scriptable:///run?scriptName=Keepline' }, Script: { setWidget: (widget: any) => { result = widget; }, complete: () => { completed = true; } } }, { timeout: 1000 });
  expect(completed).toBe(true); return { result, previewed };
}

test('personal records survive reload and support edit, pin, archive, restore, delete', async ({ page }) => {
  page.on('dialog', dialog => dialog.accept());
  await page.goto('/personal.html');
  await expect(page.getByRole('button', { name: 'Copy widget code' })).toBeDisabled();
  await add(page, 'Be calm.'); await add(page, 'Read 5 books this month.', 'month');
  const first = page.locator('#personal-lines li').filter({ hasText: 'Be calm.' });
  await first.getByRole('button', { name: 'Pin', exact: true }).click();
  await page.reload(); await expect(page.locator('#personal-line')).toHaveText('Be calm.');
  await expect(page.locator('#editor-title')).toHaveText('Add another line');
  await first.getByRole('button', { name: 'Edit', exact: true }).click();
  await page.getByLabel('Your personal line', { exact: true }).fill('Be calm. Breathe.');
  await page.getByRole('button', { name: 'Save line', exact: true }).click();
  await expect(page.locator('#personal-line')).toHaveText('Be calm. Breathe.');
  const edited = page.locator('#personal-lines li').filter({ hasText: 'Be calm. Breathe.' });
  await edited.getByRole('button', { name: 'Archive', exact: true }).click();
  await expect(page.locator('#personal-line')).toHaveText('Read 5 books this month.');
  await page.getByLabel('Show personal lines').selectOption('archived');
  await edited.getByRole('button', { name: 'Restore', exact: true }).click();
  await page.getByLabel('Show personal lines').selectOption('current');
  await edited.getByRole('button', { name: 'Delete', exact: true }).click();
  await expect(page.locator('#personal-lines li')).toHaveCount(1);
  await page.reload(); await expect(page.locator('#personal-lines li')).toHaveCount(1);
});

test('downloaded personal widget runs its documented host API contract without network access', async ({ page }) => {
  await page.goto('/personal.html');
  const ownText = 'Be calm. </script> " 🧘‍♀️'; await add(page, ownText);
  await page.locator('#personal-lines li').getByRole('button', { name: 'Pin', exact: true }).click();
  await page.getByText('Widget settings and backups', { exact: true }).click();
  await page.getByLabel('Your name (optional)').fill('Nikhil');
  await page.getByRole('button', { name: 'Save widget settings' }).click();
  const code = await downloadCode(page);
  const { result } = await runScript(code, '2026-10-10T12:00:00Z');
  expect(result.texts.map((value: any) => value.text)).toContain(ownText);
  expect(result.texts[0].text).toBe('Nikhil · Always');
  expect(result.texts[2].text).toContain('Pinned');
  expect(result.refreshAfterDate.getTime()).toBeGreaterThan(new Date('2026-10-10T12:00:00Z').getTime());
  expect((await runScript(code, '2026-10-10T12:00:00Z', 'medium', true)).previewed).toBe(true);
  expect((await runScript(code, '2026-10-10T12:00:00Z', 'small')).result.texts[1].text).toContain('medium rectangular');
});

test('widget dates exclude expired, future and archived lines and fall back from an inactive pin', async ({ page }) => {
  page.on('dialog', dialog => dialog.accept());
  await page.goto('/personal.html'); await page.getByText('Widget settings and backups', { exact: true }).click();
  const data = { version: 1, name: '', intervalMinutes: 60, pinnedID: 'dated', lines: [
    { id: 'always', text: 'Keep learning.', period: 'always', startDay: null, endDay: null, archived: false },
    { id: 'dated', text: 'Read today.', period: 'custom', startDay: '2026-10-10', endDay: '2026-10-10', archived: false },
    { id: 'future', text: 'Start next month.', period: 'custom', startDay: '2026-11-01', endDay: '2026-11-30', archived: false },
    { id: 'archived', text: 'Archived text.', period: 'always', startDay: null, endDay: null, archived: true },
  ] };
  await page.locator('#import-backup').setInputFiles({ name: 'personal.json', mimeType: 'application/json', buffer: Buffer.from(JSON.stringify(data)) });
  const code = await downloadCode(page);
  expect((await runScript(code, '2026-10-10T12:00:00Z')).result.texts[1].text).toBe('Read today.');
  expect((await runScript(code, '2026-10-11T12:00:00Z')).result.texts[1].text).toBe('Keep learning.');
});

test('invalid lines, dates and duplicate backup IDs preserve the personal library', async ({ page }) => {
  await page.goto('/personal.html'); await add(page, 'Keep learning.');
  await add(page, 'One\nTwo'); await expect(page.locator('#personal-status')).toContainText('one line');
  await page.getByLabel('Your personal line', { exact: true }).fill('a'.repeat(141));
  await expect(page.getByRole('button', { name: 'Save line', exact: true })).toBeDisabled();
  await page.getByLabel('Your personal line', { exact: true }).fill('Custom goal.');
  await page.getByLabel('Period', { exact: true }).selectOption('custom');
  await page.getByLabel('Start date', { exact: true }).fill('2026-10-10');
  await page.getByLabel('End date', { exact: true }).fill('2026-10-09');
  await page.getByRole('button', { name: 'Save line', exact: true }).click();
  await expect(page.locator('#personal-status')).toContainText('invalid dates');
  await page.getByText('Widget settings and backups', { exact: true }).click();
  const existing = await page.evaluate(() => JSON.parse(localStorage.getItem('keepline.personal.v1')!));
  existing.lines.push(existing.lines[0]);
  await page.locator('#import-backup').setInputFiles({ name: 'bad.json', mimeType: 'application/json', buffer: Buffer.from(JSON.stringify(existing)) });
  await expect(page.locator('#personal-status')).toContainText('duplicate line');
  await expect(page.locator('#personal-lines li')).toHaveCount(1);
  await page.reload(); await expect(page.locator('#personal-lines li')).toHaveCount(1);
});

test('corrupt browser records require explicit recovery and blocked writes preserve the editor', async ({ page }) => {
  await page.addInitScript(() => localStorage.setItem('keepline.personal.v1', '{broken'));
  await page.goto('/personal.html');
  await expect(page.locator('#personal-status')).toContainText('cannot be read');
  await expect(page.getByRole('button', { name: 'Save line', exact: true })).toBeDisabled();
  await page.getByText('Widget settings and backups', { exact: true }).click();
  page.on('dialog', dialog => dialog.accept());
  await page.getByRole('button', { name: 'Reset this library' }).click();
  await expect(page.locator('#personal-status')).toContainText('reset');
  await page.evaluate(() => { Storage.prototype.setItem = () => { throw new Error('Storage blocked'); }; });
  await add(page, 'Preserve my words.');
  await expect(page.locator('#personal-status')).toContainText('Could not save');
  await expect(page.getByLabel('Your personal line', { exact: true })).toHaveValue('Preserve my words.');
  await expect(page.locator('#personal-lines li')).toHaveCount(0);
});

test('clipboard copies the actual personal script and offers a manual recovery path', async ({ page, context }) => {
  await context.grantPermissions(['clipboard-read', 'clipboard-write']);
  await page.goto('/personal.html'); await add(page, 'My own reminder.');
  await page.getByRole('button', { name: 'Copy widget code' }).click();
  await expect(page.locator('#export-status')).toContainText('copied');
  expect(await page.evaluate(() => navigator.clipboard.readText())).toContain('My own reminder.');
  await page.evaluate(() => { navigator.clipboard.writeText = async () => { throw new Error('Blocked'); }; });
  await page.getByRole('button', { name: 'Copy widget code' }).click();
  await expect(page.locator('#export-status')).toContainText('blocked');
  await expect(page.getByLabel('Widget code', { exact: true })).toBeVisible();
  await expect(page.getByLabel('Widget code', { exact: true })).toHaveValue(/My own reminder/);
});

test('personal editor works offline after setup and preserves its own records', async ({ page, context }) => {
  await page.goto('/personal.html'); await add(page, 'Offline and in sight.');
  await expect(page.locator('#offline-state')).toContainText('Offline ready', { timeout: 15000 });
  await page.evaluate(async () => { await navigator.serviceWorker.ready; });
  await context.setOffline(true); await page.reload();
  await expect(page.locator('#personal-line')).toHaveText('Offline and in sight.');
  await add(page, 'Another offline line.');
  await expect(page.locator('#personal-lines li')).toHaveCount(2);
});

test('personal interface has accessible focus, touch controls and mobile layout', async ({ page }, testInfo) => {
  await page.goto('/personal.html'); await add(page, 'Be calm.');
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  const result = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa']).analyze();
  expect(result.violations).toEqual([]);
  await page.reload(); await page.keyboard.press('Tab');
  await expect(page.getByRole('link', { name: 'Skip to content' })).toBeFocused();
  await page.evaluate(() => (document.activeElement as HTMLElement)?.blur());
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({ path: `../docs/screenshots/personal-${testInfo.project.name}-viewport.png` });
  await page.screenshot({ path: `../docs/screenshots/personal-${testInfo.project.name}.png`, fullPage: true });
});
