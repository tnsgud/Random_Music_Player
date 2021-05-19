import firebase

choice = input("할 작업을 선택해주세요.\n1:데이터 업로드\n2:텍스트파일 수정 \n")

if choice == '1':
    firebase.setData(firebase.parseText(firebase.readFile('./musics.txt')), firebase.startFirebase())    
elif choice == '2':
    check = input("musics.txt파일을 변경할것 입니까? (Y/n): ")
    if check == "y" or check == 'Y':
        title = input('변경할 노래의 제목을 입력해주세요: ')
        index = int(input('어떤것을 변경할 건가요? (0: 제목, 1:가수, 2:주소, 3:앨범커버, 4:카테고리): '))
        after = input('변경 사항을 입력해주세요: ')
        firebase.writeFile('./musics.txt', title, index, after)
    elif check == 'N' or check == 'n':
        print('프로그램을 종료합니다.')

