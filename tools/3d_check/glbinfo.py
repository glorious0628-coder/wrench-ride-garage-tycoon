import struct,json,sys,numpy as np
p=sys.argv[1]
d=open(p,'rb').read()
magic,ver,ln=struct.unpack('<4sII',d[:12]);off=12
chunks=[]
while off<len(d):
    l,t=struct.unpack('<I4s',d[off:off+8]);chunks.append((t,d[off+8:off+8+l]));off+=8+l
j=json.loads(chunks[0][1]);b=chunks[1][1]
print('ver',ver,'meshes',len(j['meshes']),'materials',len(j.get('materials',[])),'images',len(j.get('images',[])),'nodes',j['nodes'])
print(json.dumps(j['materials'],ensure_ascii=False)[:600])
cm={5126:('f',4),5123:('H',2),5125:('I',4)}
nt={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}
def acc(i):
    a=j['accessors'][i];bv=j['bufferViews'][a['bufferView']]
    fmt,sz=cm[a['componentType']];n=nt[a['type']]
    o=bv.get('byteOffset',0)+a.get('byteOffset',0)
    arr=np.frombuffer(b,dtype={'f':'<f4','H':'<u2','I':'<u4'}[fmt],count=a['count']*n,offset=o).reshape(a['count'],n)
    return arr
tot=0
for m in j['meshes']:
    for pr in m['primitives']:
        pos=acc(pr['attributes']['POSITION']);idx=acc(pr['indices']).reshape(-1,3)
        print('prim verts',len(pos),'tris',len(idx),'min',pos.min(0),'max',pos.max(0),'size',pos.max(0)-pos.min(0),'center',(pos.max(0)+pos.min(0))/2)
        tot+=len(idx)
        uv=acc(pr['attributes']['TEXCOORD_0']);print('uv range',uv.min(0),uv.max(0))
print('tris',tot)
for n in j['nodes']:print(n)
for im in j.get('images',[]):
    bv=j['bufferViews'][im['bufferView']];data=b[bv.get('byteOffset',0):bv.get('byteOffset',0)+bv['byteLength']]
    open('dotbox_tex.png','wb').write(data);print('tex bytes',len(data))
