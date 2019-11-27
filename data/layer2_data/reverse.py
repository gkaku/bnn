string = ''
with open('test_file.txt', 'w') as f:
    string = string[::-1]
    for i in string:
        f.write(i+'\n')

