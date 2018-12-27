import sys, gzip
from Bio.SeqIO.QualityIO import FastqGeneralIterator

id2pos = {}
# both start and end postions in adapter.list are 0-based
with gzip.open(sys.argv[1], 'rt') as f:
	for line in f:
		lst = line.strip().split('\t')
		if not lst[0].startswith('#'):
			id2pos[lst[0]] = int(lst[2])

#print(id2pos)

with gzip.open(sys.argv[2], 'rt') as f_in:
	with gzip.open(sys.argv[3], 'wt') as f_out:
		for (title, sequence, quality) in FastqGeneralIterator(f_in):
			if title in id2pos:
				sequence = sequence[:id2pos[title]]
				quality = quality[:id2pos[title]]
				#f_out.write('@%s\n%s\n+\n%s\n' % (title, sequence, quality))
			f_out.write('@%s\n%s\n+\n%s\n' % (title, sequence, quality))
