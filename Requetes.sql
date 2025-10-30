# 1: Liste de l'ensemble des agences
SELECT agences.Id_Agence, v.Nom_Ville FROM agences JOIN villes v on agences.Id_Ville = v.Id_Ville;

# 2: Liste de l'ensemble du personnel technique de l'agence de Bordeaux
SELECT ag.Id_Agent_Technique, ag.Nom_Ag_Tech, ag.Prenom_Ag_Tech FROM agents_techniques ag
    JOIN agences ON ag.Id_Agence = agences.Id_Agence
    WHERE agences.Id_Ville = (SELECT villes.Id_Ville FROM villes WHERE villes.Nom_Ville = 'Bordeaux');
    # à noter que le where select prend moins de ressources qu'une jointure

# 3: Nombre total de capteurs déployés (total : 606)
SELECT COUNT(Id_Capteur) AS Nombre_Capteurs FROM capteurs;

# 4: Liste des rapports publiés entre 2018 et 2022
SELECT * FROM rapports WHERE '2018-01-01' < Date_Publication < '2022-12-31';

# 5: Afficher les concentrations de CH4 (en ppm) dans les régions « Ile-de-France », « Bretagne » et « Occitanie »
#   en mai et juin 2023 (Nombre : 48)
SELECT Id_Relevé, Date_Relevé, Valeur, Nom_Région FROM relevés
    JOIN capteurs c on relevés.Id_Capteur = c.Id_Capteur
    JOIN gaz on gaz.Id_Gaz = c.Id_Gaz
    JOIN villes v on v.Id_Ville = c.Id_Ville
    JOIN régions r on v.Id_Région = r.Id_Région
    WHERE gaz.Sigle ='CH4' AND Date_Relevé BETWEEN '2023-05-01' AND '2023-06-30'
      AND Nom_Région IN ( 'Ile-de-France', 'Bretagne', 'Occitanie');

# 6: Liste des noms des agents techniques maintenant des capteurs
#   concernant les gaz à effet de serre provenant de l’industrie (GESI)
SELECT DISTINCT ag.Id_Agent_Technique, ag.Nom_Ag_Tech, ag.Prenom_Ag_Tech FROM agents_techniques ag
    JOIN capteurs c on ag.Id_Agent_Technique = c.Id_Agent_Technique
    JOIN gaz on gaz.Id_Gaz = c.Id_Gaz
    WHERE gaz.Id_Gaz =
    (SELECT Id_TypeGaz FROM typesgaz WHERE NomTypeGaz = 'GESI');
    # à noter que le where select prend moins de ressources qu'une jointure

# 7: Titres et dates des rapports concernant des concentrations de NH3, classés par ordre antichronologique
SELECT rapports.Id_Rapport, Date_Publication FROM rapports
    JOIN `rapports-relevés` rpr ON rapports.Id_Rapport = rpr.Id_Rapport
    JOIN relevés r ON rpr.Id_Relevé = r.Id_Relevé
    JOIN capteurs c on r.Id_Capteur = c.Id_Capteur
    JOIN gaz on gaz.Id_Gaz = c.Id_Gaz
    WHERE gaz.Sigle ='NH3'
    GROUP BY rapports.Id_Rapport, Date_Publication
    ORDER BY Date_Publication DESC;

# 8: Afficher le mois où la concentration de HFC a été la moins importante pour chaque région
SELECT r1.Nom_Région, r1.Mois, r2.min_val
    FROM (
        SELECT rg.Nom_Région,
           DATE_FORMAT(r.Date_Relevé, '%Y-%m') AS Mois,
           r.Valeur AS min_concentration
        FROM relevés r JOIN capteurs c ON r.Id_Capteur = c.Id_Capteur
        JOIN gaz ON c.Id_Gaz = gaz.Id_Gaz
        JOIN villes v ON c.Id_Ville = v.Id_Ville
        JOIN régions rg ON v.Id_Région = rg.Id_Région
        WHERE gaz.Sigle = 'HFC'
    ) AS r1
    JOIN (
        SELECT rg.Nom_Région,
               MIN(r.Valeur) AS min_val
        FROM relevés r JOIN capteurs c ON r.Id_Capteur = c.Id_Capteur
        JOIN gaz ON c.Id_Gaz = gaz.Id_Gaz
        JOIN villes v ON c.Id_Ville = v.Id_Ville
        JOIN régions rg ON v.Id_Région = rg.Id_Région
        WHERE gaz.Sigle = 'HFC'
        GROUP BY rg.Nom_Région
    ) AS r2
    ON r1.Nom_Région = r2.Nom_Région AND r1.min_concentration = r2.min_val;

