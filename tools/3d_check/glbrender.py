import struct,json,sys,io,os,numpy as np
from PIL import Image
def load(p):
    d=open(p,'rb').read();off=12;ch=[]
    while off<len(d):
        l,t=struct.unpack('<I4s',d[off:off+8]);ch.append(d[off+8:off+8+l]);off+=8+l
    return json.loads(ch[0]),ch[1]
CM={5126:'<f4',5123:'<u2',5125:'<u4',5121:'u1',5122:'<i2'};NT={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}
def acc(j,b,i):
    a=j['accessors'][i];bv=j['bufferViews'][a['bufferView']];n=NT[a['type']]
    o=bv.get('byteOffset',0)+a.get('byteOffset',0);dt=np.dtype(CM[a['componentType']])
    st=bv.get('byteStride')
    if st and st!=dt.itemsize*n:
        raw=np.frombuffer(b,dtype='u1',count=st*a['count'],offset=o).reshape(a['count'],st)[:,:dt.itemsize*n].copy()
        return raw.view(dt).reshape(a['count'],n)
    return np.frombuffer(b,dtype=dt,count=a['count']*n,offset=o).reshape(a['count'],n)
def nodemat(n):
    if 'matrix' in n: return np.array(n['matrix']).reshape(4,4).T
    T=np.eye(4);S=np.eye(4);R=np.eye(4)
    if 'translation' in n:T[:3,3]=n['translation']
    if 'scale' in n:S[0,0],S[1,1],S[2,2]=n['scale']
    if 'rotation' in n:
        x,y,z,w=n['rotation'];R[:3,:3]=[[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]]
    return T@R@S
def tris(p):
    j,b=load(p);imgs={}
    def tex(mi):
        m=j['materials'][mi] if mi is not None else {};pb=m.get('pbrMetallicRoughness',{})
        f=np.array(pb.get('baseColorFactor',[1,1,1,1]))[:3]
        t=pb.get('baseColorTexture')
        if t is None:return f,None
        src=j['textures'][t['index']]['source']
        if src not in imgs:
            im=j['images'][src];bv=j['bufferViews'][im['bufferView']]
            imgs[src]=np.array(Image.open(io.BytesIO(b[bv.get('byteOffset',0):bv.get('byteOffset',0)+bv['byteLength']])).convert('RGB'))/255.
        return f,imgs[src]
    out=[]
    def walk(ni,M):
        n=j['nodes'][ni];M=M@nodemat(n)
        if 'mesh' in n:
            for pr in j['meshes'][n['mesh']]['primitives']:
                pos=acc(j,b,pr['attributes']['POSITION']).astype(float);pos=(np.c_[pos,np.ones(len(pos))]@M.T)[:,:3]
                idx=acc(j,b,pr['indices']).reshape(-1,3) if 'indices' in pr else np.arange(len(pos)).reshape(-1,3)
                uv=acc(j,b,pr['attributes']['TEXCOORD_0']).astype(float) if 'TEXCOORD_0' in pr['attributes'] else np.zeros((len(pos),2))
                f,t=tex(pr.get('material'));out.append((pos,idx.astype(int),uv,f,t,n.get('name','')))
        for c in n.get('children',[]):walk(c,M)
    for s in j['scenes'][j.get('scene',0)]['nodes']:walk(s,np.eye(4))
    return out
def render(prims,view,N=1024,pad=0.1,ext=None):
    fw={'front':(0,0,1),'back':(0,0,-1),'left':(1,0,0),'right':(-1,0,0),'top':(0,-1,0),'bottom':(0,1,0),'threeq':(-1,-1,1)}[view]
    f=np.array(fw,float);f/=np.linalg.norm(f);up=np.array([0,1,0.]) if view not in('top','bottom') else np.array([0,0,1.] if view=='top' else [0,0,-1.])
    r=np.cross(f,up);r/=np.linalg.norm(r);u=np.cross(r,f)
    allp=np.vstack([p[0] for p in prims]);X=allp@r;Y=allp@u
    if ext is None:ext=max(X.max()-X.min(),Y.max()-Y.min())
    cx=(X.max()+X.min())/2;cy=(Y.max()+Y.min())/2;sc=N*(1-2*pad)/ext
    img=np.ones((N,N,3));zb=np.full((N,N),1e9)
    for pos,idx,uv,fac,tx,_ in prims:
        sx=(pos@r-cx)*sc+N/2;sy=N/2-(pos@u-cy)*sc;sz=pos@f
        for t in idx:
            a,b_,c=t;x0,y0,x1,y1=sx[a],sy[a],sx[b_],sy[b_];x2,y2=sx[c],sy[c]
            area=(x1-x0)*(y2-y0)-(x2-x0)*(y1-y0)
            if abs(area)<1e-9:continue
            mnx=max(int(min(x0,x1,x2)),0);mxx=min(int(max(x0,x1,x2))+1,N-1);mny=max(int(min(y0,y1,y2)),0);mxy=min(int(max(y0,y1,y2))+1,N-1)
            if mxx<mnx or mxy<mny:continue
            gx,gy=np.meshgrid(np.arange(mnx,mxx+1)+.5,np.arange(mny,mxy+1)+.5)
            w0=((x1-gx)*(y2-gy)-(x2-gx)*(y1-gy))/area;w1=((x2-gx)*(y0-gy)-(x0-gx)*(y2-gy))/area;w2=1-w0-w1
            m=(w0>=-1e-6)&(w1>=-1e-6)&(w2>=-1e-6)
            if not m.any():continue
            z=w0*sz[a]+w1*sz[b_]+w2*sz[c]
            # geometric normal facing: 3D normal vs view dir
            n3=np.cross(pos[b_]-pos[a],pos[c]-pos[a]);facing=n3@f  # <0 means front-facing (normal toward camera)
            back=facing>0
            if back: col=np.broadcast_to(np.array([1,0,1.]),gx.shape+(3,))
            elif tx is None: col=np.broadcast_to(fac,gx.shape+(3,))
            else:
                U=w0*uv[a,0]+w1*uv[b_,0]+w2*uv[c,0];V=w0*uv[a,1]+w1*uv[b_,1]+w2*uv[c,1]
                h,w_=tx.shape[:2];col=tx[np.clip((V*h).astype(int),0,h-1),np.clip((U*w_).astype(int),0,w_-1)]*fac
            sub=zb[mny:mxy+1,mnx:mxx+1];upd=m&(z<sub)
            sub[upd]=z[upd];img[mny:mxy+1,mnx:mxx+1][upd]=col[upd]
    return (img*255).astype(np.uint8),ext
if __name__=='__main__':
    p=sys.argv[1];od=sys.argv[2];os.makedirs(od,exist_ok=True);pr=tris(p)
    ext=None
    for v in ['front','back','left','right','top','bottom','threeq']:
        im,e=render(pr,v,ext=ext);ext=ext or e if v!='threeq' else ext
        Image.fromarray(im).save(f'{od}/{v}.png')
    # stats
    allp=np.vstack([q[0] for q in pr]);print('tris',sum(len(q[1]) for q in pr),'bbox',allp.min(0).round(3),allp.max(0).round(3),'size',(allp.max(0)-allp.min(0)).round(3))
