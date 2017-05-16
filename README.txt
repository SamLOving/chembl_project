Para obtener el modelo simplificado de chembl es necesario:
1) Correr el script sql pre_simplified_chembl.sql
	mysql -uroot -proot chembl_simplified < scripts/pre_simplified_chembl.sql
2) Correr el script sql chembl_simplified.sql
	mysql -uroot -proot chembl_simplified < scripts/chembl_simplified.sql
3) Correr el archivo experimental_data_average.py
	python experimental_data_average.py

Nota: para correr los scripts sql es necesario crear las bases de datos: chembl_pre_simplified y chembl_simplified

