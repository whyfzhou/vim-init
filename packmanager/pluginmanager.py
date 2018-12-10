#!/usr/bin/env python3

import subprocess
import os
import os.path
import shutil


categories = {'start', 'opt'}
git = 'https://github.com/'


def read_list(filename):
    di = {cat: [] for cat in categories}
    try:
        with open(filename) as f:
            for line in f:
                if not line or len(line.split()) < 2 or line.split()[0].lower() not in categories:
                    continue
                cat = line.split()[0].lower()
                repo = line.split()[1]
                di[cat].append(repo)
    except:
        pass
    return di


git_rev_parse = subprocess.run(['git', 'rev-parse'])
if git_rev_parse.returncode != 0:
    print('Initializing a git repo...')
    subprocess.run(['git', 'init'])
    subprocess.run(['git', 'submodule', 'init'])

pmdir = os.getcwd()
update = read_list('packlist.txt')
maintained = read_list('maintained.txt')
os.chdir('../../pack')

for cat in categories:
    to_update = []
    to_add = []
    to_remove = []
    for u in update[cat]:
        if u in maintained[cat]:
            to_update.append(u)
        else:
            to_add.append(u)
    for m in maintained[cat]:
        if m not in update[cat]:
            to_remove.append(m)
    for pack in to_add:
        author, plugin = pack.split('/')
        command = ['git', 'submodule', 'add', git + pack, os.path.join('pack', author, cat, plugin)]
        print(' '.join(command))
        subprocess.run(command)
    for pack in to_remove:
        author, plugin = pack.split('/')
        command = ['git', 'submodule', 'deinit', os.path.join('pack', author, cat, plugin)]
        print(' '.join(command))
        subprocess.run(command)

command = ['git', 'submodule', 'update', '--remote', '--merge']
print(' '.join(command))
subprocess.run(command)

os.chdir(pmdir)
shutil.copy('packlist.txt', 'maintained.txt')
