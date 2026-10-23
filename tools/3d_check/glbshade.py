"""Shaded (soft-light, smooth-normal) renders of a GLB, to judge form/faceting the way Roblox shows it
(glbrender.py is flat/unlit for colour + flipped-face checks). pp-3d-make 10-19.
  python notes/design/3d_tools/glbshade.py <glb> <out_dir>   -> shade_<view>.png + shade_sheet.png
"""
import sys,os,numpy as np
from PIL import Image
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from glbrender import load,acc,nodemat
def prims(p):
    j,b=load(p);out=[];imgs={}
    import io
    def tex(mi):
        m=j['materials'][mi] if mi is not None else {};pb=m.get('pbrMetallicRoughness',{})
        f=np.array(pb.get('baseColorFactor',[1,1,1,1]))[:3];t=pb.get('baseColorTexture');tex.rough=pb.get('roughnessFactor',1.0) if 'metallicRoughnessTexture' not in pb else 0.5
        if t is None:return f,None
        src=j['textures'][t['index']]['source']
        if src not in imgs:
            im=j['images'][src];bv=j['bufferViews'][im['bufferView']];o=bv.get('byteOffset',0)
            imgs[src]=np.array(Image.open(io.BytesIO(b[o:o+bv['byteLength']])).convert('RGB'))/255.
        return f,imgs[src]
    def walk(ni,M):
        n=j['nodes'][ni];M=M@nodemat(n)
        if 'mesh' in n:
            for pr in j['meshes'][n['mesh']]['primitives']:
                A=pr['attributes'];pos=acc(j,b,A['POSITION']).astype(float);pos=(np.c_[pos,np.ones(len(pos))]@M.T)[:,:3]
                idx=acc(j,b,pr['indices']).reshape(-1,3).astype(int) if 'indices' in pr else np.arange(len(pos)).reshape(-1,3)
                uv=acc(j,b,A['TEXCOORD_0']).astype(float) if 'TEXCOORD_0' in A else np.zeros((len(pos),2))
                if 'NORMAL' in A: nr=acc(j,b,A['NORMAL']).astype(float)@M[:3,:3].T
                else:
                    nr=np.zeros_like(pos)
                    for t in idx: nr[t]+=np.cross(pos[t[1]]-pos[t[0]],pos[t[2]]-pos[t[0]])
                nr/=np.linalg.norm(nr,axis=1,keepdims=True)+1e-12
                f,t=tex(pr.get('material'));out.append((pos,idx,uv,nr,f,t,tex.rough))
        for c in n.get('children',[]):walk(c,M)
    for s in j['scenes'][j.get('scene',0)]['nodes']:walk(s,np.eye(4))
    return out
V={'front':(0,0,1),'back':(0,0,-1),'left':(1,0,0),'right':(-1,0,0),'top':(0,-1,0),'bottom':(0,1,0),'threeq':(-1,-1,1)}
def render(P,view,N=768,pad=0.08,ext=None):
    f=np.array(V[view],float);f/=np.linalg.norm(f);up=np.array([0,1,0.]) if view not in('top','bottom') else np.array([0,0,1.] if view=='top' else [0,0,-1.])
    r=np.cross(f,up);r/=np.linalg.norm(r);u=np.cross(r,f)
    L=-f*0.6+u*0.6-r*0.4;L/=np.linalg.norm(L)  # light from camera side, above, left
    allp=np.vstack([p[0] for p in P]);X=allp@r;Y=allp@u
    if ext is None:ext=max(X.max()-X.min(),Y.max()-Y.min())
    cx=(X.max()+X.min())/2;cy=(Y.max()+Y.min())/2;sc=N*(1-2*pad)/ext
    img=np.full((N,N,3),0.93);zb=np.full((N,N),1e9)
    for pos,idx,uv,nr,fac,tx,rough in P:
        sx=(pos@r-cx)*sc+N/2;sy=N/2-(pos@u-cy)*sc;sz=pos@f
        for t in idx:
            a,b_,c=t;x0,y0,x1,y1,x2,y2=sx[a],sy[a],sx[b_],sy[b_],sx[c],sy[c]
            area=(x1-x0)*(y2-y0)-(x2-x0)*(y1-y0)
            if abs(area)<1e-9:continue
            mnx=max(int(min(x0,x1,x2)),0);mxx=min(int(max(x0,x1,x2))+1,N-1);mny=max(int(min(y0,y1,y2)),0);mxy=min(int(max(y0,y1,y2))+1,N-1)
            if mxx<mnx or mxy<mny:continue
            gx,gy=np.meshgrid(np.arange(mnx,mxx+1)+.5,np.arange(mny,mxy+1)+.5)
            w0=((x1-gx)*(y2-gy)-(x2-gx)*(y1-gy))/area;w1=((x2-gx)*(y0-gy)-(x0-gx)*(y2-gy))/area;w2=1-w0-w1
            m=(w0>=-1e-6)&(w1>=-1e-6)&(w2>=-1e-6)
            if not m.any():continue
            z=w0*sz[a]+w1*sz[b_]+w2*sz[c]
            if np.cross(pos[b_]-pos[a],pos[c]-pos[a])@f>0:
                col=np.broadcast_to(np.array([1,0,1.]),gx.shape+(3,))
            else:
                if tx is None: base=np.broadcast_to(fac,gx.shape+(3,))
                else:
                    U=w0*uv[a,0]+w1*uv[b_,0]+w2*uv[c,0];Vv=w0*uv[a,1]+w1*uv[b_,1]+w2*uv[c,1];h,w_=tx.shape[:2]
                    base=tx[np.clip((Vv*h).astype(int),0,h-1),np.clip((U*w_).astype(int),0,w_-1)]*fac
                n=w0[...,None]*nr[a]+w1[...,None]*nr[b_]+w2[...,None]*nr[c];n/=np.linalg.norm(n,axis=-1,keepdims=True)+1e-12
                d=np.clip(n@L,0,1);rim=np.clip(-(n@f),0,1)
                H=L-f;H/=np.linalg.norm(H);sh=2/max(rough,0.05)**4;sp=(1-rough)**2*np.clip(n@H,0,1)**min(sh,400)
                col=base*(0.45+0.6*d[...,None])+sp[...,None]*0.9
            sub=zb[mny:mxy+1,mnx:mxx+1];upd=m&(z<sub);sub[upd]=z[upd];img[mny:mxy+1,mnx:mxx+1][upd]=np.clip(col[upd],0,1)
    return (img*255).astype(np.uint8),ext
if __name__=='__main__':
    g,o=sys.argv[1],sys.argv[2];os.makedirs(o,exist_ok=True);P=prims(g);ext=None;ims=[]
    for v in ['front','back','left','right','top','bottom','threeq']:
        im,e=render(P,v,ext=ext);ext=ext or e;Image.fromarray(im).save(os.path.join(o,f'shade_{v}.png'));ims.append(im)
    s=768;sheet=Image.new('RGB',(s*4,s*2),(255,255,255))
    for i,im in enumerate(ims):sheet.paste(Image.fromarray(im),((i%4)*s,(i//4)*s))
    sheet.save(os.path.join(o,'shade_sheet.png'));print('ok',o)
