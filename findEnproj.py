import codecs
import os
import traceback
import sys
reload(sys)

def findFile(projectHome,fileName):
    aimPath = "xx"
    for i in os.listdir(projectHome):
	 if not cmp(i,".git"):
	     continue
	 if not cmp(i,"WizIosSDK"):
	     continue
	 currentPath = projectHome + '/' + i 
	 if not cmp(i,fileName):
	     return currentPath
	 if os.path.isdir(currentPath):
	     path = findFile(currentPath,fileName)
	     if cmp (path, "xx"):
		  aimPath = path
    return aimPath

sys.setdefaultencoding('utf-8')
projectHome = os.getcwd()
outPutDir = findFile(projectHome,"en.lproj") 

def genstrings(level, path):
	for i in os.listdir(path):
	    if not cmp (i, '.git'):
		continue
	    if os.path.isdir(path+'/'+i):
			x = 'genstrings -a -o '+ outPutDir+' ' +path + '/'+i+'/*.m'
			print x
			os.system(x)
			os.system('genstrings -a -o '+ outPutDir+' ' +path + '/'+i+'/*.h')
			os.system('genstrings -a -o '+ outPutDir+' ' +path + '/'+i+'/*.mm')
			genstrings(level+1,path+'/'+i)
genstrings(0,projectHome)

def fileDictionary(filePath, isAddPlaceHolder,fileEncode):
    fileDic = {}
    fileContent = codecs.open(filePath,'r',fileEncode)
    for line in fileContent.readlines():
	try:
	    if(len(line) == 0):
		continue
	    strr = line.split('=')
	    if(len(strr) == 1):
		continue
	    en = strr[0]
	    en = en[en.index('"')+1:len(en)]
	    en = en[0:en.index('"')]
	    zh = strr[1]
	    zh = zh[zh.index('"')+1:len(zh)]
	    zh = zh[0:zh.index('"')]
	    if isAddPlaceHolder:
		fileDic[en] = ''
	    else:
		fileDic[en] = zh
	except KeyError:
	    print "aa"
    fileContent.close()
    return fileDic


zhFilePath = findFile(projectHome,"zh.txt")
englishFilePath = outPutDir+'/Localizable.strings'

def printDic(dic):
    for key in dic.keys():
	print key

zhDic = fileDictionary(zhFilePath, False, 'utf-8')
enDic = fileDictionary(englishFilePath,True,'utf-16BE')

print zhDic
print '**************'

for key in enDic.keys():
    try:
	zh = zhDic[key]
	enDic[key] = zhDic[key]
    except KeyError:
	transilation = raw_input('plasee input the translation of **'+key+'**:')
	print transilation
	enDic[key] = transilation

def writeDicToFile(dic,filePath,isWriteValue):
	writeFile = codecs.open(filePath, 'w','utf-8')
	for key in dic.keys():
	    try:
		keyStr = key.encode('utf-8')
		valueStr = dic[key].encode('utf-8')
		print keyStr + valueStr
		if isWriteValue:
		    writeFile.write('"'+keyStr+'"="'+valueStr+'"'+';\n')
		else:
		    writeFile.write('"'+keyStr+'"="'+keyStr+'"'+';\n')
	    except UnicodeDecodeError:
		continue
	    except TypeError:
		continue
	    except KeyError:
		continue
	writeFile.close()

enOutputFilePath = findFile(projectHome,"en.txt")
writeDicToFile(enDic,enOutputFilePath,False)
writeDicToFile(enDic,zhFilePath,True)
