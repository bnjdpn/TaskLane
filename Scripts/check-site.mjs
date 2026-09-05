import {readFile,access} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
const docs=resolve(dirname(fileURLToPath(import.meta.url)),'../docs');
const errors=[];let links=0;
for(const [p,lang] of [['index.html','en'],['fr/index.html','fr']]){
 const html=await readFile(resolve(docs,p),'utf8');
 const check=(v,m)=>{if(!v)errors.push(p+': '+m)};
 check(html.includes(`<html lang="${lang}">`),'language');
 check((html.match(/<h1>/g)||[]).length===1,'one H1');
 check(html.includes('macOS 15')&&!html.includes('Requires macOS 14'),'binary compatibility');
 check(html.includes('releases/tag/v0.5.0'),'verified public release');
 check(html.includes(lang==='fr'?'n’est pas notariée':'not notarized'),'notarization caveat');
 check(html.includes('hreflang="en"')&&html.includes('hreflang="fr"'),'language alternates');
 check(html.includes('rel="canonical"'),'canonical');
 check((html.match(/<details/g)||[]).length===5,'FAQ coverage');
 check(html.includes('id="privacy"')&&html.includes('id="support"'),'privacy/support');
 check(!html.includes('data-en=')&&!html.includes('localStorage'),'static language rendering');
 check(!html.includes('images/screenshot.png'),'old illustration must not masquerade as screenshot');
 for(const m of html.matchAll(/<img[^>]+>/g))check(/width="\d+"/.test(m[0])&&/height="\d+"/.test(m[0])&&/alt="/.test(m[0]),'image dimensions/alt');
 const ids=[...html.matchAll(/ id="([^"]+)"/g)].map(m=>m[1]);
 for(const m of html.matchAll(/href="#([^"]+)"/g))check(ids.includes(m[1]),'anchor '+m[1]);
 for(const m of html.matchAll(/(?:href|src)="([^"#]+)"/g)){
  if(/^https?:/.test(m[1]))continue;
  let path=resolve(dirname(resolve(docs,p)),m[1]);if(m[1].endsWith('/'))path+='/index.html';
  try{await access(path);links++}catch{errors.push(p+': missing '+m[1])}
 }
 JSON.parse(html.match(/<script type="application\/ld\+json">(.*?)<\/script>/s)[1]);
}
const css=await readFile(resolve(docs,'assets/css/style.css'),'utf8');
if(!css.includes('focus-visible')||!css.includes('prefers-reduced-motion'))errors.push('Keyboard/reduced motion styles');
if((await readFile(resolve(docs,'sitemap.xml'),'utf8')).match(/<url>/g)?.length!==2)errors.push('Sitemap languages');
if(errors.length){console.error(errors.join('\n'));process.exit(1)}
console.log(`✓ TaskLane EN/FR, five FAQs, released-binary caveats, native capture references and ${links} local links`);
