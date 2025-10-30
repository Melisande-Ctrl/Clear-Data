create schema projet_bdd;
use projet_bdd;
create table etats_capteurs # Création d’une table nommée etats_capteurs
(
    Id_Etat  int auto_increment # Création de la colonne Id_Etat de type int (entier) auto-increment (augmentation automatique de 1 à chaque entrée)

        primary key, # Définition de la colonne Id_Etat comme clé primaire

    Nom_Etat varchar(20) not null # Création d’une colonne Nom_Etat de type chaîne de caractères de taille 20
);

create table régions
(
    Id_Région  int auto_increment
        primary key,
    Nom_Région varchar(30) not null
);

create table typesgaz
(
    Id_TypeGaz int auto_increment
        primary key,
    NomTypeGaz varchar(5) not null
);

create table gaz
(
    Id_Gaz     int auto_increment
        primary key,
    Nom_Gaz    varchar(30) null,
    Sigle      varchar(4)  null,
    Id_TypeGaz int         null,
    constraint Gaz_Type_fk
        foreign key (Id_TypeGaz) references typesgaz (Id_TypeGaz)
    # Définition de la colonne Id_TypeGaz comme clé étrangère faisant référence à la colonne Id_TypeGaz de la table typesgaz
);

create table villes
(
    Id_Ville  int auto_increment
        primary key,
    Nom_Ville varchar(15) not null,
    Id_Région int         not null,
    constraint Villes_Région_fk
        foreign key (Id_Région) references régions (Id_Région)
);

create table adresses
(
    Id_Adresse  int auto_increment
        primary key,
    Nom_Adresse varchar(100) null,
    Id_Ville    int          not null,
    constraint Adresses_Ville_fk
        foreign key (Id_Ville) references villes (Id_Ville)
);

create table agences
(
    Id_Agence int auto_increment
        primary key,
    Id_Ville  int not null,
    constraint Agences_Ville_fk
        foreign key (Id_Ville) references villes (Id_Ville)
);

create table agents_administratifs
(
    Id_Agent_Administratif int auto_increment
        primary key,
    Nom_Ag_Ad              varchar(20) not null,
    Prenom_Ag_Ad           varchar(20) not null,
    Date_Naissance_Ag_Ad   varchar(10) not null,
    Date_Prise_Poste_Ag_Ad varchar(10) not null,
    Id_Adresse             int         not null,
    Id_Agence              int         not null,
    constraint Agents_Administratifs_Adresse_fk
        foreign key (Id_Adresse) references adresses (Id_Adresse),
    constraint Agents_Administratifs_Agence_fk
        foreign key (Id_Agence) references agences (Id_Agence)
);

create table agents_techniques
(
    Id_Agent_Technique       int auto_increment
        primary key,
    Nom_Ag_Tech              varchar(20) not null,
    Prenom_Ag_Tech           varchar(20) not null,
    Date_Naissance_Ag_Tech   varchar(10) not null,
    Date_Prise_Poste_Ag_Tech varchar(10) not null,
    Id_Adresse               int         not null,
    Id_Agence                int         not null,
    constraint Agents_Techniques_Adresse_fk
        foreign key (Id_Adresse) references adresses (Id_Adresse),
    constraint Agents_Techniques_Agence_fk
        foreign key (Id_Agence) references agences (Id_Agence)
);

create table capteurs
(
    Id_Capteur         int auto_increment
        primary key,
    Id_Agent_Technique int         not null,
    Id_Gaz             int         not null,
    Id_Ville           int         not null,
    Date_Installation  varchar(10) not null,
    Id_Etat            int         not null,
    constraint Capteurs_Ag_Tech_fk
        foreign key (Id_Agent_Technique) references agents_techniques (Id_Agent_Technique),
    constraint Capteurs_Etat_fk
        foreign key (Id_Etat) references etats_capteurs (Id_Etat),
    constraint Capteurs_Gaz_fk
        foreign key (Id_Gaz) references gaz (Id_Gaz),
    constraint Capteurs_Ville_fk
        foreign key (Id_Ville) references villes (Id_Ville)
);

create table chefs_agence
(
    Id_Chef               int auto_increment
        primary key,
    Nom_Chef              varchar(20)  not null,
    Prenom_Chef           varchar(20)  not null,
    Date_naissance        varchar(10)  not null,
    Date_Prise_Poste      varchar(10)  not null,
    Titre_dernier_diplome varchar(110) not null,
    Id_Adresse            int          not null,
    Id_Agence             int          not null,
    constraint Chefs_Agence_Adresse_fk
        foreign key (Id_Adresse) references adresses (Id_Adresse),
    constraint Chefs_Agence_Id_Agence_fk
        foreign key (Id_Agence) references agences (Id_Agence)
);

create table relevés
(
    Id_Relevé   int auto_increment
        primary key,
    Date_Relevé varchar(10) not null,
    Valeur      float       not null,
    Id_Capteur  int         not null,
    constraint Relevés_Capteur_fk
        foreign key (Id_Capteur) references capteurs (Id_Capteur)
);

create table rapports
(
    Id_Rapport             int auto_increment
        primary key,
    Date_Publication       varchar(10) not null,
    Id_Agence              int         not null,
    Analyse                text        not null,
    constraint Rapports_Agence_fk
        foreign key (Id_Agence) references agences (Id_Agence)
);

create table `rapports-agents_administratifs`
(
    Id_Rapport            int not null,
    Id_Agent_Administafif int not null,
    constraint `Rapports-Agents_Administratifs_Rapport_fk`
        foreign key (Id_Rapport) references rapports (Id_Rapport),
    constraint `Rapports-Agents_Administratifs_agents_administratifs_fk`
        foreign key (Id_Agent_Administafif) references agents_administratifs (Id_Agent_Administratif)
);

create table `rapports-relevés`
(
    Id_Rapport int null,
    Id_Relevé  int null,
    constraint `Rapports-Relevés_Rapport_fk`
        foreign key (Id_Rapport) references rapports (Id_Rapport),
    constraint `Rapports-Relevés_Relevé_fk`
        foreign key (Id_Relevé) references relevés (Id_Relevé)
);