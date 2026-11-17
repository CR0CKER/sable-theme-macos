# px.py <png> <y> <x0> <x1> — print RGB of a screenshot row between x0 and x1
# (device pixels; Sable screenshots are 2x). Dependency-free PNG reader.
import sys, zlib, struct
def load(p):
    d=open(p,'rb').read(); pos=8; idat=b''
    while pos<len(d):
        n,t=struct.unpack('>I4s',d[pos:pos+8]); c=d[pos+8:pos+8+n]; pos+=12+n
        if t==b'IHDR': w,h,bd,ct=struct.unpack('>IIBB',c[:10])
        elif t==b'IDAT': idat+=c
    raw=zlib.decompress(idat); bpp=4 if ct==6 else 3; stride=w*bpp; rows=[]; prev=bytearray(stride); i=0
    for y in range(h):
        f=raw[i]; i+=1; line=bytearray(raw[i:i+stride]); i+=stride
        for x in range(stride):
            a=line[x-bpp] if x>=bpp else 0; b=prev[x]; c=prev[x-bpp] if x>=bpp else 0
            if f==1: line[x]=(line[x]+a)&255
            elif f==2: line[x]=(line[x]+b)&255
            elif f==3: line[x]=(line[x]+(a+b)//2)&255
            elif f==4:
                pa,pb,pc=abs(b-c),abs(a-c),abs(a+b-2*c); pr=a if pa<=pb and pa<=pc else (b if pb<=pc else c); line[x]=(line[x]+pr)&255
        rows.append(line); prev=line
    return w,h,bpp,rows
w,h,bpp,rows=load(sys.argv[1]); y=int(sys.argv[2])
for x in range(int(sys.argv[3]),int(sys.argv[4])):
    print(x, tuple(rows[y][x*bpp:x*bpp+3]))
