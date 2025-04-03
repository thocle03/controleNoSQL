#!/usr/bin/env python3
import sys

def merge_csv_records(input_file, output_file):
    """
    Lit le fichier CSV d'entrée et fusionne les enregistrements dont le contenu
    est réparti sur plusieurs lignes (c'est-à-dire, les lignes contenant des retours à la ligne dans des champs)
    afin que chaque enregistrement soit sur une seule ligne.
    
    La méthode consiste à accumuler des lignes jusqu'à ce que le nombre de guillemets
    (en ignorant les guillemets échappés "") soit pair.
    """
    records = []
    current_record = ""
    
    with open(input_file, 'r', encoding='utf-8') as fin:
        for line in fin:
            line = line.rstrip('\n')
            # Si current_record n'est pas vide, on ajoute un espace pour remplacer le saut de ligne
            if current_record:
                current_record += " " + line
            else:
                current_record = line
            
            # On retire les guillemets échappés et on compte les guillemets restants
            temp = current_record.replace('""', '')
            if temp.count('"') % 2 == 0:
                # Le nombre pair de guillemets indique que l'enregistrement est complet
                records.append(current_record)
                current_record = ""
    
    # S'il reste un enregistrement incomplet en fin de fichier, on l'ajoute quand même
    if current_record:
        records.append(current_record)
    
    # Écriture du résultat dans le fichier de sortie
    with open(output_file, 'w', encoding='utf-8') as fout:
        for rec in records:
            fout.write(rec + "\n")

if __name__ == "__main__":
    input_file = "olist_order_reviews_dataset.csv"
    output_file = "merged_olist_order_reviews_dataset.csv"
    merge_csv_records(input_file, output_file)
    print(f"Le fichier fusionné a été créé : {output_file}")
