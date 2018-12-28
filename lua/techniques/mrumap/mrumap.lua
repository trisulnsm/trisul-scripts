-- mrumap.lua
-- operations like  LUA table lookup but pop_oldest()  is O(1) 
-- 
--local dbg=require'debugger'

local MruMap = {

  put=function(tbl,k,v)
    local wrap=tbl:newnode(k,v)
    tbl:push_front(wrap)
    tbl.basetable[k]=wrap 
  end,

  get=function(tbl,k)
    local wrap = tbl.basetable[k]
    if wrap==nil then return nil end
    tbl:erase(wrap)
    tbl:push_front(wrap)
    return wrap.data
  end,

  delete=function(tbl,k)
    local wrap = tbl.basetable[k]
    if wrap==nil then return nil end
    tbl:erase(wrap)
    tbl.basetable[k]=nil 
    wrap=nil 
  end,

  delete_lru=function(tbl)
    local wrap = tbl:pop_back()
    if wrap==nil then return nil end
    tbl.basetable[wrap.k]=nil 
    wrap=nil 
  end,

  pop_back=function(tbl)
    if tbl._size>0 then 
      local  wrap = tbl._Tail;
      tbl._Tail = tbl._Tail.p;
      if tbl._Tail then  tbl._Tail.n=nil end
      tbl._size=tbl._size-1
      return wrap;
    else
      return nil
    end
  end,

  newnode=function(tbl,k,v)
    return {
      k=k, data=v, p=nil, n=nil
    }
  end,

  push_front=function(tbl,n) 
    if n==tbl._Head and n==tbl._Tail then return end 

    if tbl._Head then 
      tbl._Head.p=n;
    end

    n.p=nil;
    n.n=tbl._Head;
    tbl._Head=n;

    if tbl._Tail==nil then 
      tbl._Tail=tbl._Head;
    end

    tbl._size=tbl._size+1
    return n
  end,

  erase=function(tbl,n)
    if tbl._size==0 then return end

    if n.p or n.n then
      if n.p then
        n.p.n=n.n
      else
        tbl._Head=n.n
      end
      if n.n then
        n.n.p=n.p
      else
        tbl._Tail=n.p
      end
      tbl._size=tbl._size-1
    elseif n==tbl._Head and n==tbl._Tail then 
      tbl.reset()
    end
    return n
  end,

  reset=function()
    tbl._size=0;
    tbl._Head=nil;
    tbl._Tail=nil;
  end,

  size=function(tbl)
    return tbl._size
  end,

  mru_iter=function(tbl)
    local start=tbl._Head;
    return function ()
      if start then 
        local ret=start.k
        start=start.n
        return ret
      else
        return nil
      end
    end
  end,
}


MruMap.__index=MruMap

local mrumap  = { 
   new = function() 
     return setmetatable(  {
        basetable={},
        _Head=nil,
        _Tail=nil,
        _size=0
      },MruMap)
    end
} 

return mrumap;
