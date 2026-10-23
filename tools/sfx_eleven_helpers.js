// wr-sound: ElevenLabs Sound Effects page helpers (paste with Claude-in-Chrome javascript_tool; re-paste after every page load).
// Generation tab = https://elevenlabs.io/app/sound-effects . Keys go through real key presses (computer.key), not JS.
// Throwing on mismatch makes browser_batch stop BEFORE the Enter key, so a wrong prompt/length never generates.
window.__labels = () => ({
  loop: document.querySelector('[data-testid=sfx-loop-button]')?.getAttribute('aria-label'),      // "반복: 꺼짐/켜짐"
  dur: document.querySelector('[data-testid=sfx-duration-button]')?.getAttribute('aria-label'),   // "길이: 3.0초"
  inf: document.querySelector('[data-testid=sfx-influence-button]')?.getAttribute('aria-label'),  // "프롬프트 영향도: 60%"
  ta: document.querySelector('textarea')?.value.slice(0, 60),
});
window.__open1 = (id) => { document.querySelector('[data-testid=' + id + ']').click(); return 'ok'; }; // sfx-loop-button toggles loop
// duration: __open1('sfx-duration-button'); wait 700 ms; __focusSlider(30); then keys Home + ArrowRight x n (n = (sec-0.4)/0.1, max 100 per call); Escape
window.__focusSlider = (max) => { const s = [...document.querySelectorAll('[role=slider]')].find(x => x.getAttribute('aria-valuemax') == String(max)); if (!s) throw new Error('slider none'); s.focus(); return 'focused ' + s.getAttribute('aria-valuenow'); };
window.__fp = () => { const t = document.querySelector('textarea'); t.focus(); if (document.activeElement !== t) throw new Error('ta focus'); return 'ok'; }; // then ctrl+a, type
// open duration (turns the "auto" switch off) / influence and focus their slider; then real keys Home + ArrowRight x n + Escape
window.__durOpen = async () => { __open1('sfx-duration-button'); for (let i=0;i<20 && ![...document.querySelectorAll('[role=slider]')].some(x=>x.getAttribute('aria-valuemax')=='30') && !document.querySelector('[role=switch]');i++) await new Promise(r=>setTimeout(r,150)); const sw=document.querySelector('[role=switch]'); if (sw && sw.getAttribute('aria-checked')==='true') { sw.click(); await new Promise(r=>setTimeout(r,300)); } return __focusSlider(30); };
window.__infOpen = async () => { __open1('sfx-influence-button'); for (let i=0;i<20 && ![...document.querySelectorAll('[role=slider]')].some(x=>x.getAttribute('aria-valuemax')=='1');i++) await new Promise(r=>setTimeout(r,150)); return __focusSlider(1); };
window.__gen2 =(prefix, dur) => { const L = __labels(); const ok = L.ta && L.ta.startsWith(prefix.slice(0, 40)) && L.dur.includes(dur); const b = document.querySelector('[data-testid=sfx-generate-button]'); if (ok) { b.focus(); return 'focused ' + JSON.stringify(L); } document.activeElement?.blur?.(); throw new Error('MISMATCH ' + JSON.stringify(L)); }; // then Enter

// DOWNLOAD — Chrome allows only ONE automatic download per tab (reload does not reset it). So: tabs_create x4, and in each
// new tab navigate to https://elevenlabs.io/app/sound-effects/history[?q=<words>] and run this with k = 0..3 (= #1..#4 of the
// newest group / of the search result), then a real Enter. Close the tabs afterwards.
async function __dlHistory(k, pre) {
  for (let i = 0; i < 40 && document.querySelectorAll('[data-testid=sfx-download-history-group]').length < 4; i++) await new Promise(r => setTimeout(r, 250));
  const d = document.querySelectorAll('[data-testid=sfx-download-history-group]')[k]; if (!d) throw new Error('none');
  let p = d; while (p && p.innerText.length < 120) p = p.parentElement;
  if (!p.innerText.includes(pre)) throw new Error('wrong group: ' + p.innerText.slice(0, 80));
  d.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true, button: 0, pointerType: 'mouse' }));
  await new Promise(r => setTimeout(r, 600));
  const menu = document.querySelector('[role=menu]'); if (!menu) throw new Error('no menu');
  const w = [...menu.querySelectorAll('[role=menuitem]')].find(x => /WAV/i.test(x.innerText)); if (!w) throw new Error('no wav');
  w.focus(); if (document.activeElement !== w) throw new Error('focus fail'); return 'ok'; // then real Enter -> Downloads/<first 20 chars>_#N-<n>.wav
}

// The download helper is also kept in the site's localStorage (key '__wr_dl') so each new tab can load it with
//   eval(localStorage.getItem('__wr_dl')); await __dlHistory(k, '<prompt start>')
// MUSIC page (https://elevenlabs.io/app/music/history), key '__wr_mdl': k = row in the history list (newest = 0)
//   eval(localStorage.getItem('__wr_mdl')); await __mdl(k, '<song title>')   -> then a real Enter (WAV)
async function __mdl(k, title) {
  const rows = () => [...document.querySelectorAll('button[aria-label="다운로드"]')].filter(b => b.offsetParent);
  for (let i = 0; i < 40 && rows().length < 10; i++) await new Promise(r => setTimeout(r, 250));
  const b = rows()[k]; if (!b) throw new Error('none ' + rows().length);
  let p = b; while (p && !(p.innerText || '').includes('노래 편집')) p = p.parentElement;
  const t = (p ? p.innerText : '').split('\n')[0]; if (!t.includes(title)) throw new Error('wrong row: ' + t);
  b.scrollIntoView({ block: 'center' });
  b.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true, button: 0, pointerType: 'mouse' }));
  await new Promise(r => setTimeout(r, 600));
  let w = [...document.querySelectorAll('[role=menuitem]')].find(x => /^WAV/.test(x.innerText.trim()));
  if (!w) { b.click(); await new Promise(r => setTimeout(r, 600)); w = [...document.querySelectorAll('[role=menuitem]')].find(x => /^WAV/.test(x.innerText.trim())); }
  if (!w) throw new Error('no wav'); w.focus(); if (document.activeElement !== w) throw new Error('focus fail'); return 'ok ' + t;
}
