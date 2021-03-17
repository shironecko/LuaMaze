--listbox by Luiz Renato @darkmetalic v1.0 for LÖVE2D 0.10+
-- https://github.com/darkmetalic/ListBox

--Default values
local listbox={
x=100,y=100, -- listbox position x,y (number)
w=200,h=400, -- listbox size Width x Height (number)
hor=true,ver=true, -- Show scroller Horizontal and Vertical (boolean)
sort=false, -- sort mode: string "asc" or "desc" or boolean true(asc) or false(disabled)
enabled=true, -- enable or disable the listbox, it remains visible, but does not interact (boolean)
visible=true, -- visible or invisible, the listbox may interact invisibly if it is not disabled
adjust=true, -- adjuste (boolean)
rounded=false, -- rounded rectangle (boolean)
expand=false, -- expand the listbox (boolean)
expandmode="size", -- expand mode: size true (boolean|string) or position "pos" (string)
expx=12, -- expand pixels (number)
radius=15, -- scroll ball size/radius (number)
sep=";;", -- separator that limits where the text ends and the data starts in the index (string)
ismouse=true, -- if you will use mouse (boolean)
istouch=false, -- if you will use touches (boolean)
gw = love.graphics.getWidth(), -- first Width captured to resize, do not works if you confugured(conf.lua) in fullscreen (or set gw)
gh = love.graphics.getHeight(), -- first Height captured to resize, do not works if you confugured(conf.lua) in fullscreen (or set gh)
incenter=false, -- in center of screen (boolean)
asize=false, -- auto size the listbox (boolean)
font = love.graphics.newFont(12), -- listbox font (object)
fcolor={0,190,0}, -- font color RGB (table)
bordercolor={50,50,50}, -- border color RGB (table)
selectedcolor={50,50,50}, -- selected color RGB (table)
fselectedcolor={200,200,200}, -- font selected color RGB (table)
selectedtip="fill", -- selected mode "fill" or "line" (string)
bgcolor={20,20,20}, -- background selected color RGB (table)
showindex=false, -- show index (boolean)
indexzeros=1, -- index left zeros (number)
selected=false, -- first index selected (number) or (false) none
gpadding=5 -- global padding (number)
}

function listbox:newprop(tlist)
for new, value in pairs(tlist) do self[new]=value end

listbox.ispress=false
listbox.over=false

listbox.rsize = self.rounded and 10 or 0

listbox.defw=self.w
listbox.defh=self.h
listbox.defx=self.x
listbox.defy=self.y

listbox.time=0
listbox.ptime=0
listbox.dtime=0
listbox.isdouble=false
listbox.count=0
listbox.tmpselected=0

listbox.paddingsc=10
listbox.scrypos=self.y
listbox.scrvw=self.radius+listbox.paddingsc
listbox.scrvx=self.x+self.w
listbox.scrvh=self.radius+listbox.paddingsc
listbox.scrvy=self.y+self.scrvh

listbox.scrhpos=self.w
listbox.scrhw=self.radius+listbox.paddingsc
listbox.scrhx=self.x
listbox.scrhh=self.radius+listbox.paddingsc
listbox.scrhy=self.y+self.h

listbox.min=1 listbox.max=0
listbox.fwmin=1 listbox.fwmax=0
listbox.fwmaxshow=0
listbox.maxsizew=0

listbox.paddingw=self.gpadding
listbox.paddingh=self.gpadding

listbox.tlist={}
listbox.str={} 

listbox.fw=listbox.font:getWidth("o")
listbox.fh=listbox.font:getHeight("A")

listbox.imin=self.y+listbox.paddingh
listbox.imax=self.y+listbox.paddingh+listbox.fh

local i,aux=0,0

while aux<listbox.h-listbox.fh do
aux=aux+listbox.fh
i=i+1
end
listbox.max = i>2 and i or 2
listbox.paddingh=(listbox.h-aux)/i+listbox.paddingh
end

listbox.__index = listbox

function listbox:getcount()
return #self.str>0 and #self.str or false
end

listbox.maxn = listbox.getcount

function listbox:getselected()
return type(self.selected)=="number" and self.selected or false
end

function listbox:getdata(i)
if not self.str[i] then return "" end
return self.str[i]:sub(self.str[i]:find(listbox.sep)+listbox.sep:len(),self.str[i]:len())
end

function listbox:gettext(i)
if not self.str[i] then return "" end
for str in (self.str[i]..self.sep):gmatch("([^"..self.sep.."]*)"..self.sep) do 
return str
end
end

function listbox:additem(str,data,update)
data = (type(data)=="string" or type(data)=="number") and listbox.sep..data or listbox.sep
str = (type(str)=="string" or type(str)=="number") and str or nil

if not str then return false end

table.insert(self.str,str..data)

i = #self.str

self.fwmax = self.fwmax<self.font:getWidth(str) and str:len() or self.fwmax
self.maxsizew = self.maxsizew<self.font:getWidth(str) and self.font:getWidth(str) or self.maxsizew

