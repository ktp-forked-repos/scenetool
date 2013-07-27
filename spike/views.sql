
create view if not exists nodes as
  select e.rowid as eid, e.*, s.shape, n.w, n.h
  from elem as e, node as n, shape as s
  where e.rowid = n.eid and n.sid = s.rowid;

create view if not exists edges as
  select el.rowid as eid, el.*, x1,y1,cpc,cx0,cy0,cx1,cy1
  from elem as el, edge as e
  where el.rowid = e.eid;
