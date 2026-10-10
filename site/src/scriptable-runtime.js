// Keepline personal widget. Apache-2.0. No network requests.
// PERSONAL is embedded by the personal editor before this code.
function keeplineDay(date) {
  return date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
}
function keeplineSelected(data, now) {
  const today = keeplineDay(now);
  const active = data.lines.filter(line => !line.archived && (!line.startDay || line.startDay <= today) && (!line.endDay || line.endDay >= today));
  if (!active.length) return null;
  const pin = active.find(line => line.id === data.pinnedID);
  if (pin) return pin;
  const slot = Math.floor(now.getTime() / (data.intervalMinutes * 60000));
  return active[((slot % active.length) + active.length) % active.length];
}
async function keeplineRun() {
  const widget = new ListWidget();
  const ink = Color.dynamic(new Color('223b31'), new Color('e8e8d4'));
  widget.backgroundColor = Color.dynamic(new Color('f4f2e9'), new Color('27342d'));
  widget.setPadding(16, 20, 16, 20);
  const now = new Date();
  const medium = !config.runsInWidget || config.widgetFamily === 'medium';
  const line = keeplineSelected(PERSONAL, now);
  const labels = {always: 'Always', today: 'Today', month: 'This month', year: 'This year', custom: 'Your dates'};
  const title = widget.addText(PERSONAL.name ? PERSONAL.name + ' · ' + (line ? labels[line.period] : 'Keepline') : (line ? labels[line.period] : 'Keepline'));
  title.font = Font.semiboldSystemFont(11); title.textColor = ink; title.lineLimit = 1; title.minimumScaleFactor = 0.7;
  widget.addSpacer();
  const text = widget.addText(!medium ? 'Choose the medium rectangular widget.' : line ? line.text : 'No active lines today. Update your period in Keepline.');
  text.font = new Font('Georgia', 23); text.textColor = ink; text.lineLimit = 4; text.minimumScaleFactor = 0.6;
  widget.addSpacer();
  const footer = widget.addText(line && line.id === PERSONAL.pinnedID ? 'Pinned · keep it in sight.' : 'Your own words, in sight.');
  footer.font = Font.regularSystemFont(10); footer.textColor = ink;
  const midnight = new Date(now); midnight.setHours(24, 0, 0, 0);
  const nextSlot = (Math.floor(now.getTime() / (PERSONAL.intervalMinutes * 60000)) + 1) * PERSONAL.intervalMinutes * 60000;
  widget.refreshAfterDate = new Date(Math.min(nextSlot, midnight.getTime()));
  widget.url = URLScheme.forRunningScript();
  Script.setWidget(widget);
  if (!config.runsInWidget) await widget.presentMedium();
  Script.complete();
}
await keeplineRun();
