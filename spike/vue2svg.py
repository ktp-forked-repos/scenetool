import os, glob, io
from lxml import etree

nsmap = {
    'xsi':"http://www.w3.org/2001/XMLSchema-instance"
}

def xp(tree, path):
    match = tree.xpath(path, namespaces=nsmap)
    return match[0] if match else ''


def walk(tree, indent):
    """
    walk the tree recursively, extracting node data
    """
    children = tree.xpath('child')
    for child in children:
        yield [indent] +\
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
                'ctrlPoint1/@y' ]]
        for item in walk(child, indent+1): yield item


for filename in sorted(glob.glob('*.vue')):

    # vue files are not valid xml because the doctype is misplaced.
    # so to fix, just strip off the opening comments:
    data = open(filename, 'r').read()
    data = data[data.find('<?xml'):]

    vue = etree.parse(io.BytesIO(bytes(data, 'ascii')))

    print('##', filename, '#' * (60-len(filename)))
    for item in walk(vue, 0):
        indent, *values = item
        print(indent * '> ',
              '; '.join(values), sep='')

