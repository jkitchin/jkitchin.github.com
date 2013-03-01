import glob

for html in glob.glob('*.html'):
    with open(html) as f:
        lines = f.readlines()

    with open(html, 'w') as f:
        for line in lines:
            if "tags: ''" not in line:
                print line
                f.write(line)
                
