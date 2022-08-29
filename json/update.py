#!/usr/bin/env python3

import os
import re
import requests
import subprocess
import json
from bs4 import BeautifulSoup


OUTPATH = os.getenv('OUTPATH')


urls = {
    'yandex-browser-beta': 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/',
    'yandex-browser-stable': 'https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-stable/',
}


def prefetch_url(url):
    result = subprocess.run(['nix-prefetch-url', url], capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout.strip()


def process_url(url_name):
    _url = urls[url_name]
    response = requests.get(_url)
    if response.ok:
        content = response.text
        soup = BeautifulSoup(content, 'html.parser')
        anchor = r'\b' + url_name + r'_.*'
        a = soup.find('a', string=re.compile(anchor))
        href = a.get('href')
        url = _url + href
        version = href.split('_')[1]
        sha256 = prefetch_url(url)
        with open(url_name + '.json', 'w') as f:
            json_string = json.dumps({ 'pname': url_name, 'version': version, 'sha256': sha256 })
            f.write(json_string)


if __name__ == '__main__':
    for url_name in urls.keys():
        process_url(url_name)
