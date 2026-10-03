// md2docx.js <clean.md> <company-legal.md> <out.docx> <logo.png>
// DOCX renderer for kontrak-finish: same cleaned markdown as the PDF (scripts/clean.sh output).
// Letterhead goes into the document header, signature blocks become real Word tables.
// Needs the npm package docx (preinstalled with the anthropic-skills:docx skill).
const fs=require('fs');
const [,, MD, VAULT, OUT, LOGOARG]=process.argv;
const LOGO=LOGOARG||process.env.KONTRAK_LOGO||'/Users/alisadikin/Drive-D/my-data/INDUSIA/PT/brand-industria-logo.png';
if(!fs.existsSync(LOGO)){console.error('md2docx: logo tidak ditemukan: '+LOGO+' (set KONTRAK_LOGO)');process.exit(2);}
const d=require('docx');
const v=fs.readFileSync(VAULT,'utf8').split('\n');
const bullet=(k)=>{const l=v.find(x=>x.startsWith('- **'+k));if(!l)return '';return l.replace(/^[^:]*\*\*:\s*/,'').replace(/\s*\(.*$/,'');};
const nama=bullet('Nama'),nib=bullet('NIB'),npwp=bullet('NPWP'),sk=bullet('SK Pengesahan'),telp=bullet('Telp'),email=bullet('Email');
const ai=v.findIndex(x=>/^## Alamat/.test(x));const alamat=v.slice(ai+1).find(x=>x.trim());
const merek=bullet('Merek')||nama;
for(const [k,x] of Object.entries({nama,alamat,nib,npwp,sk,telp,email})) if(!x){console.error('missing '+k);process.exit(2);}
const F='Times New Roman';
function runs(s,base={}){const out=[];s.split(/(\*\*[^*]+\*\*)/).forEach(p=>{if(!p)return;
  if(p.startsWith('**'))out.push(new d.TextRun({text:p.slice(2,-2),bold:true,font:F,size:21,...base}));
  else p.split(/<br>/).forEach((q,i)=>out.push(new d.TextRun({text:q,break:i?1:0,font:F,size:21,...base})));});return out;}
const kids=[];const lines=fs.readFileSync(MD,'utf8').split('\n');
const W=9638, border={style:d.BorderStyle.SINGLE,size:4,color:'B8B8B8'};
const borders={top:border,bottom:border,left:border,right:border};
let i=0, first=true;
while(i<lines.length){const l=lines[i];
  if(!l.trim()||/^:::/.test(l)){i++;continue;}
  let m;
  if(m=l.match(/^# (.*)/)){kids.push(new d.Paragraph({heading:d.HeadingLevel.HEADING_1,alignment:d.AlignmentType.CENTER,pageBreakBefore:!first,spacing:{after:120},children:[new d.TextRun({text:m[1],bold:true,font:F,size:28})]}));first=false;i++;continue;}
  if(m=l.match(/^## (.*)/)){kids.push(new d.Paragraph({heading:d.HeadingLevel.HEADING_2,alignment:d.AlignmentType.CENTER,keepNext:true,spacing:{before:300,after:120},children:[new d.TextRun({text:m[1],bold:true,font:F,size:22})]}));i++;continue;}
  if(l.startsWith('|')){const rows=[];while(i<lines.length&&lines[i].startsWith('|')){if(!/^\|[:\-| ]+\|$/.test(lines[i]))rows.push(lines[i].slice(1,-1).split('|').map(c=>c.trim()));i++;}
    const n=rows[0].length,cw=Math.floor(W/n);
    kids.push(new d.Table({width:{size:cw*n,type:d.WidthType.DXA},columnWidths:Array(n).fill(cw),rows:rows.map((r,ri)=>new d.TableRow({cantSplit:true,children:r.map(c=>new d.TableCell({borders,width:{size:cw,type:d.WidthType.DXA},margins:{top:80,bottom:80,left:100,right:100},children:[new d.Paragraph({alignment:d.AlignmentType.CENTER,children:runs(c.replace(/^(<br>)+$/,'<br><br><br><br>'))})]}))}))}));
    kids.push(new d.Paragraph({children:[]}));continue;}
  if(m=l.match(/^(\d+)\. (.*)/)){kids.push(new d.Paragraph({numbering:{reference:'n',level:0},alignment:d.AlignmentType.JUSTIFIED,spacing:{after:100},children:runs(m[2])}));i++;continue;}
  kids.push(new d.Paragraph({alignment:d.AlignmentType.JUSTIFIED,spacing:{after:140,line:300},keepNext:/^\*\*Mengetahui/.test(l)||/^\*\*DEMIKIAN/.test(l),children:runs(l)}));i++;}
const sm={font:'Helvetica',size:15,color:'555555'};
const header=new d.Header({children:[
 new d.Paragraph({children:[new d.ImageRun({type:'png',data:fs.readFileSync(LOGO),transformation:{width:40,height:40}}),new d.TextRun({text:'  '+merek,font:'Helvetica',size:28,color:'16324F'})]}),
 new d.Paragraph({children:[new d.TextRun({text:alamat,...sm})]}),
 new d.Paragraph({children:[new d.TextRun({text:`NIB ${nib} | NPWP ${npwp} | SK Menkumham ${sk}`,...sm})]}),
 new d.Paragraph({border:{bottom:{style:d.BorderStyle.SINGLE,size:12,color:'0F59B6',space:2}},spacing:{after:200},children:[new d.TextRun({text:`Telp. ${telp} | ${email}`,...sm})]})]});
const doc=new d.Document({numbering:{config:[{reference:'n',levels:[{level:0,format:d.LevelFormat.DECIMAL,text:'%1.',alignment:d.AlignmentType.LEFT,style:{paragraph:{indent:{left:540,hanging:360}}}}]}]},
 sections:[{properties:{page:{size:{width:11906,height:16838},margin:{top:1700,bottom:1134,left:1134,right:1134,header:567}}},headers:{default:header},children:kids}]});
d.Packer.toBuffer(doc).then(b=>{fs.writeFileSync(OUT,b);console.log('DOCX',OUT)});
