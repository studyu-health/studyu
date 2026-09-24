#!/usr/bin/env node
/*
 * refresh-material-refs.js — consolidate raw m3.material.io scrapes into the
 * StudyU Material 3 skill's generated references under references/material/.
 *
 * Pipeline (one command from the skill root):
 *   1. node scripts/refresh-m3.js pages <tmp>     (vendored: scrapes all 76 guidance pages (the remaining ~15 are platform/dev/blog/index pages — intentionally excluded))
 *   2. node scripts/refresh-material-refs.js       (this: groups by category)
 *   3. node scripts/refresh-component-tokens.js    (vendored: numeric dp/sp geometry)
 *
 * Usage:
 *   node scripts/refresh-material-refs.js [scrapeDir] [outDir]
 *     scrapeDir default: ../.build/m3-pages   (relative to this script)
 *     outDir    default: ../references/material
 *
 * Raw pages are grouped into the reference files SKILL.md routes to. Each page
 * carries a source header (slug + updated timestamp) so every regeneration is
 * traceable. Material Design content is CC-BY 4.0 (Google) — see NOTICE.md.
 */
'use strict';
const fs = require('fs');
const path = require('path');

const here = __dirname;
const scrapeDir = path.resolve(process.argv[2] || path.join(here, '../.build/m3-pages'));
const outDir = path.resolve(process.argv[3] || path.join(here, '../references/material'));

// Category -> list of raw page slugs (filename stem after the group prefix).
const CATEGORIES = {
  'foundations.md': [
    'foundations.md', 'foundations_overview', 'foundations_designing', 'foundations_design-tokens',
    'foundations_glossary', 'foundations_customization', 'foundations_writing',
    'foundations_content-design_overview', 'foundations_content-design_global-writing',
    'foundations_content-design_style-guide', 'styles_spacing', 'styles_elevation', 'styles_icons',
  ],
  'layout.md': [
    'foundations_layout_layout-overview', 'foundations_layout_breakpoints', 'foundations_layout_grids-spacing',
    'foundations_layout_scaffold', 'foundations_layout_canonical-examples', 'foundations_layout_bidirectionality-rtl',
  ],
  'interaction.md': [
    'foundations_interaction_states', 'foundations_interaction_gestures',
    'foundations_interaction_inputs', 'foundations_interaction_selection',
  ],
  'accessibility.md': [
    'foundations_building-for-all', 'foundations_usability',
    'foundations_content-design_alt-text', 'foundations_content-design_notifications',
  ],
  'color.md': [
    'styles_color_system', 'styles_color_roles', 'styles_color_choosing-a-scheme',
    'styles_color_static', 'styles_color_dynamic', 'styles_color_advanced', 'styles_color_resources',
  ],
  'typography.md': ['styles_typography'],
  'shape.md': ['styles_shape'],
  'motion.md': ['styles_motion_overview', 'styles_motion_easing-and-duration', 'styles_motion_transitions'],
  'components/buttons.md': [
    'components_all-buttons', 'components_buttons', 'components_button-groups', 'components_icon-buttons',
    'components_segmented-buttons', 'components_split-button', 'components_floating-action-button',
    'components_extended-fab', 'components_fab-menu',
  ],
  'components/input.md': [
    'components_text-fields', 'components_checkbox', 'components_radio-button', 'components_switch',
    'components_sliders', 'components_chips', 'components_search', 'components_date-pickers', 'components_time-pickers',
  ],
  'components/navigation.md': [
    'components_navigation-bar', 'components_navigation-rail', 'components_navigation-drawer', 'components_tabs',
  ],
  'components/containment.md': [
    'components_cards', 'components_carousel', 'components_lists', 'components_bottom-sheets',
    'components_side-sheets', 'components_dialogs', 'components_divider',
  ],
  'components/feedback.md': [
    'components_snackbar', 'components_tooltips', 'components_badges', 'components_menus',
    'components_progress-indicators', 'components_loading-indicator',
  ],
  'components/bars.md': ['components_app-bars', 'components_toolbars'],
};

const uniq = xs => [...new Set(xs)];
const read = p => { try { return fs.readFileSync(p, 'utf8'); } catch { return null; } };

function stripScrapeNoise(md) {
  // Raw pages repeat the description at top and carry sparse "<undefined>" artefacts.
  return md
    .replace(/^> .*\n/s, '')
    .replace(/<(?:undefined|br)\s*\/?>/gi, '')
    .replace(/&undefined;/g, '');
}

function pageHeader(slug, md) {
  const m = md.match(/updated: ([0-9T:.Z-]+)/);
  return `Source: m3.material.io · ${slug} · updated ${m ? m[1] : '?'} · CC-BY 4.0 (Google)`;
}

function build() {
  const missing = [];
  const material = new Map();
  for (const slugs of Object.values(CATEGORIES)) {
    for (const slug of uniq(slugs)) {
      const fname = slug.endsWith('.md') ? slug : slug + '.md';
      const raw = read(path.join(scrapeDir, fname));
      if (!raw) missing.push(slug);
      else material.set(slug, raw);
    }
  }
  if (missing.length) {
    throw new Error(
      `refusing to overwrite generated references: ${missing.length} required scraped page(s) missing from ${scrapeDir}: ${missing.join(', ')}`,
    );
  }

  fs.mkdirSync(outDir, { recursive: true });
  let total = 0;
  for (const [rel, slugs] of Object.entries(CATEGORIES)) {
    const parts = [];
    for (const slug of uniq(slugs)) {
      const raw = material.get(slug);
      const body = stripScrapeNoise(raw);
      // Promote each page's H1 to H2 and drop its metadata line so it nests under the category title.
      const cleaned = body.replace(/^# (.+)$/m, '## $1').replace(/^slug: .*$/m, '').trim();
      parts.push(`<!-- ${pageHeader(slug, raw)} -->\n\n${cleaned}`);
      total++;
    }
    const out = path.join(outDir, rel);
    fs.mkdirSync(path.dirname(out), { recursive: true });
    const title = path.basename(rel, '.md').replace(/^./, c => c.toUpperCase());
    fs.writeFileSync(out, `# Material 3 · ${title}\n\n${parts.join('\n\n---\n\n')}\n`);
  }
  console.error(`consolidated ${total} pages into ${Object.keys(CATEGORIES).length} reference files`);
}

build();
