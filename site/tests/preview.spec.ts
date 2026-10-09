import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('starts empty and saves only a browser draft', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByLabel('Your line', { exact: true })).toHaveValue('');
  await expect(page.getByRole('button', { name: 'Save browser draft' })).toBeDisabled();
  await page.getByLabel('Your line', { exact: true }).fill('Read 5 books this month.');
  await page.getByLabel('Keep it in sight', { exact: true }).selectOption('month');
  await expect(page.locator('#widget-line')).toHaveText('Read 5 books this month.');
  await page.getByRole('button', { name: 'Save browser draft' }).click();
  await expect(page.getByRole('status')).toContainText('Draft saved');
  await page.reload();
  await expect(page.getByLabel('Your line', { exact: true })).toHaveValue('Read 5 books this month.');
  await expect(page.getByLabel('Keep it in sight', { exact: true })).toHaveValue('month');
  await page.getByRole('button', { name: 'Clear draft' }).click();
  await page.reload();
  await expect(page.getByLabel('Your line', { exact: true })).toHaveValue('');
});

test('rejects multiline text and invalid custom dates', async ({ page }) => {
  await page.goto('/');
  await page.getByLabel('Your line', { exact: true }).fill('One\nTwo');
  await page.getByRole('button', { name: 'Save browser draft' }).click();
  await expect(page.getByRole('status')).toContainText('one line');
  await page.getByLabel('Your line', { exact: true }).fill('Be calm.');
  await page.getByLabel('Keep it in sight', { exact: true }).selectOption('custom');
  await page.getByLabel('Start date').fill('2026-10-09');
  await page.getByLabel('End date').fill('2026-10-08');
  await page.getByRole('button', { name: 'Save browser draft' }).click();
  await expect(page.getByRole('status')).toContainText('end date');
  await page.getByLabel('End date').fill('2026-10-10');
  await page.getByRole('button', { name: 'Save browser draft' }).click();
  await expect(page.getByRole('status')).toContainText('Draft saved');
  await page.getByLabel('Your line', { exact: true }).fill('a'.repeat(141));
  await expect(page.getByRole('button', { name: 'Save browser draft' })).toBeDisabled();
});

test('storage failure gives an honest recovery message', async ({ page }) => {
  await page.addInitScript(() => { Storage.prototype.setItem = () => { throw new Error('Blocked'); }; });
  await page.goto('/');
  await page.getByLabel('Your line', { exact: true }).fill('Be calm.');
  await page.getByRole('button', { name: 'Save browser draft' }).click();
  await expect(page.getByRole('status')).toContainText('cannot save');
  await expect(page.getByRole('button', { name: 'Save browser draft' })).toBeEnabled();
});

test('long lines stay inside the rectangle and mobile input has a nearby preview', async ({ page }, testInfo) => {
  await page.goto('/');
  const before = await page.locator('.widget-stage .widget').boundingBox();
  await page.getByLabel('Your line', { exact: true }).fill('Remember this goal. '.repeat(7));
  const after = await page.locator('.widget-stage .widget').boundingBox();
  expect(after?.height).toBe(before?.height);
  if (testInfo.project.name === 'mobile') {
    await expect(page.locator('#inline-line')).toBeVisible();
    await expect(page.locator('#inline-line')).toHaveText('Remember this goal. '.repeat(7).trim());
  }
});

test('responsive layout, links, keyboard focus, and accessibility', async ({ page }, testInfo) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  await page.keyboard.press('Tab');
  await expect(page.getByRole('link', { name: 'Skip to content' })).toBeFocused();
  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa', 'wcag21aa']).analyze();
  expect(results.violations).toEqual([]);
  await expect(page.getByRole('link', { name: 'Open the iPhone setup guide' })).toHaveAttribute('href', /APPLE-SETUP.md/);
  await page.evaluate(() => (document.activeElement as HTMLElement)?.blur());
  await page.screenshot({ path: `../docs/screenshots/site-${testInfo.project.name}-viewport.png` });
  await page.screenshot({ path: `../docs/screenshots/site-${testInfo.project.name}.png`, fullPage: true });
});
