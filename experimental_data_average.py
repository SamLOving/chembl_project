#!/usr/bin/python
def par_ass(num):
	import MySQLdb
	import sys
	import re
	import string
	cnx = MySQLdb.connect(user='smolina', passwd='smolina', db='chembl_pre_simplified')
	cur = cnx.cursor()
	#sys.argv[1]
	cur.execute("SELECT * FROM experimental_data WHERE assay_id = '" + str(num) + "';")
	d = cur.fetchall()
	data_experimental=[]
	for data in d:
		data_experimental.append(list(data))

	#print len(data_experimental)

	#standard_value_average = 0
	for i in xrange(len(data_experimental)-1,0,-1):
		standard_value = float(data_experimental[i][6]) * 10**-9
		if standard_value > 10**-5:
			del data_experimental[i]
		if standard_value > 10**-6 and standard_value < 10**-5:
			del data_experimental[i]
		standard_value += float(data_experimental[i][6])
		if standard_value > 10**-8 and standard_value < 10**-6:
			del data_experimental[i]
		#if i != 0:
			#del data_experimental[i]
	#print len(data_experimental)
	
	#standard_value /= len(data_experimental)
	#data_experimental[0][6] = str(standard_value)

	#cur.execute("insert into experimental_data (assay_id, molregno, tid, activity_id, standard_relation, standard_type, standard_value, standard_units, standard_flag, activity_comment, potential_duplicate, doc_id, description, assay_type, assay_test_type, assay_category, assay_organism, relationship_type, confidence_score, curated_by, src_id, src_assay_id, chembl_id, cell_id, bao_format) values (" + str(data_experimental[0][0]) + ", "  + str(data_experimental[0][1]) + ", " + str(data_experimental[0][2]) + ", " + str(data_experimental[0][3]) + ", " + data_experimental[0][4] + ", " + data_experimental[0][5] + ", " + str(data_experimental[0][6]) + ", " + data_experimental[0][7] + ", " + str(data_experimental[0][8]) + ", " + data_experimental[0][9] + ", " + str(data_experimental[0][10]) + ", " + str(data_experimental[0][11]) + ", " + data_experimental[0][12] + ", " + data_experimental[0][13] + ", " + data_experimental[0][14] + ", " + data_experimental[0][15] + ", " + data_experimental[0][16] + ", " + data_experimental[0][17] + ", " + str(data_experimental[0][18]) + ", " + data_experimental[0][19] + ", " + str(data_experimental[0][20]) + ", " + data_experimental[0][21] + ", " + data_experimental[0][22] + ", " + str(data_experimental[0][23]) + ", " + data_experimental[0][24] +  ")")

	cnx.close()
	cur.close()
	return data_experimental; 

def all_in():
	import MySQLdb
	import sys
	import re
	import string
	cnx = MySQLdb.connect(user='smolina', passwd='smolina', db='chembl_pre_simplified')
	cur = cnx.cursor()
	cur.execute("SELECT distinct(assay_id) FROM experimental_data;")
	cur.execute("delete from experimental_data")
	
	a = cur.fetchall()
	assays=[]

	for ass in a:
		assays.append(ass[0])

	print len(assays)

	for ass in assays:
		prcsv(par_ass(ass))

	cnx.close()
	cur.close()
	return; 


def prcsv(array):
	import csv
	with open('experimental_data.csv', 'a') as csvfile:
	    fieldnames = ['assay_id', 'molregno', 'tid', 'activity_id', 'standard_relation', 'standard_type', 'standard_value', 'standard_units', 
'standard_flag', 'activity_comment', 'potential_duplicate', 'doc_id', 'description', 'assay_type', 'assay_test_type', 'assay_category', 'assay_organism', 
'relationship_type', 'confidence_score', 'curated_by', 'src_id', 'src_assay_id', 'chembl_id', 'cell_id', 'bao_format']
            writer = csv.DictWriter(csvfile, delimiter='\t', fieldnames=fieldnames)
            writer.writeheader()
            for a in array:
	    	writer.writerow({'assay_id': a[0], 'molregno': a[1], 'tid': a[2], 'activity_id': a[3], 'standard_relation': a[4], 'standard_type': a[5], 
'standard_value': a[6], 'standard_units': a[7], 'standard_flag': a[8], 'activity_comment': a[9], 'potential_duplicate': a[10], 'doc_id': a[11], 'description': 
a[12], 'assay_type': a[13], 'assay_test_type': a[14], 'assay_category': a[15], 'assay_organism': a[16], 'relationship_type': a[17], 'confidence_score': a[18], 
'curated_by': a[19], 'src_id': a[20], 'src_assay_id': a[21], 'chembl_id': a[22], 'cell_id': a[23], 'bao_format': a[24]})
            	return;

all_in()
