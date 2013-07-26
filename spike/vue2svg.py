import os, glob, io
from collections import namedtuple
from lxml import etree

nsmap = {
    'xsi':"http://www.w3.org/2001/XMLSchema-instance"
}

def xp(tree, path):
    match = tree.xpath(path, namespaces=nsmap)
    return match[0] if match else ''

Join = namedtuple('Join',
                  ('parent ntype shape id ts x y w h text layer autosized'
                   ' fill strokewidth strokecolor strokestyle textcolor'
                   ' font id1 id2 p0x p0y p1x p1y ctrlcount arrowstate'
                   ' c0x c0y c1x c1y').split( ))

def walk(tree, parent=0):
    """
    walk the tree recursively, extracting node data
    """
    children = tree.xpath('child')
    for child in children:
        row = Join(*([parent] +
            [xp(child, path) for path in [
                '@xsi:type',
                'shape/@xsi:type',
                '@ID',
                '@created',
                '@x',
                '@y',
                '@width',
                '@height',
                '@label',
                '@layerID',
                '@autoSized',
                'fillColor/text()',
                'strokeWidth/text()',
                'strokeColor/text()',
                'strokeStyle/text()',
                'textColor/text()',
                'font/text()',
                'ID1/text()',
                'ID2/text()',
                'point1/@x',
                'point1/@y',
                'point2/@x',
                'point2/@y',
                '@controlCount',
                '@arrowState',
                'ctrlPoint0/@x',
                'ctrlPoint0/@y',
                'ctrlPoint1/@x',
                'ctrlPoint1/@y' ]]))
        yield row
        for item in walk(child, row.id): yield item


for filename in sorted(glob.glob('*.vue')):

    # vue files are not valid xml because the doctype is misplaced.
    # so to fix, just strip off the opening comments:
    data = open(filename, 'r').read()
    data = data[data.find('<?xml'):]

    vue = etree.parse(io.BytesIO(bytes(data, 'ascii')))

    print('##', filename, '#' * (60-len(filename)))
    for row in walk(vue, 0):
        print('; '.join(map(str, row)), sep='')

