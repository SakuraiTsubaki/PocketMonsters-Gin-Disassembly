#!/usr/bin/env python3
"""Extract and cross-version-deduplicate Gen II Pokémon battle sprites."""
from __future__ import annotations
import argparse,csv,hashlib,json,math,struct,zlib
from dataclasses import dataclass
from pathlib import Path
PIC_POINTER_TABLE=0x12*0x4000; PIC_POINTER_SIZE=6
BULBASAUR_NORMAL_MIDDLE=bytes.fromhex('ec2f5f19')
PIC_BANK_FIX={0x13:0x1F,0x14:0x20,0x1F:0x2E}
SPECIES={1:'bulbasaur',2:'ivysaur',3:'venusaur',4:'charmander',5:'charmeleon',6:'charizard',7:'squirtle',8:'wartortle',9:'blastoise',10:'caterpie',11:'metapod',12:'butterfree',13:'weedle',14:'kakuna',15:'beedrill'}
RELEASE_FILES={
 'JP-REV0':'Pocket Monsters Gin (Japan).gbc','JP-REVA':'Pocket Monsters Gin (Japan) (Rev A).gbc',
 'KR-REV0':'Pocket Monsters Eun (Korea).gbc','US-EU-REV0':'Pokemon - Silver Version (USA, Europe).gbc',
 'DE-REV0':'Pokemon - Silberne Edition (Germany).gbc','FR-REV0':'Pokemon - Version Argent (France).gbc',
 'IT-REV0':'Pokemon - Versione Argento (Italy).wbc','ES-REV0':'Pokemon - Edicion Plata (Spain).wbc'}
def sha(b): return hashlib.sha256(b).hexdigest()
def rev8(v): return int(f'{v:08b}'[::-1],2)
def lz3(rom,start):
 out=bytearray(); p=start
 while True:
  c=rom[p]; p+=1
  if c==0xff:return bytes(out),rom[start:p]
  cmd=c>>5
  if cmd==7: cmd=(c>>2)&7; n=(((c&3)<<8)|rom[p])+1; p+=1
  else:n=(c&31)+1
  if cmd==0: out.extend(rom[p:p+n]);p+=n
  elif cmd==1: out.extend([rom[p]]*n);p+=1
  elif cmd==2:
   a,b=rom[p],rom[p+1];p+=2;out.extend(a if i%2==0 else b for i in range(n))
  elif cmd==3: out.extend(b'\0'*n)
  elif cmd in (4,5,6):
   e=rom[p];p+=1
   if e&0x80:s=len(out)-((e&0x7f)+1)
   else:s=(e<<8)|rom[p];p+=1
   for i in range(n): out.append(out[s+i] if cmd==4 else rev8(out[s+i]) if cmd==5 else out[s-i])
  else: raise ValueError(f'unsupported LZ3 command {cmd}')
def off(bank,addr):
 bank=PIC_BANK_FIX.get(bank,bank)
 if not 0x4000<=addr<=0x7fff: raise ValueError(f'invalid ROM address {addr:#x}')
 return bank,bank*0x4000+addr-0x4000
def palbase(rom):
 hits=[];p=0
 while True:
  h=rom.find(BULBASAUR_NORMAL_MIDDLE,p)
  if h<0:break
  hits.append(h);p=h+1
 if len(hits)!=1:raise ValueError(f'palette signature count {len(hits)}')
 return hits[0]
def rgb(v):
 e=lambda c:(c<<3)|(c>>2);return e(v&31),e((v>>5)&31),e((v>>10)&31)
def palette(raw): return [(255,255,255),rgb(int.from_bytes(raw[:2],'little')),rgb(int.from_bytes(raw[2:4],'little')),(0,0,0)]
def render(raw,wtiles):
 count=len(raw)//16
 if count%wtiles:raise ValueError('bad tile geometry')
 htiles=count//wtiles;w=wtiles*8;h=htiles*8;px=bytearray(w*h)
 for i in range(count):
  tx,ty=divmod(i,htiles);tile=raw[i*16:(i+1)*16]
  for y in range(8):
   lo,hi=tile[y*2:y*2+2]
   for x in range(8):
    bit=7-x;px[(ty*8+y)*w+tx*8+x]=((lo>>bit)&1)|(((hi>>bit)&1)<<1)
 return w,h,bytes(px)
def chunk(k,p):return struct.pack('>I',len(p))+k+p+struct.pack('>I',zlib.crc32(k+p)&0xffffffff)
def png(w,h,px,pal):
 sig=b'\x89PNG\r\n\x1a\n';ih=struct.pack('>IIBBBBB',w,h,8,3,0,0,0);pl=b''.join(bytes(c) for c in pal)
 scan=b''.join(b'\0'+px[y*w:(y+1)*w] for y in range(h))
 return sig+chunk(b'IHDR',ih)+chunk(b'PLTE',pl)+chunk(b'IDAT',zlib.compress(scan,9))+chunk(b'IEND',b'')
