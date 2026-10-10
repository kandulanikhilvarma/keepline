---
name: Keepline
description: A quiet place for your own words.
colors:
  ink: "#223b31"
  paper: "#f4f2e9"
  muted: "#536259"
  rule: "#c9cec0"
  tint: "#dce2c6"
  hover: "#3a5748"
  field-paper: "#fffdf6"
  stroke: "#84917c"
  attention: "#a54b2d"
  native-accent-light: "color(srgb 0.133 0.231 0.192)"
  native-accent-dark: "color(srgb 0.784 0.863 0.643)"
  native-paper-light: "color(srgb 0.941 0.933 0.871)"
  native-paper-dark: "color(srgb 0.153 0.204 0.176)"
  native-ink-light: "color(srgb 0.13 0.23 0.19)"
  native-ink-dark: "color(srgb 0.91 0.91 0.83)"
typography:
  display:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "clamp(3.5rem, 6.1vw, 5.5rem)"
    fontWeight: 400
    lineHeight: 1.02
    letterSpacing: "-0.035em"
  headline:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "38px"
    fontWeight: 400
    lineHeight: 1.12
    letterSpacing: "-0.025em"
  body:
    fontFamily: "Arial, Helvetica, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.65
  label:
    fontFamily: "Arial, Helvetica, sans-serif"
    fontSize: "13px"
    fontWeight: 600
  action:
    fontFamily: "Arial, Helvetica, sans-serif"
    fontSize: "14px"
    fontWeight: 600
  widget-line:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "clamp(1.4rem, 3.4vw, 3rem)"
    fontWeight: 400
    lineHeight: 1.16
    letterSpacing: "-0.025em"
  widget-line-long:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "22px"
    fontWeight: 400
    lineHeight: 1.15
    letterSpacing: "-0.025em"
  input-line:
    fontFamily: "Newsreader, Georgia, serif"
    fontSize: "24px"
    fontWeight: 400
    lineHeight: 1.3
rounded:
  control: "5px"
  widget: "24px"
  widget-mobile: "22px"
spacing:
  micro: "10px"
  field: "14px"
  control: "16px"
  compact: "20px"
  mobile-gutter: "22px"
  small: "24px"
  column-compact: "32px"
  page-gutter: "48px"
  column: "70px"
components:
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    typography: "{typography.action}"
    rounded: "{rounded.control}"
    padding: "16px 20px"
  button-primary-hover:
    backgroundColor: "{colors.hover}"
  button-inverse:
    backgroundColor: "transparent"
    textColor: "{colors.paper}"
    typography: "{typography.action}"
    rounded: "{rounded.control}"
    padding: "16px 20px"
  button-inverse-hover:
    backgroundColor: "{colors.hover}"
  button-text:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    padding: "14px 0"
  field:
    backgroundColor: "{colors.field-paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    padding: "14px"
  textarea:
    backgroundColor: "{colors.field-paper}"
    textColor: "{colors.ink}"
    typography: "{typography.input-line}"
    rounded: "{rounded.control}"
    padding: "14px"
  widget-preview:
    backgroundColor: "{colors.tint}"
    textColor: "{colors.ink}"
    rounded: "{rounded.widget}"
    padding: "25px 28px"
    height: "240px"
  widget-preview-mobile:
    rounded: "{rounded.widget-mobile}"
    padding: "22px"
    height: "210px"
  widget-preview-inline:
    backgroundColor: "{colors.tint}"
    textColor: "{colors.ink}"
    rounded: "{rounded.widget-mobile}"
    padding: "18px 22px"
    height: "180px"
  widget-preview-personal:
    backgroundColor: "{colors.tint}"
    textColor: "{colors.ink}"
    rounded: "{rounded.widget}"
    padding: "20px 24px"
    height: "185px"
  widget-preview-personal-mobile:
    rounded: "{rounded.widget-mobile}"
    height: "180px"
---

# Design System: Keepline

## Overview

**Creative North Star: "Desk memo"**

Keepline gives one personal line a quiet place in sight. The desk memo direction uses direct text and plain digital surfaces. Broad margins separate the line from controls. Fine rules divide secondary content.

The website uses serif headlines and a rectangular preview. The iPhone app uses native navigation, forms, and lists. The shared line card carries the visual identity into the app and widget. The app and website share a palette direction. Each platform has separate type and layout rules.

The personal editor extends the same desk memo world. Saved words lead the preview and library. Settings stay within a disclosure beneath the library.

**Key Characteristics:**


- Personal words take priority over controls.

- Paper colors support dark text and quiet dividers.

- The rectangle stays stable when the line grows.

- Native iOS controls keep their platform behavior.

