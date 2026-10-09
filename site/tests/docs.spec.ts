import { test, expect } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';

test('README Mermaid diagrams parse and render', async ({ page }) => {
  const readme = fs.readFileSync(path.resolve('../README.md'), 'utf8');
  const diagrams = [...readme.matchAll(/```mermaid\r?\n([\s\S]*?)```/g)].map(match => match[1]);
  expect(diagrams.length).toBe(2);
  await page.goto('/');
  await page.addScriptTag({ path: path.resolve('node_modules/mermaid/dist/mermaid.min.js') });
  for (const [index, source] of diagrams.entries()) {
    expect(source).not.toContain('&');
    const rendered = await page.evaluate(async ({ source, index }) => {
      const mermaid = (window as any).mermaid;
      mermaid.initialize({ startOnLoad: false, securityLevel: 'strict' });
      await mermaid.parse(source);
      return (await mermaid.render(`diagram-${index}`, source)).svg as string;
    }, { source, index });
    expect(rendered).toContain('<svg');
  }
});
