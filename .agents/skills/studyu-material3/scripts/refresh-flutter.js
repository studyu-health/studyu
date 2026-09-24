#!/usr/bin/env node
/*
 * refresh-flutter.js — validate the handwritten Flutter mapping references against
 * the current Flutter Material API, so the skill does not name classes that no longer exist.
 *
 * api.flutter.dev is server-rendered HTML (no JSON index): the material library index page
 * lists every class as material/<Class>-class.html. This script fetches that index, extracts
 * the class names, and checks that every ``code``-formatted Flutter identifier mentioned in
 * references/flutter/*.md that looks like a widget/class actually exists in the index.
 *
 * Usage:  node scripts/refresh-flutter.js [refsDir]
 *         refsDir default = ../references/flutter relative to this script
 *
 * Exit code 1 if any referenced class is missing. Run after a Flutter SDK bump.
 */
'use strict';
const fs = require('fs');
const path = require('path');
const https = require('https');

const INDEX_URL = 'https://api.flutter.dev/flutter/material/index.html';

function get(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        res.resume();
        return get(new URL(res.headers.location, url).href).then(resolve, reject);
      }
      if (res.statusCode !== 200) { res.resume(); return reject(new Error('HTTP ' + res.statusCode)); }
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    }).on('error', reject);
  });
}

const INDEXES = [
  { url: 'https://api.flutter.dev/flutter/material/index.html', prefix: 'material/' },
  { url: 'https://api.flutter.dev/flutter/widgets/index.html', prefix: 'widgets/' },
  { url: 'https://api.flutter.dev/flutter/services/index.html', prefix: 'services/' },
  { url: 'https://api.flutter.dev/flutter/dart-ui/index.html', prefix: 'dart-ui/' },
  { url: 'https://api.flutter.dev/flutter/animation/index.html', prefix: 'animation/' },
  { url: 'https://api.flutter.dev/flutter/painting/index.html', prefix: 'painting/' },
  // `animations` is a pub.dev package, not a framework library.
  { url: 'https://pub.dev/documentation/animations/latest/animations/animations-library.html', prefix: 'animations/' },
];

// M3 token names (MotionEasing*) are Compose-side identifiers, not Flutter API — they appear in
// backticks but must not be looked up. Members (Curves.easeInOutCubicEmphasized) are checked via
// their owning class. dart:core types (Duration etc.) are not in these indexes.
const SKIP_CLASSES = new Set([
  'MotionEasingEmphasizedAccelerate', 'MotionEasingEmphasizedDecelerate', 'MotionEasingEmphasized',
  'MotionEasingStandard', 'MotionDurationShort1', 'MotionDurationMedium1', 'MotionDurationLong1',
  'MotionDurationExtraLong1', 'Duration', 'Cubic',
]);

async function flutterClasses() {
  const names = new Set();
  for (const { url, prefix } of INDEXES) {
    const html = await get(url);
    const re = new RegExp('href="(?:\\.\\.\\/)?' + prefix.replace('/', '\\/') + '([A-Z][A-Za-z0-9]*)(?:-class)?\\.html"', 'g');
    let m;
    while ((m = re.exec(html))) names.add(m[1]);
  }
  return names;
}

// Identifiers worth checking: UpperCamelCase names that appear inside backticks.
function candidateClasses(md) {
  const out = new Set();
  const re = /`([A-Z][A-Za-z0-9]+)`/g;
  let m;
  while ((m = re.exec(md))) out.add(m[1]);
  return [...out].filter(c => !SKIP_CLASSES.has(c));
}

(async () => {
  const refsDir = path.resolve(process.argv[2] || path.join(__dirname, '../references/flutter'));
  const files = fs.readdirSync(refsDir).filter(f => f.endsWith('.md'));
  const candidates = new Map(); // className -> [files]
  for (const f of files) {
    for (const c of candidateClasses(fs.readFileSync(path.join(refsDir, f), 'utf8'))) {
      if (!candidates.has(c)) candidates.set(c, []);
      candidates.get(c).push(f);
    }
  }

  const classes = await flutterClasses();
  const missing = [...candidates.keys()]
    .filter(c => !classes.has(c))
    // Ignore StudyU app classes (owned by this repo, not Flutter).
    .filter(c => !/^(StudyU|ThemeConfig|ThemeProvider|PrimaryButton|SecondaryButton|TwoColumnLayout|FormScaffold|Hyperlink|EmailTextField|PasswordTextField|CustomColor|StandardDialog|FormTableLayout|FormControlLabel|AuthScaffold|Reactive[A-Z]|CustomSlider|SearchAnchor|DynamicScheme|TextInputAction)/.test(c));

  if (missing.length) {
    for (const c of missing) console.error('MISSING from Flutter material API: ' + c + ' (in ' + candidates.get(c).join(', ') + ')');
    console.error(`checked ${candidates.size} candidate classes against api.flutter.dev; ${missing.length} not found`);
    process.exit(1);
  }
  console.error(`refresh-flutter OK: ${candidates.size} referenced classes all present in Flutter material API (${classes.size} classes indexed)`);
})().catch(e => { console.error('refresh-flutter ERROR: ' + e.message); process.exit(1); });
