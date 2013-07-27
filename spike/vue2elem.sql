-- convert vue data to scene data

-- normalize the fonts:
insert into font select distinct font from vuedata;

-- and the styles:
insert into style (fg, bg, sc, sw, font)
select distinct
  textcolor, fill, strokecolor, strokewidth,
  (select rowid from font where font=vuedata.font)
from vuedata;

-- create a new table with same structure as the input table.
-- the idea is that we're going to add a bunch of triggers to
-- this table, and then just copy the data.
create temp table vue2elem as select * from vuedata where 0=1;

-- temp table to store variables since sqlite doesn't have them
create temp table kvdict ( k text unique not null, v int );

create temp table convert_ntype ( vuent text, lmtag int );
insert into convert_ntype
      select 'link', rowid from lmtag where tag='edge'
union select 'node', rowid from lmtag where tag='node'
union select 'group',rowid from lmtag where tag='group';

-- trigger to create the common elem record
create temp trigger add_vue_data before insert on vue2elem
  begin
    -- create an elem record with the common fields
    insert into elem (scene, style, lmtag, label, ts, x, y, z)
    values (
      new.fid, -- scene
      (select rowid from style
       where fg = new.textcolor
	 and bg = new.fill
         and sc = new.strokecolor
         and sw = new.strokewidth
         and font=(select rowid from font where font=new.font)
       ), -- style
       (select lmtag from convert_ntype where vuent=new.ntype),
       new.text, new.ts, new.x, new.y,
       -- for the z-ordering, just assign numbers in sequence:
       (select max(z)+1 from elem where scene=new.fid) -- z
    );

    -- remember the rowid of the elem record we just made:
    insert or replace into kvdict (k,v)
    values ('last_elem', last_insert_rowid());
  end;

-- trigger to populate detail table for links/edges
create temp trigger add_vue_link after insert on vue2elem
  when
    new.ntype = 'link'
  begin
    insert into edge (eid, x0, y0, x1, y1, cpc, cx0, cy0, cx1, cy1)
    values ((select v from kvdict where k='last_elem'), -- eid
            new.p0x, new.p0y, new.p1x, new.p1y,
	    new.ctrlcount,
	    new.c0x, new.c0y, new.c1x, new.c1y);
  end;

-- trigger to populate detail table for nodes
create temp trigger add_vue_node after insert on vue2elem
  when
    new.ntype = 'node'
  begin
    insert into node (eid, sid, w, h)
    values ((select v from kvdict where k='last_elem'), -- eid
            (select rowid from shape where shape=new.shape),
	    new.w, new.h);
  end;


-- now copy the data over, firing the triggers:
insert into vue2elem select * from vuedata;

-- clean up shop
-- triggers will be deleted automatically
drop table kvdict;
drop table vue2elem;

