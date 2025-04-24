-- connecté en tant que COMPTOIR :
GRANT SELECT ON PROVENANCE TO DNF;
GRANT SELECT ON REGION_PROV TO DNF;
GRANT SELECT ON ESPECE TO DNF;
GRANT SELECT ON V_PAYS TO DNF;
GRANT SELECT ON V_TYPEMB TO DNF;
GRANT SELECT ON V_CATPROV TO DNF;

GRANT SELECT ON PROVENANCE TO EF2;
GRANT SELECT ON REGION_PROV TO EF2;
GRANT SELECT ON ESPECE TO EF2;
GRANT SELECT ON V_PAYS TO EF2;
GRANT SELECT ON V_TYPEMB TO EF2;
GRANT SELECT ON V_CATPROV TO EF2;

-- connecté en tant que DNF et EF2 de PLWALO0x: creation d'une vue
CREATE OR REPLACE VIEW PROVENANCE AS
select p.code_dnf_dict refdnf, e.sp_dnf sp,
decode(rp.pays, 'BE', 
       rp.region||' : '||decode(upper(rp.nom),'SANS OBJET','',rp.nom||' - ')||decode(length(p.nom),1,'',p.nom), 
       v_pays.abbr||' : '||rp.code_regprov||' - '||decode(upper(rp.nom),'SANS OBJET','',rp.nom||' - ')||decode(length(p.nom),1,'',p.nom)) provenance, 
decode(rp.pays, 'BE', rp.region, v_pays.abbr) regionpays, 
decode(rp.pays, 'BE', substr(rp.code_regprov,1), null) coderegprov, 
decode(rp.pays, 'BE', substr(rp.nom,1,35), null) regprov, 
v_typemb.trad typematbase, v_catprov.trad categorie, 
p.code_leg codemes, p.code_prov refdga 
from comptoir.provenance p, comptoir.region_prov rp, comptoir.espece e, comptoir.v_pays, 
	 comptoir.v_typemb, comptoir.v_catprov 
where rp.num_regprov=p.NUM_REGPROV and rp.pays=v_pays.code and p.code_sp=e.code_sp 
	  and p.type_mb=v_typemb.code and p.categorie=v_catprov.code and code_dnf_dict is not null
order by p.code_dnf_dict

-- connecté en tant que EF2 sites extérieurs: creation d'un snapshot avec refresh tous les jours a 19h
create materialized view provenance 
refresh complete
START WITH trunc(sysdate) + 19/24
NEXT trunc(sysdate) + 43/24 
as
select p.code_dnf_dict refdnf, e.sp_dnf sp,
decode(rp.pays, 'BE', 
       rp.region||' : '||decode(upper(rp.nom),'SANS OBJET','',rp.nom||' - ')||decode(length(p.nom),1,'',p.nom), 
       v_pays.abbr||' : '||rp.code_regprov||' - '||decode(upper(rp.nom),'SANS OBJET','',rp.nom||' - ')||decode(length(p.nom),1,'',p.nom)) provenance, 
decode(rp.pays, 'BE', rp.region, v_pays.abbr) regionpays, 
decode(rp.pays, 'BE', substr(rp.code_regprov,1), null) coderegprov, 
decode(rp.pays, 'BE', substr(rp.nom,1,35), null) regprov, 
v_typemb.trad typematbase, v_catprov.trad categorie, 
p.code_leg codemes, p.code_prov refdga 
from comptoir.provenance@plwalo02 p, comptoir.region_prov@plwalo02 rp, comptoir.espece@plwalo02 e, 
     comptoir.v_pays@plwalo02, comptoir.v_typemb@plwalo02, comptoir.v_catprov@plwalo02 
where rp.num_regprov=p.NUM_REGPROV and rp.pays=v_pays.code and p.code_sp=e.code_sp 
	  and p.type_mb=v_typemb.code and p.categorie=v_catprov.code and code_dnf_dict is not null
order by p.code_dnf_dict

ALTER TABLE PROVENANCE ADD CONSTRAINT PROVENANCE_I1 UNIQUE (REFDNF);
create index PROVENANCE_I2 on PROVENANCE (SP asc);

