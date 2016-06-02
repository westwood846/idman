import csv

##Requires a csv-file with 2 columns with headings name and type
def load_categorized_list_from_csv(csvFile,delim=",",quote="\""):
		tmp = read_csv(csvFile,delim,quote)
		type_index = tmp[0].index('type')
		name_index = tmp[0].index('name')
		tmp=tmp[1:]
		categories=set(map(lambda x: x[type_index],tmp))
		result = {c:[] for c in categories}
		for line in tmp:
			result[line[type_index]].append(line[name_index])
		return result

#reads a csv-file to a list of lists reomoving empty lines
def read_csv(csvFile,delim=",",quote="\""):
		file = open(csvFile,"rb")
		reader = csv.reader(file, delimiter=delim, quotechar=quote)
		result = [[y.strip() for y in x] for x in reader if len([y for y in x if y.strip()])]#remove empty lines
		return result

if __name__ == "__main__":
	import sys
	import json
	print json.dumps(load_categorized_list_from_csv(*sys.argv[1:]))
