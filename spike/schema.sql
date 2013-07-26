-- sqlite schema for scenetool diagrams
-- convention here is to use the anonymous rowid as primary key

create table scene (
  name text
);

create table font (
  name text
);

create table style (
  name text,
  created timestamp,
  fg int,  -- fg color (text)
  bg int,  -- bg color (text)
  eg int,  -- edge (stroke) color
  font int references font,
  font_size int
);

create table elem (
  scene int references scene,
  style int references style,
  x  real,
  y  real,
  z  int,  -- z-order (sequence)
  label text
);

create table shape (
  shape text
);

create table node (
  eid int references elem,
  sid int references shape,
  w  real,
  h  real
);

create table edge (
  eid int references elem,
  -- 2 end points
  x1 real,
  y1 real,
  -- (0..2) control points (for bezier curves)
  ctrl_count int,
  cx0 real,
  cy0 real,
  cx1 real,
  cy1 real
);

insert into shape values ( 'rect' );
insert into shape values ( 'rounded' );
insert into shape values ( 'ellipse' );
