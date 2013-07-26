-- sqlite schema for scenetool diagrams
-- convention here is to use the anonymous rowid as primary key

create table scene (
  name text
);

create table font (
  font text
);

create table style (
  name text,
  fg int,  -- text color
  bg int,  -- fill color
  sc int,  -- stroke color
  sw int,  -- stroke width
  font int references font,
  size int
);

create table elem (
  scene int references scene,
  style int references style,
  ts timestamp,
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
  x0 real,
  y0 real,
  x1 real,
  y1 real,
  -- (0..2) control points (for bezier curves)
  cpc int,  -- control point count
  cx0 real,
  cy0 real,
  cx1 real,
  cy1 real
);

insert into shape values ( 'rect' );
insert into shape values ( 'rounded' );
insert into shape values ( 'ellipse' );
