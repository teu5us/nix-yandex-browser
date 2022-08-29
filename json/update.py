#!/usr/bin/env python3

import os
import re
import requests
import subprocess
import json
from bs4 import BeautifulSoup


OUTPATH = os.getenv('OUTPATH') or 'json'


urls = {
    'yandex-browser-beta': 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/',
    'yandex-browser-stable': 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-stable/',
}


def getJson(url_name):
    return OUTPATH + '/' + url_name + '.json'


def prefetch_url(url):
    result = subprocess.run(['nix-prefetch-url', url], capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout.strip()


def process_url(url_name):
    _url = urls[url_name]
    response = requests.get(_url)
    if response.ok:
        json_file = getJson(url_name)
        with open(json_file, 'r') as f:
            json_data = json.load(f)
            old_version = json_data['version']
        content = response.text
        soup = BeautifulSoup(content, 'html.parser')
        anchor = r'\b' + url_name + r'_.*'
        a = soup.find('a', string=re.compile(anchor))
        href = a.get('href')
        version = href.split('_')[1]
        if version == old_version:
            print(f'No update required for {url_name}')
        else:
            url = _url + href
            sha256 = prefetch_url(url)
            with open(json_file, 'w') as f:
                json_string = json.dumps({
                    'pname': url_name,
                    'version': version,
                    'sha256': sha256
                })
                f.write(json_string)
    else:
        print('Error getting repository page')


if __name__ == '__main__':
    for url_name in urls.keys():
        process_url(url_name)
