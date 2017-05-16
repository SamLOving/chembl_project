use chembl_simplified; 

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
    canonical_smiles varchar(4000),
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
    tax_id_component int(11),
    organism_component varchar(150),
    db_source varchar(25),
    db_version varchar(10),
    primary key(tid,component_id)
); 

create table experimental_data (
    assay_id int(9) not null,
    molregno int(9) not null,
    tid int(9) not null,
    activity_id int(11) not null,
    standard_relation varchar(50),
    standard_type varchar(250),
    standard_value decimal(64,30),
    standard_units varchar(100),
    standard_flag tinyint(1),
    activity_comment varchar(4000),
    potential_duplicate tinyint(1),
    doc_id int(9) not null,
    description varchar(4000),
    assay_type varchar(1),
    assay_test_type varchar(20),
    assay_category varchar(20),
    assay_organism varchar(250),
    relationship_type varchar(1),
    confidence_score int(1),
    curated_by varchar(32),
    src_id int(3) not null,
    src_assay_id varchar(50),
    chembl_id varchar(20) not null,
    cell_id int(9),
    bao_format varchar(11)/*,
    primary key(assay_id,activity_id)*/ 
); 

alter table experimental_data add foreign key (molregno) references compounds(molregno); 
alter table experimental_data add foreign key (tid) references proteins(tid); 

/*Fill tables*/ 

insert into compounds (molregno, pref_name, chembl_id, structure_type, molecule_type, 
standard_inchi, standard_inchi_key, canonical_smiles) select molregno, pref_name, chembl_id, structure_type, molecule_type, standard_inchi, standard_inchi_key, 
canonical_smiles from chembl_pre_simplified.compounds; 

insert into proteins (tid, target_type, pref_name, tax_id_target, organism_target, chembl_id, 
component_id, homologue, component_type, accession, sequence, sequence_md5sum, description, tax_id_component, organism_component, db_source, db_version) select 
tid, target_type, pref_name, tax_id_target, organism_target, chembl_id, component_id, homologue, component_type, accession, sequence, sequence_md5sum, description, 
tax_id_component, organism_component, db_source, db_version from chembl_pre_simplified.proteins;
