import os.path
import json 
import codecs
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
def myFunc(e):
  return len(e[0])

# Writing to sample.json
with codecs.open(os.path.join(BASE_DIR, "wordTenseData.txt",), "r", "utf-8") as infile, codecs.open(os.path.join(BASE_DIR, "wordTense.json"), "w","utf-8") as outfile:
    thing = infile.readlines()
    output = {}
    x = []
    for line in thing:
        if(line == "---\n"):
            continue
        else:
            z = line.split(", ")
            for i in range(len(z)):
                if i != 0:
                    z[i] = z[i][0:-1]
            x.append([str(z[0]),z[1:]])
    x.sort(key=myFunc, reverse=True)
    print(x)
    for s in x:
        output[s[0]] = s[1]
    final = json.dumps(output,indent = 4,ensure_ascii=True)
    outfile.write(final)
    