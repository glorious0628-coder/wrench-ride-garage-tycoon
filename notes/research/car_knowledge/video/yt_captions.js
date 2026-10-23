// wr-carbook: 유튜브 자막 전부 읽기 (내장 브라우저 javascript_tool에 그대로 붙여 넣기)
// 쓰는 법: 영상 페이지로 navigate → 이 글 전체 실행 → `await ttLoad()` → `ttText('<videoId>', 0, 1e9, 30)`
// 광고 중이면 ttLoad가 'AD'를 돌려줌 → find "건너뛰기" 클릭 → 다시 ttLoad. 페이지를 옮기면 다시 실행.
// 플레이어가 스스로 받아 온 자막(/api/timedtext json3)을 저장해 읽을 뿐 — 봇 확인 우회 X.
window.ttCap = window.ttCap || {};
if (!window.__ttHooked) { window.__ttHooked = true;
  const of = window.fetch; window.fetch = async function(...a){ const r = await of.apply(this,a); try{ const u = (a[0] && a[0].url) || String(a[0]); if (u.includes('/api/timedtext')) { r.clone().text().then(t=>{ window.ttCap[new URL(u, location.href).searchParams.get('v')] = t; }); } }catch(e){} return r; };
  const oo = XMLHttpRequest.prototype.open; XMLHttpRequest.prototype.open = function(m,u,...rest){ this.__u = u; return oo.call(this,m,u,...rest); };
  const os = XMLHttpRequest.prototype.send; XMLHttpRequest.prototype.send = function(...a){ this.addEventListener('load', ()=>{ try{ if (String(this.__u).includes('/api/timedtext')) window.ttCap[new URL(this.__u, location.href).searchParams.get('v')] = this.responseText; }catch(e){} }); return os.apply(this,a); };
}
// from~to 초 사이 자막을 gap초 묶음으로 "[초] 문장" 줄로
window.ttText = (vid, from=0, to=1e9, gap=20) => { const j = JSON.parse(ttCap[vid]); const out=[]; let lastT=-99; let buf=''; for (const e of j.events||[]) { if(!e.segs) continue; const t=e.tStartMs/1000; if(t<from||t>to) continue; const s=e.segs.map(x=>x.utf8).join('').replace(/\n/g,' ').trim(); if(!s) continue; if(t-lastT>=gap){ if(buf) out.push(buf); buf='['+Math.floor(t)+'] '+s; lastT=t; } else buf+=' '+s; } if(buf) out.push(buf); return out.join('\n'); };
// 재생(광고 30초까지 기다림) → 자막 모듈 껐다 켜서 플레이어가 자막을 다시 받게 함
window.ttLoad = async () => { const p=document.querySelector('#movie_player'); const v=document.querySelector('video'); v.muted=true; v.play(); for (let i=0;i<30 && p.classList.contains('ad-showing');i++) await new Promise(r=>setTimeout(r,1000)); if (p.classList.contains('ad-showing')) return 'AD'; try{p.unloadModule('captions')}catch(e){} await new Promise(r=>setTimeout(r,500)); try{p.loadModule('captions'); p.setOption('captions','track',{languageCode:'en'})}catch(e){} await new Promise(r=>setTimeout(r,4000)); v.pause(); return Object.keys(ttCap); };
// 장면 보기: await seek(초) → computer zoom
window.seek = async (s) => { const v=document.querySelector('video'); v.muted=true; v.pause(); v.currentTime=s; await new Promise(r=>setTimeout(r,1800)); return {t:v.currentTime, ad:document.querySelector('#movie_player').classList.contains('ad-showing')}; };
// 검색: await ytSearch('검색어') → id 목록, await ytInfo(id) → 제목·채널·길이·조회수·자막 언어(caps, 빈칸 = 자막 없음)
window.ytInfo = async (id) => { const h = await (await fetch('/watch?v='+id+'&hl=en')).text(); const m = h.match(/ytInitialPlayerResponse\s*=\s*(\{.+?\});(?:var|<\/script>)/s); if(!m) return {id, err:'no'}; const j = JSON.parse(m[1]); const d = j.videoDetails; const caps = (j.captions?.playerCaptionsTracklistRenderer?.captionTracks||[]).map(c=>c.languageCode+(c.kind?'-'+c.kind:'')).join(','); return {id, t:d.title, ch:d.author, len:d.lengthSeconds, views:d.viewCount, caps}; };
// 쇼츠·작은 영상: 창이 작아 영상이 손톱만 함 → big()으로 영상만 화면 가득(보기용 스타일만) → screenshot
window.big = () => { const v=document.querySelector('video'); Object.assign(v.style,{position:'fixed',top:'0',left:'0',width:'100vw',height:'100vh',zIndex:'2147483647',background:'black',objectFit:'contain'}); };
window.ytSearch = async (q) => { const h = await (await fetch('/results?search_query='+encodeURIComponent(q)+'&hl=en')).text(); return [...new Set([...h.matchAll(/"videoId":"([\w-]{11})"/g)].map(x=>x[1]))].slice(0,8); };
'ok';
