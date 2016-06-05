def calc_similarity(w1, w2):
	return 1-bag_distance(w1,w2)/min([len(w1),len(w2)])
	

def bag_distance(word1,word2):
	l1=list(word1)
	l2=list(word2)
	for char in l1[:]:
		if char in word2:
			l1.remove(char)
	for char in l2[:]:
		if char in word1:
			l1.remove(char)
	return max([len(l1),len(l2)])
