#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import subprocess
import simplejson as json

class SetEncoder(json.JSONEncoder):
	def default(self, obj):
		if isinstance(obj, set):
	        	 return list(obj)
       		return json.JSONEncoder.default(self, obj)

def main(args):
	dataset = []
	process = subprocess.Popen(['./parseman', args[0]], shell=False, stdout=subprocess.PIPE)
	for line in process.stdout.readlines():
		dataset=learnDev(dataset,line)
	print json.dumps(dataset,indent=1,cls=SetEncoder)

def addToSet(set,el):
	if el:
		set.add(el)
	return set

def learnDev(dataset,com):
	commit = json.loads(com)
	found = False
	for d in dataset:
		if commit['author_name'] in d['Names'] or isEMailSim(commit['author_mail'],d['Mails']):
			addToSet(d['Names'],commit['author_name'])
			addToSet(d['Mails'],commit['author_mail'])
			found = True
			break
	if not found:
		tmp={}
		tmp['Names']=addToSet(set(),commit['author_name'])
		tmp['Mails']=addToSet(set(),commit['author_mail'])
		tmp['Keys']=set()
		dataset.append(tmp)
		print tmp
	found = False
	for d in dataset:
		if commit['committer_name'] in d['Names'] or isEMailSim(commit['committer_mail'],d['Mails']) or commit['signer'] in d['Names'] or commit['signer_key'] in d['Keys']:
			addToSet(d['Names'],commit['committer_name'])
			addToSet(d['Names'],commit['signer']) #Signer makes commit
                        addToSet(d['Mails'],commit['committer_mail'])
			addToSet(d['Keys'],commit['signer_key'])
			found = True
			break
	if not found:
                tmp={}
                tmp['Names']=addToSet(set(),commit['committer_name'])
                tmp['Mails']=addToSet(set(),commit['committer_mail'])
		addToSet(tmp['Names'],commit['signer'])
		tmp['Keys']=addToSet(set(),commit['signer_key'])
                print tmp
		dataset.append(tmp)
	return dataset

def isEMailSim(email1, emails):
	if not isinstance(email1,basestring):
		return False
	username = email1.split("@")[0]
	for mail in emails:
		if mail.startswith(username):
			return True
	return False

if __name__ == "__main__":
	main(sys.argv[1:])
