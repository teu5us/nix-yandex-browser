#!/usr/bin/env python3

import os
import requests
import subprocess
import json
import re


OUTPATH = os.getenv('OUTPATH') or 'json'
CODECS_JSON = 'https://browser-resources.s3.yandex.net/linux/codecs.json'

STRINGS_CMD = os.getenv('STRINGS') or 'strings'

BROWSERS = {
    'yandex-browser-stable': (os.getenv('STABLE'), 'browser'),
    'yandex-browser-beta': (os.getenv('BETA'), 'browser-beta'),
}


def get_codec_sources():
    response = requests.get(CODECS_JSON)
    if response.ok:
        content = response.text
        return json.loads(content)
    else:
        print('Failed to fetch codec links')


def get_links(name):
    nix_path, folder_name = BROWSERS[name]
    browser_cmd = f'{nix_path}/opt/yandex/{folder_name}/yandex_browser'
    filename = "/".join([OUTPATH, f'{name}.json'])
    version = None
    with open(filename, "r") as h:
        text = h.read()
        json_data = json.loads(text)
        version = json_data['version']
    patch = version.split('-')[0].split('.')[-1]
    result = subprocess.run(
        [STRINGS_CMD, browser_cmd],
        capture_output=True,
        text=True
    )
    if result.returncode == 0:
        browser_cmd_strings = result.stdout.strip().split('\n')
        versions = list(set(filter(
            lambda str: re.match(r'\d*\.\d*\.\d*\.' + patch, str),
            browser_cmd_strings
        )))
        chrver = list(filter(
            lambda str: not re.match(str, version),
            versions
        ))[0]
        chrver_no_patch = '.'.join(chrver.split('.')[0:-1])
        codec_sources = get_codec_sources()[chrver_no_patch]
        return codec_sources
    else:
        print(f'Failed to read file {browser_cmd}')


def prefetch_url(url):
    result = subprocess.run(
        ['nix-prefetch-url', url],
        capture_output=True,
        text=True
    )
    if result.returncode == 0:
        return result.stdout.strip()
    else:
        return None


def process_links(url_list):
    url_count = len(url_list)
    failed = 0
    for url in url_list:
        print(f'Failed urls: {failed} out of {url_count}')
        result = prefetch_url(url)
        if not result:
            failed += 1
            continue
        else:
            version = url.split('/')[-1]\
                         .split('_')[1]\
                         .split('-')[0]
            return {
                'url': url,
                'version': version,
                'sha256': result
            }



if __name__ == '__main__':
    for browser in BROWSERS.keys():
        print(f'Processing {browser}')
        links = get_links(browser)
        json_data = process_links(links)
        if json_data:
            with open(f'{OUTPATH}/{browser}-codecs.json', "w") as h:
                json_string = json.dumps(json_data)
                h.write(json_string)
        else:
            print("Error fetching codecs")
