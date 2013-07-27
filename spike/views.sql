
create view nodes as
  select e.rowid as eid, e.*, s.shape, n.w, n.h
  from elem as e, node as n, shape as s
  where e.rowid = n.eid and n.sid = s.rowid;

create view edges as
  select el.rowid as eid, el.*, x1,y1,cpc,cx0,cy0,cx1,cy1
  from elem as el, edge as e
  where el.rowid = e.eid;

create view scenes as
  select filename, lmtag.tag, lm.rowid as lmid, lm.*,
         sh.shape, n.w, n.h,
         e.x1, e.y1, e.cpc, e.cx0, e.cy0, e.cx1, e.cy1
  from elem as lm
       left join lmtag on lm.lmtag = lmtag.rowid
       left join file on lm.scene = file.rowid
       left outer join edge as e on e.eid = lm.rowid
       left outer join node as n on n.eid = lm.rowid
       left outer join shape as sh on n.sid = sh.rowid
  order by lm.scene, lm.z ;
