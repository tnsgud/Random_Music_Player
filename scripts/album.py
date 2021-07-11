from google_images_download import google_images_download
import sys

keywords = []

with open('musics.txt', 'r', encoding='utf-8',) as f:

    for line in f.readlines():
        words = line.split(' - ')
        keywords.append(f'{words[0]} - {words[1]}')

sys.stdout = open('out.txt', 'w', encoding='utf-8')

for keyword in keywords:
    print(keyword)
    response = google_images_download.googleimagesdownload()
    imgArgs = {'keywords': f'{keyword} 앨범 커버',
               'limit': 5, 'print_urls': True, }

    response.download(imgArgs)
