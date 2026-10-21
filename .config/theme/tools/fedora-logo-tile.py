import sys
# f 13x14 px, drawn by hand; '#' is fill
BM=[
"......########..",
".....##########.",
".....####...####",
".....####....###",
".....####.......",
"..############..",
"..############..",
"..############..",
".....####.......",
".....####.......",
".....####.......",
".....####.......",
".....####.......",
".....####.......",
".....####.......",
".....####.......",
]
H=len(BM); W=len(BM[0])
fill=lambda x,y: 1 if 0<=y<H and 0<=x<W and BM[y][x]=="#" else 0
inner_w=W+2                # 1 margin column on the left, the rest on the right with the shadow
rows=[]
for cy in range(0,H,2):
    line=[]
    for x in range(inner_w):
        px=x-1
        t,b=fill(px,cy),fill(px,cy+1)
        st=(not fill(px,cy)) and fill(px-1,cy-1); sb=(not fill(px,cy+1)) and fill(px-1,cy)
        if t and b: line.append(("1","█"))
        elif t: line.append(("1","▀"))
        elif b: line.append(("1","▄"))
        elif st or sb: line.append(("2","░"))
        else: line.append(("2"," "))
    rows.append(line)
Wf=inner_w+2
title="[ FEDORA ]"
top=[("2","┌─ "),("1",title),("2"," "+"─"*(Wf-3-len(title)-1-1)+"┐")]
bot=[("2","└"+"─"*(Wf-2)+"┘")]
def lines():
    out=[top]
    for r in rows: out.append([("2","│")]+r+[("2","│")])
    out.append(bot); return out
txt=[];prev=[]
for ln in lines():
    s="";cur=None
    for col,chs in ln:
        for ch in chs:
            if col!=cur: s+="$"+col; cur=col
            s+=ch
    txt.append(s.rstrip())
open(sys.argv[1],"w",encoding="utf-8").write("\n".join(txt)+"\n")
for ln in lines(): print("".join(ch for _c,chs in ln for ch in chs))
print("cols",Wf,"rows",len(lines()))