# 9: Moyenne des concentrations (en ppm) dans la région « Ile-de-France » en 2020, pour chaque gaz étudié
SELECT gaz.Nom_Gaz, AVG(r.Valeur) AS moyenne_ppm
    FROM relevés r
    JOIN capteurs c ON r.Id_Capteur = c.Id_Capteur
    JOIN gaz ON c.Id_Gaz = gaz.Id_Gaz
    JOIN villes v ON c.Id_Ville = v.Id_Ville
    JOIN régions rg ON v.Id_Région = rg.Id_Région
    WHERE rg.Nom_Région = 'Ile-de-France' AND r.Date_Relevé BETWEEN '2020-01-01' AND '2020-12-31'
    GROUP BY gaz.Nom_Gaz;

# 10: Taux de productivité des agents administratifs de l'agence de Toulouse (le taux est
#   calculé en nombre de rapports écrits par mois en moyenne, sur la durée de leur contrat)
#   intervalle des dates entre janvier 2017 et décembre 2024 donc date "actuelle" = 31/12/2024
SELECT ad.Id_Agent_Administratif, ad.Nom_Ag_Ad,ad.Prenom_Ag_Ad,
    COUNT(r.Id_Rapport) /
    (TIMESTAMPDIFF(MONTH, ad.Date_Prise_Poste_Ag_Ad, '2024-12-31'))
        AS Taux_Productivite
    FROM agents_administratifs ad
    JOIN `rapports-agents_administratifs` rp_ad ON ad.Id_Agent_Administratif = rp_ad.Id_Agent_Administafif
    JOIN rapports r ON rp_ad.Id_Rapport = r.Id_Rapport
    JOIN agences ag ON ad.Id_Agence = ag.Id_Agence
    JOIN villes v ON ag.Id_Ville = v.Id_Ville
    WHERE v.Nom_Ville = 'Toulouse'
    GROUP BY ad.Id_Agent_Administratif;

# 11: Pour un gaz donné, liste des rapports contenant des données qui le concernent
#   (on doit pouvoir donner le nom du gaz en paramètre)
# Remplacer 'CO2' par le nom du gaz voulu
SELECT DISTINCT r.Id_Rapport, Date_Publication FROM rapports r
    JOIN `rapports-relevés` rp_r ON r.Id_Rapport = rp_r.Id_Rapport
    JOIN relevés rel ON rp_r.Id_Relevé = rel.Id_Relevé
    JOIN capteurs c ON rel.Id_Capteur = c.Id_Capteur
    JOIN gaz ON c.Id_Gaz = gaz.Id_Gaz
    WHERE gaz.Sigle = 'CO2';

# 12: Liste des régions dans lesquelles il y a plus de capteurs que de personnel d’agence
SELECT rg.Id_Région, Nom_Région FROM régions rg
    JOIN villes v ON rg.Id_Région = v.Id_Région
    LEFT JOIN capteurs c ON v.Id_Ville = c.Id_Ville
    JOIN agences a ON v.Id_Ville = a.Id_Ville
    LEFT JOIN agents_techniques ag ON a.Id_Agence = ag.Id_Agence
    LEFT JOIN agents_administratifs ad ON a.Id_Agence = ad.Id_Agence
    LEFT JOIN chefs_agence ch on a.Id_Agence = ch.Id_Agence
    GROUP BY rg.Id_Région
    HAVING COUNT(DISTINCT c.Id_Capteur) >
       COUNT(DISTINCT ag.Id_Agent_Technique) + COUNT(DISTINCT ad.Id_Agent_Administratif) + COUNT(DISTINCT ch.Id_Chef);