@dataclass
class Pic:
 release:str;defined:int;actual:int;addr:int;fileoff:int;comp:bytes;dec:bytes;w:int;h:int;px:bytes;normal:bytes;shiny:bytes;pal:bytes
def extract(rom,release,species,side):
 p=PIC_POINTER_TABLE+(species-1)*PIC_POINTER_SIZE;e=rom[p:p+6];i=0 if side=='front' else 3
 defined=e[i];addr=int.from_bytes(e[i+1:i+3],'little');actual,fileoff=off(defined,addr);dec,comp=lz3(rom,fileoff)
 tiles=len(dec)//16
 if side=='front': edge=math.isqrt(tiles); assert edge in (5,6,7) and edge*edge==tiles
 else: edge=6; assert tiles==36
 w,h,px=render(dec,edge);pe=rom[palbase(rom)+(species-1)*8:palbase(rom)+(species-1)*8+8]
 return Pic(release,defined,actual,addr,fileoff,comp,dec,w,h,px,png(w,h,px,palette(pe[:4])),png(w,h,px,palette(pe[4:])),pe)
def ids(text):
 if '-' in text:a,b=map(int,text.split('-',1));return list(range(a,b+1))
 return [int(text)]
def main():
 ap=argparse.ArgumentParser();ap.add_argument('rom_dir',type=Path);ap.add_argument('output_dir',type=Path);ap.add_argument('--species',default='1-15');a=ap.parse_args();want=ids(a.species)
 bad=[i for i in want if i not in SPECIES]
 if bad:raise SystemExit(f'species names not staged yet: {bad}')
 roms={}
 for rel,name in RELEASE_FILES.items():
  path=a.rom_dir/name
  if not path.exists():raise SystemExit(f'missing ROM for {rel}: {path}')
  roms[rel]=path.read_bytes()
 manifest={'schema':1,'batch':f'{min(want):03d}-{max(want):03d}','dedup_policy':'one canonical asset when exact compressed bytes, decoded 2bpp, pixels, and palette are identical across releases','releases':list(RELEASE_FILES),'species':[]};rows=[]
 for sp in want:
  slug=SPECIES[sp];d=a.output_dir/'gfx'/'pokemon'/f'{sp:03d}_{slug}';d.mkdir(parents=True,exist_ok=True);item={'id':sp,'slug':slug,'sprites':{}}
  for side in ('front','back'):
   rs=[extract(roms[r],r,sp,side) for r in RELEASE_FILES]
   groups=({sha(r.comp) for r in rs},{sha(r.dec) for r in rs},{sha(r.px) for r in rs},{sha(r.pal) for r in rs})
   if any(len(g)!=1 for g in groups):raise SystemExit(f'{sp:03d} {side}: release variants exist; use variant paths')
   c=rs[0];(d/f'{side}.2bpp.lz').write_bytes(c.comp);(d/f'{side}.png').write_bytes(c.normal);(d/f'{side}_shiny.png').write_bytes(c.shiny)
   si={'canonical':{'lz_path':f'gfx/pokemon/{sp:03d}_{slug}/{side}.2bpp.lz','normal_png_path':f'gfx/pokemon/{sp:03d}_{slug}/{side}.png','shiny_png_path':f'gfx/pokemon/{sp:03d}_{slug}/{side}_shiny.png','compressed_sha256':sha(c.comp),'decompressed_2bpp_sha256':sha(c.dec),'pixel_index_sha256':sha(c.px),'palette_entry_sha256':sha(c.pal),'compressed_size':len(c.comp),'decompressed_size':len(c.dec),'width':c.w,'height':c.h,'palette_entry_hex':c.pal.hex()},'release_locations':[]}
   for r in rs:
    si['release_locations'].append({'release':r.release,'defined_bank':f'0x{r.defined:02X}','actual_bank':f'0x{r.actual:02X}','address':f'0x{r.addr:04X}','file_offset':f'0x{r.fileoff:06X}','compressed_sha256':sha(r.comp)})
    rows.append({'species':sp,'slug':slug,'side':side,'release':r.release,'defined_bank':f'0x{r.defined:02X}','actual_bank':f'0x{r.actual:02X}','address':f'0x{r.addr:04X}','file_offset':f'0x{r.fileoff:06X}','compressed_size':len(r.comp),'decompressed_size':len(r.dec),'compressed_sha256':sha(r.comp),'decompressed_2bpp_sha256':sha(r.dec)})
   item['sprites'][side]=si
  manifest['species'].append(item)
 ad=a.output_dir/'analysis'/'sprites';ad.mkdir(parents=True,exist_ok=True);batch=f'{min(want):03d}_{max(want):03d}'
 (ad/f'batch_{batch}.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 with (ad/f'batch_{batch}.csv').open('w',encoding='utf-8',newline='') as f:
  w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
if __name__=='__main__':main()
