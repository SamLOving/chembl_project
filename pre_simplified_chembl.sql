use chembl_pre_simplified; 
drop table if exists experimental_data cascade; 
drop table if exists compounds cascade; 
drop table if exists proteins cascade; 

/*Create Tables*/ 
create table compounds (
    molregno int(9) not null,
    pref_name varchar(255),
    chembl_id varchar(20),
    structure_type varchar(10),
    molecule_type varchar(30),
    standard_inchi varchar(4000),
    standard_inchi_key varchar(27),
    canonical_smiles	varchar(4000),
    primary key(molregno) 
); 

create table proteins (
    tid int(9) not null,
    target_type varchar(30) not null,
    pref_name varchar(200),
    tax_id_target int(11) unsigned,
    organism_target varchar(150),
    chembl_id varchar(20),
    component_id int(9) not null DEFAULT '0',
    homologue int(1) unsigned /*not*/ null,
    component_type varchar(50),
    accession varchar(25) /*unique*/,
    sequence longtext,
    sequence_md5sum varchar(32),
    description varchar(200),
    tax_id_component    int(11),
    organism_component  varchar(150),
    db_source varchar(25),
    db_version varchar(10),
    primary key(tid,component_id)
);

create table experimental_data (
    assay_id int(9) not null,
    molregno int(9) not null,
    tid int(9) not null,
    activity_id int(11) not null,
    standard_relation	varchar(50),
    standard_type varchar(250),
    standard_value decimal(64,30),
    standard_units varchar(100),
    standard_flag tinyint(1),
    activity_comment	varchar(4000),
    potential_duplicate	tinyint(1),
    doc_id int(9) not null,
    description varchar(4000),
    assay_type varchar(1),
    assay_test_type varchar(20),
    assay_category varchar(20),
    assay_organism varchar(250),
    relationship_type	varchar(1),
    confidence_score	int(1),
    curated_by varchar(32),
    src_id int(3) not null,
    src_assay_id varchar(50),
    chembl_id varchar(20) not null,
    cell_id int(9),
    bao_format varchar(11),
    primary key(assay_id,activity_id)
);

alter table experimental_data add foreign key (molregno) references compounds(molregno); 
alter table experimental_data add foreign key (tid) references proteins(tid); 

/*Fill tables*/ 

insert into compounds (molregno, pref_name, chembl_id, structure_type, molecule_type, 
standard_inchi, standard_inchi_key, canonical_smiles) select m.molregno, pref_name, chembl_id, structure_type, molecule_type, standard_inchi, 
standard_inchi_key, canonical_smiles from chembl_22.molecule_dictionary m, chembl_22.compound_structures c where m.molregno = c.molregno; 

insert into proteins (tid, target_type, pref_name, tax_id_target, organism_target, chembl_id, component_id, homologue, component_type, accession, sequence, 
sequence_md5sum, description, tax_id_component, organism_component, db_source, db_version) 
select td.tid, td.target_type, td.pref_name, td.tax_id, td.organism, td.chembl_id, cs.component_id, tc.homologue, cs.component_type, 
cs.accession, cs.sequence, cs.sequence_md5sum, cs.description, cs.tax_id, cs.organism, cs.db_source, cs.db_version 
from chembl_22.target_components tc 
join chembl_22.component_sequences cs on tc.component_id = cs.component_id 
join chembl_22.target_dictionary td on td.tid = tc.tid
and td.target_type = 'SINGLE PROTEIN'; 

insert into proteins (tid, target_type, pref_name, tax_id_target, organism_target, chembl_id) 
select td.tid, td.target_type, td.pref_name, td.tax_id, 
td.organism, td.chembl_id 
from chembl_22.target_dictionary td
where td.target_type = 'CELL-LINE';

insert into experimental_data (assay_id, molregno, tid, activity_id, standard_relation, standard_type, standard_value, standard_units, standard_flag, 
activity_comment, potential_duplicate, doc_id, description, assay_type, assay_test_type, assay_category, assay_organism, relationship_type, 
confidence_score, curated_by, src_id, src_assay_id, chembl_id, cell_id, bao_format) 
select ass.assay_id, ac.molregno, ass.tid, ac.activity_id, ac.standard_relation, ac.standard_type, ac.standard_value, ac.standard_units, ac.standard_flag, 
ac.activity_comment, ac.potential_duplicate, ass.doc_id, ass.description, ass.assay_type, ass.assay_test_type, ass.assay_category, ass.assay_organism, 
ass.relationship_type, ass.confidence_score, ass.curated_by, ass.src_id, ass.src_assay_id, ass.chembl_id, ass.cell_id, ass.bao_format 
from chembl_22.activities ac 
join chembl_22.assays ass on ac.assay_id = ass.assay_id 
join proteins p on ass.tid = p.tid
join compounds c on ac.molregno = c.molregno
and (ac.standard_type = 'IC50' or ac.standard_type ='Ki' or ac.standard_type ='Kd' or ac.standard_type ='EC50')
and ac.standard_value is not NULL and ac.standard_units is not NULL;