## Colors

The palette combines warm paper with forest ink and pale leaf surfaces.

### Primary


- **Forest ink** supplies website text, primary actions, the brand mark, and the setup background.

- **Forest hover** changes the background of primary and inverse website actions.

- **Native forest accent** supplies the light appearance of iOS controls.

- **Native leaf accent** supplies the dark appearance of iOS controls.

### Secondary


- **Leaf tint** fills browser widget previews and selected text.

- **Attention rust** identifies website focus and invalid fields. Error text also names the problem.

### Neutral


- **Parchment** supplies the website canvas and light text on forest backgrounds.

- **Muted forest** supplies secondary website text.

- **Quiet rule** separates website sections and the footer.

- **Field paper** supplies the background of website fields.

- **Field stroke** supplies website field borders and numbered step circles.

- **Native paper** supplies the app preview and widget background. Its asset has separate light and dark appearances.

- **Native ink** supplies shared card text. The card selects its light or dark value from the active color scheme.

### Named Rules

**The Paper and Ink Rule.** Use paper for the reading surface and ink for text. Use leaf tint for the browser line preview.

The website has one color appearance. The native asset catalog owns iOS appearance changes. Native destructive actions use the system red. Archive actions use the system orange.

## Typography

**Display Font:** Newsreader, with Georgia and serif fallbacks.

**Body Font:** Arial, with Helvetica and sans-serif fallbacks.

The website self-hosts Newsreader under its OFL license. Serif type gives the personal line more space than labels and controls. Body text stays plain and compact.

### Hierarchy


- **Display** uses the fluid headline token for the website opening. The medium layout uses (62px). The narrow layout uses (66px).

- **Headline** uses the section title token. Narrow layouts reduce it to (34px).

- **Body** uses the body token for explanatory text. Secondary blocks use smaller sizes, usually (12px to 14px).

- **Label** uses the label token for website form labels. Labels use sentence case.

- **Action** uses the action token for primary and inverse website buttons.

- **Widget line** uses the serif preview token. The narrow hero preview uses (36px). The nearby mobile preview uses (30px).

- **Long widget line** applies above (60 characters). The narrow hero uses (20px). The nearby mobile preview uses (18px).

- **Input line** uses the serif textarea token. The narrow layout reduces it to (22px).

The personal editor uses a compact headline (60px), reduced to (48px) at its own breakpoint. Library lines use serif type (24px). Its preview uses (28px), reduced to (20px) above the shared character threshold.

The native app uses SwiftUI semantic text styles. The shared card uses the system serif at `.title2`, with medium weight. Its period label uses `.caption` with medium weight. Its footer uses `.caption`.

### Named Rules

**The Two Type Roles Rule.** Use serif type for website headlines and personal lines. Use plain sans-serif type for website controls and secondary text.

Keep native forms, navigation titles, and library text in the iOS system font. Native semantic styles support Dynamic Type. Do not substitute fixed website sizes for those styles.

The Scriptable card uses Georgia (23 points) for personal text. System labels use semibold type (11 points) and regular footer type (10 points). These sizes belong to the Scriptable route.

## Layout

The website has a centered content boundary (1280px). Desktop page gutters use the page-gutter token. Paired sections use equal columns with the column token. The paired sections include the opening, draft form, setup, and privacy content.

At (800px), gutters reduce to (24px) and paired gaps reduce to the column-compact token. At (580px), gutters reduce to the mobile-gutter token. Paired content stacks in source order. The numbered steps also stack.

The nearby browser preview appears below the line field at the narrow breakpoint. Both previews show the same text and period. The nearby preview keeps the result visible when the user edits a line.

The native app uses three tabs: In sight, Library, and Settings. NavigationStack, List, Form, and sheets set the gaps between native controls. The app preview adds internal padding (20 points) with a minimum height (180 points). The widget supports the medium rectangular family.

The personal editor uses a narrower content boundary (1100px) with desktop gutters (36px). Its flexible editor column sits beside a preview column (340px), with a gap (64px). The preview stays visible with a sticky offset (24px).

At (760px), the personal workspace stacks with a gap (28px) and gutters (22px). The preview appears above the editor and becomes static. Fine rules separate the library, settings, and installation help.

### Named Rules

**The Nearby Preview Rule.** On the product page, keep the browser preview close to the line field on narrow screens. Synchronize its text and period with the opening preview.

This rule applies to the product page with two previews. The personal editor has one preview of saved lines.

## Elevation & Depth

The website uses flat sections, fine borders, and background changes for most depth. The opening widget preview has one soft shadow. The nearby mobile preview removes that shadow. Native lists, sheets, and dialogs keep the depth supplied by iOS.

