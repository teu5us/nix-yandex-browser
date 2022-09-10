#!/usr/bin/env python3

import os
import re
import requests
import subprocess
import json
import shutil
from bs4 import BeautifulSoup


OUTPATH = os.getenv('OUTPATH') or 'json'
NPX = os.getenv('NPX')
W3 = f'{NPX} @web3-storage/w3'.split(" ")
IPFS_CAR = f'{NPX} ipfs-car'.split(" ")


urls = {
    'yandex-browser-beta': 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/',
    'yandex-browser-stable': 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-stable/',
}


def getJson(url_name):
    return OUTPATH + '/' + url_name + '.json'


def prefetch_url(url):
    result = subprocess.run(
        ['nix-prefetch-url', '--print-path', url],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        return result.stdout.strip().split('\n')
    else:
        print(f'Error fetching {url}')


def make_car(name, path):
    filename = path.split('/')[-1]
    first_hyphen = filename.find('-')
    new_path = '/tmp/' + filename[(first_hyphen + 1):]
    shutil.copyfile(path, new_path)
    result = subprocess.run(
        IPFS_CAR + ['--pack', new_path, '--output', f'/tmp/{name}.car'],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        stripped = result.stdout.strip()
        split = stripped.split('\n')
        return list(map(lambda str: str.split(':')[1].strip(), split))
    else:
        print(f'Error producing {name}.car')


def is_stored(cid):
    result = subprocess.run(
        W3 + ['status', cid],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        if result.stdout.strip() == 'undefined':
            return False
        else:
            return True
    else:
        print(f'Error checking cid {cid}')


def store(path):
    result = subprocess.run(W3 + ['put-car', path])
    if result.returncode == 0:
        print(f'IPFS upload complete: {path}')
    else:
        print(f'IPFS upload failed: {path}')


def process_url(url_name):
    _url = urls[url_name]
    response = requests.get(_url)
    if response.ok:
        json_file = getJson(url_name)
        with open(json_file, 'r') as f:
            json_data = json.load(f)
            old_version = json_data['version']
            old_cid = json_data['cid']
            cid_stored = is_stored(old_cid)
        content = response.text
        soup = BeautifulSoup(content, 'html.parser')
        anchor = r'\b' + url_name + r'_.*'
        a = soup.find('a', string=re.compile(anchor))
        href = a.get('href')
        version = href.split('_')[1]
        if version == old_version and cid_stored:
            print(f'No update required for {url_name}')
        else:
            url = _url + href
            sha256, path = prefetch_url(url)
            cid, car_path = make_car(url_name, path)
            with open(json_file, 'w') as f:
                json_string = json.dumps({
                    'pname': url_name,
                    'version': version,
                    'sha256': sha256,
                    'cid': cid
                })
                f.write(json_string)
            store(car_path)
    else:
        print('Error getting repository page')


if __name__ == '__main__':
    for url_name in urls.keys():
        process_url(url_name)