local tmpw = self.font:getWidth(str)
while tmpw>self.w-self.paddingw do
str = str:sub(1,str:len()-1)
tmpw = self.font:getWidth(str)
self.fwmaxshow = str:len()-1
end
listbox:resort(self.sort)
if update then listbox:uplist() end
return true
end

listbox.insert = listbox.additem

function listbox:calc(y)
	self.scrypos=y
	local pos=y-self.y
	local c = #self.str>100 and math.ceil(pos*(#self.str)/self.h) or math.floor(pos*(#self.str)/self.h)

	if c>(self.max-1)*#self.str/100 and pos<self.h-5 then
	self.min = (c<#self.str-self.max+1 and pos+1<self.h)  and c or (#self.str-self.max)+1
	for i=1, self.max do local id=self.min+i-1 self.tlist[i]=listbox:gettext(id) end
	elseif pos>=self.h-5 then
	self.min = #self.str-self.max+1
	for i=1, self.max do local id=self.min+i-1 self.tlist[i]=listbox:gettext(id) end
	else
	self.min=1
	for i=1, self.max do local id=self.min+i-1 self.tlist[i]=listbox:gettext(id) end
	end

	self.fwmin=1
end

function listbox:setselected(i)
if i<1 or i>#self.str or not i then return false end
self.selected=i
listbox:calc2(self.selected)
return true
end

function listbox:unselect()
	self.selected=nil
end

listbox.deselect = listbox.unselect

function listbox:setrounded(bool)
self.rounded=bool
listbox.rsize = self.rounded and 10 or 0
end

function listbox:findlist(str,mode,sensible)
str = (type(str)=="string" or type(str)=="number") and str or nil
if not str then return false end

local results={}
if mode=="text" then
for i, result in pairs(self.str) do
	if listbox:gettext(i):find(listbox:insensible(str)) and not sensible then 
	table.insert(results,i)
	end
	if listbox:gettext(i):find(str) and sensible then 
	table.insert(results,i)
	end
end
elseif mode=="data" then
for i, result in pairs(self.str) do
	if listbox:getdata(i):find(listbox:insensible(str)) and not sensible then 
	table.insert(results,i)
	end
	if listbox:getdata(i):find(str) and sensible then 
	table.insert(results,i)
	end
end
elseif mode=="textdata" then
for i, result in pairs(self.str) do
	if result:find(listbox:insensible(str)) and not sensible then 
	table.insert(results,i)
	end
	if result:find(str) and sensible then 
	table.insert(results,i)
	end
end
else
for i, result in pairs(self.str) do
	if result:find(listbox:insensible(str)) then 
	table.insert(results,i)
	end
end
end
	return #results>0 and results or false
end

listbox.search = listbox.findlist

function listbox:resort(sort,update)
self.sort = sort and (type(sort)~="string" and "asc" or sort) or false
if self.sort and self.sort=="asc" then
table.sort(self.str, function(a,b) return a<b end)
elseif self.sort and self.sort=="desc" then
table.sort(self.str, function(a,b) return a>b end)
end
if update then listbox:uplist() end
end

function listbox:setexpand(mode)
mode = (mode or type(mode)=="string") and (type(mode)=="string" and mode or "size") or false
if mode then
self.expmode=mode
self.expand=true
return true
else
self.expand=false
return false
end
end

function listbox:addexpand(x,y)
if self.expmode=="pos" then
self.incenter=false
if self.x>1 and self.y>1 then
self.x,self.y=x-self.expx/2-self.w,y-self.expx/2-self.h
self.defx,self.defy=self.x,self.y
else
self.x,self.y=self.x+10,self.y+10
self.defx,self.defy=self.w,self.h
listbox.isexpanding=false
self.ispress=false
end
else
self.expmode="size"
local min
if self.showindex then
local tmpwi = self.font:getWidth(#self.str.." ")
min = tmpwi+self.font:getWidth("W")+self.paddingw*3
else
min = self.font:getWidth("W")+self.paddingw*3
end
self.asize=false
if self.w>min and self.h>min then
self.w,self.h=x-self.expx/2-self.x,y-self.expx/2-self.y
self.defw,self.defh=self.w,self.h
love.graphics.rectangle("fill", self.x+self.w, self.y+self.h,self.expx,self.expx,self.rsize,self.rsize)
else
self.w,self.h=self.w+10,self.h+10
self.defw,self.defh=self.w,self.h
listbox.isexpanding=false
self.ispress=false
end
end

self.scrypos=self.y
self.scrvx=self.x+self.w
self.scrvy=self.y+self.scrvh
self.scrhpos=self.x
self.scrhy=self.y+self.h

if self.expmode=="size" then
self.min=1 self.max=0
self.fwmin=1

self.tlist={}
local im,aux=0,0
while aux<self.h-self.fh do
aux=aux+self.fh
im=im+1
end

self.max = im>2 and im or 2

if (#self.tlist<self.max) then
for i=1, self.max do self.tlist[i]=listbox:gettext(i) end
end end
end

function listbox:setsize(w,h)
self.w = type(w)=="number" and w or self.w
self.h = type(h)=="number" and h or self.h
self.scrypos=self.y
self.scrvw=self.radius+self.paddingsc
self.scrvx=self.x+self.w
self.scrvh=self.radius+self.paddingsc
self.scrvy=self.y+self.scrvh
self.scrhpos=self.x
self.scrhw=self.radius+self.paddingsc
self.scrhx=self.x
self.scrhh=self.radius+self.paddingsc
self.scrhy=self.y+self.h
self.min=1 self.max=0
self.fwmin=1 self.fwmax=2
self.fwmaxshow = 0
self.maxsizew = 0

self.fw=self.font:getWidth("o")
self.fh=self.font:getHeight("A")
self.imin=self.y+self.paddingh
self.imax=self.y+self.paddingh+self.fh

for i, str in ipairs(self.str) do
self.fwmax = self.fwmax<self.font:getWidth(str) and str:len() or self.fwmax
self.maxsizew = self.maxsizew<self.font:getWidth(str) and self.font:getWidth(str) or self.maxsizew
local tmpw = self.font:getWidth(str)
while tmpw>self.w-self.paddingw do
str = str:sub(1,str:len()-1)
tmpw = self.font:getWidth(str)
self.fwmaxshow = str:len()-1
end
end

self.tlist={}
local im,aux=0,0
while aux<self.h-self.fh do
aux=aux+self.fh
im=im+1
end

self.max = im>2 and im or 2

if (#self.tlist<self.max) then
for i=1, self.max do self.tlist[i]=listbox:gettext(i) end
end
self.paddingh=(self.h-aux)/im+self.gpadding
end

function listbox:setpos(x,y)
self.x = type(x)=="number" and x or self.x
self.y = type(y)=="number" and y or self.y
self.scrypos=self.y
self.scrvx=self.x+self.w
self.scrhpos=self.x
self.scrhy=self.y+self.h
end

function listbox:setfont(font)
	self.font = font 
	listbox:uplist()
end

function listbox:resize()
local min
if self.showindex then
local tmpwi = self.font:getWidth(#self.str.." ")
min = tmpwi+self.font:getWidth("W")+self.paddingw*3
else
min = self.font:getWidth("W")+self.paddingw*3
end

self.asize=false
local w,h = love.graphics.getDimensions()
local sizew,sizeh=w/self.gw,h/self.gh

if self.w>min and self.h>min then
self.w,self.h=self.defw*sizew,self.defh*sizeh
self.x,self.y=self.defx*sizew,self.defy*sizeh
else
self.w,self.h=self.w+10,self.h+10
self.x,self.y=self.x+10,self.y+10
end

self.scrypos=self.y
self.scrvw=self.radius+self.paddingsc
self.scrvx=self.x+self.w
self.scrvh=self.radius+self.paddingsc
self.scrvy=self.y+self.scrvh
self.scrhpos=self.x
self.scrhw=self.radius+self.paddingsc
self.scrhx=self.x
self.scrhh=self.radius+self.paddingsc
self.scrhy=self.y+self.h
self.min=1 self.max=0
self.fwmin=1 self.fwmax=2
self.fwmaxshow = 0
self.maxsizew = 0

self.fw=self.font:getWidth("o")
self.fh=self.font:getHeight("A")
self.imin=self.y+self.paddingh
self.imax=self.y+self.paddingh+self.fh

for i, str in ipairs(self.str) do
self.fwmax = self.fwmax<self.font:getWidth(str) and str:len() or self.fwmax
self.maxsizew = self.maxsizew<self.font:getWidth(str) and self.font:getWidth(str) or self.maxsizew

local tmpw = self.font:getWidth(str)
while tmpw>self.w-self.paddingw do
str = str:sub(1,str:len()-1)
tmpw = self.font:getWidth(str)
self.fwmaxshow = str:len()-1
end
end

self.tlist={}
local im,aux=0,0
while aux<self.h-self.fh do
aux=aux+self.fh
im=im+1
end

self.max = im>2 and im or 2

if (#self.tlist<self.max) then
for i=1, self.max do self.tlist[i]=listbox:gettext(i) end
end
end

function listbox:getsize()
return self.w,self.h
end

function listbox:getpos()
return self.x,self.y
end

function listbox:delitem(i)
if not i or (i and i<1 or i>#self.str) then return false end
if #self.str<=1 then listbox:delall() return true end
table.remove(self.str,i)
listbox:uplist()
if i>self.max*2 then
if i<#self.str then listbox:setselected(1) else listbox:setselected(1) listbox:setselected(#self.str) end
else
self.min= i>self.max and self.min+i-1 or 1
listbox:setselected(1)
end
return true
end

listbox.remove = listbox.delitem

function listbox:uplist()
listbox:resort(self.sort)
for i, str in ipairs(self.str) do
self.maxsizew = 0
self.fwmax = self.fwmax<self.font:getWidth(str) and str:len() or self.fwmax
self.maxsizew = self.maxsizew<self.font:getWidth(str) and self.font:getWidth(str) or self.maxsizew
local tmpw = self.font:getWidth(str)
while tmpw>self.w-self.paddingw do
str = str:sub(1,str:len()-1)
tmpw = self.font:getWidth(str)
self.fwmaxshow = str:len()-1
end
end
self.tlist={}
local im,aux=0,0
while aux<self.h-self.fh do
aux=aux+self.fh
im=im+1
end
self.max = im>2 and im or 2
if (#self.tlist<self.max) then
for i=1, self.max do self.tlist[i]=listbox:gettext(i) end
end
end

function listbox:settext(i,str)
if i<1 or i>#self.str or not i then return false end
str = (type(str)=="string" or type(str)=="number") and str or nil
if not str then return false end
local data = self.sep..listbox:getdata(i)
self.str[i]=str..data
listbox:uplist()
return true
end

function listbox:setdata(i,data)
if i<1 or i>#self.str or not i then return false end
data = (type(data)=="string" or type(data)=="number") and listbox.sep..data or false
if not data then return false end
self.str[i]=listbox:gettext(i)..data
return true
end

function listbox:setitem(i,str,data)
if i<1 or i>#self.str or not i then return false end
data = (type(data)=="string" or type(data)=="number") and listbox.sep..data or listbox.sep
str = (type(str)=="string" or type(str)=="number") and str or nil
if not str then return false end
self.str[i]=str..data
listbox:uplist()
return true
end

function listbox:getfusion(i)
return self.str[i]:gsub(self.sep,"")
end

listbox.concat = listbox.getfusion

function listbox:delall()
self.str={}
self.tlist={}
self.selected=nil
self.min=1 self.max=2
self.fwmin=1 self.fwmax=2
self.fwmaxshow=0
self.maxsizew = 0
end

listbox.empty = listbox.delall

function listbox:setvisible(bool)
self.visible=bool
end

function listbox:setenabled(bool)
self.enabled=bool
end

function listbox:isvisible()
return self.visible
end

function listbox:isenabled()
return self.enabled
end

function listbox:getfileext(fpath)
return fpath:match("^.+(%..+)$")
end

function listbox:getfilename(fpath)
fpath=fpath:sub(1,fpath:len()-4)
return fpath:match("^.+/(.+)$")
end

function listbox:getdirname(fpath)
return fpath:match("^.+/(.+)$")
end

function listbox:onlynumbers(str)
local tb={}
for n in str:gmatch("%d+") do
	table.insert(tb,n)
end
return #tb>0 and table.concat(tb) or ""
end

function listbox:onlyletters(str)
local tb={}
for l in str:gmatch("%a+") do
	table.insert(tb,l)
end
return #tb>0 and table.concat(tb) or ""
end

function listbox:enudir(fpath,exts)
local itens,ext,files={},{},{}
for fext in (exts.." "):gmatch("([^%s]*)%s") do table.insert(ext,fext) end
itens=love.filesystem.getDirectoryItems(fpath)
for i, f in ipairs(itens) do
if #ext>0 and love.filesystem.isFile(fpath.."/"..f) then
for j, e in pairs(ext) do
	if listbox:getfileext(f)==e then table.insert(files,f) end
end
end

if not exts then table.insert(files,f) end

end
return #files>0 and files or false
end

function listbox:sectotime(sec,milliseconds)
local h,m,s=0,0,0
h=math.floor(sec/3600)%60
m=math.floor(sec/60)%60
s=sec%60
if milliseconds then
return sec and string.format("%02i:%02i:%.1f",h,m,s) or "00:00:00.0"
else
return sec and string.format("%02i:%02i:%02i",h,m,s) or "00:00:00"
end
end

function listbox:rgbtohex(tcolor)
local hex={}
for i, color in ipairs(tcolor) do
color=string.format("%X", color*256) 
hex[i]=string.format("%02s",string.sub(color,1,2))
end
return table.concat(hex)	
end

function listbox:autosize(bool)
self.asize = (bool or self.asize) and true or false

local tmpi = self.showindex and string.format("%0"..self.indexzeros.."i",#self.str).." " or ""
local tmpwi = self.font:getWidth(tmpi)
if self.asize then
while self.fh*#self.str+self.paddingh<self.h-(self.paddingh+1) do
self.h=self.h-1
end
if self.maxsizew+tmpwi+self.paddingw*2>self.w then
while (self.maxsizew)+tmpwi+self.paddingw*2>self.w-(self.paddingw+1) do
self.w=self.w+1
end
end

self.defw,self.defh=self.w,self.h

self.scrypos=self.y
self.scrvx=self.x+self.w
self.scrvy=self.y+self.scrvh
self.scrhpos=self.x
self.scrhy=self.y+self.h
self.min=1 self.max=0
self.fwmin=1 self.fwmax=2
self.fwmaxshow = 0
self.maxsizew = 0

for i, str in ipairs(self.str) do
self.fwmax = self.fwmax<self.font:getWidth(str) and str:len() or self.fwmax
self.maxsizew = self.maxsizew<self.font:getWidth(str) and self.font:getWidth(str) or self.maxsizew
local tmpw = self.font:getWidth(str)
while tmpw>self.w-self.paddingw do
str = str:sub(1,str:len()-1)
tmpw = self.font:getWidth(str)
self.fwmaxshow = str:len()-1
end
end

self.tlist={}
local im,aux=0,0
while aux<self.h-self.fh do
aux=aux+self.fh
im=im+1
end

self.max = im>2 and im or 2

if (#self.tlist<self.max) then
for i=1, self.max do self.tlist[i]=listbox:gettext(i) end
end
end
self.asize=false
end

function listbox:setindex(bool)
self.showindex = (bool or nil) and true or false
if self.showindex then listbox:uplist() end
end

function listbox:center(bool)
self.incenter = (bool or self.incenter) and true or false
if self.incenter then
local width, height = love.graphics.getDimensions()
local newx,newy = width/2-self.w/2,height/2-self.h/2
if self.x~=newx and self.y~=newy then 
listbox:setpos(newx,newy)
end end end

function listbox:isover()
return self.over
end

function listbox:export(path,f,mode)
mode = (mode==true or (mode and mode=="text")) and true or false
f = (f==true or (f and f=="savedir")) and true or false

local index,fpath="",path

local name = love.filesystem.getIdentity()
if type(name)~="string" or name=="" then
name="save"
love.filesystem.setIdentity(name)
end

if not love.filesystem.exists(name) then
love.filesystem.createDirectory(name)
end

osString = love.system.getOS()

f = (osString=="Android" or osString=="iOS") and true or f

f = f==true and love.filesystem.newFile(path,"w") or io.open(path, "w")

for i=1,#self.str do
index = self.showindex and string.format("%0"..self.indexzeros.."i",(self.min+i-1)).." " or ""
if i<#self.str then 
	if mode then
	f:write(index..listbox:gettext(i).."\n")
	else
	f:write(index..self.str[i].."\n")
	end 
	else 
	if mode then
	f:write(index..listbox:gettext(i))
	else
	f:write(index..self.str[i])
	end 
end
end
f:close()

if not love.filesystem.exists(path) then
path=listbox:mount(path).."/"..path
end

if not love.filesystem.exists(path) then
path=love.filesystem.getWorkingDirectory().."/"..fpath
end

if not love.filesystem.exists(path) then
path=love.filesystem.getSaveDirectory().."/"..fpath
end

if not love.filesystem.exists(path) then
path=love.filesystem.getSourceBaseDirectory().."/"..fpath
end

return love.filesystem.exists(path) and true or false
end

listbox.save = listbox.export

function listbox:mount(path)
path=listbox:getdirname(love.filesystem.getSourceBaseDirectory())
if love.filesystem.isFused() then
local dir = love.filesystem.getSourceBaseDirectory()
local success = love.filesystem.mount(dir, path)
end
return path
end

function listbox:import(path)
local fpath=path

if not love.filesystem.exists(path) then
path=listbox:mount(path).."/"..path
end

if not love.filesystem.exists(path) then
path=love.filesystem.getWorkingDirectory().."/"..fpath
end

if not love.filesystem.exists(path) then
path=love.filesystem.getSaveDirectory().."/"..fpath
end

if not love.filesystem.exists(path) then
path=love.filesystem.getSourceBaseDirectory().."/"..fpath
end

if not love.filesystem.exists(path) then return false end

if #self.str>0 then listbox:delall() end

local count=1
for line in love.filesystem.lines(path) do
	if line~="" then
	if line:find(self.sep) then
	self.str[count]=line
	str = listbox:gettext(count)
	self.fwmax = self.fwmax<self.font:getWidth(str) and str:len() or self.fwmax
	local tmpw = self.font:getWidth(str)
	while tmpw>self.w-self.paddingw do
	str = str:sub(1,str:len()-1)
	tmpw = self.font:getWidth(str)
	self.fwmaxshow = str:len()-1
	end
	listbox:resort(self.sort)
	else
  	listbox:additem(line)
  	end
  	count=count+1
  	end
end
listbox:uplist()
return #self.str>0 and true or false
end

listbox.open = listbox.import

function listbox:insensible(pattern)
  local p = pattern:gsub("(%%?)(.)", function(percent, letter)
    if percent ~= "" or not letter:match("%a") then
      return percent .. letter
    else
      return string.format("[%s%s]", letter:lower(), letter:upper())
    end
  end)
  return p
end

function listbox:calc2(i)
	self.fwmin=1
	local c = i
	if math.abs(self.min-c)==self.max then
	if c<#self.str then
	self.min=self.min+1
	else
	self.min=#self.str-self.max+1
	self.selected=#self.str
	end
	for i=1, self.max do local id=self.min+i-1 self.tlist[i]=listbox:gettext(id) end
	end

	if (math.abs(self.min-c)>self.max+1) then
	self.min = c<#self.str-self.max+1 and c or #self.str-self.max+1
	for i=1, self.max do local id=self.min+i-1 self.tlist[i]=listbox:gettext(id) end
	end

	if math.abs(self.min-c-2)==1 then
	self.min=self.min-1
	for i=1, self.max do local id=self.min+i-1 self.tlist[i]=listbox:gettext(id) end
	end

	self.scrypos = self.y+math.floor(self.h*c/#self.str)

	if c>=#self.str then
	self.scrypos = self.h+self.y
	end

	if c<=1 then
	self.scrypos = self.y
	end
end

function listbox:isdoublec()
return self.isdouble
end

function listbox:key(key,shortcut)
if not self.selected or not self.enabled then return end
love.keyboard.setKeyRepeat(true)
if key=="down" then
self.selected = self.selected<#self.str and self.selected+1 or #self.str
elseif key=="up" then
self.selected = self.selected>1 and self.selected-1 or 1
end

if key:len()==1 and shortcut then
for i, first in ipairs(self.str) do
	first=first:sub(1,1)
	if key:lower()==first:lower() then self.selected=i break end
end
end

listbox:calc2(self.selected)
return key
end

function listbox:mousew(x,y)
if not self.selected or not self.enabled then return end
if y>0 then
self.selected = self.selected>1 and self.selected-1 or 1
elseif y<0 then
self.selected = self.selected<#self.str and self.selected+1 or #self.str
end
listbox:calc2(self.selected)
end

function listbox:drawtext(i,x,y)
if (i>#self.str) or (self.min+i-1<1) or self.tlist[i]=="" then return end
local deffont=love.graphics.getFont()
local tmpi = self.showindex and string.format("%0"..self.indexzeros.."i",(self.min+i-1)).." " or ""
local tmpf = self.tlist[i] 
local tmpt = tmpf
local tmpw = self.font:getWidth(tmpf)
local tmpwi = self.font:getWidth(tmpi)
local index = self.y+self.fh*i-self.fh+self.paddingh

while tmpw+tmpwi+self.paddingw+self.fw>=self.w-(self.paddingw+1) do
tmpt = tmpt:sub(1,tmpt:len()-1)
tmpw = self.font:getWidth(tmpt)
self.fwmaxshow=tmpt:len()
end

if not listbox.isexpanding and self.adjust then
while self.fh*i+self.paddingh>self.h-self.paddingh do
self.h=self.h+1
self.scrhy=self.y+self.h
end
end

self.fwmaxshow = self.showindex and math.abs(self.fwmaxshow+self.fwmin-1) or math.abs(self.fwmaxshow+self.fwmin-1)

tmpf = self.font:getWidth(tmpf)>(self.w-tmpwi)-self.paddingw and (self.fwmin<2 and tmpf:sub(self.fwmin,self.fwmaxshow+1) or tmpf:sub(self.fwmin,self.fwmaxshow) ) or tmpf

if (x>self.x and x<self.x+(self.w-self.radius*1.1)) and (y>index and y<index+self.fh) and self.ispress and self.enabled and not listbox.ish and self.time>self.ptime then
self.ptime=self.time+0.2
self.dtime = self.time>self.dtime and self.time+0.5 or self.dtime
self.count = self.time<self.dtime and self.count+1 or 0
self.selected=self.min+i-1
self.ispress=false
end

if self.count>1 then
self.isdouble = true
end

if self.time>self.dtime then
self.isdouble=false
self.count = 0
self.dtime = 0
end

if self.selected==self.min+i-1 then
self.imin=index
love.graphics.setColor(self.selectedcolor)
love.graphics.rectangle(self.selectedtip, self.x, self.imin, self.w, self.fh)
love.graphics.setColor(self.fselectedcolor)
else
love.graphics.setColor(self.fcolor)
end

love.graphics.setFont(self.font)
love.graphics.print(tmpi..tmpf, self.x+self.paddingw, index)
love.graphics.setFont(deffont)
end

function listbox:update(dt)
self.time=self.time+dt
if self.ismouse then
if love.mouse.isDown(1) then
self.ispress=true
else
self.ispress=false 
end
end
self.selectchange = self.tmpselected~=self.selected and true or false
self.tmpselected = self.tmpselected~=self.selected and self.selected or self.tmpselected
end

function listbox:isselectchange()
	return self.selectchange
end

function listbox:press(x,y)
self.ispress=true	
end

function listbox:released(x,y)
self.ispress=false 
end

function listbox:moved(x,y)
self.ispress=true
end

function listbox:draw()
	local x,y=0,0

	if self.ismouse then
	x,y=love.mouse.getPosition()
	end

	if self.istouch then
    for i, id in ipairs(love.touch.getTouches()) do
    x,y=love.touch.getPosition(id)
	end
	end

	if (x>self.x and x<self.x+self.w) and (y>self.y and y<self.y+self.h) then
	self.over=true
	else
	self.over=false
	end

	if not self.visible then return end

	if (self.scrypos+self.radius<self.y+self.h) and not listbox.isexpanding and not self.isscrlling and self.expand and x>=self.x+self.w and x<=self.x+self.w+self.expx+1 and y>=self.y+self.h and y<=self.y+self.h+self.expx+1 and self.ispress then
	print(self.scrypos)
	self.asize=false
	listbox.isexpanding = true
	end

	if self.expand and not self.ispress then
	listbox.isexpanding = false
	end

	love.graphics.setColor(self.bgcolor)
	
	if self.expand and listbox.isexpanding then
	love.graphics.setColor(self.bordercolor)
	listbox:addexpand(x,y)
	end

	if self.expand then love.graphics.rectangle("fill", self.x+self.w, self.y+self.h,self.expx,self.expx,self.rsize,self.rsize) end

	listbox:center()
	listbox:autosize()

	love.graphics.setColor(self.bgcolor)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h,self.rsize,self.rsize)
	
	if #self.str>0 then
	if (#self.tlist<self.max) then
	for i=1, self.max do self.tlist[i]=listbox:gettext(i) end
	end
	for i=1, #self.tlist do listbox:drawtext(i,x,y,self.ispress) end
	end

	love.graphics.setColor(self.bordercolor)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h,self.rsize,self.rsize)

	if self.expand then love.graphics.rectangle("line", self.x+self.w, self.y+self.h,self.expx,self.expx,self.rsize,self.rsize) end

	if #self.str<1 then return end

	if not listbox.isexpanding and (x>self.scrvx-self.radius and x<self.scrvx+self.scrvw) and (y>self.y and y<self.y+self.h) and self.ispress and self.max<#self.str and self.enabled then
	self.isscrlling=true
	listbox:calc(y)
	else
	self.isscrlling=false
	end

	if not listbox.isexpanding and self.max<#self.str and self.ver then
	love.graphics.circle("fill", self.scrvx, self.scrypos, self.radius, 100)
	love.graphics.circle("line", self.scrvx, self.scrypos, self.radius, 100)
	end

	if not listbox.isexpanding and not self.isscrlling and (x>self.x and x<self.x+self.w-self.radius) and (y>self.y+self.h-self.radius*1.1 and y<self.y+self.h+self.radius) and self.ispress and self.fwmaxshow>0 and self.enabled then
	self.scrhpos=x
	local pos=x-self.x
	local calc = math.ceil(pos*(self.fwmax)/self.w)
	self.fwmin= calc>1 and calc or 1
	listbox.ish=true
	else
	listbox.ish=false
	end

	if not listbox.isexpanding and self.fwmin>=2 and self.hor and self.maxsizew>self.w then
	love.graphics.circle("fill", self.scrhpos, self.scrhy, self.radius, 100)
	love.graphics.circle("line", self.scrhpos, self.scrhy, self.radius, 100)
	end
end

return listbox --[[ 

>>> FUNCTIONS <<<

NOTE: all default values and functions are in lowercase

text = string or number
data = string or number
str = string or number
index = integer (number)
item = index (text and data)
tlist = table
mode = boolean or string
update = boolean (uplist)
font = object
[] = optional

listbox:additem(text,[data],[update]) or listbox:insert(text,[data],[update]) -- add new item, return true if successfully
ex: list:additem("MySite","www,mysite.com",true)
ex: list:insert("MySite","www,mysite.com",false)

listbox:delitem(index) or listbox:remove(index) -- delete a specific item, return true if successfully
ex: list:delitem(16)

listbox:delall() or listbox:empty() -- remove all itens, no returns

listbox:getcount() or listbox:maxn() -- return max itens (number) if successfully or false (boolean)

listbox:getselected() -- return selected index (number) if successfully or false (boolean)

listbox:getdata(index) -- return item data (string) if successfully or "" (empty string)

listbox:gettext(index) -- return item text (string) if successfully or "" (empty string)

listbox:getfusion(index) or listbox:concat(index)  -- return item concatenated text..data (string) if successfully or (false)

listbox:getsize() -- two returns dimension Width Height of the listbox (number)

listbox:getpos() -- two returns position X Y of the listbox (number)

listbox:uplist() -- update/atualize the listbox, no returns

listbox:unselect() or listbox:deselect() --  deselect the listbox, no returns

listbox:setexpand(mode) -- set exapand mode true enables or "size" and enables or "pos" and enables or false disable, no returns
ex: list:setexpand("size")
ex: list:setexpand("pos")
ex: list:setexpand(true)
ex: list:setexpand(false)

listbox:settext(index,text) -- replaces item text, return true if successfully
ex = list:settext(2,"Second")

listbox:setdata(index,data) -- replaces item data, return true if successfully

listbox:setitem(index,text,[data]) -- replaces item text and data, return true if successfully
ex = list:setitem(2,"Second","SecondData")

listbox:setfont(font) -- set the listbox font, return true if successfully

listbox:setselected(index) -- selects a item in the listbox, return true if successfully

listbox:newprop(tlist) -- creates a new property for the listbox 

listbox:setrounded(boolean) -- listbox is rounded or rectangle

listbox:findlist(str,[mode],[sensible]) or listbox:search(str,[mode],[sensible]) -- return (table) index of all found str if successfully, or false (boolean)
ex: result = list:findlist("love","text",true)
if result then print(result[1]) end

ex: result = list:search("love","textdata",false)
if result then list:setselected(table.maxn(result)) end

ex: result = list:findlist("love","data",false)
if result then list:setdata(result[1],"Love2D") end

listbox:resort(mode,update) -- sort the listbox in asceding or descending, no returns
ex: list:resort("asc",true)
ex: list:resort(true,true) -- ascending 
ex: list:resort("desc",true)
ex: list:resort(false) -- disables, but not defaults sorted itens

listbox:setsize(Width,Height) -- set dimension (number)

listbox:setpos(X,Y) -- set position (number)

listbox:setindex(boolean) -- show or hide index numbers counted, no returns

listbox:setvisible(boolean) -- visible or invisible, the listbox may interact invisibly if it is not disabled

listbox:setenabled(boolean) -- enable or disable the listbox, it remains visible, but does not interact (boolean)

listbox:isvisible() -- get if is visible, return boolean

listbox:isenabled() -- get if is enabled, return boolean

listbox:isover() -- get if is pointed(over) in the listbox, return boolean

listbox:isselectchange() -- get if item selected is changed, return boolean

listbox:isdoublec() -- get if is double click in the selected item, return boolean

listbox:autosize(boolean) -- auto size the listbox, no returns

listbox:center(boolean) -- auto center in the screen, no returns

listbox:export(file,[mode1],[mode2]) or listbox:save(file,[mode1],[mode2]) -- save all itens in a file to save directory or on the side
ex: list:export("list.txt",true,"text") -- ("text" or true) exports only itens texts in save directory (and index if enabled)
ex: list:export("list.txt",false,false) -- exports all itens text..separator..data on the side (and index if enabled)
ex: list:export("list.txt") -- exports all itens text..separator..data on the side (and index if enabled)
NOTE: on the side (mode1-false) not works in android or ios, automatically exports in your save directory (mode1-true)

listbox:import(file) or listbox:open(file) -- load all lines in the listbox, if have separator will add as data, return true if successfully
ex: list:import("newlist.list") 

>>> EXTRA TOOLS <<<

listbox:getfileext(filepath) -- return file extension

listbox:getfilename(filepath) -- return file name

listbox:getdirname(path) -- return directory name

listbox:onlynumbers(str) -- return only numbers of a given string

listbox:onlyletters(str) -- return only letters of a given string

listbox:insensible(string) -- return string insensible "aA"=="aa"

listbox:enudir(path,[extensions]) -- return (table) of all files enumerated with a specific extension (or no), or false
ex: result = list:enudir("music/rock",".wav .mp3 .ogg")
ex: result = list:enudir("images",".png .jpeg .bmp")
ex: result = list:enudir("contents")

listbox:sectotime(seconds,[milliseconds]) -- return a time of a given number, or "00:00:00"
ex: result = list:sectotime(1000) -- return 00:16:40
ex: result = list:sectotime(1e3,true) -- return 00:16:40.0

listbox:rgbtohex(tcolor) -- return hexadecimal (string) of a given RGB color (table)
ex: tcolor = {100,200,255}
result = list:rgbtohex(tcolor) -- return 64C8FF

ex: print("#"..list:rgbtohex({100,200,255})) -- print #64C8FF

listbox:mount(path) -- mounts a directory outside of its executable

>>> MAIN FUNCTIONS <<<

listbox:key(key,shortcut) -- required if you want to interacts the listbox using keyboards, returns key pressed

ex: function love.keypressed(key)
list:key(key,true) -- if shortcut is enabled, select the first item character found while pressed a key 
end

listbox:mousew(x,y) -- required if you want to interacts the listbox using mouse wheel

ex: function love.wheelmoved(x,y)
list:mousew(x,y)
end

listbox:update(dt) -- required if you want to interacts the listbox...

ex: function love.update(dt)
list:update(dt)
end

listbox:press(x,y) or list.ispress=true -- optional for mouses, required for touches

ex: function love.touchpressed(id, x, y, dx, dy, pressure)
list:press(x,y)
end

ex: function love.touchpressed(id, x, y, dx, dy, pressure)
list.ispress=true
end

listbox:moved(x,y) or list.ispress=true -- optional for mouses, required for touches

listbox:released(x,y) or list.ispress=false -- optional for mouses, required for touches

listbox:resize() -- required if you want to autosize the listbox on resize

ex: function love.resize(w,h)
list:resize()
end

listbox:draw() -- required if you want to use the listbox

ex: function love.draw()
list:draw()
end 

>>> DEMO <<<

function love.load()

font = love.graphics.newFont(15)

list = require "listbox"

local tlist={
x=200, y=100,
font=font,ismouse=true,
rounded=true,
w=200,h=300,showindex=true}

list:newprop(tlist)

list:insert("MySite","www.MySite.com")
list:insert("MyNumber",123456)
end

function love.keypressed(key)
list:key(key,true)
end

function love.wheelmoved(x,y)
list:mousew(x,y)
end

function love.update(dt)
list:update(dt)
end

function love.draw()
list:draw()
end 

]]