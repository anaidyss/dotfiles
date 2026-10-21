# Fedora logo generator for fastfetch: python3 fedora-logo.py <N>  ->  logo<N>.txt (copy to ~/.config/fastfetch/fedora-veil.txt)
import sys
from PIL import Image, ImageDraw
N=int(sys.argv[1]); S=24; G=24
img=Image.new("L",(N*S,N*S),0); d=ImageDraw.Draw(img)
k=N*S/G; c=N*S/2
def circ(r,fill): d.ellipse([c-r*k,c-r*k,c+r*k,c+r*k],fill=fill)
def rect(x0,y0,x1,y1): d.rectangle([x0*k,y0*k,x1*k,y1*k],fill=255)
circ(11.7,255); circ(8.5,0)                      # ring
# f: stem
rect(10.6,8.0,13.2,17.6)
# hook: arc from the top of the stem to the right and down
d.arc([10.6*k,5.4*k,16.8*k,11.6*k],180,350,fill=255,width=int(2.5*k))
# crossbar
rect(7.8,11.4,15.8,13.8)
# tail loop: goes left-down into the ring
d.line([(11.9*k,17.0*k),(6.0*k,19.4*k)],fill=255,width=int(2.8*k))
d.pieslice([c-13*k,c-13*k,c+13*k,c+13*k],125,150,fill=0)
d.line([(11.9*k,17.0*k),(6.0*k,19.4*k)],fill=255,width=int(2.8*k))
small=img.resize((N,N),Image.BOX)
fill=[[1 if small.getpixel((x,y))>115 else 0 for x in range(N)] for y in range(N)]
def f(x,y): return fill[y][x] if 0<=x<N and 0<=y<N else 0
# shadow: only right/bottom of the OUTER logo outline (+1,+1), nothing drawn inside
def inside(x,y):                        # inside the outer circle
    return (x+0.5-N/2)**2+(y+0.5-N/2)**2 <= (11.7*N/G)**2
shadow=lambda x,y: (not f(x,y)) and f(x-1,y-1) and not inside(x,y)
rows=[]
for cy in range(0,N+1,2):
    line=[]
    for x in range(N+1):
        t,b=f(x,cy),f(x,cy+1)
        st,sb=shadow(x,cy),shadow(x,cy+1)
        if t and b: line.append(("1","█"))
        elif t: line.append(("1","▀"))
        elif b: line.append(("1","▄"))
        elif st or sb: line.append(("2","░"))
        else: line.append(("2"," "))
    rows.append(line)
out=[]
for line in rows:
    s="";cur=None
    for col,ch in line:
        if col!=cur: s+="$"+col; cur=col
        s+=ch
    out.append(s.rstrip())
open(f"logo{N}.txt","w",encoding="utf-8").write("\n".join(out)+"\n")
for line in rows: print("".join(ch for _c,ch in line))
print("cols",N+1,"rows",len(rows))
