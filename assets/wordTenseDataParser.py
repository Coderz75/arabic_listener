import os.path
import json 
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
 
# Writing to sample.json
with open(os.path.join(BASE_DIR, "wordTenseData.txt"), "r") as infile, open(os.path.join(BASE_DIR, "wordTense.json"), "w") as outfile:
    thing = infile.readlines()
    output = {}
    for line in thing:
        if(line == "----\n"):
            pass
        else:
            z = line.split(", ")
            for i in range(len(z)):
                if i != 0:
                    z[i] = z[i][0:-1]
            output[z[0]] = z[1:]
    final = json.dumps(output,indent = 4)
    outfile.write(final)
    