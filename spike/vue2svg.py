import os, glob, io
from lxml import etree

nsmap = {
    'xsi':"http://www.w3.org/2001/XMLSchema-instance"
}

def xp(tree, path):
    match = tree.xpath(path, namespaces=nsmap)
    return match[0] if match else ''


def walk(tree, sep, indent):
    """
    walk the tree recursively, extracting node data
    """
    children = tree.xpath('child')
    for child in children:
        print('> ' * indent +
              sep.join(xp(child, path) for path in [
                    '@ID',
                    '@created',
                    '@xsi:type',
                    'shape/@xsi:type',
                    '@x',
                    '@y',
                    '@width',
                    '@height',
                    '@label',
                    '@layerID',
                    'fillColor/text()',
                    'strokeWidth/text()',
                    'strokeColor/text()',
                    'textColor/text()',
                    'font/text()',
                    'ID1/text()',
                    'ID2/text()',
                    'point1/@x',
                    'point1/@y',
                    'point2/@x',
                    'point2/@y',
                    '@controlCount',
                    'ctrlPoint0/@x',
                    'ctrlPoint0/@y',
                    'ctrlPoint1/@x',
                    'ctrlPoint1/@y',
                    ]))
        walk(child, sep, indent+1)


for filename in sorted(glob.glob('*.vue')):

    # vue files are not valid xml because the doctype is misplaced.
    # so to fix, just strip off the opening comments:
    data = open(filename, 'r').read()
    data = data[data.find('<?xml'):]

    vue = etree.parse(io.BytesIO(bytes(data, 'ascii')))

    print('##', filename, '#' * (60-len(filename)))
    walk(vue, '; ', 0)

