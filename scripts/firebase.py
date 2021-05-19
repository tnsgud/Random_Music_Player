import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from colorama import init
from colorama import Fore, Back, Style

init()

# Fore: BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, RESET.
# Back: BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, RESET.
# Style: DIM, NORMAL, BRIGHT, RESET_ALL

def delete_collection(coll_ref, batch_size):
    docs = coll_ref.limit(batch_size).stream()
    deleted = 0

    for doc in docs:
        print(f'Deleting doc {doc.id} => {doc.to_dict()}')
        doc.reference.delete()
        deleted = deleted + 1

    if deleted >= batch_size:
        return delete_collection(coll_ref, batch_size)

def startFirebase():
    """
    FireBase와 연동을 하는 메소드
    """
    cred = credentials.Certificate(
        './music-c5930-firebase-adminsdk-oplbd-8b4ba9c398.json')
    firebase_admin.initialize_app(
        cred, {'projectId': "music-c5930"})
    # 'databaseURL': "https://music-c5930.firebaseio.com/"

    db = firestore.client()
    print(Fore.GREEN+'firebase 연결성공'+Fore.WHITE)
    delete_collection(db.collection(u'songs'), 100)
    return db


def readFile(path: str):
    """
    파일을 읽어 내용을 반환하는 메소드
    """
    file = open(path, 'r',  encoding='utf-8')
    res = []
    line = file.readline()
    while line:
        res.append(line)
        line = file.readline()
    file.close()
    return res


def mkdic(title: str, singer: str, url: str, picture:str, genres: list):
    """
    Dictionary를 만드는 메소드
    """
    res = {
        'title': title,
        'singer': singer,
        'genres': genres,
        'url': url,
        'album cover': picture
    }
    print(res)
    return res


def writeFile(path: str, title: str, index: int, after: str):
    """
    파일에서 제목을 가지고 url 또는 url과 장르를 변경하는 메소드
    """

    rfile = open(path, 'r', encoding='utf-8')
    lines = rfile.readlines()

    wfile = open(path, 'w', encoding='utf-8')

    for line in lines:
        song = line.split(' - ')
        if song[0] == title:
            song[index] = after
        wfile.write(f'{song[0]} - {song[1]} - {song[2]} - {song[3]}')

    wfile.close()
    rfile.close()


def parseText(string: list):
    """
    Cloud store 형식에 맞게 텍스트를 나누는 메소드 
    """
    res = []
    for i in range(0, len(string)):
        a = string[i].split(' - ')
        b = a[3].split(':')
        b[-1] = b[-1].replace('\n', '');
        res.append(mkdic(a[0], a[1], a[2], a[3], b))
    return res


def setData(song: list, db):
    """
    Cloud store에 데이터를 업로드하는 메소드 
    """
    for i in range(0, len(song)):
        doc_ref = db.collection(u'songs').document(u'song{0:0>5}'.format(i))
        doc_ref.set({
            u'id': i,
            u'title': u'{0}'.format(song[i]['title']),
            u'singer': u'{0}'.format(song[i]['singer']),
            u'url': u'{0}'.format(song[i]['url']),
            u'genres': u'{0}'.format(song[i]['genres']),
            u'album cover':u'{0}'.format(song[i]['album cover'])
        })
        print(Fore.WHITE+f"{song[i]['title']} 등록성공")