The personal preview remains flat at all widths. Library rows use bottom rules rather than separate cards.

### Shadow Vocabulary


- **Widget preview shadow** (`0 18px 30px -24px #223b3170`) gives the opening rectangle slight separation from the page.

### Named Rules

**The Quiet Depth Rule.** Use borders and surface colors for separation. Reserve the custom shadow for the opening widget preview.

Website buttons change their background over (150ms). Focus uses an immediate outline. Reduced motion removes transitions and smooth scroll.

## Shapes

Website controls use small rounded corners. The widget preview uses a wider rounded rectangle. Its height stays fixed across text lengths. Text wraps within that boundary, with at most (4 visible lines).

The shared native card also allows (4 lines). Its minimum text scale is (0.65). WidgetKit supplies the native widget boundary. SwiftUI supplies the list row and form shapes. Do not copy the website radius values into native controls.

The Scriptable card permits (4 lines) with a minimum text scale (0.6). Scriptable supplies the rectangular widget boundary.

SVG strokes supply website icons. SF Symbols supply native icons. Numbered circles show the sequence of introductory steps.

## Components

### Buttons

Website primary buttons use an ink background with paper text. Inverse buttons use paper text and a paper border on the setup background. Both variants use the same radius, padding, and hover fill. Their minimum height is (52px).

Text buttons use an underline and a transparent background. Their minimum height is (48px). Disabled buttons reduce opacity to (0.55). The cursor identifies the unavailable state.

### Cards / Containers

The browser preview is the signature card. A period label sits above the line. A short footer sits below it. The text column can shrink within the fixed rectangle.

Long text reduces its size after the character threshold. The website limits visible text to four lines. The native card permits four lines with semantic font scaling.

### Inputs / Fields

Website fields use field paper, a field stroke, and the control radius. Their minimum height is (48px). The user can change the height of the textarea. Custom date fields appear as a pair beneath the period control.

Focus uses an attention outline (3px) with an offset (4px). Invalid fields use the attention border. A text status explains errors, unsaved changes, success, and storage failures. Save progress changes the button label and disables the action.

The native editor uses a Form with a vertical TextField, Picker, DatePicker, and Toggle. Native dialogs confirm discarded changes and deleted lines. Native validation uses visible error text and the system red.

### Navigation

The website header places the brand opposite compact text links. Header links have a minimum height (44px). The first informational link hides at the medium breakpoint. The second hides at the narrow breakpoint. The source link remains visible.

The iPhone app uses native tabs and navigation bars. The line editor appears as a sheet. Native actions use SF Symbols with text labels where the platform control supplies them.

The personal header keeps its widget installation link visible at all widths. Its informational link follows the narrow navigation rule.

### Widget preview

The product page starts with an explicit illustrative line. The website never treats that example as a saved personal record. Text updates use `textContent`. Accessible labels follow the current text. Product preview saves keep a separate local draft.

The native card has explicit empty and storage-failure messages. One accessibility element combines its period, personal line, and footer. The shared card uses the native paper asset in both the app preview and widget.

The personal preview starts empty. Its top row shows the period and optional name. Its footer names the pin state. Its fixed rectangle uses the personal preview variants.

### Personal library

Saved lines use plain rows with serif text above small metadata. Underlined actions wrap beneath each row. The filter separates current records from archived records. Text identifies active periods and pinned lines.

The editor title identifies the empty, add, or edit state. Text statuses announce save results and errors. Disabled actions keep the shared button treatment. Settings and backups use a native disclosure with the attention outline on focus.

### Named Rules

**The Saved Preview Rule.** Show saved lines in the personal preview. Keep unsaved field text in the editor.

**The Written State Rule.** Name the period and pin state with text. Name empty and unavailable states with text.

The Scriptable card uses forest ink and website paper in light appearance. Its dark appearance follows the native paper and ink colors. The optional name joins the period label. The line and footer keep the same hierarchy as the browser preview.

## Do's and Don'ts

### Do:


- **Do** give personal words priority over controls.

- **Do** preserve the fixed rectangle when preview text grows.

- **Do** keep both product-page previews synchronized.

- **Do** keep semantic styles and native controls.

- **Do** explain errors with text as well as color.

- **Do** use SVG icons on the website and SF Symbols in the app.

- **Do** respect the reduced-motion preference on the website.

### Do not:


- **Do not** use textures or invented activity metrics in this direction.

- **Do not** stretch the preview rectangle to fit a long line.

- **Do not** replace native navigation or forms with website components.

- **Do not** treat a labeled example as a personal saved line.

- **Do not** use color as the only state cue.
